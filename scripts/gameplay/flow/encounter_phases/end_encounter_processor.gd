class_name EndEncounterProcessor
extends BaseProcessor
	
	
func on_execute() -> void:
	if not Contexts.encounter_context \
	or not Contexts.encounter_context.check_result: return
	
	var was_success := Contexts.encounter_context.check_result.was_success
	var card := Contexts.encounter_context.card
	
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
				var close_processor := NewResolvableProcessor.new(close_resolvable)
				GameServices.game_flow.interrupt(close_processor)),
			ChoiceOption.new("Skip", func(): pass)
		])

		var next_processor := NewResolvableProcessor.new(close_choice_resolvable)
		GameServices.game_flow.interrupt(next_processor)

	Contexts.end_encounter()
	
	
func _is_closing_henchman(card: CardInstance) -> bool:
	if !card or !Contexts.game_context or !Contexts.game_context.scenario_data: return false
	
	var henchmen := Contexts.game_context.scenario_data.henchmen
	return henchmen.any(func(h: StoryBane): return h.card_data.card_id == card.data.card_id and h.is_closing)
