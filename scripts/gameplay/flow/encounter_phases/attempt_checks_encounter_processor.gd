class_name AttemptChecksEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase


func execute() -> void:
	if !Contexts.encounter_context: return
	
	Contexts.encounter_context.current_phase = EncounterPhase.ATTEMPT_CHECK
	
	var card := Contexts.encounter_context.card
	
	if card.has_custom_check:
		DialogEvents.emit_custom_check_encountered()
	
	var resolvable := card.get_check_resolvable()
	if resolvable:
		TaskManager.push(resolvable)
