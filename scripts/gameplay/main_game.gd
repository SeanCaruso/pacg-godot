# main_game.gd
extends Control

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

@onready var scenario_area: ScenarioArea = %ScenarioArea
@onready var test_data: TestData = %TestData


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scenario_area.set_scenario(test_data.scenario_data)
	var game_context := GameContext.new(1, test_data.scenario_data)
	Contexts.new_game(game_context)
	
	for i in range(30):
		game_context.hour_deck.shuffle_in(GameServices.cards.new_card(test_data.hour_card_data))
	
	var num_pcs := test_data.characters_to_use.size()
	for scenario_location: ScenarioLocation in test_data.scenario_data.locations:
		if scenario_location.num_pcs > num_pcs: continue
		var location := Location.new(scenario_location.location_data)
		game_context.locations.append(location)
		
		for loc_card in test_data.test_locations.get(location.data, []):
			location.shuffle_in(GameServices.cards.new_card(loc_card), true)
	
	var henchman_idx := 0
	var villain_loc := randi_range(0, game_context.locations.size() - 1)
	if not test_data.scenario_data.villain:
		villain_loc = -1
	for i in range(game_context.locations.size()):
		var story_bane_data: CardData
		if i == villain_loc:
			story_bane_data = test_data.scenario_data.villain.card_data
		else:
			story_bane_data = test_data.scenario_data.henchmen[henchman_idx].card_data
			henchman_idx = min(henchman_idx + 1, test_data.scenario_data.henchmen.size() - 1)
		
		var story_bane_instance := GameServices.cards.new_card(story_bane_data)
		game_context.locations[i].shuffle_in(story_bane_instance, false)
	
	for pc: CharacterData in test_data.test_characters:
		if not test_data.characters_to_use.has(pc.character_name): continue
		var character = PlayerCharacter.new(pc)
		game_context.characters.append(character)
		character.location = game_context.locations.filter(func(l): return l.name == "Caravan").front()
		
		for pc_card in test_data.test_characters[pc]:
			var card_instance := GameServices.cards.new_card(pc_card, character)
			character.shuffle_into_deck(card_instance)
		
		character.draw_initial_hand()
	
	var first_pc := game_context.characters[0]
	Contexts.game_context.set_active_character(first_pc)
	var turn_controller := StartTurnController.new(first_pc)
	TaskManager.push(turn_controller)
	TaskManager.process()
