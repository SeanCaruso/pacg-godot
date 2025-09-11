class_name TokenOfRemembranceLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	var valid_cards := action.card.owner.discards.filter(func(c: CardInstance): return c.card_type == CardType.SPELL)
	
	if valid_cards.is_empty():
		return
	
	var resolvable := TokenOfRemembranceResolvable.new(valid_cards)
	var processor := NewResolvableProcessor.new(resolvable)
	_game_flow.start_phase(processor, action.card.to_string())


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Recharge on your check to recharge a spell.
	if _contexts.turn_context \
	and _contexts.turn_context.current_phase == TurnContext.TurnPhase.RECOVERY \
	and _contexts.current_resolvable is CheckResolvable \
	and _contexts.current_resolvable.card.card_type == CardType.SPELL \
	and _contexts.current_resolvable.character == card.owner \
	and _contexts.current_resolvable.can_stage_type(card.card_type):
		var modifier := CheckModifier.new(card)
		modifier.added_dice = [8]
		return [PlayCardAction.new(card, Action.RECHARGE, modifier)]
	
	# Bury to reload a spell from your discards.
	if _contexts.are_cards_playable \
	and card.owner.discards.any(func(c: CardInstance): return c.card_type == CardType.SPELL):
		return [PlayCardAction.new(card, Action.BURY, null)]
	
	return []
