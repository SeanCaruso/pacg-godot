# PlayerHand.gd
extends Control

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

@onready var hand_layout: HBoxContainer = %HandLayout

var current_player: PlayerCharacter
var card_to_display_map: Dictionary = {} # CardInstance -> CardDisplay

const MAX_HAND_WIDTH := 1045.0
const CARD_DISPLAY_SCENE := preload("res://scenes/cards/card_display.tscn")


func _ready():
	# Connect to signals (Godot's equivalent of your event subscriptions)
	GameEvents.card_location_changed.connect(_on_card_location_changed)
	GameEvents.player_character_changed.connect(_on_player_changed)


func _on_player_changed(player: PlayerCharacter):
	current_player = player
	_clear_all_cards()
	_populate_initial_hand()


func _on_card_location_changed(card: CardInstance, old_location: CardLocation, new_location: CardLocation) -> void:
	if card.owner != current_player:
		return
	
	# Card entering hand
	if new_location == CardLocation.HAND:
		_create_card_display(card)
	# Card leaving hand  
	elif old_location == CardLocation.HAND and card in card_to_display_map:
		_remove_card_display(card)
	
	_adjust_hand_spacing()


func _create_card_display(card: CardInstance) -> void:
	var card_display := CARD_DISPLAY_SCENE.instantiate()
	hand_layout.add_child(card_display)
	card_display.display_card(card)
	
	card_to_display_map[card] = card_display


func _remove_card_display(card: CardInstance) -> void:
	if card in card_to_display_map:
		var display = card_to_display_map[card]
		display.queue_free()
		card_to_display_map.erase(card)

func _adjust_hand_spacing() -> void:
	var card_count := card_to_display_map.size()
	if card_count <= 4:
		hand_layout.add_theme_constant_override("separation", 15)
		return
	
	# Calculate spacing to fit within max width
	var card_width := 250.0
	var total_width := card_count * card_width
	var excess_width := total_width - MAX_HAND_WIDTH
	var new_spacing := -excess_width / (card_count - 1)
	hand_layout.add_theme_constant_override("separation", int(new_spacing))

func _clear_all_cards():
	for display in card_to_display_map.values():
		display.queue_free()
	card_to_display_map.clear()

func _populate_initial_hand():
	for card in current_player.hand:
		_create_card_display(card)
	_adjust_hand_spacing()
