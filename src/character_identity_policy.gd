class_name CharacterIdentityPolicy
extends RefCounted


const CHARACTER_KEYS := [
	"id", "name", "group", "aliases", "source_refs", "affiliations"
]
const AFFILIATION_KEYS := [
	"id", "group_id", "relation_type", "layer", "period",
	"authority_character_id", "position_title", "source_refs",
	"source_locator", "confidence", "uncertainty_note"
]
const PERIOD_KEYS := ["start_year", "end_year", "precision", "note"]
const ALLOWED_GAMEPLAY_GROUPS := [
	"刘备军", "黄巾军", "汉廷", "群雄", "曹氏", "孙氏"
]
const ALLOWED_AFFILIATION_LAYERS := ["historical", "romance"]
const ALLOWED_AFFILIATION_RELATIONS := [
	"official", "leader", "subordinate", "member", "nominal_allegiance"
]
const ALLOWED_AFFILIATION_CONFIDENCE := [
	"text_explicit", "source_inferred", "approximate", "disputed"
]


static func decode_runtime_records(characters_value: Variant, catalog_ids_value: Variant) -> Dictionary:
	if not characters_value is Array:
		return _failure("characters_not_array", "人物身份数据顶层必须是数组。")
	if not catalog_ids_value is Array:
		return _failure("catalog_ids_not_array", "人物身份数据缺少目录 ID 数组。")
	var characters: Array = characters_value
	var catalog_ids: Array = catalog_ids_value
	if characters.size() != catalog_ids.size():
		return _failure("character_count_mismatch", "人物身份数据与目录人数不一致。")
	var known_character_ids := {}
	for character_id_value in catalog_ids:
		if not character_id_value is String:
			return _failure("invalid_catalog_id", "人物目录 ID 必须是字符串。")
		var character_id := str(character_id_value)
		if not _is_safe_id(character_id) or known_character_ids.has(character_id):
			return _failure("invalid_or_duplicate_catalog_id", "人物目录 ID 无效或重复：%s。" % character_id)
		known_character_ids[character_id] = true

	var decoded_characters: Array[Dictionary] = []
	var seen_affiliation_ids := {}
	var group_counts := {}
	var alias_count := 0
	var source_reference_count := 0
	var affiliation_count := 0
	for index in range(characters.size()):
		var record_result := _decode_character(
			characters[index],
			index,
			str(catalog_ids[index]),
			known_character_ids,
			seen_affiliation_ids
		)
		if not bool(record_result.get("ok", false)):
			return record_result
		var character: Dictionary = (record_result.get("character", {}) as Dictionary).duplicate(true)
		decoded_characters.append(character)
		var group := str(character.get("group", ""))
		group_counts[group] = int(group_counts.get(group, 0)) + 1
		alias_count += (character.get("aliases", []) as Array).size()
		source_reference_count += (character.get("source_refs", []) as Array).size()
		affiliation_count += (character.get("affiliations", []) as Array).size()
	return {
		"ok": true,
		"characters": decoded_characters,
		"character_count": decoded_characters.size(),
		"group_counts": group_counts,
		"alias_count": alias_count,
		"source_reference_count": source_reference_count,
		"affiliation_count": affiliation_count,
	}


