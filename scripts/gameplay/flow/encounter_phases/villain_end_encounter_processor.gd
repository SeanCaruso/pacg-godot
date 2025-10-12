class_name VillainEndEncounterProcessor
extends BaseProcessor
	
	
func execute() -> void:
	if not Contexts.encounter_context \
	or not Contexts.encounter_context.check_result:
		return
	
	var was_success := Contexts.encounter_context.check_result.was_success
	var card := Contexts.encounter_context.card
	
	var guarded_locs: Dictionary = {}
	if Contexts.turn_context and Contexts.turn_context.guard_locations_resolvable:
		guarded_locs = Contexts.turn_context.guard_locations_resolvable.distant_locs_guarded
	
	var escape_locs: Array[Location] = []
	for loc in Contexts.game_context.locations:
		if not guarded_locs.get(loc, false):
			escape_locs.append(loc)
	
	if not was_success:
		escape_locs.append(Contexts.encounter_pc_location)
	
	if was_success:
		card.on_defeated()
	else:
		card.on_undefeated()
		
	GameEvents.encounter_ended.emit()
	
	if was_success and _is_closing_henchman(card):
		var pc := Contexts.encounter_context.character
		
		var close_choice_resolvable = PlayerChoiceResolvable.new("Close location?", [
			ChoiceOption.new("Close", func():
				var close_resolvable: BaseResolvable = pc.location.to_close_resolvable
				TaskManager.push(close_resolvable)
				),
			ChoiceOption.new("Skip", func(): pass)
		])

		TaskManager.push(close_choice_resolvable)

	Contexts.end_encounter()
	
	
func _is_closing_henchman(card: CardInstance) -> bool:
	if !card or !Contexts.game_context or !Contexts.game_context.scenario_data: return false
	
	var henchmen := Contexts.game_context.scenario_data.henchmen
	return henchmen.any(func(h: StoryBane): return h.card_data.card_id == card.data.card_id and h.is_closing)
