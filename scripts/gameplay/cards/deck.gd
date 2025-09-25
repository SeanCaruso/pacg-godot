class_name Deck
extends RefCounted

const CardLocation = preload("res://scripts/core/enums/card_location.gd").CardLocation
const CardType = preload("res://scripts/core/enums/card_type.gd").CardType

var _cards: Array[CardInstance] = []

var count: int:
	get: return _cards.size()

var _examined_cards: Dictionary = {} # CardInstance -> bool (HashSet)
var _known_cards: Dictionary = {}    # CardInstance -> bool (HashSet)

var _card_manager := GameServices.cards


func at(idx: int) -> CardInstance:
	return _cards[idx]


func has(card: CardInstance) -> bool:
	return _cards.has(card)


func erase(card: CardInstance) -> void:
	_cards.erase(card)


func shuffle():
	_cards.shuffle()
	for card in _examined_cards:
		_known_cards[card] = true
	_examined_cards.clear()


func draw_card() -> CardInstance:
	if _cards.size() == 0: return null
	
	var card = _cards.pop_front()
	_examined_cards.erase(card)
	_known_cards.erase(card)
	return card


func examine_top(_count: int) -> Array[CardInstance]:
	return _cards.slice(0, min(_count, _cards.size()))


func reorder_examined(new_order: Array[CardInstance]):
	for i in range(new_order.size()):
		_cards[i] = new_order[i]


func recharge(card: CardInstance):
	if not card or _cards.has(card): return
	_cards.push_back(card)
	_examined_cards[card] = true;
	_card_manager.move_card_to(card, CardLocation.DECK)


func reload(card: CardInstance):
	if not card or _cards.has(card): return
	_cards.push_front(card)
	_examined_cards[card] = true
	_card_manager.move_card_to(card, CardLocation.DECK)


func shuffle_in(card: CardInstance):
	reload(card)
	shuffle();


func draw_first_card_with(card_type: CardType, traits: Array[String] = []) -> CardInstance:
	var matching_cards = _cards.filter(func(c: CardInstance):
		var type_matches = c.card_type == card_type
		var trait_matches = traits.is_empty() or _has_any_trait(c.traits, traits)
		return type_matches and trait_matches
	)
	
	if matching_cards.is_empty(): return null
	
	var card = matching_cards[0]
	_cards.erase(card)
	_examined_cards.erase(card)
	_known_cards.erase(card)
	return card


func _has_any_trait(card_traits: Array[String], required_traits: Array[String]) -> bool:
	for req_trait in required_traits:
		if req_trait in card_traits: return true
	return false
