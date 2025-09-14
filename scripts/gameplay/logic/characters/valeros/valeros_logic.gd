class_name ValerosLogic
extends CharacterLogicBase

const CardType := preload("res://scripts/core/enums/card_type.gd").CardType

var _valid_cards: Array[CardInstance]

func get_end_of_turn_power(pc: PlayerCharacter) -> CharacterPower:
	_valid_cards.assign(pc.hand)
	_valid_cards.append_array(pc.discards)
	_valid_cards = _valid_cards.filter(
		func(c: CardInstance):
			return c.card_type in [CardType.ARMOR, CardType.WEAPON]
	)
	
	if _valid_cards.is_empty():
		return null
	
	return pc.data.powers[1]


func execute_power(pc: PlayerCharacter, id: String) -> void:
	match id:
		"valeros_end":
			var resolvable := ValerosEndOfTurnResolvable.new(_valid_cards)
			var processor := NewResolvableProcessor.new(resolvable)
			GameServices.game_flow.interrupt(processor)
			GameServices.asm.commit()
