class_name DamageResolvable
extends BaseResolvable

const ActionType := preload("res://scripts/core/enums/action_type.gd").Action
const CardLocation := preload("res://scripts/core/enums/card_location.gd").CardLocation

var damage_type: String
var amount: int
var _current_resolved: int = 0
var _default_action_type: ActionType = ActionType.DISCARD
var _queried_for_responses := false


func override_action_type(action: ActionType) -> void:
	_default_action_type = action


func _init(_pc: PlayerCharacter, _amount: int, _damage_type: String = "Combat"):	
	pc = _pc
	amount = _amount
	damage_type = _damage_type
	
	
func get_additional_actions_for_card(card: CardInstance) -> Array[StagedAction]:
	if _current_resolved >= amount: return []
	
	var actions: Array[StagedAction] = []
	# Add default damage discard action if the card was in the player's hand.
	if pc.hand.has(card) or pc.revealed_cards.has(card):
		actions.append(DefaultAction.new(card, _default_action_type))
	
	return actions


func on_active() -> void:
	super()
	
	if _queried_for_responses: return
	_queried_for_responses = true
	
	var args := DiscardEventArgs.new(pc, [], CardLocation.HAND, self)
	Cards.trigger_before_discard(args)
	
	if args.has_responses:
		var options: Array[ChoiceOption] = []
		for response: CardResponse in args.card_responses:
			options.append(ChoiceOption.new(response.description, response.on_accept))
		options.append(ChoiceOption.new("Skip", func(): pass))
		
		var choice_resolvable = PlayerChoiceResolvable.new("Use Power?", options)		
		TaskManager.push(choice_resolvable)
	
	
func can_commit(_actions: Array[StagedAction]) -> bool:
	if pc.hand.is_empty():
		GameEvents.set_status_text.emit("")
		return true
	
	var total_resolved := 0
	for action in _actions:
		if action is DefaultAction:
			total_resolved += 1
		if action is PlayCardAction:
			total_resolved += action.action_data.get("Damage", 0)
			amount = action.action_data.get("ReduceDamageTo", amount)
	
	
	_current_resolved = total_resolved
	
	if total_resolved >= amount:
		GameEvents.set_status_text.emit("")
		return true
	
	GameEvents.set_status_text.emit("Damage: Discard %d" % (amount - total_resolved))
	return false


func can_stage_action(action: StagedAction) -> bool:
	return action.is_freely or can_stage_type(action.card.card_type)


func can_stage_type(card_type: CardType) -> bool:
	return not staged_actions.any(
		func(a: StagedAction):
			return a.card.card_type == card_type and not a.is_freely
	)
