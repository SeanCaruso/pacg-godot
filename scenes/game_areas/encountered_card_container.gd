# encountered_card_container.gd
extends Control

const CardDisplay := preload("res://scripts/presentation/cards/card_display.gd")
const CardDisplayScene := preload("res://scenes/cards/card_display.tscn")


func _ready() -> void:
	GameEvents.encounter_started.connect(_on_encounter_started)
	GameEvents.encounter_ended.connect(_on_encounter_ended)


func _on_encounter_ended() -> void:
	for child in get_children():
		child.queue_free()


func _on_encounter_started(card: CardInstance) -> void:
	var card_display: CardDisplay = CardDisplayScene.instantiate()
	add_child(card_display)
	card_display.set_card_instance(card)
