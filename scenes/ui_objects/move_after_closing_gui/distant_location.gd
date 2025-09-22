# distant_location.gd
extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var character_icons: HFlowContainer = %CharacterIcons


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	self_modulate = Color(1.2, 1.2, 1.2)
	return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if not data.has("button"):
		return
	
	var button: TextureButton = data["button"]
	button.reparent(character_icons, false)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_END, NOTIFICATION_MOUSE_EXIT:
			self_modulate = Color.WHITE
