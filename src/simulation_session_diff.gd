class_name SimulationSessionDiff
extends RefCounted


const DEFAULT_ACTION := "standby"
const DEFAULT_TROOPS := 1000
const POSITION_EPSILON := 0.0005


static func compare(before: Dictionary, after: Dictionary) -> Dictionary:
	var result := {
		"placements_added": [],
		"placements_removed": [],
		"placements_moved": [],
		"actions_changed": [],
		"troops_changed": [],
		"assignments_changed": [],
		"factions_added": [],
		"factions_removed": [],
		"factions_changed": [],
		"city_ownership_changed": [],
		"annotations_added": [],
		"annotations_removed": [],
		"annotations_changed": [],
		"strokes_added": [],
		"strokes_removed": [],
		"strokes_changed": [],
		"change_count": 0,
	}

	_compare_placements(
		_dictionary_value(before, "placements"),
		_dictionary_value(after, "placements"),
		result
	)
	_compare_sparse_values(
		_dictionary_value(before, "character_actions"),
		_dictionary_value(after, "character_actions"),
		DEFAULT_ACTION,
		"action",
		result["actions_changed"]
	)
	_compare_sparse_values(
		_dictionary_value(before, "character_troops"),
		_dictionary_value(after, "character_troops"),
		DEFAULT_TROOPS,
		"troops",
		result["troops_changed"]
	)

	var before_scenario := _dictionary_value(before, "scenario_state")
	var after_scenario := _dictionary_value(after, "scenario_state")
	_compare_record_sets(
		_index_records(_array_value(before_scenario, "factions"), "id"),
		_index_records(_array_value(after_scenario, "factions"), "id"),
		"factions",
		result
	)
	_compare_mapping_records(
		_array_value(before_scenario, "character_assignments"),
		_array_value(after_scenario, "character_assignments"),
		"character_id",
		"faction_id",
		"assignments_changed",
		result
	)
	_compare_mapping_records(
		_array_value(before_scenario, "city_ownership"),
		_array_value(after_scenario, "city_ownership"),
		"place_id",
		"faction_id",
		"city_ownership_changed",
		result
	)

	_compare_record_sets(
		_dictionary_value(before, "annotations"),
		_dictionary_value(after, "annotations"),
		"annotations",
		result
	)
	_compare_record_sets(
		_index_records(_array_from_variant(before.get("player_strokes", [])), "id"),
		_index_records(_array_from_variant(after.get("player_strokes", [])), "id"),
		"strokes",
		result
	)

	var count := 0
	for key in result.keys():
		if key == "change_count":
			continue
		var value: Variant = result[key]
		if value is Array:
			count += (value as Array).size()
	result["change_count"] = count
	return result


static func has_changes(diff: Dictionary) -> bool:
	return int(diff.get("change_count", 0)) > 0


static func _compare_placements(before: Dictionary, after: Dictionary, result: Dictionary) -> void:
	var ids := _union_sorted_keys(before, after)
	for character_id_value in ids:
		var character_id := str(character_id_value)
		var had_before := before.has(character_id)
		var has_after := after.has(character_id)
		if not had_before and has_after:
			var added := _placement_summary(character_id, _dictionary_variant(after.get(character_id, {})))
			(result["placements_added"] as Array).append(added)
		elif had_before and not has_after:
			var removed := _placement_summary(character_id, _dictionary_variant(before.get(character_id, {})))
			(result["placements_removed"] as Array).append(removed)
		elif had_before and has_after:
			var before_placement := _dictionary_variant(before.get(character_id, {}))
			var after_placement := _dictionary_variant(after.get(character_id, {}))
			if _placement_changed(before_placement, after_placement):
				(result["placements_moved"] as Array).append({
					"character_id": character_id,
					"from_place_id": str(before_placement.get("place_id", "")),
					"to_place_id": str(after_placement.get("place_id", "")),
					"from_x": float(before_placement.get("x", 0.5)),
					"from_y": float(before_placement.get("y", 0.5)),
					"to_x": float(after_placement.get("x", 0.5)),
					"to_y": float(after_placement.get("y", 0.5)),
				})


