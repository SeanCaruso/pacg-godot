class_name CardInstance
extends ICard

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const CardTypes = preload("res://scripts/core/enums/card_type.gd")
# const CardType = CardTypes.CardType

var instance_id: int
var data: CardData
var logic: CardLogicBase
var original_owner: PlayerCharacter
var owner: PlayerCharacter
var current_location: CardLocation

var is_bane: bool:
	get: return CardTypes.is_bane(card_type)

var is_boon: bool:
	get: return CardTypes.is_boon(card_type)

var is_story_bane: bool:
	get: return data.card_type == CardTypes.CardType.STORY_BANE

func _init(card_data: CardData, _card_logic = null, _card_owner = null):
	data = card_data.duplicate() if card_data else null
	
	# Populate ICard members
	name = card_data.card_name
	card_type = data.story_bane_type if is_story_bane else data.card_type
	traits = card_data.traits
	
	instance_id = ResourceUID.create_id()
	current_location = CardLocation.VAULT
	logic = _card_logic
	owner = _card_owner

func _to_string() -> String:
	return name
