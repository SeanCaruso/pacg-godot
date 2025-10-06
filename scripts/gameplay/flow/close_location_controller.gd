class_name CloseLocationController
extends BaseProcessor

const CardType := preload("res://scripts/core/enums/card_type.gd").CardType

var _loc: Location


func _init(loc: Location) -> void:
	_loc = loc


func execute() -> void:
	# If this location has the villain, push the special processor that reveals it.
	if _loc.cards.any(func(c: CardInstance): return c.is_villain):
		TaskManager.push(RevealVillainsCloseLocationProcessor.new(_loc))
		return
	
	TaskManager.push(AfterClosingCloseLocationProcessor.new(_loc))
	TaskManager.push(MoveCharactersCloseLocationProcessor.new(_loc))
	TaskManager.push(OnClosingCloseLocationProcessor.new(_loc))
	TaskManager.push(BeforeClosingCloseLocationProcessor.new(_loc))
