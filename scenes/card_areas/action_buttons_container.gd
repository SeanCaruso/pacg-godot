# action_buttons_container
extends VBoxContainer

const ACTION_BUTTON_SCENE := preload("res://scenes/ui_objects/action_button.tscn")
const ActionButton := preload("res://scenes/ui_objects/action_button.gd")


func _ready() -> void:
	GameEvents.player_choice_event.connect(_on_player_choice_event)


func _end_choice() -> void:
	GameEvents.set_status_text.emit("")
	
	for c in get_children():
		c.queue_free()


func _on_player_choice_event(resolvable: PlayerChoiceResolvable) -> void:
	GameEvents.set_status_text.emit(resolvable.prompt)
	
	for option in resolvable.options:
		var button: ActionButton = ACTION_BUTTON_SCENE.instantiate()
		add_child(button)
		button.text = option.label
		
		button.pressed.connect(
			func():
				_end_choice()
				resolvable.chosen_action = option.action
				TaskManager.resolve_current()
		)
