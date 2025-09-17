class_name SageLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	if action.action_type != Action.DISCARD:
		return
	
	var examine_resolvable := ExamineResolvable.new(action.card.owner.location._deck, 1)
	examine_resolvable.override_next_processor(ShuffleDeckProcessor.new(action.card.owner.location.deck))
	GameServices.game_flow.queue_next_processor(NewResolvableProcessor.new(examine_resolvable))
	
	if action.card.owner != _contexts.turn_context.character:
		return
	
	var explore_option_resolvable := CardUtils.create_explore_choice()
	GameServices.game_flow.queue_next_processor(NewResolvableProcessor.new(explore_option_resolvable))
	


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	if not _contexts.check_context: return []
	
	# Can recharge for +1d6 on a local Arcane or Knowledge non-combat check.
	if _contexts.check_context \
	and _contexts.check_context.character.local_characters.has(card.owner) \
	and _contexts.current_resolvable.can_stage_type(card.card_type) \
	and _contexts.check_context.is_skill_valid \
	and _contexts.check_context.has_valid_skill([Skill.ARCANE, Skill.KNOWLEDGE]):
		var modifier := CheckModifier.new(card)
		modifier.restricted_category = CheckCategory.SKILL
		modifier.restricted_skills = [Skill.ARCANE, Skill.KNOWLEDGE]
		modifier.added_dice = [6]
		return [PlayCardAction.new(card, Action.RECHARGE, modifier)]
	
	# Can discard to examine and shuffle.
	if _contexts.are_cards_playable and card.owner.location.count > 0:
		return [PlayCardAction.new(card, Action.DISCARD, null)]
	
	return []
