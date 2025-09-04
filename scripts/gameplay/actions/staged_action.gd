class_name StagedAction
extends RefCounted

const ActionType := preload("res://scripts/core/enums/action_type.gd").Action

var card: CardInstance
var action_type: ActionType
var is_freely: bool
var action_data: Dictionary = {} # String -> Variant

func commit() -> void:
	pass
