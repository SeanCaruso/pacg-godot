class_name CloseLocationController
extends BaseProcessor

const CardType := preload("res://scripts/core/enums/card_type.gd").CardType

var _loc: Location


func _init(loc: Location) -> void:
	_loc = loc


func on_execute() -> void:	
	if _loc.cards.any(func(c: CardInstance): return c.is_villain):
		GameServices.game_flow.queue_next_processor(RevealVillainsCloseLocationProcessor.new(_loc))
		return
	
	GameServices.game_flow.queue_next_processor(BeforeClosingCloseLocationProcessor.new(_loc))
	GameServices.game_flow.queue_next_processor(OnClosingCloseLocationProcessor.new(_loc))
	GameServices.game_flow.queue_next_processor(MoveCharactersCloseLocationProcessor.new(_loc))
	GameServices.game_flow.queue_next_processor(AfterClosingCloseLocationProcessor.new(_loc))
