class_name CheckController
extends BaseProcessor

const CardType := preload("res://scripts/core/enums/card_type.gd").CardType

var _resolvable: CheckResolvable

func _init(resolvable: CheckResolvable):
	_resolvable = resolvable


func on_execute() -> void:
	GameServices.game_flow.queue_next_processor(RollCheckDiceProcessor.new())
	
	if _resolvable.card.card_type == CardType.MONSTER:
		GameServices.game_flow.queue_next_processor(CheckDamageProcessor.new())
	
	GameServices.game_flow.queue_next_processor(EndOfCheckProcessor.new())
