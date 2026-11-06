class_name CharacterCatalogCandidatePolicy
extends RefCounted


const CharacterCatalogPolicyScript = preload("res://src/character_catalog_policy.gd")
const CharacterClaimPolicyScript = preload("res://src/character_claim_policy.gd")
const CharacterResearchBatchPolicyScript = preload("res://src/character_research_batch_policy.gd")
const ATTRIBUTE_KEYS := ["character_id", "might", "intelligence", "leadership", "charisma"]


static func validate_candidate(
	runtime_characters_value: Variant,
	runtime_attributes_value: Variant,
	runtime_sources_value: Variant,
	runtime_claims_value: Variant,
	current_catalog_value: Variant,
	research_batch_value: Variant,
	draft_catalog_value: Variant,
	roster_value: Variant
) -> Dictionary:
	if not runtime_characters_value is Array:
		return _failure("runtime_characters_not_array", "运行人物必须是数组。")
	for document_value in [
		runtime_attributes_value,
		runtime_sources_value,
		runtime_claims_value,
		current_catalog_value,
		research_batch_value,
		draft_catalog_value,
		roster_value,
	]:
		if not document_value is Dictionary:
			return _failure("document_not_dictionary", "候选人物目录所需文档必须是对象。")

	var runtime_characters: Array = runtime_characters_value
	var runtime_attributes: Dictionary = runtime_attributes_value
	var runtime_sources: Dictionary = runtime_sources_value
	var runtime_claims: Dictionary = runtime_claims_value
	var current_catalog: Dictionary = current_catalog_value
	var research_batch: Dictionary = research_batch_value
	var draft_catalog: Dictionary = draft_catalog_value
	var roster: Dictionary = roster_value

	var current_catalog_result: Dictionary = CharacterCatalogPolicyScript.decode_manifest(
		current_catalog,
		runtime_characters
	)
	if not bool(current_catalog_result.get("ok", false)):
		return _failure(
			"invalid_current_catalog",
			"当前人物目录无效：%s" % current_catalog_result.get("message", "")
		)
	var batch_result: Dictionary = CharacterResearchBatchPolicyScript.validate_package(
		research_batch,
		runtime_characters,
		runtime_sources,
		roster
	)
	if not bool(batch_result.get("ok", false)):
		return _failure(
			"invalid_research_batch",
			"候选研究包无效：%s" % batch_result.get("message", "")
		)

	var combined_characters: Array = runtime_characters.duplicate(true)
	combined_characters.append_array((research_batch.get("characters", []) as Array).duplicate(true))
	var character_identity_result := _validate_character_identity_keys(combined_characters)
	if not bool(character_identity_result.get("ok", false)):
		return character_identity_result
	var draft_catalog_result: Dictionary = CharacterCatalogPolicyScript.decode_manifest(
		draft_catalog,
		combined_characters
	)
	if not bool(draft_catalog_result.get("ok", false)):
		return _failure(
			"invalid_draft_catalog",
			"候选人物目录无效：%s" % draft_catalog_result.get("message", "")
		)
	var current_ids: Array = current_catalog.get("character_ids", [])
	var draft_ids: Array = draft_catalog.get("character_ids", [])
	if draft_ids.slice(0, current_ids.size()) != current_ids:
		return _failure("catalog_prefix_changed", "候选人物目录不得改动既有 ID 及顺序。")
	var expected_suffix: Array[String] = []
	for character_value in research_batch.get("characters", []):
		expected_suffix.append(str((character_value as Dictionary).get("id", "")))
	if draft_ids.slice(current_ids.size(), draft_ids.size()) != expected_suffix:
		return _failure("catalog_suffix_mismatch", "候选人物目录新增段必须与研究包稳定顺序一致。")

	var combined_sources: Array = []
	var sources_by_id := {}
	for source_value in runtime_sources.get("sources", []):
		var source_result := _append_unique_source(source_value, combined_sources, sources_by_id)
		if not bool(source_result.get("ok", false)):
			return source_result
	for source_value in research_batch.get("source_registry_additions", []):
		var source_result := _append_unique_source(source_value, combined_sources, sources_by_id)
		if not bool(source_result.get("ok", false)):
			return source_result
	var declared_source_result := _validate_batch_source_declarations(research_batch)
	if not bool(declared_source_result.get("ok", false)):
		return declared_source_result

	var combined_claims: Array = (runtime_claims.get("claims", []) as Array).duplicate(true)
	combined_claims.append_array((research_batch.get("claims", []) as Array).duplicate(true))
	var claim_result: Dictionary = CharacterClaimPolicyScript.decode_document(
		{"schema_version": 2, "claims": combined_claims},
		_index_characters(combined_characters),
		sources_by_id
	)
	if not bool(claim_result.get("ok", false)):
		return _failure(
			"invalid_combined_claims",
			"40 人合并事实表无效：%s" % claim_result.get("message", "")
		)

	var runtime_records_value: Variant = runtime_attributes.get("records", null)
	if not runtime_records_value is Array:
		return _failure("runtime_attributes_not_array", "当前人物四维 records 必须是数组。")
	var combined_attributes: Array = (runtime_records_value as Array).duplicate(true)
	combined_attributes.append_array((research_batch.get("display_attributes", []) as Array).duplicate(true))
	var attribute_result := _validate_attributes(combined_attributes, combined_characters)
	if not bool(attribute_result.get("ok", false)):
		return attribute_result

	var cache_result := _validate_character_caches(
		combined_characters,
		claim_result.get("claims_by_character", {})
	)
	if not bool(cache_result.get("ok", false)):
		return cache_result

	var field_counts := {"identity": 0, "alias": 0, "affiliation": 0}
	for claim_value in combined_claims:
		var field := str((claim_value as Dictionary).get("field", ""))
		if field_counts.has(field):
			field_counts[field] = int(field_counts.get(field, 0)) + 1
	return {
		"ok": true,
		"catalog_version": int(draft_catalog_result.get("catalog_version", 0)),
		"character_count": combined_characters.size(),
		"source_count": combined_sources.size(),
		"claim_count": combined_claims.size(),
		"identity_count": int(field_counts.get("identity", 0)),
		"alias_count": int(field_counts.get("alias", 0)),
		"affiliation_count": int(field_counts.get("affiliation", 0)),
		"attribute_count": combined_attributes.size(),
		"current_prefix_count": current_ids.size(),
		"candidate_suffix_count": expected_suffix.size(),
		"characters": combined_characters,
		"sources": combined_sources,
		"claims": combined_claims,
		"attributes": combined_attributes,
	}


