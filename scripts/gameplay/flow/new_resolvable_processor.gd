class_name NewResolvableProcessor
extends BaseProcessor

var _next_resolvable: BaseResolvable

# Dependency injection
var _contexts: ContextManager

func _init(next_resolvable: BaseResolvable, game_services: GameServices):
	_next_resolvable = next_resolvable
	_contexts = game_services.contexts
	
	
func on_execute() -> void:
	print("[%s] Creating next resolvable: %s" % [self, _next_resolvable])
	_contexts.new_resolvable(_next_resolvable)