static func _decode_character(
	value: Variant,
	index: int,
	expected_id: String,
	known_character_ids: Dictionary,
	seen_affiliation_ids: Dictionary
) -> Dictionary:
	if not value is Dictionary:
		return _failure("character_not_dictionary", "人物身份数据第 %d 条必须是对象。" % (index + 1))
	var character: Dictionary = value
	if not _has_exact_keys(character, CHARACTER_KEYS):
		return _failure("invalid_character_keys", "人物身份字段不完整或包含未登记字段：%s。" % expected_id)
	var character_id_value: Variant = character.get("id", null)
	if not character_id_value is String or str(character_id_value) != expected_id:
		return _failure("character_order_mismatch", "人物身份数据必须与目录稳定顺序完全一致：%s。" % expected_id)
	var display_name_value: Variant = character.get("name", null)
	if not display_name_value is String:
		return _failure("invalid_character_name", "人物显示名必须是字符串：%s。" % expected_id)
	var display_name := str(display_name_value)
	if display_name != display_name.strip_edges() or display_name.is_empty() or display_name.length() > 12:
		return _failure("invalid_character_name", "人物显示名必须是 1—12 字且不能带首尾空白：%s。" % expected_id)
	var group_value: Variant = character.get("group", null)
	if not group_value is String or not ALLOWED_GAMEPLAY_GROUPS.has(str(group_value)):
		return _failure("invalid_gameplay_group", "人物原型分类未登记：%s。" % expected_id)

	var aliases_result := _decode_string_array(
		character.get("aliases", null),
		"alias",
		expected_id,
		false,
		false
	)
	if not bool(aliases_result.get("ok", false)):
		return aliases_result
	var aliases: Array = aliases_result.get("values", [])
	if aliases.has(display_name):
		return _failure("alias_matches_name", "人物别名不得重复规范显示名：%s。" % expected_id)

	var sources_result := _decode_string_array(
		character.get("source_refs", null),
		"source_ref",
		expected_id,
		true,
		true
	)
	if not bool(sources_result.get("ok", false)):
		return sources_result
	var source_refs: Array = sources_result.get("values", [])
	var source_ref_set := {}
	for source_ref in source_refs:
		source_ref_set[str(source_ref)] = true

	var affiliations_value: Variant = character.get("affiliations", null)
	if not affiliations_value is Array:
		return _failure("affiliations_not_array", "人物历史归属缓存必须是数组：%s。" % expected_id)
	var decoded_affiliations: Array[Dictionary] = []
	for affiliation_value in affiliations_value:
		var affiliation_result := _decode_affiliation(
			affiliation_value,
			expected_id,
			known_character_ids,
			source_ref_set,
			seen_affiliation_ids
		)
		if not bool(affiliation_result.get("ok", false)):
			return affiliation_result
		decoded_affiliations.append((affiliation_result.get("affiliation", {}) as Dictionary).duplicate(true))
	return {
		"ok": true,
		"character": {
			"id": expected_id,
			"name": display_name,
			"group": str(group_value),
			"aliases": aliases.duplicate(),
			"source_refs": source_refs.duplicate(),
			"affiliations": decoded_affiliations,
		},
	}


static func _decode_affiliation(
	value: Variant,
	character_id: String,
	known_character_ids: Dictionary,
	character_source_refs: Dictionary,
	seen_affiliation_ids: Dictionary
) -> Dictionary:
	if not value is Dictionary:
		return _failure("affiliation_not_dictionary", "人物历史归属记录必须是对象：%s。" % character_id)
	var affiliation: Dictionary = value
	if not _has_exact_keys(affiliation, AFFILIATION_KEYS):
		return _failure("invalid_affiliation_keys", "人物历史归属字段不完整或包含未登记字段：%s。" % character_id)
	var affiliation_id_value: Variant = affiliation.get("id", null)
	if not affiliation_id_value is String:
		return _failure("invalid_affiliation_id", "人物历史归属 ID 必须是字符串：%s。" % character_id)
	var affiliation_id := str(affiliation_id_value)
	if not _is_safe_id(affiliation_id) or not affiliation_id.begins_with("aff_") or seen_affiliation_ids.has(affiliation_id):
		return _failure("invalid_or_duplicate_affiliation_id", "人物历史归属 ID 无效或重复：%s。" % affiliation_id)
	seen_affiliation_ids[affiliation_id] = true
	var group_id_value: Variant = affiliation.get("group_id", null)
	if not group_id_value is String or not _is_safe_id(str(group_id_value)):
		return _failure("invalid_affiliation_group", "人物历史归属实体 ID 无效：%s。" % affiliation_id)
	var relation_value: Variant = affiliation.get("relation_type", null)
	if not relation_value is String or not ALLOWED_AFFILIATION_RELATIONS.has(str(relation_value)):
		return _failure("invalid_affiliation_relation", "人物历史归属关系未登记：%s。" % affiliation_id)
	var layer_value: Variant = affiliation.get("layer", null)
	if not layer_value is String or not ALLOWED_AFFILIATION_LAYERS.has(str(layer_value)):
		return _failure("invalid_affiliation_layer", "人物历史归属层级无效：%s。" % affiliation_id)
	var confidence_value: Variant = affiliation.get("confidence", null)
	if not confidence_value is String or not ALLOWED_AFFILIATION_CONFIDENCE.has(str(confidence_value)):
		return _failure("invalid_affiliation_confidence", "人物历史归属置信度无效：%s。" % affiliation_id)
	var authority_value: Variant = affiliation.get("authority_character_id", null)
	if authority_value != null:
		if not authority_value is String or not known_character_ids.has(str(authority_value)):
			return _failure("unknown_affiliation_authority", "人物历史归属引用未知权威人物：%s。" % affiliation_id)
	for field in ["position_title", "source_locator", "uncertainty_note"]:
		var text_value: Variant = affiliation.get(field, null)
		if not text_value is String or str(text_value).strip_edges().is_empty():
			return _failure("invalid_affiliation_text", "人物历史归属缺少 %s：%s。" % [field, affiliation_id])
	var sources_result := _decode_string_array(
		affiliation.get("source_refs", null),
		"affiliation_source_ref",
		affiliation_id,
		true,
		true
	)
	if not bool(sources_result.get("ok", false)):
		return sources_result
	for source_ref in sources_result.get("values", []):
		if not character_source_refs.has(str(source_ref)):
			return _failure("affiliation_source_not_cached", "历史归属来源未进入人物来源缓存：%s。" % affiliation_id)
	var period_result := _decode_period(affiliation.get("period", null), affiliation_id)
	if not bool(period_result.get("ok", false)):
		return period_result
	var decoded := affiliation.duplicate(true)
	decoded["period"] = (period_result.get("period", {}) as Dictionary).duplicate(true)
	decoded["source_refs"] = (sources_result.get("values", []) as Array).duplicate()
	return {"ok": true, "affiliation": decoded}