static func _append_unique_source(
	source_value: Variant,
	combined_sources: Array,
	sources_by_id: Dictionary
) -> Dictionary:
	if not source_value is Dictionary:
		return _failure("source_not_dictionary", "人物来源记录必须是对象。")
	var source: Dictionary = source_value
	var source_id := str(source.get("id", "")).strip_edges()
	if source_id.is_empty() or sources_by_id.has(source_id):
		return _failure("source_id_collision", "40 人来源注册表 ID 为空或冲突：%s。" % source_id)
	sources_by_id[source_id] = source.duplicate(true)
	combined_sources.append(source.duplicate(true))
	return {"ok": true}


static func _validate_batch_source_declarations(research_batch: Dictionary) -> Dictionary:
	var declared_sources := {}
	for source_id_value in research_batch.get("source_registry_reuse", []):
		declared_sources[str(source_id_value)] = true
	for source_value in research_batch.get("source_registry_additions", []):
		declared_sources[str((source_value as Dictionary).get("id", ""))] = true
	var used_sources := {}
	for claim_value in research_batch.get("claims", []):
		for source_id_value in (claim_value as Dictionary).get("source_refs", []):
			used_sources[str(source_id_value)] = true
	if declared_sources != used_sources:
		return _failure(
			"batch_source_declaration_mismatch",
			"候选研究包声明的复用／新增来源必须与本批事实实际使用来源完全一致。"
		)
	return {"ok": true}


static func _validate_character_identity_keys(characters: Array) -> Dictionary:
	var ids := {}
	var names := {}
	for character_value in characters:
		if not character_value is Dictionary:
			return _failure("character_not_dictionary", "40 人目录人物记录必须是对象。")
		var character: Dictionary = character_value
		var character_id := str(character.get("id", "")).strip_edges()
		var character_name := str(character.get("name", "")).strip_edges()
		if character_id.is_empty() or ids.has(character_id):
			return _failure("character_id_collision", "40 人目录人物 ID 为空或冲突：%s。" % character_id)
		if character_name.is_empty() or names.has(character_name):
			return _failure("character_name_collision", "40 人目录人物姓名为空或冲突：%s。" % character_name)
		ids[character_id] = true
		names[character_name] = true
	return {"ok": true}


static func _index_characters(characters: Array) -> Dictionary:
	var characters_by_id := {}
	for character_value in characters:
		if character_value is Dictionary:
			characters_by_id[str((character_value as Dictionary).get("id", ""))] = character_value
	return characters_by_id


