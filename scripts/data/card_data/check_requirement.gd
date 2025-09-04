class_name CheckRequirement
extends Resource

enum CheckMode { SINGLE, CHOICE, SEQUENTIAL, NONE }

@export var mode: CheckMode = CheckMode.SINGLE
@export var check_steps: Array[CheckStep] = []
