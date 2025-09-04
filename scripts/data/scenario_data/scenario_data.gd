class_name ScenarioData
extends Resource

@export_category("Scenario Name")
@export var name: String
@export var id: String

@export_category("Setup")
@export_multiline var setup: String

@export_category("Locations")
@export var locations: Array[ScenarioLocation]

@export_category("During This Scenario")
@export_multiline var during_scenario: String
@export var is_during_power_activated: bool
@export var during_scenario_power_enabled: Texture2D
@export var during_scenario_power_disabled: Texture2D

@export_category("Story Banes")
@export var dangers: Array[StoryBane]
@export var villain: StoryBane
@export var henchmen: Array[StoryBane]

@export_category("Reward")
@export var reward: String
