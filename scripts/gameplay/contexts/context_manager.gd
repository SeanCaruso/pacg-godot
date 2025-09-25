class_name ContextManager
extends Node

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

var _asm: ActionStagingManager:
	get: return GameServices.asm
var _card_manager: CardManager:
	get: return GameServices.cards

###############################################################################
# THE CONTEXTS
###############################################################################
var game_context: GameContext
var turn_context: TurnContext
var encounter_context: EncounterContext
var check_context: CheckContext
var _resolvable_stack: Array[BaseResolvable]
var current_resolvable: BaseResolvable:
	get:
		return _resolvable_stack.back() if not _resolvable_stack.is_empty() else null

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

## USE ONLY IF YOU KNOW WHAT YOU'RE DOING!!!
##
## NewResolvableProcessor is probably better.
func new_resolvable(resolvable: BaseResolvable) -> void:
	
	for action: Callable in encounter_context.resolvable_modifiers if encounter_context else []:
		action.call(resolvable)
		
	_resolvable_stack.push_back(resolvable)
		
	if current_resolvable is CheckResolvable:
		check_context = CheckContext.new(current_resolvable)
		DialogEvents.check_start_event.emit(check_context)
		
		if encounter_context:
			check_context.explore_effects.append_array(encounter_context.explore_effects)
			encounter_context.explore_effects = encounter_context.explore_effects.filter(
				func(e: BaseExploreEffect):
					return not (e is SkillBonusExploreEffect and e.is_for_one_check)
			)
	# Now that it's set as our current resolvable and we have a CheckContext if needed,
	# do any post-construction setup.
	resolvable.initialize()
	
	# Update the UI.
	GameEvents.turn_state_changed.emit()
	_asm.update_game_state_preview()
	_asm.update_action_buttons()


func end_resolvable() -> void:
	current_resolvable.resolve()
	
	# If it requires a processor, kick off a new phase immediately.
	var processor := current_resolvable.create_processor()
	_resolvable_stack.pop_back()
	
	if processor:
		GameServices.game_flow.start_phase(processor, str(processor))
	
	GameEvents.turn_state_changed.emit()


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
		return not current_resolvable \
		and not encounter_context \
		and GameServices.asm.staged_actions.is_empty()

var is_explore_possible: bool:
	get:
		return turn_context.is_explore_possible if turn_context else false
