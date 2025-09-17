# test_bracers_of_protection.gd
extends BaseTest

var _bracers_instance: CardInstance

func before_each():
	super()
	# Set up the Bracers of Protection card
	var bracers_data = TestUtils.load_card_data("Bracers Of Protection")
	_bracers_instance = GameServices.cards.new_card(bracers_data, ezren)
	_bracers_instance.current_location = CardLocation.HAND
	ezren.add_to_hand(_bracers_instance)
	ezren.add_to_hand(longsword)
	ezren.add_to_hand(TestUtils.get_card("Frostbite"))


func test_bracers_of_protection_two_actions_combat_damage():
	# Set up damage resolvable for combat damage
	var resolvable = DamageResolvable.new(ezren, 2)
	GameServices.contexts.new_resolvable(resolvable)
	
	var actions := _bracers_instance.get_available_actions()
	assert_eq(actions.size(), 2, "Bracers should have two actions for combat damage")
	assert_eq(actions[0].action_type, Action.REVEAL, "First action should be reveal")
	assert_eq(actions[1].action_type, Action.RECHARGE, "Second action should be recharge")
	
	# Stage reveal action - should prevent commit
	GameServices.asm.stage_action(actions[0])
	assert_false(resolvable.can_commit(GameServices.asm.staged_actions), "Should not be able to commit with just reveal")
	
	# Check available actions after reveal
	actions = _bracers_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one action left after reveal")
	assert_eq(actions[0].action_type, Action.RECHARGE, "Remaining action should be recharge")
	
	# Stage recharge action - should allow commit
	GameServices.asm.stage_action(actions[0])
	assert_true(resolvable.can_commit(GameServices.asm.staged_actions), "Should be able to commit with both actions")


func test_bracers_of_protection_one_action_other_damage():
	# Set up damage resolvable for non-combat damage
	var resolvable = DamageResolvable.new(ezren, 1, "Other")
	GameServices.contexts.new_resolvable(resolvable)
	
	var actions := _bracers_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Bracers should have one action for other damage")
	assert_eq(actions[0].action_type, Action.RECHARGE, "Action should be recharge")
	
	# Stage recharge action - should allow commit
	GameServices.asm.stage_action(actions[0])
	assert_true(resolvable.can_commit(GameServices.asm.staged_actions), "Should be able to commit with recharge")
