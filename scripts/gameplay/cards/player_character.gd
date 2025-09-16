class_name PlayerCharacter
extends ICard

const Action       := preload("res://scripts/core/enums/action_type.gd").Action
const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation
const Scourge      := preload("res://scripts/gameplay/effects/scourge_rules.gd").Scourge
const Skill        := preload("res://scripts/core/enums/skill.gd").Skill


func _to_string() -> String:
	return name

var data: CharacterData
var logic: CharacterLogicBase
var deck: Deck
var location: Location
var _skills: Dictionary = {} # Skill -> Dictionary["die": int, "bonus": int]


func get_skill(skill: Skill) -> Dictionary:
	return _skills.get(skill, {"die": 4, "bonus": 0})


var _skill_attrs: Dictionary = {} # Skill -> Skill


func get_attribute_for_skill(skill: Skill) -> Skill:
	return _skill_attrs.get(skill, skill)

var _active_scourges: Array[Scourge] = []

var active_scourges: Array[Scourge]:
	get: return _active_scourges


func add_scourge(scourge: Scourge) -> void:
	if _contexts.turn_context and _contexts.turn_context.character == self:
		for effect in _contexts.turn_context.explore_effects:
			if effect is ScourgeImmunityExploreEffect and effect.num_to_ignore > 0:
				effect.num_to_ignore -= 1
				return
	_active_scourges.append(scourge)


func remove_scourge(scourge: Scourge) -> void:
	_active_scourges.erase(scourge)

# Dependency injection
var _card_manager := GameServices.cards
var _contexts := GameServices.contexts


func _init(character_data: CharacterData):
	data = character_data
	logic = character_data.logic

	# Populate ICard members
	name = character_data.character_name
	card_type = CardType.CHARACTER
	traits = character_data.traits

	deck = Deck.new()

	for attr in character_data.attributes:
		_skills[attr.attribute] = { "die": attr.die, "bonus": attr.bonus }

	for skill in character_data.skills:
		_skills[skill.skill] = {
			"die": _skills[skill.attribute]["die"],
			"bonus": skill.bonus + _skills[skill.attribute]["bonus"]
		}
		_skill_attrs[skill.skill] = skill.attribute


func set_active() -> void:
	_contexts.game_context.active_character = self
	GameEvents.player_character_changed.emit(self)


# ==============================================================================
# SKILLS AND ATTRIBUTES
# ==============================================================================
func is_proficient(card: CardInstance) -> bool:
	for proficiency in data.proficiencies:
		var type_matches  := proficiency.card_type == card.card_type or proficiency.card_type == CardType.NONE
		var trait_matches := card.traits.has(proficiency.card_trait) or proficiency.card_trait.is_empty()

		if type_matches and trait_matches:
			return true

	return false


## Finds the character's best skill from the given options.
##
## The return value is a Dictionary with the following key-value pairs:[br]
## "skill": Skill - best skill[br]
## "die": int - attribute die for the skill[br]
## "bonus": int - the total bonus for the skill (attribute bonus plus skill bonus)
func get_best_skill(skills: Array[Skill]) -> Dictionary: # {"skill": Skill, "die": int, "bonus": int
	if skills.is_empty():
		assert(false, "get_best_skill called with empty skill list!")

	var best_skill := skills[0]
	var best_die   := 4
	var best_bonus := 0
	var best_avg   := 2.5

	for skill in skills:
		var value: Dictionary = _skills.get(skill, {"die": 4, "bonus": 0})

		var avg: float = (value["die"] / 2.0) + 0.5 + value["bonus"]
		if avg <= best_avg: continue
		best_skill = skill
		best_die = value["die"]
		best_bonus = value["bonus"]
		best_avg = avg

	return { "skill": best_skill, "die": best_die, "bonus": best_bonus }


# ==============================================================================
# CARD MOVEMENT INVOLVING THE PLAYER'S DECK
# ==============================================================================
func add_to_hand(card: CardInstance) -> void:
	if !card: return
	card.owner = self
	_card_manager.move_card_to(card, CardLocation.HAND)


