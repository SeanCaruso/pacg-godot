class_name TraitAccumulator
extends RefCounted

var _added_traits: Dictionary = {} # ICard -> Array[String]
var _required_traits: Dictionary = {} # ICard -> Array[String]
var _prohibited_traits: Dictionary = {} # ICard -> Array[String]

var traits: Array[String]:
	get:
		var trait_list: Array[String] = []
		for card_traits in _added_traits.values():
			trait_list.append_array(card_traits)
		return trait_list

var required_traits: Array[String]:
	get:
		var trait_list: Array[String] = []
		for card_traits in _required_traits.values():
			trait_list.append_array(card_traits)
		return trait_list

func prohibited_traits(pc: PlayerCharacter) -> Array[String]:
	var trait_list: Array[String] = []
	var pc_cards := _prohibited_traits.keys().filter(func(card): return card is CardInstance and card.owner == pc)

	for card in pc_cards:
		trait_list.append_array(_prohibited_traits[card])

	return trait_list
	

func _init(resolvable: CheckResolvable):
	if not resolvable: return
	
	add_traits(resolvable.card, resolvable.card.traits)
	add_traits(resolvable.pc, resolvable.pc.traits)
	
	
func add_traits(card: ICard, _traits: Array[String]):
	_added_traits[card] = _traits.duplicate()
	
	
func add_required_traits(card: ICard, _traits: Array[String]):
	_required_traits[card] = _traits.duplicate()
	
	
func add_prohibited_traits(card: ICard, _traits: Array[String]):
	_prohibited_traits[card] = _traits.duplicate()
