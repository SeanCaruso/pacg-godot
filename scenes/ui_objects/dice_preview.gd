# dice_preview.gd
extends HBoxContainer

const D4_SPRITE := preload("res://assets/textures/d4.png")
const D6_SPRITE := preload("res://assets/textures/d6.png")
const D8_SPRITE := preload("res://assets/textures/d8.png")
const D10_SPRITE := preload("res://assets/textures/d10.png")
const D12_SPRITE := preload("res://assets/textures/d12.png")
const D20_SPRITE := preload("res://assets/textures/d20.png")
const DICE_DICT := {
	20: D20_SPRITE, 12: D12_SPRITE, 10: D10_SPRITE, 8: D8_SPRITE, 6: D6_SPRITE, 4: D4_SPRITE
}


func _ready() -> void:
	GameEvents.dice_pool_changed.connect(_on_dice_pool_changed)
	GameEvents.set_status_text.connect(_on_set_status_text)


func _hide_dice() -> void:
	for c in get_children():
		c.visible = false


func _on_dice_pool_changed(pool: DicePool) -> void:
	for c in get_children():
		c.queue_free()
	
	for sides in DICE_DICT:
		for i in range(pool.num_dice(sides)):
			var image := TextureRect.new()
			add_child(image)
			image.texture = DICE_DICT[sides]
			image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL


func _on_set_status_text(_text: String) -> void:
	_hide_dice()
