class_name EncounterContext
extends RefCounted

enum EncounterPhase {
	ON_ENCOUNTER,
	EVASION,
	BEFORE_ACTING,
	ATTEMPT_CHECK,
	AFTER_ACTING,
	RESOLVE,
	AVENGE
}

var current_phase: EncounterPhase = EncounterPhase.ON_ENCOUNTER

var character: PlayerCharacter
var card: CardInstance

var prohibited_traits: Dictionary = {} # PlayerCharacter -> Array[String]
var explore_effects: Array[BaseExploreEffect] = []

var check_result: CheckResult

# Flags/properties set by cards/powers
var ignore_after_acting_powers: bool = false
var resolvable_modifiers: Array[Callable] = []

# Convenience properties
var card_data: CardData:
	get: return card.data

func _init(pc: PlayerCharacter, encountered_card: CardInstance):
	character = pc
	card = encountered_card

func has_trait(traits: Array[String]) -> bool:
	return traits.any(func(card_trait: String): card_data.traits.has(card_trait))

func add_prohibited_traits(pc: PlayerCharacter, traits: Array[String]):
	prohibited_traits.get_or_add(pc, [])
	prohibited_traits[pc].append_array(traits)
