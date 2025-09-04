class_name CardResponse
extends RefCounted

var responding_card: CardInstance
var description: String
var on_accept: Callable

func _init(_responding_card: CardInstance, _description: String, _on_accept: Callable):
	responding_card = _responding_card
	description = _description
	on_accept = _on_accept
