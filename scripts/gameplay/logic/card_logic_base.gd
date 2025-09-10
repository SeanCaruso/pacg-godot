class_name CardLogicBase
extends Resource

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const CheckCategory := preload("res://scripts/data/card_data/check_step.gd").CheckCategory
const CheckMode := preload("res://scripts/data/card_data/check_requirement.gd").CheckMode
const Scourge := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge
const Skill := preload("res://scripts/core/enums/skill.gd").Skill

var _asm := GameServices.asm
var _contexts := GameServices.contexts


func can_evade() -> bool:
	return true


func get_available_actions(card: CardInstance) -> Array[StagedAction]:
	if not card.owner: return []
	
	# If the owner is exhausted and already played a boon,
	# no actions are available on another boon.
	if card.owner.active_scourges.has(Scourge.EXHAUSTED) \
	and _asm.staged_actions_for(card.owner).any(func(a: StagedAction): return a.card != card):
		return []
	
	# If there's an encountered card with immunities, check the card's traits.
	if _contexts.encounter_context:
		for immunity in _contexts.encounter_context.card_data.immunities:
			if card.traits.has(immunity): return []
	
	# Only cards in hand, revealed, and displayed areas are playable by default.
	# Resolvables will add extra actions if necessary.
	if not card.current_location in [CardLocation.HAND, CardLocation.REVEALED, CardLocation.DISPLAYED]:
		return []
	
	# Check for any prohibited traits.
	var prohibited_traits: Array[String] = []
	if _contexts.encounter_context:
		prohibited_traits = _contexts.encounter_context.get_prohibited_traits(card.owner)
	for pro_trait in prohibited_traits:
		if card.traits.has(pro_trait): return []
	
	# If we made it this far, query the actual card logic.
	return get_available_card_actions(card)


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	return []


## Applies the permanent, one-time effects of an action when committed.
func on_commit(action: StagedAction) -> void:
	pass


func on_encounter() -> void:
	pass


func get_on_encounter_resolvable(card: CardInstance) -> BaseResolvable: return null


func get_before_acting_resolvable(card: CardInstance) -> BaseResolvable: return null


func get_resolve_encounter_resolvable(card: CardInstance) -> BaseResolvable: return null


func get_after_acting_resolvable(card: CardInstance) -> BaseResolvable: return null


func get_check_resolvable(card: CardInstance) -> BaseResolvable:
	if card.data.check_requirement.mode in [CheckMode.CHOICE, CheckMode.SINGLE]:
		return CheckResolvable.new(
			card,
			_contexts.encounter_context.character,
			card.data.check_requirement)
	
	return null


func on_defeated(card: CardInstance) -> void:
	if card.is_bane:
		GameServices.cards.move_card_to(card, CardLocation.VAULT)
	else:
		_contexts.encounter_context.character.add_to_hand(card)


func on_undefeated(card: CardInstance) -> void:
	if card.is_bane:
		if _contexts.encounter_pc_location:
			_contexts.encounter_pc_location.shuffle_in(card, true)
	else:
		GameServices.cards.move_card_to(card, CardLocation.VAULT)


func get_recovery_resolvable(card: CardInstance) -> BaseResolvable: return null
