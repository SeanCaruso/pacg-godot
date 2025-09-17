# turn_buttons.gd
extends HBoxContainer

var _contexts : ContextManager:
	get:
		return GameServices.contexts

@onready var give_button: TextureButton = %GiveButton
@onready var move_button: TextureButton = %MoveButton
@onready var optional_discards_button: TextureButton = %OptionalDiscardsButton
@onready var end_turn_button: TextureButton = %EndTurnButton


func _ready() -> void:
	GameEvents.player_character_changed.connect(_on_player_character_changed)
	GameEvents.staged_actions_state_changed.connect(_on_staged_actions_chaged)
	GameEvents.turn_state_changed.connect(_update_turn_buttons)
	
	GuiUtils.add_mouseover_effect_to_button(give_button)
	
	GuiUtils.add_mouseover_effect_to_button(move_button)
	move_button.pressed.connect(
		func():
			DialogEvents.move_clicked_event.emit(_contexts.turn_context.character)
	)
	
	GuiUtils.add_mouseover_effect_to_button(optional_discards_button)
	optional_discards_button.pressed.connect(
		func():
			GameServices.game_flow.start_phase(EndTurnController.new(false), "End Turn")
	)
	
	GuiUtils.add_mouseover_effect_to_button(end_turn_button)
	end_turn_button.pressed.connect(
		func():
			GameServices.game_flow.start_phase(EndTurnController.new(true), "End Turn")
	)


func _on_player_character_changed(_pc: PlayerCharacter) -> void:
	_update_turn_buttons()


func _on_staged_actions_chaged(state: StagedActionsState) -> void:
	move_button.disabled = not state.is_move_enabled


func _update_turn_buttons() -> void:
	if _contexts.current_resolvable \
	or not _contexts.turn_context \
	or _contexts.game_context.active_character != _contexts.turn_context.character:
		give_button.disabled = true
		move_button.disabled = true
		optional_discards_button.disabled = true
		end_turn_button.disabled = true
		return
	
	give_button.disabled = not _contexts.turn_context.can_give
	move_button.disabled = not _contexts.turn_context.can_move
	optional_discards_button.disabled = _contexts.turn_context.character.hand.is_empty()
	end_turn_button.disabled = false
