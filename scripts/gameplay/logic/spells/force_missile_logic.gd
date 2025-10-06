class_name ForceMissileLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Playable for +2d4 on any combat check.
	if not Contexts.check_context \
	or not Contexts.check_context.is_combat_valid \
	or not TaskManager.current_resolvable is CheckResolvable \
	or not TaskManager.current_resolvable.has_combat \
	or not TaskManager.current_resolvable.can_stage_type(card.card_type):
		return []
	
	var modifier := CheckModifier.new(card)
	modifier.added_dice = [4, 4]
	modifier.added_traits = ["Attack", "Force", "Magic"]
	modifier.restricted_category = CheckCategory.COMBAT
	
	# Also adds Arcane skill for the owner.
	if card.owner == Contexts.check_context.resolvable.character:
		modifier.added_traits.append("Arcane")
		modifier.added_valid_skills.append(Skill.ARCANE)
		modifier.restricted_skills.append(Skill.ARCANE)
	
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
