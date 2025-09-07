class_name CheckContext
extends RefCounted

const CheckCategory := preload("res://scripts/data/card_data/check_step.gd").CheckCategory
const Skill := preload("res://scripts/core/enums/skill.gd").Skill

var _skills: CheckSkillAccumulator
var _type_determinator: CheckTypeDeterminator
var _traits: TraitAccumulator

var explore_effects: Array[BaseExploreEffect] = []

var resolvable: CheckResolvable

var character: PlayerCharacter:
	get: return resolvable.character

func _init(check_resolvable: CheckResolvable):
	resolvable = check_resolvable
	
	_skills = CheckSkillAccumulator.new(check_resolvable)
	_type_determinator = CheckTypeDeterminator.new(check_resolvable)
	_traits = TraitAccumulator.new(check_resolvable)
	
	used_skill = character.get_best_skill(get_current_valid_skills())["skill"]
	
	
func update_preview_state(staged_actions: Array[StagedAction]):
	# Start from a fresh state
	_skills = CheckSkillAccumulator.new(resolvable)
	_type_determinator = CheckTypeDeterminator.new(resolvable)
	_traits = TraitAccumulator.new(resolvable)
	
	# Gather and apply modifiers
	for action in staged_actions:
		if action is not PlayCardAction: continue
		
		var modifier = (action as PlayCardAction).check_modifier
		if not modifier: continue
		
		# Do this first - the skill selection dialog uses it to determine the DC for the selected
		# skill, but if something forces a Combat check, we need to know that first.
		if modifier.restricted_category != CheckCategory.NONE:
			_type_determinator.restrict_check_category(modifier.source_card, modifier.restricted_category)
			
			
		_skills.restrict_valid_skills(modifier.source_card, modifier.restricted_skills)
		_skills.add_valid_skills(modifier.source_card, modifier.added_valid_skills)
		_traits.add_traits(modifier.source_card, modifier.added_traits)
		_traits.add_required_traits(modifier.source_card, modifier.required_traits)
		_traits.add_prohibited_traits(modifier.source_card, modifier.prohibited_traits)
		
	GameEvents.dice_pool_changed.emit(DicePoolBuilder.build(self, staged_actions))
	
	# Update the context
	var new_valid_skills = get_current_valid_skills()
	if !new_valid_skills.has(used_skill):
		used_skill = character.get_best_skill(new_valid_skills).skill
		
	DialogEvents.valid_skills_changed.emit(new_valid_skills)
	
	
func get_current_valid_skills() -> Array[Skill]:
	var valid_skills := _skills.get_current_valid_skills()
	if _traits.required_traits.is_empty(): return valid_skills
	
	for i in range(valid_skills.size() - 1, -1, -1):
		var skill := valid_skills[i]
		var attr = character.get_attribute_for_skill(skill)
		if !_traits.required_traits.has(str(skill).to_pascal_case()) and !_traits.required_traits.has(str(attr).to_pascal_case()):
			valid_skills.remove_at(i)
		
	return valid_skills
	
# =====================================================================================
# TRAITS
# =====================================================================================
## ALl traits currently invoked by the check
var traits: Array[String]:
	get:
		var ret := _traits.traits
		ret.append(str(used_skill).to_pascal_case())
		if character.get_attribute_for_skill(used_skill) != used_skill:
			ret.append(str(character.get_attribute_for_skill(used_skill)).to_pascal_case())
		return ret

## Returns whether the check invokes any of the given traits.
##
## A check invokes a trait if the card played to determine the skill has the trait,
## or if the card that triggered the check has the trait.
func invokes(some_traits: Array[String]) -> bool:
	for given_trait in some_traits:
		if traits.has(given_trait): return true
	return false
	
# =====================================================================================
# TYPE DETERMINATION PASSTHROUGHS TO CheckTypeDeterminator
# =====================================================================================
var is_combat_valid: bool:
	get: return _type_determinator.is_combat_valid

var is_combat_check: bool:
	get: return get_active_check_step().category == CheckCategory.COMBAT

var is_skill_valid: bool:
	get: return _type_determinator.is_skill_valid

func get_dc_for_skill(skill: Skill) -> int:
	return _type_determinator.get_dc_for_skill(skill)
	
	
func get_active_check_step() -> CheckStep:
	var forced_step := _type_determinator.get_forced_check_step()
	if forced_step: return forced_step
	
	var steps_with_skill = resolvable.check_steps.filter(func(step: CheckStep): return step.allowed_skills.has(used_skill))
	if !steps_with_skill.is_empty(): return steps_with_skill[0]
	
	return resolvable.check_steps[0]
	
	
func get_dc() -> int:
	return CardUtils.get_dc(get_active_check_step().base_dc, get_active_check_step().adventure_level_mult)
	
# =====================================================================================
# SKILL PASSTHROUGHS TO CheckSkillAccumulator
# =====================================================================================
## Convenience function to determine if a card power with the given skills can be played on the
## current set of valid skills for the check.
func can_use_skill(skills: Array[Skill]) -> bool:
	return _skills.can_use_skill(skills)

# =====================================================================================
# CHECK RESULTS ENCAPSULATION
# =====================================================================================
var committed_actions: Array[StagedAction] = []
var used_skill: Skill
var check_result: CheckResult

func dice_pool(actions: Array[StagedAction]) -> DicePool:
	return DicePoolBuilder.build(self, actions)
	
	
# Custom data
var context_data: Dictionary = {} # String -> Variant

# =====================================================================================
# CONVENIENCE FUNCTIONS
# =====================================================================================
## Returns whether the given PC is in the same location as the PC making the check.
func is_local(pc: PlayerCharacter) -> bool:
	return pc.location == character.location
