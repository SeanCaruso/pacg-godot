class_name StagedAction
extends RefCounted

const ActionType := preload("res://scripts/core/enums/action_type.gd").Action

var card: CardInstance
var action_type: ActionType
var is_freely: bool
var action_data: Dictionary = {} # String -> Variant

var label: String:
	get:
		return ActionType.find_key(action_type)


func _to_string() -> String:
	return "%s %s" % [ActionType.find_key(action_type), card]


func commit() -> void:
	pass


func on_stage() -> void:
	pass
