class_name ActionStagingManager
extends RefCounted

var _pcs_staged_actions: Dictionary = {} # PlayerCharacter -> Array[StagedAction]
var _original_card_locs: Dictionary = {} # CardInstance -> CardLocation

var _has_move_staged: bool = false
var _has_explore_staged: bool = false

var _cards: CardManager:
	get: return GameServices.cards
var _game_flow: GameFlowManager:
	get: return GameServices.game_flow

var staged_actions: Array[StagedAction]:
	get:
		var actions: Array[StagedAction] = []
		for _staged_actions in _pcs_staged_actions.values():
			actions.append_array(_staged_actions)
		return actions

var staged_cards: Array[CardInstance]:
	get: 
		var result: Array[CardInstance] = []
		result.assign(_original_card_locs.keys())
		return result


func _to_string() -> String:
	return get_script().get_global_name()


func cancel() -> void:
	for card in _original_card_locs:
		_cards.move_card_to(card, _original_card_locs[card])
	
	GameEvents.card_locations_changed.emit(_original_card_locs.keys())
	
	_has_move_staged = false
	_has_explore_staged = false
	
	_original_card_locs.clear()
	_pcs_staged_actions.clear()
	
	# Reset any check context data (like used character powers).
	if Contexts.check_context:
		Contexts.check_context.context_data.clear()
	
	# Additional step for phase-level cancels
	if Contexts.current_resolvable and Contexts.current_resolvable.cancel_aborts_phase:
		_game_flow.abort_phase()
		Contexts.end_resolvable()
	
	GameEvents.set_status_text.emit("")
	update_game_state_preview()
	update_action_buttons()


func commit() -> void:
	GameEvents.set_status_text.emit("")
	
	for action in staged_actions:
		action.commit()
	
	# If we have a resolvable, the fact that we committed means it's been resolved.
	if Contexts.current_resolvable:
		Contexts.end_resolvable()
	
	# If there are no more resolvables, clean up!
	if not Contexts.current_resolvable:
		if Contexts.check_context:
			Contexts.check_context.committed_actions = staged_actions
		
		_has_explore_staged = false
		_has_move_staged = false
		_original_card_locs.clear()
		_pcs_staged_actions.clear()
		_cards.restore_revealed_cards_to_hand()
	
	update_action_buttons()
	
	# We're done committing actions. Tell the GameFlowManager to continue.
	_game_flow.process()


func get_default_ui_state() -> StagedActionsState:
	var state := StagedActionsState.new()
	state.is_cancel_button_visible = not staged_actions.is_empty()
	state.is_commit_button_visible = \
		not staged_actions.is_empty() \
		and not (_has_explore_staged or _has_move_staged)
	state.is_skip_button_visible = false
	state.is_move_enabled = \
		(Contexts.turn_context and Contexts.turn_context.can_move) \
		or _has_move_staged
	state.is_explore_enabled = \
		(Contexts.turn_context and Contexts.turn_context.can_freely_explore) \
		or _has_explore_staged
	
	return state


func get_staged_dice_pool() -> DicePool:
	if not Contexts.check_context: return DicePool.new()
	return Contexts.check_context.dice_pool(staged_actions)


func skip() -> void:
	if Contexts.current_resolvable:
		Contexts.current_resolvable.on_skip()
	commit()


func stage_action(action: StagedAction) -> void:
	var pc_actions = _pcs_staged_actions.get(action.card.owner, [])
	if pc_actions.has(action):
		print("%s staged multiple times!" % action)
		return
	
	if Contexts.current_resolvable \
	and not Contexts.current_resolvable.can_stage_action(action):
		return
	
	_has_move_staged = action is MoveAction
	_has_explore_staged = action is ExploreAction
	if _has_move_staged:
		GameEvents.set_status_text.emit("Move?")
	if _has_explore_staged:
		GameEvents.set_status_text.emit("Explore?")
	
	# If this is the first staged action for this card, store where it originally came from.
	_original_card_locs.get_or_add(action.card, action.card.current_location)
	
	# We need to handle this here so that damage resolvables behave with hand size.
	_cards.move_card_by(action.card, action.action_type)
	
	# Perform all required staging logic.
	pc_actions.append(action)
	_pcs_staged_actions[action.card.owner] = pc_actions
	
	update_game_state_preview()
	update_action_buttons()


func staged_actions_for(pc: PlayerCharacter) -> Array[StagedAction]:
	var actions: Array[StagedAction] = []
	actions.append_array(_pcs_staged_actions.get(pc, []))
	return actions


func update_action_buttons() -> void:
	var pc := Contexts.game_context.active_character
	var pc_actions: Array[StagedAction] = []
	pc_actions.append_array(_pcs_staged_actions.get(pc, []) if pc else [])
	
	var state := Contexts.current_resolvable.get_ui_state(pc_actions) \
		if Contexts.current_resolvable \
		else get_default_ui_state()
	
	if not Contexts.turn_context \
	or pc != Contexts.turn_context.character:
		state.is_move_enabled = false
		state.is_explore_enabled = false
	
	GameEvents.staged_actions_state_changed.emit(state)


func update_game_state_preview() -> void:
	if not Contexts.check_context or Contexts.current_resolvable is not CheckResolvable:
		return
	Contexts.check_context.update_preview_state(staged_actions)
