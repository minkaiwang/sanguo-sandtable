class_name CharacterReviewOverviewPolicy
extends RefCounted

const BatchPolicy = preload("res://src/character_review_batch_policy.gd")


static func validate_overview(
	overview_document: Variant,
	batch_documents: Array,
	records_by_id: Dictionary
) -> Dictionary:
	if not (overview_document is Dictionary):
		return _failure("invalid_document", "总览速审契约必须是 JSON 对象。")
	var overview: Dictionary = overview_document
	if int(overview.get("schema_version", 0)) != 1:
		return _failure("invalid_schema", "总览速审契约版本必须为 1。")
	if str(overview.get("runtime_policy", "")) != "research_only_not_loaded_not_searchable_not_serialized":
		return _failure("invalid_runtime_policy", "总览速审必须保持研究态隔离。")
	if bool(overview.get("promotion_allowed", true)):
		return _failure("promotion_forbidden", "总览速审不能直接允许正式提升。")
	if str(overview.get("review_mode", "")) != "mark_exceptions_then_confirm_remainder":
		return _failure("invalid_review_mode", "总览速审必须采用先标例外、再确认其余的模式。")
	if batch_documents.size() != 2:
		return _failure("invalid_batch_count", "总览速审必须合并恰好两个审核批次。")
	var expected_batch_ids: Array = overview.get("expected_source_batch_ids", [])
	if expected_batch_ids.size() != batch_documents.size():
		return _failure("invalid_expected_batches", "总览速审的批次声明与实际批次不一致。")

	var source_character_ids: Array[String] = []
	var entries_by_id := {}
	var seen := {}
	var source_batch_ids: Array[String] = []
	for index in range(batch_documents.size()):
		var batch_value: Variant = batch_documents[index]
		var validation := BatchPolicy.validate_batch(batch_value, records_by_id)
		if not bool(validation.get("ok", false)):
			return _failure(
				"invalid_source_batch",
				"第 %d 个来源批次不可用：%s" % [
					index + 1,
					str(validation.get("message", "未知错误")),
				]
			)
		var batch: Dictionary = batch_value
		var batch_id := str(batch.get("batch_id", ""))
		if batch_id != str(expected_batch_ids[index]):
			return _failure("source_batch_mismatch", "来源批次顺序或 ID 不一致。")
		if (
			int(batch.get("catalog_version", 0)) != int(overview.get("catalog_version", 0))
			or int(batch.get("baseline_catalog_version", 0)) != int(overview.get("baseline_catalog_version", 0))
			or int(batch.get("baseline_formal_count", 0)) != int(overview.get("baseline_formal_count", 0))
		):
			return _failure("source_batch_baseline_mismatch", "来源批次与总览目录基线不一致。")
		source_batch_ids.append(batch_id)
		for entry_value in batch.get("characters", []):
			var entry: Dictionary = entry_value
			var character_id := str(entry.get("id", ""))
			if seen.has(character_id):
				return _failure("duplicate_character", "两个审核批次存在重复人物：%s" % character_id)
			seen[character_id] = true
			source_character_ids.append(character_id)
			var combined_entry := entry.duplicate(true)
			combined_entry["source_batch_id"] = batch_id
			entries_by_id[character_id] = combined_entry

	var candidate_count := int(overview.get("candidate_count", 0))
	var selection_mode := str(overview.get("selection_mode", "full_source"))
	var source_candidate_count := int(overview.get(
		"source_candidate_count",
		candidate_count
	))
	if source_character_ids.size() != source_candidate_count:
		return _failure("invalid_source_candidate_count", "来源批次人物数与契约声明不一致。")

	var character_ids: Array[String] = []
	var selected_entries_by_id := {}
	match selection_mode:
		"full_source":
			if source_character_ids.size() != candidate_count:
				return _failure("invalid_candidate_count", "总览人物数与契约声明不一致。")
			if source_character_ids.size() != 20:
				return _failure("invalid_overview_size", "完整总览速审必须恰好包含 20 人。")
			character_ids.assign(source_character_ids)
			selected_entries_by_id = entries_by_id.duplicate(true)
		"ordered_subset":
			var subset_values: Variant = overview.get("review_subset_ids", [])
			if not (subset_values is Array) or subset_values.size() != candidate_count:
				return _failure("invalid_review_subset_count", "重点速审人物数与契约声明不一致。")
			var subset_seen := {}
			for value in subset_values:
				var character_id := str(value)
				if (
					character_id.is_empty()
					or subset_seen.has(character_id)
					or character_id not in source_character_ids
				):
					return _failure("invalid_review_subset_identity", "重点速审含有重复或未知人物：%s" % character_id)
				subset_seen[character_id] = true
				character_ids.append(character_id)
				selected_entries_by_id[character_id] = (entries_by_id.get(character_id, {}) as Dictionary).duplicate(true)
		_:
			return _failure("invalid_selection_mode", "总览速审的人物选择方式无效。")
	return {
		"ok": true,
		"overview": overview.duplicate(true),
		"character_ids": character_ids,
		"entries_by_id": selected_entries_by_id,
		"source_character_ids": source_character_ids,
		"source_batch_ids": source_batch_ids,
	}


static func approve_pending(character_ids: Array, decisions: Dictionary) -> Dictionary:
	var result := decisions.duplicate(true)
	for character_id in character_ids:
		if BatchPolicy.normalize_decision(str(result.get(character_id, BatchPolicy.DECISION_PENDING))) == BatchPolicy.DECISION_PENDING:
			result[character_id] = BatchPolicy.DECISION_APPROVED
	return result


static func build_export(
	overview: Dictionary,
	character_ids: Array,
	records_by_id: Dictionary,
	entries_by_id: Dictionary,
	decisions: Dictionary,
	notes: Dictionary,
	exported_at: String,
	review_input_lock_sha256: String = ""
) -> Dictionary:
	var summary := BatchPolicy.summarize(character_ids, decisions)
	var result_records: Array[Dictionary] = []
	for character_id in character_ids:
		var record: Dictionary = records_by_id.get(character_id, {})
		var entry: Dictionary = entries_by_id.get(character_id, {})
		result_records.append({
			"character_id": character_id,
			"name": str(record.get("name", "")),
			"source_batch_id": str(entry.get("source_batch_id", "")),
			"decision": BatchPolicy.normalize_decision(str(decisions.get(character_id, BatchPolicy.DECISION_PENDING))),
			"note": str(notes.get(character_id, "")).strip_edges(),
		})
	var completion_state := "partial_review"
	if int(summary.get("pending", 0)) == 0:
		completion_state = str(overview.get(
			"completion_state_when_complete",
			"complete_for_release_planning"
		))
	return {
		"schema_version": 1,
		"record_type": "human_character_review_overview_draft",
		"overview_id": str(overview.get("overview_id", "")),
		"catalog_version": int(overview.get("catalog_version", 0)),
		"baseline_formal_count": int(overview.get("baseline_formal_count", 0)),
		"exported_at": exported_at,
		"promotion_allowed": false,
		"review_input_lock_sha256": review_input_lock_sha256,
		"completion_state": completion_state,
		"summary": summary,
		"records": result_records,
	}


static func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": code, "message": message}
