# location_card_container.gd
extends Control

const LOCATION_DISPLAY_SCENE := preload("res://scenes/cards/location_display.tscn")
const LocationDisplay := preload("res://scripts/presentation/cards/location_display.gd")

var _current_location_display: LocationDisplay


func _ready() -> void:
	GameEvents.player_character_changed.connect(_on_pc_location_changed)
	GameEvents.location_power_enabled.connect(_on_location_power_enabled)
	GameEvents.pc_location_changed.connect(_on_pc_location_changed)


func _on_location_power_enabled(power: LocationPower, is_enabled: bool) -> void:
	if not _current_location_display:
		return
	
	var button: TextureButton
	match power.type:
		LocationPower.Type.AT_LOCATION:
			button = _current_location_display.at_location_button
		LocationPower.Type.TO_CLOSE:
			button = _current_location_display.to_close_button
		LocationPower.Type.WHEN_CLOSED:
			button = _current_location_display.when_closing_button
	
	if not button:
		return
	
	button.disabled = not is_enabled


func _on_pc_location_changed(pc: PlayerCharacter) -> void:
	if _current_location_display:
		_current_location_display.queue_free()
	
	var new_display: LocationDisplay = LOCATION_DISPLAY_SCENE.instantiate()
	add_child(new_display)
	new_display.set_location(pc.location)
	_current_location_display = new_display
