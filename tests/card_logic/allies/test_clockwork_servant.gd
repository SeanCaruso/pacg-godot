# test_clockwork_servant.gd
extends BaseTest

# Test subjects
var _clockwork_servant: CardInstance

func before_each():
	super()
	
	_clockwork_servant = TestUtils.get_card("Clockwork Servant")


func test_clock_serv_can_recharge_vs_int():
	# Set up a new encounter
	TestUtils.setup_encounter("Valeros", "Deflect")
	Contexts.encounter_context.character.add_to_hand(_clockwork_servant)
	
	# Check that the game pauses when reaching the required check resolvable
	assert_not_null(Contexts.current_resolvable)
	assert_true(Contexts.current_resolvable is CheckResolvable)
	
	# Check that the card has one recharge action
	var actions := _clockwork_servant.get_available_actions()
	assert_eq(actions.size(), 1)
	assert_eq(actions[0].action_type, Action.RECHARGE)
	
	# Check for +1d6
	var modifier = (actions[0] as PlayCardAction).check_modifier
	var num_d6 = modifier.added_dice.count(6)
	assert_eq(num_d6, 1)

func test_clock_serv_can_recharge_vs_craft():
	pass

func test_clock_serv_can_not_recharge():
	# Set up a new encounter with an item
	TestUtils.setup_encounter("Valeros", "Spyglass")
	Contexts.encounter_context.character.add_to_hand(_clockwork_servant)
	
	# Check that the game pauses when reaching the required check resolvable
	assert_not_null(Contexts.current_resolvable)
	assert_true(Contexts.current_resolvable is CheckResolvable)
	
	# Check that the card doesn't have a recharge action
	var actions := _clockwork_servant.get_available_actions()
	assert_eq(actions.size(), 0)

func test_clock_serv_two_explore_options():
	Contexts.new_turn(TurnContext.new(valeros))
	valeros.add_to_hand(_clockwork_servant)
	
	# Set up the location with a zombie card
	var zombie_data = TestUtils.load_card_data("zombie")
	var zombie_instance = GameServices.cards.new_card(zombie_data)
	valeros.location.shuffle_in(zombie_instance, false)
	
	# Check that we can use the card to explore
	var actions := _clockwork_servant.get_available_actions()
	assert_eq(actions.size(), 2)
	assert_eq(actions[0].action_type, Action.BURY)
	assert_eq(actions[1].action_type, Action.BANISH)
