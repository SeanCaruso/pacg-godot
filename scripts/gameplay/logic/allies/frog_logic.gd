class_name FrogLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	match action.action_type:
		Action.BURY:
			var resolvable := CardUtils.create_explore_choice()
			var processor := NewResolvableProcessor.new(resolvable)
			_game_flow.queue_next_processor(processor)
		Action.DISCARD:
			_contexts.turn_context.explore_effects.append(ScourgeImmunityExploreEffect.new())


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# The owner can bury to evade an Obstacle or Trap bane.
	if _contexts.encounter_context \
	and _contexts.encounter_context.current_phase == EncounterContext.EncounterPhase.EVASION \
	and _contexts.encounter_context.character == card.owner \
	and _contexts.encounter_context.card.is_bane \
	and _contexts.encounter_context.has_traits(["Obstacle", "Trap"]):
		return [PlayCardAction.new(card, Action.BURY, null)]
	
	# Can discard if the owner can explore.
	if _contexts.is_explore_possible and card.owner == _contexts.turn_context.character:
		return [ExploreAction.new(card, Action.DISCARD)]
	
	return []
