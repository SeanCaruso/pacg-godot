# test_deflect.gd
extends BaseTest

var _deflect: CardInstance

func before_each():
	super()
	_deflect = TestUtils.get_card("Deflect")
	ezren.add_to_hand(_deflect)

func test_deflect_reduces_four_combat_damage_to_owner():
	GameServices.contexts.new_encounter(EncounterContext.new(ezren, zombie))
	const base_damage = 4
	GameServices.contexts.new_resolvable(DamageResolvable.new(ezren, base_damage))
	
	var actions := _deflect.get_available_actions()
	assert_eq(actions.size(), 1)
	
	assert_true(GameServices.contexts.current_resolvable.can_commit(actions))

func test_deflect_not_usable_non_combat_damage_to_owner():
	GameServices.contexts.new_encounter(EncounterContext.new(ezren, zombie))
	const base_damage = 5
	GameServices.contexts.new_resolvable(DamageResolvable.new(ezren, base_damage, "Magic"))
	
	var actions := _deflect.get_available_actions()
	assert_eq(actions.size(), 0)

func test_deflect_reduces_four_combat_damage_to_other_local_character():
	valeros.location = caravan
	
	GameServices.contexts.new_encounter(EncounterContext.new(valeros, zombie))
	const base_damage = 4
	GameServices.contexts.new_resolvable(DamageResolvable.new(valeros, base_damage))
	
	var actions := _deflect.get_available_actions()
	assert_eq(actions.size(), 1)
	
	assert_true(GameServices.contexts.current_resolvable.can_commit(actions))

func test_deflect_not_usable_non_combat_damage_to_other_local_character():
	valeros.location = caravan
	
	GameServices.contexts.new_encounter(EncounterContext.new(valeros, zombie))
	const base_damage = 5
	GameServices.contexts.new_resolvable(DamageResolvable.new(valeros, base_damage, "Magic"))
	
	var actions := _deflect.get_available_actions()
	assert_eq(actions.size(), 0)

func test_deflect_not_usable_combat_damage_to_distant_character():
	var campsite = TestUtils.get_location("campsite")
	valeros.location = campsite
	
	GameServices.contexts.new_encounter(EncounterContext.new(valeros, zombie))
	const base_damage = 5
	GameServices.contexts.new_resolvable(DamageResolvable.new(valeros, base_damage, "Magic"))
	
	var actions := _deflect.get_available_actions()
	assert_eq(actions.size(), 0)
