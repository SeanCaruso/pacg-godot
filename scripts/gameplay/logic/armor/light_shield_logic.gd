class_name LightShieldLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	if _contexts.encounter_context:
		_contexts.encounter_context.add_prohibited_traits(action.card.owner, ["2-Handed"])
	
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
	return not _asm.staged_cards.has(card) \
		and _contexts.current_resolvable is DamageResolvable \
		and (_contexts.current_resolvable as DamageResolvable).damage_type == "Combat" \
		and (_contexts.current_resolvable as DamageResolvable).character == card.owner


func _can_recharge(card: CardInstance) -> bool:
	# We can freely recharge to reroll if we're processing a RerollResolvable 
	# and the dice pool has a d4, d6, or d8.
	return _contexts.check_context != null \
		and _contexts.current_resolvable is RerollResolvable \
		and card.owner == (_contexts.current_resolvable as RerollResolvable).character \
		and _contexts.check_context.used_skill == Skill.MELEE \
		and (_contexts.current_resolvable as RerollResolvable).dice_pool.num_dice_in_sizes([4, 6, 8]) > 0
