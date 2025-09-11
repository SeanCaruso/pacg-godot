class_name MagicEyeLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Reveal for +1d4 on your non-combat check.
	if _contexts.check_context \
	and _contexts.current_resolvable is CheckResolvable \
	and _contexts.check_context.character == card.owner \
	and _contexts.check_context.is_skill_valid \
	and _contexts.current_resolvable.can_stage_type(card.card_type):
		var modifier := CheckModifier.new(card)
		modifier.restricted_category = CheckCategory.SKILL
		modifier.added_dice = [4]
		return [PlayCardAction.new(card, Action.REVEAL, modifier)]
	
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
