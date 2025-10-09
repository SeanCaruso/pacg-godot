class_name EncounterController
extends BaseProcessor

var _pc: PlayerCharacter
var _card: CardInstance

## Defines a custom callback to call if the encounter is successfully resolved.
var on_success: Callable


func _init(pc: PlayerCharacter, card: CardInstance):
	_pc = pc
	_card = card
	
	
func execute() -> void:
	var context := EncounterContext.new(_pc, _card)
	context.on_success = on_success
	Contexts.new_encounter(context)
	
	GameEvents.encounter_started.emit(_card)
	
	var processor_queue: Array[Task] = []
	processor_queue.append(EvasionEncounterProcessor.new())
	processor_queue.append(OnEncounterProcessor.new())
	
	if _card.is_villain and _pc.local_characters.size() != Contexts.game_context.characters.size():
		processor_queue.append(GuardLocationsEncounterProcessor.new())
	
	processor_queue.append(BeforeActingEncounterProcessor.new())
	processor_queue.append(AttemptChecksEncounterProcessor.new())
	processor_queue.append(AfterActingEncounterProcessor.new())
	processor_queue.append(ResolveEncounterProcessor.new())
	processor_queue.append(AvengeEncounterProcessor.new())
	
	if _card.is_villain:
		processor_queue.append(VillainEndEncounterProcessor.new())
	else:
		processor_queue.append(EndEncounterProcessor.new())
	
	TaskManager.push_queue(processor_queue)
