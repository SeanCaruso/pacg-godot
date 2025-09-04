class_name EndOfCheckProcessor
extends BaseProcessor

var _contexts : ContextManager

func _init(game_services: GameServices):
	_contexts = game_services.contexts
	
	
func on_execute() -> void:
	if !_contexts.check_context or !_contexts.check_context.check_result: return
	
	var resolvable := _contexts.check_context.resolvable
	var result := _contexts.check_context.check_result
	# If we have any defined success/fail callbacks, invoke them.
	if result.was_success:
		if resolvable: resolvable.on_success.call()
	else:
		if resolvable: resolvable.on_failure.call()
		
	# If we're in an encounter, store the check result for later processing.
	if _contexts.encounter_context:
		_contexts.encounter_context.check_result = result
		
	_contexts.end_check()
