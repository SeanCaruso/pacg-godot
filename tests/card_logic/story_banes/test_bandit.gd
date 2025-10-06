# test_bandit.gd
extends BaseTest

var got_custom_check: bool


func before_each():
	super()
	got_custom_check = false


func test_bandit_recharge_before_acting():
	valeros.add_to_hand(longsword)
	TestUtils.setup_encounter_with_instances(valeros, TestUtils.get_card("Bandit"))
	
	assert_true(
		TaskManager.current_resolvable is CardActionResolvable,
		"Expected a CardActionResolvable to recharge a card."
	)
	
	var actions := TaskManager.current_resolvable.get_additional_actions_for_card(longsword)
	assert_eq(actions.size(), 1, "Longsword has one action.")
	
	assert_eq((actions[0] as DefaultAction).action_type, Action.RECHARGE, "Sword is rechargeable.")


func test_bandit_no_recharge_before_acting_with_empty_hand():
	TestUtils.setup_encounter("Valeros", "Bandit")
	valeros = Contexts.encounter_context.character
	
	assert_true(
		TaskManager.current_resolvable is CheckResolvable,
		"Expected a CheckResolvable with no cards in hand."
	)
	
	assert_false(got_custom_check, "Didn't get a custom check resolvable either.")


func test_bandit_defeat_by_banishing_boon():
	DialogEvents.custom_check_encountered.connect(func(): got_custom_check = true)
	
	var soldier := TestUtils.get_card("Soldier")
	var cat := TestUtils.get_card("Cat")
	valeros.add_to_hand(longsword)
	valeros.add_to_hand(soldier)
	valeros.add_to_hand(cat)
	
	var boons := [longsword, soldier, cat]
	
	TestUtils.setup_encounter_with_instances(valeros, TestUtils.get_card("Bandit"))
	var bandit := Contexts.encounter_context.card
	TaskManager.commit()
	
	assert_true(got_custom_check, "Received a custom_check_encountered signal")
	
	TaskManager.push(Contexts.encounter_context.card.get_custom_check_resolvable())
	assert_true(
		TaskManager.current_resolvable is PlayerChoiceResolvable,
		"Expected a custom check PlayerChoiceResolvable"
	)
	
	var callable := (TaskManager.current_resolvable as PlayerChoiceResolvable).options[0].action
	TaskManager.resolve_current()
	callable.call()
	
	var card_locs := {CardLocation.HAND: 0, CardLocation.VAULT: 0}
	for boon in boons:
		card_locs[boon.current_location] = card_locs[boon.current_location] + 1
	assert_eq(card_locs[CardLocation.VAULT], 1, "One card banished.")
	assert_eq(card_locs[CardLocation.HAND], boons.size() - 1, "Other cards still in hand.")
	assert_eq(bandit.current_location, CardLocation.VAULT, "Bandit was banished.")


func test_bandit_undefeated_buries_bottom_deck_card() -> void:
	valeros.reload(longsword)
	valeros.reload(TestUtils.get_card("Soldier"))
	valeros.reload(TestUtils.get_card("Cat"))
	
	TestUtils.setup_encounter_with_instances(valeros, TestUtils.get_card("Bandit"))
	Contexts.check_context.resolvable.check_steps[0].base_dc = 99
	TaskManager.commit()
	
	assert_eq(longsword.current_location, CardLocation.BURIED, "Longsword was buried.")
	assert_eq(valeros.deck.count, 2, "Valeros has 2 cards remaining.")


func test_bandit_evaded_buries_bottom_deck_card() -> void:
	ezren.reload(longsword)
	ezren.reload(TestUtils.get_card("Soldier"))
	ezren.reload(TestUtils.get_card("Cat"))
	
	var sleep := TestUtils.get_card("Sleep")
	ezren.add_to_hand(sleep)
	
	TestUtils.setup_encounter_with_instances(ezren, TestUtils.get_card("Bandit"))
	TaskManager.current_resolvable.stage_action(sleep.get_available_actions()[0])
	TaskManager.commit()
	
	assert_eq(longsword.current_location, CardLocation.BURIED, "Longsword was buried.")
	assert_eq(ezren.deck.count, 2, "Ezren has 2 cards remaining.")
