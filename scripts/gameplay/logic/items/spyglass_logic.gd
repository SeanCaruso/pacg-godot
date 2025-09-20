class_name SpyglassLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	if action.action_type != Action.DISCARD:
		return
	Contexts.new_resolvable(ExamineResolvable.new(action.card.owner.location._deck, 2, true))


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Reveal for +1d6 on your Perception check.
	if _can_reveal(card):
		var modifier := CheckModifier.new(card)
		modifier.restricted_skills = [Skill.PERCEPTION]
		modifier.added_dice = [6]
		return [PlayCardAction.new(card, Action.REVEAL, modifier)]
	
	# Can discard to examine any time outside resolvables or encounters.
	if Contexts.current_resolvable == null \
	and Contexts.encounter_context == null \
	and card.owner.location.count > 0 \
	and _asm.staged_actions.is_empty():
		return [PlayCardAction.new(card, Action.DISCARD, null)]
	
	return []


func _can_reveal(card: CardInstance) -> bool:
	# Can reveal on your Perception check.
	return Contexts.check_context != null \
		and Contexts.current_resolvable is CheckResolvable \
		and Contexts.check_context.character == card.owner \
		and Contexts.check_context.has_valid_skill([Skill.PERCEPTION]) \
		and Contexts.current_resolvable.can_stage_type(card.card_type)
