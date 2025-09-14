# test_quarterstaff.gd
extends BaseTest

# Test subjects
var _quarterstaff: CardInstance

func before_each():
	super()
	
	_quarterstaff = TestUtils.get_card("Quarterstaff")
	valeros.add_to_hand(_quarterstaff)


func test_quarterstaff_combat_proficient_actions():
	# Set up encounter with Zombie (combat)
	TestUtils.setup_encounter("Valeros", "Zombie")
	GameServices.contexts.encounter_context.character.add_to_hand(_quarterstaff)
	
	# Before staging, any PC has two actions
	var actions := _quarterstaff.get_available_actions()
	assert_eq(actions.size(), 2, "Should have two actions")
	assert_eq(actions[0].action_type, Action.REVEAL, "First action should be reveal")
	assert_eq(actions[1].action_type, Action.DISCARD, "Second action should be discard")
	
	# After staging, any PC has one action
	GameServices.asm.stage_action(actions[0])
	actions = _quarterstaff.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one action after staging")
	assert_eq(actions[0].action_type, Action.DISCARD, "Remaining action should be discard")


func test_quarterstaff_evade_obstacle():
	# Set up a new encounter with an Obstacle barrier
	GameServices.contexts.new_turn(TurnContext.new(valeros))
	
	var encounter_data = CardData.new()
	encounter_data.card_type = CardType.BARRIER
	encounter_data.traits.assign(["Obstacle", "Other Trait"])
	
	var encounter_instance = CardInstance.new(encounter_data, null)
	
	GameServices.contexts.new_encounter(EncounterContext.new(valeros, encounter_instance))
	
	# Start the encounter
	GameServices.game_flow.start_phase(EncounterController.new(valeros, encounter_instance), "Encounter")
	
	# Check that the game pauses when reaching an EvadeResolvable
	assert_not_null(GameServices.contexts.current_resolvable, "Should have current resolvable")
	assert_true(GameServices.contexts.current_resolvable is EvadeResolvable, "Should be evade resolvable")
	
	# Check that the quarterstaff has one evade action
	var actions := _quarterstaff.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one evade action")
	assert_eq(actions[0].action_type, Action.DISCARD, "Should be discard action")
	
	# Stage and commit the evade action
	GameServices.asm.stage_action(actions[0])
	GameServices.asm.commit()
	
	# Check that the encounter ends
	assert_null(GameServices.contexts.current_resolvable, "Should have no current resolvable")
	assert_null(GameServices.contexts.encounter_context, "Encounter context should be cleared")


func test_quarterstaff_evade_trap():
	# Set up a new encounter with a Trap barrier
	GameServices.contexts.new_turn(TurnContext.new(valeros))
	
	var encounter_data = CardData.new()
	encounter_data.card_type = CardType.BARRIER
	encounter_data.traits.assign(["Trap", "Other Trait"])
	
	var encounter_instance = CardInstance.new(encounter_data, null)
	
	GameServices.contexts.new_encounter(EncounterContext.new(valeros, encounter_instance))
	
	# Start the encounter
	GameServices.game_flow.start_phase(EncounterController.new(valeros, encounter_instance), "Encounter")
	
	# Check that the game pauses when reaching an EvadeResolvable
	assert_not_null(GameServices.contexts.current_resolvable, "Should have current resolvable")
	assert_true(GameServices.contexts.current_resolvable is EvadeResolvable, "Should be evade resolvable")
	
	# Check that the quarterstaff has one evade action
	var actions := _quarterstaff.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one evade action")
	assert_eq(actions[0].action_type, Action.DISCARD, "Should be discard action")
	
	# Stage and commit the evade action
	GameServices.asm.stage_action(actions[0])
	GameServices.asm.commit()
	
	# Check that the encounter ends
	assert_null(GameServices.contexts.current_resolvable, "Should have no current resolvable")
	assert_null(GameServices.contexts.encounter_context, "Encounter context should be cleared")


func test_quarterstaff_no_evade_non_obstacle_or_trap():
	# Set up a new encounter with a barrier that's neither Obstacle nor Trap
	GameServices.contexts.new_turn(TurnContext.new(valeros))
	
	var encounter_data = CardData.new()
	encounter_data.card_type = CardType.BARRIER
	encounter_data.traits.assign(["Not a Trap", "Not an Obstacle"])
	
	var check_requirement = CheckRequirement.new()
	check_requirement.mode = CheckRequirement.CheckMode.SINGLE
	var check_step = CheckStep.new()
	check_step.category = CheckStep.CheckCategory.SKILL
	check_step.allowed_skills.assign([])
	check_requirement.check_steps.assign([check_step])
	encounter_data.check_requirement = check_requirement
	
	var encounter_instance = CardInstance.new(encounter_data, null)
	
	GameServices.contexts.new_encounter(EncounterContext.new(valeros, encounter_instance))
	
	# Start the encounter
	GameServices.game_flow.start_phase(EncounterController.new(valeros, encounter_instance), "Encounter")
	
	# Check that the game pauses when reaching a CheckResolvable, not EvadeResolvable
	assert_not_null(GameServices.contexts.current_resolvable, "Should have current resolvable")
	assert_true(GameServices.contexts.current_resolvable is CheckResolvable, "Should be check resolvable")
	
	# Check that the quarterstaff has no evade actions
	var actions := _quarterstaff.get_available_actions()
	assert_eq(actions.size(), 0, "Should have no evade actions for invalid barrier")
