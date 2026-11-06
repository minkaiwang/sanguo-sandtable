class_name CharacterNextTextPolicy
extends RefCounted


const ResearchPolicy = preload("res://src/character_next_research_policy.gd")
const EDITORIAL_ROOT_KEYS := [
	"schema_version", "batch_id", "status", "runtime_policy", "retrieved_at",
	"target_character_catalog_version", "selected_character_count",
	"identity_fact_package", "attribute_rubric_ref", "source_registry_reuse",
	"source_registry_additions", "display_attributes", "editorial_uncertainty",
	"attribute_calibration_notes", "profiles", "group_reviews",
	"boundary_guards", "release_gates",
]
const DIMENSIONS := ["might", "intelligence", "leadership", "charisma"]
const COLLECTION_KEYS := {
	"display_attributes": ["character_id", "might", "intelligence", "leadership", "charisma"],
	"editorial_uncertainty": ["character_id", "might", "intelligence", "leadership", "charisma"],
	"attribute_calibration_notes": ["character_id", "anchor_ids", "notes"],
	"profiles": ["character_id", "headline", "biography", "source_refs"],
	"group_reviews": ["character_id", "proposed_group", "review_status", "rationale", "historical_affiliations"],
	"boundary_guards": ["character_id", "forbidden_assertions", "evidence_boundary"],
}
const REQUIRED_EDITORIAL_GATES := {
	"identity_and_alias_facts": "completed",
	"attribute_rubric_draft": "completed",
	"biography_drafts": "completed",
	"prototype_group_review": "completed",
	"portrait_pipeline": "blocked",
	"catalog_and_save_migration": "blocked",
}


static func validate_pipeline(
	queue: Dictionary,
	batch_05_facts: Dictionary,
	batch_05_editorial: Dictionary,
	batch_06_facts: Dictionary,
	formal_catalog: Dictionary,
	review_roster: Dictionary,
	scenarios: Dictionary,
	sources: Dictionary,
	formal_attributes: Dictionary
) -> Dictionary:
	var queue_result: Dictionary = ResearchPolicy.validate_queue(
		queue, formal_catalog, review_roster, scenarios
	)
	if not bool(queue_result.get("ok", false)):
		return queue_result
	var batch_05_result: Dictionary = ResearchPolicy.validate_identity_package(
		batch_05_facts, queue, formal_catalog, review_roster, sources
	)
	if not bool(batch_05_result.get("ok", false)):
		return batch_05_result
	var batch_06_result: Dictionary = ResearchPolicy.validate_identity_package(
		batch_06_facts, queue, formal_catalog, review_roster, sources
	)
	if not bool(batch_06_result.get("ok", false)):
		return batch_06_result
	var editorial_result := validate_editorial_package(
		batch_05_editorial, batch_05_facts, queue, sources, formal_attributes
	)
	if not bool(editorial_result.get("ok", false)):
		return editorial_result
	if (
		int(queue_result.get("completed_identity_count", 0)) != 20
		or int(queue_result.get("completed_editorial_count", 0)) < 10
		or int(queue_result.get("pending_source_count", -1)) != 0
	):
		return _failure(
			"pipeline_progress_mismatch",
			"人物文字生产线必须保持身份 20／20、至少完成首批 10 人编辑、待选来源 0。"
		)
	return {
		"ok": true,
		"identity_count": int(batch_05_result.get("identity_count", 0))
			+ int(batch_06_result.get("identity_count", 0)),
		"identity_claim_count": int(batch_05_result.get("claim_count", 0))
			+ int(batch_06_result.get("claim_count", 0)),
		"editorial_count": int(editorial_result.get("character_count", 0)),
		"profile_count": int(editorial_result.get("profile_count", 0)),
		"attribute_count": int(editorial_result.get("attribute_count", 0)),
		"formal_count": int(queue_result.get("formal_count", 0)),
		"review_count": int(queue_result.get("review_count", 0)),
		"promoted_count": int(queue_result.get("promoted_count", 0)),
		"research_count": int(queue_result.get("candidate_count", 0)),
	}


