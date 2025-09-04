class_name CheckController
extends BaseProcessor

var _resolvable: CheckResolvable

# Dependency injection
var _game_flow: GameFlowManager
var _game_services: GameServices

func _init(resolvable: CheckResolvable, game_services: GameServices):
	_resolvable = resolvable
	
	_game_flow = game_services.game_flow
	_game_services = game_services
