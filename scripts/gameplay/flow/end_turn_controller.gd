class_name EndTurnController
extends BaseProcessor

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

var _skip_optional_discards: bool = false

var _card_manager: CardManager

func _init(skip_optional_discards: bool, game_services: GameServices):
	super(game_services)
	_card_manager = game_services.cards
	
	_skip_optional_discards = skip_optional_discards
	
	
func on_execute() -> void:
	_game_flow.queue_next_processor(EndOfTurnProcessor.new(_game_services))
	
	if !_card_manager.get_cards_in_location(CardLocation.RECOVERY).is_empty():
		_game_flow.queue_next_processor(RecoveryTurnProcessor.new(_game_services))
		
	var pc := _contexts.turn_context.character
	if !_skip_optional_discards or pc.hand.size() > pc.data.hand_size:
		_game_flow.queue_next_processor(DiscardDuringResetTurnProcessor.new(_game_services))
		
	_game_flow.queue_next_processor(NextTurnTurnProcessor.new(_game_services))
