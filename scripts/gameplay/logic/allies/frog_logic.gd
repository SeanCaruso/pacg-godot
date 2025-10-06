class_name FrogLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	match action.action_type:
		Action.BURY:
			var resolvable := CardUtils.create_explore_choice()
			TaskManager.push_deferred(resolvable)
		Action.DISCARD:
			Contexts.turn_context.explore_effects.append(ScourgeImmunityExploreEffect.new())


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# The owner can bury to evade an Obstacle or Trap bane.
	if Contexts.encounter_context \
	and Contexts.encounter_context.current_phase == EncounterContext.EncounterPhase.EVASION \
	and Contexts.encounter_context.character == card.owner \
	and Contexts.encounter_context.card.is_bane \
	and Contexts.encounter_context.has_trait(["Obstacle", "Trap"]):
		return [PlayCardAction.new(card, Action.BURY, null)]
	
	# Can discard if the owner can explore.
	if Contexts.is_explore_possible and card.owner == Contexts.turn_context.character:
		return [ExploreAction.new(card, Action.DISCARD)]
	
	return []
