# card_input_handler.gd
class_name CardInputHandler
extends Control

const CardDisplay := preload("res://scripts/presentation/cards/card_display.gd")

signal card_clicked(card_display: Control)
signal card_drag_started(card: CardInstance)
signal card_drag_updated(card: CardInstance, delta: Vector2)
signal card_drag_ended(card: CardInstance, global_pos: Vector2)

const DRAG_THRESHOLD := 10.0

var card_instance: CardInstance
var card_display: CardDisplay
var is_dragging: bool = false
var drag_start_pos: Vector2


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: _on_mouse_down(event.global_position)
			else: _on_mouse_up()
	if event is InputEventMouseMotion:
		_on_mouse_motion(event.global_position)


func setup_input(card: CardInstance, display: CardDisplay) -> void:
	card_instance = card
	card_display = display
	mouse_filter = Control.MOUSE_FILTER_PASS


func _on_mouse_down(pos: Vector2) -> void:
	drag_start_pos = pos


func _on_mouse_up() -> void:
	if card_display and card_display.is_previewed: return
	
	if is_dragging:
		card_drag_ended.emit(card_instance, global_position + get_global_mouse_position())
		is_dragging = false
	else:
		card_clicked.emit(card_display)


func _on_mouse_motion(pos: Vector2) -> void:
	if not Input.is_action_pressed("click"): return
	if card_display and card_display.is_previewed: return
	
	if is_dragging:
		card_drag_updated.emit(card_instance, pos - drag_start_pos)
	elif drag_start_pos and drag_start_pos.distance_to(pos) > DRAG_THRESHOLD:
		is_dragging = true
		card_drag_started.emit(card_instance)
