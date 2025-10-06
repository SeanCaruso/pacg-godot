class_name AfterClosingCloseLocationProcessor
extends BaseProcessor

var _loc: Location


func _init(loc: Location) -> void:
	_loc = loc


func execute() -> void:
	_loc.close()
	return
