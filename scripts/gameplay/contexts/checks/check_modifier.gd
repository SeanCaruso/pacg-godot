class_name CheckModifier
extends RefCounted

const CheckCategory = preload("res://scripts/data/check_step.gd").CheckCategory
const Skill = preload("res://scripts/core/enums/skill.gd").Skill

var source_card: CardInstance

# Skill modifications
var restricted_skills: Array[Skill] = []
var added_valid_skills: Array[Skill] = []
var required_traits: Array[String] = []
var prohibited_traits: Array[String] = []

# Category modifications
var restricted_category: CheckCategory = CheckCategory.NONE

# Dice modifications
var added_dice: Array[int] = []
var added_bonus: int = 0
var skill_dice_to_add: int = 0
var die_override: int = -1 # Positive value indicates it was set

# Trait modifications
var added_traits: Array[String] = []

func _init(_source_card: CardInstance):
	source_card = _source_card