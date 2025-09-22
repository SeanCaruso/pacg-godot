# move_after_closing.gd
extends Control

const DistantLocation = preload("uid://b306ovgy1fn34")
const DISTANT_LOCATION = preload("uid://bt5pgyebqln2w")
const DraggableIcon = preload("uid://bbcv6g7f0frnb")
const LocationDisplay = preload("uid://cub6h47pj0t5o")
const LOCATION_DISPLAY = preload("uid://bixget8gifffr")

const ICON_SIZE := Vector2(100.0, 100.0)

var _closed_loc: Location
var _distant_locs: Array[DistantLocation] = []

@onready var local_icons: HBoxContainer = %LocalIcons
@onready var locations_container: HBoxContainer = %LocationsContainer
@onready var continue_button: TextureButton = %ContinueButton
@onready var left_preview: Control = %LeftPreview
@onready var right_preview: Control = %RightPreview


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_END:
			continue_button.disabled = local_icons.get_child_count() > 0


func initialize(loc: Location) -> void:
	_closed_loc = loc
	GuiUtils.add_mouseover_effect_to_button(continue_button)
	
	_setup_local_icons()
	_setup_distant_locs()


func _on_continue_pressed() -> void:
	for loc_panel in _distant_locs:
		var loc: Location = loc_panel.get_meta("loc")
		
		for pc_icon in loc_panel.character_icons.get_children():
			var pc: PlayerCharacter = pc_icon.get_meta("pc")
			if not pc:
				continue
			pc.location = loc
	
	GameEvents.pc_location_changed.emit(Contexts.game_context.active_character)
	queue_free()


func _distant_loc_on_mouse_entered(panel: DistantLocation):
	var loc: Location = panel.get_meta("loc")
	if not loc:
		return
	
	var container := left_preview
	if _distant_locs.find(panel) == 0 and _distant_locs.size() > 3:
		container = right_preview
	if _distant_locs.find(panel) == 1 and _distant_locs.size() > 5:
		container = right_preview
	
	var display: LocationDisplay = LOCATION_DISPLAY.instantiate()
	container.add_child(display)
	display.scale = Vector2(2.0, 2.0)
	display.set_location(loc)


func _distant_loc_on_mouse_exited():
	for c in left_preview.get_children():
		c.queue_free()
	for c in right_preview.get_children():
		c.queue_free()


func _setup_distant_locs() -> void:
	for loc in Contexts.game_context.locations:
		if loc == _closed_loc:
			continue
		
		var panel: DistantLocation = DISTANT_LOCATION.instantiate()
		locations_container.add_child(panel)
		panel.mouse_entered.connect(_distant_loc_on_mouse_entered.bind(panel))
		panel.mouse_exited.connect(_distant_loc_on_mouse_exited)
		panel.set_meta("loc", loc)
		_distant_locs.append(panel)
		panel.name_label.text = loc.name


func _setup_local_icons() -> void:
	for pc in _closed_loc.characters:
		var icon := TextureButton.new()
		local_icons.add_child(icon)
		
		icon.texture_normal = pc.data.icon_enabled
		icon.ignore_texture_size = true
		icon.stretch_mode = TextureButton.STRETCH_SCALE
		icon.custom_minimum_size = Vector2(100.0, 100.0)
		icon.set_meta("pc", pc)
		icon.set_script(DraggableIcon)
		GuiUtils.add_mouseover_effect_to_button(icon)
