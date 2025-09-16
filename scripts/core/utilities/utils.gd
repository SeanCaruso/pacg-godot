class_name Utils
extends RefCounted

static func intersect(array1: Array, array2: Array) -> Array:
	var arr1_dict = {}
	for i in array1:
		arr1_dict[i] = true
	
	var intersection = []
	for i in array2:
		if arr1_dict.get(i, false):
			intersection.append(i)
	
	return intersection
