class_name ExamineContext
extends RefCounted

enum Mode { DECK, DISCARD }

var examine_mode: Mode = Mode.DECK
var cards: Array[CardInstance] = []
var unknown_count: int
var can_reorder: bool
var on_close: Callable
