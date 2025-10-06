# test_wounded.gd
extends BaseTest

func before_each():
	super()
	longsword.owner = valeros
	valeros.reload(longsword)
	
	var game_context = GameContext.new(1, null)
	Contexts.new_game(game_context)
	Contexts.new_turn(TurnContext.new(valeros))

func test_wounded_scourged_discards_at_start_of_turn():
	valeros.add_scourge(Scourge.WOUNDED)
	TaskManager.start_task(StartTurnController.new(valeros))
	
	assert_eq(valeros.deck.count, 0)
	assert_eq(valeros.discards.size(), 1)
	assert_eq(valeros.discards[0], longsword)

func test_wounded_removal_prompt_on_heal():
	valeros.add_scourge(Scourge.WOUNDED)
	valeros.heal(1)
	
	assert_true(TaskManager.current_resolvable is PlayerChoiceResolvable)
	
	var resolvable = TaskManager.current_resolvable as PlayerChoiceResolvable
	resolvable.options[1].action.call()

func test_wounded_removed():
	valeros.add_scourge(Scourge.WOUNDED)
	ScourgeRules.prompt_for_wounded_removal(valeros)
	
	assert_true(TaskManager.current_resolvable is PlayerChoiceResolvable)
	
	var resolvable = TaskManager.current_resolvable as PlayerChoiceResolvable
	resolvable.options[1].action.call()
	assert_true(valeros.active_scourges.size() == 1)
	assert_true(valeros.active_scourges.has(Scourge.WOUNDED))
	
	resolvable.options[0].action.call()
	assert_true(valeros.active_scourges.size() == 0)
