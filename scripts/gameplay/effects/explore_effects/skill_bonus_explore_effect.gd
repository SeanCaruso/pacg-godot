class_name SkillBonusExploreEffect
extends BaseExploreEffect

const Skill := preload("res://scripts/core/enums/skill.gd").Skill

var dice_count: int
var die_size: int
var bonus: int
var is_for_one_check: bool
var skills: Array[Skill] = []
var traits: Array[String] = []

func _init(
	_dice_count: int,
	_die_size: int,
	_bonus: int,
	_is_for_one_check: bool,
	_skills: Array[Skill] = []
):
	dice_count = _dice_count
	die_size = _die_size
	bonus = _bonus
	is_for_one_check = _is_for_one_check
	skills = _skills

func set_traits(trait_string: String):
	traits = [trait_string]

func apply_to(check: CheckContext, dice_pool: DicePool):
	if not does_apply_to(check): return
	
	dice_pool.add_dice(dice_count, die_size, bonus)
	
	var bonus_str := "+%s" % bonus if bonus > 0 else ""
	print("Added %dd%d%s to check." % [dice_count, die_size, bonus_str])


func does_apply_to(check: CheckContext) -> bool:
	if not check: return false
	
	if skills.is_empty() and traits.is_empty(): return true
	
	if not skills.is_empty() and not traits.is_empty():
		printerr("Found an exploration bonus with both skills and traits!")
		return false
	
	if not skills.is_empty() and skills.has(check.used_skill):
		return true
	
	if not traits.is_empty() and check.invokes(traits):
		return true
	
	return false
