# test_razor_snare.gd
extends BaseTest


func test_razor_snare_undefeated_entangles():
	# Set up encounter with Razor Snare
	TestUtils.setup_encounter("Valeros", "Razor Snare")
	
	var check = Contexts.check_context
	check.resolvable.check_steps[0].base_dc = 99  # Make it impossible to succeed
	
	GameServices.asm.commit()
	
	assert_false(check.check_result.was_success, "Check should fail")
	assert_true(check.character.active_scourges.has(Scourge.ENTANGLED), "Should have Entangled scourge")


func test_razor_snare_undefeated_wounds():
	# Set up encounter with Razor Snare
	TestUtils.setup_encounter("Valeros", "Razor Snare")
	
	var check = Contexts.check_context
	check.resolvable.check_steps[0].base_dc = 99  # Make it impossible to succeed
	
	GameServices.asm.commit()
	
	assert_false(check.check_result.was_success, "Check should fail")
	assert_true(check.character.active_scourges.has(Scourge.WOUNDED), "Should have Wounded scourge")


func test_razor_snare_undefeated_ends_turn():
	# Set up turn context
	var test_valeros = TestUtils.get_character("Valeros")
	Contexts.new_turn(TurnContext.new(test_valeros))
	
	# Get Razor Snare and call undefeated
	var card = TestUtils.get_card("Razor Snare")
	card.logic.on_undefeated(card)
	
	assert_true(Contexts.turn_context.force_end_turn, "Should force end turn")
