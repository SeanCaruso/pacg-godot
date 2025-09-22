class_name TokenOfRemembranceLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	if action.action_type != Action.BURY:
		return
	
	var valid_cards := action.card.owner.discards.filter(func(c: CardInstance): return c.card_type == CardType.SPELL)
	
	if valid_cards.is_empty():
		return
	
	var resolvable := TokenOfRemembranceResolvable.new(valid_cards)
	var processor := NewResolvableProcessor.new(resolvable)
	_game_flow.start_phase(processor, action.card.to_string())


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Recharge on your check to recharge a spell.
	if Contexts.turn_context \
	and Contexts.turn_context.current_phase == TurnContext.TurnPhase.RECOVERY \
	and Contexts.current_resolvable is CheckResolvable \
	and Contexts.current_resolvable.card.card_type == CardType.SPELL \
	and Contexts.current_resolvable.character == card.owner \
	and Contexts.current_resolvable.can_stage_type(card.card_type):
		var modifier := CheckModifier.new(card)
		modifier.added_dice = [8]
		return [PlayCardAction.new(card, Action.RECHARGE, modifier)]
	
	# Bury to reload a spell from your discards.
	if Contexts.are_cards_playable \
	and card.owner.discards.any(func(c: CardInstance): return c.card_type == CardType.SPELL):
		return [PlayCardAction.new(card, Action.BURY, null)]
	
	return []
