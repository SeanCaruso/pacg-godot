class_name CheckController
extends BaseProcessor

var _resolvable: CheckResolvable

func _init(resolvable: CheckResolvable, game_services: GameServices):
	super(game_services)
	_resolvable = resolvable
