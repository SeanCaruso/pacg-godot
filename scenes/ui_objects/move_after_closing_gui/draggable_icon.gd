# draggable_icon.gd
extends TextureButton

var _is_dragged := false


func _get_drag_data(_at_position: Vector2) -> Variant:
	_is_dragged = true
	
	var drag_texture := TextureRect.new()
	drag_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	drag_texture.texture = texture_normal
	drag_texture.custom_minimum_size = Vector2(100.0, 100.0)
	
	var container := Control.new()
	container.add_child(drag_texture)
	drag_texture.position = -0.5 * drag_texture.custom_minimum_size
	set_drag_preview(container)
	
	return {"button": self}


func _notification(what: int) -> void:
	if not _is_dragged: return
	
	match what:
		NOTIFICATION_DRAG_BEGIN:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			self_modulate = Color.TRANSPARENT
		NOTIFICATION_DRAG_END:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			self_modulate = Color.WHITE
			_is_dragged = false
