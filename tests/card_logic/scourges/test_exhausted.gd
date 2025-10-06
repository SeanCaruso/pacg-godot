# test_exhausted.gd
extends BaseTest

func before_each():
	super()

func test_exhausted_limits_to_one_boon():
	valeros.add_scourge(Scourge.EXHAUSTED)
	valeros.add_to_hand(longsword)
	
	var soldier = TestUtils.get_card("Soldier")
	valeros.add_to_hand(soldier)
	
	var resolvable = CheckResolvable.new(zombie, valeros, zombie.data.check_requirement)
	TaskManager.push(resolvable)
	
	assert_eq(longsword.get_available_actions().size(), 2)
	TaskManager.current_resolvable.stage_action(longsword.get_available_actions()[0])
	
	assert_eq(soldier.get_available_actions().size(), 0)

func test_exhausted_doesnt_limit_same_boon():
	valeros.add_scourge(Scourge.EXHAUSTED)
	valeros.add_to_hand(longsword)
	
	var resolvable = CheckResolvable.new(zombie, valeros, zombie.data.check_requirement)
	TaskManager.push(resolvable)
	
	assert_eq(longsword.get_available_actions().size(), 2)
	TaskManager.current_resolvable.stage_action(longsword.get_available_actions()[0])
	
	assert_eq(longsword.get_available_actions().size(), 1)

func test_exhausted_removal_prompt_on_turn_start():
	valeros.add_scourge(Scourge.EXHAUSTED)
	Contexts.new_turn(TurnContext.new(valeros))
	
	TaskManager.start_task(StartTurnProcessor.new())
	assert_true(TaskManager.current_resolvable is PlayerChoiceResolvable)

func test_exhausted_removed():
	Contexts.new_turn(TurnContext.new(valeros))
	
	valeros.add_scourge(Scourge.EXHAUSTED)
	ScourgeRules.prompt_for_exhausted_removal(valeros)
	
	assert_true(TaskManager.current_resolvable is PlayerChoiceResolvable)
	
	var resolvable = TaskManager.current_resolvable as PlayerChoiceResolvable
	resolvable.options[1].action.call()
	assert_true(valeros.active_scourges.size() == 1)
	assert_true(valeros.active_scourges.has(Scourge.EXHAUSTED))
	
	resolvable.options[0].action.call()
	assert_true(valeros.active_scourges.size() == 0)
