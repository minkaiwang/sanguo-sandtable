class_name CharacterArchiveData
extends RefCounted

## 首页“人物志”的正式资料适配器。
##
## 只读取当前运行目录 v6 的 90 位正式人物，不读取研究候选，不访问 user://，
## 不提供编辑、保存或提升入口。

const CharacterIdentityPolicyScript = preload("res://src/character_identity_policy.gd")
const CharacterProfilePolicyScript = preload("res://src/character_profile_policy.gd")

const CATALOG_PATH := "res://data/character_catalog.json"
const CHARACTERS_PATH := "res://data/characters.json"
const ATTRIBUTES_PATH := "res://data/character_display_attributes.json"
const PROFILES_PATH := "res://data/character_profiles.json"
const SOURCES_PATH := "res://data/character_sources.json"
const SCENARIO_TEMPLATES_PATH := "res://data/scenario_templates.json"

const CATALOG_VERSION := 6
const FORMAL_COUNT := 90
const GROUP_ORDER := [
	"",
	"刘备军",
	"黄巾军",
	"汉廷",
	"群雄",
	"曹氏",
	"孙氏",
]


func load_archive() -> Dictionary:
	var catalog_result := _load_json_dictionary(CATALOG_PATH)
	if not bool(catalog_result.get("ok", false)):
		return catalog_result
	var characters_result := _load_json_array(CHARACTERS_PATH)
	if not bool(characters_result.get("ok", false)):
		return characters_result
	var attributes_result := _load_json_dictionary(ATTRIBUTES_PATH)
	if not bool(attributes_result.get("ok", false)):
		return attributes_result
	var profiles_result := _load_json_dictionary(PROFILES_PATH)
	if not bool(profiles_result.get("ok", false)):
		return profiles_result
	var sources_result := _load_json_dictionary(SOURCES_PATH)
	if not bool(sources_result.get("ok", false)):
		return sources_result
	var scenarios_result := _load_json_dictionary(SCENARIO_TEMPLATES_PATH)
	if not bool(scenarios_result.get("ok", false)):
		return scenarios_result

	var catalog: Dictionary = catalog_result.get("value", {})
	if (
		int(catalog.get("character_catalog_version", 0)) != CATALOG_VERSION
		or int(catalog.get("runtime_character_count", 0)) != FORMAL_COUNT
	):
		return _failure("invalid_catalog_version", "正式人物目录版本或人数不匹配。")
	var catalog_ids := _normalized_strings(catalog.get("character_ids", []))
	if catalog_ids.size() != FORMAL_COUNT:
		return _failure("invalid_catalog_count", "正式人物目录必须恰好包含 %d 个唯一身份。" % FORMAL_COUNT)

	var characters: Array = characters_result.get("value", [])
	var attributes_document: Dictionary = attributes_result.get("value", {})
	var profiles_document: Dictionary = profiles_result.get("value", {})
	var sources_document: Dictionary = sources_result.get("value", {})
	var scenarios_document: Dictionary = scenarios_result.get("value", {})
	if characters.size() != FORMAL_COUNT:
		return _failure("invalid_character_count", "正式人物表必须恰好包含 %d 人。" % FORMAL_COUNT)
	var identity_result: Dictionary = CharacterIdentityPolicyScript.decode_runtime_records(
		characters,
		catalog_ids
	)
	if not bool(identity_result.get("ok", false)):
		return _failure(
			str(identity_result.get("error_code", "invalid_character_identity")),
			str(identity_result.get("message", "正式人物身份资料无法读取。"))
		)
	characters.assign(identity_result.get("characters", []))
	var profile_result: Dictionary = CharacterProfilePolicyScript.decode_document(
		profiles_document,
		characters,
		sources_document
	)
	if not bool(profile_result.get("ok", false)):
		return _failure(
			str(profile_result.get("error_code", "invalid_character_profiles")),
			str(profile_result.get("message", "正式人物小传无法读取。"))
		)

	var characters_by_id := _records_by_id(characters, "id")
	var attributes_by_id := _records_by_id(
		attributes_document.get("records", []),
		"character_id"
	)
	var profiles_by_id: Dictionary = (profile_result.get("profiles_by_id", {}) as Dictionary).duplicate(true)
	for mapping in [
		characters_by_id,
		attributes_by_id,
		profiles_by_id,
	]:
		if mapping.size() != FORMAL_COUNT:
			return _failure("incomplete_formal_material", "人物志所需正式资料没有达到 %d／%d。" % [FORMAL_COUNT, FORMAL_COUNT])

	var scenario_index_result := _build_scenario_index(
		scenarios_document.get("templates", []),
		catalog_ids
	)
	if not bool(scenario_index_result.get("ok", false)):
		return scenario_index_result
	var scenarios: Array[Dictionary] = []
	scenarios.assign(scenario_index_result.get("scenarios", []))
	var scenarios_by_character: Dictionary = scenario_index_result.get(
		"scenarios_by_character",
		{}
	)
	var scenario_counts: Dictionary = scenario_index_result.get("scenario_counts", {})
	var scenario_role_counts: Dictionary = scenario_index_result.get(
		"scenario_role_counts",
		{}
	)

	var records: Array[Dictionary] = []
	var group_counts := {}
	for index in range(catalog_ids.size()):
		var character_id := catalog_ids[index]
		if (
			not characters_by_id.has(character_id)
			or not attributes_by_id.has(character_id)
			or not profiles_by_id.has(character_id)
		):
			return _failure("missing_character_material", "人物志缺少人物资料：%s" % character_id)
		var character: Dictionary = characters_by_id[character_id]
		var attributes: Dictionary = attributes_by_id[character_id]
		var profile: Dictionary = profiles_by_id[character_id]
		var display_name := str(character.get("name", "")).strip_edges()
		var group := str(character.get("group", "")).strip_edges()
		var aliases := _normalized_strings(character.get("aliases", []))
		if (
			display_name.is_empty()
			or group.is_empty()
		):
			return _failure("invalid_character_material", "人物志资料不完整：%s" % character_id)
		group_counts[group] = int(group_counts.get(group, 0)) + 1
		records.append({
			"catalog_index": index + 1,
			"id": character_id,
			"name": display_name,
			"group": group,
			"aliases": aliases,
			"attributes": {
				"might": int(attributes.get("might", 0)),
				"intelligence": int(attributes.get("intelligence", 0)),
				"leadership": int(attributes.get("leadership", 0)),
				"charisma": int(attributes.get("charisma", 0)),
			},
			"headline": str(profile.get("headline", "")).strip_edges(),
			"biography": str(profile.get("biography", "")).strip_edges(),
			"search_text": _build_search_text(display_name, aliases),
			"scenarios": (
				scenarios_by_character.get(character_id, []) as Array
			).duplicate(true),
			"scenario_ids": _scenario_ids(
				scenarios_by_character.get(character_id, [])
			),
		})

	if records.size() != FORMAL_COUNT:
		return _failure("invalid_archive_count", "人物志必须恰好整理出 %d 人。" % FORMAL_COUNT)
	return {
		"ok": true,
		"records": records,
		"group_counts": group_counts,
		"scenarios": scenarios,
		"scenario_counts": scenario_counts,
		"scenario_role_counts": scenario_role_counts,
		"catalog_version": CATALOG_VERSION,
		"formal_count": FORMAL_COUNT,
	}


