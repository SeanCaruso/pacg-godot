class_name MoveAction
extends StagedAction

const Action := preload("res://scripts/core/enums/action_type.gd").Action

func _init(_card: CardInstance, _action_type: Action):
	card = _card
	action_type = _action_type
	is_freely = false


func commit() -> void:
	if card.logic:
		card.logic.on_commit(self)


func on_stage() -> void:
	GameEvents.set_status_text.emit("Move?")
