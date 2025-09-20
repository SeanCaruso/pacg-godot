class_name CrowbarLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	if not _is_card_playable(card):
		return []
	
	# Only restrict to Strength skill on non-Lock or Obstacle Barriers.
	var required_traits: Array[String] = []
	if not _is_lock_obstacle_barrier():
		required_traits.append("Strength")
	
	# We can reveal for +1d8 or reveal and recharge for +2d8 if not revealed already.
	if card.current_location != CardLocation.REVEALED:
		var one_d8_modifier := CheckModifier.new(card)
		one_d8_modifier.added_dice = [8]
		one_d8_modifier.required_traits = required_traits
		
		var two_d8_modifier := CheckModifier.new(card)
		two_d8_modifier.added_dice = [8, 8]
		two_d8_modifier.required_traits = required_traits
		
		return [
			PlayCardAction.new(card, Action.REVEAL, one_d8_modifier),
			PlayCardAction.new(card, Action.RECHARGE, two_d8_modifier)
		]
	else:
		# Otherwise, if we're playable that means we've revealed. We can freely recharge for +1d8.
		var recharge_modifier := CheckModifier.new(card)
		recharge_modifier.added_dice = [8]
		recharge_modifier.required_traits = required_traits
		return [PlayCardAction.new(card, Action.RECHARGE, recharge_modifier, {"IsFreely": true})]


func _is_card_playable(card: CardInstance) -> bool:
	if Contexts.check_context == null:
		return false  # Must be in a check...
	
	if not Contexts.current_resolvable is CheckResolvable:
		return false  # ... for a CheckResolvable...
	
	var resolvable := Contexts.current_resolvable as CheckResolvable
	if resolvable.character != card.owner:
		return false  # ... for the card's owner...
	
	if not resolvable.can_stage_type(card.card_type):
		return false  # ... with no Items played.
	
	if Contexts.check_context.invokes(["Strength"]):
		return true  # We can play on Strength checks...
	
	if _is_lock_obstacle_barrier():
		return true  # ... or Lock or Obstacle Barriers.
	
	return false


func _is_lock_obstacle_barrier() -> bool:
	if not Contexts.encounter_context:
		return false
	
	if Contexts.encounter_context.card_data.card_type != CardType.BARRIER:
		return false
	
	var traits := Contexts.encounter_context.card_data.traits
	return traits.has("Lock") or traits.has("Obstacle")
