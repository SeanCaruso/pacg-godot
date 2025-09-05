class_name BeforeActingEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase


func on_execute() -> void:
	if !_contexts.encounter_context: return

	_contexts.encounter_context.current_phase = EncounterPhase.BEFORE_ACTING

	if _contexts.encounter_context.ignore_before_acting_powers: return

	var resolvable := _contexts.encounter_context.card.get_before_acting_resolvable()
	if resolvable:
		_contexts.new_resolvable(resolvable)	
