class_name EndTurnController
extends BaseProcessor

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

var _skip_optional_discards: bool = false


func _init(skip_optional_discards: bool):	
	_skip_optional_discards = skip_optional_discards


func execute() -> void:
	var tasks: Array[Task] = []
	tasks.append(EndOfTurnProcessor.new())
	
	if !Cards.get_cards_in_location(CardLocation.RECOVERY).is_empty():
		tasks.append(RecoveryTurnProcessor.new())
	
	var pc := Contexts.turn_context.character
	if !_skip_optional_discards or pc.hand.size() > pc.data.hand_size:
		tasks.append(DiscardDuringResetTurnProcessor.new())
	
	tasks.append(NextTurnTurnProcessor.new())
	
	TaskManager.push_queue(tasks)
