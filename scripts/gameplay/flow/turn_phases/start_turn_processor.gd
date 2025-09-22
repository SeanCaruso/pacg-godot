class_name StartTurnProcessor
extends BaseProcessor

const Scourge := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge
const TurnPhase := preload("res://scripts/core/enums/turn_phase.gd").TurnPhase

func on_execute() -> void:
	if !Contexts.turn_context: return
	
	Contexts.turn_context.current_phase = TurnPhase.TURN_START
	
	# Only continue once we finished handling start-of-turn powers.
	if handled_start_of_turn_powers(): return
	
	var pc := Contexts.turn_context.character
	
	#TODO: Allow the user to pick the order of start-of-turn actions
	if pc.active_scourges.has(Scourge.WOUNDED):
		ScourgeRules.handle_wounded_deck_discard(pc)
		
	# Set initial availability of turn actions.
	Contexts.turn_context.can_give = pc.local_characters.size() > 1 and !pc.hand.is_empty()
	Contexts.turn_context.can_move = Contexts.game_context.locations.size() > 1 if Contexts.game_context else false
	Contexts.turn_context.can_freely_explore = pc.location.count > 0 if pc.location else false
	Contexts.turn_context.can_close_location = pc.location.count == 0 if pc.location else false
	
	if Contexts.game_context.scenario_logic \
	and Contexts.game_context.scenario_logic.has_available_actions():
		Contexts.turn_context.has_scenario_turn_action = true
		Contexts.turn_context.can_use_scenario_turn_action = true
		
		GameEvents.scenario_power_enabled.emit(true)
		
	if pc.active_scourges.has(Scourge.ENTANGLED):
		Contexts.turn_context.can_move = false
		
	if pc.active_scourges.has(Scourge.EXHAUSTED):
		ScourgeRules.prompt_for_exhausted_removal(pc)
		
	GameEvents.turn_state_changed.emit()
	
	# Set this here - we should stop processing after this.
	Contexts.turn_context.current_phase = TurnPhase.TURN_ACTIONS
	
	
## Finds and handles any start-of-turn powers.
##
## Returns true if a power was found (and another processor was started), false otherwise.
func handled_start_of_turn_powers() -> bool:
	if not Contexts.turn_context:
		return false
	
	var location_power := Contexts.turn_context.character.location.start_of_turn_power
	var character_power := Contexts.turn_context.character.start_of_turn_power
	
	if location_power and Contexts.turn_context.performed_location_power_ids.has(location_power.power_id):
		location_power = null
	if character_power and Contexts.turn_context.performed_character_power_ids.has(character_power.power_id):
		character_power = null
	
	if !location_power and !character_power:
		return false
	
	# We'll need to process this again in case there are more valid powers.
	_game_flow.interrupt(self)
	
	GameEvents.set_status_text.emit("Use Start-of-Turn power?")
	
	var resolvable := PowersAvailableResolvable.new(location_power, character_power)
	resolvable.hide_cancel_button = true
	var processor := NewResolvableProcessor.new(resolvable)
	_game_flow.start_phase(processor, "Start-of-Turn")
	
	return true
