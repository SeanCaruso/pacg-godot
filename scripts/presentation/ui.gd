extends CanvasLayer

const GuardLocationsGui = preload("uid://c47qovhrqypa")
const GUARD_LOCATIONS_GUI = preload("uid://b400nrqo4hjyh")

const ExamineGui := preload("res://scenes/ui_objects/examine_gui.gd")
const EXAMINE_GUI_SCENE := preload("res://scenes/ui_objects/examine_gui.tscn")

const MoveAfterClosingGui = preload("uid://ddl7thxydojwn")
const MOVE_AFTER_CLOSING_GUI = preload("uid://bp0qmu5xq5sg5")

const MoveGui := preload("res://scenes/ui_objects/move_gui.gd")
const MOVE_GUI_SCENE := preload("res://scenes/ui_objects/move_gui.tscn")

const SkillDialog := preload("res://scenes/ui_objects/skill_selection_dialog/skill_selection_dialog.gd")
const SKILL_DIALOG_SCENE := preload("res://scenes/ui_objects/skill_selection_dialog/skill_selection_dialog.tscn")

@onready var dialog_area: Control = %DialogArea
@onready var skill_dialog_area: Control = %SkillDialogArea
@onready var game_over_panel: PanelContainer = %GameOverPanel
@onready var game_over_label: Label = %GameOverLabel


func _ready() -> void:	
	# Encounter/Check events
	#DialogEvents.guard_locations_started.connect(_on_guard_locations_started)
	DialogEvents.check_start_event.connect(_on_check_start)
	DialogEvents.skill_selection_ended.connect(_on_skill_selection_ended)
	
	# Turn phase events
	DialogEvents.guard_locations_started.connect(_on_guard_locations_started)
	DialogEvents.location_closed.connect(_on_location_closed)
	DialogEvents.move_clicked_event.connect(_on_move_clicked)
	
	# Deck examine events
	DialogEvents.examine_event.connect(_on_examine_event)
	
	# Game end events
	GameEvents.game_ended.connect(_on_game_end)


func _on_skill_selection_ended() -> void:
	for c in skill_dialog_area.get_children():
		c.queue_free()


func _on_check_start(context: CheckContext) -> void:
	var dialog: SkillDialog = SKILL_DIALOG_SCENE.instantiate()
	skill_dialog_area.add_child(dialog)
	dialog.set_context(context)


func _on_game_end(is_victory: bool) -> void:
	game_over_panel.visible = true
	game_over_label.text = "VICTORY!" if is_victory else "DEFEAT!"


func _on_examine_event(context: ExamineContext) -> void:
	var dialog: ExamineGui = EXAMINE_GUI_SCENE.instantiate()
	dialog_area.add_child(dialog)
	dialog.start_examine(context)


func _on_guard_locations_started(resolvable: GuardLocationsResolvable) -> void:
	var dialog: GuardLocationsGui = GUARD_LOCATIONS_GUI.instantiate()
	dialog_area.add_child(dialog)
	dialog.initialize(resolvable)


func _on_location_closed(loc: Location) -> void:
	var dialog: MoveAfterClosingGui = MOVE_AFTER_CLOSING_GUI.instantiate()
	dialog_area.add_child(dialog)
	dialog.initialize(loc)


func _on_move_clicked(pc: PlayerCharacter) -> void:
	var dialog: MoveGui = MOVE_GUI_SCENE.instantiate()
	dialog_area.add_child(dialog)
	dialog.initialize(pc)
