class_name QuarterstaffLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	_contexts.encounter_context.add_prohibited_traits(action.card.owner, ["Offhand"])


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var actions: Array[StagedAction] = []
	
	if _is_playable_for_combat(card):
		# If a weapon hasn't been played yet, display both combat options.
		if _contexts.current_resolvable.can_stage_type(card.card_type):
			var reveal_modifier := CheckModifier.new(card)
			reveal_modifier.restricted_category = CheckCategory.COMBAT
			reveal_modifier.added_traits = card.traits
			reveal_modifier.restricted_skills = [Skill.STRENGTH, Skill.MELEE]
			reveal_modifier.prohibited_traits = ["Offhand"]
			reveal_modifier.added_dice = [6]
			
			actions.append(PlayCardAction.new(card, Action.REVEAL, reveal_modifier, {"IsCombat": true}))
			
			var reveal_and_discard_modifier := CheckModifier.new(card)
			reveal_and_discard_modifier.restricted_category = CheckCategory.COMBAT
			reveal_and_discard_modifier.added_traits = card.traits
			reveal_and_discard_modifier.restricted_skills = [Skill.STRENGTH, Skill.MELEE]
			reveal_and_discard_modifier.prohibited_traits = ["Offhand"]
			reveal_and_discard_modifier.added_dice = [6, 6]
			
			actions.append(PlayCardAction.new(card, Action.DISCARD, reveal_and_discard_modifier, {"IsCombat": true}))
			
		# Otherwise, if this card has already been played, present the discard option only.
		elif _asm.staged_cards.has(card):
			var discard_modifier := CheckModifier.new(card)
			discard_modifier.restricted_category = CheckCategory.COMBAT
			discard_modifier.restricted_skills = [Skill.STRENGTH, Skill.MELEE]
			discard_modifier.prohibited_traits = ["Offhand"]
			discard_modifier.added_dice = [6]
			
			actions.append(PlayCardAction.new(card, Action.DISCARD, discard_modifier, {"IsCombat": true, "IsFreely": true}))
	
	if _can_discard_to_evade(card):
		actions.append(PlayCardAction.new(card, Action.DISCARD, null))
	
	return actions


# Can be played on Strength or Melee combat checks.
func _is_playable_for_combat(card: CardInstance) -> bool:
	return _contexts.check_context \
		and _contexts.check_context.is_combat_valid \
		and _contexts.check_context.character == card.owner \
		and not _contexts.check_context.are_skills_blocked([Skill.STRENGTH, Skill.MELEE])


# Can be played by the owner to evade an Obstacle or Trap barrier.
func _can_discard_to_evade(card: CardInstance) -> bool:
	return _contexts.encounter_context \
		and _contexts.encounter_context.current_phase == EncounterContext.EncounterPhase.EVASION \
		and _contexts.encounter_context.card_data.card_type == CardType.BARRIER \
		and _contexts.encounter_context.has_trait(["Obstacle", "Trap"]) \
		and _contexts.encounter_context.character == card.owner
