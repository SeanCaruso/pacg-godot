class_name DetectMagicLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	# Examine the top card of your location...
	var examine_resolvable := ExamineResolvable.new(action.card.owner.location._deck, 1)
	
	# If it's a magic card, you may encounter it.
	var top_card := action.card.owner.location.examine_top(1)[0]
	var next_resolvable: BaseResolvable = null
	
	if top_card.traits.has("Magic"):
		if action.card.owner == Contexts.turn_context.character:
			next_resolvable = CardUtils.create_explore_choice()
	else:
		next_resolvable = PlayerChoiceResolvable.new("Shuffle?", [
			ChoiceOption.new("Shuffle", func(): action.card.owner.location.shuffle()),
			ChoiceOption.new("Skip Shuffle", func(): pass)
		])
	
	if next_resolvable != null:
		var next_processor := NewResolvableProcessor.new(next_resolvable)
		examine_resolvable.override_next_processor(next_processor)
	
	_game_flow.queue_next_processor(NewResolvableProcessor.new(examine_resolvable))


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	if Contexts.are_cards_playable and card.owner.location.count > 0:
		return [PlayCardAction.new(card, Action.BANISH, null)]
	
	return []


func get_recovery_resolvable(card: CardInstance) -> BaseResolvable:
	if not card.owner.is_proficient(card):
		return null
	
	var resolvable := CheckResolvable.new(
		card,
		card.owner,
		CardUtils.skill_check(5, [Skill.ARCANE, Skill.DIVINE])
	)
	resolvable.on_success = func(): card.owner.recharge(card)
	resolvable.on_failure = func(): card.owner.discard(card)
	
	return CardUtils.create_default_recovery_resolvable(resolvable)
