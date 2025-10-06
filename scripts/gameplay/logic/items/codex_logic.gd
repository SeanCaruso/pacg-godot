class_name CodexLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var actions: Array[StagedAction] = []
	
	# Reveal for +1 on your check to acquire.
	if TaskManager.current_resolvable is CheckResolvable \
	and TaskManager.current_resolvable.card is CardInstance \
	and TaskManager.current_resolvable.card.is_boon \
	and TaskManager.current_resolvable.can_stage_type(card.card_type) \
	and TaskManager.current_resolvable.character == card.owner:
		var modifier := CheckModifier.new(card)
		modifier.added_bonus = 1
		actions.append(PlayCardAction.new(card, Action.REVEAL, modifier))
	
	# Discard for +Knowledge on a local check to acquire
	if TaskManager.current_resolvable is CheckResolvable \
	and TaskManager.current_resolvable.card is CardInstance \
	and TaskManager.current_resolvable.card.is_boon \
	and TaskManager.current_resolvable.can_stage_type(card.card_type) \
	and TaskManager.current_resolvable.character.local_characters.has(card.owner):
		var skill_info := card.owner.get_skill(Skill.KNOWLEDGE)
		var modifier := CheckModifier.new(card)
		modifier.added_dice = [skill_info.die]
		modifier.added_bonus = skill_info.bonus
		actions.append(PlayCardAction.new(card, Action.DISCARD, modifier))
	
	return actions
