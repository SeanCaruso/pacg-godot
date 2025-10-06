# custom_check_button.gd
extends Button

const CheckCategory := preload("res://scripts/data/card_data/check_step.gd").CheckCategory

var _resolvable: BaseResolvable


func _ready() -> void:
	DialogEvents.custom_check_encountered.connect(_on_custom_check_encountered)
	DialogEvents.skill_selection_ended.connect(_on_skill_selection_ended)
	
	GuiUtils.add_mouseover_effect_to_button(self)


func _on_custom_check_encountered() -> void:
	if not Contexts.encounter_context:
		return
	
	var card := Contexts.encounter_context.card
	_resolvable = card.get_custom_check_resolvable()
	if not _resolvable:
		return
	
	var steps := card.data.check_requirement.check_steps
	text = steps[0].custom_text if steps[0].category == CheckCategory.CUSTOM else steps[1].custom_text
	
	visible = true


func _on_pressed() -> void:
	if not Contexts.encounter_context:
		return
	
	var resolvable := Contexts.encounter_context.card.get_custom_check_resolvable()
	if not resolvable:
		return
		
	DialogEvents.emit_skill_selection_ended()
	visible = false
	
	TaskManager.push(resolvable)


func _on_skill_selection_ended() -> void:
	visible = false
