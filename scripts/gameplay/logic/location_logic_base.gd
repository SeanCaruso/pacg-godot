class_name LocationLogicBase
extends Resource


# Simple pass-throughs.
func get_start_of_turn_resolvable() -> BaseResolvable: return null
func get_start_of_turn_power(_location: Location) -> LocationPower: return null
func get_end_of_turn_resolvable() -> BaseResolvable: return null
func get_end_of_turn_power(_location: Location) -> LocationPower: return null
func get_when_closed_resolvable() -> BaseResolvable: return null


func get_to_close_resolvable(loc: Location, pc: PlayerCharacter) -> BaseResolvable:
	var resolvable := get_card_to_close_resolvable(loc, pc)
	if not resolvable:
		return null
	
	resolvable.verb = CheckResolvable.CheckVerb.CLOSE
	resolvable.on_success = func():
		var processor := CloseLocationController.new(loc)
		TaskManager.start_task(processor)
	return resolvable


func get_to_guard_resolvable(loc: Location, pc: PlayerCharacter) -> BaseResolvable:
	var resolvable := get_card_to_close_resolvable(loc, pc)
	if not resolvable or not Contexts.encounter_context.guard_locations_resolvable:
		return null
	
	var guard_resolvable := Contexts.encounter_context.guard_locations_resolvable
	
	if resolvable is CheckResolvable:
		resolvable.verb = CheckResolvable.CheckVerb.GUARD
		resolvable.on_success = func():
			guard_resolvable.distant_locs_guarded[loc] = true
		
	return resolvable


## Card logic should override this and provide only the minimal logic required to close.
##
## LocationLogicBase will handle the rest depending on whether it's a check to
## close, or to temporarily guard a location.
func get_card_to_close_resolvable(_loc: Location, _pc: PlayerCharacter) -> BaseResolvable: return null
