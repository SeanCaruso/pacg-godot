class_name ICard
extends RefCounted

const CardType            := preload("res://scripts/core/enums/card_type.gd").CardType
var name: String          =  ""
var card_type: CardType   =  CardType.NONE
var traits: Array[String] =  []
