# test_dire_wolf.gd
extends BaseTest

func before_each():
	super()

func test_dire_wolf_prevents_evasion():
	Contexts.new_turn(TurnContext.new(valeros))
	
	var dire_wolf = TestUtils.get_card("Dire Wolf")
	
	var encounter = EncounterContext.new(valeros, dire_wolf)
	encounter.explore_effects.append(EvadeExploreEffect.new())
	Contexts.new_encounter(encounter)
	
	TaskManager.start_task(EvasionEncounterProcessor.new())
	assert_true(TaskManager.current_resolvable is FreePlayResolvable, "Should be in free play")

func test_dire_wolf_adds_damage():
	var dire_wolf = TestUtils.get_card("Dire Wolf")
	for i in range(100):
		Contexts.new_encounter(EncounterContext.new(valeros, dire_wolf))
		dire_wolf.logic.on_encounter()
		
		const base_damage = 1
		var resolvable = DamageResolvable.new(valeros, base_damage)
		TaskManager.push(resolvable)
		
		assert_true(resolvable.amount >= base_damage + 1)
		assert_true(resolvable.amount <= base_damage + 4)
