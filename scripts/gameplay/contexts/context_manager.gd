class_name ContextManager
extends RefCounted

const CardLocation = preload("res://scripts/core/enums/card_location.gd").CardLocation

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
	
	encounter_context.explore_effects.append_array(turn_context.explore_effects)
	turn_context.explore_effects.clear()

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
		var args := DiscardEventArgs.new(
			resolvable.character,
			[],
			CardLocation.HAND,
			resolvable
		)
		_card_manager.trigger_before_discard(args)
		
		if args.has_responses:
			var options: Array[ChoiceOption] = []
			for response: CardResponse in args.card_responses:
				options.append(ChoiceOption.new(response.description, response.on_accept))
			options.append(ChoiceOption.new("Skip", func(): pass))
			
			var choice_resolvable = PlayerChoiceResolvable.new("Use Power?", options)
			var damage_processor = NewResolvableProcessor.new(resolvable)
			choice_resolvable.override_next_processor(damage_processor)
			
			var choice_processor = NewResolvableProcessor.new(choice_resolvable)
			GameServices.game_flow.start_phase(choice_processor, "Power Options")
			return
		
	current_resolvable = resolvable
		
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


func end_resolvable():
	current_resolvable.resolve()
	current_resolvable = null
	GameEvents.turn_state_changed.emit()


func end_check():
	DialogEvents.check_end_event.emit()
	check_context = null
	GameEvents.turn_state_changed.emit()


###############################################################################
# CONVENIENCE PROPERTIES/FUNCTIONS
###############################################################################\
var turn_pc_location: Location:
	get: return turn_context.character.location if turn_context else null

var encounter_pc_location: Location:
	get: return encounter_context.character.location if encounter_context else null

var are_cards_playable: bool:
	get:
		return not current_resolvable \
		and not encounter_context \
		and GameServices.asm.staged_actions.is_empty()

var is_explore_possible: bool:
	get:
		if not turn_pc_location: return false
		return are_cards_playable and turn_pc_location.count > 0
