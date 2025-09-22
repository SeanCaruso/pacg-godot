# debug_console.gd
extends VBoxContainer

var expression := Expression.new()

@onready var history: RichTextLabel = %History
@onready var input: LineEdit = %Input


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		input.clear()


func _ready() -> void:
	input.text_submitted.connect(_on_text_submitted)
	visibility_changed.connect(_on_visibility_changed)


func close() -> void:
	var loc := Contexts.game_context.active_character.location
	out("\t- Closing %s" % loc.name)
	visible = false
	
	var processor := CloseLocationController.new(loc)
	GameServices.game_flow.start_phase(processor, "Close %s" % loc.name)


func out(text: String) -> void:
	history.add_text(text + "\n")


func _on_text_submitted(command: String) -> void:
	input.clear()
	out(command)
	
	if has_method(command):
		call(command)
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
