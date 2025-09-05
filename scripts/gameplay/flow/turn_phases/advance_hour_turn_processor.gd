class_name AdvanceHourTurnProcessor
extends BaseProcessor

const TurnPhase := preload("res://scripts/core/enums/turn_phase.gd").TurnPhase
	
	
func on_execute() -> void:
	if !_contexts.turn_context: return
	
	_contexts.turn_context.current_phase = TurnPhase.TURN_START
	
	var hour_card := _contexts.game_context.hour_deck.draw_card()
	_contexts.turn_context.hour_card = hour_card
	GameEvents.hour_changed.emit(hour_card)
	
	# TODO: Handle hour powers.
