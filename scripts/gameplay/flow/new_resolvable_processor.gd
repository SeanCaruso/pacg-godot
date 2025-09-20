class_name NewResolvableProcessor
extends BaseProcessor

var _next_resolvable: BaseResolvable

func _init(next_resolvable: BaseResolvable):
	_next_resolvable = next_resolvable
	
	
func on_execute() -> void:
	print("[%s] Creating next resolvable: %s" % [self, _next_resolvable])
	Contexts.new_resolvable(_next_resolvable)
