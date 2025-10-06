class_name CheckDamageProcessor
extends BaseProcessor
	
	
func execute() -> void:
	if not Contexts.check_context or Contexts.check_context.force_success:
		return
	
	var check := Contexts.check_context
	if check.check_result.was_success:
		print("Rolled %d vs. %d - Success!" % [check.check_result.final_roll_total, check.check_result.dc])
	elif not check.resolvable.character.hand_and_revealed.is_empty():
		var damage_resolvable = DamageResolvable.new(
			check.resolvable.character,
			-check.check_result.margin_of_success)
		TaskManager.push(damage_resolvable)
		print("Rolled %d vs. %d - Take %d damage!" %
			[check.check_result.final_roll_total, check.check_result.dc, damage_resolvable.amount])
