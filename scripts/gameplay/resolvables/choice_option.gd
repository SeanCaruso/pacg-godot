class_name ChoiceOption
extends RefCounted

var label: String
## action gets called by the Controller after ContextManager.end_resolvable() and before GFM.process
var action: Callable

func _init(_label: String, _action: Callable):
	label = _label
	action = _action