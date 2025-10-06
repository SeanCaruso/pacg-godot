class_name LightningTouchLogic
extends CardLogicBase


func on_commit(_action: StagedAction) -> void:
	if not Contexts.encounter_context or Contexts.encounter_context.card.card_type != CardType.MONSTER:
		return
	
	Contexts.encounter_context.ignore_after_acting_powers = true


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Playable for Arcane +2d4 on the owner's combat check.
	if not Contexts.check_context \
	or not Contexts.check_context.is_combat_valid \
	or not TaskManager.current_resolvable is CheckResolvable \
	or not TaskManager.current_resolvable.has_combat \
	or TaskManager.current_resolvable.character != card.owner \
	or not TaskManager.current_resolvable.can_stage_type(card.card_type):
		return []
	
	var modifier := CheckModifier.new(card)
	modifier.restricted_category = CheckCategory.COMBAT
	modifier.added_valid_skills = [Skill.ARCANE]
	modifier.restricted_skills = [Skill.ARCANE]
	modifier.added_dice = [4, 4]
	modifier.added_traits = card.traits
	
	return [PlayCardAction.new(card, Action.BANISH, modifier, {"IsCombat": true})]


func get_recovery_resolvable(card: CardInstance) -> BaseResolvable:
	if not card.owner.is_proficient(card):
		return null
	
	var resolvable := CheckResolvable.new(
		card,
		card.owner,
		CardUtils.skill_check(6, [Skill.ARCANE])
	)
	resolvable.on_success = func(): card.owner.recharge(card)
	resolvable.on_failure = func(): card.owner.discard(card)
	
	return CardUtils.create_default_recovery_resolvable(resolvable)
