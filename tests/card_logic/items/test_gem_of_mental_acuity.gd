# test_gem_of_mental_acuity.gd
extends BaseTest

var _gem_instance: CardInstance

func before_each():
	super()
	# Set up the Gem of Mental Acuity card
	var gem_data = TestUtils.load_card_data("Gem Of Mental Acuity")
	_gem_instance = Cards.new_card(gem_data, valeros)
	_gem_instance.current_location = CardLocation.HAND


func test_gem_mental_acuity_combat_no_actions():
	# Set up encounter with Zombie (combat check)
	TestUtils.setup_encounter("Valeros", "Zombie")
	Contexts.encounter_context.character.add_to_hand(_gem_instance)
	
	var actions := _gem_instance.get_available_actions()
	assert_eq(actions.size(), 0, "Gem of Mental Acuity should have no actions in combat")


func test_gem_mental_acuity_non_combat_one_action():
	# Set up encounter with Soldier (non-combat check)
	TestUtils.setup_encounter("Valeros", "Soldier")
	Contexts.turn_context.character.add_to_hand(_gem_instance)
	
	var actions := _gem_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Gem of Mental Acuity should have one action for non-combat")


func test_gem_mental_acuity_valeros_d6():
	# Set up encounter with Soldier (non-combat check)
	TestUtils.setup_encounter("Valeros", "Soldier")
	Contexts.turn_context.character.add_to_hand(_gem_instance)
	
	# Default should be Melee
	var dice_pool := (TaskManager.current_resolvable as CheckResolvable).get_staged_dice_pool()
	assert_eq(dice_pool.to_string(), "1d10 + 2", "Default should be Melee dice pool")
	
	var actions := _gem_instance.get_available_actions()
	TaskManager.current_resolvable.stage_action(actions[0])
	dice_pool = (TaskManager.current_resolvable as CheckResolvable).get_staged_dice_pool()
	assert_eq(dice_pool.to_string(), "1d6 + 2", "Gem should change to Intelligence dice (d6)")
