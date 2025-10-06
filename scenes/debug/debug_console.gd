# debug_console.gd
extends VBoxContainer

var expression := Expression.new()

@onready var history: RichTextLabel = %History
@onready var input: LineEdit = %Input


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		input.clear()
		input.grab_focus.call_deferred()


func _ready() -> void:
	input.text_submitted.connect(_on_text_submitted)
	visibility_changed.connect(_on_visibility_changed)


func close() -> void:
	var loc := Contexts.game_context.active_character.location
	out("\t- Closing %s" % loc.name)
	visible = false
	
	var processor := CloseLocationController.new(loc)
	TaskManager.start_task(processor)


func draw(card_name: String) -> void:
	var card := TestUtils.get_card(card_name)
	if not card:
		out("Unable to find card: %s" % card_name)
	
	Contexts.game_context.active_character.add_to_hand(card)


func examine(loc_name: String) -> void:
	var loc: Array[Location] = Contexts.game_context.locations.filter(
		func(l: Location):
			return l.name.to_upper() == loc_name.to_upper()
	)
	if loc.is_empty():
		out("Unable to find location: \"%s\"" % loc_name)
		return
	
	var context := ExamineContext.new()
	context.examine_mode = ExamineContext.Mode.SCROLL
	context.cards = loc[0].cards
	context.unknown_count = 0
	context.can_reorder = true
	context.on_close = func(): pass
	
	DialogEvents.examine_event.emit(context)


func find(card_name: String) -> void:
	for location in Contexts.game_context.locations:
		var idx := location.cards.find_custom(
			func(c: CardInstance):
				return c.name.to_lower() == card_name.to_lower()
		)
		if idx < 0:
			continue
		
		out("Found %s in %s at index %d." % [card_name, location.name, idx])
		return
	
	out("Couldn't find %s!" % card_name)


func help() -> void:
	for method in get_method_list():
		out(method["name"])


func move(pc_name: String, loc_name: String) -> void:
	var pc: PlayerCharacter
	for _pc in Contexts.game_context.characters:
		if _pc.name.to_lower() == pc_name.to_lower():
			pc = _pc
			break
	
	if not pc:
		out("Unable to find character: %s" % pc_name)
		return
	
	var loc: Location
	for _loc in Contexts.game_context.locations:
		if _loc.name.to_lower() == loc_name.to_lower():
			loc = _loc
			break
	
	if not loc:
		out("Unable to find location: %s" % loc_name)
		return
	
	pc.location = loc
	GameEvents.pc_location_changed.emit(pc)


func movecard(card_name: String) -> void:
	for loc in Contexts.game_context.locations:
		loc.cards = loc.cards.filter(func(c: CardInstance): return c.name.to_lower() != card_name.to_lower())
	
	var card := TestUtils.get_card(card_name)
	if not card:
		out("Unable to find card: %s" % card_name)
	
	Contexts.game_context.active_character.location._deck._cards.push_front(card)


func out(text: String) -> void:
	history.add_text(text + "\n")


func set_dc(dc_text: String) -> void:
	if not Contexts.check_context:
		out("check_context is null")
		return
	
	if not dc_text.is_valid_int():
		out("Invalid DC: %s" % dc_text)
		return
	
	var dc := dc_text.to_int()
	Contexts.check_context.get_active_check_step().base_dc = dc


func _on_text_submitted(command: String) -> void:
	input.clear()
	out(command)
	
	var split_command := command.split(" ", false)
	if split_command.is_empty():
		return
	
	var method := split_command[0]
	var nargs := split_command.size() - 1
	
	if has_method(method):
		if get_method_argument_count(method) == nargs:
			callv(method, split_command.slice(1))
		else:
			out("Invalid arguments to method: %s" % method)
		return
	
	var error := expression.parse(command)
	if error != OK:
		out(expression.get_error_text())
		return
	var result = expression.execute()
	if not expression.has_execute_failed():
		out(str(result))


func _on_visibility_changed() -> void:
	if visible:
		input.editable = true
		input.grab_focus()
		input.call_deferred("clear")
	else:
		input.release_focus()
		input.editable = false
