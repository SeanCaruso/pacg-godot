extends Node

# Turn phase events
signal move_clicked_event(pc: PlayerCharacter)

# Deck examine events
signal examine_event(context: ExamineContext)

# Skill selection events
signal check_start_event(context: CheckContext)
signal valid_skills_changed(skills: Array[Skill])
signal check_end_event()

const Skill := preload("res://scripts/core/enums/skill.gd").Skill
