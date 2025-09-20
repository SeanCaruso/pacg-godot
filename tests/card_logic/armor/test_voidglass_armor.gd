# test_voidglass_armor.gd
extends BaseTest

# Test subjects
var _voidglass_armor: CardInstance

func before_each():
	super()
	
	_voidglass_armor = TestUtils.get_card("Voidglass Armor")


func test_voidglass_armor_can_recharge_for_any_damage():
	_voidglass_armor.owner = valeros
	_voidglass_armor.current_location = CardLocation.DISPLAYED
	
	Contexts.new_resolvable(DamageResolvable.new(valeros, 1, "Magic"))
	
	var actions := _voidglass_armor.get_available_actions()
	assert_eq(actions.size(), 2, "Should have two actions")
	assert_eq(actions[0].action_type, Action.RECHARGE, "First action should be recharge")
	assert_eq(actions[1].action_type, Action.BURY, "Second action should be bury")
	
	GameServices.asm.stage_action(actions[0])
	assert_true(Contexts.current_resolvable.can_commit(GameServices.asm.staged_actions), "Should be able to commit")


func test_voidglass_armor_can_display_then_recharge_for_any_damage():
	_voidglass_armor.owner = valeros
	_voidglass_armor.current_location = CardLocation.HAND
	
	Contexts.new_resolvable(DamageResolvable.new(valeros, 1, "Special"))
	
	var actions := _voidglass_armor.get_available_actions()
	assert_eq(actions.size(), 1, "Should have one action")
	assert_eq(actions[0].action_type, Action.DISPLAY, "Should be display action")
	
	GameServices.asm.stage_action(actions[0])
	
	actions = _voidglass_armor.get_available_actions()
	assert_eq(actions.size(), 2, "Should have two actions after display")
	assert_eq(actions[0].action_type, Action.RECHARGE, "First action should be recharge")
	assert_eq(actions[1].action_type, Action.BURY, "Second action should be bury")
	
	GameServices.asm.stage_action(actions[0])
	assert_true(Contexts.current_resolvable.can_commit(GameServices.asm.staged_actions), "Should be able to commit")


func test_voidglass_armor_prompts_on_mental_damage_when_displayed():
	_voidglass_armor.owner = valeros
	GameServices.cards.move_card_to(_voidglass_armor, CardLocation.DISPLAYED)
	
	Contexts.new_resolvable(DamageResolvable.new(valeros, 3, "Mental"))
	
	assert_true(Contexts.current_resolvable is PlayerChoiceResolvable, "Should have player choice resolvable")
	
	var resolvable = Contexts.current_resolvable as PlayerChoiceResolvable
	assert_eq(resolvable.options.size(), 2, "Should have two options")


func test_voidglass_armor_prompts_on_mental_damage_when_in_hand():
	_voidglass_armor.owner = valeros
	GameServices.cards.move_card_to(_voidglass_armor, CardLocation.HAND)
	
	Contexts.new_resolvable(DamageResolvable.new(valeros, 3, "Mental"))
	
	assert_true(Contexts.current_resolvable is PlayerChoiceResolvable, "Should have player choice resolvable")
	
	var resolvable = Contexts.current_resolvable as PlayerChoiceResolvable
	assert_eq(resolvable.options.size(), 2, "Should have two options")


func test_voidglass_armor_mental_damage_power_allows_recharge():
	_voidglass_armor.owner = valeros
	var test_longsword = TestUtils.get_card("Longsword")
	valeros.add_to_hand(test_longsword)
	GameServices.cards.move_card_to(_voidglass_armor, CardLocation.HAND)
	
	var damage_resolvable = DamageResolvable.new(valeros, 1, "Mental")
	var processor = NewResolvableProcessor.new(damage_resolvable)
	GameServices.game_flow.start_phase(processor, "Damage")
	
	assert_true(Contexts.current_resolvable is PlayerChoiceResolvable, "Should have player choice")
	
	var resolvable = Contexts.current_resolvable as PlayerChoiceResolvable
	assert_eq(resolvable.options.size(), 2, "Should have two options")
	
	resolvable.options[0].action.call()
	assert_eq(_voidglass_armor.current_location, CardLocation.DECK, "Armor should be recharged to deck")
	
	assert_eq(damage_resolvable, Contexts.current_resolvable, "Should return to damage resolvable")
	assert_false(Contexts.current_resolvable.can_commit(GameServices.asm.staged_actions), "Should not be able to commit without more actions")
	
	var damage_actions := Contexts.current_resolvable.get_additional_actions_for_card(test_longsword)
	assert_eq(damage_actions.size(), 1, "Should have one damage action")
	GameServices.asm.stage_action(damage_actions[0])
	
	assert_eq(test_longsword.current_location, CardLocation.DECK, "Longsword should be recharged to deck")
	assert_true(Contexts.current_resolvable.can_commit(GameServices.asm.staged_actions), "Should be able to commit now")


func test_voidglass_armor_prompts_on_deck_discard_when_displayed():
	_voidglass_armor.owner = valeros
	valeros.shuffle_into_deck(longsword)
	GameServices.cards.move_card_to(_voidglass_armor, CardLocation.DISPLAYED)
	
	ScourgeRules.handle_wounded_deck_discard(valeros)
	
	assert_true(Contexts.current_resolvable is PlayerChoiceResolvable, "Should have player choice resolvable")
	
	var resolvable = Contexts.current_resolvable as PlayerChoiceResolvable
	assert_eq(resolvable.options.size(), 2, "Should have two options")


func test_voidglass_armor_prompts_on_deck_discard_when_in_hand():
	_voidglass_armor.owner = valeros
	valeros.shuffle_into_deck(longsword)
	GameServices.cards.move_card_to(_voidglass_armor, CardLocation.HAND)
	
	ScourgeRules.handle_wounded_deck_discard(valeros)
	
	assert_true(Contexts.current_resolvable is PlayerChoiceResolvable, "Should have player choice resolvable")
	
	var resolvable = Contexts.current_resolvable as PlayerChoiceResolvable
	assert_eq(resolvable.options.size(), 2, "Should have two options")


func test_voidglass_armor_recharge_instead_of_deck_discard():
	_voidglass_armor.owner = valeros
	valeros.shuffle_into_deck(longsword)
	GameServices.cards.move_card_to(_voidglass_armor, CardLocation.HAND)
	
	ScourgeRules.handle_wounded_deck_discard(valeros)
	
	assert_true(Contexts.current_resolvable is PlayerChoiceResolvable, "Should have player choice resolvable")
	
	var resolvable = Contexts.current_resolvable as PlayerChoiceResolvable
	assert_eq(resolvable.options.size(), 2, "Should have two options")
	
	resolvable.options[0].action.call()
	assert_eq(_voidglass_armor.current_location, CardLocation.DECK, "Armor should be in deck")
	assert_eq(longsword.current_location, CardLocation.DECK, "Longsword should remain in deck")
