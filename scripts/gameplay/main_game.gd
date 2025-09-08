# main_game.gd
extends Control

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for i in range(3):
		var longsword_data: CardData = load("res://_game_data/weapons/longsword.tres")
		var longsword = CardInstance.new(longsword_data)
		GameEvents.card_location_changed.emit(longsword, CardLocation.DECK, CardLocation.HAND)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
