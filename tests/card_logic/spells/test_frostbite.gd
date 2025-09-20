# test_frostbite.gd
extends BaseTest

var _frostbite: CardInstance

func before_each():
	super()
	_frostbite = TestUtils.get_card("Frostbite")
	ezren.add_to_hand(_frostbite)

func test_frostbite_on_own_check():
	TestUtils.setup_encounter_with_instances(ezren, zombie)
	
	var actions := _frostbite.get_available_actions()
	assert_eq(actions.size(), 1)
	
	GameServices.asm.stage_action(actions[0])
	
	var dice = Contexts.check_context.dice_pool(GameServices.asm.staged_actions)
	assert_eq(dice.to_string(), "1d12 + 2d4 + 2")
	
	var traits = Contexts.check_context.traits
	assert_true(traits.has("Magic"))
	assert_true(traits.has("Arcane"))
	assert_true(traits.has("Divine"))
	assert_true(traits.has("Attack"))
	assert_true(traits.has("Cold"))

func test_frostbite_unusable_on_other_check():
	TestUtils.setup_encounter_with_instances(valeros, zombie)
	
	var actions := _frostbite.get_available_actions()
	assert_eq(actions.size(), 0)

func test_frostbite_reduced_damage_by_one():
	Contexts.new_encounter(EncounterContext.new(ezren, zombie))
	
	var frostbite_action = PlayCardAction.new(_frostbite, Action.BANISH, null)
	frostbite_action.commit()
	
	assert_eq(Contexts.encounter_context.resolvable_modifiers.size(), 1)
	
	var resolvable = DamageResolvable.new(ezren, 2, "Magic")
	Contexts.new_resolvable(resolvable)
	
	assert_eq((Contexts.current_resolvable as DamageResolvable).amount, 1)
