class_name CharacterResearchBatchPolicy
extends RefCounted


const CharacterPromotionPolicyScript = preload("res://src/character_promotion_policy.gd")
const ROOT_KEYS := [
	"schema_version", "batch_id", "status", "runtime_policy", "retrieved_at",
	"target_character_catalog_version", "selected_character_count", "selection_rationale",
	"source_registry_reuse", "source_registry_additions", "characters", "claims",
	"display_attributes", "release_gates"
]
const SOURCE_KEYS := [
	"id", "work_title", "citation_title", "layer", "kind", "author", "annotator",
	"url", "permalink", "license", "license_url", "usage_status", "roles", "notes"
]
const REQUIRED_RELEASE_GATES := [
	"fixed_version_sources_reviewed",
	"atomic_promotion_gate_pass",
	"runtime_catalog_update_deferred",
	"save_version_update_deferred",
	"long_list_visual_test_deferred",
]


static func validate_package(
	package_value: Variant,
	runtime_characters_value: Variant,
	runtime_source_payload_value: Variant,
	roster_value: Variant
) -> Dictionary:
	if not package_value is Dictionary:
		return _failure("package_not_dictionary", "人物研究包必须是对象。")
	if not runtime_characters_value is Array:
		return _failure("runtime_characters_not_array", "运行人物必须是数组。")
	if not runtime_source_payload_value is Dictionary:
		return _failure("runtime_sources_not_dictionary", "运行来源注册表必须是对象。")
	if not roster_value is Dictionary:
		return _failure("roster_not_dictionary", "人物候选注册表必须是对象。")
	var package: Dictionary = package_value
	if not _has_exact_keys(package, ROOT_KEYS):
		return _failure("invalid_root_keys", "人物研究包根字段不完整或夹带未登记字段。")
	if not _is_integer(package.get("schema_version", null)) or int(package.get("schema_version", 0)) != 1:
		return _failure("unsupported_schema", "人物研究包只接受 schema v1。")
	if not _is_safe_id(str(package.get("batch_id", ""))):
		return _failure("invalid_batch_id", "人物研究包 batch_id 无效。")
	if str(package.get("status", "")) != "validated_research_package_not_runtime":
		return _failure("invalid_status", "人物研究包必须明确保持已核验研究态。")
	if str(package.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized":
		return _failure("invalid_runtime_policy", "人物研究包不得进入运行、搜索与存档。")
	if not _is_date(str(package.get("retrieved_at", ""))):
		return _failure("invalid_retrieved_at", "人物研究包缺少 YYYY-MM-DD 核验日期。")
	if not _is_integer(package.get("target_character_catalog_version", null)) \
			or int(package.get("target_character_catalog_version", 0)) != 2:
		return _failure("invalid_target_catalog", "首批人物研究包目标目录必须是 v2。")
	if not package.get("selection_rationale", null) is String \
			or str(package.get("selection_rationale", "")).strip_edges().is_empty():
		return _failure("missing_selection_rationale", "人物研究包必须说明分批依据。")
	var release_gates_value: Variant = package.get("release_gates", null)
	if not release_gates_value is Array:
		return _failure("release_gates_not_array", "人物研究包 release_gates 必须是数组。")
	var release_gates: Array = release_gates_value
	for required_gate in REQUIRED_RELEASE_GATES:
		if not release_gates.has(required_gate):
			return _failure("missing_release_gate", "人物研究包缺少发布门禁：%s。" % required_gate)

	var runtime_ids := {}
	for runtime_character_value in runtime_characters_value:
		if not runtime_character_value is Dictionary:
			return _failure("invalid_runtime_character", "运行人物记录无效。")
		var runtime_id := str((runtime_character_value as Dictionary).get("id", "")).strip_edges()
		if runtime_id.is_empty() or runtime_ids.has(runtime_id):
			return _failure("invalid_runtime_catalog", "运行人物 ID 为空或重复。")
		runtime_ids[runtime_id] = true

	var roster_candidates := {}
	for candidate_value in roster_value.get("candidates", []):
		if candidate_value is Dictionary:
			var candidate_id := str((candidate_value as Dictionary).get("id", "")).strip_edges()
			if not candidate_id.is_empty():
				roster_candidates[candidate_id] = candidate_value

	var runtime_sources_by_id := {}
	var merged_sources: Array = []
	for source_value in runtime_source_payload_value.get("sources", []):
		if not source_value is Dictionary:
			return _failure("invalid_runtime_source", "运行来源记录无效。")
		var source: Dictionary = source_value
		var source_id := str(source.get("id", "")).strip_edges()
		if source_id.is_empty() or runtime_sources_by_id.has(source_id):
			return _failure("invalid_runtime_source_registry", "运行来源 ID 为空或重复。")
		runtime_sources_by_id[source_id] = source
		merged_sources.append(source.duplicate(true))

	var reuse_value: Variant = package.get("source_registry_reuse", null)
	if not reuse_value is Array:
		return _failure("source_reuse_not_array", "复用来源清单必须是数组。")
	var reused_sources := {}
	for source_id_value in reuse_value:
		if not source_id_value is String:
			return _failure("invalid_reused_source", "复用来源 ID 必须是字符串。")
		var source_id := str(source_id_value).strip_edges()
		if source_id.is_empty() or reused_sources.has(source_id) or not runtime_sources_by_id.has(source_id):
			return _failure("unknown_or_duplicate_reused_source", "复用来源不存在或重复：%s。" % source_id)
		reused_sources[source_id] = true

	var additions_value: Variant = package.get("source_registry_additions", null)
	if not additions_value is Array:
		return _failure("source_additions_not_array", "新增来源必须是数组。")
	var addition_ids := {}
	for source_value in additions_value:
		var source_result := _validate_source_record(source_value)
		if not bool(source_result.get("ok", false)):
			return source_result
		var source: Dictionary = source_result.get("source", {})
		var source_id := str(source.get("id", ""))
		if runtime_sources_by_id.has(source_id) or addition_ids.has(source_id):
			return _failure("source_id_collision", "新增来源 ID 与现有或本批来源冲突：%s。" % source_id)
		addition_ids[source_id] = true
		merged_sources.append(source.duplicate(true))
	var merged_source_payload := {
		"schema_version": 1,
		"retrieved_at": str(package.get("retrieved_at", "")),
		"sources": merged_sources,
	}

	var characters_value: Variant = package.get("characters", null)
	var claims_value: Variant = package.get("claims", null)
	var attributes_value: Variant = package.get("display_attributes", null)
	if not characters_value is Array or not claims_value is Array or not attributes_value is Array:
		return _failure("invalid_package_arrays", "人物、事实与四维必须都是数组。")
	var characters: Array = characters_value
	var claims: Array = claims_value
	var attributes: Array = attributes_value
	if not _is_integer(package.get("selected_character_count", null)) \
			or int(package.get("selected_character_count", 0)) != characters.size() \
			or characters.is_empty():
		return _failure("selected_count_mismatch", "人物研究包声明数量与实际人物不一致。")
	if attributes.size() != characters.size():
		return _failure("attribute_count_mismatch", "人物研究包四维数量必须与人物一致。")

	var characters_by_id := {}
	var attributes_by_id := {}
	for attribute_value in attributes:
		if not attribute_value is Dictionary:
			return _failure("attribute_not_dictionary", "人物研究包四维记录必须是对象。")
		var character_id := str((attribute_value as Dictionary).get("character_id", "")).strip_edges()
		if character_id.is_empty() or attributes_by_id.has(character_id):
			return _failure("duplicate_or_empty_attribute", "人物研究包四维人物 ID 为空或重复。")
		attributes_by_id[character_id] = attribute_value
	for character_value in characters:
		if not character_value is Dictionary:
			return _failure("character_not_dictionary", "人物研究包人物记录必须是对象。")
		var character: Dictionary = character_value
		var character_id := str(character.get("id", "")).strip_edges()
		if character_id.is_empty() or characters_by_id.has(character_id):
			return _failure("duplicate_or_empty_character", "人物研究包人物 ID 为空或重复。")
		if runtime_ids.has(character_id):
			return _failure("character_id_collision", "研究人物不得已存在于运行目录：%s。" % character_id)
		if not roster_candidates.has(character_id):
			return _failure("character_not_in_roster", "研究人物不在 D10A 候选表：%s。" % character_id)
		var roster_candidate: Dictionary = roster_candidates.get(character_id, {})
		if str(roster_candidate.get("name", "")) != str(character.get("name", "")) \
				or str(roster_candidate.get("proposed_group", "")) != str(character.get("group", "")):
			return _failure("roster_identity_mismatch", "研究人物姓名或原型分类与 D10A 候选不一致：%s。" % character_id)
		if not attributes_by_id.has(character_id):
			return _failure("missing_attribute", "研究人物缺少同批项目四维：%s。" % character_id)
		characters_by_id[character_id] = character

	for character_id in attributes_by_id.keys():
		if not characters_by_id.has(character_id):
			return _failure("unrelated_attribute", "人物研究包夹带无关四维：%s。" % character_id)
	for claim_value in claims:
		if not claim_value is Dictionary:
			return _failure("claim_not_dictionary", "人物研究包事实记录必须是对象。")
		if not characters_by_id.has(str((claim_value as Dictionary).get("character_id", ""))):
			return _failure("unrelated_claim", "人物研究包夹带无关人物事实。")

	var identity_count := 0
	var alias_count := 0
	for character_id in characters_by_id.keys():
		var per_character_claims: Array = []
		for claim_value in claims:
			if str((claim_value as Dictionary).get("character_id", "")) == character_id:
				per_character_claims.append((claim_value as Dictionary).duplicate(true))
				if str((claim_value as Dictionary).get("field", "")) == "identity":
					identity_count += 1
				elif str((claim_value as Dictionary).get("field", "")) == "alias":
					alias_count += 1
		var result: Dictionary = CharacterPromotionPolicyScript.validate_initial_promotion(
			(characters_by_id.get(character_id, {}) as Dictionary).duplicate(true),
			(attributes_by_id.get(character_id, {}) as Dictionary).duplicate(true),
			{"schema_version": 2, "claims": per_character_claims},
			runtime_characters_value,
			merged_source_payload
		)
		if not bool(result.get("ok", false)):
			return _failure(
				"atomic_promotion_failed",
				"人物研究包未通过单人原子提升门禁：%s；%s。" % [character_id, result.get("message", "")]
			)
	return {
		"ok": true,
		"batch_id": str(package.get("batch_id", "")),
		"character_count": characters.size(),
		"identity_count": identity_count,
		"alias_count": alias_count,
		"new_source_count": addition_ids.size(),
		"reused_source_count": reused_sources.size(),
	}


static func _validate_source_record(source_value: Variant) -> Dictionary:
	if not source_value is Dictionary:
		return _failure("source_not_dictionary", "新增来源记录必须是对象。")
	var source: Dictionary = source_value
	if not _has_exact_keys(source, SOURCE_KEYS):
		return _failure("invalid_source_keys", "新增来源字段不完整或夹带未登记字段。")
	var source_id := str(source.get("id", "")).strip_edges()
	if not _is_safe_id(source_id):
		return _failure("invalid_source_id", "新增来源 ID 无效。")
	for field in ["work_title", "citation_title", "kind", "author", "url", "permalink", "license", "license_url", "usage_status", "notes"]:
		if not source.get(field, null) is String or str(source.get(field, "")).strip_edges().is_empty():
			return _failure("missing_source_text", "新增来源缺少字段：%s。" % field)
	if str(source.get("layer", "")) not in ["historical", "romance"]:
		return _failure("invalid_source_layer", "新增来源层级无效。")
	if str(source.get("kind", "")) != "digitized_primary_text":
		return _failure("invalid_source_kind", "新增人物身份来源必须是数字化原始文本。")
	if str(source.get("permalink", "")).find("oldid=") == -1:
		return _failure("source_not_fixed_version", "新增来源必须使用 oldid 固定版本。")
	if str(source.get("usage_status", "")) != "reference_only":
		return _failure("invalid_source_usage", "数字文本只能作为引用来源。")
	if str(source.get("license", "")).find("public_domain_work") == -1 \
			or str(source.get("license", "")).find("cc_by_sa_4_0") == -1:
		return _failure("invalid_source_license", "新增来源必须分别声明古籍原作与页面许可。")
	var roles_value: Variant = source.get("roles", null)
	if not roles_value is Array or not (roles_value as Array).has("character_identity"):
		return _failure("missing_identity_role", "新增来源必须允许人物身份核验。")
	return {"ok": true, "source": source.duplicate(true)}


static func _has_exact_keys(record: Dictionary, allowed: Array) -> bool:
	if record.size() != allowed.size():
		return false
	for key in record.keys():
		if not allowed.has(str(key)):
			return false
	return true


static func _is_integer(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] \
		and is_finite(float(value)) \
		and is_equal_approx(float(value), roundf(float(value)))


static func _is_safe_id(value: String) -> bool:
	if value.is_empty() or value.length() > 96:
		return false
	var pattern := RegEx.new()
	return pattern.compile("^[a-z0-9][a-z0-9_]*$") == OK and pattern.search(value) != null


static func _is_date(value: String) -> bool:
	var pattern := RegEx.new()
	return pattern.compile("^\\d{4}-\\d{2}-\\d{2}$") == OK and pattern.search(value) != null


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
