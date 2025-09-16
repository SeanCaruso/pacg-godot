class_name ScenarioArea
extends VBoxContainer

const CARD_DISPLAY_SCENE := preload("res://scenes/cards/card_display.tscn")

@onready var scenario_power_text: Label = %ScenarioPowerText
@onready var scenario_power_button: TextureButton = %ScenarioPowerButton
@onready var danger_container: Control = %DangerContainer


func set_scenario(scenario: ScenarioData) -> void:
	scenario_power_text.text = scenario.during_scenario
	
	scenario_power_button.texture_normal = scenario.during_scenario_power_enabled
	scenario_power_button.texture_disabled = scenario.during_scenario_power_disabled
	scenario_power_button.visible = scenario.is_during_power_activated
	
	var danger_instance := CardInstance.new(scenario.dangers[0].card_data)
	var danger_display := CARD_DISPLAY_SCENE.instantiate()
	danger_container.add_child(danger_display)
	danger_display.set_card_instance(danger_instance)
	danger_display.scale = Vector2(.5, .5)
