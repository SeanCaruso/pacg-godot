# test_longsword.gd
extends BaseTest

# Test subjects - specific to this test
var _longsword: CardInstance

func before_each():
	# Call parent setup first
	super()
	
	# Set up longsword specific to this test
	_longsword = TestUtils.get_card("longsword")


func test_longsword_logic_setup_was_successful():
	assert_not_null(_longsword.data, "Longsword data should not be null")
	assert_eq(_longsword.data.card_name, "Longsword", "Should have correct card name")
	assert_eq(_longsword.data.card_type, CardType.WEAPON, "Should be weapon type")
	
	assert_not_null(valeros.data, "Valeros character data should not be null")
	assert_eq(valeros.data.character_name, "Valeros", "Should have correct character name")
	assert_true(valeros.is_proficient(_longsword), "Valeros should be proficient with longsword")


func test_longsword_combat_proficient_actions():
	# Set up encounter with Zombie (combat)
	TestUtils.setup_encounter("valeros", "zombie")
	Contexts.encounter_context.character.add_to_hand(longsword)
	
	# Before staging, a proficient PC has two actions
	var actions := longsword.get_available_actions()
	assert_eq(actions.size(), 2, "Should have two actions")
	assert_eq(actions[0].action_type, Action.REVEAL, "First action should be reveal")
	assert_eq(actions[1].action_type, Action.RELOAD, "Second action should be reload")
	
	# After staging, a proficient PC has one action
	GameServices.asm.stage_action(actions[0])
	actions = longsword.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one action after staging")
	assert_eq(actions[0].action_type, Action.RELOAD, "Remaining action should be reload")


func test_longsword_reveal_then_reload():
	# Set up encounter with Zombie
	TestUtils.setup_encounter("valeros", "zombie")
	Contexts.encounter_context.character.add_to_hand(_longsword)
	
	var actions := _longsword.get_available_actions()
	GameServices.asm.stage_action(actions[0])
	
	var staged_pool := GameServices.asm.get_staged_dice_pool()
	assert_eq(staged_pool.num_dice(12), 0, "Should have no d12s")
	assert_eq(staged_pool.num_dice(10), 1, "Should have 1 d10")
	assert_eq(staged_pool.num_dice(8), 1, "Should have 1 d8")
	assert_eq(staged_pool.num_dice(6), 0, "Should have no d6s")
	assert_eq(staged_pool.num_dice(4), 0, "Should have no d4s")
	
	actions = _longsword.get_available_actions()
	GameServices.asm.stage_action(actions[0])
	staged_pool = GameServices.asm.get_staged_dice_pool()
	assert_eq(staged_pool.num_dice(12), 0, "Should have no d12s")
	assert_eq(staged_pool.num_dice(10), 1, "Should have 1 d10")
	assert_eq(staged_pool.num_dice(8), 1, "Should have 1 d8")
	assert_eq(staged_pool.num_dice(6), 0, "Should have no d6s")
	assert_eq(staged_pool.num_dice(4), 1, "Should have 1 d4 after reload")


func test_longsword_reload():
	# Set up encounter with Zombie
	TestUtils.setup_encounter("valeros", "zombie")
	Contexts.encounter_context.character.add_to_hand(_longsword)
	
	var actions := _longsword.get_available_actions()
	GameServices.asm.stage_action(actions[1])  # Stage reload action
	
	var staged_pool := GameServices.asm.get_staged_dice_pool()
	assert_eq(staged_pool.num_dice(12), 0, "Should have no d12s")
	assert_eq(staged_pool.num_dice(10), 1, "Should have 1 d10")
	assert_eq(staged_pool.num_dice(8), 1, "Should have 1 d8")
	assert_eq(staged_pool.num_dice(6), 0, "Should have no d6s")
	assert_eq(staged_pool.num_dice(4), 1, "Should have 1 d4 from reload")


func test_longsword_adds_traits():
	# Set up encounter with Zombie
	TestUtils.setup_encounter("valeros", "zombie")
	Contexts.encounter_context.character.add_to_hand(_longsword)
	
	var actions := _longsword.get_available_actions()
	GameServices.asm.stage_action(actions[0])
	
	for card_trait in _longsword.traits:
		assert_true(Contexts.check_context.invokes([card_trait]), "Should invoke trait: " + card_trait)


func test_longsword_not_usable_during_damage():
	valeros.add_to_hand(_longsword)
	
	var damage = DamageResolvable.new(valeros, 1, "Magic")
	Contexts.new_resolvable(damage)
	
	var actions := _longsword.get_available_actions()
	assert_eq(actions.size(), 0, "Should have no actions during damage resolvable")
