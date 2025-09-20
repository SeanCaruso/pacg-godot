class_name DireBadgerLogic
extends CardLogicBase


func get_resolve_encounter_resolvable(card: CardInstance) -> BaseResolvable:
	var result := Contexts.encounter_context.check_result
	
	if result.was_success and result.is_combat:
		return DamageResolvable.new(
			Contexts.encounter_context.character,
			DiceUtils.roll(4)
		)
	
	return null


func on_undefeated(card: CardInstance) -> void:
	# If undefeated, shuffle into a random location.
	var locations := Contexts.game_context.locations
	var new_location := locations[DiceUtils.roll(locations.size()) - 1]
	new_location.shuffle_in(card, true)
	
	print("[DireBadgerLogic] %s shuffled into %s." % [card, new_location])
