class_name CharacterReviewNext20Data
extends RefCounted

## 目录 v4 前的下一批 20 人资料适配器。
##
## 只组合研究队列、身份资料与展示资料，不读取头像，也不修改正式人物库。

const QUEUE_PATH := "res://references/candidates/character_research_queue_v1.json"
const FACTS_BATCH_05_PATH := \
	"res://references/candidates/character_promotion_batch_05_facts.json"
const FACTS_BATCH_06_PATH := \
	"res://references/candidates/character_promotion_batch_06_facts.json"
const EDITORIAL_BATCH_05_PATH := \
	"res://references/candidates/character_promotion_batch_05_editorial_draft.json"
const EDITORIAL_BATCH_06_PATH := \
	"res://references/candidates/character_promotion_batch_06_editorial_draft.json"

const TARGET_CATALOG_VERSION := 4
const BASELINE_FORMAL_COUNT := 60
const CANDIDATE_COUNT := 20
const STATUS_CANDIDATE := "candidate_review"


func load_catalog() -> Dictionary:
	var queue_result := _load_json_dictionary(QUEUE_PATH)
	if not bool(queue_result.get("ok", false)):
		return queue_result
	var facts_05_result := _load_json_dictionary(FACTS_BATCH_05_PATH)
	if not bool(facts_05_result.get("ok", false)):
		return facts_05_result
	var facts_06_result := _load_json_dictionary(FACTS_BATCH_06_PATH)
	if not bool(facts_06_result.get("ok", false)):
		return facts_06_result
	var editorial_05_result := _load_json_dictionary(EDITORIAL_BATCH_05_PATH)
	if not bool(editorial_05_result.get("ok", false)):
		return editorial_05_result
	var editorial_06_result := _load_json_dictionary(EDITORIAL_BATCH_06_PATH)
	if not bool(editorial_06_result.get("ok", false)):
		return editorial_06_result

	var queue: Dictionary = queue_result.get("value", {})
	if (
		int(queue.get("schema_version", 0)) != 1
		or str(queue.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized"
		or int(queue.get("formal_character_count", 0)) != BASELINE_FORMAL_COUNT
		or int(queue.get("target_character_catalog_version", 0)) != TARGET_CATALOG_VERSION
		or int(queue.get("target_runtime_count", 0)) != BASELINE_FORMAL_COUNT + CANDIDATE_COUNT
	):
		return _failure("invalid_queue_contract", "下一批人物研究队列与 60→80 目标不一致。")
	var candidates: Variant = queue.get("candidates", [])
	if not (candidates is Array) or candidates.size() != CANDIDATE_COUNT:
		return _failure("invalid_queue_count", "下一批人物研究队列必须恰好包含 20 人。")

	var facts_by_id := {}
	for result in [facts_05_result, facts_06_result]:
		var document: Dictionary = result.get("value", {})
		if not _validate_source_document(document, "characters"):
			return _failure("invalid_fact_package", "下一批身份资料与目录 v4 目标不一致。")
		if not _merge_unique(facts_by_id, _records_by_id(document.get("characters", []), "id")):
			return _failure("duplicate_fact_identity", "下一批身份资料存在重复人物。")

	var attributes_by_id := {}
	var profiles_by_id := {}
	for result in [editorial_05_result, editorial_06_result]:
		var document: Dictionary = result.get("value", {})
		if not _validate_source_document(document, "profiles"):
			return _failure("invalid_editorial_package", "下一批展示资料与目录 v4 目标不一致。")
		if not _merge_unique(
			attributes_by_id,
			_records_by_id(document.get("display_attributes", []), "character_id")
		):
			return _failure("duplicate_attributes", "下一批展示资料存在重复四维。")
		if not _merge_unique(
			profiles_by_id,
			_records_by_id(document.get("profiles", []), "character_id")
		):
			return _failure("duplicate_profiles", "下一批展示资料存在重复小传。")

	if (
		facts_by_id.size() != CANDIDATE_COUNT
		or attributes_by_id.size() != CANDIDATE_COUNT
		or profiles_by_id.size() != CANDIDATE_COUNT
	):
		return _failure("incomplete_research_material", "下一批 20 人的身份、四维或小传尚未完整。")

	var records: Array[Dictionary] = []
	var seen := {}
	for index in range(candidates.size()):
		var candidate_value: Variant = candidates[index]
		if not (candidate_value is Dictionary):
			return _failure("invalid_candidate", "下一批人物研究队列含有无效记录。")
		var candidate: Dictionary = candidate_value
		var character_id := str(candidate.get("id", ""))
		var name := str(candidate.get("name", ""))
		var fact: Dictionary = facts_by_id.get(character_id, {})
		var attributes: Dictionary = attributes_by_id.get(character_id, {})
		var profile: Dictionary = profiles_by_id.get(character_id, {})
		if (
			character_id.is_empty()
			or name.is_empty()
			or seen.has(character_id)
			or fact.is_empty()
			or attributes.is_empty()
			or profile.is_empty()
			or str(fact.get("name", "")) != name
			or str(profile.get("character_id", "")) != character_id
		):
			return _failure("candidate_material_mismatch", "下一批人物资料无法对应：%s" % character_id)
		seen[character_id] = true
		var aliases := _normalized_strings(fact.get("aliases", []))
		records.append({
			"catalog_index": BASELINE_FORMAL_COUNT + index + 1,
			"id": character_id,
			"name": name,
			"group": str(candidate.get("prototype_group_candidate", "待定")),
			"aliases": aliases,
			"affiliations": (fact.get("affiliations", []) as Array).duplicate(true),
			"source_refs": _normalized_strings(fact.get("source_refs", [])),
			"status_id": STATUS_CANDIDATE,
			"status_label": "下一批候选资料",
			"presentation_mode": "nameplate",
			"nameplate_display_name": name,
			"requires_portrait": false,
			"attributes": attributes.duplicate(true),
			"headline": str(profile.get("headline", "")),
			"biography": str(profile.get("biography", "")),
			"profile_source_refs": _normalized_strings(profile.get("source_refs", [])),
			"search_text": _build_search_text(name, aliases),
		})

	return {
		"ok": true,
		"catalog_version": TARGET_CATALOG_VERSION,
		"records": records,
		"counts": {
			"catalog": records.size(),
			"formal_baseline": BASELINE_FORMAL_COUNT,
			"candidate_review": records.size(),
		},
		"runtime_policy": "research_review_memory_only_no_formal_writes",
	}


func _validate_source_document(document: Dictionary, record_key: String) -> bool:
	var values: Variant = document.get(record_key, [])
	return (
		int(document.get("schema_version", 0)) == 1
		and int(document.get("target_character_catalog_version", 0)) == TARGET_CATALOG_VERSION
		and int(document.get("selected_character_count", 0)) == 10
		and values is Array
		and values.size() == 10
	)


func _load_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("missing_file", "缺少下一批人物资料：%s" % path)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return {"ok": true, "value": parsed}
	return _failure("invalid_json_object", "下一批人物资料不是 JSON 对象：%s" % path)


func _records_by_id(values: Variant, id_key: String) -> Dictionary:
	var result := {}
	if not (values is Array):
		return result
	for value in values:
		if value is Dictionary:
			var record: Dictionary = value
			var record_id := str(record.get(id_key, ""))
			if not record_id.is_empty():
				result[record_id] = record
	return result


func _merge_unique(target: Dictionary, additions: Dictionary) -> bool:
	for record_id in additions:
		if target.has(record_id):
			return false
		target[record_id] = additions[record_id]
	return true


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
