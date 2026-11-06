class_name CharacterReviewBatchPolicy
extends RefCounted

const DECISION_PENDING := "pending"
const DECISION_APPROVED := "approved"
const DECISION_REVISE := "revise"
const DECISION_DEFERRED := "deferred"
const DECISIONS := [
	DECISION_PENDING,
	DECISION_APPROVED,
	DECISION_REVISE,
	DECISION_DEFERRED,
]


static func validate_batch(document: Variant, records_by_id: Dictionary) -> Dictionary:
	if not (document is Dictionary):
		return _failure("invalid_document", "审核批次必须是 JSON 对象。")
	var batch: Dictionary = document
	if int(batch.get("schema_version", 0)) != 1:
		return _failure("invalid_schema", "审核批次版本必须为 1。")
	if str(batch.get("runtime_policy", "")) != "research_only_not_loaded_not_searchable_not_serialized":
		return _failure("invalid_runtime_policy", "审核批次必须保持研究态隔离。")
	if bool(batch.get("promotion_allowed", true)):
		return _failure("promotion_forbidden", "快速审核不能直接允许正式提升。")
	var values: Variant = batch.get("characters", [])
	if not (values is Array) or values.size() != int(batch.get("candidate_count", 0)):
		return _failure("invalid_candidate_count", "审核人数与批次声明不一致。")
	if values.size() != 10:
		return _failure("invalid_batch_size", "快速审核批次必须恰好包含 10 人。")
	var seen := {}
	var character_ids: Array[String] = []
	for value in values:
		if not (value is Dictionary):
			return _failure("invalid_character", "审核人物记录必须是对象。")
		var entry: Dictionary = value
		var character_id := str(entry.get("id", ""))
		if character_id.is_empty() or seen.has(character_id):
			return _failure("invalid_character_id", "审核人物 ID 为空或重复。")
		if not records_by_id.has(character_id):
			return _failure("unknown_character", "审核人物不在当前研究目录：%s" % character_id)
		var record: Dictionary = records_by_id[character_id]
		if str(record.get("status_id", "")) != "candidate_review":
			return _failure("not_candidate", "正式人物不能混入候选快审：%s" % character_id)
		if str(entry.get("name", "")) != str(record.get("name", "")):
			return _failure("name_mismatch", "审核人物姓名与研究目录不一致：%s" % character_id)
		if str(entry.get("visual_focus", "")).strip_edges().is_empty():
			return _failure("missing_visual_focus", "每位候选都必须有视觉检查点。")
		seen[character_id] = true
		character_ids.append(character_id)
	return {
		"ok": true,
		"batch": batch.duplicate(true),
		"character_ids": character_ids,
	}


static func normalize_decision(value: String) -> String:
	return value if value in DECISIONS else DECISION_PENDING


static func decision_label(value: String) -> String:
	match normalize_decision(value):
		DECISION_APPROVED:
			return "通过"
		DECISION_REVISE:
			return "需返工"
		DECISION_DEFERRED:
			return "暂缓"
		_:
			return "未审核"


static func summarize(character_ids: Array, decisions: Dictionary) -> Dictionary:
	var result := {
		"total": character_ids.size(),
		"pending": 0,
		"approved": 0,
		"revise": 0,
		"deferred": 0,
	}
	for character_id in character_ids:
		var decision := normalize_decision(str(decisions.get(character_id, DECISION_PENDING)))
		result[decision] = int(result.get(decision, 0)) + 1
	return result


static func build_export(
	batch: Dictionary,
	character_ids: Array,
	records_by_id: Dictionary,
	decisions: Dictionary,
	notes: Dictionary,
	exported_at: String
) -> Dictionary:
	var summary := summarize(character_ids, decisions)
	var result_records: Array[Dictionary] = []
	for character_id in character_ids:
		var record: Dictionary = records_by_id.get(character_id, {})
		result_records.append({
			"character_id": character_id,
			"name": str(record.get("name", "")),
			"decision": normalize_decision(str(decisions.get(character_id, DECISION_PENDING))),
			"note": str(notes.get(character_id, "")).strip_edges(),
		})
	return {
		"schema_version": 1,
		"record_type": "human_character_review_draft",
		"batch_id": str(batch.get("batch_id", "")),
		"catalog_version": int(batch.get("catalog_version", 0)),
		"exported_at": exported_at,
		"promotion_allowed": false,
		"completion_state": (
			"complete_for_release_planning"
			if int(summary.get("pending", 0)) == 0
			else "partial_review"
		),
		"summary": summary,
		"records": result_records,
	}


static func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": code, "message": message}
