class_name EnchantWeaponLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Can freely banish for +1d4 if a weapon has been played on a combat check.
	if not TaskManager.current_resolvable is CheckResolvable \
	or not TaskManager.current_resolvable.has_combat:
		return []
	
	if not TaskManager.current_resolvable.staged_actions.any(
		func(a: StagedAction):
			return a.card.card_type == CardType.WEAPON
	):
		return []
	
	var modifier := CheckModifier.new(card)
	modifier.added_dice = [4]
	modifier.added_bonus = Contexts.game_context.adventure_number
	modifier.added_traits = ["Magic"]
	
	return [PlayCardAction.new(card, Action.BANISH, modifier, {"IsFreely": true})]


func get_recovery_resolvable(card: CardInstance) -> BaseResolvable:
	if not card.owner.is_proficient(card):
		return null
	
	var resolvable := CheckResolvable.new(
		card,
		card.owner,
		CardUtils.skill_check(6, [Skill.ARCANE, Skill.DIVINE])
	)
	resolvable.on_success = func(): card.owner.recharge(card)
	resolvable.on_failure = func(): card.owner.discard(card)
	
	return CardUtils.create_default_recovery_resolvable(resolvable)
