class_name SleepLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var can_banish_to_evade := \
	Contexts.encounter_context \
	and Contexts.encounter_context.current_phase == EncounterContext.EncounterPhase.EVASION \
	and Contexts.encounter_context.card.card_type == CardType.MONSTER \
	and card.owner.local_characters.has(Contexts.encounter_context.character)
	
	var resolvable := TaskManager.current_resolvable as CheckResolvable
	var can_banish_on_check := \
	resolvable \
	and resolvable.card.card_type in [CardType.ALLY, CardType.MONSTER] \
	and resolvable.pc.local_characters.has(card.owner) \
	and resolvable.can_stage_type(card.card_type)
	
	if not can_banish_on_check and not can_banish_to_evade: return []
	
	var modifier := CheckModifier.new(card)
	modifier.added_dice = [6]
	
	return [PlayCardAction.new(card, Action.BANISH, modifier)]


func get_recovery_resolvable(card: CardInstance) -> BaseResolvable:
	if not card.owner.is_proficient(card):
		return null
	
	var resolvable := CheckResolvable.new(
		card,
		card.owner,
		CardUtils.skill_check(9, [Skill.ARCANE])
	)
	resolvable.on_success = func(): card.owner.recharge(card)
	resolvable.on_failure = func(): card.owner.discard(card)
	
	return CardUtils.create_default_recovery_resolvable(resolvable)