static func _validate_attributes(attributes: Array, characters: Array) -> Dictionary:
	if attributes.size() != characters.size():
		return _failure("attribute_count_mismatch", "40 人四维数量必须与人物数量一致。")
	var character_ids := {}
	for character_value in characters:
		if not character_value is Dictionary:
			return _failure("character_not_dictionary", "40 人目录人物记录必须是对象。")
		var character_id := str((character_value as Dictionary).get("id", "")).strip_edges()
		if character_id.is_empty() or character_ids.has(character_id):
			return _failure("character_id_collision", "40 人目录人物 ID 为空或冲突。")
		character_ids[character_id] = true
	var attribute_ids := {}
	for attribute_value in attributes:
		if not attribute_value is Dictionary:
			return _failure("attribute_not_dictionary", "人物四维记录必须是对象。")
		var attribute: Dictionary = attribute_value
		if not _has_exact_keys(attribute, ATTRIBUTE_KEYS):
			return _failure("invalid_attribute_keys", "人物四维字段不完整或夹带未登记字段。")
		var character_id := str(attribute.get("character_id", "")).strip_edges()
		if not character_ids.has(character_id) or attribute_ids.has(character_id):
			return _failure("unknown_or_duplicate_attribute", "人物四维引用未知或重复人物：%s。" % character_id)
		attribute_ids[character_id] = true
		for dimension in ["might", "intelligence", "leadership", "charisma"]:
			if not _is_integer_in_range(attribute.get(dimension, null), 0, 100):
				return _failure("invalid_attribute_value", "人物四维必须是 0—100 整数：%s／%s。" % [character_id, dimension])
	return {"ok": true}


static func _validate_character_caches(characters: Array, claims_by_character_value: Variant) -> Dictionary:
	if not claims_by_character_value is Dictionary:
		return _failure("claims_index_not_dictionary", "人物事实索引无效。")
	var claims_by_character: Dictionary = claims_by_character_value
	for character_value in characters:
		var character: Dictionary = character_value
		var character_id := str(character.get("id", ""))
		if not character.get("aliases", null) is Array or not character.get("source_refs", null) is Array:
			return _failure("invalid_character_cache", "人物别名或来源缓存必须是数组：%s。" % character_id)
		var expected_aliases: Array[String] = []
		var expected_sources: Array[String] = []
		for claim_value in claims_by_character.get(character_id, []):
			var claim: Dictionary = claim_value
			if str(claim.get("field", "")) == "alias":
				expected_aliases.append(str(claim.get("value", "")))
			for source_id_value in claim.get("source_refs", []):
				var source_id := str(source_id_value)
				if not expected_sources.has(source_id):
					expected_sources.append(source_id)
		var actual_aliases: Array[String] = []
		for alias_value in character.get("aliases", []):
			actual_aliases.append(str(alias_value))
		var actual_sources: Array[String] = []
		for source_id_value in character.get("source_refs", []):
			var source_id := str(source_id_value)
			if not actual_sources.has(source_id):
				actual_sources.append(source_id)
		expected_aliases.sort()
		actual_aliases.sort()
		expected_sources.sort()
		actual_sources.sort()
		if actual_aliases != expected_aliases:
			return _failure("alias_cache_mismatch", "人物别名缓存与 40 人事实表不一致：%s。" % character_id)
		if actual_sources != expected_sources:
			return _failure("source_cache_mismatch", "人物来源缓存与 40 人事实表不一致：%s。" % character_id)
		if not character.get("affiliations", null) is Array:
			return _failure("invalid_affiliation_cache", "人物史料归属缓存必须是数组：%s。" % character_id)
		var expected_affiliation_ids: Array[String] = []
		for claim_value in claims_by_character.get(character_id, []):
			var claim: Dictionary = claim_value
			if str(claim.get("field", "")) == "affiliation":
				expected_affiliation_ids.append(str(claim.get("value", "")))
		var actual_affiliation_ids: Array[String] = []
		for affiliation_value in character.get("affiliations", []):
			if not affiliation_value is Dictionary:
				return _failure("invalid_affiliation_cache", "人物史料归属缓存包含无效记录：%s。" % character_id)
			actual_affiliation_ids.append(str((affiliation_value as Dictionary).get("id", "")))
		expected_affiliation_ids.sort()
		actual_affiliation_ids.sort()
		if actual_affiliation_ids != expected_affiliation_ids:
			return _failure("affiliation_cache_mismatch", "人物史料归属缓存与事实表不一致：%s。" % character_id)
	return {"ok": true}


static func _has_exact_keys(record: Dictionary, allowed: Array) -> bool:
	if record.size() != allowed.size():
		return false
	for key in record.keys():
		if not allowed.has(str(key)):
			return false
	return true


static func _is_integer_in_range(value: Variant, minimum: int, maximum: int) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] \
		and is_finite(float(value)) \
		and is_equal_approx(float(value), roundf(float(value))) \
		and int(value) >= minimum \
		and int(value) <= maximum


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
