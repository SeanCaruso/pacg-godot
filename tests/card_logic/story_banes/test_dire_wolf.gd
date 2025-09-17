# test_dire_wolf.gd
extends BaseTest

func before_each():
	super()

func test_dire_wolf_prevents_evasion():
	GameServices.contexts.new_turn(TurnContext.new(valeros))
	
	var dire_wolf = TestUtils.get_card("Dire Wolf")
	
	var encounter = EncounterContext.new(valeros, dire_wolf)
	encounter.explore_effects.append(EvadeExploreEffect.new())
	GameServices.contexts.new_encounter(encounter)
	
	GameServices.game_flow.start_phase(EvasionEncounterProcessor.new(), "Evasion")
	assert_null(GameServices.contexts.current_resolvable)

func test_dire_wolf_adds_damage():
	var dire_wolf = TestUtils.get_card("Dire Wolf")
	for i in range(100):
		GameServices.contexts.new_encounter(EncounterContext.new(valeros, dire_wolf))
		dire_wolf.logic.on_encounter()
		
		const base_damage = 1
		var resolvable = DamageResolvable.new(valeros, base_damage)
		GameServices.contexts.new_resolvable(resolvable)
		
		assert_true(resolvable.amount >= base_damage + 1)
		assert_true(resolvable.amount <= base_damage + 4)
