class_name ExploreTurnProcessor
extends BaseProcessor

func on_execute() -> void:
	if !_contexts.turn_context: return
	
	_contexts.turn_context.can_give = false
	_contexts.turn_context.can_move = false
	_contexts.turn_context.can_freely_explore = false
	_contexts.turn_context.can_close_location = false
	
	GameEvents.turn_state_changed.emit()
	
	var explored_card := _contexts.turn_pc_location.draw_card()
	if !explored_card:
		printerr("[%s] Explored card was null!" % self)
		return
	
	var encounter_processor := EncounterController.new(_contexts.turn_context.character, explored_card)
	_game_flow.start_phase(encounter_processor, "Explore: %s" % explored_card)
