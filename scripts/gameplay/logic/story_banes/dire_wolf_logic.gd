class_name DireWolfLogic
extends CardLogicBase


func can_evade() -> bool:
	return false


func on_encounter() -> void:
	if _contexts.encounter_context:
		_contexts.encounter_context.resolvable_modifiers.append(_modify_damage_resolvable)


func _modify_damage_resolvable(resolvable: BaseResolvable) -> void:
	if not resolvable is DamageResolvable:
		return
	
	var damage_resolvable := resolvable as DamageResolvable
	var damage_increase := DiceUtils.roll(4)
	print("Dire Wolf increased damage by %d!" % damage_increase)
	damage_resolvable.amount += damage_increase
