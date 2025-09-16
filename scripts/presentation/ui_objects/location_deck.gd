# location_deck.gd
extends TextureButton

var _contexts: ContextManager:
	get:
		return GameServices.contexts


func _ready() -> void:
	GameEvents.player_character_changed.connect(_on_player_character_changed)
	GameEvents.staged_actions_state_changed.connect(_on_staged_actions_changed)
	GameEvents.turn_state_changed.connect(_update_explore_button)


func _on_explore_pressed() -> void:
	GameServices.asm.commit()
	GameServices.game_flow.start_phase(ExploreTurnProcessor.new(), "Explore")


func _on_player_character_changed(_pc: PlayerCharacter) -> void:
	_update_explore_button()


func _on_staged_actions_changed(state: StagedActionsState) -> void:
	disabled = !state.is_explore_enabled


func _update_explore_button() -> void:
	if _contexts.current_resolvable \
	or not _contexts.turn_context \
	or _contexts.game_context.active_character != _contexts.turn_context.character:
		disabled = true
		return
	
	disabled = !_contexts.turn_context.can_freely_explore
