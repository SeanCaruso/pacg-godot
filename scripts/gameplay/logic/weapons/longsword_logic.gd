class_name LongswordLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	if not _is_card_playable(card): return []
	
	var actions: Array[StagedAction] = []
	
	# If a weapon hasn't been staged yet, present one or both options
	if _contexts.current_resolvable.can_stage_type(card.card_type):
		var reveal_modifier := CheckModifier.new(card)
		reveal_modifier.restricted_category = CheckCategory.COMBAT
		reveal_modifier.restricted_skills = [Skill.STRENGTH, Skill.MELEE]
		reveal_modifier.added_traits = card.traits
		reveal_modifier.added_dice = [8]
		actions.append(PlayCardAction.new(card, Action.REVEAL, reveal_modifier, {"IsCombat": true}))
		
		# If not proficient, just the reveal power is available.
		if not _contexts.check_context.character.is_proficient(card): return actions
		
		var reveal_and_reload_mod := CheckModifier.new(card)
		reveal_and_reload_mod.restricted_category = CheckCategory.COMBAT
		reveal_and_reload_mod.restricted_skills = [Skill.STRENGTH, Skill.MELEE]
		reveal_and_reload_mod.added_traits = card.traits
		reveal_and_reload_mod.added_dice = [8, 4]
		actions.append(PlayCardAction.new(card, Action.RELOAD, reveal_and_reload_mod, {"IsCombat": true}))
	
	# Otherwise, if this card has been played, present the reload option if proficient
	elif _asm.is_card_staged(card) and _contexts.check_context.character.is_proficient(card):
		var reload_mod := CheckModifier.new(card)
		reload_mod.restricted_category = CheckCategory.COMBAT
		reload_mod.restricted_skills = [Skill.STRENGTH, Skill.MELEE]
		reload_mod.added_dice = [4]
		actions.append(PlayCardAction.new(card, Action.RELOAD, reload_mod, {"IsCombat": true, "IsFreely": true}))
	
	return actions


func _is_card_playable(card: CardInstance) -> bool:
	return _contexts.check_context \
	and _contexts.check_context.is_combat_valid \
	and _contexts.current_resolvable is CheckResolvable \
	and _contexts.current_resolvable.has_combat \
	and _contexts.check_context.character == card.owner \
	and _contexts.check_context.can_use_skill([Skill.STRENGTH, Skill.MELEE])
