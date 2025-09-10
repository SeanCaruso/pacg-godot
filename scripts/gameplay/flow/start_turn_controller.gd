class_name StartTurnController
extends BaseProcessor

var _pc: PlayerCharacter


func _init(pc: PlayerCharacter):
	_pc = pc
	
	
func on_execute() -> void:
	print("===== STARTING TURN %d =====" % _contexts.game_context.turn_number)
	_contexts.game_context.turn_number += 1
	
	_contexts.new_turn(TurnContext.new(_pc))
	GameEvents.player_character_changed.emit(_pc)
	GameEvents.pc_location_changed.emit(_pc, _pc.location)
	
	_game_flow.queue_next_processor(AdvanceHourTurnProcessor.new())
	_game_flow.queue_next_processor(StartTurnProcessor.new())
