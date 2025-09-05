## Turn sub-processor for any automatic stuff that happens between turns
class_name NextTurnTurnProcessor
extends BaseProcessor

func on_execute() -> void:
	if !_contexts.turn_context or !_contexts.turn_context.character: return
	
	_contexts.turn_context.character.draw_to_hand_size()
	
	var idx := _contexts.game_context.characters.find(_contexts.turn_context.character) + 1
	idx %= _contexts.game_context.characters.size()
	var next_pc := _contexts.game_context.characters[idx]
	
	_contexts.end_turn()
	_game_flow.queue_next_processor(StartTurnController.new(next_pc, _game_services))
	
	GameEvents.turn_state_changed.emit()
