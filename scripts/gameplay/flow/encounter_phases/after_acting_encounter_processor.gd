class_name AfterActingEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase


func execute() -> void:
	if !Contexts.encounter_context: return
	
	Contexts.encounter_context.current_phase = EncounterPhase.AFTER_ACTING
	
	if Contexts.encounter_context.ignore_after_acting_powers: return
	
	var resolvable = Contexts.encounter_context.card.get_after_acting_resolvable()
	if resolvable:
		TaskManager.push(resolvable)
