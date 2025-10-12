class_name VoidglassArmorLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var actions: Array[StagedAction] = []
	
	if _can_display(card):
		actions.append(PlayCardAction.new(card, Action.DISPLAY, null))
	if _can_recharge_for_damage(card):
		actions.append(PlayCardAction.new(card, Action.RECHARGE, null, {"Damage": 1}))
	if _can_freely_recharge_for_damage(card):
		actions.append(PlayCardAction.new(card, Action.RECHARGE, null, {"Damage": 1, "IsFreely": true}))
	if _can_bury(card):
		actions.append(PlayCardAction.new(card, Action.BURY, null, {"ReduceDamageTo": 0}))
	if _can_freely_bury(card):
		actions.append(PlayCardAction.new(card, Action.BURY, null, {"ReduceDamageTo": 0, "IsFreely": true}))
	
	return actions


func _can_display(card: CardInstance) -> bool:
	# Can't display if already displayed.
	if card.owner and card.owner.displayed_cards.has(card):
		return false
	
	# Can't display if another armor was played on the check.
	if TaskManager.current_resolvable and not TaskManager.current_resolvable.can_stage_type(card.card_type):
		return false
	
	# If there's no encounter or resolvable...
	if Contexts.are_cards_playable:
		return true  # ... we can display.
	
	# Otherwise, we can only display if there's a DamageResolvable for this card's owner.
	if TaskManager.current_resolvable is DamageResolvable:
		var resolvable := TaskManager.current_resolvable as DamageResolvable
		return resolvable.pc == card.owner
	
	return false


func _can_recharge_for_damage(card: CardInstance) -> bool:
	return card.owner.displayed_cards.has(card) \
		and TaskManager.current_resolvable is DamageResolvable \
		and TaskManager.current_resolvable.can_stage_type(card.card_type) \
		and TaskManager.current_resolvable.pc == card.owner


func _can_freely_recharge_for_damage(card: CardInstance) -> bool:
	return card.owner.displayed_cards.has(card) \
		and TaskManager.current_resolvable is DamageResolvable \
		and TaskManager.current_resolvable.staged_cards.has(card) \
		and TaskManager.current_resolvable.pc == card.owner


func _can_bury(card: CardInstance) -> bool:
	return card.owner.displayed_cards.has(card) \
		and card.owner.is_proficient(card) \
		and TaskManager.current_resolvable is DamageResolvable \
		and TaskManager.current_resolvable.can_stage_type(card.card_type) \
		and TaskManager.current_resolvable.pc == card.owner


func _can_freely_bury(card: CardInstance) -> bool:
	return card.owner.displayed_cards.has(card) \
		and card.owner.is_proficient(card) \
		and TaskManager.current_resolvable is DamageResolvable \
		and TaskManager.current_resolvable.staged_cards.has(card) \
		and TaskManager.current_resolvable.pc == card.owner


func on_before_discard(source_card: CardInstance, args: DiscardEventArgs) -> void:
	if source_card.owner != args.character:
		return
	
	# Only respond if displayed or in hand.
	if source_card.current_location not in [CardLocation.HAND, CardLocation.DISPLAYED]:
		return
	
	# If we're not discarding from the deck or dealing mental damage, we can't use this card.
	if not (args.original_location == CardLocation.DECK or (args.damage_resolvable and args.damage_resolvable.damage_type == "Mental")):
		return
	
	var offer := CardResponse.new(
		source_card,
		"Recharge %s" % source_card,
		_accept_recharge_action.bind(source_card, args)
	)
	args.card_responses.append(offer)


func _accept_recharge_action(source_card: CardInstance, args: DiscardEventArgs) -> void:
	Cards.move_card_by(source_card, Action.RECHARGE)
	
	# If this is for a Mental DamageResolvable, override the default action to Recharge.
	if args.damage_resolvable and args.damage_resolvable.damage_type == "Mental":
		args.damage_resolvable.override_action_type(Action.RECHARGE)
		TaskManager.resolve_current()
	
	# If this is for discarding cards from the deck, recharge them instead.
	for card_to_recharge in args.cards:
		Cards.move_card_by(card_to_recharge, Action.RECHARGE)
