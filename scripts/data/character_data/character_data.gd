class_name CharacterData
extends Resource

@export_category("Name")
@export var character_name: String

@export_category("Skills")
@export var attributes: Array[AttributeSkill]
@export var skills: Array[PcSkill]

@export_category("Other Basic Info")
@export var hand_size: int
@export var proficiencies: Array[Proficiency]
@export var traits: Array[String]

@export_category("Powers")
@export var powers: Array[CharacterPower]

@export_category("Deck List")
@export var weapons: int
@export var spells: int
@export var armor: int
@export var items: int
@export var allies: int
@export var blessings: int
@export var favored_cards: Array[Proficiency]

@export_category("Logic")
@export var logic: CharacterLogicBase

@export_category("Images")
@export var icon_enabled: Texture2D
@export var icon_disabled: Texture2D
