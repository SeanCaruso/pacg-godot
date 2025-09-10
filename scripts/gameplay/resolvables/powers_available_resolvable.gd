class_name PowersAvailableResolvable
extends BaseResolvable

var _location_power: LocationPower = null
var _character_power: CharacterPower = null
var hide_cancel_button: bool = false

var _contexts := GameServices.contexts

func _init(location_power: LocationPower, character_power: CharacterPower):
	_location_power = location_power
	_character_power = character_power
	
	if _location_power:
		GameEvents.location_power_enabled.emit(_location_power, true)
	if _character_power:
		GameEvents.player_power_enabled.emit(_character_power, true)
	
	
func resolve():
	if _location_power:
		GameEvents.location_power_enabled.emit(_location_power, false)
	if _character_power:
		GameEvents.player_power_enabled.emit(_character_power, false)
		
		
func on_skip():
	if _location_power:
		_contexts.turn_context.performed_location_powers.append(_location_power)
	if _character_power:
		_contexts.turn_context.performed_character_powers.append(_character_power)
		
		
func get_ui_state(actions: Array[StagedAction]) -> StagedActionsState:
	var base_state := super(actions)
	if hide_cancel_button:
		base_state.is_cancel_button_visible = false
	return base_state
