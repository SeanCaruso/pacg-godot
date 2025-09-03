class_name Location
extends RefCounted

const CardLocation = preload("res://scripts/core/enums/CardLocation.gd").CardLocation
const CardTypes = preload("res://scripts/core/enums/card_type.gd")
const CardType = CardTypes.CardType

var data: LocationData
# var logic: CardLogicBase
# var original_owner: PlayerCharacter
# var owner: PlayerCharacter

var name: String:
	get: return data.card_name if data else ""

var card_type: CardType:
	get: return CardType.LOCATION

var traits: Array[String]:
	get: return data.traits

var _deck: Deck
var count: int:
	get: return _deck.count

func shuffle(): _deck.shuffle()

var _known_composition: Dictionary = {}
var _unknown_card_count: int = 0

var characters: Array[PlayerCharacter]:
	get: return _contexts.game_context.get_characters_at(self)

# Dependency injections
var _contexts: ContextManager

func _init(location_data: LocationData, _card_logic, game_services: GameServices):
	_contexts = GameServices.contexts
	
	data = location_data.duplicate() if location_data else null
	_deck = Deck.new(game_services.card_manager)
	
	for type in CardType:
		_known_composition[type] = 0
# logic = card_logic
# owner = card_owner

func _to_string() -> String: return name

func draw_card() -> CardInstance:
	var card = _deck.draw_card()
	
	if _known_composition[card.data.card_type] != 0:
		_known_composition[card.data.card_type] -= 1
	elif _unknown_card_count > 0:
		_unknown_card_count -= 1
	else:
		printerr("[%s] Drew a card we both did and didn't know the type of: %s.", [self, card.data.card_type])
	
	return card

func examine_top(num_cards: int) -> Array[CardInstance]: return _deck.examine_top(num_cards)

func shuffle_in(card: CardInstance, is_type_known: bool):
	if not card: return
	
	_deck.shuffle_in(card)
	
	if is_type_known:
		_known_composition[card.data.card_type] += 1
	else:
		_unknown_card_count += 1

func close():
	for pc in characters:
		pc.remove_scourge(Scourge.ENTANGLED)
		pc.remove_scourge(Scourge.FRIGHTENED)

################################################################################
# Facade Pattern for LocationLogic
################################################################################
func get_start_of_turn_power(): return null
func get_end_of_turn_power(): return null
func get_to_close_resolvable(): return null
