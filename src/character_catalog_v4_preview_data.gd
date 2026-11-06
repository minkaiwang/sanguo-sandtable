class_name CharacterCatalogV4PreviewData
extends "res://src/character_archive_data.gd"

## M4-B6：目录 v4／80 人隔离试玩的数据适配器。
##
## 直接读取 M4-B5 候选数据包与既有开局资料。新增 20 人只作为可检索的
## 背包候选和开局补位建议出现；本适配器不访问 user://，也不写正式目录。

const CANDIDATE_ROOT := "res://artifacts/m4_b5_catalog_v4_80_candidate"
const CATALOG_PATH_V4 := CANDIDATE_ROOT + "/data/character_catalog.json"
const CHARACTERS_PATH_V4 := CANDIDATE_ROOT + "/data/characters.json"
const ATTRIBUTES_PATH_V4 := CANDIDATE_ROOT + "/data/character_display_attributes.json"
const PROFILES_PATH_V4 := CANDIDATE_ROOT + "/data/character_profiles.json"
const MANIFEST_PATH := CANDIDATE_ROOT + "/candidate_manifest.json"
const MIGRATION_CONTRACT_PATH := CANDIDATE_ROOT + "/migration_contract.json"
const RESEARCH_QUEUE_PATH := "res://references/candidates/character_research_queue_v1.json"

const PREVIEW_CATALOG_VERSION := 4
const PREVIEW_SAVE_VERSION := 16
const PREVIEW_CHARACTER_COUNT := 80
const FORMAL_PREFIX_COUNT := 60
const APPEND_COUNT := 20
const GROUP_ORDER_V4 := [
	"",
	"刘备军",
	"黄巾军",
	"汉廷",
	"群雄",
	"曹氏",
	"孙氏",
]


