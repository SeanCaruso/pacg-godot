class_name EncounterContext
extends RefCounted

const EncounterPhase := preload("res://scripts/core/enums/encounter_phase.gd").EncounterPhase

var current_phase: EncounterPhase = EncounterPhase.ON_ENCOUNTER

var character: PlayerCharacter
var card: CardInstance

var _prohibited_traits: Dictionary = {} # PlayerCharacter -> Array[String]
var explore_effects: Array[BaseExploreEffect] = []

var check_result: CheckResult

# Flags/properties set by cards/powers
var ignore_before_acting_powers: bool = false
var ignore_after_acting_powers: bool = false
var resolvable_modifiers: Array[Callable] = []

# Convenience properties
var card_data: CardData:
	get: return card.data


func _init(pc: PlayerCharacter, encountered_card: CardInstance):
	character = pc
	card = encountered_card


func has_trait(traits: Array[String]) -> bool:
	print("Checking traits: ", traits)
	print("Card traits: ", card_data.traits)
	var result = traits.any(func(card_trait: String):
		var has_it = card_data.traits.has(card_trait)
		print("Checking trait '", card_trait, "': ", has_it)
		return has_it
	)
	print("Final result: ", result)
	return result


func add_prohibited_traits(pc: PlayerCharacter, traits: Array[String]):
	_prohibited_traits.get_or_add(pc, [])
	_prohibited_traits[pc].append_array(traits)


func get_prohibited_traits(pc: PlayerCharacter) -> Array[String]:
	if not _prohibited_traits.has(pc): return []
	return _prohibited_traits[pc] as Array[String]