static func _decode_period(value: Variant, affiliation_id: String) -> Dictionary:
	if not value is Dictionary:
		return _failure("affiliation_period_not_dictionary", "人物历史归属时期必须是对象：%s。" % affiliation_id)
	var period: Dictionary = value
	if not _has_exact_keys(period, PERIOD_KEYS):
		return _failure("invalid_affiliation_period_keys", "人物历史归属时期字段不完整或包含未登记字段：%s。" % affiliation_id)
	var start_value: Variant = period.get("start_year", null)
	var end_value: Variant = period.get("end_year", null)
	if not _is_integer_number(start_value) or not _is_integer_number(end_value) or int(start_value) > int(end_value):
		return _failure("invalid_affiliation_period", "人物历史归属起止年份无效：%s。" % affiliation_id)
	if str(period.get("precision", "")) != "year":
		return _failure("invalid_affiliation_precision", "当前人物历史归属时期精度必须为 year：%s。" % affiliation_id)
	var note_value: Variant = period.get("note", null)
	if not note_value is String or str(note_value).strip_edges().is_empty():
		return _failure("missing_affiliation_period_note", "人物历史归属时期缺少边界说明：%s。" % affiliation_id)
	return {
		"ok": true,
		"period": {
			"start_year": int(start_value),
			"end_year": int(end_value),
			"precision": "year",
			"note": str(note_value),
		},
	}


static func _decode_string_array(
	value: Variant,
	field: String,
	record_id: String,
	require_nonempty: bool,
	require_safe_id: bool
) -> Dictionary:
	if not value is Array:
		return _failure("%s_not_array" % field, "%s 必须是数组：%s。" % [field, record_id])
	var values: Array = value
	if require_nonempty and values.is_empty():
		return _failure("missing_%s" % field, "%s 不得为空：%s。" % [field, record_id])
	var decoded: Array[String] = []
	var seen := {}
	for item_value in values:
		if not item_value is String:
			return _failure("invalid_%s" % field, "%s 必须只含字符串：%s。" % [field, record_id])
		var item := str(item_value)
		if item != item.strip_edges() or item.is_empty() or seen.has(item):
			return _failure("duplicate_or_empty_%s" % field, "%s 含空白或重复值：%s。" % [field, record_id])
		if require_safe_id and not _is_safe_id(item):
			return _failure("invalid_%s" % field, "%s 含无效 ID：%s。" % [field, record_id])
		seen[item] = true
		decoded.append(item)
	return {"ok": true, "values": decoded}


static func _has_exact_keys(record: Dictionary, allowed: Array) -> bool:
	if record.size() != allowed.size():
		return false
	for key_value in record.keys():
		if not allowed.has(str(key_value)):
			return false
	return true


static func _is_integer_number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] \
		and is_finite(float(value)) \
		and is_equal_approx(float(value), roundf(float(value)))


static func _is_safe_id(value: String) -> bool:
	if value.is_empty() or value.length() > 96:
		return false
	var pattern := RegEx.new()
	return pattern.compile("^[a-z0-9][a-z0-9_]*$") == OK and pattern.search(value) != null


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
