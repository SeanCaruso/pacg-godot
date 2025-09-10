class_name RecoveryTurnProcessor
extends BaseProcessor

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const TurnPhase := preload("res://scripts/core/enums/turn_phase.gd").TurnPhase


func on_execute() -> void:
	if !_contexts.turn_context: return
	
	_contexts.turn_context.current_phase = TurnPhase.RECOVERY
	
	var recovery_cards := GameServices.cards.get_cards_in_location(CardLocation.RECOVERY)
	if recovery_cards.is_empty(): return
	
	# Continue to run this processor until all recovery cards are gone.
	_game_flow.interrupt(self)
	
	var card: CardInstance = recovery_cards.pop_front()
	var resolvable := card.get_recovery_resolvable()
	if resolvable:
		_contexts.new_resolvable(resolvable)
