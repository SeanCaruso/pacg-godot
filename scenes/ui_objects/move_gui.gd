# move_gui.gd
extends Control

const ACTION_BUTTON_SCENE := preload("res://scenes/ui_objects/action_button.tscn")
const ActionButton := preload("res://scenes/ui_objects/action_button.gd")
const LOCATION_DISPLAY_SCENE := preload("res://scenes/cards/location_display.tscn")
const LocationDisplay := preload("res://scripts/presentation/cards/location_display.gd")

var _current_loc: Location
var _pc: PlayerCharacter

@onready var preview_container: Control = %PreviewContainer
@onready var button_container: VBoxContainer = %ButtonContainer
@onready var title_label: Label = %TitleLabel
@onready var commit_button: TextureButton = %CommitButton
@onready var cancel_button: TextureButton = %CancelButton


func initialize(pc: PlayerCharacter):
	_pc = pc
	title_label.text = ("Move %s" % pc.name).to_upper()
	
	GuiUtils.add_mouseover_effect_to_button(commit_button)
	GuiUtils.add_mouseover_effect_to_button(cancel_button)
	
	for location in Contexts.game_context.locations:
		var button: ActionButton = ACTION_BUTTON_SCENE.instantiate()
		button_container.add_child(button)
		button.text = location.name
		button.pressed.connect(_preview.bind(location))
		GuiUtils.add_mouseover_effect_to_button(button)
	
	_preview(pc.location)


func _on_cancel_pressed() -> void:
	queue_free()


func _on_commit_pressed() -> void:
	Contexts.turn_context.can_give = false
	Contexts.turn_context.can_move = false
	_pc.location = _current_loc
	GameEvents.pc_location_changed.emit(_pc)
	TaskManager.commit()
	queue_free()


func _preview(loc: Location):
	for c in preview_container.get_children():
		c.queue_free()
	
	_current_loc = loc
	
	var loc_display: LocationDisplay = LOCATION_DISPLAY_SCENE.instantiate()
	preview_container.add_child(loc_display)
	loc_display.set_location(loc)
	loc_display.scale = Vector2(1.8, 1.8)
	
	commit_button.disabled = loc == _pc.location
