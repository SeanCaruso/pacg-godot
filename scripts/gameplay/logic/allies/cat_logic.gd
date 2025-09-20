class_name CatLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	if action.action_type != Action.DISCARD:
		return
	
	# Discard to explore. +1d4 on checks that invoke the Magic trait.
	var explore_effect := SkillBonusExploreEffect.new(1, 4, 0, false)
	explore_effect.set_traits("Magic")
	Contexts.turn_context.explore_effects.append(explore_effect)


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:	
	# Can recharge for +1d4 on a local check against a spell.
	if Contexts.check_context \
	and Contexts.check_context.resolvable.card is CardInstance \
	and Contexts.check_context.resolvable.card.data.card_type == CardType.SPELL \
	and Contexts.check_context.resolvable.can_stage_type(card.card_type):
		var modifier := CheckModifier.new(card)
		modifier.added_dice = [4]
		return [PlayCardAction.new(card, Action.RECHARGE, modifier)]
	
	# Discard to explore.
	if Contexts.is_explore_possible \
	and card.owner == Contexts.turn_context.character:
		return [ExploreAction.new(card, Action.DISCARD)]
	
	return []
