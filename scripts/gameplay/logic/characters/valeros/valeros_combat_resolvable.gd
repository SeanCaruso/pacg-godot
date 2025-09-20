class_name ValerosCombatResolvable
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
	
	if not _valid_cards.has(card):
		return actions
	
	var modifier := CheckModifier.new(card)
	modifier.restricted_category = CheckModifier.CheckCategory.COMBAT
	modifier.added_dice = [4]
	
	actions.append(PlayCardAction.new(card, Action.RELOAD, modifier, {"IsFreely": true}))
	actions.append(PlayCardAction.new(card, Action.RECHARGE, modifier, {"IsFreely": true}))
	
	return actions


func can_commit(actions: Array[StagedAction]) -> bool:
	if actions.size() == 1:
		GameEvents.set_status_text.emit("")
		return true
	
	GameEvents.set_status_text.emit("Choose a weapon or armor to reload or recharge.")
	return false


func resolve() -> void:
	Contexts.check_context.context_data["character_powers"].append("valeros_combat")
	GameServices.asm.update_game_state_preview()
