class_name HelmLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	if _contexts.encounter_context:
		_contexts.encounter_context.add_prohibited_traits(action.card.owner, ["Helm"])


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	if not _can_reveal(card):
		return []
	
	var modifier := CheckModifier.new(card)
	modifier.prohibited_traits = ["Helm"]
	return [PlayCardAction.new(card, Action.REVEAL, modifier, {"IsFreely": true, "Damage": 1})]


func _can_reveal(card: CardInstance) -> bool:
	# We can freely reveal for damage if we have a DamageResolvable for the card's owner
	# with Combat damage, or any type of damage if proficient.
	if not _contexts.current_resolvable is DamageResolvable:
		return false
	
	var resolvable := _contexts.current_resolvable as DamageResolvable
	return (resolvable.damage_type == "Combat" or card.owner.is_proficient(card)) \
		and resolvable.character == card.owner
