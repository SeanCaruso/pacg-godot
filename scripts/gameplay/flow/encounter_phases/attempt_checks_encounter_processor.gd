class_name AttemptChecksEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase


func on_execute() -> void:
	if !Contexts.encounter_context: return
	
	Contexts.encounter_context.current_phase = EncounterPhase.ATTEMPT_CHECK
	
	var resolvable := Contexts.encounter_context.card.get_check_resolvable()
	if resolvable:
		Contexts.new_resolvable(resolvable)
