# status_text.gd
extends Label


func _ready() -> void:
	GameEvents.set_status_text.connect(_on_set_status_text)


func _on_set_status_text(_text: String) -> void:
	text = _text
