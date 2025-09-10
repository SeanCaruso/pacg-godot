class_name PlayCardAction
extends StagedAction

var is_combat: bool:
	get: return action_data.get("IsCombat", false)

const Action := preload("res://scripts/core/enums/action_type.gd").Action

var check_modifier: CheckModifier


func _init(
	_card: CardInstance,
	_action: Action,
	_check_modifier: CheckModifier,
	_action_data: Dictionary
) -> void:
	card  = _card
	action_type = _action
	check_modifier = _check_modifier
	
	for key in _action_data:
		action_data[key] = _action_data[key]


func commit() -> void:
	if not card.logic: return
	card.logic.on_commit(self)
