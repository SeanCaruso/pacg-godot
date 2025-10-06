class_name BaseProcessor
extends Task


func _to_string() -> String:
	return get_script().get_global_name()


func is_automatic() -> bool:
	return true
