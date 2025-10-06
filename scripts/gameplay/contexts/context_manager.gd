class_name ContextManager
extends Node

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

###############################################################################
# THE CONTEXTS
###############################################################################
var game_context: GameContext
var turn_context: TurnContext
var encounter_context: EncounterContext
var check_context: CheckContext
#var _resolvable_stack: Array[BaseResolvable]
#var current_resolvable: BaseResolvable:
	#get:
		#return _resolvable_stack.back() if not _resolvable_stack.is_empty() else null

###############################################################################
# STARTING/ENDING CONTEXTS
###############################################################################
func new_game(_game_context: GameContext): game_context = _game_context

func new_turn(context: TurnContext):
	turn_context = context
	game_context.set_active_character(context.character)

func end_turn():
	if check_context:
		print("[%s] Ending turn with a CheckContext still active!" % self)
	if encounter_context:
		print("[%s] Ending turn with an EncounterContext still active!" % self)
	
	turn_context = null

func new_encounter(context: EncounterContext):
	encounter_context = context
	if not turn_context: return
	
	encounter_context.explore_effects.append_array(turn_context.explore_effects)
	turn_context.explore_effects.clear()

## This only sets the context to null. Event sending must be handled by the caller.
func end_encounter(): encounter_context = null


func end_check() -> void:
	check_context = null
	GameEvents.turn_state_changed.emit()


###############################################################################
# CONVENIENCE PROPERTIES/FUNCTIONS
###############################################################################\

var encounter_pc_location: Location:
	get: return encounter_context.character.location if encounter_context else null

var are_cards_playable: bool:
	get:
		return TaskManager.current_resolvable is FreePlayResolvable \
		and not encounter_context \
		and TaskManager.current_resolvable.staged_actions.is_empty()

var is_explore_possible: bool:
	get:
		return turn_context.is_explore_possible if turn_context else false
