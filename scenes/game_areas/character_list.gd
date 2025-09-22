extends PanelContainer

# Parent VBoxContainers for Local/Distant characters
@onready var local_characters: VBoxContainer = %LocalCharacters
@onready var distant_characters: VBoxContainer = %DistantCharacters

# HBoxContainer rows for character icons
@onready var local_row_1: HBoxContainer = %LocalRow1
@onready var local_row_2: HBoxContainer = %LocalRow2
@onready var distant_row_1: HBoxContainer = %DistantRow1
@onready var distant_row_2: HBoxContainer = %DistantRow2

# TextureButtons for the various characters
@onready var local_1: TextureButton = %Local1
@onready var local_2: TextureButton = %Local2
@onready var local_3: TextureButton = %Local3
@onready var local_4: TextureButton = %Local4
@onready var local_5: TextureButton = %Local5
@onready var local_6: TextureButton = %Local6
@onready var distant_1: TextureButton = %Distant1
@onready var distant_2: TextureButton = %Distant2
@onready var distant_3: TextureButton = %Distant3
@onready var distant_4: TextureButton = %Distant4
@onready var distant_5: TextureButton = %Distant5
@onready var distant_6: TextureButton = %Distant6


func _ready() -> void:
	GameEvents.pc_location_changed.connect(_on_pc_location_changed)
	GameEvents.player_character_changed.connect(_on_player_character_changed)


func _on_pc_location_changed(pc: PlayerCharacter):
	_on_player_character_changed(pc)


func _on_player_character_changed(pc: PlayerCharacter) -> void:
	if Contexts.game_context.characters.size() < 2:
		visible = false
		return
	
	var locals := pc.local_characters.filter(func(p): return p != pc)
	var distant := pc.distant_characters
	
	local_characters.visible = not locals.is_empty()
	distant_characters.visible = not distant.is_empty()
	
	var local_buttons: Array[TextureButton] = [local_1, local_2, local_3, local_4, local_5, local_6]
	var distant_buttons: Array[TextureButton] = [distant_1, distant_2, distant_3, distant_4, distant_5, distant_6]
	for i in range(6):
		local_buttons[i].visible = i < locals.size()
		distant_buttons[i].visible = i < distant.size()
		
		if i < locals.size():
			_update_pc_icon(pc, locals[i], local_buttons[i])
		if i < distant.size():
			_update_pc_icon(pc, distant[i], distant_buttons[i])
	
	reset_size()


func _update_pc_icon(current_pc: PlayerCharacter, icon_pc: PlayerCharacter, button: TextureButton) -> void:
	button.texture_normal = icon_pc.data.icon_enabled
	button.texture_disabled = icon_pc.data.icon_disabled
	
	button.disabled = current_pc == icon_pc
	
	for connection in button.pressed.get_connections():
		button.pressed.disconnect(connection["callable"])
		
	var on_pressed := func():
		icon_pc.set_active()
		button.modulate = Color.WHITE
		
	button.pressed.connect(on_pressed)
	
	if not button.mouse_entered.is_connected(_on_mouse_entered):
		button.mouse_entered.connect(_on_mouse_entered.bind(button))
	if not button.mouse_exited.is_connected(_on_mouse_exited):
		button.mouse_exited.connect(_on_mouse_exited.bind(button))


func _on_mouse_entered(button: TextureButton) -> void:
	if button.disabled: return
	button.modulate = Color(1.1, 1.1, 1.1)


func _on_mouse_exited(button: TextureButton) -> void:
	if button.disabled: return
	button.modulate = Color.WHITE
