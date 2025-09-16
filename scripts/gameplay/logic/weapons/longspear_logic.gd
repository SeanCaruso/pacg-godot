class_name LongspearLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Reveal for Strength/Melee +1d8 on your combat check.
	if _contexts.check_context \
	and _contexts.check_context.is_combat_valid \
	and _contexts.current_resolvable is CheckResolvable \
	and _contexts.current_resolvable.has_combat \
	and _contexts.check_context.character == card.owner \
	and _contexts.check_context.can_use_skill([Skill.STRENGTH, Skill.MELEE]) \
	and _contexts.current_resolvable.can_stage_type(card.card_type):	
		var modifier := CheckModifier.new(card)
		modifier.restricted_category = CheckCategory.COMBAT
		modifier.added_valid_skills = [Skill.STRENGTH, Skill.MELEE]
		modifier.restricted_skills = [Skill.STRENGTH, Skill.MELEE]
		modifier.added_dice = [8]
		modifier.added_traits = card.traits
		modifier.prohibited_traits = ["Offhand"]
	
		return [PlayCardAction.new(card, Action.REVEAL, modifier, {"IsCombat": true})]
	
	# Discard to reroll if we have a RerollResolvable and this card is one of the options.
	if _contexts.current_resolvable is RerollResolvable \
	and _contexts.check_context.context_data.get("rerollCards", []).has(self):
		return [PlayCardAction.new(card, Action.DISCARD, null, {"IsFreely": true})]
	
	return []


func on_commit(action: StagedAction):
	_contexts.encounter_context.add_prohibited_traits(action.card.owner, ["Offhand"])
	
	var reroll_sources = _contexts.check_context.context_data.get_or_add("rerollCards", [])
	
	match action.action_type:
		Action.REVEAL:
			reroll_sources.append(self)
		Action.DISCARD:
			reroll_sources.erase(self)
			_contexts.check_context.context_data["doReroll"] = true
