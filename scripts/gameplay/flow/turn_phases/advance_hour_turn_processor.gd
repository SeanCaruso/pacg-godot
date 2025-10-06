class_name AdvanceHourTurnProcessor
extends BaseProcessor

const TurnPhase := preload("res://scripts/core/enums/turn_phase.gd").TurnPhase
	
	
func execute() -> void:
	if !Contexts.turn_context: return
	
	Contexts.turn_context.current_phase = TurnPhase.TURN_START
	
	var hour_card := Contexts.game_context.hour_deck.draw_card()
	Contexts.turn_context.hour_card = hour_card
	GameEvents.hour_changed.emit(hour_card)
	
	# TODO: Handle hour powers.
