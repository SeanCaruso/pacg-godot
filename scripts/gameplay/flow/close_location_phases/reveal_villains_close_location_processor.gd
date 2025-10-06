class_name RevealVillainsCloseLocationProcessor
extends BaseProcessor

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

var _loc: Location


func _init(loc: Location) -> void:
	_loc = loc


func execute() -> void:
	var context := ExamineContext.new()
	context.examine_mode = ExamineContext.Mode.SCROLL
	context.cards = _loc.cards
	context.unknown_count = 0
	context.can_reorder = false
	
	GameEvents.set_status_text.emit("Found the villain!")
	DialogEvents.examine_event.emit(context)
	
	for i in range(_loc.cards.size() - 1, -1, -1):
		if _loc.cards[i].is_villain:
			continue
		GameServices.cards.move_card_to(_loc.cards[i], CardLocation.VAULT)
		_loc._deck._cards.remove_at(i)
