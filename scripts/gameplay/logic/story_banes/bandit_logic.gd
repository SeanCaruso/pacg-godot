class_name BanditLogic
extends CardLogicBase


func on_evaded(card: CardInstance) -> void:
	_trigger_card_bury()
	super(card)


func on_undefeated(card: CardInstance) -> void:
	_trigger_card_bury()
	super(card)


func get_before_acting_resolvable(_card: CardInstance) -> BaseResolvable:
	if not Contexts.encounter_context \
	or Contexts.encounter_context.character.hand_and_revealed.is_empty():
		return null
	
	GameEvents.set_status_text.emit("Recharge a card.")
	return CardActionResolvable.new(Contexts.encounter_context.character, [Action.RECHARGE])


func get_custom_check_resolvable(_card: CardInstance) -> BaseResolvable:
	if not Contexts.encounter_context \
	or not Contexts.encounter_context.character.hand_and_revealed.any(
		func(c: CardInstance): return c.is_boon
	):
		return null
	
	var random_boon: CardInstance = Contexts.encounter_context.character.hand_and_revealed.filter(
		func(c: CardInstance): return c.is_boon
	).pick_random()
	
	var resolvable := PlayerChoiceResolvable.new("Banish a random boon?", [
		ChoiceOption.new("Yes",
			func():
				Cards.move_card_to(random_boon, CardLocation.VAULT)
				Contexts.check_context.force_success = true
				TaskManager.resolve_current()
				),
		ChoiceOption.new("Cancel", func(): DialogEvents.emit_custom_check_encountered())
	])
	return resolvable


func _trigger_card_bury() -> void:
	if not Contexts.encounter_context:
		return
	
	var pc := Contexts.encounter_context.character
	if pc.deck_cards.is_empty():
		# TODO: Death effects
		return
	var bottom_card := pc.deck.at(-1)
	pc.bury(bottom_card)
	
	GameEvents.set_status_text.emit("Buried %s!" % str(bottom_card))
	print("Buried %s" % str(bottom_card))
	
