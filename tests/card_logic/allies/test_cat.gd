# test_cat.gd
extends BaseTest

# Test subjects - specific to this test
var _cat_instance: CardInstance

func before_each():
	# Call parent setup first
	super()
	
	# Set up the Cat card specific to this test
	_cat_instance = TestUtils.get_card("Cat")
	valeros.add_to_hand(_cat_instance)


func test_cat_can_recharge_vs_spell():
	# Set up a new encounter with a spell
	TestUtils.setup_encounter("Valeros", "Deflect")
	Contexts.encounter_context.character.add_to_hand(_cat_instance)
	
	# Check that the game pauses when reaching the required check resolvable.
	assert_not_null(Contexts.current_resolvable)
	assert_true(Contexts.current_resolvable is CheckResolvable)
	
	# Check that the Cat has one recharge action.
	var actions := _cat_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Cat should have one action vs. a spell")
	assert_eq(actions[0].action_type, Action.RECHARGE, "Cat should have a recharge action")
	
	var modifier = (actions[0] as PlayCardAction).check_modifier
	var num_d4 = modifier.added_dice.count(4)
	assert_eq(num_d4, 1, "Cat should add 1d4 vs. spell")


func test_cat_cannot_recharge_vs_non_spell():
	# Set up a new encounter with a non-spell
	TestUtils.setup_encounter("Valeros", "Longsword")
	Contexts.encounter_context.character.add_to_hand(_cat_instance)
	
	# Test that Cat doesn't have recharge actions vs non-spell
	var actions = _cat_instance.get_available_actions()
	assert_eq(actions.size(), 0, "Cat should not have recharge actions vs non-spell")


func test_cat_explore_without_magic():
	Contexts.new_turn(TurnContext.new(valeros))
	valeros.add_to_hand(_cat_instance)
	
	valeros.location.shuffle_in(zombie, true)
	
	var actions := _cat_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Cat has one action")
	assert_eq(actions[0].action_type, Action.DISCARD, "Can discard Cat")
	
	GameServices.asm.stage_action(actions[0])
	GameServices.asm.commit()
	
	var effects := Contexts.turn_context.explore_effects
	assert_eq(effects.size(), 1, "One explore effect")
	
	var resolvable := CheckResolvable.new(zombie, valeros, zombie.data.check_requirement)
	var check := CheckContext.new(resolvable)
	var dice_pool := DicePool.new()
	effects[0].apply_to(check, dice_pool)
	assert_eq(dice_pool.num_dice(4), 0, "No added dice vs. zombie")


func test_cat_explore_with_magic():
	Contexts.new_turn(TurnContext.new(valeros))
	valeros.add_to_hand(_cat_instance)
	
	var deflect := TestUtils.get_card("Deflect")
	valeros.location.shuffle_in(deflect, true)
	
	var actions := _cat_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Cat has one action")
	assert_eq(actions[0].action_type, Action.DISCARD, "Can discard Cat")
	
	GameServices.asm.stage_action(actions[0])
	GameServices.asm.commit()
	
	var effects := Contexts.turn_context.explore_effects
	assert_eq(effects.size(), 1, "One explore effect")
	
	var resolvable := CheckResolvable.new(deflect, valeros, deflect.data.check_requirement)
	var check := CheckContext.new(resolvable)
	var dice_pool := DicePool.new()
	effects[0].apply_to(check, dice_pool)
	assert_eq(dice_pool.num_dice(4), 1, "Cat added 1d4 vs. deflect")
