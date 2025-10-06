class_name ExploreTurnProcessor
extends BaseProcessor

func execute() -> void:
	if !Contexts.turn_context: return
	
	Contexts.turn_context.can_give = false
	Contexts.turn_context.can_move = false
	Contexts.turn_context.can_freely_explore = false
	Contexts.turn_context.can_close_location = false
	
	GameEvents.turn_state_changed.emit()
	
	var explored_card := Contexts.turn_context.character.location.draw_card()
	if !explored_card:
		printerr("[%s] Explored card was null!" % self)
		return
	
	var encounter_processor := EncounterController.new(Contexts.turn_context.character, explored_card)
	TaskManager.start_task(encounter_processor)
