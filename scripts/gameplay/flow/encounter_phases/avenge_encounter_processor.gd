class_name AvengeEncounterProcessor
extends BaseProcessor

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase
	
	
func execute() -> void:
	if not Contexts.encounter_context \
	or Contexts.encounter_context.is_avenged \
	or not Contexts.check_context \
	or not Contexts.check_context.check_result \
	or not Contexts.encounter_context.card.is_bane \
	or Contexts.check_context.check_result.was_success \
	or Contexts.encounter_context.character.local_characters.size() == 1:
		return
	
	Contexts.encounter_context.current_phase = EncounterPhase.AVENGE
