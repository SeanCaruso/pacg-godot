class_name LongbowLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	if _contexts.encounter_context:
		_contexts.encounter_context.add_prohibited_traits(action.card.owner, ["Offhand"])


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var actions: Array[StagedAction] = []
	
	if _can_reveal(card):
		var reveal_modifier := CheckModifier.new(card)
		reveal_modifier.restricted_category = CheckCategory.COMBAT
		reveal_modifier.prohibited_traits = ["Offhand"]
		reveal_modifier.added_dice = [8]
		reveal_modifier.added_valid_skills = [Skill.DEXTERITY, Skill.RANGED]
		reveal_modifier.restricted_skills = [Skill.DEXTERITY, Skill.RANGED]
		reveal_modifier.added_traits = card.traits
		actions.append(PlayCardAction.new(card, Action.REVEAL, reveal_modifier, {"IsCombat": true}))
	
	if _can_discard(card):
		var modifier := CheckModifier.new(card)
		modifier.restricted_category = CheckCategory.COMBAT
		modifier.prohibited_traits = ["Offhand"]
		modifier.added_dice = [8]
		actions.append(PlayCardAction.new(card, Action.DISCARD, modifier, {"IsCombat": true, "IsFreely": true}))
	
	return actions


func _can_reveal(card: CardInstance) -> bool:
	# Reveal power can be used by the current owner while playing cards for a Dexterity or Ranged combat check.
	return _contexts.check_context \
	and _contexts.current_resolvable is CheckResolvable \
	and _contexts.check_context.is_combat_valid \
	and _contexts.check_context.character == card.owner \
	and _contexts.current_resolvable.can_stage_type(card.card_type) \
	and not _contexts.check_context.are_skills_blocked([Skill.DEXTERITY, Skill.RANGED])


func _can_discard(card: CardInstance) -> bool:
	# Discard power can be freely used on another character's combat check while playing cards if the owner is proficient.
	return _contexts.check_context \
	and _contexts.current_resolvable is CheckResolvable \
	and _contexts.check_context.is_combat_valid \
	and _contexts.check_context.character != card.owner \
	and card.owner.is_proficient(card)
