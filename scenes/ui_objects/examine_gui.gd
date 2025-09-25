# examine_gui.gd
extends Control

const CARD_BACK := preload("res://assets/textures/card_back.png")
const CardDisplay := preload("res://scripts/presentation/cards/card_display.gd")
const CARD_DISPLAY_SCENE := preload("res://scenes/cards/card_display.tscn")

var _context: ExamineContext
var _child_idx_to_array_idx: Dictionary = {} # int -> int

@onready var default_deck_container: HBoxContainer = %DefaultDeckContainer
@onready var card_backs_container: HBoxContainer = %CardBacksContainer
@onready var cards_container: HBoxContainer = %CardsContainer
@onready var continue_button: TextureButton = %ContinueButton
@onready var scrollable_deck_container: ScrollContainer = %ScrollableDeckContainer
@onready var scroll_cards_container: HBoxContainer = %ScrollCardsContainer


func start_examine(context: ExamineContext) -> void:
	_context = context
	GuiUtils.add_mouseover_effect_to_button(continue_button)
	
	match context.examine_mode:
		ExamineContext.Mode.DECK:
			_examine_deck(context)
		ExamineContext.Mode.SCROLL:
			_examine_scroll(context)


func _end_examine() -> void:
	if _context and _context.on_close:
		_context.on_close.call()
	
	queue_free()
	
	if _context.examine_mode == ExamineContext.Mode.DECK:
		GameServices.asm.commit()


func _examine_deck(context: ExamineContext) -> void:
	default_deck_container.visible = true
	scrollable_deck_container.visible = false
	
	for i in range(context.unknown_count):
		var img = TextureRect.new()
		card_backs_container.add_child(img)
		img.texture = CARD_BACK
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		img.size = Vector2(250.0, 350.0)
	
	# Iterate in reverse order so that the top card is on the right.
	for i in range(context.cards.size() - 1, -1, -1):
		var card: CardInstance = context.cards[i]
		var display: CardDisplay = CARD_DISPLAY_SCENE.instantiate()
		cards_container.add_child(display)
		display.set_card_instance(card)
		display.is_draggable = context.can_reorder
		display.drag_ended.connect(_on_drag_ended)
		
		_child_idx_to_array_idx[display.get_index()] = i


func _examine_scroll(context: ExamineContext) -> void:
	scrollable_deck_container.visible = true
	default_deck_container.visible = false
	
	for card in context.cards:
		var display: CardDisplay = CARD_DISPLAY_SCENE.instantiate()
		scroll_cards_container.add_child(display)
		display.set_card_instance(card)
		if card.is_villain:
			display.scale = Vector2(1.2, 1.2)


func _on_drag_ended(card: CardDisplay) -> void:
	var drop_card: CardDisplay
	var mouse_pos := get_global_mouse_position()
	for c in cards_container.get_children():
		if c == card: continue
		
		if (c as CardDisplay).get_global_rect().has_point(mouse_pos):
			drop_card = c
			break
	
	if not drop_card:
		return
	
	var dragged_child_idx := card.get_index()
	var dragged_array_idx: int = _child_idx_to_array_idx[dragged_child_idx]
	var dropped_child_idx := drop_card.get_index()
	var dropped_array_idx: int = _child_idx_to_array_idx[dropped_child_idx]
	
	_context.cards[dragged_array_idx] = drop_card.card_instance
	_context.cards[dropped_array_idx] = card.card_instance
	
	cards_container.move_child(card, dropped_child_idx)
	cards_container.move_child(drop_card, dragged_child_idx)
