# guardable_location.gd
extends PanelContainer

signal pc_clicked

const LocationDisplay = preload("uid://cub6h47pj0t5o")

const ICON_SIZE := Vector2(100.0, 100.0)

var _resolvable: GuardLocationsResolvable

@onready var location_display: LocationDisplay = %LocationDisplay
@onready var guarded_texture: TextureRect = %GuardedTexture
@onready var character_icons: HFlowContainer = %CharacterIcons


func initialize(loc: Location, resolvable: GuardLocationsResolvable) -> void:
	_resolvable = resolvable
	
	location_display.set_location(loc)
	guarded_texture.visible = resolvable.distant_locs_guarded.get_or_add(loc, false)
	
	for pc in loc.characters:
		var icon := TextureButton.new()
		character_icons.add_child(icon)
		
		icon.texture_normal = pc.data.icon_enabled
		icon.texture_disabled = pc.data.icon_disabled
		icon.disabled = pc in resolvable.acted_pcs
		icon.ignore_texture_size = true
		icon.stretch_mode = TextureButton.STRETCH_SCALE
		icon.custom_minimum_size = ICON_SIZE
		icon.pressed.connect(_on_pc_icon_pressed.bind(pc))
		GuiUtils.add_mouseover_effect_to_button(icon)


func _on_pc_icon_pressed(pc: PlayerCharacter) -> void:
	pc_clicked.emit()
	GameEvents.emit_active_character_changed(pc)
	var resolvable_ref = _resolvable
	var close_choice_resolvable = PlayerChoiceResolvable.new("Guard %s?" % pc.location, [
		ChoiceOption.new("Guard", func():
			resolvable_ref.acted_pcs.append(pc)
			var guard_resolvable: BaseResolvable = pc.location.get_to_guard_resolvable(pc)
			TaskManager.push(guard_resolvable)
			),
		ChoiceOption.new("Cancel", func(): pass)
	])
	TaskManager.push(close_choice_resolvable)
