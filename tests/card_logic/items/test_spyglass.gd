# test_spyglass.gd
extends BaseTest

var _spyglass_instance: CardInstance

func before_each():
	super()
	# Set up the Spyglass card
	var spyglass_data = TestUtils.load_card_data("Spyglass")
	_spyglass_instance = GameServices.cards.new_card(spyglass_data, valeros)
	_spyglass_instance.current_location = CardLocation.HAND


func test_spyglass_usable_with_perception():
	# Set up a new encounter with Dire Badger (requires perception)
	TestUtils.setup_encounter("Valeros", "Dire Badger")
	Contexts.encounter_context.character.add_to_hand(_spyglass_instance)
	
	var actions := _spyglass_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Spyglass should have one action with perception check")
	
	GameServices.asm.stage_action(actions[0])
	var dice_pool := GameServices.asm.get_staged_dice_pool()
	assert_eq(dice_pool.to_string(), "1d6 + 1d4", "Spyglass should add 1d4 to perception check")


func test_spyglass_unusable_without_perception():
	# Set up a new encounter with Soldier (doesn't require perception)
	TestUtils.setup_encounter("Valeros", "Soldier")
	Contexts.encounter_context.character.add_to_hand(_spyglass_instance)
	
	var actions := _spyglass_instance.get_available_actions()
	assert_eq(actions.size(), 0, "Spyglass should have no actions without perception check")