static func record_matches(
	record: Dictionary,
	query: String,
	group_filter: String,
	scenario_filter: String = ""
) -> bool:
	if not group_filter.is_empty() and str(record.get("group", "")) != group_filter:
		return false
	if (
		not scenario_filter.is_empty()
		and scenario_filter not in (record.get("scenario_ids", []) as Array)
	):
		return false
	var normalized_query := query.strip_edges().to_lower()
	if normalized_query.is_empty():
		return true
	return str(record.get("search_text", "")).contains(normalized_query)


func _build_scenario_index(templates_value: Variant, catalog_ids: Array[String]) -> Dictionary:
	if not (templates_value is Array):
		return _failure("invalid_scenario_templates", "内置开局资料不是数组。")
	var known_ids := {}
	for character_id in catalog_ids:
		known_ids[character_id] = true
	var scenarios: Array[Dictionary] = []
	var scenarios_by_character := {}
	var scenario_counts := {}
	var scenario_role_counts := {}
	for value in templates_value:
		if not (value is Dictionary):
			return _failure("invalid_scenario_template", "内置开局资料含有无效记录。")
		var template: Dictionary = value
		if str(template.get("scenario_kind", "")) != "historical_start":
			continue
		var scenario_id := str(template.get("scenario_id", "")).strip_edges()
		var scenario_name := str(template.get("name", "")).strip_edges()
		var year := int(template.get("year", 0))
		if scenario_id.is_empty() or scenario_name.is_empty() or year <= 0:
			return _failure("invalid_historical_scenario", "历史开局缺少编号、名称或年份。")
		var placed_ids: Array[String] = []
		for placement_value in template.get("placements", []):
			if not (placement_value is Dictionary):
				return _failure("invalid_scenario_placement", "%s 含有无效人物落点。" % scenario_name)
			var character_id := str(placement_value.get("character_id", "")).strip_edges()
			if not known_ids.has(character_id):
				return _failure("unknown_scenario_character", "%s 引用了正式目录外人物：%s" % [scenario_name, character_id])
			if character_id not in placed_ids:
				placed_ids.append(character_id)
		var featured_ids := _normalized_strings(template.get("featured_character_ids", []))
		for character_id in featured_ids:
			if not known_ids.has(character_id):
				return _failure("unknown_featured_character", "%s 的重点人物不在正式目录：%s" % [scenario_name, character_id])
		var member_ids := placed_ids.duplicate()
		for character_id in featured_ids:
			if character_id not in member_ids:
				member_ids.append(character_id)
		var scenario := {
			"id": scenario_id,
			"name": scenario_name,
			"year": year,
			"era_label": str(template.get("era_label", "")).strip_edges(),
			"placed_count": placed_ids.size(),
			"featured_count": featured_ids.size(),
			"placed_and_featured_count": _intersection_count(placed_ids, featured_ids),
			"member_count": member_ids.size(),
		}
		scenarios.append(scenario)
		scenario_counts[scenario_id] = member_ids.size()
		scenario_role_counts[scenario_id] = {
			"placed": placed_ids.size(),
			"featured": featured_ids.size(),
			"placed_and_featured": _intersection_count(placed_ids, featured_ids),
			"members": member_ids.size(),
		}
		for character_id in member_ids:
			if not scenarios_by_character.has(character_id):
				scenarios_by_character[character_id] = []
			var role := "预摆"
			if character_id in placed_ids and character_id in featured_ids:
				role = "预摆·重点"
			elif character_id in featured_ids:
				role = "重点"
			(scenarios_by_character[character_id] as Array).append({
				"id": scenario_id,
				"name": scenario_name,
				"year": year,
				"role": role,
			})
	if scenarios.size() != 5:
		return _failure("invalid_historical_scenario_count", "人物志当前需要五个历史开局。")
	return {
		"ok": true,
		"scenarios": scenarios,
		"scenarios_by_character": scenarios_by_character,
		"scenario_counts": scenario_counts,
		"scenario_role_counts": scenario_role_counts,
	}


