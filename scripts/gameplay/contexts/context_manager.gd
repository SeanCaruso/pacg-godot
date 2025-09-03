class_name ContextManager
extends RefCounted

# Dependency injection
# var _asm: ActionStagingManager
var _card_manager: CardManager
var _game_services: GameServices

func _init(game_services: GameServices):
	#_asm = game_services.asm
	_card_manager = game_services.card_manager
	_game_services = game_services

###############################################################################
# THE CONTEXTS
###############################################################################
var game_context: GameContext
var turn_context: TurnContext
var encounter_context: EncounterContext
var check_context: CheckContext
#var current_resolvable: IResolvable

###############################################################################
# STARTING/ENDING CONTEXTS
###############################################################################
func new_game(_game_context: GameContext): game_context = _game_context

func new_turn(context: TurnContext):
	turn_context = context
	game_context.active_character = context.character

func end_turn():
	if check_context:
		print("[%s] Ending turn with a CheckContext still active!" % self)
	if encounter_context:
		print("[%s] Ending turn with an EncounterContext still active!" % self)
	
	turn_context = null

func new_encounter(context: EncounterContext):
	encounter_context = context
	
	#encounter_context.explore_effects.append_array(turn_context.explore_effects)
	#turn_context.explore_effects.clear()

## This only sets the context to null. Event sending must be handled by the caller.
func end_encounter(): encounter_context = null

## USE ONLY IF YOU KNOW WHAT YOU'RE DOING!!!
##
## NewResolvableProcessor is probably better.
# func new_resolvable()

# func end_resolvable()

func end_check():
	# raise end check event
	check_context = null
	# raise turn state changed

###############################################################################
# CONVENIENCE PROPERTIES/FUNCTIONS
###############################################################################\
var turn_pc_location: Location:
	get: return turn_context.character.location if turn_context else null

var encounter_pc_location: Location:
	get: return encounter_context.character.location if encounter_context else null
