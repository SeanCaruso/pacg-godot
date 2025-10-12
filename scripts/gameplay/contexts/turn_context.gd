class_name TurnContext
extends RefCounted

const TurnPhase := preload("res://scripts/core/enums/turn_phase.gd").TurnPhase

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
var was_location_closed: bool = false

var explore_effects: Array[BaseExploreEffect] = []

var performed_location_power_ids: Array[String] = []
var performed_character_power_ids: Array[String] = []

## If a PC encounters the villain this turn, this keeps track of which locations are guarded.
var guard_locations_resolvable: GuardLocationsResolvable

var is_explore_possible: bool:
	get:
		return character.location.count > 0 \
		and Contexts.are_cards_playable \
		and not was_location_closed

func _init(turn_character: PlayerCharacter):
	character = turn_character
