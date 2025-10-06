class_name CheckController
extends BaseProcessor

const CardType := preload("res://scripts/core/enums/card_type.gd").CardType

var _resolvable: CheckResolvable

func _init(resolvable: CheckResolvable):
	_resolvable = resolvable


func execute() -> void:
	TaskManager.push(EndOfCheckProcessor.new())
	
	if _resolvable.card.card_type == CardType.MONSTER:
		TaskManager.push(CheckDamageProcessor.new())
	
	TaskManager.push(RollCheckDiceProcessor.new())