func _intersection_count(left: Array[String], right: Array[String]) -> int:
	var count := 0
	for value in left:
		if value in right:
			count += 1
	return count


func _scenario_ids(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if not (values is Array):
		return result
	for value in values:
		if value is Dictionary:
			var scenario_id := str(value.get("id", "")).strip_edges()
			if not scenario_id.is_empty() and scenario_id not in result:
				result.append(scenario_id)
	return result


func _load_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("missing_file", "缺少人物志资料：%s" % path)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return {"ok": true, "value": parsed}
	return _failure("invalid_json_object", "人物志资料不是 JSON 对象：%s" % path)


func _load_json_array(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("missing_file", "缺少人物志资料：%s" % path)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Array:
		return {"ok": true, "value": parsed}
	return _failure("invalid_json_array", "人物志资料不是 JSON 数组：%s" % path)


func _records_by_id(values: Variant, id_key: String) -> Dictionary:
	var result := {}
	if not (values is Array):
		return result
	for value in values:
		if not (value is Dictionary):
			continue
		var record: Dictionary = value
		var record_id := str(record.get(id_key, "")).strip_edges()
		if record_id.is_empty() or result.has(record_id):
			return {}
		result[record_id] = record
	return result


func _normalized_strings(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if not (values is Array):
		return result
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty() and text not in result:
			result.append(text)
	return result


func _build_search_text(display_name: String, aliases: Array[String]) -> String:
	var parts: Array[String] = [display_name.to_lower()]
	for alias in aliases:
		parts.append(alias.to_lower())
	return " ".join(parts)


func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": code, "message": message}
