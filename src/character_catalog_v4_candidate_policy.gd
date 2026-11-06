class_name CharacterCatalogV4CandidatePolicy
extends RefCounted

## M4-B5：目录 v4／80 人隔离数据候选门禁。
##
## 候选只包含人物目录、人物、四维、小传、事实与来源六类 JSON。
## 逐人头像既不属于候选文档，也不属于发布准备条件。

const CatalogPolicy = preload("res://src/character_catalog_policy.gd")
const ClaimPolicy = preload("res://src/character_claim_policy.gd")

const STATUS_READY := "validated_catalog_v4_data_candidate_not_runtime"
const STATUS_INVALID := "invalid_catalog_v4_data_candidate"
const FORMAL_CATALOG_VERSION := 3
const TARGET_CATALOG_VERSION := 4
const FORMAL_COUNT := 60
const CANDIDATE_COUNT := 20
const TARGET_COUNT := 80
const DOCUMENT_KEYS := ["catalog", "characters", "attributes", "profiles", "claims", "sources"]
const CHARACTER_KEYS := ["id", "name", "group", "aliases", "affiliations", "source_refs"]
const ATTRIBUTE_KEYS := ["character_id", "might", "intelligence", "leadership", "charisma"]
const PROFILE_KEYS := ["character_id", "headline", "biography", "source_refs"]


