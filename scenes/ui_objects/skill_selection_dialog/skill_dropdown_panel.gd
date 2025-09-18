extends VBoxContainer

const D4_SPRITE := preload("res://assets/textures/d4.png")
const D6_SPRITE := preload("res://assets/textures/d6.png")
const D8_SPRITE := preload("res://assets/textures/d8.png")
const D10_SPRITE := preload("res://assets/textures/d10.png")
const D12_SPRITE := preload("res://assets/textures/d12.png")
const D20_SPRITE := preload("res://assets/textures/d20.png")
const DICE_DICT := {
	20: D20_SPRITE, 12: D12_SPRITE, 10: D10_SPRITE, 8: D8_SPRITE, 6: D6_SPRITE, 4: D4_SPRITE
}

const Skill := preload("res://scripts/core/enums/skill.gd").Skill
const SkillRow := preload("res://scenes/ui_objects/skill_selection_dialog/skill_row.gd")
const SKILL_ROW_SCENE := preload("res://scenes/ui_objects/skill_selection_dialog/skill_row.tscn")

var _context: CheckContext
var _card_color: Color
var _is_collapsed := true
var _skill_rows: Dictionary = {} # Skill -> SkillRow
var _skill_rows_height: float
var _initial_location_y: float

@onready var skill_rows_container: VBoxContainer = %SkillRowsContainer
@onready var left_arrow: TextureRect = %LeftArrow
@onready var skill_label: Label = %SkillLabel
@onready var right_arrow: TextureRect = %RightArrow
@onready var selected_skill_button: Button = %SelectedSkillButton


func _ready() -> void:
	_initial_location_y = position.y
	
	DialogEvents.valid_skills_changed.connect(_on_valid_skills_changed)


func set_check_context(context: CheckContext) -> void:
	_context = context
	_card_color = GuiUtils.get_color_for_card_type(context.resolvable.card.card_type)
	
	_on_valid_skills_changed(context.get_current_valid_skills())
	
	left_arrow.rotation_degrees = 180.0
	right_arrow.rotation_degrees = -180.0


func _on_row_clicked(skill: Skill) -> void:
	_context.used_skill = skill
	skill_label.text = Skill.find_key(skill).to_upper()
	
	for s: Skill in _skill_rows:
		var skill_row: SkillRow = _skill_rows[s]
		var target_color := Color.GRAY if s == skill else Color.BLACK
		GuiUtils.set_panel_color(skill_row, _card_color.lerp(target_color, 0.75))
	
	GameEvents.dice_pool_changed.emit(_context.dice_pool(GameServices.asm.staged_actions))


func _on_show_hide() -> void:
	var time := 0.3
	var target_y := _initial_location_y if _is_collapsed else _initial_location_y - _skill_rows_height
	var target_pos := position
	target_pos.y = target_y
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(self, "position", target_pos, time)
	tween.parallel().tween_property(left_arrow, "rotation_degrees", 0.0 if _is_collapsed else 180.0, time)
	tween.parallel().tween_property(right_arrow, "rotation_degrees", 0.0 if _is_collapsed else -180.0, time)
	
	_is_collapsed = not _is_collapsed


func _on_valid_skills_changed(skills: Array[Skill]) -> void:
	_skill_rows.clear()
	_skill_rows_height = 0
	
	for child in skill_rows_container.get_children():
		child.queue_free()
	
	var best_skill := _context.character.get_best_skill(skills)
	_context.used_skill = best_skill["skill"]
	
	for skill in skills:
		var skill_row: SkillRow = SKILL_ROW_SCENE.instantiate()
		skill_rows_container.add_child(skill_row)
		
		var pc_skill := _context.character.get_skill(skill)
		skill_row.die_image.texture = DICE_DICT[pc_skill["die"]]
		skill_row.die_text.text = "d%d" % pc_skill["die"]
		skill_row.bonus_label.text = "+ %d" % pc_skill["bonus"]
		skill_row.skill_label.text = str(Skill.find_key(skill)).to_pascal_case()
		skill_row.dc_label.text = str(_context.get_dc_for_skill(skill))
		
		var target_color := Color.GRAY if skill == best_skill["skill"] else Color.BLACK
		GuiUtils.set_panel_color(skill_row, _card_color.lerp(target_color, 0.75))
		
		skill_row.skill_row_overlay_button.pressed.connect(_on_row_clicked.bind(skill))
		
		_skill_rows[skill] = skill_row
		_skill_rows_height += skill_row.size.y
	
	skill_label.text = Skill.find_key(best_skill["skill"])
	
	position.y = _initial_location_y - _skill_rows_height if _is_collapsed else _initial_location_y