static func validate_editorial_package(
	draft: Dictionary,
	facts: Dictionary,
	queue: Dictionary,
	formal_sources: Dictionary,
	formal_attributes: Dictionary,
	expected_batch_id: String = "m2_d49_batch_05_editorial_draft",
	expected_fact_ref: String = "references/candidates/character_promotion_batch_05_facts.json"
) -> Dictionary:
	if not _has_exact_keys(draft, EDITORIAL_ROOT_KEYS):
		return _failure("invalid_editorial_root_keys", "人物编辑资料根字段不完整或夹带未登记字段。")
	if int(draft.get("schema_version", 0)) != 1:
		return _failure("unsupported_editorial_schema", "人物编辑资料只接受 schema v1。")
	if str(draft.get("batch_id", "")) != expected_batch_id:
		return _failure("invalid_editorial_batch", "人物编辑资料批次编号不一致。")
	if str(draft.get("status", "")) != "validated_editorial_draft_not_runtime":
		return _failure("invalid_editorial_status", "人物编辑资料必须保持已验证研究态。")
	if str(draft.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized":
		return _failure("invalid_editorial_runtime_policy", "人物编辑资料不得进入运行、搜索或存档。")
	if int(draft.get("target_character_catalog_version", 0)) != 4:
		return _failure("invalid_editorial_target_catalog", "人物编辑资料必须指向未来目录 v4。")
	if str(draft.get("identity_fact_package", "")) != expected_fact_ref:
		return _failure("invalid_editorial_fact_ref", "人物编辑资料引用了错误的身份事实包。")
	if str(draft.get("attribute_rubric_ref", "")) != "references/candidates/character_display_attribute_rubric_v1_draft.json":
		return _failure("invalid_editorial_rubric_ref", "人物编辑资料引用了错误的四维量表。")
	if not (draft.get("source_registry_additions", null) is Array) or not (draft.get("source_registry_additions", []) as Array).is_empty():
		return _failure("editorial_source_addition_forbidden", "编辑资料只能复用身份事实来源，不得另加来源。")

	var expected_ids: Array[String] = []
	var fact_characters := {}
	for value in facts.get("characters", []):
		if not value is Dictionary:
			return _failure("invalid_editorial_fact_character", "身份事实包含有无效人物。")
		var character: Dictionary = value
		var character_id := str(character.get("id", ""))
		expected_ids.append(character_id)
		fact_characters[character_id] = character
	if expected_ids.size() != 10 or int(draft.get("selected_character_count", 0)) != expected_ids.size():
		return _failure("editorial_character_count_mismatch", "人物编辑资料必须恰好覆盖第一批 10 人。")

	var queue_characters := {}
	for value in queue.get("candidates", []):
		if value is Dictionary:
			queue_characters[str((value as Dictionary).get("id", ""))] = value
	for character_id in expected_ids:
		if not queue_characters.has(character_id):
			return _failure("editorial_character_not_in_queue", "编辑人物不在研究队列：%s。" % character_id)
		if str((queue_characters[character_id] as Dictionary).get("editorial_status", "")) != "completed":
			return _failure("queue_editorial_not_completed", "研究队列未记录人物编辑完成：%s。" % character_id)

	var allowed_source_ids := {}
	for source_id in facts.get("source_registry_reuse", []):
		allowed_source_ids[str(source_id)] = true
	for value in facts.get("source_registry_additions", []):
		if value is Dictionary:
			allowed_source_ids[str((value as Dictionary).get("id", ""))] = true
	var reused_sources_result := _unique_strings(draft.get("source_registry_reuse", []))
	if not bool(reused_sources_result.get("ok", false)):
		return _failure("invalid_editorial_sources", "人物编辑资料复用来源为空或重复。")
	var reused_source_ids: Array = reused_sources_result.get("values", [])
	if reused_source_ids.size() != allowed_source_ids.size():
		return _failure("editorial_source_count_mismatch", "人物编辑资料必须完整复用身份事实来源。")
	for source_id in reused_source_ids:
		if not allowed_source_ids.has(str(source_id)):
			return _failure("editorial_unknown_source", "人物编辑资料引用了计划外来源：%s。" % source_id)

	var formal_attribute_ids := {}
	for value in formal_attributes.get("records", []):
		if value is Dictionary:
			formal_attribute_ids[str((value as Dictionary).get("character_id", ""))] = true
	if formal_attribute_ids.size() != 60:
		return _failure("invalid_formal_attribute_baseline", "四维锚点必须绑定正式 60 人资料。")

	var collections := {}
	for collection_name in COLLECTION_KEYS:
		var values: Variant = draft.get(collection_name, null)
		if not values is Array:
			return _failure("editorial_collection_not_array", "人物编辑资料集合无效：%s。" % collection_name)
		var ids: Array[String] = []
		var by_id := {}
		for value in values:
			if not value is Dictionary:
				return _failure("editorial_record_not_dictionary", "人物编辑资料记录必须是对象：%s。" % collection_name)
			var record: Dictionary = value
			if not _has_exact_keys(record, COLLECTION_KEYS[collection_name]):
				return _failure("invalid_editorial_record_keys", "人物编辑资料记录字段错误：%s。" % collection_name)
			var character_id := str(record.get("character_id", ""))
			if character_id in ids:
				return _failure("duplicate_editorial_character", "人物编辑资料重复：%s／%s。" % [collection_name, character_id])
			ids.append(character_id)
			by_id[character_id] = record
		if ids != expected_ids:
			return _failure("editorial_order_mismatch", "人物编辑资料必须逐项按批次顺序覆盖：%s。" % collection_name)
		collections[collection_name] = by_id

	for character_id in expected_ids:
		var attributes: Dictionary = collections["display_attributes"][character_id]
		var uncertainty: Dictionary = collections["editorial_uncertainty"][character_id]
		var calibration: Dictionary = collections["attribute_calibration_notes"][character_id]
		var anchors: Variant = calibration.get("anchor_ids", null)
		var notes: Variant = calibration.get("notes", null)
		if not anchors is Dictionary or not notes is Dictionary:
			return _failure("invalid_editorial_calibration", "人物四维校准资料无效：%s。" % character_id)
		if not _has_exact_keys(anchors, DIMENSIONS) or not _has_exact_keys(notes, DIMENSIONS):
			return _failure("invalid_editorial_dimensions", "人物四维校准维度不完整：%s。" % character_id)
		for dimension in DIMENSIONS:
			var score: Variant = attributes.get(dimension, null)
			var width: Variant = uncertainty.get(dimension, null)
			if (
				not (score is int or score is float)
				or float(score) < 0.0
				or float(score) > 100.0
				or float(score) != floor(float(score))
			):
				return _failure("invalid_editorial_score", "人物四维必须为 0–100 整数：%s／%s。" % [character_id, dimension])
			if (
				not (width is int or width is float)
				or float(width) < 5.0
				or float(width) > 9.0
				or float(width) != floor(float(width))
			):
				return _failure("invalid_editorial_uncertainty", "人物编辑不确定区间必须为 5–9：%s／%s。" % [character_id, dimension])
			var anchor_result := _unique_strings((anchors as Dictionary).get(dimension, []))
			if not bool(anchor_result.get("ok", false)) or (anchor_result.get("values", []) as Array).size() < 2:
				return _failure("insufficient_editorial_anchors", "每一维至少需要两个正式人物锚点：%s／%s。" % [character_id, dimension])
			for anchor_id in anchor_result.get("values", []):
				if not formal_attribute_ids.has(str(anchor_id)):
					return _failure("unknown_editorial_anchor", "四维锚点不在正式 60 人资料：%s。" % anchor_id)
			if str((notes as Dictionary).get(dimension, "")).strip_edges().is_empty():
				return _failure("missing_editorial_note", "人物四维缺少编制理由：%s／%s。" % [character_id, dimension])

		var profile: Dictionary = collections["profiles"][character_id]
		var headline := str(profile.get("headline", ""))
		var biography := str(profile.get("biography", ""))
		if headline.length() < 4 or headline.length() > 40:
			return _failure("invalid_editorial_headline", "人物小传标题必须为 4–40 字：%s。" % character_id)
		if biography.length() < 80 or biography.length() > 160:
			return _failure("invalid_editorial_biography", "人物小传必须为 80–160 字：%s。" % character_id)
		var profile_sources_result := _unique_strings(profile.get("source_refs", []))
		if not bool(profile_sources_result.get("ok", false)):
			return _failure("invalid_profile_sources", "人物小传来源为空或重复：%s。" % character_id)
		var fact_sources: Array = (fact_characters[character_id] as Dictionary).get("source_refs", [])
		for source_id in fact_sources:
			if str(source_id) not in profile_sources_result.get("values", []):
				return _failure("profile_missing_identity_source", "人物小传缺少身份来源：%s／%s。" % [character_id, source_id])
		for source_id in profile_sources_result.get("values", []):
			if not allowed_source_ids.has(str(source_id)):
				return _failure("profile_unknown_source", "人物小传引用了计划外来源：%s／%s。" % [character_id, source_id])

		var group_review: Dictionary = collections["group_reviews"][character_id]
		if str(group_review.get("proposed_group", "")) != str((fact_characters[character_id] as Dictionary).get("prototype_group_candidate", "")):
			return _failure("editorial_group_mismatch", "人物原型分组与身份事实不一致：%s。" % character_id)
		if str(group_review.get("review_status", "")) != "retained_as_interface_prototype":
			return _failure("invalid_group_review_status", "人物原型分组必须明确为界面原型：%s。" % character_id)
		if str(group_review.get("rationale", "")).strip_edges().is_empty():
			return _failure("missing_group_rationale", "人物原型分组缺少说明：%s。" % character_id)
		if not (group_review.get("historical_affiliations", null) is Array) or not (group_review.get("historical_affiliations", []) as Array).is_empty():
			return _failure("editorial_inferred_affiliation", "人物编辑资料不得从原型组生成历史归属：%s。" % character_id)

		var boundary: Dictionary = collections["boundary_guards"][character_id]
		var forbidden_result := _unique_strings(boundary.get("forbidden_assertions", []))
		if not bool(forbidden_result.get("ok", false)) or (forbidden_result.get("values", []) as Array).size() < 2:
			return _failure("missing_editorial_boundaries", "人物至少需要两项避写断言：%s。" % character_id)
		if str(boundary.get("evidence_boundary", "")).strip_edges().is_empty():
			return _failure("missing_editorial_evidence_boundary", "人物缺少证据边界：%s。" % character_id)

	var gate_statuses := {}
	for value in draft.get("release_gates", []):
		if not value is Dictionary or not _has_exact_keys(value, ["id", "status", "requirement"]):
			return _failure("invalid_editorial_gate", "人物编辑资料发布门禁无效。")
		var gate: Dictionary = value
		var gate_id := str(gate.get("id", ""))
		if gate_statuses.has(gate_id) or str(gate.get("requirement", "")).strip_edges().is_empty():
			return _failure("invalid_editorial_gate_identity", "人物编辑资料门禁重复或缺少要求。")
		gate_statuses[gate_id] = str(gate.get("status", ""))
	if gate_statuses != REQUIRED_EDITORIAL_GATES:
		return _failure("invalid_editorial_gate_statuses", "人物编辑资料只能完成文字环节，头像和正式迁移必须阻塞。")
	return {
		"ok": true,
		"character_count": expected_ids.size(),
		"attribute_count": (draft.get("display_attributes", []) as Array).size(),
		"profile_count": (draft.get("profiles", []) as Array).size(),
		"source_count": reused_source_ids.size(),
	}


static func _unique_strings(values: Variant) -> Dictionary:
	if not values is Array:
		return {"ok": false, "values": []}
	var result: Array[String] = []
	for value in values:
		if not value is String:
			return {"ok": false, "values": []}
		var text := str(value).strip_edges()
		if text.is_empty() or text in result:
			return {"ok": false, "values": []}
		result.append(text)
	return {"ok": not result.is_empty(), "values": result}


static func _has_exact_keys(record: Dictionary, expected: Array) -> bool:
	if record.size() != expected.size():
		return false
	for key in record.keys():
		if str(key) not in expected:
			return false
	return true


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
