extends Node

const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

# Scenario events
signal scenario_has_power(game_services: GameServices)
signal scenario_power_enabled(enabled: bool)
signal scenario_has_danger(card: CardInstance)

# Turn phase events
signal turn_state_changed()
signal hour_changed(hour_card: CardInstance)
signal pc_location_changed(pc: PlayerCharacter)
signal encounter_started(card: CardInstance)
signal encounter_ended()

# Card staging events
signal staged_actions_state_changed(staged_actions_state: StagedActionsState)

# Card display events
signal card_location_changed(card: CardInstance, old_location: CardLocation)
signal card_locations_changed(cards: Array[CardInstance])

# Location events
signal location_power_enabled(power: LocationPower, is_enabled: bool)

# Player Character events
signal player_character_changed(pc: PlayerCharacter)
signal player_power_enabled(power: CharacterPower, is_enabled: bool)
signal player_deck_count_changed(_count: int)

# Special Resolvable events
signal player_choice_event(resolvable: PlayerChoiceResolvable)

# General game status events
signal set_status_text(text: String)
signal dice_pool_changed(dice_pool: DicePool)
