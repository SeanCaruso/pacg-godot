class_name StringUtils
extends Node

static func replace_adventure_level(text: String) -> String:
	if not text.contains("#"): return text
	
	# RegEx pattern: (\d+)\+(#+)|#+
	# Matches either "number+#" or just "#" characters.
	var regex := RegEx.new()
	regex.compile(r"(\d+)\+(#+)|#+")
	
	var result := text
	for _match in regex.search_all(text):
		var full_match = _match.get_string()
		var replacement: String
		
		# Check if we have number+# pattern (group 1 exists)
		if _match.get_group_count() >= 2 and not _match.get_string(1).is_empty():
			var base_number := _match.get_string(1).to_int()
			var hash_count := _match.get_string(2).length()
			replacement = str(base_number + (CardUtils.adventure_number * hash_count))
		else:
			# Just # characters
			var count := full_match.length()
			replacement = str(count * CardUtils.adventure_number)
			
		result = result.replace(full_match, replacement)
	
	return result
