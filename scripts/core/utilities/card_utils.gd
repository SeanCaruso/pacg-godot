class_name CardUtils
extends Node

static var _is_initialized: bool = false
static var adventure_number: int = 1

static func initialize(_adventure_number: int):
	_is_initialized = true
	adventure_number = _adventure_number

static func get_dc(base_dc: int, adventure_level_mult: int) -> int:
	if !_is_initialized:
		assert(false, "CardUtils MUST be initialized!!!")
	
	return base_dc + adventure_level_mult * adventure_number
		