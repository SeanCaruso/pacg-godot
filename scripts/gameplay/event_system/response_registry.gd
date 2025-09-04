class_name ResponseRegistry
extends RefCounted

# Dictionary[String, Array[CardInstance]] - use class names as keys
var _response_registry: Dictionary = {}

func register_responses(card: CardInstance):
	if not card.logic:
		return
	
	var logic_script = card.logic.get_script()
	if not logic_script:
		return
	
	# Check if logic implements response interfaces
	if _implements_interface(card.logic, "IOnBeforeDiscardResponse"):
		_register_for_type("IOnBeforeDiscardResponse", card)
		
	# Add other response types as needed...

func unregister_responses(card: CardInstance):
	if not card.logic:
		return

	if _implements_interface(card.logic, "IOnBeforeDiscardResponse"):
		_unregister_for_type("IOnBeforeDiscardResponse", card)
	
func trigger_before_discard(args: DiscardEventArgs):
	var response_list = _response_registry.get("IOnBeforeDiscardResponse", [])
	for card in response_list:
		if card.logic.has_method("on_before_discard"):
			card.logic.on_before_discard(card, args)

# Helper methods
func _register_for_type(type_name: String, card: CardInstance):
	_response_registry.get_or_add(type_name, [])
	_response_registry[type_name].append(card)
	
func _unregister_for_type(type_name: String, card: CardInstance):
	if type_name in _response_registry:
		_response_registry[type_name].erase(card)

func _implements_interface(logic: CardLogicBase, interface_name: String) -> bool:
	# Check if the logic class has the required method.
	match interface_name:
		"IOnBeforeDiscardResponse":
			return logic.has_method("on_before_discard")
		# Add other interfaces as needed...
	return false
