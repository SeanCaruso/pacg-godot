class_name BracersOfProtectionLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	var actions: Array[StagedAction] = []
	
	# Can freely reveal for Combat damage to the owner if not staged already.
	if TaskManager.current_resolvable is DamageResolvable \
	and (TaskManager.current_resolvable as DamageResolvable).damage_type == "Combat" \
	and (TaskManager.current_resolvable as DamageResolvable).character == card.owner \
	and not TaskManager.current_resolvable.staged_cards.has(card):
		actions.append(PlayCardAction.new(card, Action.REVEAL, null, {"Damage": 1, "IsFreely": true}))
	
	# Can recharge for any damage to the owner.
	if TaskManager.current_resolvable is DamageResolvable \
	and (TaskManager.current_resolvable as DamageResolvable).character == card.owner \
	and TaskManager.current_resolvable.can_stage_type(card.card_type):
		actions.append(PlayCardAction.new(card, Action.RECHARGE, null, {"Damage": 1}))
	
	return actions
