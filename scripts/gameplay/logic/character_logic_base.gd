class_name CharacterLogicBase
extends Resource

func get_start_of_turn_power(_pc: PlayerCharacter) -> CharacterPower:
	return null


func get_end_of_turn_power(_pc: PlayerCharacter) -> CharacterPower:
	return null


func initialize() -> void:
	pass


func is_power_enabled(_pc: PlayerCharacter, _idx: int) -> bool:
	return false
