class_name MoveCharactersCloseLocationProcessor
extends BaseProcessor

var _loc: Location


func _init(loc: Location) -> void:
	_loc = loc


func execute() -> void:
	DialogEvents.emit_location_closed(_loc)
