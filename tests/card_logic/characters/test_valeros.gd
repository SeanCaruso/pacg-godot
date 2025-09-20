# test_valeros.gd
extends BaseTest

func before_each():
	super()
	Contexts.new_turn(TurnContext.new(valeros))


func test_valeros_end_turn_power_valid_card_in_hand():
	# Add weapon to hand
	valeros.add_to_hand(longsword)
	
	GameServices.game_flow.start_phase(EndOfTurnProcessor.new(), "End Turn")
	
	var recharge_power = valeros.end_of_turn_power
	assert_not_null(recharge_power, "Should have recharge power with weapon in hand")
	assert_eq(recharge_power, valeros.data.powers[1], "Should be the correct recharge power")


func test_valeros_end_turn_power_valid_card_in_discards():
	# Move weapon to discard pile
	longsword.owner = valeros
	GameServices.cards.move_card_to(longsword, CardLocation.DISCARDS)
	
	GameServices.game_flow.start_phase(EndOfTurnProcessor.new(), "End Turn")
	
	var recharge_power = valeros.end_of_turn_power
	assert_not_null(recharge_power, "Should have recharge power with weapon in discards")
	assert_eq(recharge_power, valeros.data.powers[1], "Should be the correct recharge power")


func test_valeros_end_turn_power_no_valid_card_in_hand():
	# Add ally (not weapon/armor) to hand
	var soldier = TestUtils.get_card("Soldier")
	valeros.add_to_hand(soldier)
	
	GameServices.game_flow.start_phase(EndOfTurnProcessor.new(), "End Turn")
	
	var recharge_power = valeros.end_of_turn_power
	assert_null(recharge_power, "Should not have recharge power with ally in hand")


func test_valeros_end_turn_power_no_valid_card_in_discards():
	# Move ally (not weapon/armor) to discard pile
	var soldier = TestUtils.get_card("Soldier")
	soldier.owner = valeros
	GameServices.cards.move_card_to(soldier, CardLocation.DISCARDS)
	
	GameServices.game_flow.start_phase(EndOfTurnProcessor.new(), "End Turn")
	
	var recharge_power = valeros.end_of_turn_power
	assert_null(recharge_power, "Should not have recharge power with ally in discards")
