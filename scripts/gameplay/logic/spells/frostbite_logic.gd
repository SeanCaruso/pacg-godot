class_name FrostbiteLogic
extends CardLogicBase


func on_commit(_action: StagedAction) -> void:
	if not Contexts.encounter_context or not Contexts.encounter_context.card.is_bane:
		return
	
	Contexts.encounter_context.resolvable_modifiers.append(_modify_damage_resolvable)


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Playable for Arcane/Divine +2d4 on the owner's combat check.
	if not Contexts.check_context \
	or not Contexts.check_context.is_combat_valid \
	or not TaskManager.current_resolvable is CheckResolvable \
	or not TaskManager.current_resolvable.has_combat \
	or TaskManager.current_resolvable.character != card.owner \
	or not Contexts.check_context.resolvable.can_stage_type(card.card_type):
		return []
	
	var modifier := CheckModifier.new(card)
	modifier.restricted_category = CheckCategory.COMBAT
	modifier.added_valid_skills = [Skill.ARCANE, Skill.DIVINE]
	modifier.restricted_skills = [Skill.ARCANE, Skill.DIVINE]
	modifier.added_dice = [4, 4]
	modifier.added_traits = card.traits
	
	return [PlayCardAction.new(card, Action.BANISH, modifier, {"IsCombat": true})]


func get_recovery_resolvable(card: CardInstance) -> BaseResolvable:
	if not card.owner.is_proficient(card):
		return null
	
	var check_req := CheckRequirement.new()
	check_req.mode = CheckMode.CHOICE
	
	var arcane_step := CheckStep.new()
	arcane_step.category = CheckCategory.SKILL
	arcane_step.base_dc = 8
	arcane_step.allowed_skills = [Skill.ARCANE]
	check_req.check_steps.append(arcane_step)
	
	var divine_step := CheckStep.new()
	divine_step.category = CheckCategory.SKILL
	divine_step.base_dc = 10
	divine_step.allowed_skills = [Skill.DIVINE]
	check_req.check_steps.append(divine_step)
	
	var resolvable := CheckResolvable.new(card, card.owner, check_req)
	resolvable.on_success = func(): card.owner.recharge(card)
	resolvable.on_failure = func(): card.owner.discard(card)
	
	return CardUtils.create_default_recovery_resolvable(resolvable)


func _modify_damage_resolvable(resolvable: BaseResolvable) -> void:
	if not resolvable is DamageResolvable:
		return
	
	var damage_resolvable := resolvable as DamageResolvable
	damage_resolvable.amount -= 1
