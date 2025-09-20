class_name ResolveEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase
	
	
func on_execute() -> void:
	if !Contexts.encounter_context: return
	
	Contexts.encounter_context.current_phase = EncounterPhase.RESOLVE
	
	var resolvable := Contexts.encounter_context.card.get_resolve_encounter_resolvable()
	if resolvable:
		Contexts.new_resolvable(resolvable)
