class_name ShuffleDeckProcessor
extends BaseProcessor

var _deck: Deck


func _init(deck: Deck) -> void:
	_deck = deck


func execute() -> void:
	_deck.shuffle()
