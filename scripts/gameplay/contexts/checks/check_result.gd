class_name CheckResult
extends RefCounted

const Skill := preload("res://scripts/core/enums/skill.gd").Skill

var final_roll_total: int
var dc: int

var was_success: bool:
	get: return final_roll_total >= dc

var margin_of_success: int:
	get: return final_roll_total - dc

var character: PlayerCharacter
var is_combat: bool
var skill: Skill
var traits: Array[String]

func _init(roll_total: int, _dc: int, _character: PlayerCharacter, _is_combat: bool, _skill: Skill, _traits: Array[String]):
	final_roll_total = roll_total
	dc = _dc
	character = _character
	is_combat = _is_combat
	skill = _skill
	traits = _traits
