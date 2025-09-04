class_name DicePool
extends RefCounted

var _dice: Dictionary = {} # Dictionary[int, int] - Sides -> count
var _bonus: int       = 0


func add_dice(count: int, sides: int, bonus: int = 0):
	_dice.get_or_add(sides, 0)
	_dice[sides] += count
	_bonus += bonus


func add_bonus(bonus: int):
	_bonus += bonus


func num_dice(sides: int):
	return _dice.get(sides, 0)


func roll():
	var roll_result := _bonus
	for sides in _dice:
		roll_result += DiceUtils.roll_dice(sides, _dice[sides])

	return roll_result


func _to_string() -> String:
	var retval       := ""
	var sorted_sides := _dice.keys()
	sorted_sides.sort()
	sorted_sides.reverse()
	for sides in sorted_sides:
		retval += "" if retval.is_empty() else " + "
		retval += "%dd%d" % [_dice[sides], sides]

	retval += "" if _bonus == 0 else " + %d" % _bonus
	return retval
		
