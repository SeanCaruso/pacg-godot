# test_entangled.gd
extends BaseTest

var _location1: Location
var _location2: Location

func before_each():
	super()
	# Set up additional locations
	_location1 = TestUtils.get_location("Caravan")
	_location2 = TestUtils.get_location("Caravan")  # Using same data for simplicity
	
	var game_context := GameContext.new(1, null)
	game_context.characters.append(valeros)
	game_context.locations.append_array([_location1, _location2])
	valeros.location = _location1
	Contexts.new_game(game_context)


func test_entangled_unscourged_doesnt_prevent_move():
	# Start turn without Entangled scourge
	TaskManager.start_task(StartTurnController.new(valeros))
	assert_true(Contexts.turn_context.can_move, "Should be able to move when not entangled")


func test_entangled_scourged_prevents_move():
	# Add Entangled scourge and start turn
	valeros.add_scourge(Scourge.ENTANGLED)
	TaskManager.start_task(StartTurnController.new(valeros))
	assert_false(Contexts.turn_context.can_move, "Should not be able to move when entangled")


func test_entangled_unscourged_doesnt_prevent_evasion():
	# Start turn and encounter without Entangled
	Contexts.new_turn(TurnContext.new(valeros))
	
	var encounter = EncounterContext.new(valeros, zombie)
	encounter.explore_effects.append(EvadeExploreEffect.new())
	Contexts.new_encounter(encounter)
	
	TaskManager.start_task(EvasionEncounterProcessor.new())
	assert_true(TaskManager.current_resolvable is PlayerChoiceResolvable, "Should have evasion choice")
	
	var resolvable = TaskManager.current_resolvable as PlayerChoiceResolvable
	assert_eq(resolvable.prompt, "Evade?", "Should ask about evasion")


func test_entangled_scourged_prevents_evasion():
	# Add Entangled scourge and test evasion prevention
	valeros.add_scourge(Scourge.ENTANGLED)
	Contexts.new_turn(TurnContext.new(valeros))
	
	var encounter = EncounterContext.new(valeros, zombie)
	encounter.explore_effects.append(EvadeExploreEffect.new())
	Contexts.new_encounter(encounter)
	
	TaskManager.start_task(EvasionEncounterProcessor.new())
	assert_true(TaskManager.current_resolvable is FreePlayResolvable, "Should be in free play")


func test_entangled_location_close_removes():
	# Add Entangled scourge and close location
	valeros.add_scourge(Scourge.ENTANGLED)
	valeros.location.close()
	
	assert_eq(valeros.active_scourges.size(), 0, "Entangled should be removed when location closes")
