class_name ResolveEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase

var _contexts: ContextManager

func _init(game_services: GameServices):
	_contexts = game_services.contexts
	
	
func on_execute() -> void:
	if !_contexts.encounter_context: return
	
	_contexts.encounter_context.current_phase = EncounterPhase.RESOLVE
	
	var resolvable := _contexts.encounter_context.card.get_resolve_encounter_resolvable()
	if resolvable:
		_contexts.new_resolvable(resolvable)
