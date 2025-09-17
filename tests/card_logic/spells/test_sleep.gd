# test_sleep.gd
extends BaseTest

var _sleep: CardInstance
var _dire_badger: CardInstance

func before_each():
	super()
	_sleep = TestUtils.get_card("Sleep")
	ezren.add_to_hand(_sleep)
	
	_dire_badger = TestUtils.get_card("Dire Badger")
	_dire_badger.current_location = CardLocation.DECK

func test_sleep_to_evade_own_monster_encounter():
	GameServices.contexts.new_encounter(EncounterContext.new(ezren, _dire_badger))
	
	var processor = EvasionEncounterProcessor.new()
	processor.execute()
	
	assert_true(GameServices.contexts.current_resolvable is EvadeResolvable)
	assert_eq(_sleep.get_available_actions().size(), 1)
	
	GameServices.contexts.current_resolvable.resolve()
	assert_eq(caravan.count, 1)
	assert_eq(caravan.examine_top(1)[0], _dire_badger)

func test_sleep_to_evade_local_monster_encounter():
	valeros.location = caravan
	GameServices.contexts.new_encounter(EncounterContext.new(valeros, _dire_badger))
	
	var processor = EvasionEncounterProcessor.new()
	processor.execute()
	
	assert_true(GameServices.contexts.current_resolvable is EvadeResolvable)
	assert_eq(_sleep.get_available_actions().size(), 1)
	
	GameServices.contexts.current_resolvable.resolve()
	assert_eq(caravan.count, 1)
	assert_eq(caravan.examine_top(1)[0], _dire_badger)

func test_sleep_cannot_evade_distant_monster_encounter():
	var campsite = TestUtils.get_location("campsite")
	valeros.location = campsite
	GameServices.contexts.new_encounter(EncounterContext.new(valeros, _dire_badger))
	
	var processor = EvasionEncounterProcessor.new()
	processor.execute()
	
	assert_null(GameServices.contexts.current_resolvable)
	assert_eq(_sleep.get_available_actions().size(), 0)

func test_sleep_cannot_evade_immune_monster_encounter():
	GameServices.contexts.new_encounter(EncounterContext.new(ezren, zombie))
	
	var processor = EvasionEncounterProcessor.new()
	processor.execute()
	
	assert_null(GameServices.contexts.current_resolvable)
	assert_eq(_sleep.get_available_actions().size(), 0)

func test_sleep_cannot_evade_unevadable_monster_encounter():
	var dire_wolf = TestUtils.get_card("Dire Wolf")
	GameServices.contexts.new_encounter(EncounterContext.new(ezren, dire_wolf))
	
	var processor = EvasionEncounterProcessor.new()
	processor.execute()
	
	assert_null(GameServices.contexts.current_resolvable)
	assert_eq(_sleep.get_available_actions().size(), 0)

func test_sleep_adds_bonus_to_own_monster_check():
	GameServices.contexts.new_encounter(EncounterContext.new(ezren, _dire_badger))
	
	var processor = AttemptChecksEncounterProcessor.new()
	processor.execute()
	
	assert_true(GameServices.contexts.current_resolvable is CheckResolvable)
	assert_eq(_sleep.get_available_actions().size(), 1)
	
	var modifier = (_sleep.get_available_actions()[0] as PlayCardAction).check_modifier
	assert_not_null(modifier)
	assert_eq(modifier.added_dice.size(), 1)
	assert_eq(modifier.added_dice[0], 6)

func test_sleep_adds_bonus_to_own_ally_check():
	var soldier = TestUtils.get_card("soldier")
	GameServices.contexts.new_encounter(EncounterContext.new(ezren, soldier))
	
	var processor = AttemptChecksEncounterProcessor.new()
	processor.execute()
	
	assert_true(GameServices.contexts.current_resolvable is CheckResolvable)
	assert_eq(_sleep.get_available_actions().size(), 1)
	
	var modifier = (_sleep.get_available_actions()[0] as PlayCardAction).check_modifier
	assert_not_null(modifier)
	assert_eq(modifier.added_dice.size(), 1)
	assert_eq(modifier.added_dice[0], 6)

func test_sleep_adds_bonus_to_local_monster_check():
	valeros.location = caravan
	GameServices.contexts.new_encounter(EncounterContext.new(valeros, _dire_badger))
	
	var processor = AttemptChecksEncounterProcessor.new()
	processor.execute()
	
	assert_true(GameServices.contexts.current_resolvable is CheckResolvable)
	assert_eq(_sleep.get_available_actions().size(), 1)
	
	var modifier = (_sleep.get_available_actions()[0] as PlayCardAction).check_modifier
	assert_not_null(modifier)
	assert_eq(modifier.added_dice.size(), 1)
	assert_eq(modifier.added_dice[0], 6)

func test_sleep_adds_bonus_to_local_ally_check():
	valeros.location = caravan
	var soldier = TestUtils.get_card("soldier")
	GameServices.contexts.new_encounter(EncounterContext.new(valeros, soldier))
	
	var processor = AttemptChecksEncounterProcessor.new()
	processor.execute()
	
	assert_true(GameServices.contexts.current_resolvable is CheckResolvable)
	assert_eq(_sleep.get_available_actions().size(), 1)
	
	var modifier = (_sleep.get_available_actions()[0] as PlayCardAction).check_modifier
	assert_eq(modifier.added_dice.size(), 1)
	assert_eq(modifier.added_dice[0], 6)

func test_sleep_does_not_add_bonus_to_own_immune_monster_check():
	GameServices.contexts.new_encounter(EncounterContext.new(ezren, zombie))
	
	var processor = AttemptChecksEncounterProcessor.new()
	processor.execute()
	
	assert_true(GameServices.contexts.current_resolvable is CheckResolvable)
	assert_eq(_sleep.get_available_actions().size(), 0)
