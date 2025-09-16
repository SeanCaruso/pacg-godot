# main_game.gd
extends Control

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

@onready var scenario_area: ScenarioArea = %ScenarioArea
@onready var test_data: TestData = %TestData


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scenario_area.set_scenario(test_data.scenario_data)
	var game_context := GameContext.new(1, test_data.scenario_data)
	GameServices.contexts.new_game(game_context)
	
	for i in range(30):
		game_context.hour_deck.shuffle_in(GameServices.cards.new_card(test_data.hour_card_data))
	
	var num_pcs := test_data.characters_to_use.size()
	for scenario_location: ScenarioLocation in test_data.scenario_data.locations:
		if scenario_location.num_pcs > num_pcs: continue
		var location := Location.new(scenario_location.location_data)
		game_context.locations.append(location)
		
		if not test_data.scenario_data.henchmen.is_empty():
			var henchman_data = test_data.scenario_data.henchmen[0].card_data
			location.shuffle_in(GameServices.cards.new_card(henchman_data), false)
	
	for pc: CharacterData in test_data.test_characters:
		if not test_data.characters_to_use.has(pc.character_name): continue
		var character = PlayerCharacter.new(pc)
		game_context.characters.append(character)
		character.location = game_context.locations.front()
		
		for pc_card in test_data.test_characters[pc]:
			var card_instance := GameServices.cards.new_card(pc_card, character)
			character.shuffle_into_deck(card_instance)
		
		character.draw_initial_hand()
	
	var first_pc := game_context.characters[0]
	GameServices.contexts.game_context.set_active_character(first_pc)
	var turn_controller := StartTurnController.new(first_pc)
	GameServices.game_flow.start_phase(turn_controller, "Turn")
