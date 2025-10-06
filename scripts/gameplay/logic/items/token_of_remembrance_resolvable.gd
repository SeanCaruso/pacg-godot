class_name TokenOfRemembranceResolvable
extends BaseResolvable

const Action := preload("res://scripts/core/enums/action_type.gd").Action

var _valid_cards: Array[CardInstance]

func _init(cards: Array[CardInstance]):
	_valid_cards = cards
	cancel_aborts_phase = true

func get_additional_actions_for_card(card: CardInstance) -> Array[StagedAction]:
	# Only one card allowed.
	if staged_actions.any(
		func(a: StagedAction):
			return a.action_type == Action.RELOAD
	):
		return []
	
	if _valid_cards.has(card):
		return [DefaultAction.new(card, Action.RELOAD)]
	
	return []

func can_commit(actions: Array[StagedAction]) -> bool:
	if actions.any(func(a: StagedAction): return a.action_type == Action.RELOAD):
		GameEvents.set_status_text.emit("")
		return true
	
	GameEvents.set_status_text.emit("Reload a spell from your discards.")
	return false
