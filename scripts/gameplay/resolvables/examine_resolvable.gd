class_name ExamineResolvable
extends BaseResolvable

var _examined_cards: Array[CardInstance]
var current_order: Array[CardInstance]
var deck: Deck
var count: int
var can_reorder: bool


func _init(_deck: Deck, _count: int, _can_reorder: bool = false) -> void:
	deck = _deck
	count = _count
	can_reorder = _can_reorder
	
	_examined_cards = deck.examine_top(_count)
	current_order = _examined_cards.duplicate()


func initialize():
	var examine_context = ExamineContext.new()
	examine_context.cards = current_order
	examine_context.unknown_count = deck.count - count
	examine_context.can_reorder = can_reorder
	examine_context.on_close = func(): if can_reorder: deck.reorder_examined(current_order)
	
	DialogEvents.examine_event.emit(examine_context)


## This resolvable can only be resolved via the Examine UI.
func can_commit(_actions: Array[StagedAction]) -> bool:
	return false


func resolve():
	if can_reorder: deck.reorder_examined(current_order)


## The Examine GUI handles its own button.
func get_ui_state(_actions: Array[StagedAction]) -> StagedActionsState:	
	return StagedActionsState.new()
