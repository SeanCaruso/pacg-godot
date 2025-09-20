class_name ValerosLogic
extends CharacterLogicBase

const CardType := preload("res://scripts/core/enums/card_type.gd").CardType

var _valid_cards: Array[CardInstance]


func get_end_of_turn_power(pc: PlayerCharacter) -> CharacterPower:
	return pc.data.powers[1] if _is_valeros_end_enabled(pc) else null


func is_power_enabled(pc: PlayerCharacter, idx: int) -> bool:
	match idx:
		0:
			return _is_valeros_combat_enabled(pc)
		1:
			return _is_valeros_end_enabled(pc)
		2:
			return _is_valeros_avenge_enabled(pc)
	return false


func valeros_avenge() -> void:
	# TODO: Implement this
	print("Valeros avenges!")


func valeros_combat() -> void:
	var powers: Array[String] = \
		Contexts.check_context.context_data.get_or_add("character_powers", [] as Array[String])
	powers.append("valeros_combat")
	
	var resolvable := ValerosCombatResolvable.new(_valid_cards)
	Contexts.new_resolvable(resolvable)
	GameServices.game_flow.process()


func valeros_end() -> void:
	var resolvable := ValerosEndOfTurnResolvable.new(_valid_cards)
	var processor := NewResolvableProcessor.new(resolvable)
	GameServices.game_flow.interrupt(processor)
	GameServices.asm.commit()


func _is_valeros_avenge_enabled(pc: PlayerCharacter) -> bool:
	if not Contexts.encounter_context \
	or Contexts.encounter_context.current_phase != EncounterContext.EncounterPhase.AVENGE \
	or not Contexts.encounter_context.character.local_characters.has(pc) \
	or Contexts.encounter_context.character == pc:
		return false
	
	return not (pc.hand.is_empty() and pc.revealed_cards.is_empty())


func _is_valeros_combat_enabled(pc: PlayerCharacter) -> bool:
	if Contexts.current_resolvable is not CheckResolvable \
	or not Contexts.check_context.is_local(pc) \
	or not Contexts.check_context.is_combat_valid:
		return false
		
	var power_used: bool = Contexts.check_context.context_data.get("character_powers", []).has("valeros_combat")
	_valid_cards.assign(pc.hand)
	_valid_cards.append_array(pc.revealed_cards)
	_valid_cards = _valid_cards.filter(
		func(c: CardInstance):
			return c.card_type in [CardType.ARMOR, CardType.WEAPON]
	)
	
	return not power_used and not _valid_cards.is_empty()


func _is_valeros_end_enabled(pc: PlayerCharacter) -> bool:
	if not Contexts.turn_context \
	or Contexts.turn_context.current_phase != TurnContext.TurnPhase.END_OF_TURN_EFFECTS \
	or Contexts.turn_context.performed_character_power_ids.has("valeros_end"):
		return false
	
	_valid_cards.assign(pc.hand)
	_valid_cards.append_array(pc.discards)
	_valid_cards = _valid_cards.filter(
		func(c: CardInstance):
			return c.card_type in [CardType.ARMOR, CardType.WEAPON]
	)
	return not _valid_cards.is_empty()
