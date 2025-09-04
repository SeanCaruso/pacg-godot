class_name CheckController
extends BaseProcessor

var _resolvable: CheckResolvable

# Dependency injection
var _game_services: GameServices

func _init(resolvable: CheckResolvable, game_services: GameServices):
	super(game_services)
	_resolvable = resolvable
	
	_game_services = game_services
