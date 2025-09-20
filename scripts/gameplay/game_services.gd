# game_services.gd
extends Node

# The main service references
var asm: ActionStagingManager
var cards: CardManager
var contexts: ContextManager:
	get:
		return Contexts
var game_flow: GameFlowManager

var adventure_number := 1

func _ready():
	_initialize_game_systems()
	
	
func _initialize_game_systems():
	# Initialize CardUtils first
	CardUtils.initialize(adventure_number)
	
	# Construct all services
	asm = ActionStagingManager.new()
	cards = CardManager.new()
	game_flow = GameFlowManager.new()
