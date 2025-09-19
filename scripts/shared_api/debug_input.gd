extends Node

var _pc: PlayerCharacter


func _ready() -> void:
	GameEvents.player_character_changed.connect(_set_pc)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_discard"):
		_discard_card()
	if event.is_action_pressed("debug_draw"):
		_draw_card()
	if event.is_action_pressed("debug_recharge"):
		_recharge_card()
	
	if event.is_pressed() and event is InputEventKey:
		_handle_key_event(event)


func _handle_key_event(event: InputEventKey) -> void:
	if event.ctrl_pressed and event.shift_pressed and Input.is_key_pressed(KEY_E):
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var card_count := event.keycode - KEY_0
			var resolvable := ExamineResolvable.new(
				GameServices.contexts.game_context.active_character.location._deck,
				card_count,
				Input.is_key_pressed(KEY_ALT)
			)
			print("Examining %d" % card_count)
			GameServices.contexts.new_resolvable(resolvable)


func _discard_card() -> void:
	if _pc.hand.size() == 0: return
	_pc.discard(_pc.hand[0])


func _draw_card() -> void:
	if _pc.deck.count == 0: return
	_pc.add_to_hand(_pc.draw_from_deck())


func _recharge_card() -> void:
	if _pc.hand.size() == 0: return
	_pc.recharge(_pc.hand[0])


func _set_pc(pc: PlayerCharacter):
	_pc = pc
