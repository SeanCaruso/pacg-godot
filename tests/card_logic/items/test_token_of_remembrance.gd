# test_token_of_remembrance.gd
extends BaseTest

var _token_instance: CardInstance
var _frostbite: CardInstance

func before_each():
	super()
	# Set up the Token of Remembrance card
	var token_data = TestUtils.load_card_data("Token Of Remembrance")
	_token_instance = GameServices.cards.new_card(token_data, ezren)
	_token_instance.current_location = CardLocation.HAND
	ezren.add_to_hand(_token_instance)
	
	# Set up Frostbite spell
	_frostbite = TestUtils.get_card("Frostbite")
	_frostbite.owner = ezren


func test_token_of_remembrance_recharge_for_spell():
	# Put Frostbite in recovery
	_frostbite.current_location = CardLocation.RECOVERY
	
	# Start recovery phase
	var processor = RecoveryTurnProcessor.new()
	Contexts.new_turn(TurnContext.new(ezren))
	processor.execute()
	
	# Should have a choice to recharge or not
	assert_true(Contexts.current_resolvable is PlayerChoiceResolvable, "Should have choice resolvable")
	var resolvable = Contexts.current_resolvable as PlayerChoiceResolvable
	Contexts.end_resolvable()
	resolvable.options[0].action.call()
	GameServices.game_flow.process()
	
	# Token should now have recharge action
	var actions := _token_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Token should have one action")
	assert_eq(actions[0].action_type, Action.RECHARGE, "Token should have recharge action")
	
	var modifier = (actions[0] as PlayCardAction).check_modifier
	assert_not_null(modifier, "Recharge action should have modifier")
	assert_eq(modifier.added_dice.size(), 1, "Should add one die")
	assert_eq(modifier.added_dice[0], 8, "Should add d8")


func test_token_of_remembrance_no_recharge_for_non_spell():
	# Put Clockwork Servant (non-spell) in recovery
	var clockwork_servant = TestUtils.get_card("Clockwork Servant")
	clockwork_servant.owner = ezren
	clockwork_servant.current_location = CardLocation.RECOVERY
	
	# Start recovery phase
	var processor = RecoveryTurnProcessor.new()
	Contexts.new_turn(TurnContext.new(ezren))
	processor.execute()
	
	var actions := _token_instance.get_available_actions()
	assert_eq(actions.size(), 0, "Token should have no actions for non-spell")


func test_token_of_remembrance_no_actions_with_no_discarded_spell():
	# Discard a non-spell
	var soldier = TestUtils.get_card("Soldier")
	ezren.discard(soldier)
	
	var actions := _token_instance.get_available_actions()
	assert_eq(actions.size(), 0, "Token should have no actions without discarded spell")


func test_token_of_remembrance_reloads_discarded_spell():
	# Discard Frostbite
	ezren.discard(_frostbite)
	
	var actions := _token_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Token should have one action")
	assert_eq(actions[0].action_type, Action.BURY, "Token should have bury action")
	
	# Commit the bury action
	_token_instance.logic.on_commit(actions[0])
	assert_true(Contexts.current_resolvable is TokenOfRemembranceResolvable, "Should have token resolvable")
	
	# Check that we can reload the spell
	var reload_actions := Contexts.current_resolvable.get_additional_actions_for_card(_frostbite)
	assert_eq(reload_actions.size(), 1, "Should have reload action for spell")
	assert_eq(reload_actions[0].action_type, Action.RELOAD, "Should be reload action")
