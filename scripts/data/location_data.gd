class_name LocationData
extends Resource

# Unique Identifier
@export var card_id: String

@export_category("Basic Info")
@export var card_name: String
@export var card_level: int

@export_category("Powers")
@export var at_location_power: LocationPower
@export var to_close_power: LocationPower
@export var when_closed_power: LocationPower

@export_category("Card List")
@export var num_monsters: int
@export var num_barriers: int
@export var num_weapons: int
@export var num_spells: int
@export var num_armors: int
@export var num_items: int
@export var num_allies: int
@export var num_blessings: int

@export_category("Traits")
@export var traits: Array[String]

@export_category("Location Logic")
@export var logic: LocationLogicBase
