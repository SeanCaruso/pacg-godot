extends Node

# Turn phase events
signal move_clicked_event(pc: PlayerCharacter)

signal location_closed(loc: Location)
func emit_location_closed(loc: Location) -> void:
	location_closed.emit(loc)

# Deck examine events
signal examine_event(context: ExamineContext)

# Encounter/Skill selection events
signal custom_check_encountered()
func emit_custom_check_encountered() -> void:
	custom_check_encountered.emit()

signal check_start_event(context: CheckContext)
func emit_check_start_event(context: CheckContext) -> void:
	check_start_event.emit(context)

signal valid_skills_changed(skills: Array[Skill])
signal skill_selection_ended()
func emit_skill_selection_ended() -> void:
	skill_selection_ended.emit()

const Skill := preload("res://scripts/core/enums/skill.gd").Skill
