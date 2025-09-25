class_name EvadeResolvable
extends BaseResolvable

var _on_evade_callback: Callable

func _init(callback: Callable):
	_on_evade_callback = callback


func on_skip() -> void:
	_on_evade_callback = func(): pass


func resolve() -> void:
	_on_evade_callback.call()


func get_ui_state(actions: Array[StagedAction]) -> StagedActionsState:
	var state = StagedActionsState.new()
	state.is_commit_button_visible = !actions.is_empty()
	state.is_skip_button_visible = actions.is_empty()
	state.is_cancel_button_visible = !actions.is_empty() or cancel_aborts_phase
	return state
