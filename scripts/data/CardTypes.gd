# CardTypes.gd
class_name CardTypes
extends RefCounted

enum CardType {
    # Boons
    ALLY, ARMOR, BLESSING, ITEM, SPELL, WEAPON,
    # Banes
    BARRIER, MONSTER, STORY_BANE,
    # Other
    NONE, # Used for Trait proficiencies
    CHARACTER, LOCATION, SCOURGE
}

# Helper functions
static func as_string(card_type: CardType) -> String:
    match card_type:
        CardType.STORY_BANE:
            return "STORY BANE"
        _:
            return CardType.keys()[card_type]
            
static func is_bane(card_type: CardType) -> bool:
    return card_type in [CardType.BARRIER, CardType.MONSTER, CardType.STORY_BANE]

static func is_boon(card_type: CardType) -> bool:
    return not is_bane(card_type)
