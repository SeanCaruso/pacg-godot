class_name CheckTypeDeterminator
extends RefCounted

const CheckCategory := preload("res://scripts/data/card_data/check_step.gd").CheckCategory
const Skill := preload("res://scripts/core/enums/skill.gd").Skill

var _resolvable: CheckResolvable

var _check_restriction: CheckCategory = CheckCategory.NONE
var _category_restriction_cards: Array[CardInstance] = []

var is_combat_valid: bool:
	get: return _resolvable.has_combat and _check_restriction != CheckCategory.SKILL

var is_skill_valid: bool:
	get: return _resolvable.has_skill and _check_restriction != CheckCategory.COMBAT

func _init(resolvable: CheckResolvable):
	_resolvable = resolvable
	
	
func restrict_check_category(card: CardInstance, category: CheckCategory):
	_check_restriction = category
	_category_restriction_cards.push_back(card)
	
	
func get_forced_check_step() -> CheckStep:
	if _check_restriction == CheckCategory.NONE: return null
	return _resolvable.check_steps.filter(func(step): return step.category == _check_restriction)[0]
	
	
func get_dc_for_skill(skill: Skill):
	var forced_step := get_forced_check_step()
	if forced_step:
		return CardUtils.get_dc(forced_step.base_dc, forced_step.adventure_level_mult)
		
		
	var step_with_skill: CheckStep = _resolvable.check_steps.filter(func(step: CheckStep): return step.allowed_skills.has(skill))[0]
	return CardUtils.get_dc(step_with_skill.base_dc, step_with_skill.adventure_level_mult)
