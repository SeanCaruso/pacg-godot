# vault_manager.gd
extends Node

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const CardType := preload("res://scripts/core/enums/card_type.gd").CardType


func draw(card_type: CardType) -> CardInstance:
	var cards := Cards.get_cards_in_location(CardLocation.VAULT).filter(
		func(c: CardInstance):
			return c.card_type == card_type
	)
	return null if cards.is_empty() else cards.pick_random()


func initialize(vault_def: VaultDefinition, adventure_level: int) -> void:
	# Clear existing vault
	var existing_vault := Cards.get_cards_in_location(Cards.CardLocation.VAULT)
	for card in existing_vault:
		Cards._all_cards.erase(card)
	
	_add_cards(vault_def.monsters, adventure_level)
	_add_cards(vault_def.barriers, adventure_level)
	_add_cards(vault_def.story_banes, adventure_level)
	_add_cards(vault_def.weapons)
	_add_cards(vault_def.spells)
	_add_cards(vault_def.armors)
	_add_cards(vault_def.items)
	_add_cards(vault_def.allies)
	_add_cards(vault_def.blessings)


func _add_cards(cards: Array[CardData], max_level: int = 99) -> void:
	for card in cards.filter(func(c: CardData): return c.card_level <= max_level):
		Cards.new_card(card)
