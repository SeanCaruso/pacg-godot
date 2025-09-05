class_name BaseProcessor
extends RefCounted

var _contexts: ContextManager
var _game_flow: GameFlowManager
var _game_services: GameServices

func _init(game_services: GameServices):
	_contexts = game_services.contexts
	_game_flow = game_services.game_flow
	_game_services = game_services
	
	
func execute() -> void:
	# Call custom processor logic.
	on_execute()
	
	# Automatically complete the current phase.
	_game_flow.complete_current_phase()
	
	
## Sub-processor-specific functionality. GFM.complete_current_phase is handled by BaseProcessor
func on_execute() -> void:
	pass
