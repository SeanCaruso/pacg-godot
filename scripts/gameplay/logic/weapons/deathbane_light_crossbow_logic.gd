class_name DeathbaneLightCrossbowLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Reveal to use Dexterity or Ranged + 1d8+1 on your combat check.
	if not Contexts.check_context \
	or not Contexts.check_context.is_combat_valid \
	or not TaskManager.current_resolvable is CheckResolvable \
	or not TaskManager.current_resolvable.has_combat \
	or Contexts.check_context.character != card.owner \
	or not TaskManager.current_resolvable.can_stage_type(card.card_type):
		return []
	
	var modifier := CheckModifier.new(card)
	modifier.restricted_category = CheckCategory.COMBAT
	modifier.added_valid_skills = [Skill.DEXTERITY, Skill.RANGED]
	modifier.restricted_skills = [Skill.DEXTERITY, Skill.RANGED]
	modifier.added_dice = [8]
	modifier.added_bonus = 1
	modifier.added_traits = card.traits
	
	# Against an Undead bane, add another 1d8.
	if Contexts.encounter_context \
	and Contexts.encounter_context.card.data.traits.has("Undead"):
		modifier.added_dice.append(8)
	
	return [PlayCardAction.new(card, Action.REVEAL, modifier, {"IsCombat": true})]
