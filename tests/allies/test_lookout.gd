# test_lookout.gd
extends BaseTest

# Test subjects
var _lookout: CardInstance

func before_each():
	super()
	
	_lookout = TestUtils.get_card("Lookout")

func test_lookout_combat_no_actions():
	TestUtils.setup_encounter("Valeros", "Zombie")
	GameServices.contexts.encounter_context.character.add_to_hand(_lookout)
	
	var actions := _lookout.get_available_actions()
	assert_eq(actions.size(), 0)

func test_lookout_combat_one_action():
	TestUtils.setup_encounter("Valeros", "Dire Badger")
	GameServices.contexts.encounter_context.character.add_to_hand(_lookout)
	
	var actions := _lookout.get_available_actions()
	assert_eq(actions.size(), 1)
	
	GameServices.asm.stage_action(actions[0])
	
	var dice_pool = GameServices.contexts.check_context.dice_pool(GameServices.asm.staged_actions)
	assert_eq(dice_pool.to_string(), "2d4")

func test_lookout_not_usable_during_damage():
	valeros.add_to_hand(_lookout)
	
	var damage = DamageResolvable.new(valeros, 1, "Magic")
	GameServices.contexts.new_resolvable(damage)
	
	var actions := _lookout.get_available_actions()
	assert_eq(actions.size(), 0)
