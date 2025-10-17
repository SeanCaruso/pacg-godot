class_name ScenarioLogicBase
extends Resource

func has_available_actions() -> bool:
	return false


func invoke_action() -> void:
	pass


func on_location_closed() -> void:
	pass


func on_villain_defeated() -> void:
	pass
