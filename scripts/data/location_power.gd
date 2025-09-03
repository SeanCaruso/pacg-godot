class_name LocationPower
extends Resource

enum Type { AT_LOCATION, TO_CLOSE, WHEN_CLOSED }
	
@export var type: Type
@export var is_activated: bool
@export var sprite_enabled: Texture2D
@export var sprite_disabled: Texture2D
@export_multiline var text: String

var on_activate: Callable
