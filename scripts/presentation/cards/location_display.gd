# location_display.gd
extends TextureRect

signal card_clicked(location_display: Control)

const CardType := preload("res://scripts/core/enums/card_type.gd").CardType
const Skill := preload("res://scripts/core/enums/skill.gd").Skill

#region ========== NODE REFERENCES ==========
# Using the '%' sign gets a reference to nodes with a "unique name in owner".
# It's Godot's best practice for getting nodes in a script.

# --- Top/Bottom Panel ---
@onready var card_name: Label = %CardName
@onready var card_level: Label = %CardLevel

# --- Powers ---
@onready var at_location_text: Label = %AtLocationText
@onready var at_location_button: TextureButton = %AtLocationButton
@onready var to_close_text: Label = %ToCloseText
@onready var to_close_button: TextureButton = %ToCloseButton
@onready var when_closing_text: Label = %WhenClosingText
@onready var when_closing_button: TextureButton = %WhenClosingButton

# --- Traits ---
@onready var traits_container: VBoxContainer = %Traits_Container

# --- Input ---
@onready var card_input_handler: CardInputHandler = %CardInputHandler
#endregion

var is_previewed: bool = false
var _location: Location
var _original_pos: Vector2
var _original_scale: Vector2
var _original_z_idx: int
var _is_dragging: bool = false

var location: Location:
	get: return _location


## Main entry point - call this to tell the card what to display.
func set_location(loc: Location) -> void:
	if not loc:
		visible = false
		return
		
	visible = true
	_location = loc
	_update_display()
	
	card_input_handler.setup_input(loc, self)


func _update_display():
	if not card_name:
		printerr("LocationDisplay is null - add it to the scene first!")
		return
	
	var data := _location.data
	
	# 1. Update top bar
	card_name.text = data.card_name.to_upper()
	card_level.text = str(data.card_level)
	
	# 4. Update Powers
	at_location_text.text = StringUtils.replace_adventure_level(data.at_location_power.text)
	at_location_button.visible = data.at_location_power.is_activated_power
	at_location_button.texture_normal = data.at_location_power.sprite_enabled
	at_location_button.texture_disabled = data.at_location_power.sprite_disabled
	at_location_button.pressed.connect(Callable(_location.logic, data.at_location_power.power_id))
	GuiUtils.add_mouseover_effect_to_button(at_location_button)
	
	to_close_text.text = StringUtils.replace_adventure_level(data.to_close_power.text)
	to_close_button.visible = data.to_close_power.is_activated_power
	to_close_button.texture_normal = data.to_close_power.sprite_enabled
	to_close_button.texture_disabled = data.to_close_power.sprite_disabled
	to_close_button.pressed.connect(Callable(_location.logic, data.to_close_power.power_id))
	GuiUtils.add_mouseover_effect_to_button(to_close_button)
	
	when_closing_text.text = StringUtils.replace_adventure_level(data.when_closed_power.text)
	when_closing_button.visible = data.when_closed_power.is_activated_power
	when_closing_button.texture_normal = data.when_closed_power.sprite_enabled
	when_closing_button.texture_disabled = data.when_closed_power.sprite_disabled
	when_closing_button.pressed.connect(Callable(_location.logic, data.when_closed_power.power_id))
	GuiUtils.add_mouseover_effect_to_button(when_closing_button)
	
	# 5. Update traits
	_populate_traits(data.traits)


func _populate_traits(traits: Array[String]) -> void:
	# CRITICAL STEP: Clear out any old labels from a previous display.
	for child in traits_container.get_children():
		child.queue_free()
	
	for card_trait in traits:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 8)
		label.text = card_trait.to_upper()
		traits_container.add_child(label)


func _on_card_clicked(card_display: Control) -> void:
	if not is_previewed:
		card_clicked.emit(card_display)


func _on_drag_started(_card: CardInstance) -> void:
	# Store initial state
	_original_pos = position
	_original_scale = scale
	_original_z_idx = z_index
	_is_dragging = true
	
	# Visual feedback
	z_index = 100 # Bring to front.
	scale *= 1.05


func _on_drag_updated(_card: CardInstance, delta: Vector2) -> void:
	if not _is_dragging: return
	
	position = _original_pos + delta


func _on_drag_ended(_card: CardInstance, _global_pos: Vector2) -> void:
	_is_dragging = false
	position = _original_pos
	scale = _original_scale
	z_index = _original_z_idx
