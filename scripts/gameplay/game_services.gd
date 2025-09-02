# GameServices.gd
extends Node

# The main service references
# var action_staging_manager: ActionStagingManager
var card_manager: CardManager
#var context_manager: ContextManager
#var game_flow_manager: GameFlowManager
#var logic_registry: LogicRegistry

var adventure_number := 1

func _ready():
    # Initialize CardUtils first
    #CardUtils.initialize(adventure_number)
    
    # Step 1 - Construct all services
    #action_staging_manager = ActionStagingManager.new()
    card_manager = CardManager.new()
    #context_manager = ContextManager.new()
    #game_flow_manager = GameFlowManager.new()
    #logic_registry = LogicRegistry.new()
    
    # Step 2 - Initialize with cross-dependencies
    #action_staging_manager.initialize(self)
    card_manager.initialize(self)
    #context_manager.initialize(self)
    #game_flow_manager.initialize(self)
    #logic_registry.initialize(self)
    
    print("GameServices initialized!")

# Convenience accessors
#var ASM: ActionStagingManager:
    #get: return action_staging_manager

var Cards: CardManager:
    get: return card_manager

#var Contexts: ContextManager:
    #get: return context_manager

#var GameFlow: GameFlowManager:
    #get: return game_flow_manager

#var Logic: LogicRegistry:
    #get: return logic_registry
