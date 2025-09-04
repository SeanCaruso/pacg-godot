class_name TurnContext
extends RefCounted

enum TurnPhase {
	TURN_START,
	TURN_ACTIONS,
	CLOSE_LOCATION,
	END_OF_TURN_EFFECTS,
	RECOVERY,
	RESET,
	NONE
}

var current_phase: TurnPhase = TurnPhase.TURN_START
var hour_card: CardInstance
var character: PlayerCharacter

# General turn action availability flags
var can_give: bool
var can_move: bool
var can_freely_explore: bool
var can_close_location: bool
var can_end_turn: bool

# Special cases for scenario effects
var has_scenario_turn_action: bool
var can_use_scenario_turn_action: bool

var force_end_turn: bool = false

var explore_effects: Array[BaseExploreEffect] = []

var performed_location_powers: Array[LocationPower] = []
#var performed_character_powers: Array[CharacterPower] = []

func _init(turn_character: PlayerCharacter):
	character = turn_character
