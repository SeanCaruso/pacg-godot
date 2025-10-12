class_name GameContext
extends RefCounted

var adventure_number: int

var scenario_data: ScenarioData
var scenario_logic: ScenarioLogicBase
var hour_deck: Deck
var turn_number: int = 1

var locations: Array[Location] = []
var characters: Array[PlayerCharacter] = []

var _active_character: PlayerCharacter
var active_character: PlayerCharacter:
	get:
		return _active_character

func _init(
	_adventure_number: int,
	_scenario_data: ScenarioData
):
	CardUtils.initialize(_adventure_number)
	adventure_number = _adventure_number
	scenario_data = _scenario_data
	scenario_logic = _scenario_data.logic if _scenario_data else null
	
	hour_deck = Deck.new()


func get_characters_at(loc: Location) -> Array[PlayerCharacter]:
	return characters.filter(func(pc: PlayerCharacter): return pc.location == loc) if loc else []


func is_villain(card: CardInstance) -> bool:
	if not scenario_data or not scenario_data.villain or not scenario_data.villain.card_data:
		return false
	
	return card.data.card_id == scenario_data.villain.card_data.card_id


func set_active_character(pc: PlayerCharacter) -> void:
	_active_character = pc
	GameEvents.player_character_changed.emit(pc)
