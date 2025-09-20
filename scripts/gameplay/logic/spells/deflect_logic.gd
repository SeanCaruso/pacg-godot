class_name DeflectLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Freely banish to reduce a local character's Combat damage by 4.
	if Contexts.current_resolvable is DamageResolvable \
	and (Contexts.current_resolvable as DamageResolvable).damage_type == "Combat" \
	and (Contexts.current_resolvable as DamageResolvable).character.local_characters.has(card.owner):
		return [PlayCardAction.new(card, Action.BANISH, null, {"Damage": 4})]
	
	return []


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
