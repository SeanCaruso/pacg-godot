class_name EndEncounterProcessor
extends BaseProcessor
	
	
func on_execute() -> void:
	if !_contexts.encounter_context: return
	
	var was_success := _contexts.encounter_context.check_result.was_success
	var card := _contexts.encounter_context.card
	
	if was_success:
		card.on_defeated()
	else:
		card.on_undefeated()
		
	GameEvents.encounter_ended.emit()
	
	if was_success and _is_closing_henchman(card):
		var pc := _contexts.encounter_context.character
		
		var close_choice_resolvable = PlayerChoiceResolvable.new("Close location?", [
			ChoiceOption.new("Close", func():
				var close_resolvable: BaseResolvable = pc.location.get_to_close_resolvable()
				var close_processor := NewResolvableProcessor.new(close_resolvable)
				_game_flow.interrupt(close_processor)),
			ChoiceOption.new("Skip", func(): pass)
		])

		var next_processor := NewResolvableProcessor.new(close_choice_resolvable)
		_game_flow.interrupt(next_processor)

	_contexts.end_encounter()
	
	
func _is_closing_henchman(card: CardInstance) -> bool:
	if !card or !_contexts.game_context or !_contexts.game_context.scenario_data: return false
	
	var henchmen := _contexts.game_context.scenario_data.henchmen
	return henchmen.any(func(h: StoryBane): return h.card_data.card_id == card.data.card_id and h.is_closing)
