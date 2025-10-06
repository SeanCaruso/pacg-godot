# test_utils.gd
class_name TestUtils
extends RefCounted

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation


# Load card data by name - searches in _game_data folders
static func load_card_data(card_name: String):
	# Define search paths for different card types
	var search_paths = [
		"res://_game_data/allies/",
		"res://_game_data/armor/", 
		"res://_game_data/barriers/",
		"res://_game_data/blessings/",
		"res://_game_data/characters/",
		"res://_game_data/items/",
		"res://_game_data/locations/",
		"res://_game_data/monsters/",
		"res://_game_data/scenarios/",
		"res://_game_data/spells/",
		"res://_game_data/story_banes/",
		"res://_game_data/weapons/"
	]
	
	for path in search_paths:
		var full_path = path + card_name.to_lower().replace(" ", "_") + ".tres"
		if ResourceLoader.exists(full_path):
			return load(full_path)
	
	# Also try the exact card_name without modification
	for path in search_paths:
		var full_path = path + card_name + ".tres"  
		if ResourceLoader.exists(full_path):
			return load(full_path)
	
	assert(false, "Could not find card data for: " + card_name)
	return null


# Helper methods similar to your Unity TestUtils
static func get_card(card_name: String) -> CardInstance:
	var card_data = load_card_data(card_name)
	return GameServices.cards.new_card(card_data)


static func get_character(character_name: String) -> PlayerCharacter:
	var character_data = load_card_data(character_name) as CharacterData
	return PlayerCharacter.new(character_data)


static func get_location(location_name: String) -> Location:
	var location_data = load_card_data(location_name) as LocationData
	return Location.new(location_data)


static func get_scenario(scenario_name: String) -> ScenarioData:
	var scenario_data = load_card_data(scenario_name) as ScenarioData
	return scenario_data


static func setup_encounter(character_name: String, card_name: String):
	var pc = get_character(character_name)
	var encounter_card = get_card(card_name)
	setup_encounter_with_instances(pc, encounter_card)


static func setup_encounter_with_instances(pc: PlayerCharacter, card: CardInstance):
	var location = get_location("Caravan")  # Default test location
	
	if not Contexts.game_context:
		var game_context = GameContext.new(1, null)
		Contexts.new_game(game_context)
	pc.location = location
	
	var turn_context = TurnContext.new(pc)
	Contexts.new_turn(turn_context)
	TaskManager.start_task(EncounterController.new(pc, card))
