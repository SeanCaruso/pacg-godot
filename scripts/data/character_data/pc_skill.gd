class_name PcSkill
extends Resource

const Skill := preload("res://scripts/core/enums/skill.gd").Skill

@export var skill: Skill
@export var attribute: Skill
@export var bonus: int
