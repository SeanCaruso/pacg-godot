class_name CaravanLogic
extends LocationLogicBase

const Skill := preload("res://scripts/core/enums/skill.gd").Skill


func caravan_at_location():
	DialogEvents.move_clicked_event.emit(Contexts.game_context.active_character)


func get_card_to_close_resolvable(loc: Location, pc: PlayerCharacter, callback: Callable) -> BaseResolvable:
	return PlayerChoiceResolvable.new(
		"Close %s?" % loc.name,
		[
			ChoiceOption.new("Skill Check", func():
				var skill_resolvable := _skill_check_close_resolvable(loc, pc)
				skill_resolvable.on_success = callback
				TaskManager.start_task(skill_resolvable)),
			
			ChoiceOption.new("Summon Danger", func():
				var danger_encounter = _danger_close_encounter(loc, pc)
				danger_encounter.on_success = callback
				TaskManager.start_task(danger_encounter)),
			
			ChoiceOption.new("Cancel", func(): pass)
		]
	)


func _skill_check_close_resolvable(loc: Location, pc: PlayerCharacter) -> CheckResolvable:
	var dc := 5 + Contexts.game_context.adventure_number
	
	var resolvable := CheckResolvable.new(
		loc,
		pc,
		CardUtils.skill_check(dc, [Skill.WISDOM, Skill.PERCEPTION])
	)
	if Contexts.turn_context.guard_locations_resolvable:
		resolvable.verb = CheckResolvable.CheckVerb.GUARD
	else:
		resolvable.verb = CheckResolvable.CheckVerb.CLOSE
	return resolvable


func _danger_close_encounter(loc: Location, pc: PlayerCharacter) -> Task:
	if not Contexts.game_context \
	or not Contexts.game_context.scenario_data \
	or not Contexts.game_context.scenario_data.dangers \
	or Contexts.game_context.scenario_data.dangers.is_empty():
		push_warning("%s: Unable to find a Danger. Creating a skill check." % loc)
		return _skill_check_close_resolvable(loc, pc)
	
	var danger := Contexts.game_context.scenario_data.dangers[0]
	var danger_instance := Cards.new_card(danger.card_data)
	if not danger.custom_name.is_empty():
		danger_instance.name = danger.custom_name
	
	return EncounterController.new(pc, danger_instance)
