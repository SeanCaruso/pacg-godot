# card_display.gd
extends TextureRect

signal card_clicked(card_display: Control)

const CardType := preload("res://scripts/core/enums/card_type.gd").CardType
const Skill := preload("res://scripts/core/enums/skill.gd").Skill

#region ========== NODE REFERENCES ==========
# Using the '%' sign gets a reference to nodes with a "unique name in owner".
# It's Godot's best practice for getting nodes in a script.

# --- Top/Bottom Panel ---
@onready var top_panel: ColorRect = %TopPanel
@onready var card_name: Label = %CardName
@onready var card_type: Label = %CardType
@onready var card_level: Label = %CardLevel
@onready var bottom_panel: ColorRect = %Bottom_Panel


# --- Story Bane ---
@onready var story_bane_panel: ColorRect = %StoryBanePanel
@onready var story_bane_type_text: Label = %StoryBaneTypeText

# --- Checks Section 1 ---
@onready var check_label_panel: ColorRect = %Check_Label_Panel
@onready var check_label: Label = %CheckLabel
@onready var skills_1_panel: PanelContainer = %Skills1_Panel
@onready var skills_1_container: VBoxContainer = %Skills1_Container
@onready var dc_1_label: Label = %DC1_Label

# --- Additional checks ---
@onready var or_bar: PanelContainer = %Or_Bar
@onready var then_bar: PanelContainer = %Then_Bar
@onready var check_2_area: HBoxContainer = %Check2_Area
@onready var skills_2_panel: PanelContainer = %Skills2_Panel
@onready var skills_2_container: VBoxContainer = %Skills2_Container
@onready var dc_2_label: Label = %DC2_Label

# --- Powers ---
@onready var powers_panel: PanelContainer = %Powers_Panel
@onready var powers_text: Label = %Powers_Text
@onready var recovery_label: Label = %Recovery_Label
@onready var recovery_text: Label = %Recovery_Text

# --- Traits ---
@onready var loot_panel: PanelContainer = %Loot_Panel
@onready var traits_panel: PanelContainer = %Traits_Panel
@onready var traits_container: VBoxContainer = %Traits_Container

# --- Input ---
@onready var card_input_handler: CardInputHandler = %CardInputHandler
#endregion

var is_previewed: bool = false
var _card_instance: CardInstance
var _panel_color: Color
var _original_pos: Vector2
var _original_scale: Vector2
var _original_z_idx: int
var _is_dragging: bool = false

var card_instance: CardInstance:
	get: return _card_instance


## Main entry point - call this to tell the card what to display.
func set_card_instance(card: CardInstance) -> void:
	if not card:
		visible = false
		return
		
	visible = true
	_card_instance = card
	_update_display()
	
	card_input_handler.setup_input(card, self)


func _update_display():
	if not top_panel:
		printerr("CardDisplay is null - add it to the scene first!")
		return
	
	var data := _card_instance.data
	
	_panel_color = GuiUtils.get_color_for_card_type(data.card_type)
	
	# 1. Update top bar
	top_panel.color = _panel_color
	card_name.text = data.card_name.to_upper()
	card_type.text = "STORY BANE" if data.card_type == CardType.STORY_BANE else CardType.keys()[data.card_type]
	card_level.text = str(data.card_level)
	bottom_panel.color = _panel_color
	
	# 2. Update Story Bane panel
	story_bane_panel.visible = _card_instance.is_story_bane
	story_bane_panel.color = GuiUtils.get_color_for_card_type(data.story_bane_type)
	story_bane_type_text.text = CardType.keys()[data.story_bane_type]
	
	# 3. Update Checks section
	_update_checks_section()
	
	# 4. Update Powers
	GuiUtils.set_panel_color(powers_panel, _panel_color.lightened(.75))
	powers_text.text = StringUtils.replace_adventure_level(data.powers)
	recovery_label.visible = not data.recovery.is_empty()
	recovery_text.visible = not data.recovery.is_empty()
	recovery_text.text = StringUtils.replace_adventure_level(data.recovery)
	
	# 5. Update traits
	loot_panel.visible = data.is_loot
	GuiUtils.set_panel_color(traits_panel, _panel_color)
	_populate_traits(data.traits)


func _update_checks_section() -> void:
	var data := _card_instance.data
	
	# Set the label text.
	check_label.text = "CHECK TO DEFEAT" if _card_instance.is_bane else "CHECK TO ACQUIRE"
	check_label_panel.color = _panel_color.darkened(.75)
	
	var req: CheckRequirement = data.check_requirement
	if req.check_steps.is_empty(): return
	
	# --- Handle Check 1 ---
	var check_1: CheckStep = req.check_steps[0]
	GuiUtils.set_panel_color(skills_1_panel, _panel_color)
	_populate_skills(skills_1_container, check_1)
	dc_1_label.text = str(CardUtils.get_dc(check_1.base_dc, check_1.adventure_level_mult))
	
	# --- Handle Check 2 if needed ---
	var show_check_2 := req.mode in \
		[CheckRequirement.CheckMode.CHOICE, CheckRequirement.CheckMode.SEQUENTIAL]
	check_2_area.visible = show_check_2
	or_bar.visible = req.mode == CheckRequirement.CheckMode.CHOICE
	then_bar.visible = req.mode == CheckRequirement.CheckMode.SEQUENTIAL
	
	if show_check_2:
		assert(req.check_steps.size() == 2)
	else:
		return
	
	var check_2: CheckStep = req.check_steps[1]
	GuiUtils.set_panel_color(skills_2_panel, _panel_color)
	_populate_skills(skills_2_container, check_2)
	dc_2_label.text = str(CardUtils.get_dc(check_2.base_dc, check_2.adventure_level_mult))


func _populate_skills(container: VBoxContainer, check_step: CheckStep) -> void:
	# CRITICAL STEP: Clear out any old labels from a previous display.
	for child in container.get_children():
		child.queue_free()
	
	if check_step.category == CheckStep.CheckCategory.COMBAT:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 8)
		label.text = "COMBAT"
		container.add_child(label)
		return
	
	for skill_enum in check_step.allowed_skills:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 8)
		label.text = Skill.keys()[skill_enum]
		container.add_child(label)


func _populate_traits(traits: Array[String]) -> void:
	# CRITICAL STEP: Clear out any old labels from a previous display.
	for child in traits_container.get_children():
		child.queue_free()
	
	for card_trait in traits:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 8)
		label.text = card_trait.to_upper()
		traits_container.add_child(label)


func _on_card_clicked(card_display: Control) -> void:
	if not is_previewed:
		card_clicked.emit(card_display)


func _on_drag_started(_card: CardInstance) -> void:
	# Store initial state
	_original_pos = position
	_original_scale = scale
	_original_z_idx = z_index
	_is_dragging = true
	
	# Visual feedback
	z_index = 100 # Bring to front.
	scale *= 1.05


func _on_drag_updated(_card: CardInstance, delta: Vector2) -> void:
	if not _is_dragging: return
	
	position = _original_pos + delta


func _on_drag_ended(_card: CardInstance, _global_pos: Vector2) -> void:
	_is_dragging = false
	position = _original_pos
	scale = _original_scale
	z_index = _original_z_idx
