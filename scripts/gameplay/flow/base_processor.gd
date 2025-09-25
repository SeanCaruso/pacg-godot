class_name BaseProcessor
extends RefCounted


func _to_string() -> String:
	return get_script().get_global_name()


func execute() -> void:
	# Call custom processor logic.
	on_execute()
	
	# Automatically complete the current phase.
	GameServices.game_flow.complete_current_phase()
	
	
## Sub-processor-specific functionality. GFM.complete_current_phase is handled by BaseProcessor
func on_execute() -> void:
	pass
