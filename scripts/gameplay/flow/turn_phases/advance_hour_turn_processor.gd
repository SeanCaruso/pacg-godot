class_name AdvanceHourTurnProcessor
extends BaseProcessor

const TurnPhase := preload("res://scripts/core/enums/turn_phase.gd").TurnPhase
	
	
func execute() -> void:
	if not Contexts.turn_context:
		return
	
	Contexts.turn_context.current_phase = TurnPhase.TURN_START
	
	if Contexts.game_context.hour_deck.count == 0:
		GameEvents.emit_game_ended(false)
		return
	
	var hour_card := Contexts.game_context.hour_deck.draw_card()
	Contexts.turn_context.hour_card = hour_card
	GameEvents.emit_hour_changed(hour_card)
	
	# TODO: Handle hour powers.
