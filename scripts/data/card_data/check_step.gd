# CheckStep.gd
class_name CheckStep
extends Resource

const SkillEnum = preload("res://scripts/core/enums/Skill.gd")

enum CheckCategory {
	COMBAT,
	SKILL,
	NONE # Used by CheckModifier to indicate no restricted categories
}

# DC
@export var base_dc: int
@export var adventure_level_mult: int

#Check Type
@export var category: CheckCategory
@export var allowed_skills: Array[SkillEnum.Skill] = []
