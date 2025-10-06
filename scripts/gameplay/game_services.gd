# game_services.gd
extends Node

# The main service references
var cards: CardManager

var adventure_number := 1

func _ready():
	_initialize_game_systems()
	
	
func _initialize_game_systems():
	# Initialize CardUtils first
	CardUtils.initialize(adventure_number)
	
	# Construct all services
	cards = CardManager.new()
