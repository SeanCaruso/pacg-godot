class_name LookoutLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	if _contexts.check_context != null:
		return
	
	match action.action_type:
		Action.RECHARGE:
			GameServices.game_flow.queue_next_processor(NewResolvableProcessor.new(
				ExamineResolvable.new(action.card.owner.location._deck, 1)))
			pass
		Action.DISCARD:
			_contexts.turn_context.explore_effects.append(EvadeExploreEffect.new())


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Recharge for +1d4 on a local Perception check.
	if _can_recharge_for_check(card):
		var modifier := CheckModifier.new(card)
		modifier.restricted_skills = [Skill.PERCEPTION]
		modifier.added_dice = [4]
		return [PlayCardAction.new(card, Action.RECHARGE, modifier)]
	
	# Can recharge to examine outside of resolvables or encounters.
	if _contexts.current_resolvable == null \
	and _contexts.encounter_context == null \
	and card.owner.location.count > 0 \
	and GameServices.asm.staged_actions.is_empty():
		return [PlayCardAction.new(card, Action.RECHARGE, null)]
	
	# Can discard to explore.
	if _contexts.is_explore_possible and card.owner == _contexts.turn_context.character:
		return [ExploreAction.new(card, Action.DISCARD)]
	
	return []


func _can_recharge_for_check(card: CardInstance) -> bool:
	return _contexts.current_resolvable is CheckResolvable \
	and _contexts.check_context != null \
	and _contexts.check_context.is_local(card.owner) \
	and _contexts.check_context.resolvable.can_stage_type(card.card_type) \
	and _contexts.check_context.has_valid_skill([Skill.PERCEPTION])
