class_name PhaseQueue
extends RefCounted

var processors: Array[BaseProcessor] = []
var name: String

var count: int:
	get: return processors.size()

func is_empty() -> bool:
	return processors.is_empty()

func _init(_name: String):
	name = _name


func enqueue(processor: BaseProcessor) -> void:
	processors.append(processor)


func interrupt(processor: BaseProcessor) -> void:
	processors.push_front(processor)


func dequeue() -> BaseProcessor:
	return null if processors.is_empty() else processors.pop_front()
	
