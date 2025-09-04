## A default card action or power that can be done freely
class_name DefaultAction
extends StagedAction

func _init(_card: CardInstance, _action_type: ActionType):
	card = _card
	action_type = _action_type
	is_freely = true
