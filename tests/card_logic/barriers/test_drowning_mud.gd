# test_drowning_mud.gd
extends BaseTest

# Test subjects
var _test_valeros: PlayerCharacter
var _test_longsword: CardInstance
var _drowning_mud: CardInstance

func before_each():
	super()
	
	# Set up Valeros character
	_test_valeros = TestUtils.get_character("Valeros")
	_test_longsword = TestUtils.get_card("Longsword")
	_test_longsword.owner = _test_valeros
	_test_valeros.reload(_test_longsword)
	
	_drowning_mud = TestUtils.get_card("Drowning Mud")


func test_drowning_mud_undefeated_entangles():
	# Set up encounter with Drowning Mud
	Contexts.new_encounter(EncounterContext.new(_test_valeros, _drowning_mud))
	_drowning_mud.logic.on_undefeated(_drowning_mud)
	
	assert_true(_test_valeros.active_scourges.has(Scourge.ENTANGLED), "Should have Entangled scourge")


func test_drowning_mud_undefeated_exhausts():
	# Set up encounter with Drowning Mud
	Contexts.new_encounter(EncounterContext.new(_test_valeros, _drowning_mud))
	_drowning_mud.logic.on_undefeated(_drowning_mud)
	
	assert_true(_test_valeros.active_scourges.has(Scourge.EXHAUSTED), "Should have Exhausted scourge")


func test_drowning_mud_undefeated_buries_top_card():
	# Set up encounter with Drowning Mud
	Contexts.new_encounter(EncounterContext.new(_test_valeros, _drowning_mud))
	_drowning_mud.logic.on_undefeated(_drowning_mud)
	
	assert_eq(_test_valeros.deck.count, 0, "Deck should be empty after burying top card")
	assert_eq(_test_valeros.buried_cards.size(), 1, "Should have one buried card")
	assert_eq(_test_valeros.buried_cards[0], _test_longsword, "Longsword should be buried")