static func evaluate(
	formal_documents_value: Variant,
	candidate_documents_value: Variant,
	expected_append_ids_value: Variant
) -> Dictionary:
	var blockers: Array[Dictionary] = []
	if not (formal_documents_value is Dictionary):
		blockers.append(_blocker("formal_documents_invalid", "正式人物资料集合不是对象。"))
	if not (candidate_documents_value is Dictionary):
		blockers.append(_blocker("candidate_documents_invalid", "目录 v4 候选资料集合不是对象。"))
	if not (expected_append_ids_value is Array):
		blockers.append(_blocker("expected_append_ids_invalid", "目录 v4 新增顺序不是数组。"))
	if not blockers.is_empty():
		return _report(false, [], blockers, {})

	var formal_documents: Dictionary = formal_documents_value
	var candidate_documents: Dictionary = candidate_documents_value
	for key in DOCUMENT_KEYS:
		if not formal_documents.has(key) or not candidate_documents.has(key):
			blockers.append(_blocker("document_missing", "人物资料集合缺少文档：%s。" % key))
	if not blockers.is_empty():
		return _report(false, [], blockers, {})

	var formal_catalog_value: Variant = formal_documents.get("catalog", null)
	var formal_characters_value: Variant = formal_documents.get("characters", null)
	var candidate_catalog_value: Variant = candidate_documents.get("catalog", null)
	var candidate_characters_value: Variant = candidate_documents.get("characters", null)
	var formal_decode := CatalogPolicy.decode_manifest(formal_catalog_value, formal_characters_value)
	var candidate_decode := CatalogPolicy.decode_manifest(candidate_catalog_value, candidate_characters_value)
	if (
		not bool(formal_decode.get("ok", false))
		or int(formal_decode.get("catalog_version", 0)) != FORMAL_CATALOG_VERSION
		or int(formal_decode.get("character_count", 0)) != FORMAL_COUNT
	):
		blockers.append(_blocker("formal_catalog_invalid", "正式基线必须是目录 v3／60 人。"))
	if (
		not bool(candidate_decode.get("ok", false))
		or int(candidate_decode.get("catalog_version", 0)) != TARGET_CATALOG_VERSION
		or int(candidate_decode.get("character_count", 0)) != TARGET_COUNT
	):
		blockers.append(_blocker("candidate_catalog_invalid", "候选必须是目录 v4／80 人。"))
	if not blockers.is_empty():
		return _report(false, [], blockers, {})

	var formal_ids: Array = formal_decode.get("character_ids", [])
	var target_ids: Array = candidate_decode.get("character_ids", [])
	var expected_ids := _unique_strings(expected_append_ids_value)
	if expected_ids.size() != CANDIDATE_COUNT:
		blockers.append(_blocker("append_ids_invalid", "目录 v4 必须提供 20 个唯一新增 ID。"))
	if target_ids.slice(0, FORMAL_COUNT) != formal_ids:
		blockers.append(_blocker("formal_catalog_prefix_changed", "目录 v4 不得改变正式 60 人 ID 或顺序。"))
	var append_ids: Array = target_ids.slice(FORMAL_COUNT, TARGET_COUNT)
	if append_ids != expected_ids:
		blockers.append(_blocker("catalog_suffix_mismatch", "目录 v4 新增段与已就绪 20 人顺序不一致。"))

	var formal_characters: Array = formal_characters_value
	var candidate_characters: Array = candidate_characters_value
	if candidate_characters.slice(0, FORMAL_COUNT) != formal_characters:
		blockers.append(_blocker("formal_character_prefix_changed", "候选人物表改变了正式 60 人记录。"))

	var prefix_pairs := [
		["attributes", "records"],
		["profiles", "profiles"],
		["claims", "claims"],
		["sources", "sources"],
	]
	for pair in prefix_pairs:
		var document_key := str(pair[0])
		var records_key := str(pair[1])
		var formal_document_value: Variant = formal_documents.get(document_key, null)
		var candidate_document_value: Variant = candidate_documents.get(document_key, null)
		if not (formal_document_value is Dictionary) or not (candidate_document_value is Dictionary):
			blockers.append(_blocker("document_shape_invalid", "%s 文档不是对象。" % document_key))
			continue
		var formal_values_value: Variant = (formal_document_value as Dictionary).get(records_key, null)
		var candidate_values_value: Variant = (candidate_document_value as Dictionary).get(records_key, null)
		if not (formal_values_value is Array) or not (candidate_values_value is Array):
			blockers.append(_blocker("document_records_invalid", "%s 文档缺少记录数组。" % document_key))
			continue
		var formal_values: Array = formal_values_value
		var candidate_values: Array = candidate_values_value
		if candidate_values.size() < formal_values.size() or candidate_values.slice(0, formal_values.size()) != formal_values:
			blockers.append(_blocker("formal_document_prefix_changed", "候选 %s 改变了正式记录前缀。" % document_key))

	var source_result := _validate_sources(candidate_documents.get("sources", null))
	if not bool(source_result.get("ok", false)):
		blockers.append(_blocker("candidate_sources_invalid", str(source_result.get("message", "人物来源无效。"))))
	var sources_by_id: Dictionary = source_result.get("sources_by_id", {})
	var characters_by_id := _index_records(candidate_characters, "id")
	var claim_result := ClaimPolicy.decode_document(
		candidate_documents.get("claims", null),
		characters_by_id,
		sources_by_id
	)
	if not bool(claim_result.get("ok", false)):
		blockers.append(_blocker("candidate_claims_invalid", str(claim_result.get("message", "人物事实无效。"))))
	var claims_by_character: Dictionary = claim_result.get("claims_by_character", {})
	var identity_by_character: Dictionary = claim_result.get("identity_by_character", {})

	var attributes_result := _validate_attributes(candidate_documents.get("attributes", null), target_ids)
	if not bool(attributes_result.get("ok", false)):
		blockers.append(_blocker("candidate_attributes_invalid", str(attributes_result.get("message", "人物四维无效。"))))
	var profiles_result := _validate_profiles(
		candidate_documents.get("profiles", null),
		target_ids,
		sources_by_id
	)
	if not bool(profiles_result.get("ok", false)):
		blockers.append(_blocker("candidate_profiles_invalid", str(profiles_result.get("message", "人物小传无效。"))))

	var character_result := _validate_characters(
		candidate_characters,
		target_ids,
		sources_by_id,
		claims_by_character,
		identity_by_character,
		expected_ids
	)
	if not bool(character_result.get("ok", false)):
		blockers.append_array(character_result.get("blocking_reasons", []))

	var formal_attributes: Dictionary = formal_documents.get("attributes", {})
	var candidate_attributes: Dictionary = candidate_documents.get("attributes", {})
	if (
		int(candidate_attributes.get("schema_version", 0)) != 1
		or candidate_attributes.get("dimensions", []) != formal_attributes.get("dimensions", [])
		or candidate_attributes.get("scale", {}) != formal_attributes.get("scale", {})
		or candidate_attributes.get("provenance", {}) != formal_attributes.get("provenance", {})
	):
		blockers.append(_blocker("attribute_root_contract_changed", "目录 v4 不得改变四维量表与来源边界。"))

	var summary := {
		"formal_prefix": FORMAL_COUNT,
		"candidate_append": append_ids.size(),
		"target_characters": target_ids.size(),
		"attributes": int(attributes_result.get("count", 0)),
		"profiles": int(profiles_result.get("count", 0)),
		"claims": int(claim_result.get("claims", []).size()),
		"sources": sources_by_id.size(),
		"portrait_documents": 0,
	}
	return _report(blockers.is_empty(), append_ids, blockers, summary, target_ids)


