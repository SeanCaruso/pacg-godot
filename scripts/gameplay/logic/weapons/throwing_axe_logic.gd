class_name ThrowingAxeLogic
extends CardLogicBase

const _valid_skills := [Skill.STRENGTH, Skill.DEXTERITY, Skill.MELEE, Skill.RANGED]


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var actions: Array[StagedAction] = []
	
	# Reveal for Strength/Melee/Dexterity/Ranged +1d6 on a combat check.
	if _can_reveal(card):
		var modifier := CheckModifier.new(card)
		modifier.restricted_category = CheckCategory.COMBAT
		modifier.added_traits = card.traits
		modifier.restricted_skills = _valid_skills
		modifier.added_dice = [6]
		
		actions.append(PlayCardAction.new(card, Action.REVEAL, modifier, {"IsCombat": true}))
	
	if _can_discard(card):
		# Discard for +1d6 on a local combat check.
		var discard_modifier := CheckModifier.new(card)
		discard_modifier.restricted_category = CheckCategory.COMBAT
		discard_modifier.added_dice = [6]
		
		actions.append(PlayCardAction.new(card, Action.DISCARD, discard_modifier, {"IsCombat": true, "IsFreely": true}))
	
	return actions


func _can_reveal(card: CardInstance) -> bool:
	# Reveal power can be used by the current owner while playing cards for a Strength, Dexterity, Melee, or Ranged combat check.
	return _contexts.check_context \
		and _contexts.check_context.is_combat_valid \
		and _contexts.current_resolvable is CheckResolvable \
		and _contexts.current_resolvable.has_combat \
		and _contexts.check_context.character == card.owner \
		and _contexts.current_resolvable.can_stage_type(card.card_type) \
		and _contexts.check_context.can_use_skill(_valid_skills)


func _can_discard(card: CardInstance) -> bool:
	# Discard power can be freely used on a local combat check while playing cards if the owner is proficient.
	return _contexts.check_context \
		and _contexts.check_context.is_combat_valid \
		and _contexts.current_resolvable is CheckResolvable \
		and _contexts.current_resolvable.has_combat \
		and card.owner.is_proficient(card) \
		and _contexts.check_context.is_local(card.owner)
