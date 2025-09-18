# skill_selection_dialog.gd
class_name SkillSelectionDialog
extends Control

const CheckVerb := preload("res://scripts/gameplay/resolvables/check_resolvable.gd").CheckVerb
const SkillDropdownPanel := preload("res://scenes/ui_objects/skill_selection_dialog/skill_dropdown_panel.gd")

# SkillSelectionDialog
@onready var skill_dropdown_panel: SkillDropdownPanel = %SkillDropdownPanel
@onready var check_type_panel: PanelContainer = %CheckTypePanel
@onready var check_label: Label = %CheckLabel
@onready var card_name_panel: PanelContainer = %CardNamePanel
@onready var card_name_label: Label = %CardNameLabel


func set_context(context: CheckContext) -> void:
	if not context.resolvable: return
	
	# Set up header area.
	check_label.text = "CHECK TO %s" % str(CheckVerb.find_key(context.resolvable.verb)).to_upper()
	card_name_label.text = str(context.resolvable.card).to_upper()
	GuiUtils.set_panel_color(card_name_panel, GuiUtils.get_color_for_card_type(context.resolvable.card.card_type))
	
	skill_dropdown_panel.set_check_context(context)
