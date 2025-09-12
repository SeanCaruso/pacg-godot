# test_cat.gd
extends GutTest

const Action := preload("res://scripts/core/enums/action_type.gd").Action
const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const CardType := preload("res://scripts/core/enums/card_type.gd").CardType

# Test subjects
var _cat_data: CardData
var _cat_instance: CardInstance
var _valeros_data: CharacterData
var _valeros: PlayerCharacter


func before_each():
	# GUT's equivalent of [SetUp] - runs before each test
	GameServices._initialize_game_systems()
	
	# Create a basic game context
	var game_context = GameContext.new(1, null)  # Adjust constructor as needed
	GameServices.contexts.new_game(game_context)
	
	# Load test data
	_valeros_data = TestUtils.load_card_data("Valeros") as CharacterData
	_valeros = PlayerCharacter.new(_valeros_data)
	
	# Set up a basic location for testing
	var location_data = LocationData.new()
	location_data.card_name = "Test Location"
	var location = Location.new(location_data)
	_valeros.location = location
	
	# Set up the Cat card
	_cat_data = TestUtils.load_card_data("Cat")
	_cat_instance = GameServices.cards.new_card(_cat_data, _valeros)
	_cat_instance.current_location = CardLocation.HAND


func after_each():
	# GUT's equivalent of [TearDown] - runs after each test
	if GameServices.contexts.check_context:
		GameServices.contexts.end_check()
	if GameServices.contexts.current_resolvable:
		GameServices.contexts.end_resolvable()
	if GameServices.contexts.encounter_context:
		GameServices.contexts.end_encounter()
	if GameServices.contexts.turn_context:
		GameServices.contexts.end_turn()


func test_cat_can_recharge_vs_spell():
	# Set up a new encounter with a spell
	TestUtils.setup_encounter("Valeros", "Deflect")
	GameServices.contexts.encounter_context.character.add_to_hand(_cat_instance)
	
	# Check that the game pauses when reaching the required check resolvable.
	assert_not_null(GameServices.contexts.current_resolvable)
	assert_true(GameServices.contexts.current_resolvable is CheckResolvable)
	
	# Check that the Cat has one recharge action.
	var actions := _cat_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Cat should have one action vs. a spell")
	assert_eq(actions[0].action_type, Action.RECHARGE, "Cat should have a recharge action")
	
	var modifier = (actions[0] as PlayCardAction).check_modifier
	var num_d4 = modifier.added_dice.count(4)
	assert_eq(num_d4, 1, "Cat should add 1d4 vs. spell")


func test_cat_cannot_recharge_vs_non_spell():
	# Set up a new encounter with a non-spell
	TestUtils.setup_encounter("Valeros", "Longsword")
	GameServices.contexts.encounter_context.character.add_to_hand(_cat_instance)
	
	# Test that Cat doesn't have recharge actions vs non-spell
	var actions = _cat_instance.get_available_actions()
	assert_eq(actions.size(), 0, "Cat should not have recharge actions vs non-spell")


func test_cat_explore_without_magic():
	GameServices.contexts.new_turn(TurnContext.new(_valeros))
	_valeros.add_to_hand(_cat_instance)
	
	var zombie := TestUtils.get_card("Zombie")
	_valeros.location.shuffle_in(zombie, true)
	
	var actions := _cat_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Cat has one action")
	assert_eq(actions[0].action_type, Action.DISCARD, "Can discard Cat")
	
	GameServices.asm.stage_action(actions[0])
	GameServices.asm.commit()
	
	var effects := GameServices.contexts.turn_context.explore_effects
	assert_eq(effects.size(), 1, "One explore effect")
	
	var resolvable := CheckResolvable.new(zombie, _valeros, zombie.data.check_requirement)
	var check := CheckContext.new(resolvable)
	var dice_pool := DicePool.new()
	effects[0].apply_to(check, dice_pool)
	assert_eq(dice_pool.num_dice(4), 0, "No added dice vs. zombie")


func test_cat_explore_with_magic():
	GameServices.contexts.new_turn(TurnContext.new(_valeros))
	_valeros.add_to_hand(_cat_instance)
	
	var deflect := TestUtils.get_card("Deflect")
	_valeros.location.shuffle_in(deflect, true)
	
	var actions := _cat_instance.get_available_actions()
	assert_eq(actions.size(), 1, "Cat has one action")
	assert_eq(actions[0].action_type, Action.DISCARD, "Can discard Cat")
	
	GameServices.asm.stage_action(actions[0])
	GameServices.asm.commit()
	
	var effects := GameServices.contexts.turn_context.explore_effects
	assert_eq(effects.size(), 1, "One explore effect")
	
	var resolvable := CheckResolvable.new(deflect, _valeros, deflect.data.check_requirement)
	var check := CheckContext.new(resolvable)
	var dice_pool := DicePool.new()
	effects[0].apply_to(check, dice_pool)
	assert_eq(dice_pool.num_dice(4), 1, "Cat added 1d4 vs. deflect")
