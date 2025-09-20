class_name BeforeActingEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase


func on_execute() -> void:
	if !Contexts.encounter_context: return

	Contexts.encounter_context.current_phase = EncounterPhase.BEFORE_ACTING

	if Contexts.encounter_context.ignore_before_acting_powers: return

	var resolvable := Contexts.encounter_context.card.get_before_acting_resolvable()
	if resolvable:
		Contexts.new_resolvable(resolvable)	
