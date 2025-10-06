class_name CardActionResolvable
extends BaseResolvable
## A resolvable for generic card actions that must be done.
##
## If a power instructs a character to perform some type of action on one or
## more cards, this is the resolvable for you!

const Action := preload("res://scripts/core/enums/action_type.gd").Action
const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

var num_required: int = 1
var valid_actions: Array[Action] = []


func _init(actions: Array[Action]) -> void:
	valid_actions.assign(actions)


func can_commit(actions: Array[StagedAction]) -> bool:
	return actions.size() >= num_required


func get_additional_actions_for_card(card: CardInstance) -> Array[StagedAction]:
	if staged_actions.size() >= num_required:
		return []
		
	if not card.current_location in [CardLocation.HAND, CardLocation.REVEALED]:
		return []
	
	var actions: Array[StagedAction] = []
	for action in valid_actions:
		actions.append(DefaultAction.new(card, action))
	
	return actions
