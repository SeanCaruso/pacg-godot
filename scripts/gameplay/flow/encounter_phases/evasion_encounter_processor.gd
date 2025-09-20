class_name EvasionEncounterProcessor
extends BaseProcessor

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase
const Scourge := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge

var _cards := GameServices.cards


func on_execute() -> void:
	if Contexts.encounter_context \
	and Contexts.encounter_context.card.logic \
	and not Contexts.encounter_context.card.logic.can_evade() : return
	
	# The Entangled scourge prevents evasion.
	if Contexts.encounter_context.character.active_scourges.has(Scourge.ENTANGLED): return
	
	# First, see if there were any explore effects that added an evasion.
	if Contexts.encounter_context.explore_effects.any(func(e): return e is EvadeExploreEffect):
		prompt_for_evasion(evade_encounter)
		return
		
	# If not, update the phase and check for available evasion powers.
	Contexts.encounter_context.current_phase = EncounterPhase.EVASION
	
	# TODO: Check character powers

	# Finally, check characters' cards to see if any have available actions during the evasion phase.
	if !_cards._all_cards.any(func(c: CardInstance): return !c.get_available_actions().is_empty()):
		return
		
	GameEvents.set_status_text.emit("Evade?")
	
	Contexts.new_resolvable(EvadeResolvable.new(evade_encounter))
	
	
func prompt_for_evasion(on_evade: Callable) -> void:
	var resolvable = PlayerChoiceResolvable.new("Evade?", [
		ChoiceOption.new("Evade", on_evade),
		ChoiceOption.new("Encounter", func(): pass)
	])
	Contexts.new_resolvable(resolvable)
	
	
static func evade_encounter() -> void:
	if not Contexts.encounter_context: return
	
	print("Evading %s" % [Contexts.encounter_context.card])
	
	if Contexts.encounter_context.card.current_location == CardLocation.DECK:
		Contexts.encounter_pc_location.shuffle_in(Contexts.encounter_context.card, true)
		
	# Null out the encounter for the subsequent Encounter sub-processors
	GameEvents.encounter_ended.emit()
	Contexts.end_encounter()
