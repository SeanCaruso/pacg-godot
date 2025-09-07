# game_services.gd
extends Node

# The main service references
var asm: ActionStagingManager
var cards: CardManager
var contexts: ContextManager
var game_flow: GameFlowManager
#var logic_registry: LogicRegistry

var adventure_number := 1

func _ready():
	print ("GameServices loaded but not initialized yet.")
	_initialize_game_systems()
	
	
func _initialize_game_systems():
	# Initialize CardUtils first
	CardUtils.initialize(adventure_number)
	
	# Step 1 - Construct all services
	asm = ActionStagingManager.new()
	cards = CardManager.new()
	contexts = ContextManager.new()
	game_flow = GameFlowManager.new()
	#logic_registry = LogicRegistry.new()
	
	# Step 2 - Initialize with cross-dependencies
	asm.initialize(self)
	contexts.initialize(self)
	game_flow.initialize(self)
	#logic_registry.initialize(self)
	
	print("GameServices initialized!")
