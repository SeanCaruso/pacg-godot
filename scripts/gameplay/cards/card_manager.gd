class_name CardManager
extends RefCounted

const Action       := preload("res://scripts/core/enums/action_type.gd").Action
const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

var _all_cards: Array[CardInstance]
var _response_registry := ResponseRegistry.new()

func new_card(card_data: CardData, owner = null) -> CardInstance:
	if not card_data:
		print("Can't create card from null CardData!")
		return null

	var new_instance = CardInstance.new(card_data, owner)
	_all_cards.append(new_instance)
	return new_instance

func move_card_to(card: CardInstance, new_location: CardLocation):
	if not card:
		print("Attempted to move a null card to " + str(new_location) + "!")
		return

	if (card.current_location == new_location):
		return

	var wasActive: bool = card.current_location in [CardLocation.HAND, CardLocation.REVEALED, CardLocation.DISPLAYED]
	var isActive: bool  = new_location in [CardLocation.HAND, CardLocation.REVEALED, CardLocation.DISPLAYED]

	if isActive and not wasActive:
		_response_registry.register_responses(card)
	if not isActive and wasActive:
		_response_registry.unregister_responses(card)

	var prev_location := card.current_location
	card.current_location = new_location
	GameEvents.card_location_changed.emit(card, prev_location)
	
	if card.owner:
		GameEvents.player_deck_count_changed.emit(card.owner.deck.count)

func move_card_by(card: CardInstance, action: Action):
	if not card.owner:
		print("%s has no owner - use move_card_to(CardInstance, CardLocation) instead!" % card)

	match action:
		Action.BANISH:
			move_card_to(card, CardLocation.VAULT if not card.owner else CardLocation.RECOVERY)
		Action.BURY:
			move_card_to(card, CardLocation.BURIED)
		Action.DISCARD:
			move_card_to(card, CardLocation.DISCARDS)
		Action.DISPLAY:
			move_card_to(card, CardLocation.DISPLAYED)
		Action.DRAW:
			move_card_to(card, CardLocation.HAND)
		Action.RECHARGE:
			move_card_to(card, CardLocation.DECK)
			card.owner.recharge(card)
		Action.RELOAD:
			move_card_to(card, CardLocation.DECK)
			card.owner.reload(card)
		Action.REVEAL:
			move_card_to(card, CardLocation.REVEALED)
		_:
			print("Unsupported action: %s!" % action)

func restore_revealed_cards_to_hand():
	var revealed_cards := get_cards_in_location(CardLocation.REVEALED)
	for card in revealed_cards:
		move_card_to(card, CardLocation.HAND)

		
func find_all(predicate: Callable) -> Array[CardInstance]:
	return _all_cards.filter(predicate)

	
func get_cards_in_location(location: CardLocation) -> Array[CardInstance]:
	return find_all(func(card): return card.current_location == location)

	
func get_all_cards_owned_by(owner: PlayerCharacter) -> Array[CardInstance]:
	return find_all(func(card: CardInstance): return card.owner == owner)
	
	
func get_cards_owned_by(owner: PlayerCharacter, location: CardLocation) -> Array[CardInstance]:
	return find_all(func(card: CardInstance): return card.owner == owner and card.current_location == location)


func get_cards_in_hand(owner: PlayerCharacter) -> Array[CardInstance]:
	return find_all(func(card: CardInstance): return card.owner == owner and card.current_location in [CardLocation.HAND, CardLocation.REVEALED])


func trigger_before_discard(args: DiscardEventArgs):
	_response_registry.trigger_before_discard(args)
