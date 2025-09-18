# skill_dialog_area.gd
extends Control

const SkillDialog := preload("res://scenes/ui_objects/skill_selection_dialog/skill_selection_dialog.gd")
const SKILL_DIALOG_SCENE := preload("res://scenes/ui_objects/skill_selection_dialog/skill_selection_dialog.tscn")

var _dialog: SkillDialog


func _ready() -> void:
	DialogEvents.check_start_event.connect(_on_check_start)
	DialogEvents.check_end_event.connect(_on_check_end)


func _on_check_end() -> void:
	_dialog.queue_free()


func _on_check_start(context: CheckContext) -> void:
	_dialog = SKILL_DIALOG_SCENE.instantiate()
	add_child(_dialog)
	_dialog.set_context(context)
