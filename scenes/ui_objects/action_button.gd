class_name ActionButton
extends TextureButton

@onready var text_label: Label = %Text

var text: String:
	get:
		return text_label.text
	set(value):
		text_label.text = value


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	if disabled: return
	modulate = Color(1.1, 1.1, 1.1)


func _on_mouse_exited() -> void:
	if disabled: return
	modulate = Color.WHITE
