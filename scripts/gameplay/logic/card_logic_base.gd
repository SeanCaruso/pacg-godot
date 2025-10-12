class_name CardLogicBase
extends Resource

const Action := preload("res://scripts/core/enums/action_type.gd").Action
const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const CardType := preload("res://scripts/core/enums/card_type.gd").CardType
const CheckCategory := preload("res://scripts/data/card_data/check_step.gd").CheckCategory
const CheckMode := preload("res://scripts/data/card_data/check_requirement.gd").CheckMode
const Scourge := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge
const Skill := preload("res://scripts/core/enums/skill.gd").Skill


func can_evade() -> bool:
	return true


func get_available_actions(card: CardInstance) -> Array[StagedAction]:
	if not card.owner:
		return []
	
	# If the owner is exhausted and already played a boon,
	# no actions are available on another boon.
	if card.owner.active_scourges.has(Scourge.EXHAUSTED) \
	and TaskManager.current_resolvable \
	and TaskManager.current_resolvable.staged_cards.any(
		func(c: CardInstance):
			return c.owner == card.owner and c != card
	):
		return []
	
	# If there's an encountered card with immunities, check the card's traits.
	if Contexts.encounter_context:
		for immunity in Contexts.encounter_context.card.data.immunities:
			if card.traits.has(immunity): return []
	
	# Only cards in hand, revealed, and displayed areas are playable by default.
	# Resolvables will add extra actions if necessary.
	if not card.current_location in [CardLocation.HAND, CardLocation.REVEALED, CardLocation.DISPLAYED]:
		return []
	
	# Check for any prohibited traits.
	var prohibited_traits: Array[String] = []
	if Contexts.encounter_context:
		prohibited_traits = Contexts.encounter_context.get_prohibited_traits(card.owner)
	for pro_trait in prohibited_traits:
		if card.traits.has(pro_trait): return []
	
	# If we made it this far, query the actual card logic.
	return get_available_card_actions(card)


func get_available_card_actions(_card: CardInstance) -> Array[StagedAction]:
	return []


## Applies the permanent, one-time effects of an action when committed.
func on_commit(_action: StagedAction) -> void:
	pass


func on_encounter() -> void:
	pass


func get_on_encounter_resolvable(_card: CardInstance) -> BaseResolvable: return null


func get_before_acting_resolvable(_card: CardInstance) -> BaseResolvable: return null


func get_resolve_encounter_resolvable(_card: CardInstance) -> BaseResolvable: return null


func get_after_acting_resolvable(_card: CardInstance) -> BaseResolvable: return null


func get_check_resolvable(card: CardInstance) -> BaseResolvable:
	if card.data.check_requirement.mode in [CheckMode.CHOICE, CheckMode.SINGLE]:
		return CheckResolvable.new(
			card,
			Contexts.encounter_context.character,
			card.data.check_requirement)
	
	return null


func get_custom_check_resolvable(_card: CardInstance) -> BaseResolvable:
	return null


func on_defeated(card: CardInstance) -> void:
	if card.is_bane:
		Cards.move_card_to(card, CardLocation.VAULT)
	else:
		Contexts.encounter_context.character.add_to_hand(card)


func on_evaded(card: CardInstance) -> void:
	if not Contexts.encounter_pc_location:
		return
	
	if card.current_location == CardLocation.DECK:
		Contexts.encounter_pc_location.shuffle_in(card, true)


func on_undefeated(card: CardInstance) -> void:
	if card.is_bane:
		if card.current_location == CardLocation.DECK and Contexts.encounter_pc_location:
			Contexts.encounter_pc_location.shuffle_in(card, true)
	else:
		Cards.move_card_to(card, CardLocation.VAULT)


func get_recovery_resolvable(_card: CardInstance) -> BaseResolvable: return null
