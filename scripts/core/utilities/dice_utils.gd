class_name DiceUtils
extends RefCounted

static func roll(sides: int) -> int:
	return randi_range(1, sides)
	
	
static func roll_dice(count: int, sides: int) -> int:
	var total := 0
	for i in range(count):
		total += randi_range(1, sides)
		
		
	return total
