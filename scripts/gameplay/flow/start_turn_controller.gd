class_name StartTurnController
extends BaseProcessor

var _pc: PlayerCharacter


func _init(pc: PlayerCharacter):
	_pc = pc
	
	
func execute() -> void:
	print("===== STARTING TURN %d =====" % Contexts.game_context.turn_number)
	Contexts.game_context.turn_number += 1
	
	Contexts.new_turn(TurnContext.new(_pc))
	Contexts.game_context.set_active_character(_pc)
	GameEvents.pc_location_changed.emit(_pc)
	
	TaskManager.push(StartTurnProcessor.new())
	TaskManager.push(AdvanceHourTurnProcessor.new())
