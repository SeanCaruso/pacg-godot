class_name OnEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase
	
	
func execute() -> void:
	if !Contexts.encounter_context: return
	
	Contexts.encounter_context.current_phase = EncounterPhase.ON_ENCOUNTER
	
	Contexts.encounter_context.card.on_encounter()
	
	var resolvable := Contexts.encounter_context.card.get_on_encounter_resolvable()
	if resolvable:
		TaskManager.push(resolvable)
