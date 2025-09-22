class_name CheckSkillAccumulator
extends RefCounted

const CheckCategory := preload("res://scripts/data/card_data/check_step.gd").CheckCategory
const Skill         := preload("res://scripts/core/enums/skill.gd").Skill
var _base_valid_skills: Array[Skill]       = []
var _staged_skill_additions: Dictionary    = {} # CardInstance -> Array[Skill]
var _staged_skill_restrictions: Dictionary = {} # CardInstance -> Array[Skill]


func _init(resolvable: CheckResolvable):
	for check_step in resolvable.check_steps:
		if check_step.category == CheckCategory.COMBAT:
			_base_valid_skills.append_array([Skill.STRENGTH, Skill.MELEE])
		
		else:
			_base_valid_skills.append_array(check_step.allowed_skills)


func add_valid_skills(card: CardInstance, skills: Array[Skill]) -> void:
	_staged_skill_additions.get_or_add(card, []).append_array(skills)


func are_skills_blocked(skills: Array[Skill]) -> bool:
	if _staged_skill_restrictions.is_empty():
		return false
	
	for skill_restrictions in _staged_skill_restrictions.values():
		skills = skills.filter(func(s): return s in skill_restrictions)
	return skills.is_empty()


func restrict_valid_skills(card: CardInstance, skills: Array[Skill]) -> void:
	if (skills.is_empty()): return
	_staged_skill_restrictions.get_or_add(card, []).append_array(skills)


## Returns true if at least one of the given skills is a valid skill.
func has_valid_skill(skills: Array[Skill]) -> bool:
	for _skill in skills:
		if get_current_valid_skills().has(_skill): return true
	
	return false


func get_current_valid_skills() -> Array[Skill]:
	var skills := _base_valid_skills.duplicate()
	
	# Apply all additions - add unique skills from staged actions
	for added_skills in _staged_skill_additions.values():
		for _skill in added_skills:
			if _skill not in skills: skills.append(_skill)
			
	# Apply all restrictions - intersection logic
	for restriction in _staged_skill_restrictions.values():
		skills = skills.filter(func(_skill): return _skill in restriction)
	
	return skills
