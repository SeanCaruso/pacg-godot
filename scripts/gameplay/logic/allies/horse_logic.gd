class_name HorseLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	# Discard to explore with +1d4 on the first check.
	if action.action_type != Action.DISCARD:
		return
	
	var explore_effect := SkillBonusExploreEffect.new(1, 4, 0, true)
	Contexts.turn_context.explore_effects.append(explore_effect)


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Recharge to move while not in an encounter.
	if Contexts.are_cards_playable and Contexts.game_context.locations.size() > 1:
		return [MoveAction.new(card, Action.RECHARGE)]
	
	# Discard to explore.
	if Contexts.is_explore_possible and card.owner == Contexts.turn_context.character:
		return [ExploreAction.new(card, Action.DISCARD)]
	
	return []
