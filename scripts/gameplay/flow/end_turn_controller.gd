class_name EndTurnController
extends BaseProcessor

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

var _skip_optional_discards: bool = false


func _init(skip_optional_discards: bool):	
	_skip_optional_discards = skip_optional_discards


func on_execute() -> void:
	_game_flow.queue_next_processor(EndOfTurnProcessor.new())
	
	if !GameServices.cards.get_cards_in_location(CardLocation.RECOVERY).is_empty():
		_game_flow.queue_next_processor(RecoveryTurnProcessor.new())
		
	var pc := Contexts.turn_context.character
	if !_skip_optional_discards or pc.hand.size() > pc.data.hand_size:
		_game_flow.queue_next_processor(DiscardDuringResetTurnProcessor.new())
		
	_game_flow.queue_next_processor(NextTurnTurnProcessor.new())
