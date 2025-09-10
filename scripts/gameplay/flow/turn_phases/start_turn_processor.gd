class_name StartTurnProcessor
extends BaseProcessor

const Scourge := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge
const TurnPhase := preload("res://scripts/core/enums/turn_phase.gd").TurnPhase

func on_execute() -> void:
	if !_contexts.turn_context: return
	
	_contexts.turn_context.current_phase = TurnPhase.TURN_START
	
	# Only continue once we finished handling start-of-turn powers.
	if handled_start_of_turn_powers(): return
	
	var pc := _contexts.turn_context.character
	
	#TODO: Allow the user to pick the order of start-of-turn actions
	if pc.active_scourges.has(Scourge.WOUNDED):
		ScourgeRules.handle_wounded_deck_discard(pc)
		
	# Set initial availability of turn actions.
	_contexts.turn_context.can_give = pc.local_characters.size() > 1 and !pc.hand.is_empty()
	_contexts.turn_context.can_move = _contexts.game_context.locations.size() > 1 if _contexts.game_context else false
	_contexts.turn_context.can_freely_explore = pc.location.count > 0 if pc.location else false
	_contexts.turn_context.can_close_location = pc.location.count == 0 if pc.location else false
	
	if false: #_contexts.game_context.scenario_logic.has_available_actions:
		_contexts.turn_context.has_scenario_turn_action = true
		_contexts.turn_context.can_use_scenario_turn_action = true
		
		GameEvents.scenario_power_enabled.emit(true)
		
	if pc.active_scourges.has(Scourge.ENTANGLED):
		_contexts.turn_context.can_move = false
		
	if pc.active_scourges.has(Scourge.EXHAUSTED):
		ScourgeRules.prompt_for_exhausted_removal(pc)
		
	GameEvents.turn_state_changed.emit()
	
	# Set this here - we should stop processing after this.
	_contexts.turn_context.current_phase = TurnPhase.TURN_ACTIONS
	
	
## Finds and handles any start-of-turn powers.
##
## Returns true if a power was found (and another processor was started), false otherwise.
func handled_start_of_turn_powers() -> bool:
	var location_power := _contexts.turn_pc_location.get_start_of_turn_power()
	var character_power := _contexts.turn_context.character.start_of_turn_power
	
	if _contexts.turn_context.performed_location_powers.has(location_power):
		location_power = null
	if _contexts.turn_context.performed_character_powers.has(character_power):
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
