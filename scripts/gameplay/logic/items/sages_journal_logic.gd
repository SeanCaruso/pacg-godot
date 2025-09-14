class_name SagesJournalLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var actions: Array[StagedAction] = []
	
	# Reveal for +1d4 on your check against a story bane.
	if _contexts.current_resolvable is CheckResolvable \
	and _contexts.current_resolvable.card is CardInstance \
	and _contexts.current_resolvable.card.is_story_bane \
	and _contexts.current_resolvable.can_stage_type(card.card_type) \
	and _contexts.current_resolvable.character == card.owner:
		var modifier := CheckModifier.new(card)
		modifier.added_dice = [4]
		actions.append(PlayCardAction.new(card, Action.REVEAL, modifier))
	
	# Bury for +Knowledge on a local check against a bane.
	if _contexts.current_resolvable is CheckResolvable \
	and _contexts.current_resolvable.card is CardInstance \
	and _contexts.current_resolvable.card.is_bane \
	and _contexts.current_resolvable.can_stage_type(card.card_type) \
	and _contexts.current_resolvable.character.local_characters.has(card.owner):
		var skill_info := card.owner.get_skill(Skill.KNOWLEDGE)
		var modifier := CheckModifier.new(card)
		modifier.added_dice = [skill_info.die]
		modifier.added_bonus = skill_info.bonus
		actions.append(PlayCardAction.new(card, Action.BURY, modifier))
	
	return actions
