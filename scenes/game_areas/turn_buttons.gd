# turn_buttons.gd
extends HBoxContainer

const CARD_DISPLAY = preload("uid://banp7lkt3ongm")
const CardDisplay = preload("uid://bom1qycn3dg43")

@onready var hour_container: Control = %HourContainer
@onready var give_button: TextureButton = %GiveButton
@onready var move_button: TextureButton = %MoveButton
@onready var optional_discards_button: TextureButton = %OptionalDiscardsButton
@onready var end_turn_button: TextureButton = %EndTurnButton


func _ready() -> void:
	GameEvents.hour_changed.connect(_on_hour_changed)
	GameEvents.player_character_changed.connect(_on_player_character_changed)
	GameEvents.staged_actions_state_changed.connect(_on_staged_actions_chaged)
	GameEvents.turn_state_changed.connect(_update_turn_buttons)
	
	GuiUtils.add_mouseover_effect_to_button(give_button)
	
	GuiUtils.add_mouseover_effect_to_button(move_button)
	move_button.pressed.connect(
		func():
			DialogEvents.move_clicked_event.emit(Contexts.turn_context.character)
	)
	
	GuiUtils.add_mouseover_effect_to_button(optional_discards_button)
	optional_discards_button.pressed.connect(
		func():
			TaskManager.start_task(EndTurnController.new(false))
	)
	
	GuiUtils.add_mouseover_effect_to_button(end_turn_button)
	end_turn_button.pressed.connect(
		func():
			TaskManager.start_task(EndTurnController.new(true))
	)


func _on_hour_changed(hour_instance: CardInstance) -> void:
	for child in hour_container.get_children():
		child.queue_free()
	
	var hour_display: CardDisplay = CARD_DISPLAY.instantiate()
	hour_container.add_child(hour_display)
	hour_display.set_card_instance(hour_instance)
	hour_display.scale = Vector2(0.5, 0.5)


func _on_player_character_changed(_pc: PlayerCharacter) -> void:
	_update_turn_buttons()


func _on_staged_actions_chaged(state: StagedActionsState) -> void:
	move_button.disabled = not state.is_move_enabled


func _update_turn_buttons() -> void:
	if not TaskManager.current_resolvable is FreePlayResolvable \
	or not Contexts.turn_context \
	or Contexts.game_context.active_character != Contexts.turn_context.character:
		give_button.disabled = true
		move_button.disabled = true
		optional_discards_button.disabled = true
		end_turn_button.disabled = true
		return
	
	give_button.disabled = \
		not Contexts.turn_context.can_give \
		or Contexts.game_context.active_character.local_characters.size() < 2
	move_button.disabled = not Contexts.turn_context.can_move or Contexts.game_context.locations.size() < 2
	optional_discards_button.disabled = Contexts.turn_context.character.hand.is_empty()
	end_turn_button.disabled = false
