class_name BaseProcessor
extends RefCounted

var _game_flow: GameFlowManager

func _init(game_services: GameServices):
	_game_flow = game_services.game_flow
	
	
func execute() -> void:
	# Call custom processor logic.
	on_execute()
	
	# Automatically complete the current phase.
	_game_flow.complete_current_phase()
	
	
## Sub-processor-specific functionality. GFM.complete_current_phase is handled by BaseProcessor
func on_execute() -> void:
	pass
