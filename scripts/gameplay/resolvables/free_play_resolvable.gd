class_name FreePlayResolvable
extends BaseResolvable


func can_stage_action(_action: StagedAction) -> bool:
	return Contexts.are_cards_playable


func get_ui_state(actions: Array[StagedAction]) -> StagedActionsState:
	var state := super(actions)
	state.is_skip_button_visible = false
	return state
