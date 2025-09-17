# test_frog.gd
extends BaseTest

# Test subjects
var _frog: CardInstance


func before_each():
	super()
	
	_frog = TestUtils.get_card("Frog")
	ezren.add_to_hand(_frog)


func test_frog_cannot_evade_monster():
	# Set up encounter with Zombie (monster)
	TestUtils.setup_encounter_with_instances(ezren, zombie)
	assert_eq(_frog.get_available_actions().size(), 0, "Frog should have no actions vs monster")


func test_frog_evade_obstacle():
	# Create an Obstacle barrier
	var encounter_data := CardData.new()
	encounter_data.card_type = CardType.BARRIER
	encounter_data.traits.assign(["Obstacle", "Other Trait"])
	var encounter_instance := CardInstance.new(encounter_data)
	
	TestUtils.setup_encounter_with_instances(ezren, encounter_instance)
	
	# Check that the game pauses when reaching an Evade Resolvable
	assert_true(GameServices.contexts.current_resolvable is EvadeResolvable, "Should be evade resolvable")
	
	# Check that the frog has one evade action
	var actions := _frog.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one evade action")
	assert_eq(actions[0].action_type, Action.BURY, "Should be bury action")
	
	# Stage and commit the evade action
	GameServices.asm.stage_action(actions[0])
	GameServices.asm.commit()
	
	# Check that the encounter ends
	assert_null(GameServices.contexts.encounter_context, "Encounter context should be cleared")
	assert_true(GameServices.contexts.current_resolvable is PlayerChoiceResolvable, "Should have player choice resolvable")


func test_frog_evade_trap():
	# Create a Trap barrier
	var encounter_data = CardData.new()
	encounter_data.card_type = CardType.BARRIER
	encounter_data.traits.assign(["Trap", "Other Trait"])
	
	var encounter_instance = CardInstance.new(encounter_data, null)
	
	TestUtils.setup_encounter_with_instances(ezren, encounter_instance)
	
	# Check that the game pauses when reaching an Evade Resolvable
	assert_true(GameServices.contexts.current_resolvable is EvadeResolvable, "Should be evade resolvable")
	
	# Check that the frog has one evade action
	var actions := _frog.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one evade action")
	assert_eq(actions[0].action_type, Action.BURY, "Should be bury action")
	
	# Stage and commit the evade action
	GameServices.asm.stage_action(actions[0])
	GameServices.asm.commit()
	
	# Check that the encounter ends
	assert_null(GameServices.contexts.encounter_context, "Encounter context should be cleared")
	assert_true(GameServices.contexts.current_resolvable is PlayerChoiceResolvable, "Should have player choice resolvable")


func test_frog_explore_ignores_first_scourge():
	# Set up game and location
	GameServices.contexts.new_game(GameContext.new(1, null))
	ezren.location = caravan
	
	GameServices.contexts.new_turn(TurnContext.new(ezren))
	ezren.location.shuffle_in(longsword, true)
	
	var actions := _frog.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one action")
	assert_eq(actions[0].action_type, Action.DISCARD, "Should be discard action")
	
	# Commit the frog action to get explore effect
	_frog.logic.on_commit(actions[0])
	assert_eq(GameServices.contexts.turn_context.explore_effects.size(), 1, "Should have one explore effect")
	assert_true(GameServices.contexts.turn_context.explore_effects[0] is ScourgeImmunityExploreEffect, "Should be scourge immunity effect")
	
	# Test scourge immunity - first scourge should be ignored
	ezren.add_scourge(Scourge.ENTANGLED)
	assert_eq(ezren.active_scourges.size(), 0, "First scourge should be ignored")
	
	# Second scourge should apply normally
	ezren.add_scourge(Scourge.WOUNDED)
	assert_eq(ezren.active_scourges.size(), 1, "Second scourge should apply")
	assert_eq(ezren.active_scourges[0], Scourge.WOUNDED, "Should have Wounded scourge")
