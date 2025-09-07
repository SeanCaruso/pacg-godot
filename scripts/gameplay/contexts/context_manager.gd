class_name ContextManager
extends RefCounted

const CardLocation = preload("res://scripts/core/enums/card_location.gd").CardLocation

# Dependency injection
# var _asm: ActionStagingManager
var _card_manager: CardManager
var _game_services: GameServices

func initialize(game_services: GameServices):
	#_asm = game_services.asm
	_card_manager = game_services.cards
	_game_services = game_services

###############################################################################
# THE CONTEXTS
###############################################################################
var game_context: GameContext
var turn_context: TurnContext
var encounter_context: EncounterContext
var check_context: CheckContext
var current_resolvable: BaseResolvable

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
func new_resolvable(resolvable: BaseResolvable):
	if current_resolvable:
		print("[%s] Created resolvable %s is overwriting %s!", [self, resolvable, current_resolvable])
	
	for action: Callable in encounter_context.resolvable_modifiers if encounter_context else []:
		action.call(resolvable)
	
	# If this is a damage resolvable, check to see if we have any responses for it.
	# If so, we'll need to handle those responses first.
	if resolvable is DamageResolvable:
		var args = DiscardEventArgs.new(
			resolvable.character,
			[],
			CardLocation.HAND,
			resolvable
		)
		_card_manager.trigger_before_discard(args)
		
		if args.has_responses:
			pass
		
		current_resolvable = resolvable
		
		if current_resolvable is CheckResolvable:
			check_context = CheckContext.new(current_resolvable)

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