static func _placement_changed(before: Dictionary, after: Dictionary) -> bool:
	if str(before.get("place_id", "")) != str(after.get("place_id", "")):
		return true
	return (
		absf(float(before.get("x", 0.5)) - float(after.get("x", 0.5))) > POSITION_EPSILON
		or absf(float(before.get("y", 0.5)) - float(after.get("y", 0.5))) > POSITION_EPSILON
	)


static func _placement_summary(character_id: String, placement: Dictionary) -> Dictionary:
	return {
		"character_id": character_id,
		"place_id": str(placement.get("place_id", "")),
		"x": float(placement.get("x", 0.5)),
		"y": float(placement.get("y", 0.5)),
	}


static func _compare_sparse_values(before: Dictionary, after: Dictionary, default_value: Variant, field_name: String, output: Array) -> void:
	for record_id_value in _union_sorted_keys(before, after):
		var record_id := str(record_id_value)
		var before_value: Variant = before.get(record_id, default_value)
		var after_value: Variant = after.get(record_id, default_value)
		if before_value != after_value:
			output.append({
				"character_id": record_id,
				"from": before_value,
				"to": after_value,
				"field": field_name,
			})


static func _compare_mapping_records(before_records: Array, after_records: Array, id_key: String, value_key: String, output_key: String, result: Dictionary) -> void:
	var before := _record_value_map(before_records, id_key, value_key)
	var after := _record_value_map(after_records, id_key, value_key)
	var output: Array = result[output_key]
	for record_id_value in _union_sorted_keys(before, after):
		var record_id := str(record_id_value)
		var before_value := str(before.get(record_id, ""))
		var after_value := str(after.get(record_id, ""))
		if before_value != after_value:
			output.append({id_key: record_id, "from": before_value, "to": after_value})


static func _compare_record_sets(before: Dictionary, after: Dictionary, prefix: String, result: Dictionary) -> void:
	var added: Array = result["%s_added" % prefix]
	var removed: Array = result["%s_removed" % prefix]
	var changed: Array = result["%s_changed" % prefix]
	for record_id_value in _union_sorted_keys(before, after):
		var record_id := str(record_id_value)
		if not before.has(record_id):
			added.append(record_id)
		elif not after.has(record_id):
			removed.append(record_id)
		elif _stable_variant(before.get(record_id)) != _stable_variant(after.get(record_id)):
			changed.append(record_id)


static func _record_value_map(records: Array, id_key: String, value_key: String) -> Dictionary:
	var result := {}
	for record_value in records:
		if not record_value is Dictionary:
			continue
		var record := record_value as Dictionary
		var record_id := str(record.get(id_key, ""))
		if not record_id.is_empty():
			result[record_id] = str(record.get(value_key, ""))
	return result


static func _index_records(records: Array, id_key: String) -> Dictionary:
	var result := {}
	for record_value in records:
		if not record_value is Dictionary:
			continue
		var record := record_value as Dictionary
		var record_id := str(record.get(id_key, ""))
		if not record_id.is_empty():
			result[record_id] = record.duplicate(true)
	return result


static func _stable_variant(value: Variant) -> String:
	if value is Dictionary:
		var dictionary := value as Dictionary
		var keys := dictionary.keys()
		keys.sort_custom(func(a: Variant, b: Variant) -> bool: return str(a) < str(b))
		var parts: Array[String] = []
		for key in keys:
			parts.append("%s:%s" % [str(key), _stable_variant(dictionary[key])])
		return "{%s}" % ",".join(parts)
	if value is Array:
		var parts: Array[String] = []
		for item in value as Array:
			parts.append(_stable_variant(item))
		return "[%s]" % ",".join(parts)
	return var_to_str(value)


static func _union_sorted_keys(left: Dictionary, right: Dictionary) -> Array:
	var seen := {}
	for key in left.keys():
		seen[str(key)] = true
	for key in right.keys():
		seen[str(key)] = true
	var keys := seen.keys()
	keys.sort()
	return keys


static func _dictionary_value(source: Dictionary, key: String) -> Dictionary:
	return _dictionary_variant(source.get(key, {}))


static func _dictionary_variant(value: Variant) -> Dictionary:
	return (value as Dictionary) if value is Dictionary else {}


static func _array_value(source: Dictionary, key: String) -> Array:
	return _array_from_variant(source.get(key, []))


static func _array_from_variant(value: Variant) -> Array:
	return (value as Array) if value is Array else []
