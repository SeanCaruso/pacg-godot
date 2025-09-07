class_name CheckResolvable
extends BaseResolvable

const CheckCategory := preload("res://scripts/data/card_data/check_step.gd").CheckCategory
enum CheckVerb { DEFEAT, ACQUIRE, CLOSE, RECOVER }
var card: ICard
var verb: CheckVerb
var character: PlayerCharacter
var check_steps: Array[CheckStep]

var has_combat: bool:
	get: return check_steps.any(func(step: CheckStep): return step.category == CheckCategory.COMBAT)

var has_skill: bool:
	get: return check_steps.any(func(step: CheckStep): return step.category == CheckCategory.SKILL)

var on_success: Callable = func(): pass
var on_failure: Callable = func(): pass
# Dependency injection
var _asm: ActionStagingManager


func _init(_card: ICard, _character: PlayerCharacter, check_requirement: CheckRequirement, game_services: GameServices):
	_asm = game_services.asm

	card = _card
	character = _character
	check_steps = check_requirement.check_steps

	# Default to defeat for banes, acquire for boons
	verb = CheckVerb.ACQUIRE if CardTypes.is_boon(card.card_type) else CheckVerb.DEFEAT


func can_commit(_actions: Array[StagedAction]) -> bool:
	return true


func create_processor(_game_services: GameServices) -> BaseProcessor:
	return CheckController.new(self, _game_services)


func get_ui_state(actions: Array[StagedAction]) -> StagedActionsState:
	var state := StagedActionsState.new()
	state.is_cancel_button_visible = actions.size() > 0
	state.is_commit_button_visible =true
	return state


func can_stage_action(_action: StagedAction) -> bool:
	return _action.is_freely or can_stage_type(_action.card.card_type)


func can_stage_type(card_type: CardType) -> bool:
	var staged_actions := _asm.staged_actions
	return staged_actions.count(func(a: StagedAction): return a.card.card_type == card_type and !a.is_freely) == 0
