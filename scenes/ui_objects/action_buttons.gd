# action_buttons.gd
extends Control

@onready var cancel_button: TextureButton = %CancelButton
@onready var commit_button: TextureButton = %CommitButton
@onready var skip_button: TextureButton = %SkipButton


func _ready() -> void:
	GuiUtils.add_mouseover_effect_to_button(cancel_button)
	GuiUtils.add_mouseover_effect_to_button(commit_button)
	GuiUtils.add_mouseover_effect_to_button(skip_button)
	
	cancel_button.pressed.connect(_on_cancel_pressed)
	commit_button.pressed.connect(_on_commit_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	
	GameEvents.staged_actions_state_changed.connect(_update_staged_action_buttons)


func _on_cancel_pressed() -> void:
	if not TaskManager.current_resolvable:
		push_error("Atttempted to cancel without a resolvable!")
		return
	TaskManager.current_resolvable.cancel()


func _on_commit_pressed() -> void:
	if not TaskManager.current_resolvable:
		push_error("Atttempted to commit without a resolvable!")
		return
	TaskManager.current_resolvable.commit()


func _on_skip_pressed() -> void:
	if not TaskManager.current_resolvable:
		push_error("Atttempted to skip without a resolvable!")
		return
	TaskManager.current_resolvable.skip()


func _update_staged_action_buttons(state: StagedActionsState) -> void:
	cancel_button.visible = state.is_cancel_button_visible
	commit_button.visible = state.is_commit_button_visible
	skip_button.visible = state.is_skip_button_visible
