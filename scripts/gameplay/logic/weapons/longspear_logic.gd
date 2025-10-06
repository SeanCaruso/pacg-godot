class_name LongspearLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Reveal for Strength/Melee +1d8 on your combat check.
	if Contexts.check_context \
	and Contexts.check_context.is_combat_valid \
	and TaskManager.current_resolvable is CheckResolvable \
	and TaskManager.current_resolvable.has_combat \
	and Contexts.check_context.character == card.owner \
	and not Contexts.check_context.are_skills_blocked([Skill.STRENGTH, Skill.MELEE]) \
	and TaskManager.current_resolvable.can_stage_type(card.card_type):	
		var modifier := CheckModifier.new(card)
		modifier.restricted_category = CheckCategory.COMBAT
		modifier.added_valid_skills = [Skill.STRENGTH, Skill.MELEE]
		modifier.restricted_skills = [Skill.STRENGTH, Skill.MELEE]
		modifier.added_dice = [8]
		modifier.added_traits = card.traits
		modifier.prohibited_traits = ["Offhand"]
	
		return [PlayCardAction.new(card, Action.REVEAL, modifier, {"IsCombat": true})]
	
	# Discard to reroll if we have a RerollResolvable and this card is one of the options.
	if TaskManager.current_resolvable is RerollResolvable \
	and Contexts.check_context.context_data.get("rerollCards", []).has(self):
		return [PlayCardAction.new(card, Action.DISCARD, null, {"IsFreely": true})]
	
	return []


func on_commit(action: StagedAction):
	Contexts.encounter_context.add_prohibited_traits(action.card.owner, ["Offhand"])
	
	var reroll_sources = Contexts.check_context.context_data.get_or_add("rerollCards", [])
	
	match action.action_type:
		Action.REVEAL:
			reroll_sources.append(self)
		Action.DISCARD:
			reroll_sources.erase(self)
			Contexts.check_context.context_data["doReroll"] = true
