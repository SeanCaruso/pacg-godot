class_name LightShieldLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	if Contexts.encounter_context:
		Contexts.encounter_context.add_prohibited_traits(action.card.owner, ["2-Handed"])
	
	if action.action_type != Action.RECHARGE:
		return
	
	# TODO: Implement reroll logic.
	print("[LightShieldLogic] Reroll logic not implemented.")


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var modifier := CheckModifier.new(card)
	modifier.prohibited_traits = ["2-Handed"]
	
	if _can_reveal(card):
		return [PlayCardAction.new(card, Action.REVEAL, modifier, {"IsFreely": true, "Damage": 1})]
	if _can_recharge(card):
		return [PlayCardAction.new(card, Action.RECHARGE, modifier, {"IsFreely": true})]
	
	return []


func _can_reveal(card: CardInstance) -> bool:
	# Can freely reveal once if the owner has a Combat DamageResolvable.
	return TaskManager.current_resolvable is DamageResolvable \
		and not TaskManager.current_resolvable.staged_cards.has(card) \
		and (TaskManager.current_resolvable as DamageResolvable).damage_type == "Combat" \
		and (TaskManager.current_resolvable as DamageResolvable).character == card.owner


func _can_recharge(card: CardInstance) -> bool:
	# We can freely recharge to reroll if we're processing a RerollResolvable 
	# and the dice pool has a d4, d6, or d8.
	return Contexts.check_context != null \
		and TaskManager.current_resolvable is RerollResolvable \
		and card.owner == (TaskManager.current_resolvable as RerollResolvable).character \
		and Contexts.check_context.used_skill == Skill.MELEE \
		and (TaskManager.current_resolvable as RerollResolvable).dice_pool.num_dice_in_sizes([4, 6, 8]) > 0
