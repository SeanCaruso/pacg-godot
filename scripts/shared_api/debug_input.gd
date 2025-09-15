extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_discard"):
		_discard_card()
	if event.is_action_pressed("debug_draw"):
		_draw_card()
	if event.is_action_pressed("debug_recharge"):
		_recharge_card()


func _discard_card() -> void:
	if GameServices.contexts.turn_context \
	and GameServices.contexts.turn_context.character:
		var pc := GameServices.contexts.turn_context.character
		if pc.hand.size() == 0: return
		pc.discard(pc.hand[0])


func _draw_card() -> void:
	if GameServices.contexts.turn_context \
	and GameServices.contexts.turn_context.character:
		var pc :=  GameServices.contexts.turn_context.character
		if pc.deck.count == 0: return
		pc.add_to_hand(pc.draw_from_deck())


func _recharge_card() -> void:
	if GameServices.contexts.turn_context \
	and GameServices.contexts.turn_context.character:
		var pc := GameServices.contexts.turn_context.character
		if pc.hand.size() == 0: return
		pc.recharge(pc.hand[0])
