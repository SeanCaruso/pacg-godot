class_name AttributeSkill
extends Resource

const Skill := preload("res://scripts/core/enums/skill.gd").Skill

@export var attribute: Skill
@export var die: int
@export var bonus: int