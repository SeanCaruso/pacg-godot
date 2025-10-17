class_name VillainEndEncounterProcessor
extends BaseProcessor

const CardType := preload("res://scripts/core/enums/card_type.gd").CardType


func execute() -> void:
	if not Contexts.encounter_context \
	or not Contexts.encounter_context.check_result:
		return
	
	var was_success := Contexts.encounter_context.check_result.was_success
	var card := Contexts.encounter_context.card
	
	var guarded_locs: Dictionary = {}
	if Contexts.turn_context and Contexts.turn_context.guard_locations_resolvable:
		guarded_locs = Contexts.turn_context.guard_locations_resolvable.distant_locs_guarded
	
	var escape_locs: Array[Location] = []
	for loc in Contexts.game_context.locations:
		if not guarded_locs.get(loc, false):
			escape_locs.append(loc)
	
	if was_success:
		escape_locs.erase(Contexts.encounter_pc_location)
	
	# If there's nowhere to escape to, the villain was successfully defeated.
	if escape_locs.is_empty():
		if Contexts.game_context.scenario_logic:
			Contexts.game_context.scenario_logic.on_villain_defeated()
		else:
			push_warning("No scenario logic: defaulting to win")
			GameEvents.emit_game_ended(true)
		return
	
	var num_blessings := escape_locs.size() - 1
	# If the villain wasn't defeated and there aren't enough blessings, we lose.
	if not was_success and Contexts.game_context.hour_deck.count < num_blessings:
		GameEvents.emit_game_ended(false)
		return
	
	var escape_cards: Array[CardInstance] = []
	escape_cards.append(Contexts.encounter_context.card)
	for i in range(num_blessings):
		var blessing: CardInstance
		if was_success:
			blessing = Vault.draw(CardType.BLESSING)
		else:
			blessing = Contexts.game_context.hour_deck.draw_card()
		if not blessing:
			push_error("Got a null blessing... something went horribly wrong.")
			return
		
		escape_cards.append(blessing)
	
	for loc in escape_locs:
		var loc_card: CardInstance = escape_cards.pick_random()
		loc.shuffle_in(loc_card, false)
		escape_cards.erase(loc_card)
	
	GameEvents.encounter_ended.emit()
