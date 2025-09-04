class_name DamageResolvable
extends BaseResolvable

const ActionType := preload("res://scripts/core/enums/action_type.gd").Action

var character: PlayerCharacter
var damage_type: String
var amount: int
var _current_resolved: int = 0
var _default_action_type: ActionType = ActionType.DISCARD

func override_action_type(action: ActionType) -> void:
	_default_action_type = action

# Dependency injection
var _asm: ActionStagingManager

func _init(pc: PlayerCharacter, _amount: int, game_services: GameServices, _damage_type: String = "Combat"):
	_asm = game_services.asm
	
	character = pc
	amount = _amount
	damage_type = _damage_type
	
	
func get_additional_actions_for_card(card: CardInstance) -> Array[StagedAction]:
	if _current_resolved >= amount: return []
	
	var actions: Array[StagedAction] = []
	# Add default damage discard action if the card was in the player's hand.
	if character.hand.has(card):
		actions.append(DefaultAction.new(card, _default_action_type))
	
	return actions
	
	
func can_commit(_actions: Array[StagedAction]) -> bool:
	if character.hand.is_empty():
		GameEvents.set_status_text.emit("")
		return true
	
	var total_resolved := 0
	for action in _actions:
		match action:
			DefaultAction:
				total_resolved += 1
			PlayCardAction:
				total_resolved += action.action_data.get("Damage", 0)
				amount = action.action_data.get("ReduceDamageTo", amount)
	
	
	_current_resolved = total_resolved
	
	if total_resolved >= amount:
		GameEvents.set_status_text.emit("")
		return true
	
	GameEvents.set_status_text.emit("Damage: Discard %d" % (amount - total_resolved))
	return false
