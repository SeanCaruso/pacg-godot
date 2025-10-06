## Turn sub-processor for any automatic stuff that happens between turns
class_name NextTurnTurnProcessor
extends BaseProcessor

func execute() -> void:
	if !Contexts.turn_context or !Contexts.turn_context.character: return
	
	Contexts.turn_context.character.draw_to_hand_size()
	
	var idx := Contexts.game_context.characters.find(Contexts.turn_context.character) + 1
	idx %= Contexts.game_context.characters.size()
	var next_pc := Contexts.game_context.characters[idx]
	
	Contexts.end_turn()
	TaskManager.push(StartTurnController.new(next_pc))
	
	GameEvents.turn_state_changed.emit()
