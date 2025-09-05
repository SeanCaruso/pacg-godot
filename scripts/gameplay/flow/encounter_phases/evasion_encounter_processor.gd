class_name EvasionEncounterProcessor
extends BaseProcessor

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase
const Scourge := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge

var _cards: CardManager

func _init(game_services: GameServices):
	super(game_services)
	_cards = game_services.cards


func on_execute() -> void:
	if !_contexts.encounter_context: return
	
	if !_contexts.encounter_context.card.logic.can_evade(): return
	
	# The Entangled scourge prevents evasion.
	if _contexts.encounter_context.character.active_scourges.has(Scourge.ENTANGLED): return
	
	# First, see if there were any explore effects that added an evasion.
	if _contexts.encounter_context.explore_effects.any(func(e): return e is EvadeExploreEffect):
		prompt_for_evasion(evade_encounter)
		return
		
	# If not, update the phase and check for available evasion powers.
	_contexts.encounter_context.current_phase = EncounterPhase.EVASION
	
	# TODO: Check character powers

	# Finally, check characters' cards to see if any have available actions during the evasion phase.
	if !_cards._all_cards.any(func(c: CardInstance): return !c.get_available_actions().is_empty()):
		return
		
	GameEvents.set_status_text.emit("Evade?")
	
	_contexts.new_resolvable(EvadeResolvable.new(evade_encounter))
	
	
func prompt_for_evasion(on_evade: Callable) -> void:
	var resolvable = PlayerChoiceResolvable.new("Evade?", [
		ChoiceOption.new("Evade", on_evade),
		ChoiceOption.new("Encounter", func(): pass)
	])
	_contexts.new_resolvable(resolvable)
	
	
func evade_encounter() -> void:
	if !_contexts.encounter_context: return
	
	print("[%s] Evading %s" % [self, _contexts.encounter_context.card])
	
	if _contexts.encounter_context.card.current_location == CardLocation.DECK:
		_contexts.encounter_pc_location.shuffle_in(_contexts.encounter_context.card, true)
		
	# Null out the encounter for the subsequent Encounter sub-processors
	GameEvents.encounter_ended.emit()
	_contexts.end_encounter()
