class_name BaseResolvable
extends Task

const CardTypes = preload("res://scripts/core/enums/card_type.gd")
const CardType := CardTypes.CardType

var pc: PlayerCharacter
var _next_processor: BaseProcessor
var _original_card_locs: Dictionary = {} # CardInstance -> CardLocation

var on_success: Callable = func(): pass
var on_failure: Callable = func(): pass

var cancel_aborts_phase: bool = false
var staged_actions: Array[StagedAction] = []

var staged_cards: Array[CardInstance]:
	get:
		var cards: Array[CardInstance] = []
		for action in staged_actions:
			cards.append(action.card)
		return cards


func _to_string() -> String:
	return get_script().get_global_name()


func on_active():
	if Contexts.encounter_context:
		for action: Callable in Contexts.encounter_context.resolvable_modifiers:
			action.call(self)
	
	update_ui()


func create_processor() -> BaseProcessor:
	return _next_processor


func get_additional_actions_for_card(_card: CardInstance) -> Array[StagedAction]:
	return []


func can_commit(_actions: Array[StagedAction]) -> bool:
	return true


## The default action button state - Commit/Skip if valid, Cancel if actions are staged
func get_ui_state(actions: Array[StagedAction]) -> StagedActionsState:
	var move_action_staged := actions.any(
		func(a: StagedAction):
			return a is MoveAction
	)
	var explore_action_staged := actions.any(
		func(a: StagedAction):
			return a is ExploreAction
	)
	
	var state = StagedActionsState.new()
	state.is_commit_button_visible = \
		actions.size() > 0 \
		and can_commit(actions) \
		and not (move_action_staged or explore_action_staged)
	state.is_skip_button_visible = actions.is_empty() and can_commit(actions)
	state.is_cancel_button_visible = not actions.is_empty() || cancel_aborts_phase
	state.is_move_enabled = \
		(Contexts.turn_context and Contexts.turn_context.can_move) \
		or move_action_staged
	state.is_explore_enabled = \
		(Contexts.turn_context and Contexts.turn_context.can_freely_explore) \
		or explore_action_staged
	
	return state


func stage_action(action: StagedAction) -> void:
	if staged_actions.has(action):
		print("%s staged multiple times!" % action)
		return
	
	if not can_stage_action(action):
		return
	
	# If this is the first staged action for this card, store where it originally came from.
	_original_card_locs.get_or_add(action.card, action.card.current_location)
	
	# We need to handle this here so that damage resolvables behave with hand size.
	Cards.move_card_by(action.card, action.action_type)
	
	action.on_stage()
	staged_actions.append(action)
	
	update_ui()


func cancel():
	for card in _original_card_locs:
		Cards.move_card_to(card, _original_card_locs[card])
	
	GameEvents.card_locations_changed.emit(_original_card_locs.keys())
	
	_original_card_locs.clear()
	staged_actions.clear()
	
	# Reset any check context data (like used character powers).
	if Contexts.check_context:
		Contexts.check_context.context_data.clear()
	
	# Additional step for phase-level cancels
	if cancel_aborts_phase:
		TaskManager.resolve_current()
	
	GameEvents.set_status_text.emit("")


func commit():
	GameEvents.set_status_text.emit("")
	
	for action in staged_actions:
		action.commit()
	
	# If a new resolvable was pushed, stop and wait.
	if TaskManager.current_resolvable != self:
		update_ui()
		return
	
	# If we have a resolvable, the fact that we committed means it's been resolved.
	TaskManager.resolve_current()
	
	# If there are no more resolvables, clean up!
	if not TaskManager.current_resolvable:
		_original_card_locs.clear()
		staged_actions.clear()
		Cards.restore_revealed_cards_to_hand()
	
	# We're done committing actions. Tell the TaskManager to continue.
	TaskManager.process()


## If overridden, you MUST call commit.
func skip():
	commit()


func update_ui() -> void:
	var active_pc := Contexts.game_context.active_character
	var pc_actions := staged_actions.filter(
		func(a: StagedAction):
			return a.card.owner == active_pc
	)
	
	var state := get_ui_state(pc_actions)
	
	if not Contexts.turn_context or pc != Contexts.turn_context.character:
		state.is_move_enabled = false
		state.is_explore_enabled = false
	
	GameEvents.staged_actions_state_changed.emit(state)
	GameEvents.turn_state_changed.emit()


# =====================================================================================
# RESOLVABLE-SPECIFIC ACTION STAGING
# =====================================================================================
func can_stage_action(_action: StagedAction) -> bool:
	return true


func can_stage_type(_type: CardType) -> bool:
	return true
