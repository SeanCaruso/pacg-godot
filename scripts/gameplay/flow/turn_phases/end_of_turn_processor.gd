class_name EndOfTurnProcessor
extends BaseProcessor

func on_execute() -> void:
	var location_power := _contexts.turn_pc_location.get_end_of_turn_power()
	var character_power: CharacterPower = null
	
	if !_contexts.turn_context.force_end_turn:
		character_power = _contexts.turn_context.character.end_of_turn_power
		
	if _contexts.turn_context.performed_character_powers.has(character_power):
		character_power = null
	
	if _contexts.turn_context.performed_location_powers.has(location_power):
		location_power = null
	
	if !character_power and !location_power:
		return
	
	# We'll need to process this again in case there are multiple valid powers.
	_game_flow.interrupt(self)
	
	GameEvents.set_status_text.emit("Use End-of-Turn Power?")
	
	var resolvable := PowersAvailableResolvable.new(location_power, character_power, _game_services)
	var processor := NewResolvableProcessor.new(resolvable, _game_services)
	_game_flow.start_phase(processor, "End-of-Turn")
