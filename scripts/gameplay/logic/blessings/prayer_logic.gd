class_name PrayerLogic
extends CardLogicBase


func on_commit(action: StagedAction) -> void:
	var is_bless: bool = action.action_data.get("Bless", false)
	if is_bless:
		return
	
	# Examine the top card of your location...
	var examine_resolvable := ExamineResolvable.new(action.card.owner.location._deck, 1)
	
	# Then you may explore.
	var explore_option_resolvable := CardUtils.create_explore_choice()
	
	examine_resolvable.override_next_processor(
		NewResolvableProcessor.new(explore_option_resolvable)
	)
	
	_game_flow.queue_next_processor(NewResolvableProcessor.new(examine_resolvable))


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	if _can_bless(card):
		var modifier := CheckModifier.new(card)
		modifier.skill_dice_to_add = 1
		return [PlayCardAction.new(card, Action.DISCARD, modifier, {"Bless": true})]
	elif Contexts.is_explore_possible and Contexts.turn_context.character == card.owner:
		return [PlayCardAction.new(card, Action.DISCARD, null, {"Bless": false})]
	
	return []


func _can_bless(card: CardInstance) -> bool:
	# We can bless on any check.
	return Contexts.current_resolvable is CheckResolvable \
		and Contexts.current_resolvable.can_stage_type(card.card_type)
