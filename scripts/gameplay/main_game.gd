# main_game.gd
extends Control

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

@onready var player_hand: Control = $PlayerHand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var longsword_data: CardData = load("res://_game_data/weapons/longsword.tres")
	var longsword = CardInstance.new(longsword_data)
	print("Sending event!")
	GameEvents.card_location_changed.emit(longsword, CardLocation.DECK, CardLocation.HAND)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
