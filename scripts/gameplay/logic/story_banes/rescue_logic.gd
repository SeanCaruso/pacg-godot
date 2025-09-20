class_name RescueLogic
extends CardLogicBase


func get_available_card_actions(card: CardInstance) -> Array[StagedAction]:
	# Freely recharge an ally for +1d4.
	if card.card_type != CardType.ALLY \
	or not Contexts.check_context \
	or Contexts.check_context.character != card.owner:
		return []
	
	var modifier := CheckModifier.new(card)
	modifier.added_dice = [4]
	
	return [PlayCardAction.new(card, Action.RECHARGE, modifier, {"IsFreely": true})]


func on_defeated(card: CardInstance) -> void:
	# TODO: Draw a new ally that lists Diplomacy in its check to acquire from the Vault.
	print("Rescue on defeat logic not implemented yet!")
	super.on_defeated(card)
