class_name CheckDamageProcessor
extends BaseProcessor
	
	
func on_execute() -> void:
	var check := _contexts.check_context
	if !check: return
	
	if check.check_result.was_success:
		print("Rolled %d vs. %d - Success!" % [check.check_result.final_roll_total, check.check_result.dc])
	else:
		var damage_resolvable = DamageResolvable.new(
			check.resolvable.character,
			-check.check_result.margin_of_success)
		_contexts.new_resolvable(damage_resolvable)
		print("Rolled %d vs. %d - Take %d damage!" %
			[check.check_result.final_roll_total, check.check_result.dc, damage_resolvable.amount])
