class_name PowersAvailableResolvable
extends BaseResolvable

var _location_power: LocationPower = null
var _character_power: CharacterPower = null
var hide_cancel_button: bool = false


func _init(_pc: PlayerCharacter, location_power: LocationPower, character_power: CharacterPower):
	pc = _pc
	_location_power = location_power
	_character_power = character_power
	
	if _location_power:
		GameEvents.location_power_enabled.emit(_location_power, true)
	if _character_power:
		GameEvents.player_power_enabled.emit(_character_power, true)


func execute():
	if _location_power:
		GameEvents.location_power_enabled.emit(_location_power, false)
	if _character_power:
		GameEvents.player_power_enabled.emit(_character_power, false)


func skip() -> void:
	if _location_power:
		Contexts.turn_context.performed_location_power_ids.append(_location_power.power_id)
	if _character_power:
		Contexts.turn_context.performed_character_power_ids.append(_character_power.power_id)
	
	commit()


func get_ui_state(actions: Array[StagedAction]) -> StagedActionsState:
	var base_state := super(actions)
	if hide_cancel_button:
		base_state.is_cancel_button_visible = false
	return base_state
