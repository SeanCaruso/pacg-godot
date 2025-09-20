# base_test.gd
class_name BaseTest
extends GutTest

const Action := preload("res://scripts/core/enums/action_type.gd").Action
const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const CardType := preload("res://scripts/core/enums/card_type.gd").CardType
const Scourge := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge
const Skill := preload("res://scripts/core/enums/skill.gd").Skill

# Common cards - similar to Unity BaseTest
var ezren: PlayerCharacter
var valeros: PlayerCharacter

var longsword: CardInstance
var zombie: CardInstance

var caravan: Location

func before_each():
	# Initialize game systems
	GameServices._initialize_game_systems()
	
	# Set up common characters
	ezren = TestUtils.get_character("Ezren")
	valeros = TestUtils.get_character("Valeros")
	
	# Set up common cards
	longsword = TestUtils.get_card("Longsword")
	zombie = TestUtils.get_card("Zombie")
	
	# Set up common location
	caravan = TestUtils.get_location("Caravan")
	
	# Create a basic game context
	var game_context = GameContext.new(1, null)
	game_context.characters.append_array([ezren, valeros])
	game_context.locations.append(caravan)
	GameServices.contexts.new_game(game_context)
	
	# Put the characters at the location
	ezren.location = caravan
	valeros.location = caravan


func after_each():
	# Clean up all contexts in proper order
	if GameServices.contexts.check_context:
		GameServices.contexts.end_check()
	while GameServices.contexts.current_resolvable:
		GameServices.contexts.end_resolvable()
	if GameServices.contexts.encounter_context:
		GameServices.contexts.end_encounter()
	if GameServices.contexts.turn_context:
		GameServices.contexts.end_turn()
