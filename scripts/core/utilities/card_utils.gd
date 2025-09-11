class_name CardUtils
extends Node

const Skill := preload("res://scripts/core/enums/skill.gd").Skill

static var _is_initialized: bool = false
static var adventure_number: int = 1


static func initialize(_adventure_number: int):
	_is_initialized = true
	adventure_number = _adventure_number


static func create_default_recovery_resolvable(check_resolvable: CheckResolvable) -> PlayerChoiceResolvable:
	check_resolvable.verb = CheckResolvable.CheckVerb.RECOVER
	
	var choice_resolvable := PlayerChoiceResolvable.new(
		"Recover?",
		[
			ChoiceOption.new("Yes", func():
				var processor := NewResolvableProcessor.new(check_resolvable)
				GameServices.game_flow.interrupt(processor)),
			ChoiceOption.new("No", func(): pass)
		]
	)
	choice_resolvable.card = check_resolvable.card
	
	return choice_resolvable


static func create_explore_choice() -> PlayerChoiceResolvable:
	return PlayerChoiceResolvable.new(
		"Explore?", [
			ChoiceOption.new(
				"Explore",
				func(): GameServices.game_flow.queue_next_processor(ExploreTurnProcessor.new())
			),
			ChoiceOption.new("Forfeit\nExploration", func(): pass)
		]
	)


static func get_dc(base_dc: int, adventure_level_mult: int) -> int:
	if !_is_initialized:
		assert(false, "CardUtils MUST be initialized!!!")
	
	return base_dc + adventure_level_mult * adventure_number


static func skill_check(base_dc: int, skills: Array[Skill]) -> CheckRequirement:
	var req := CheckRequirement.new()
	req.mode = CheckRequirement.CheckMode.SINGLE
	
	var check_step := CheckStep.new()
	check_step.category = CheckStep.CheckCategory.SKILL
	check_step.base_dc = base_dc
	check_step.allowed_skills.append_array(skills)
	req.check_steps = [check_step]
	
	return req
