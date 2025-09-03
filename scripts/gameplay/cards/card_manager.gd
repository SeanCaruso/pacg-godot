class_name CardManager
extends RefCounted

const Action       = preload("res://scripts/core/enums/action_type.gd").Action
const CardLocation = preload("res://scripts/core/enums/card_location.gd").CardLocation
var _all_cards: Array[CardInstance]


# var _response_registry: ResponseRegistry

func new_card(card_data: CardData, owner = null) -> CardInstance:
	if not card_data:
		print("Can't create card from null CardData!")
		return null

	# var card_logic = _logic.get_logic(card_data.card_id) when ready
	var new_instance = CardInstance.new(card_data, null, owner)
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
		print("Registering responses")
	# _response_registry.RegisterResponses(card)
	if not isActive and wasActive:
		print("Unregistering responses")
	# _response_registry.UnregisterResponses(card)

	card.current_location = new_location


func move_card_by(card: CardInstance, action: Action):
	if not card.owner:
		print("%s has no owner - use move_card(CardInstance, CardLocation) instead!" % card)

	match action:
		Action.BANISH:
			move_card_to(card, CardLocation.VAULT if not card.original_owner else CardLocation.RECOVERY)
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
	var revealed_cards = get_cards_in_location(CardLocation.REVEALED)
	for card in revealed_cards:
		move_card_to(card, CardLocation.HAND)


func find_all(predicate: Callable) -> Array[CardInstance]:
	return _all_cards.filter(predicate)


func get_cards_in_location(location: CardLocation) -> Array[CardInstance]:
	return find_all(func(card): return card.current_location == location)

#public List<CardInstance> GetCardsOwnedBy(PlayerCharacter owner) => FindAll(card => card.Owner == owner);
#public List<CardInstance> GetCardsOwnedBy(PlayerCharacter owner, CardLocation location) => FindAll(card => card.Owner == owner && card.CurrentLocation == location);
#public List<CardInstance> GetCardsInHand(PlayerCharacter owner) => FindAll(card => card.Owner == owner && card.CurrentLocation is CardLocation.Hand or CardLocation.Revealed);
