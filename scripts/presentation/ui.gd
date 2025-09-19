extends CanvasLayer

const ExamineGui := preload("res://scenes/ui_objects/examine_gui.gd")
const EXAMINE_GUI_SCENE := preload("res://scenes/ui_objects/examine_gui.tscn")

const SkillDialog := preload("res://scenes/ui_objects/skill_selection_dialog/skill_selection_dialog.gd")
const SKILL_DIALOG_SCENE := preload("res://scenes/ui_objects/skill_selection_dialog/skill_selection_dialog.tscn")

@onready var deck_examine_area: Control = %DeckExamineArea
@onready var skill_dialog_area: Control = %SkillDialogArea


func _ready() -> void:
	# Check events
	DialogEvents.check_start_event.connect(_on_check_start)
	DialogEvents.check_end_event.connect(_on_check_end)
	
	# Deck examine events
	DialogEvents.examine_event.connect(_on_examine_event)


func _on_check_end() -> void:
	for c in skill_dialog_area.get_children():
		c.queue_free()


func _on_check_start(context: CheckContext) -> void:
	var dialog: SkillDialog = SKILL_DIALOG_SCENE.instantiate()
	skill_dialog_area.add_child(dialog)
	dialog.set_context(context)


func _on_examine_event(context: ExamineContext) -> void:
	var dialog: ExamineGui = EXAMINE_GUI_SCENE.instantiate()
	deck_examine_area.add_child(dialog)
	dialog.start_examine(context)
