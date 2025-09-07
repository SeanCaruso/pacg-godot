class_name ActionStagingManager
extends RefCounted

var _pcs_staged_actions: Dictionary = {} # PlayerCharacter -> Array[StagedAction]
var _original_card_locs: Dictionary = {} # CardInstance -> CardLocation

var _has_move_staged: bool = false
var _has_explore_staged: bool = false

# Dependency injections
var _cards: CardManager
var _contexts: ContextManager
var _game_flow: GameFlowManager
var _game_services: GameServices

var staged_actions: Array[StagedAction]:
	get:
		var actions: Array[StagedAction] = []
		for _staged_actions in _pcs_staged_actions.values():
			actions.append_array(_staged_actions)
		return actions

var staged_cards: Array[CardInstance]:
	get: return _original_card_locs.keys()


func initialize(game_services: GameServices):
	_cards = game_services.cards
	_contexts = game_services.contexts
	_game_flow = game_services.game_flow
	_game_services = game_services
	

func staged_actions_for(pc: PlayerCharacter) -> Array[StagedAction]:
	return _pcs_staged_actions.get(pc, [])
	
	
func is_card_staged(card: CardInstance) -> bool:
	return _original_card_locs.has(card)
	
