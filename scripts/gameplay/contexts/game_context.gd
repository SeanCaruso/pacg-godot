class_name GameContext
extends RefCounted

var adventure_number: int

var scenario_data: ScenarioData
var scenario_logic: ScenarioLogicBase
var hour_deck: Deck
var turn_number: int = 1

var locations: Array[Location] = []
var characters: Array[PlayerCharacter] = []

var active_character: PlayerCharacter

func _init(
	_adventure_number: int,
	_scenario_data: ScenarioData,
	_scenario_logic: ScenarioLogicBase,
	game_services: GameServices
):
	adventure_number = _adventure_number
	scenario_data = _scenario_data
	scenario_logic = _scenario_logic
	
	hour_deck = Deck.new(game_services.card_manager)

func get_characters_at(loc: Location) -> Array[PlayerCharacter]:
	return characters.filter(func(pc: PlayerCharacter): return pc.location == loc) if loc else []
