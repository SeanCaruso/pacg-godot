# test_lightning_touch.gd
extends BaseTest

var _lightning_touch: CardInstance

func before_each():
	super()
	_lightning_touch = TestUtils.get_card("Lightning Touch")
	ezren.add_to_hand(_lightning_touch)

func test_lightning_touch_on_own_check():
	TestUtils.setup_encounter_with_instances(ezren, zombie)
	
	var actions := _lightning_touch.get_available_actions()
	assert_eq(actions.size(), 1)
	
	TaskManager.current_resolvable.stage_action(actions[0])
	
	var dice = Contexts.check_context.dice_pool(TaskManager.current_resolvable.staged_actions)
	assert_eq(dice.to_string(), "1d12 + 2d4 + 2")
	
	var traits = Contexts.check_context.traits
	assert_true(traits.has("Magic"))
	assert_true(traits.has("Arcane"))
	assert_true(traits.has("Attack"))
	assert_true(traits.has("Electricity"))

func test_lightning_touch_unusable_on_other_check():
	TestUtils.setup_encounter_with_instances(valeros, zombie)
	
	var actions := _lightning_touch.get_available_actions()
	assert_eq(actions.size(), 0)

func test_lightning_touch_disables_monster_after_acting():
	# TODO: Implement this when we have a monster with after-acting powers.
	pass
