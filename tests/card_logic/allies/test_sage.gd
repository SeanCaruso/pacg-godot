# test_sage.gd
extends BaseTest

# Test subjects
var _sage: CardInstance

func before_each():
	super()
	
	_sage = TestUtils.get_card("Sage")
	ezren.add_to_hand(_sage)

func test_sage_no_actions_combat():
	TestUtils.setup_encounter_with_instances(ezren, zombie)
	var frostbite = TestUtils.get_card("Frostbite")
	ezren.add_to_hand(frostbite)
	GameServices.asm.stage_action(frostbite.get_available_actions()[0])
	
	assert_eq(Contexts.check_context.used_skill, Skill.ARCANE)
	
	var actions := _sage.get_available_actions()
	assert_eq(actions.size(), 0)

func test_sage_no_actions_non_arcane_knowledge_skill():
	var soldier = TestUtils.get_card("Soldier")
	TestUtils.setup_encounter_with_instances(ezren, soldier)
	
	assert_true(Contexts.check_context.is_skill_valid)
	
	var actions := _sage.get_available_actions()
	assert_eq(actions.size(), 0)

func test_sage_adds_to_own_arcane_skill_check():
	var frostbite = TestUtils.get_card("Frostbite")
	TestUtils.setup_encounter_with_instances(ezren, frostbite)
	
	var actions := _sage.get_available_actions()
	assert_eq(actions.size(), 1)
	assert_eq(actions[0].action_type, Action.RECHARGE)
	
	var mod = (actions[0] as PlayCardAction).check_modifier
	assert_eq(mod.added_dice.size(), 1)
	assert_eq(mod.added_dice[0], 6)

func test_sage_adds_to_own_knowledge_skill_check():
	var codex = TestUtils.get_card("Codex")
	TestUtils.setup_encounter_with_instances(ezren, codex)
	
	var actions := _sage.get_available_actions()
	assert_eq(actions.size(), 1)
	assert_eq(actions[0].action_type, Action.RECHARGE)
	
	var mod = (actions[0] as PlayCardAction).check_modifier
	assert_eq(mod.added_dice.size(), 1)
	assert_eq(mod.added_dice[0], 6)

func test_sage_adds_to_local_arcane_skill_check():
	var frostbite = TestUtils.get_card("Frostbite")
	TestUtils.setup_encounter_with_instances(valeros, frostbite)
	ezren.location = valeros.location
	
	var actions := _sage.get_available_actions()
	assert_eq(actions.size(), 1)
	assert_eq(actions[0].action_type, Action.RECHARGE)
	
	var mod = (actions[0] as PlayCardAction).check_modifier
	assert_not_null(mod)
	assert_eq(mod.added_dice.size(), 1)
	assert_eq(mod.added_dice[0], 6)

func test_sage_adds_to_local_knowledge_skill_check():
	var codex = TestUtils.get_card("Codex")
	TestUtils.setup_encounter_with_instances(valeros, codex)
	ezren.location = valeros.location
	
	var actions := _sage.get_available_actions()
	assert_eq(actions.size(), 1)
	assert_eq(actions[0].action_type, Action.RECHARGE)
	
	var mod = (actions[0] as PlayCardAction).check_modifier
	assert_not_null(mod)
	assert_eq(mod.added_dice.size(), 1)
	assert_eq(mod.added_dice[0], 6)
