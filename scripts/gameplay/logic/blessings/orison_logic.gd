class_name OrisonLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	if _can_bless(card):
		var modifier := CheckModifier.new(card)
		modifier.skill_dice_to_add = 1
		var actions: Array[StagedAction] = [PlayCardAction.new(card, Action.DISCARD, modifier)]
		
		if Contexts.turn_context.hour_card.data.card_level == 0:
			actions.append(PlayCardAction.new(card, Action.RECHARGE, modifier))
		
		return actions
	elif Contexts.is_explore_possible and Contexts.turn_context.character == card.owner:
		return [ExploreAction.new(card, Action.DISCARD)]
	
	return []


func _can_bless(card: CardInstance) -> bool:
	# We can bless on a local check.
	return Contexts.check_context != null \
		and TaskManager.current_resolvable is CheckResolvable \
		and TaskManager.current_resolvable.can_stage_type(card.card_type) \
		and Contexts.check_context.character.location.characters.has(card.owner)
