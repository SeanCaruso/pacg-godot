# CheckStep.gd
class_name CheckStep
extends Resource

const Skill := preload("res://scripts/core/enums/skill.gd").Skill

enum CheckCategory {
	COMBAT,
	SKILL,
	CUSTOM,
	NONE # Used by CheckModifier to indicate no restricted categories
}

# DC
@export var base_dc: int
@export var adventure_level_mult: int

#Check Type
@export var category: CheckCategory
@export var allowed_skills: Array[Skill] = []
@export var custom_text: String
