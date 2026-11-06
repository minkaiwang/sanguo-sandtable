class_name CharacterCatalogReferencePolicy
extends RefCounted


static func validate_payload_references(
	cards_value: Variant,
	scenario_state_value: Variant,
	character_states_value: Variant,
	character_actions_value: Variant,
	allowed_character_ids_value: Variant,
	character_troops_value: Variant = {"records": []}
) -> Dictionary:
	if not allowed_character_ids_value is Array:
		return _failure("allowed_ids_not_array", "人物目录 ID 必须是数组。")
	var allowed_ids := {}
	for character_id_value in allowed_character_ids_value:
		if not character_id_value is String:
			return _failure("invalid_allowed_id", "人物目录 ID 必须是字符串。")
		var character_id := str(character_id_value).strip_edges()
		if character_id.is_empty() or allowed_ids.has(character_id):
			return _failure("invalid_or_duplicate_allowed_id", "人物目录 ID 为空或重复：%s。" % character_id)
		allowed_ids[character_id] = true

	var cards_result := _validate_record_list(cards_value, "character_id", "cards", allowed_ids)
	if not bool(cards_result.get("ok", false)):
		return cards_result
	if not scenario_state_value is Dictionary:
		return _failure("scenario_state_not_dictionary", "玩法势力状态必须是对象。")
	var featured_result := _validate_id_list(
		(scenario_state_value as Dictionary).get("featured_character_ids", []),
		"featured_character_ids",
		allowed_ids
	)
	if not bool(featured_result.get("ok", false)):
		return featured_result
	var assignments_result := _validate_record_list(
		(scenario_state_value as Dictionary).get("character_assignments", null),
		"character_id",
		"character_assignments",
		allowed_ids
	)
	if not bool(assignments_result.get("ok", false)):
		return assignments_result
	if not character_states_value is Dictionary:
		return _failure("character_states_not_dictionary", "人物四维覆盖必须是对象。")
	var states_result := _validate_record_list(
		(character_states_value as Dictionary).get("records", null),
		"character_id",
		"character_states",
		allowed_ids
	)
	if not bool(states_result.get("ok", false)):
		return states_result
	if not character_actions_value is Dictionary:
		return _failure("character_actions_not_dictionary", "人物行动必须是对象。")
	var actions_result := _validate_record_list(
		(character_actions_value as Dictionary).get("records", null),
		"character_id",
		"character_actions",
		allowed_ids
	)
	if not bool(actions_result.get("ok", false)):
		return actions_result
	if not character_troops_value is Dictionary:
		return _failure("character_troops_not_dictionary", "人物兵力必须是对象。")
	var troops_result := _validate_record_list(
		(character_troops_value as Dictionary).get("records", null),
		"character_id",
		"character_troops",
		allowed_ids
	)
	if not bool(troops_result.get("ok", false)):
		return troops_result
	return {
		"ok": true,
		"allowed_character_count": allowed_ids.size(),
		"reference_family_count": 6,
		"card_count": int(cards_result.get("count", 0)),
		"featured_count": int(featured_result.get("count", 0)),
		"assignment_count": int(assignments_result.get("count", 0)),
		"state_count": int(states_result.get("count", 0)),
		"action_count": int(actions_result.get("count", 0)),
		"troop_count": int(troops_result.get("count", 0)),
	}


static func _validate_id_list(
	values: Variant,
	section: String,
	allowed_ids: Dictionary
) -> Dictionary:
	if not values is Array:
		return _failure("%s_not_array" % section, "%s 必须是数组。" % section)
	var seen_ids := {}
	for value in values:
		if not value is String:
			return _failure(
				"%s_invalid_character" % section,
				"%s 包含非字符串人物 ID。" % section
			)
		var character_id := str(value).strip_edges()
		if not allowed_ids.has(character_id):
			return _failure(
				"%s_unknown_character" % section,
				"%s 引用了当前目录无法识别的人物：%s。" % [section, character_id]
			)
		if seen_ids.has(character_id):
			return _failure(
				"%s_duplicate_character" % section,
				"%s 重复引用人物：%s。" % [section, character_id]
			)
		seen_ids[character_id] = true
	return {"ok": true, "count": seen_ids.size()}


static func _validate_record_list(
	records_value: Variant,
	id_field: String,
	section: String,
	allowed_ids: Dictionary
) -> Dictionary:
	if not records_value is Array:
		return _failure("%s_not_array" % section, "%s 必须是数组。" % section)
	var seen_ids := {}
	for index in range((records_value as Array).size()):
		var record_value: Variant = (records_value as Array)[index]
		if not record_value is Dictionary:
			return _failure(
				"%s_record_not_dictionary" % section,
				"%s 第 %d 条记录必须是对象。" % [section, index + 1]
			)
		var character_id := str((record_value as Dictionary).get(id_field, "")).strip_edges()
		if character_id.is_empty():
			return _failure("%s_empty_character" % section, "%s 含空人物 ID。" % section)
		if not allowed_ids.has(character_id):
			return _failure(
				"%s_unknown_character" % section,
				"%s 引用了当前目录无法识别的人物：%s。" % [section, character_id]
			)
		if seen_ids.has(character_id):
			return _failure(
				"%s_duplicate_character" % section,
				"%s 重复引用人物：%s。" % [section, character_id]
			)
		seen_ids[character_id] = true
	return {"ok": true, "count": seen_ids.size()}


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