func banish(card: CardInstance, force_to_vault: bool = false) -> void:
	if !card: return
	if force_to_vault:
		card.owner = null
		card.original_owner = null

	_card_manager.move_card_by(card, Action.BANISH)


func discard(card: CardInstance) -> void:
	if !card: return
	card.owner = self
	_card_manager.move_card_by(card, Action.DISCARD)


func draw_from_deck() -> CardInstance:
	if deck.count == 0:
		# TODO: Handle character death
		print("%s must draw but has no more cards left. %s dies!" % [self, self])
		return null

	var card := deck.draw_card()
	GameEvents.player_deck_count_changed.emit(deck.count)
	return card


func draw_initial_hand() -> void:
	# TODO: Handle multiple favored card types
	var fav := data.favored_cards[0]

	var card := deck.draw_first_card_with(fav.card_type, [fav.card_trait])
	if card:
		add_to_hand(card)

	draw_to_hand_size()


func draw_to_hand_size() -> void:
	var cards_to_draw := data.hand_size - hand.size()
	if cards_to_draw <= 0:
		return
	for i in range(cards_to_draw):
		add_to_hand(draw_from_deck())


func heal(amount: int, source: CardInstance = null):
	# If we're wounded, prompt to remove the scourge. Return without healing if removed.
	if (active_scourges.has(Scourge.WOUNDED)):
		ScourgeRules.prompt_for_wounded_removal(self)
		if !active_scourges.has(Scourge.WOUNDED):
			return
		
	var valid_cards := discards.filter(func(c: CardInstance): return c != source)
	amount = valid_cards.size() if valid_cards.size() < amount else amount
	for i in range(amount):
		var card = valid_cards.pick_random()
		valid_cards.erase(card)
		deck.shuffle_in(card)
		
		
func recharge(card: CardInstance) -> void:
	if !card or card.owner != self: return
	_card_manager.move_card_to(card, CardLocation.DECK)
	deck.recharge(card)
	
	
func reload(card: CardInstance) -> void:
	if !card or card.owner != self: return
	_card_manager.move_card_to(card, CardLocation.DECK)
	deck.reload(card)
	
	
func shuffle_into_deck(card: CardInstance) -> void:
	if !card: return
	card.owner = self
	_card_manager.move_card_to(card, CardLocation.DECK)
	deck.shuffle_in(card)


# ==============================================================================
# CONVENIENCE FUNCTIONS
# ==============================================================================
# Pass-throughs to CardManager
var all_cards: Array[CardInstance]:
	get: return _card_manager.get_all_cards_owned_by(self)
var hand: Array[CardInstance]:
	get: return _card_manager.get_cards_owned_by(self, CardLocation.HAND)
var discards: Array[CardInstance]:
	get: return _card_manager.get_cards_owned_by(self, CardLocation.DISCARDS)
var buried_cards: Array[CardInstance]:
	get: return _card_manager.get_cards_owned_by(self, CardLocation.BURIED)
var displayed_cards: Array[CardInstance]:
	get: return _card_manager.get_cards_owned_by(self, CardLocation.DISPLAYED)
var recovery_cards: Array[CardInstance]:
	get: return _card_manager.get_cards_owned_by(self, CardLocation.RECOVERY)
var revealed_cards: Array[CardInstance]:
	get: return _card_manager.get_cards_owned_by(self, CardLocation.REVEALED)
var deck_cards: Array[CardInstance]:
	get: return _card_manager.get_cards_owned_by(self, CardLocation.DECK)

# Pass-throughs to ContextManager
var local_characters: Array[PlayerCharacter]:
	get: return _contexts.game_context.get_characters_at(location) if location else []
var distant_characters: Array[PlayerCharacter]:
	get: return _contexts.game_context.characters.filter(func(pc: PlayerCharacter): return pc.location != location)

# Facade pattern for CharacterLogic
var start_of_turn_power: CharacterPower:
	get: return logic.get_start_of_turn_power(self) if logic else null
var end_of_turn_power: CharacterPower:
	get: return logic.get_end_of_turn_power(self) if logic else null
