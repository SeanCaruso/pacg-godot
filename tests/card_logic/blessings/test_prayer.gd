# test_prayer.gd
extends BaseTest


func test_prayer_can_bless_combat():
	# Set up encounter with Zombie (combat check)
	TestUtils.setup_encounter("Valeros", "Zombie")
	var prayer = TestUtils.get_card("Prayer")
	Contexts.encounter_context.character.add_to_hand(prayer)
	
	var actions := prayer.get_available_actions()
	assert_eq(actions.size(), 1, "Prayer should have one action for combat check")


func test_prayer_can_bless_skill():
	# Set up encounter with Soldier (skill check)
	TestUtils.setup_encounter("Valeros", "Soldier")
	var prayer = TestUtils.get_card("Prayer")
	Contexts.encounter_context.character.add_to_hand(prayer)
	
	var actions := prayer.get_available_actions()
	assert_eq(actions.size(), 1, "Prayer should have one action for skill check")


func test_prayer_not_freely():
	# Set up encounter with Soldier (skill check)
	TestUtils.setup_encounter("Valeros", "Soldier")
	var prayer = TestUtils.get_card("Prayer")
	Contexts.encounter_context.character.add_to_hand(prayer)
	
	# Stage first Prayer
	var actions := prayer.get_available_actions()
	assert_eq(actions.size(), 1, "First Prayer should have one action")
	GameServices.asm.stage_action(actions[0])
	
	# Try to use second Prayer
	var prayer2 = TestUtils.get_card("Prayer")
	Contexts.encounter_context.character.add_to_hand(prayer2)
	actions = prayer2.get_available_actions()
	assert_eq(actions.size(), 0, "Second Prayer should have no actions (not freely playable)")


func test_prayer_bless_valeros_combat():
	# Set up encounter with Zombie (combat check)
	TestUtils.setup_encounter("Valeros", "Zombie")
	var prayer = TestUtils.get_card("Prayer")
	Contexts.encounter_context.character.add_to_hand(prayer)
	
	var actions := prayer.get_available_actions()
	assert_eq(actions.size(), 1, "Prayer should have one action")
	GameServices.asm.stage_action(actions[0])
	
	var dice_pool := GameServices.asm.get_staged_dice_pool()
	assert_eq(dice_pool.to_string(), "2d10 + 2", "Prayer should add an extra d10 to Valeros combat")
