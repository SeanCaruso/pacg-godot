class_name DetectMagicLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	var tasks: Array[Task] = []
	
	# Examine the top card of your location...
	tasks.append(ExamineResolvable.new(action.card.owner.location._deck, 1))
	
	# If it's a magic card, you may encounter it.
	var top_card := action.card.owner.location.examine_top(1)[0]
	
	if top_card.traits.has("Magic"):
		tasks.append(CardUtils.create_explore_choice())
	else:
		tasks.append(PlayerChoiceResolvable.new("Shuffle?", [
			ChoiceOption.new("Shuffle", func(): action.card.owner.location.shuffle()),
			ChoiceOption.new("Skip Shuffle", func(): pass)
		]))
	
	TaskManager.push_queue(tasks)


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
