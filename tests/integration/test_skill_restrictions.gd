extends BaseTest


func test_skill_restrictions_longbow_blocks_soldier() -> void:
	var longbow := TestUtils.get_card("Longbow")
	var soldier := TestUtils.get_card("Soldier")
	valeros.add_to_hand(longbow)
	valeros.add_to_hand(soldier)
	
	TestUtils.setup_encounter_with_instances(valeros, zombie)
	
	assert_not_null(GameServices.contexts.current_resolvable)
	assert_true(GameServices.contexts.current_resolvable is CheckResolvable)
	
	# Longbow should be usable - no skill restrictions yet.
	var longbow_actions := longbow.get_available_actions()
	assert_eq(longbow_actions.size(), 1, "Longbow has one action.")
	
	var soldier_actions := soldier.get_available_actions()
	assert_eq(soldier_actions.size(), 1, "Soldier has one action.")
	
	GameServices.asm.stage_action(longbow_actions[0])
	
	soldier_actions = soldier.get_available_actions()
	assert_eq(soldier_actions.size(), 0, "Soldier has no actions.")


func test_skill_restrictions_soldier_blocks_longbow() -> void:
	var longbow := TestUtils.get_card("Longbow")
	var soldier := TestUtils.get_card("Soldier")
	valeros.add_to_hand(longbow)
	valeros.add_to_hand(soldier)
	
	TestUtils.setup_encounter_with_instances(valeros, zombie)
	
	assert_not_null(GameServices.contexts.current_resolvable)
	assert_true(GameServices.contexts.current_resolvable is CheckResolvable)
	
	# Longbow should be usable - no skill restrictions yet.
	var longbow_actions := longbow.get_available_actions()
	assert_eq(longbow_actions.size(), 1, "Longbow has one action.")
	
	var soldier_actions := soldier.get_available_actions()
	assert_eq(soldier_actions.size(), 1, "Soldier has one action.")
	
	GameServices.asm.stage_action(soldier_actions[0])
	
	longbow_actions = longbow.get_available_actions()
	assert_eq(longbow_actions.size(), 0, "Longbow has no actions.")
