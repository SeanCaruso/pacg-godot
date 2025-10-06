# test_rumble_road.gd
extends BaseTest

var _data: ScenarioData

func before_each():
	super()
	_data = TestUtils.get_scenario("1S Rumble Road")
	Contexts.new_game(GameContext.new(1, _data))
	valeros.location = caravan
	Contexts.new_turn(TurnContext.new(valeros))

func test_rumble_road_heal_power_available():
	valeros.discard(longsword)
	valeros.location.shuffle_in(zombie, true)
	
	var processor = StartTurnProcessor.new()
	processor.execute()
	
	assert_true(Contexts.game_context.scenario_logic.has_available_actions())
	assert_true(Contexts.turn_context.has_scenario_turn_action)
	assert_true(Contexts.turn_context.can_use_scenario_turn_action)

func test_rumble_road_dire_wolf_allows_close():
	# Setup puts Valeros at the Caravan
	var dire_wolf = TestUtils.get_card("Dire Wolf")
	Contexts.new_encounter(EncounterContext.new(valeros, dire_wolf))
	
	Contexts.encounter_context.check_result = CheckResult.new(
		1, 0, valeros, true, Skill.MELEE, [])
	var processor = EndEncounterProcessor.new()
	processor.execute()
	
	assert_true(TaskManager.current_resolvable is PlayerChoiceResolvable)
	var resolvable = TaskManager.current_resolvable as PlayerChoiceResolvable
	assert_eq(resolvable.prompt, "Close location?")
	assert_eq(resolvable.options.size(), 2)
	assert_eq(resolvable.options[0].label, "Close")
	assert_eq(resolvable.options[1].label, "Skip")