static func _validate_sources(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return _failure("人物来源顶层不是对象。")
	var document: Dictionary = value
	if int(document.get("schema_version", 0)) != 1 or not (document.get("sources", null) is Array):
		return _failure("人物来源 schema 或 records 无效。")
	var sources_by_id := {}
	for source_value in document.get("sources", []):
		if not (source_value is Dictionary):
			return _failure("人物来源包含非对象记录。")
		var source: Dictionary = source_value
		var source_id := str(source.get("id", "")).strip_edges()
		if source_id.is_empty() or sources_by_id.has(source_id):
			return _failure("人物来源 ID 为空或重复：%s。" % source_id)
		if not (source.get("roles", null) is Array) or (source.get("roles", []) as Array).is_empty():
			return _failure("人物来源缺少用途：%s。" % source_id)
		sources_by_id[source_id] = source
	return {"ok": true, "sources_by_id": sources_by_id}


static func _validate_attributes(value: Variant, target_ids: Array) -> Dictionary:
	if not (value is Dictionary):
		return _failure("人物四维顶层不是对象。")
	var document: Dictionary = value
	var records_value: Variant = document.get("records", null)
	if int(document.get("schema_version", 0)) != 1 or not (records_value is Array):
		return _failure("人物四维 schema 或 records 无效。")
	var records: Array = records_value
	if records.size() != TARGET_COUNT:
		return _failure("人物四维必须覆盖 80 人。")
	for index in range(records.size()):
		var record_value: Variant = records[index]
		if not (record_value is Dictionary):
			return _failure("人物四维包含非对象记录。")
		var record: Dictionary = record_value
		if not _has_exact_keys(record, ATTRIBUTE_KEYS) or str(record.get("character_id", "")) != str(target_ids[index]):
			return _failure("人物四维字段或顺序不一致：%s。" % str(target_ids[index]))
		for key in ["might", "intelligence", "leadership", "charisma"]:
			var score: Variant = record.get(key, null)
			if not (typeof(score) in [TYPE_INT, TYPE_FLOAT]):
				return _failure("人物四维不是数字：%s／%s。" % [str(target_ids[index]), key])
			var numeric := float(score)
			if not is_finite(numeric) or not is_equal_approx(numeric, roundf(numeric)) or int(numeric) < 0 or int(numeric) > 100:
				return _failure("人物四维必须是 0—100 整数：%s／%s。" % [str(target_ids[index]), key])
	return {"ok": true, "count": records.size()}


static func _validate_profiles(value: Variant, target_ids: Array, sources_by_id: Dictionary) -> Dictionary:
	if not (value is Dictionary):
		return _failure("人物小传顶层不是对象。")
	var document: Dictionary = value
	var profiles_value: Variant = document.get("profiles", null)
	if int(document.get("schema_version", 0)) != 1 or not (profiles_value is Array):
		return _failure("人物小传 schema 或 profiles 无效。")
	var profiles: Array = profiles_value
	if profiles.size() != TARGET_COUNT:
		return _failure("人物小传必须覆盖 80 人。")
	var target_set := {}
	for target_id_value in target_ids:
		target_set[str(target_id_value)] = true
	var seen := {}
	var suffix_ids: Array[String] = []
	for index in range(profiles.size()):
		var profile_value: Variant = profiles[index]
		if not (profile_value is Dictionary):
			return _failure("人物小传包含非对象记录。")
		var profile: Dictionary = profile_value
		var character_id := str(profile.get("character_id", ""))
		if not _has_exact_keys(profile, PROFILE_KEYS) or not target_set.has(character_id) or seen.has(character_id):
			return _failure("人物小传字段、引用或唯一性无效：%s。" % character_id)
		seen[character_id] = true
		if index >= FORMAL_COUNT:
			suffix_ids.append(character_id)
		if str(profile.get("headline", "")).strip_edges().is_empty() or str(profile.get("biography", "")).strip_edges().is_empty():
			return _failure("人物标题或小传为空：%s。" % character_id)
		if not _valid_source_refs(profile.get("source_refs", null), sources_by_id):
			return _failure("人物小传来源为空、重复或未知：%s。" % character_id)
	if seen.size() != TARGET_COUNT or suffix_ids != target_ids.slice(FORMAL_COUNT, TARGET_COUNT):
		return _failure("人物小传必须完整覆盖 80 人，新增 20 人按目录顺序追加。")
	return {"ok": true, "count": profiles.size()}


static func _validate_characters(
	characters: Array,
	target_ids: Array,
	sources_by_id: Dictionary,
	claims_by_character: Dictionary,
	identity_by_character: Dictionary,
	candidate_ids: Array
) -> Dictionary:
	var blockers: Array[Dictionary] = []
	var seen_names := {}
	var candidate_set := {}
	for character_id in candidate_ids:
		candidate_set[str(character_id)] = true
	for index in range(characters.size()):
		var value: Variant = characters[index]
		if not (value is Dictionary):
			blockers.append(_blocker("character_invalid", "人物表包含非对象记录。"))
			continue
		var character: Dictionary = value
		var character_id := str(target_ids[index])
		var character_name := str(character.get("name", "")).strip_edges()
		if (
			not _has_exact_keys(character, CHARACTER_KEYS)
			or str(character.get("id", "")) != character_id
			or character_name.is_empty()
			or seen_names.has(character_name)
			or str(character.get("group", "")).strip_edges().is_empty()
			or not _valid_string_array(character.get("aliases", null), true)
			or not (character.get("affiliations", null) is Array)
			or not _valid_source_refs(character.get("source_refs", null), sources_by_id)
		):
			blockers.append(_blocker("character_record_invalid", "人物记录字段、姓名、分组或来源无效。", [character_id]))
			continue
		seen_names[character_name] = true
		if not candidate_set.has(character_id):
			continue
		if not identity_by_character.has(character_id):
			blockers.append(_blocker("candidate_identity_claim_missing", "新增人物缺少规范姓名事实。", [character_id]))
			continue
		var claims: Array = claims_by_character.get(character_id, [])
		var expected_aliases: Array[String] = []
		var expected_sources: Array[String] = []
		var expected_affiliations: Array[String] = []
		for claim_value in claims:
			var claim: Dictionary = claim_value
			match str(claim.get("field", "")):
				"alias":
					expected_aliases.append(str(claim.get("value", "")))
				"affiliation":
					expected_affiliations.append(str(claim.get("value", "")))
			for source_id_value in claim.get("source_refs", []):
				var source_id := str(source_id_value)
				if source_id not in expected_sources:
					expected_sources.append(source_id)
		var actual_aliases := _string_values(character.get("aliases", []))
		var actual_sources := _string_values(character.get("source_refs", []))
		var actual_affiliations: Array[String] = []
		for affiliation_value in character.get("affiliations", []):
			if affiliation_value is Dictionary:
				actual_affiliations.append(str((affiliation_value as Dictionary).get("id", "")))
		expected_aliases.sort()
		expected_sources.sort()
		expected_affiliations.sort()
		actual_aliases.sort()
		actual_sources.sort()
		actual_affiliations.sort()
		if actual_aliases != expected_aliases or actual_sources != expected_sources or actual_affiliations != expected_affiliations:
			blockers.append(_blocker("candidate_cache_mismatch", "新增人物缓存与事实表不一致。", [character_id]))
	return {"ok": blockers.is_empty(), "blocking_reasons": blockers}


static func _index_records(values: Array, id_key: String) -> Dictionary:
	var result := {}
	for value in values:
		if value is Dictionary:
			var record_id := str((value as Dictionary).get(id_key, ""))
			if not record_id.is_empty():
				result[record_id] = value
	return result


static func _valid_string_array(value: Variant, allow_empty: bool) -> bool:
	if not (value is Array):
		return false
	if not allow_empty and (value as Array).is_empty():
		return false
	var seen := {}
	for item in value:
		if not (item is String):
			return false
		var text := str(item).strip_edges()
		if text.is_empty() or seen.has(text):
			return false
		seen[text] = true
	return true


static func _valid_source_refs(value: Variant, sources_by_id: Dictionary) -> bool:
	if not _valid_string_array(value, false):
		return false
	for source_id_value in value:
		if not sources_by_id.has(str(source_id_value)):
			return false
	return true


static func _string_values(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			result.append(str(value))
	return result


static func _unique_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(value).strip_edges()
		if text.is_empty() or text in result:
			continue
		result.append(text)
	return result


static func _has_exact_keys(record: Dictionary, keys: Array) -> bool:
	if record.size() != keys.size():
		return false
	for key in keys:
		if not record.has(key):
			return false
	return true


static func _report(
	ready: bool,
	append_ids: Array,
	blockers: Array,
	summary: Dictionary,
	target_ids: Array = []
) -> Dictionary:
	return {
		"schema_version": 1,
		"record_type": "character_catalog_v4_data_candidate_validation",
		"stage": "M4-B5",
		"status": STATUS_READY if ready else STATUS_INVALID,
		"ready": ready,
		"formal_write_permitted": false,
		"runtime_activation_permitted": false,
		"portrait_assets_required": false,
		"candidate_append_ids": append_ids.duplicate(),
		"target_character_ids": target_ids.duplicate(),
		"summary": summary.duplicate(true),
		"blocking_reasons": blockers.duplicate(true),
	}


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "message": message}


static func _blocker(code: String, message: String, character_ids: Array = []) -> Dictionary:
	return {"code": code, "message": message, "character_ids": character_ids.duplicate()}
