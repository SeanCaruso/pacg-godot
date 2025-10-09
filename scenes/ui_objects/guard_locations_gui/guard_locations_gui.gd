# guard_locations_gui.gd
extends Control

const GuardableLocation = preload("uid://b7chbd6wsxote")
const GUARDABLE_LOCATION = preload("uid://v87b1dc2lfcd")

const ICON_SIZE := Vector2(100.0, 100.0)

var _resolvable: GuardLocationsResolvable

@onready var locations_container: HBoxContainer = %LocationsContainer
@onready var continue_button: TextureButton = %ContinueButton


func _ready() -> void:
	GameEvents.turn_state_changed.connect(_on_turn_state_changed)


func initialize(resolvable: GuardLocationsResolvable) -> void:
	_resolvable = resolvable
	GuiUtils.add_mouseover_effect_to_button(continue_button)
	
	_refresh_display()


func _on_continue_pressed() -> void:
	queue_free()
	TaskManager.commit()


func _on_pc_clicked() -> void:
	visible = false


func _on_turn_state_changed() -> void:
	if TaskManager.current_resolvable == _resolvable:
		mouse_filter = Control.MOUSE_FILTER_STOP
		visible = true
		_refresh_display()
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		visible = false


func _refresh_display() -> void:
	for child in locations_container.get_children():
		child.queue_free()
	
	for loc in _resolvable.distant_locs_guarded:
		var panel: GuardableLocation = GUARDABLE_LOCATION.instantiate()
		locations_container.add_child(panel)
		panel.initialize(loc, _resolvable)
		panel.pc_clicked.connect(_on_pc_clicked)
