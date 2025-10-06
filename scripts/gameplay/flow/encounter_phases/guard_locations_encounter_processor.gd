class_name GuardLocationsEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase


func execute() -> void:
	if !Contexts.encounter_context: return

	Contexts.encounter_context.current_phase = EncounterPhase.GUARD_LOCATIONS
	
	var resolvable := GuardLocationsResolvable.new()
	Contexts.encounter_context.guard_locations_resolvable = resolvable
	TaskManager.push(resolvable)
