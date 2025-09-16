# action_buttons.gd
extends Control

@onready var cancel_button: TextureButton = %CancelButton
@onready var commit_button: TextureButton = %CommitButton
@onready var skip_button: TextureButton = %SkipButton


func _ready() -> void:
	cancel_button.pressed.connect(GameServices.asm.cancel)
	commit_button.pressed.connect(GameServices.asm.commit)
	skip_button.pressed.connect(GameServices.asm.skip)
	
	GameEvents.staged_actions_state_changed.connect(_update_staged_action_buttons)


func _update_staged_action_buttons(state: StagedActionsState) -> void:
	cancel_button.visible = state.is_cancel_button_visible
	commit_button.visible = state.is_commit_button_visible
	skip_button.visible = state.is_skip_button_visible
