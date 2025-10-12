class_name TokenOfRemembranceLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	if action.action_type != Action.BURY \
	or TaskManager.current_resolvable is TokenOfRemembranceResolvable:
		return
	
	var valid_cards := action.card.owner.discards.filter(func(c: CardInstance): return c.card_type == CardType.SPELL)
	
	if valid_cards.is_empty():
		return
	
	var resolvable := TokenOfRemembranceResolvable.new(valid_cards)
	TaskManager.push(resolvable)


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Recharge on your check to recharge a spell.
	if Contexts.turn_context \
	and Contexts.turn_context.current_phase == TurnContext.TurnPhase.RECOVERY \
	and TaskManager.current_resolvable is CheckResolvable \
	and TaskManager.current_resolvable.card.card_type == CardType.SPELL \
	and TaskManager.current_resolvable.pc == card.owner \
	and TaskManager.current_resolvable.can_stage_type(card.card_type):
		var modifier := CheckModifier.new(card)
		modifier.added_dice = [8]
		return [PlayCardAction.new(card, Action.RECHARGE, modifier)]
	
	# Bury to reload a spell from your discards.
	if Contexts.are_cards_playable \
	and card.owner.discards.any(func(c: CardInstance): return c.card_type == CardType.SPELL):
		return [PlayCardAction.new(card, Action.BURY, null)]
	
	return []
