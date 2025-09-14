class_name ValerosEndOfTurnResolvable
extends BaseResolvable

const Action := preload("res://scripts/core/enums/action_type.gd").Action

var _valid_cards: Array[CardInstance]


func _init(cards: Array[CardInstance]) -> void:
	_valid_cards = cards


func get_additional_actions_for_card(card: CardInstance) -> Array[StagedAction]:
	# Only one card allowed.
	if not GameServices.asm.staged_cards.is_empty():
		return []
	
	var actions: Array[StagedAction] = []
	
	if _valid_cards.has(card):
		actions.append(DefaultAction.new(card, Action.RECHARGE))
	
	return actions


func can_commit(actions: Array[StagedAction]) -> bool:
	if actions.size() == 1:
		GameEvents.set_status_text.emit("")
		return true
	
	GameEvents.set_status_text.emit("Recharge a weapon or an armor from your hand or discards.")
	return false


func resolve() -> void:
	GameServices.contexts.turn_context.performed_character_powers.append("valeros_end")
