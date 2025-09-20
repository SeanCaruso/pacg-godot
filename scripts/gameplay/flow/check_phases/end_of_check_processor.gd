class_name EndOfCheckProcessor
extends BaseProcessor
	
	
func on_execute() -> void:
	if !Contexts.check_context or !Contexts.check_context.check_result: return
	
	var resolvable := Contexts.check_context.resolvable
	var result := Contexts.check_context.check_result
	# If we have any defined success/fail callbacks, invoke them.
	if result.was_success:
		if resolvable: resolvable.on_success.call()
	else:
		if resolvable: resolvable.on_failure.call()
		
	# If we're in an encounter, store the check result for later processing.
	if Contexts.encounter_context:
		Contexts.encounter_context.check_result = result
		
	Contexts.end_check()
