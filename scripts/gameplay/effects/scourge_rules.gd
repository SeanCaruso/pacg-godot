class_name ScourgeRules
extends Node

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

enum Scourge {
	DAZED,
	DRAINED,
	ENTANGLED,
	EXHAUSTED,
	FRIGHTENED,
	POISONED,
	WOUNDED
}

# =============================================================================================================
# EXHAUSTED
# =============================================================================================================
static func prompt_for_exhausted_removal(pc: PlayerCharacter) -> void:
	var resolvable := PlayerChoiceResolvable.new("Remove Exhausted?",
		[ChoiceOption.new("Yes", func():
			pc.remove_scourge(Scourge.EXHAUSTED)
			var end_turn_controller := EndTurnController.new(false)
			GameServices.game_flow.start_phase(end_turn_controller, "Force End Turn")),
		ChoiceOption.new("No", func(): pass)])

	var processor = NewResolvableProcessor.new(resolvable)
	GameServices.game_flow.start_phase(processor, "Exhaustion Removal")

# =============================================================================================================
# WOUNDED
# =============================================================================================================
static func handle_wounded_deck_discard(pc: PlayerCharacter) -> void:
	var top_card := pc.draw_from_deck()
	if !top_card: return
	var args := DiscardEventArgs.new(pc, [top_card], CardLocation.DECK)
	GameServices.cards.trigger_before_discard(args)
	
	var default_discard := func default_discard() -> void:
		GameServices.cards.move_card_to(top_card, CardLocation.DISCARDS)
		
	if !args.has_responses:
		default_discard.call()
		return
		
	var options: Array[ChoiceOption] = []
	for response in args.card_responses:
		options.append(ChoiceOption.new(response.description, response.on_accept))
	options.append(ChoiceOption.new("Skip", default_discard))
	
	var choice_resolvable := PlayerChoiceResolvable.new("Use Power?", options)
	var processor := NewResolvableProcessor.new(choice_resolvable)
	GameServices.game_flow.start_phase(processor, "Wound Discard Options")


static func prompt_for_wounded_removal(pc: PlayerCharacter) -> void:
	var resolvable := PlayerChoiceResolvable.new("Remove Wounded?",
		[ChoiceOption.new("Yes", func(): pc.remove_scourge(Scourge.WOUNDED)),
		ChoiceOption.new("No", func(): pass)]
	)
	GameServices.contexts.new_resolvable(resolvable)
	
	var processor = NewResolvableProcessor.new(resolvable)
	GameServices.game_flow.start_phase(processor, "Wound Removal")
