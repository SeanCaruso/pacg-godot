class_name EndOfTurnProcessor
extends BaseProcessor

func execute() -> void:
	Contexts.turn_context.current_phase = TurnContext.TurnPhase.END_OF_TURN_EFFECTS
	
	var location_power: LocationPower = Contexts.turn_context.character.location.end_of_turn_power
	var character_power: CharacterPower = null if Contexts.turn_context.force_end_turn \
		else Contexts.turn_context.character.end_of_turn_power
		
	if character_power and Contexts.turn_context.performed_character_power_ids.has(character_power.power_id):
		character_power = null
	
	if location_power and Contexts.turn_context.performed_location_power_ids.has(location_power.power_id):
		location_power = null
	
	if !character_power and !location_power:
		return
	
	# We'll need to process this again in case there are multiple valid powers.
	TaskManager.push(self)
	
	GameEvents.set_status_text.emit("Use End-of-Turn Power?")
	
	var resolvable := PowersAvailableResolvable.new(Contexts.turn_context.character, location_power, character_power)
	TaskManager.push(resolvable)
