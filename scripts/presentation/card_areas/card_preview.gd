# card_preview.gd
extends Control

const ActionButton := preload("res://scenes/ui_objects/action_button.tscn")
const CardDisplay := preload("res://scripts/presentation/cards/card_display.gd")

@onready var background_button: Control = %BackgroundButton
@onready var card_container: Control = %CardContainer
@onready var action_buttons_container: VBoxContainer = %ActionButtonsContainer

var _current_card: Control = null
var _original_parent: Control = null
var _placeholder: Control = null

var Contexts: ContextManager:
	get: return Contexts


func _ready() -> void:
	hide()
	background_button.gui_input.connect(_on_background_clicked)
	
	for card in get_tree().get_nodes_in_group("cards"):
		if card.has_signal("card_clicked") and not card.card_clicked.is_connected(_on_card_clicked):
			card.card_clicked.connect(_on_card_clicked)
	
	# Check for previewable cards whenever a node is added.
	get_tree().node_added.connect(_on_node_added)


func end_preview() -> void:
	hide()
	
	# Clean up placeholder.
	if _placeholder:
		_placeholder.queue_free()
		_placeholder = null
		
	_original_parent = null
	
	for button in action_buttons_container.get_children():
		button.queue_free()
	
	if not _current_card:
		return
	
	_current_card.is_previewed = false
	_current_card = null


func generate_action_buttons() -> void:
	if not _current_card or _current_card is not CardDisplay:
		return
	var card := (_current_card as CardDisplay).card_instance
	
	var actions: Array[StagedAction] = []
	# If there's an encountered card, grab any additional actions that card might add to the previewed card.
	if Contexts.encounter_context and Contexts.encounter_context.card:
		actions.append_array(Contexts.encounter_context.card.get_additional_actions_for_card(card))
	
	# If there's a resolvable, grab any additional actions from that.
	if Contexts.current_resolvable:
		actions.append_array(Contexts.current_resolvable.get_additional_actions_for_card(card))
	
	actions.append_array(card.get_available_actions())
	
	for action in actions:
		var button := ActionButton.instantiate()
		action_buttons_container.add_child(button)
		button.text = action.label.to_pascal_case()
		button.pressed.connect(
			func():
				GameServices.asm.stage_action(action)
				_current_card.queue_free()
				end_preview()
		)


func start_preview(card_display: Control) -> void:
	if _current_card:
		return
	
	_current_card = card_display
	
	# Create invisible placeholder.
	_placeholder = Control.new()
	_placeholder.custom_minimum_size = card_display.size
	_placeholder.scale = card_display.scale
	
	# Insert at same position.
	var index := card_display.get_index()
	_original_parent = card_display.get_parent()
	_original_parent.add_child(_placeholder)
	_original_parent.move_child(_placeholder, index)
	
	# Move card to preview container.
	card_display.reparent(card_container)
	card_display.is_previewed = true
	
	# Calculate target transform.
	var target_pos := Vector2.ZERO
	var target_scale := Vector2(2.0, 2.0)
	
	show()
	
	# Animate to preview position.
	var tween := create_tween()
	tween.parallel().tween_property(card_display, "position", target_pos, 0.1)
	tween.parallel().tween_property(card_display, "scale", target_scale, 0.1)
	
	generate_action_buttons()


func _on_background_clicked(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_return_card_to_origin()


func _on_card_clicked(card_display: Control):
	start_preview(card_display)


func _on_node_added(node: Node) -> void:
	if node.is_in_group("cards"):
		if node.has_signal("card_clicked") and not node.card_clicked.is_connected(_on_card_clicked):
			node.card_clicked.connect(_on_card_clicked)


func _return_card_to_origin() -> void:
	if not _current_card or not _placeholder: return
	
	# Animate back to original size.
	var original_scale := _placeholder.scale
	var target_pos := _placeholder.global_position - card_container.global_position
	
	var tween := create_tween()
	tween.parallel().tween_property(_current_card, "position", target_pos, 0.1)
	tween.parallel().tween_property(_current_card, "scale", original_scale, 0.1)
	
	# When animation completes, restore hierarchy.
	await tween.finished
	
	# Move card back to original parent.
	var index := _placeholder.get_index()
	_current_card.reparent(_original_parent)
	_original_parent.move_child(_current_card, index)
	
	end_preview()
