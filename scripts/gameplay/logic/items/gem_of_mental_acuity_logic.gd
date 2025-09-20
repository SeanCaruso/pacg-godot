class_name GemOfMentalAcuityLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Usable on any non-combat check by the owner.
	if not Contexts.check_context \
	or not Contexts.check_context.is_skill_valid \
	or not Contexts.current_resolvable.can_stage_type(card.card_type) \
	or Contexts.check_context.character != card.owner:
		return []
	
	var modifier := CheckModifier.new(card)
	modifier.restricted_category = CheckCategory.SKILL
	modifier.die_override = card.owner.get_best_skill([Skill.INTELLIGENCE, Skill.WISDOM, Skill.CHARISMA])["die"]
	
	return [PlayCardAction.new(card, Action.RECHARGE, modifier)]
