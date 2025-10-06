class_name EncounterController
extends BaseProcessor

var _pc: PlayerCharacter
var _card: CardInstance


func _init(pc: PlayerCharacter, card: CardInstance):	
	_pc = pc
	_card = card
	
	
func execute() -> void:
	Contexts.new_encounter(EncounterContext.new(_pc, _card))
	GameEvents.encounter_started.emit(_card)
	
	if _card.is_villain:
		TaskManager.push(VillainEndEncounterProcessor.new())
	else:
		TaskManager.push(EndEncounterProcessor.new())
	
	TaskManager.push(AvengeEncounterProcessor.new())
	TaskManager.push(ResolveEncounterProcessor.new())
	TaskManager.push(AfterActingEncounterProcessor.new())
	TaskManager.push(AttemptChecksEncounterProcessor.new())
	TaskManager.push(BeforeActingEncounterProcessor.new())
	
	if _card.is_villain and _pc.local_characters.size() != Contexts.game_context.characters.size():
		TaskManager.push(GuardLocationsEncounterProcessor.new())
	
	TaskManager.push(OnEncounterProcessor.new())
	TaskManager.push(EvasionEncounterProcessor.new())
