class_name GuiUtils
extends Node

const CardType := preload("res://scripts/core/enums/card_type.gd").CardType

static func set_panel_color(panel: PanelContainer, color: Color):
	var stylebox = panel.get_theme_stylebox("panel")
	
	if not stylebox or not stylebox is StyleBoxFlat:
		stylebox = StyleBoxFlat.new()
	else:
		# Create a duplicate to avoid modifying shared resources
		stylebox = stylebox.duplicate()
	
	panel.add_theme_stylebox_override("panel", stylebox)
	(stylebox as StyleBoxFlat).bg_color = color


static func get_color_for_card_type(card_type: CardType) -> Color:
	match card_type:
		# Boons
		CardType.ALLY:
			return Color.from_rgba8(68, 98, 153)
		CardType.ARMOR:
			return Color.from_rgba8(170, 178, 186)
		CardType.BLESSING:
			return Color.from_rgba8(0, 172, 235)
		CardType.ITEM:
			return Color.from_rgba8(96, 133, 132)
		CardType.SPELL:
			return Color.from_rgba8(97, 46, 138)
		CardType.WEAPON:
			return Color.from_rgba8(93, 97, 96)

		# Banes	
		CardType.BARRIER:
			return Color.from_rgba8(240, 180, 29)
		CardType.MONSTER:
			return Color.from_rgba8(213, 112, 41)
		CardType.STORY_BANE:
			return Color.from_rgba8(130, 36, 38)

		# Other
		CardType.CHARACTER:
			return Color.DARK_GREEN
		CardType.LOCATION:
			return Color.from_rgba8(135, 113, 84)
		CardType.SCOURGE:
			return Color.DARK_GOLDENROD
		_:
			return Color.MAGENTA
