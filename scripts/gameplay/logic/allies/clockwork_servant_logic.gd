class_name ClockworkServantLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	# Bury or Banish to explore
	if action.action_type not in [Action.BURY, Action.BANISH]:
		return
	
	_contexts.turn_context.explore_effects.append(BaseExploreEffect.new())


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Recharge for +1d6 on a local Intelligence or Craft check.
	if _can_recharge(card):
		var modifier := CheckModifier.new(card)
		modifier.required_traits = ["Intelligence", "Craft"]
		modifier.added_dice = [6]
		return [PlayCardAction.new(card, Action.RECHARGE, modifier)]
	
	# Bury or banish to explore
	if _contexts.is_explore_possible and card.owner == _contexts.turn_context.character:
		return [
			ExploreAction.new(card, Action.BURY),
			ExploreAction.new(card, Action.BANISH)
		]
	
	return []


func get_recovery_resolvable(card: CardInstance) -> BaseResolvable:
	var resolvable := CheckResolvable.new(
		card,
		card.owner,
		CardUtils.skill_check(8, [Skill.CRAFT]))
	resolvable.on_success = func(): card.owner.recharge(card)
	resolvable.on_failure = func(): card.owner.banish(card, true)
	return CardUtils.create_default_recovery_resolvable(resolvable)


func _can_recharge(card: CardInstance) -> bool:
	return _contexts.check_context \
	and _contexts.check_context.is_local(card.owner) \
	and _contexts.check_context.resolvable.can_stage_type(card.card_type) \
	and _contexts.check_context.invokes_traits(["Intelligence", "Craft"])
