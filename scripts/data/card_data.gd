# CardData.gd
class_name CardData
extends Resource

# Unique Identifier
@export var card_id: String

# Base Card Info
@export var card_name: String
@export var card_type: CardTypes.CardType
@export var story_bane_type: CardTypes.CardType
@export var card_level: int
@export var card_art: Texture2D

# Check Requirements
@export var check_requirement: CheckRequirement
@export var reroll_threshold: int = 0

# Powers
@export_multiline var powers: String
@export_multiline var recovery: String
@export var immunities: Array[String] = []
@export var vulnerabilities: Array[String] = []

# Traits
@export var is_loot: bool = false
@export var traits: Array[String] = []
