# location_deck.gd
extends TextureButton


func _ready() -> void:
	GameEvents.player_character_changed.connect(_on_player_character_changed)
	GameEvents.staged_actions_state_changed.connect(_on_staged_actions_changed)
	GameEvents.turn_state_changed.connect(_update_explore_button)


func _on_explore_pressed() -> void:
	TaskManager.commit()
	TaskManager.start_task(ExploreTurnProcessor.new())


func _on_player_character_changed(_pc: PlayerCharacter) -> void:
	_update_explore_button()


func _on_staged_actions_changed(state: StagedActionsState) -> void:
	disabled = !state.is_explore_enabled


func _update_explore_button() -> void:
	if TaskManager.current_resolvable is not FreePlayResolvable \
	or not Contexts.turn_context \
	or Contexts.game_context.active_character != Contexts.turn_context.character:
		disabled = true
		return
	
	disabled = !Contexts.turn_context.can_freely_explore