func load_archive() -> Dictionary:
	var catalog_result := _load_json_dictionary(CATALOG_PATH_V4)
	if not bool(catalog_result.get("ok", false)):
		return catalog_result
	var characters_result := _load_json_array(CHARACTERS_PATH_V4)
	if not bool(characters_result.get("ok", false)):
		return characters_result
	var attributes_result := _load_json_dictionary(ATTRIBUTES_PATH_V4)
	if not bool(attributes_result.get("ok", false)):
		return attributes_result
	var profiles_result := _load_json_dictionary(PROFILES_PATH_V4)
	if not bool(profiles_result.get("ok", false)):
		return profiles_result
	var scenarios_result := _load_json_dictionary(SCENARIO_TEMPLATES_PATH)
	if not bool(scenarios_result.get("ok", false)):
		return scenarios_result
	var queue_result := _load_json_dictionary(RESEARCH_QUEUE_PATH)
	if not bool(queue_result.get("ok", false)):
		return queue_result
	var manifest_result := _load_json_dictionary(MANIFEST_PATH)
	if not bool(manifest_result.get("ok", false)):
		return manifest_result
	var migration_result := _load_json_dictionary(MIGRATION_CONTRACT_PATH)
	if not bool(migration_result.get("ok", false)):
		return migration_result

	var catalog: Dictionary = catalog_result.get("value", {})
	var manifest: Dictionary = manifest_result.get("value", {})
	var migration_contract: Dictionary = migration_result.get("value", {})
	if (
		int(catalog.get("character_catalog_version", 0)) != PREVIEW_CATALOG_VERSION
		or int(catalog.get("runtime_character_count", 0)) != PREVIEW_CHARACTER_COUNT
	):
		return _failure("invalid_preview_catalog", "隔离试玩需要目录 v4／80 人候选数据。")
	if (
		bool(manifest.get("formal_write_permitted", true))
		or bool(manifest.get("runtime_activation_permitted", true))
		or bool(manifest.get("portrait_assets_required", true))
	):
		return _failure("invalid_preview_manifest", "隔离试玩清单的只读或名牌约束不匹配。")
	var transaction_rule: Dictionary = migration_contract.get("transaction_rule", {})
	if bool(transaction_rule.get("runtime_write_permitted", true)):
		return _failure("runtime_write_enabled", "隔离试玩迁移契约不得允许运行时写入。")

	var catalog_ids := _normalized_strings(catalog.get("character_ids", []))
	var append_ids := _normalized_strings(manifest.get("append_ids_in_catalog_order", []))
	if (
		catalog_ids.size() != PREVIEW_CHARACTER_COUNT
		or append_ids.size() != APPEND_COUNT
		or catalog_ids.slice(FORMAL_PREFIX_COUNT) != append_ids
	):
		return _failure("invalid_preview_catalog_order", "目录 v4 必须保留前 60 人并在末尾追加 20 人。")

	var characters: Array = characters_result.get("value", [])
	var attributes_document: Dictionary = attributes_result.get("value", {})
	var profiles_document: Dictionary = profiles_result.get("value", {})
	if characters.size() != PREVIEW_CHARACTER_COUNT:
		return _failure("invalid_preview_character_count", "隔离试玩人物表必须恰好包含 80 人。")
	var characters_by_id := _records_by_id(characters, "id")
	var attributes_by_id := _records_by_id(attributes_document.get("records", []), "character_id")
	var profiles_by_id := _records_by_id(profiles_document.get("profiles", []), "character_id")
	for mapping in [characters_by_id, attributes_by_id, profiles_by_id]:
		if mapping.size() != PREVIEW_CHARACTER_COUNT:
			return _failure("incomplete_preview_material", "隔离试玩所需人物资料没有达到 80／80。")

	var queue_document: Dictionary = queue_result.get("value", {})
	var queue_by_id := _records_by_id(queue_document.get("candidates", []), "id")
	if queue_by_id.size() != APPEND_COUNT:
		return _failure("invalid_candidate_queue", "开局补位队列必须覆盖新增 20 人。")
	for character_id in append_ids:
		if not queue_by_id.has(character_id):
			return _failure("candidate_missing_from_queue", "补位队列缺少人物：%s" % character_id)

	var scenarios_document: Dictionary = scenarios_result.get("value", {})
	var scenario_index_result := _build_scenario_index(
		scenarios_document.get("templates", []),
		catalog_ids
	)
	if not bool(scenario_index_result.get("ok", false)):
		return scenario_index_result
	var scenarios: Array[Dictionary] = []
	scenarios.assign(scenario_index_result.get("scenarios", []))
	var actual_scenarios_by_character: Dictionary = scenario_index_result.get(
		"scenarios_by_character",
		{}
	)
	var actual_scenario_counts: Dictionary = scenario_index_result.get("scenario_counts", {})
	var scenario_role_counts: Dictionary = (
		scenario_index_result.get("scenario_role_counts", {}) as Dictionary
	).duplicate(true)
	var scenario_lookup := {}
	for scenario in scenarios:
		scenario_lookup[str(scenario.get("id", ""))] = scenario

	var suggested_scenarios_by_character := {}
	var suggestion_counts := {}
	for scenario_id in scenario_lookup:
		suggestion_counts[scenario_id] = 0
	for character_id in append_ids:
		var queue_record: Dictionary = queue_by_id.get(character_id, {})
		var suggestions: Array[Dictionary] = []
		for scenario_id in _normalized_strings(queue_record.get("target_scenarios", [])):
			if not scenario_lookup.has(scenario_id):
				return _failure("unknown_candidate_scenario", "%s 的建议开局不存在：%s" % [character_id, scenario_id])
			var scenario: Dictionary = scenario_lookup[scenario_id]
			suggestions.append({
				"id": scenario_id,
				"name": str(scenario.get("name", "")),
				"year": int(scenario.get("year", 0)),
				"role": "候选补位",
			})
			suggestion_counts[scenario_id] = int(suggestion_counts.get(scenario_id, 0)) + 1
		suggested_scenarios_by_character[character_id] = suggestions

	var preview_scenario_counts := {}
	for index in range(scenarios.size()):
		var scenario := scenarios[index].duplicate(true)
		var scenario_id := str(scenario.get("id", ""))
		var actual_count := int(actual_scenario_counts.get(scenario_id, 0))
		var suggested_count := int(suggestion_counts.get(scenario_id, 0))
		var preview_count := actual_count + suggested_count
		scenario["actual_member_count"] = actual_count
		scenario["candidate_suggestion_count"] = suggested_count
		scenario["preview_member_count"] = preview_count
		scenarios[index] = scenario
		preview_scenario_counts[scenario_id] = preview_count
		var roles: Dictionary = scenario_role_counts.get(scenario_id, {}).duplicate(true)
		roles["actual_members"] = actual_count
		roles["candidate_suggestions"] = suggested_count
		roles["preview_members"] = preview_count
		scenario_role_counts[scenario_id] = roles

	var records: Array[Dictionary] = []
	var group_counts := {}
	for index in range(catalog_ids.size()):
		var character_id := catalog_ids[index]
		if (
			not characters_by_id.has(character_id)
			or not attributes_by_id.has(character_id)
			or not profiles_by_id.has(character_id)
		):
			return _failure("missing_preview_material", "隔离试玩缺少人物资料：%s" % character_id)
		var character: Dictionary = characters_by_id[character_id]
		var attributes: Dictionary = attributes_by_id[character_id]
		var profile: Dictionary = profiles_by_id[character_id]
		var display_name := str(character.get("name", "")).strip_edges()
		var group := str(character.get("group", "")).strip_edges()
		var aliases := _normalized_strings(character.get("aliases", []))
		if display_name.is_empty() or group.is_empty():
			return _failure("invalid_preview_character", "隔离试玩人物资料不完整：%s" % character_id)
		group_counts[group] = int(group_counts.get(group, 0)) + 1
		var actual_scenarios: Array = (
			actual_scenarios_by_character.get(character_id, []) as Array
		).duplicate(true)
		var suggested_scenarios: Array = (
			suggested_scenarios_by_character.get(character_id, []) as Array
		).duplicate(true)
		var combined_scenarios := actual_scenarios.duplicate(true)
		combined_scenarios.append_array(suggested_scenarios)
		var scenario_ids := _scenario_ids(combined_scenarios)
		var release_stage := "formal" if index < FORMAL_PREFIX_COUNT else "candidate"
		var headline := str(profile.get("headline", "")).strip_edges()
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
			"headline": headline,
			"biography": str(profile.get("biography", "")).strip_edges(),
			"search_text": _build_preview_search_text(character_id, display_name, aliases, headline),
			"scenarios": combined_scenarios,
			"scenario_ids": scenario_ids,
			"actual_scenario_ids": _scenario_ids(actual_scenarios),
			"suggested_scenario_ids": _scenario_ids(suggested_scenarios),
			"release_stage": release_stage,
			"status_label": "正式" if release_stage == "formal" else "候选",
		})

	if records.size() != PREVIEW_CHARACTER_COUNT:
		return _failure("invalid_preview_record_count", "隔离试玩必须恰好整理出 80 人。")
	return {
		"ok": true,
		"records": records,
		"group_counts": group_counts,
		"scenarios": scenarios,
		"scenario_counts": actual_scenario_counts,
		"preview_scenario_counts": preview_scenario_counts,
		"scenario_suggestion_counts": suggestion_counts,
		"scenario_role_counts": scenario_role_counts,
		"catalog_version": PREVIEW_CATALOG_VERSION,
		"target_save_version": PREVIEW_SAVE_VERSION,
		"formal_count": FORMAL_PREFIX_COUNT,
		"candidate_count": APPEND_COUNT,
		"total_count": PREVIEW_CHARACTER_COUNT,
		"append_ids": append_ids,
		"runtime_write_permitted": false,
		"user_data_access": false,
		"presentation_mode": "nameplate",
	}


static func preview_record_matches(
	record: Dictionary,
	query: String,
	group_filter: String,
	scenario_filter: String,
	stage_filter: String
) -> bool:
	if not group_filter.is_empty() and str(record.get("group", "")) != group_filter:
		return false
	if not stage_filter.is_empty() and str(record.get("release_stage", "")) != stage_filter:
		return false
	if (
		not scenario_filter.is_empty()
		and scenario_filter not in (record.get("scenario_ids", []) as Array)
	):
		return false
	var normalized_query := query.strip_edges().to_lower()
	return (
		normalized_query.is_empty()
		or str(record.get("search_text", "")).contains(normalized_query)
	)


func _build_preview_search_text(
	character_id: String,
	display_name: String,
	aliases: Array[String],
	headline: String
) -> String:
	var parts: Array[String] = [character_id.to_lower(), display_name.to_lower()]
	for alias in aliases:
		parts.append(alias.to_lower())
	if not headline.is_empty():
		parts.append(headline.to_lower())
	return " ".join(parts)
