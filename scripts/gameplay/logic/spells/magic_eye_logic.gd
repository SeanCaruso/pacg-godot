class_name MagicEyeLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	# Examine the top 3 cards of your location.
	var examine_resolvable := ExamineResolvable.new(action.card.owner.location._deck, 3)
	
	GameServices.game_flow.queue_next_processor(NewResolvableProcessor.new(examine_resolvable))


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var actions: Array[StagedAction] = []
	
	if Contexts.are_cards_playable and card.owner.location.count > 0:
		actions.append(PlayCardAction.new(card, Action.BANISH, null))
	
	return actions


func get_recovery_resolvable(card: CardInstance) -> BaseResolvable:
	if not card.owner.is_proficient(card):
		return null
	
	var resolvable := CheckResolvable.new(
		card,
		card.owner,
		CardUtils.skill_check(9, [Skill.ARCANE, Skill.DIVINE])
	)
	resolvable.on_success = func(): card.owner.recharge(card)
	resolvable.on_failure = func(): card.owner.discard(card)
	
	return CardUtils.create_default_recovery_resolvable(resolvable)
