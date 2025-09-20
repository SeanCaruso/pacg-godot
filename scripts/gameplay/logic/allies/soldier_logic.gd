class_name SoldierLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	# Discard to explore - +1d4 on Strength and Melee checks.
	if action.action_type != Action.DISCARD:
		return
	
	var explore_effect := SkillBonusExploreEffect.new(1, 4, 0, false, [Skill.STRENGTH, Skill.MELEE])
	Contexts.turn_context.explore_effects.append(explore_effect)


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Recharge for +1d4 on a local Strength or Melee check.
	if _can_recharge(card):
		var modifier := CheckModifier.new(card)
		modifier.restricted_skills.append_array([Skill.STRENGTH, Skill.MELEE])
		modifier.added_dice = [4]
		return [PlayCardAction.new(card, Action.RECHARGE, modifier)]
	
	if Contexts.is_explore_possible and card.owner == Contexts.turn_context.character:
		return [ExploreAction.new(card, Action.DISCARD)]
	
	return []


func _can_recharge(card: CardInstance) -> bool:
	return Contexts.check_context \
	and Contexts.current_resolvable is CheckResolvable \
	and Contexts.check_context.is_local(card.owner) \
	and Contexts.check_context.resolvable.can_stage_type(card.card_type) \
	and Contexts.check_context.has_valid_skill([Skill.STRENGTH, Skill.MELEE])
