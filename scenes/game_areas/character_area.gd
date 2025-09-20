class_name CharacterArea
extends Control

var _pc: PlayerCharacter
var _power_button_map: Dictionary # CharacterPower -> TextureButton

@onready var deck_count: Label = %DeckCount
@onready var power_button_1: TextureButton = %PowerButton1
@onready var power_button_2: TextureButton = %PowerButton2
@onready var power_button_3: TextureButton = %PowerButton3


func _ready() -> void:
	GuiUtils.add_mouseover_effect_to_button(power_button_1)
	GuiUtils.add_mouseover_effect_to_button(power_button_2)
	GuiUtils.add_mouseover_effect_to_button(power_button_3)
	
	GameEvents.player_character_changed.connect(_on_player_character_changed)
	GameEvents.player_deck_count_changed.connect(_on_player_deck_count_changed)
	GameEvents.player_power_enabled.connect(_on_player_power_enabled)


func _on_player_character_changed(pc: PlayerCharacter) -> void:
	_pc = pc
	_on_player_deck_count_changed(pc.deck.count)
	
	var buttons: Array[TextureButton] = [power_button_1, power_button_2, power_button_3]
	for i in range(3):
		buttons[i].visible = pc.data.powers[i].is_activated_power
		buttons[i].texture_normal = pc.data.powers[i].sprite_enabled
		buttons[i].texture_disabled = pc.data.powers[i].sprite_disabled
		buttons[i].disabled = not pc.is_power_enabled(i)
		
		for c in buttons[i].pressed.get_connections():
			buttons[i].pressed.disconnect(c["callable"])
		
		buttons[i].pressed.connect(Callable(pc.logic, pc.data.powers[i].power_id))
		
		_power_button_map[pc.data.powers[i]] = buttons[i]


func _on_player_deck_count_changed(count: int) -> void:
	deck_count.text = str(count)


func _on_player_power_enabled(power: CharacterPower, enabled: bool) -> void:
	if not _power_button_map.has(power): return
	var button: TextureButton = _power_button_map[power]
	
	for s in button.pressed.get_connections():
		button.pressed.disconnect(s["callable"])
	
	button.disabled = !enabled
	button.pressed.connect(Callable(_pc.logic, power.power_id))
