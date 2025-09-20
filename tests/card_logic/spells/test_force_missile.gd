# test_force_missile.gd
extends BaseTest

var _force_missile: CardInstance

func before_each():
	super()
	_force_missile = TestUtils.get_card("Force Missile")
	ezren.add_to_hand(_force_missile)


func test_force_missile_on_own_check():
	# Set up encounter with Ezren vs Zombie
	TestUtils.setup_encounter_with_instances(ezren, zombie)
	
	var actions := _force_missile.get_available_actions()
	assert_eq(actions.size(), 1, "Force Missile should have one action")
	
	GameServices.asm.stage_action(actions[0])
	
	var dice = Contexts.check_context.dice_pool(GameServices.asm.staged_actions)
	assert_eq(dice.to_string(), "1d12 + 2d4 + 2", "Should use Ezren's Arcane die")
	
	var traits = Contexts.check_context.traits
	assert_true(traits.has("Magic"), "Should have Magic trait")
	assert_true(traits.has("Arcane"), "Should have Arcane trait")
	assert_true(traits.has("Attack"), "Should have Attack trait")
	assert_true(traits.has("Force"), "Should have Force trait")


func test_force_missile_on_other_check():
	# Set up encounter with Valeros vs Zombie
	TestUtils.setup_encounter_with_instances(valeros, zombie)
	
	var actions := _force_missile.get_available_actions()
	assert_eq(actions.size(), 1, "Force Missile should have one action")
	
	GameServices.asm.stage_action(actions[0])
	
	var dice = Contexts.check_context.dice_pool(GameServices.asm.staged_actions)
	assert_eq(dice.to_string(), "1d10 + 2d4 + 2", "Should use Valeros's Melee die")
	
	var traits = Contexts.check_context.traits
	assert_true(traits.has("Magic"), "Should have Magic trait")
	assert_false(traits.has("Arcane"), "Should not have Arcane trait (not Ezren)")
	assert_true(traits.has("Attack"), "Should have Attack trait")
	assert_true(traits.has("Force"), "Should have Force trait")
