# discards.gd
extends Button

const CardDisplay := preload("res://scripts/presentation/cards/card_display.gd")
const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const CARD_DISPLAY_SCENE := preload("res://scenes/cards/card_display.tscn")

var active_character: PlayerCharacter:
	get:
		return GameServices.contexts.game_context.active_character


func _ready() -> void:
	GameEvents.card_location_changed.connect(_on_card_location_changed)
	GameEvents.player_character_changed.connect(_on_player_character_changed)


func _examine_discards() -> void:
	if active_character.discards.is_empty():
		return
	
	var context := ExamineContext.new()
	context.examine_mode = ExamineContext.Mode.DISCARD
	context.cards = active_character.discards
	context.unknown_count = 0
	context.can_reorder = false
	context.on_close = func(): pass
	
	DialogEvents.examine_event.emit(context)


func _on_card_location_changed(card: CardInstance, prev_loc: CardLocation) -> void:
	if card.owner != active_character:
		return
	
	if not (card.current_location == CardLocation.DISCARDS or prev_loc == CardLocation.DISCARDS):
		return
	
	_update_shown_discard()


func _on_player_character_changed(_pc: PlayerCharacter) -> void:
	_update_shown_discard()


func _update_shown_discard() -> void:
	for c in get_children():
		c.queue_free()
	
	var pc := active_character
	if pc.discards.is_empty():
		return
	
	var display: CardDisplay = CARD_DISPLAY_SCENE.instantiate()
	add_child(display)
	
	display.set_card_instance(pc.discards[-1])
	display.scale = Vector2(0.75, 0.75)
	display.card_input_handler.mouse_filter = Control.MOUSE_FILTER_IGNORE
