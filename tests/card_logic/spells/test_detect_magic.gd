# test_detect_magic.gd
extends BaseTest

var _detect_magic: CardInstance

func before_each():
	super()
	_detect_magic = TestUtils.get_card("Detect Magic")
	ezren.add_to_hand(_detect_magic)
	
	Contexts.new_game(GameContext.new(1, null))
	ezren.location = caravan


func test_detect_magic_allows_explore_for_magic_card_on_owners_turn():
	# Start Ezren's turn
	Contexts.new_turn(TurnContext.new(ezren))
	
	var frostbite = TestUtils.get_card("Frostbite")
	caravan.shuffle_in(frostbite, true)
	
	var actions := _detect_magic.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one action")
	
	_detect_magic.logic.on_commit(actions[0])
	TaskManager.process()
	assert_true(TaskManager.current_resolvable is ExamineResolvable, "Should have examine resolvable")
	
	var resolvable = TaskManager.current_resolvable as ExamineResolvable
	assert_not_null(resolvable, "Examine resolvable should not be null")
	
	TaskManager.resolve_current()
	assert_true(TaskManager.current_resolvable is PlayerChoiceResolvable, "Should have player choice resolvable")
	
	var explore_resolvable = TaskManager.current_resolvable as PlayerChoiceResolvable
	assert_not_null(explore_resolvable, "Explore resolvable should not be null")
	assert_eq(explore_resolvable.prompt, "Explore?", "Should ask about exploration")


func test_detect_magic_allows_shuffle_for_non_magic_card():
	caravan.shuffle_in(zombie, true)
	
	var actions := _detect_magic.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one action")
	
	_detect_magic.logic.on_commit(actions[0])
	TaskManager.process()
	assert_true(TaskManager.current_resolvable is ExamineResolvable, "Should have examine resolvable")
	
	var resolvable = TaskManager.current_resolvable as ExamineResolvable
	assert_not_null(resolvable, "Examine resolvable should not be null")
	
	TaskManager.resolve_current()
	assert_true(TaskManager.current_resolvable is PlayerChoiceResolvable, "Should have player choice resolvable")
	
	var shuffle_resolvable = TaskManager.current_resolvable as PlayerChoiceResolvable
	assert_not_null(shuffle_resolvable, "Shuffle resolvable should not be null")
	assert_eq(shuffle_resolvable.prompt, "Shuffle?", "Should ask about shuffling")


func test_detect_magic_allows_explore_for_magic_card_on_another_turn():
	# Start Valeros's turn instead of Ezren's
	Contexts.new_turn(TurnContext.new(valeros))
	
	var frostbite = TestUtils.get_card("Frostbite")
	ezren.location.shuffle_in(frostbite, true)
	
	var actions := _detect_magic.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one action")
	
	_detect_magic.logic.on_commit(actions[0])
	TaskManager.process()
	assert_true(TaskManager.current_resolvable is ExamineResolvable, "Should have examine resolvable")
	
	var resolvable = TaskManager.current_resolvable as ExamineResolvable
	assert_not_null(resolvable, "Examine resolvable should not be null")
	
	TaskManager.resolve_current()
	assert_true(TaskManager.current_resolvable is PlayerChoiceResolvable, "Should have player choice resolvable")
	
	var explore_resolvable = TaskManager.current_resolvable as PlayerChoiceResolvable
	assert_not_null(explore_resolvable, "Explore resolvable should not be null")
	assert_eq(explore_resolvable.prompt, "Explore?", "Should ask about exploration")
