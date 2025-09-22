class_name MoveCharactersCloseLocationProcessor
extends BaseProcessor

var _loc: Location


func _init(loc: Location) -> void:
	_loc = loc


func on_execute() -> void:
	DialogEvents.emit_location_closed(_loc)
