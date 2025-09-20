class_name CampsiteLogic
extends LocationLogicBase

const Scourge := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge


func get_end_of_turn_power(location: Location) -> LocationPower:
	var pc := Contexts.turn_context.character
	
	# At end of turn, you may heal a card (also prompt for Poisoned/Wounded)
	if pc.discards.is_empty() \
	and not pc.active_scourges.any(
		func(s: Scourge):
			return s in [Scourge.POISONED, Scourge.WOUNDED]
	):
		return null
	
	return null
