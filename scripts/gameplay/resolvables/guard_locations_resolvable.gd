class_name GuardLocationsResolvable
extends BaseResolvable

var acted_pcs: Array[PlayerCharacter] = []
var distant_locs_guarded: Dictionary = {} # Location -> bool
var villain_loc: Location


func _init() -> void:
	if not Contexts.encounter_context or not Contexts.game_context:
		push_error("Attempted to guard locations with a null game or encounter context.")
		return
	
	villain_loc = Contexts.encounter_pc_location
	for loc in Contexts.game_context.locations.filter(func(l): return l != villain_loc):
		distant_locs_guarded[loc] = false


## The Guard GUI handles its own button.
func get_ui_state(_actions: Array[StagedAction]) -> StagedActionsState:
	return StagedActionsState.new()


func on_active() -> void:
	DialogEvents.emit_guard_locations_started(self)
