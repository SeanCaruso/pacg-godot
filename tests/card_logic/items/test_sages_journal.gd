# test_sages_journal.gd
extends BaseTest

var _sages_journal_instance: CardInstance
var _soldier: CardInstance
var _dire_wolf: CardInstance

func before_each():
	super()
	# Load common test cards
	_soldier = TestUtils.get_card("Soldier")
	_dire_wolf = TestUtils.get_card("Dire Wolf")
	
	# Set up the Sage's Journal card
	var sages_journal_data = TestUtils.load_card_data("Sages Journal")
	_sages_journal_instance = Cards.new_card(sages_journal_data, ezren)
	_sages_journal_instance.current_location = CardLocation.HAND
	ezren.add_to_hand(_sages_journal_instance)


func test_sages_journal_no_actions_vs_ally():
	# Set up encounter with Soldier (ally)
	TestUtils.setup_encounter_with_instances(ezren, _soldier)
	
	var actions := _sages_journal_instance.get_available_actions()
	assert_eq(actions.size(), 0, "Sage's Journal should have no actions vs ally")


func test_sages_journal_two_actions_vs_own_story_bane():
	# Set up encounter with Dire Wolf (story bane) for Ezren
	TestUtils.setup_encounter_with_instances(ezren, _dire_wolf)
	
	var actions := _sages_journal_instance.get_available_actions()
	assert_eq(actions.size(), 2, "Sage's Journal should have two actions vs own story bane")
	
	var reveal_mod = (actions[0] as PlayCardAction).check_modifier
	assert_not_null(reveal_mod, "Reveal action should have modifier")
	assert_eq(reveal_mod.added_dice.size(), 1, "Reveal should add one die")
	assert_eq(reveal_mod.added_dice[0], 4, "Reveal should add d4")
	
	var bury_mod = (actions[1] as PlayCardAction).check_modifier
	assert_not_null(bury_mod, "Bury action should have modifier")
	assert_eq(bury_mod.added_dice.size(), 1, "Bury should add one die")
	assert_eq(bury_mod.added_dice[0], 12, "Bury should add d12")
	assert_eq(bury_mod.added_bonus, 2, "Bury should add +2 bonus")


func test_sages_journal_one_action_vs_local_story_bane():
	# Set up encounter with Dire Wolf for Valeros, but Ezren at same location
	TestUtils.setup_encounter_with_instances(valeros, _dire_wolf)
	ezren.location = valeros.location
	
	var actions := _sages_journal_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Sage's Journal should have one action vs local story bane")
	
	var bury_mod = (actions[0] as PlayCardAction).check_modifier
	assert_not_null(bury_mod, "Bury action should have modifier")
	assert_eq(bury_mod.added_dice.size(), 1, "Bury should add one die")
	assert_eq(bury_mod.added_dice[0], 12, "Bury should add d12")
	assert_eq(bury_mod.added_bonus, 2, "Bury should add +2 bonus")


func test_sages_journal_no_actions_vs_distant_story_bane():
	# Set up encounter with Dire Wolf for Valeros, but Ezren at different location
	TestUtils.setup_encounter_with_instances(valeros, _dire_wolf)
	
	var campsite = TestUtils.get_location("Campsite")
	ezren.location = campsite
	assert_ne(ezren.location, valeros.location, "Ezren should be at different location")
	
	var actions := _sages_journal_instance.get_available_actions()
	assert_eq(actions.size(), 0, "Sage's Journal should have no actions vs distant story bane")
