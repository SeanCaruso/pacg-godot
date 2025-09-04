## Check sub-processor to handle rolling dice (including after rerolls).
class_name RollCheckDiceProcessor
extends BaseProcessor

var _contexts: ContextManager

func _init(game_services: GameServices):
	_contexts = game_services.contexts
	
	
func on_execute() -> void:
	if !_contexts.check_context or !_contexts.check_context.resolvable: return

	var check := _contexts.check_context
	var resolvable := check.resolvable
	var pc := resolvable.character
	var dc := check.get_dc()
	var dice_pool := check.dice_pool(check.committed_actions)
	var roll_total := dice_pool.roll()
	
	check.check_result = CheckResult.new(roll_total, dc, pc, check.is_combat_check, check.used_skill, check.traits)
	
	if resolvable.card is not CardInstance: return
	
	var card := resolvable.card as CardInstance
	var needs_reroll: bool = check.check_result.margin_of_success < card.data.reroll_threshold
	var cards_to_check := pc.hand
	cards_to_check.append_array(pc.displayed_cards)
	var has_reroll_options := cards_to_check.any(func(c: CardInstance): return !c.get_available_actions().is_empty())
	
	for pc_card in cards_to_check.filter(func(c: CardInstance): return !c.get_available_actions().is_empty()):
		print("%s has a reroll action" % pc_card)
		
		
	has_reroll_options |= !_contexts.check_context.context_data.get("rerollCards", []).is_empty()
	
	# If we don't need to reroll or we have no options, we're done!
	if !needs_reroll or !has_reroll_options:
		GameEvents.set_status_text.emit("Rolled %s: %d" % [dice_pool, roll_total])
		return
		
		
	GameEvents.set_status_text.emit("Rolled %s: %d... Reroll?" % [dice_pool, roll_total])
	var reroll_resolvable = RerollResolvable.new(pc, dice_pool, check)
	_contexts.new_resolvable(reroll_resolvable)
