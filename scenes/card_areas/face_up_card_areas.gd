extends Node

const CardDisplay := preload("res://scenes/cards/card_display.tscn")
const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

const CARD_SCALE = Vector2(0.6, 0.6)

var _active_pc: PlayerCharacter
var _card_instances_to_displays: Dictionary = {} # CardInstance -> Control (card wrapper)

@onready var displayed_area: HBoxContainer = %DisplayedArea
@onready var revealed_area: HBoxContainer = %RevealedArea
@onready var recovery_area: HBoxContainer = %RecoveryArea


func _ready() -> void:
	GameEvents.player_character_changed.connect(_on_active_player_changed)
	GameEvents.card_location_changed.connect(_on_card_location_changed)


func _add_card_to_container(card: CardInstance, container: HBoxContainer) -> void:
	var card_wrapper := Control.new()
	container.add_child(card_wrapper)
	var new_display := CardDisplay.instantiate()
	
	card_wrapper.add_child(new_display)
	new_display.set_card_instance(card)
	card_wrapper.custom_minimum_size = new_display.size * CARD_SCALE
	new_display.scale = CARD_SCALE
	_card_instances_to_displays[card] = card_wrapper


func _on_active_player_changed(pc: PlayerCharacter) -> void:
	_active_pc = pc
	
	# Remove all current displays
	for card_wrapper in _card_instances_to_displays.values():
		card_wrapper.queue_free()
	_card_instances_to_displays.clear()
	
	# Map each face-up area to the list of cards.
	var face_up_cards := {
		displayed_area: pc.displayed_cards,
		recovery_area: pc.recovery_cards,
		revealed_area: pc.revealed_cards
	}
	
	# Populate each face-up area.
	for container in face_up_cards:
		var card_list = face_up_cards[container]
		for card in card_list:
			_add_card_to_container(card, container)


func _on_card_location_changed(card: CardInstance, _prev_loc: CardLocation) -> void:
	if card.owner != _active_pc: return
	
	# If we're moving from a face-up location, remove the existing display.
	if _card_instances_to_displays.has(card):
		var card_wrapper = _card_instances_to_displays[card]
		card_wrapper.queue_free()
		_card_instances_to_displays.erase(card)
	
	# If we're moving to a face-up location, create a new display.
	var target_parent: Node = null
	match card.current_location:
		CardLocation.DISPLAYED: target_parent = displayed_area
		CardLocation.RECOVERY: target_parent = recovery_area
		CardLocation.REVEALED: target_parent = revealed_area
	
	if not target_parent: return
	
	_add_card_to_container(card, target_parent)
