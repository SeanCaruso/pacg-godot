class_name Location
extends ICard

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const CardTypes = preload("res://scripts/core/enums/card_type.gd")
const Scourge := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge

var data: LocationData
var logic: LocationLogicBase

var _deck: Deck
var cards: Array[CardInstance]:
	get:
		return _deck._cards
var count: int:
	get:
		return _deck.count

func shuffle(): _deck.shuffle()

var _known_composition: Dictionary = {}
var _unknown_card_count: int = 0

var characters: Array[PlayerCharacter]:
	get:
		return Contexts.game_context.get_characters_at(self)

func _init(location_data: LocationData):
	# Populate ICard members
	name = location_data.card_name
	card_type = CardType.LOCATION
	traits = location_data.traits
	logic = location_data.logic
	
	data = location_data
	_deck = Deck.new()
	
	for type in CardType.values():
		_known_composition[type] = 0

func _to_string() -> String: return name

func draw_card() -> CardInstance:
	var card := _deck.draw_card()
	
	if _known_composition[card.data.card_type] != 0:
		_known_composition[card.data.card_type] -= 1
	elif _unknown_card_count > 0:
		_unknown_card_count -= 1
	else:
		printerr("[%s] Drew a card we both did and didn't know the type of: %s.", [self, card.data.card_type])
	
	return card

func examine_top(num_cards: int) -> Array[CardInstance]: return _deck.examine_top(num_cards)

func shuffle_in(card: CardInstance, is_type_known: bool) -> void:
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
	
	for i in range(_deck.count - 1, -1, -1):
		_deck._cards[i].current_location = CardLocation.VAULT
		_deck._cards.remove_at(i)
	
	if Contexts.game_context:
		Contexts.game_context.locations.erase(self)
	if Contexts.turn_context:
		Contexts.turn_context.can_freely_explore = false
		Contexts.turn_context.was_location_closed = true
	
	GameEvents.turn_state_changed.emit()

################################################################################
# Facade Pattern for LocationLogic
################################################################################
var start_of_turn_power: LocationPower:
	get:
		return logic.get_start_of_turn_power(self) if logic else null

var end_of_turn_power: LocationPower:
	get:
		return logic.get_end_of_turn_power(self) if logic else null


func get_to_close_resolvable(pc: PlayerCharacter) -> BaseResolvable:
	return logic.get_to_close_resolvable(self, pc) if logic else null


func get_to_guard_resolvable(pc: PlayerCharacter) -> BaseResolvable:
	return logic.get_to_guard_resolvable(self, pc) if logic else null

var when_closed_resolvable: BaseResolvable:
	get:
		return logic.get_when_closed_resolvable() if logic else null
