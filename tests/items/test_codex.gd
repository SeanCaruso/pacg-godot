# test_codex.gd
extends BaseTest

var _codex_instance: CardInstance

func before_each():
	super()
	# Set up the Codex card
	var codex_data = TestUtils.load_card_data("Codex")
	_codex_instance = GameServices.cards.new_card(codex_data, ezren)
	_codex_instance.current_location = CardLocation.HAND
	ezren.add_to_hand(_codex_instance)


func test_codex_no_actions_vs_bane():
	# Set up encounter with Zombie (bane)
	TestUtils.setup_encounter_with_instances(ezren, zombie)
	
	var actions := _codex_instance.get_available_actions()
	assert_eq(actions.size(), 0, "Codex should have no actions vs bane")


func test_codex_two_actions_vs_own_boon():
	# Set up encounter with Longsword (boon) for Ezren
	TestUtils.setup_encounter_with_instances(ezren, longsword)
	
	var actions := _codex_instance.get_available_actions()
	assert_eq(actions.size(), 2, "Codex should have two actions vs own boon")
	
	var reveal_mod = (actions[0] as PlayCardAction).check_modifier
	assert_not_null(reveal_mod, "Reveal action should have modifier")
	assert_eq(reveal_mod.added_dice.size(), 0, "Reveal should add no dice")
	assert_eq(reveal_mod.added_bonus, 1, "Reveal should add +1 bonus")
	
	var bury_mod = (actions[1] as PlayCardAction).check_modifier
	assert_not_null(bury_mod, "Bury action should have modifier")
	assert_eq(bury_mod.added_dice.size(), 1, "Bury should add one die")
	assert_eq(bury_mod.added_dice[0], 12, "Bury should add d12")
	assert_eq(bury_mod.added_bonus, 2, "Bury should add +2 bonus")


func test_codex_one_action_vs_local_boon():
	# Set up encounter with Longsword for Valeros, but Ezren at same location
	TestUtils.setup_encounter_with_instances(valeros, longsword)
	ezren.location = valeros.location
	
	var actions := _codex_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Codex should have one action vs local boon")
	
	var bury_mod = (actions[0] as PlayCardAction).check_modifier
	assert_not_null(bury_mod, "Bury action should have modifier")
	assert_eq(bury_mod.added_dice.size(), 1, "Bury should add one die")
	assert_eq(bury_mod.added_dice[0], 12, "Bury should add d12")
	assert_eq(bury_mod.added_bonus, 2, "Bury should add +2 bonus")


func test_codex_no_actions_vs_distant_boon():
	# Set up encounter with Longsword for Valeros, but Ezren at different location
	TestUtils.setup_encounter_with_instances(valeros, longsword)
	
	var campsite = TestUtils.get_location("Campsite")
	ezren.location = campsite
	assert_ne(ezren.location, valeros.location, "Ezren should be at different location")
	
	var actions := _codex_instance.get_available_actions()
	assert_eq(actions.size(), 0, "Codex should have no actions vs distant boon")
