# test_rescue.gd
extends BaseTest

var _rescue: CardInstance

func before_each():
	super()
	_rescue = TestUtils.get_card("Rescue")

func test_rescue_can_recharge_allies():
	TestUtils.setup_encounter_with_instances(valeros, _rescue)
	
	var soldier = TestUtils.get_card("Soldier")
	valeros.add_to_hand(soldier)
	var sage = TestUtils.get_card("Sage")
	valeros.add_to_hand(sage)
	var cat = TestUtils.get_card("Cat")
	valeros.add_to_hand(cat)
	
	var soldier_actions := _rescue.get_additional_actions_for_card(soldier)
	assert_eq(soldier_actions.size(), 1)
	var soldier_action = soldier_actions[0] as PlayCardAction
	assert_not_null(soldier_action)
	assert_eq(soldier_action.check_modifier.added_dice.size(), 1)
	assert_eq(soldier_action.check_modifier.added_dice[0], 4)
	assert_true(soldier_action.action_data.get("IsFreely", false))
	GameServices.asm.stage_action(soldier_action)
	assert_eq(GameServices.asm.staged_actions.size(), 1)
	
	var sage_actions := _rescue.get_additional_actions_for_card(sage)
	assert_eq(sage_actions.size(), 1)
	var sage_action = sage_actions[0] as PlayCardAction
	assert_not_null(sage_action)
	assert_eq(sage_action.check_modifier.added_dice.size(), 1)
	assert_eq(sage_action.check_modifier.added_dice[0], 4)
	assert_true(sage_action.action_data.get("IsFreely", false))
	GameServices.asm.stage_action(sage_action)
	assert_eq(GameServices.asm.staged_actions.size(), 2)
	
	var cat_actions := _rescue.get_additional_actions_for_card(cat)
	assert_eq(cat_actions.size(), 1)
	var cat_action = cat_actions[0] as PlayCardAction
	assert_not_null(cat_action)
	assert_eq(cat_action.check_modifier.added_dice.size(), 1)
	assert_eq(cat_action.check_modifier.added_dice[0], 4)
	assert_true(cat_action.action_data.get("IsFreely", false))
	GameServices.asm.stage_action(cat_action)
	assert_eq(GameServices.asm.staged_actions.size(), 3)
	
	var dice_pool = GameServices.contexts.check_context.dice_pool(GameServices.asm.staged_actions)
	# Valeros should default to Melee (1d10 + 2) and have 3 ally dice
	assert_eq(dice_pool.to_string(), "1d10 + 3d4 + 2")
