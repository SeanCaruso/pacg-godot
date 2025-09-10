class_name BaseResolvable
extends RefCounted

const CardTypes = preload("res://scripts/core/enums/card_type.gd")
const CardType := CardTypes.CardType

var _next_processor: BaseProcessor

var cancel_aborts_phase: bool = false


func _to_string() -> String:
	return get_script().get_global_name()


func initialize():
	pass


func override_next_processor(next_processor: BaseProcessor):
	_next_processor = next_processor


func create_processor() -> BaseProcessor:
	return _next_processor


func get_additional_actions_for_card(_card: CardInstance) -> Array[StagedAction]:
	return []


func can_commit(_actions: Array[StagedAction]) -> bool:
	return true


func resolve():
	pass


func on_skip():
	pass


## The default action button state - Commit/Skip if valid, Cancel if actions are staged
func get_ui_state(actions: Array[StagedAction]) -> StagedActionsState:
	var _can_commit := actions.size() > 0 && can_commit(actions)
	var _can_skip := actions.is_empty() && can_commit(actions)
	
	var action_state = StagedActionsState.new()
	action_state.is_commit_button_visible = _can_commit
	action_state.is_skip_button_visible = _can_skip
	action_state.is_cancel_button_visible = !actions.is_empty() || cancel_aborts_phase
	
	return action_state


# =====================================================================================
# RESOLVABLE-SPECIFIC ACTION STAGING
#
# Note: ActionStagingManager is responsible for the actual actions and cards that have
#       been staged, but is rule-agnostic. Derived resolvables contain the rule-specific
#       logic about which actions *can* be staged during that resolvable.
# =====================================================================================
func can_stage_action(_action: StagedAction) -> bool:
	return true


func can_stage_type(_type: CardType) -> bool:
	return true
