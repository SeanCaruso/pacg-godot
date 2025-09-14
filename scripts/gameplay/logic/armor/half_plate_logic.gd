class_name HalfPlateLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var actions: Array[StagedAction] = []
	
	if _can_display(card):
		actions.append(PlayCardAction.new(card, Action.DISPLAY, null))
	if _can_draw(card):
		actions.append(PlayCardAction.new(card, Action.DRAW, null, {"Damage": 2}))
	if _can_freely_draw(card):
		actions.append(PlayCardAction.new(card, Action.DRAW, null, {"Damage": 2, "IsFreely": true}))
	if _can_bury(card):
		actions.append(PlayCardAction.new(card, Action.BURY, null, {"ReduceDamageTo": 0}))
	if _can_freely_bury(card):
		actions.append(PlayCardAction.new(card, Action.BURY, null, {"ReduceDamageTo": 0, "IsFreely": true}))
	
	return actions


func _can_display(card: CardInstance) -> bool:
	# Can't display if already displayed.
	if card.owner and card.owner.displayed_cards.has(card):
		return false
	
	# Can't display if another armor was played for the damage resolvable.
	if _contexts.current_resolvable and not _contexts.current_resolvable.can_stage_type(card.card_type):
		return false
	
	# If there's no encounter or resolvable...
	if _contexts.encounter_context == null and _contexts.current_resolvable == null:
		return true  # ... we can display.
	
	# Otherwise, we can only display if there's a DamageResolvable for this card's owner.
	if _contexts.current_resolvable is DamageResolvable:
		var damage_resolvable := _contexts.current_resolvable as DamageResolvable
		return damage_resolvable.character == card.owner
	
	return false


func _can_draw(card: CardInstance) -> bool:
	return card.owner.displayed_cards.has(card) \
		and _contexts.current_resolvable is DamageResolvable \
		and (_contexts.current_resolvable as DamageResolvable).damage_type == "Combat" \
		and _contexts.current_resolvable.can_stage_type(card.card_type) \
		and (_contexts.current_resolvable as DamageResolvable).character == card.owner


func _can_freely_draw(card: CardInstance) -> bool:
	return card.owner.displayed_cards.has(card) \
		and _asm.staged_cards.has(card) \
		and _contexts.current_resolvable is DamageResolvable \
		and (_contexts.current_resolvable as DamageResolvable).damage_type == "Combat" \
		and (_contexts.current_resolvable as DamageResolvable).character == card.owner


func _can_bury(card: CardInstance) -> bool:
	return card.owner.displayed_cards.has(card) \
		and card.owner.is_proficient(card) \
		and _contexts.current_resolvable is DamageResolvable \
		and _contexts.current_resolvable.can_stage_type(card.card_type) \
		and (_contexts.current_resolvable as DamageResolvable).character == card.owner


func _can_freely_bury(card: CardInstance) -> bool:
	return card.owner.displayed_cards.has(card) \
		and _asm.staged_cards.has(card) \
		and card.owner.is_proficient(card) \
		and _contexts.current_resolvable is DamageResolvable \
		and (_contexts.current_resolvable as DamageResolvable).character == card.owner
