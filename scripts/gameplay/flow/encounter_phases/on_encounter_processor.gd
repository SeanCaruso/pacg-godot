class_name OnEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase

var _contexts: ContextManager

func _init(game_services: GameServices):
	_contexts = game_services.contexts
	
	
func on_execute() -> void:
	if !_contexts.encounter_context: return
	
	_contexts.encounter_context.current_phase = EncounterPhase.ON_ENCOUNTER
	
	var resolvable := _contexts.encounter_context.card.get_on_encounter_resolvable()
	if resolvable:
		_contexts.new_resolvable(resolvable)
