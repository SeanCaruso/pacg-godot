class_name RumbleRoadLogic
extends ScenarioLogicBase

const Scourge := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge

## We have an available turn action if the player has discarded cards or an applicable scourge and can freely explore.
func has_available_actions() -> bool:
	if Contexts.check_context \
	or not TaskManager.current_resolvable is FreePlayResolvable \
	or not Contexts.turn_context:
		return false
	
	var has_discards: bool = Contexts.turn_context.character.discards.size() > 0
	var has_scourge: bool = Contexts.turn_context.character.active_scourges.any(
		func(s: Scourge): return s in [Scourge.POISONED, Scourge.WOUNDED]
	)
	
	return (has_discards or has_scourge) and Contexts.turn_context.can_freely_explore


func invoke_action() -> void:
	if not Contexts.turn_context: return
	
	# Instead of the first exploration, heal 1d4 cards.
	var pc := Contexts.turn_context.character
	var amount := DiceUtils.roll(4)
	print("[%s] Healing %s for %d." % [get_script().get_global_name(), pc, amount])
	pc.heal(amount)
	
	Contexts.turn_context.can_give = false
	Contexts.turn_context.can_move = false
	Contexts.turn_context.can_freely_explore = false
	GameEvents.turn_state_changed.emit()


func on_villain_defeated() -> void:
	GameEvents.emit_game_ended(true)
