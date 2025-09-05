class_name AttemptChecksEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase


func on_execute() -> void:
	if !_contexts.encounter_context: return
	
	_contexts.encounter_context.current_phase = EncounterPhase.ATTEMPT_CHECK
	
	var resolvable := _contexts.encounter_context.card.get_check_resolvable()
	if resolvable:
		_contexts.new_resolvable(resolvable)
