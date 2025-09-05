class_name DiscardEventArgs
extends RefCounted

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

var character: PlayerCharacter
var cards: Array[CardInstance]
var original_location: CardLocation
var damage_resolvable: DamageResolvable

var card_responses: Array[CardResponse]
var has_responses: bool:
	get: return !card_responses.is_empty()

func _init(_character: PlayerCharacter,
	_cards: Array[CardInstance],
	_original_location: CardLocation,
	_resolvable: DamageResolvable = null
):
	character = _character
	cards = _cards
	original_location = _original_location
	damage_resolvable = _resolvable
