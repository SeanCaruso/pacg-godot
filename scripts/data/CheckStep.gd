# CheckStep.gd
class_name CheckStep
extends Resource

enum CheckCategory { COMBAT, SKILL }

# DC
@export var base_dc: int
@export var adventure_level_mult: int

#Check Type
@export var category: CheckCategory
@export var allowed_skills: Array[Skill.Type] = []
