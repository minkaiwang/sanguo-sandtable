class_name CharacterReleaseReadinessPolicy
extends RefCounted

## M4-A2.2：把人物真人审核、目录 v3 和 v15 研究契约汇总为只读发布门禁。
##
## 本策略只返回报告，不读写文件，不提升人物，也不允许正式运行写入。

const BatchPolicy = preload("res://src/character_review_batch_policy.gd")

const STATUS_AWAITING_REVIEW := "awaiting_human_review"
const STATUS_PARTIAL_REVIEW := "partial_human_review"
const STATUS_REVISION_REQUIRED := "revision_required"
const STATUS_DEFERRED := "deferred_candidates"
const STATUS_READY := "ready_for_release_candidate"
const STATUS_INVALID := "invalid_release_inputs"


static func evaluate(
	review_document: Variant,
	overview_document: Variant,
	expected_review_ids: Array,
	expected_review_metadata: Dictionary,
	review_input_lock_sha256: String,
	review_input_lock_valid: bool,
	material_preflight_valid: bool,
	formal_ids: Array,
	target_ids: Array,
	catalog_counts: Dictionary,
	migration_contract: Variant
) -> Dictionary:
	var input_validation := _validate_release_inputs(
		overview_document,
		expected_review_ids,
		review_input_lock_sha256,
		review_input_lock_valid,
		material_preflight_valid,
		formal_ids,
		target_ids,
		catalog_counts,
		migration_contract
	)
	if not bool(input_validation.get("ok", false)):
		return _report(
			STATUS_INVALID,
			false,
			[],
			{},
			[],
			input_validation.get("blocking_reasons", []),
			"修复目录、总览或迁移契约后重新运行门禁。"
		)

	var release_order: Array[String] = []
	release_order.assign(input_validation.get("release_order", []))
	if review_document == null:
		return _report(
			STATUS_AWAITING_REVIEW,
			false,
			release_order,
			{
				"total": expected_review_ids.size(),
				"pending": expected_review_ids.size(),
				"approved": 0,
				"revise": 0,
				"deferred": 0,
			},
			[],
			[{
				"code": "human_review_draft_missing",
				"message": "尚未找到 20 人真人审核草稿。",
				"character_ids": [],
			}],
			"在 20 人总览速审中标记例外、确认其余并显式保存。"
		)

	var review_validation := _validate_review_document(
		review_document,
		overview_document,
		expected_review_ids,
		expected_review_metadata,
		review_input_lock_sha256
	)
	if not bool(review_validation.get("ok", false)):
		return _report(
			STATUS_INVALID,
			false,
			release_order,
			review_validation.get("summary", {}),
			[],
			review_validation.get("blocking_reasons", []),
			"不要手工修补损坏的审核草稿；回到总览速审重新保存。"
		)

	var decisions: Dictionary = review_validation.get("decisions", {})
	var summary: Dictionary = review_validation.get("summary", {})
	var approved_ids: Array[String] = []
	var pending_ids: Array[String] = []
	var revise_ids: Array[String] = []
	var deferred_ids: Array[String] = []
	for character_id in release_order:
		match str(decisions.get(character_id, BatchPolicy.DECISION_PENDING)):
			BatchPolicy.DECISION_APPROVED:
				approved_ids.append(character_id)
			BatchPolicy.DECISION_REVISE:
				revise_ids.append(character_id)
			BatchPolicy.DECISION_DEFERRED:
				deferred_ids.append(character_id)
			_:
				pending_ids.append(character_id)

	var blockers: Array[Dictionary] = []
	if not revise_ids.is_empty():
		blockers.append({
			"code": "portrait_revision_required",
			"message": "%d 位人物需要返工。" % revise_ids.size(),
			"character_ids": revise_ids,
		})
	if not deferred_ids.is_empty():
		blockers.append({
			"code": "candidate_review_deferred",
			"message": "%d 位人物被暂缓，不能进入本次 60 人发布。" % deferred_ids.size(),
			"character_ids": deferred_ids,
		})
	if not pending_ids.is_empty():
		blockers.append({
			"code": "human_review_incomplete",
			"message": "%d 位人物仍未审核。" % pending_ids.size(),
			"character_ids": pending_ids,
		})

	if not revise_ids.is_empty():
		return _report(
			STATUS_REVISION_REQUIRED,
			false,
			release_order,
			summary,
			approved_ids,
			blockers,
			"只为“需返工”人物建立新候选版本；通过者冻结，暂缓者不提升。"
		)
	if not deferred_ids.is_empty():
		return _report(
			STATUS_DEFERRED,
			false,
			release_order,
			summary,
			approved_ids,
			blockers,
			"明确暂缓人物是否退出本次发布，或完成复核后重新保存。"
		)
	if not pending_ids.is_empty():
		return _report(
			STATUS_PARTIAL_REVIEW,
			false,
			release_order,
			summary,
			approved_ids,
			blockers,
			"完成剩余人物审核并显式保存。"
		)
	return _report(
		STATUS_READY,
		true,
		release_order,
		summary,
		approved_ids,
		[],
		"冻结批准清单与资产哈希，建立预变更备份，再单独实施目录 v3／v15 发布候选。"
	)


static func _validate_release_inputs(
	overview_document: Variant,
	expected_review_ids: Array,
	review_input_lock_sha256: String,
	review_input_lock_valid: bool,
	material_preflight_valid: bool,
	formal_ids: Array,
	target_ids: Array,
	catalog_counts: Dictionary,
	migration_contract: Variant
) -> Dictionary:
	var blockers: Array[Dictionary] = []
	if not (overview_document is Dictionary):
		blockers.append(_blocker("overview_invalid", "20 人总览契约不可用。"))
		return {"ok": false, "blocking_reasons": blockers}
	var overview: Dictionary = overview_document
	if (
		int(overview.get("schema_version", 0)) != 1
		or str(overview.get("overview_id", "")) != "m4_a2_character_review_overview_20"
		or str(overview.get("runtime_policy", "")) != "research_only_not_loaded_not_searchable_not_serialized"
		or str(overview.get("review_mode", "")) != "mark_exceptions_then_confirm_remainder"
		or int(overview.get("candidate_count", 0)) != 20
		or int(overview.get("catalog_version", 0)) != 3
		or int(overview.get("baseline_formal_count", 0)) != 40
		or bool(overview.get("promotion_allowed", true))
	):
		blockers.append(_blocker("overview_contract_mismatch", "20 人总览契约版本或正式边界不一致。"))

	var normalized_expected := _unique_ids(expected_review_ids)
	var normalized_formal := _unique_ids(formal_ids)
	var normalized_target := _unique_ids(target_ids)
	if normalized_expected.size() != 20 or normalized_expected.size() != expected_review_ids.size():
		blockers.append(_blocker("review_id_set_invalid", "审核人物 ID 必须恰好为 20 个且不能重复。"))
	if review_input_lock_sha256.length() != 64 or not review_input_lock_valid:
		blockers.append(_blocker("review_input_lock_invalid", "真人审核输入锁缺失、哈希异常或素材校验未闭合。"))
	if not material_preflight_valid:
		blockers.append(_blocker("release_material_preflight_invalid", "20 人事实、四维、小传或头像发布材料尚未通过技术预检。"))
	if normalized_formal.size() != 40 or normalized_formal.size() != formal_ids.size():
		blockers.append(_blocker("formal_catalog_invalid", "正式目录必须恰好为 40 个唯一 ID。"))
	if normalized_target.size() != 60 or normalized_target.size() != target_ids.size():
		blockers.append(_blocker("target_catalog_invalid", "目标目录必须恰好为 60 个唯一 ID。"))
	if blockers.is_empty():
		for index in range(normalized_formal.size()):
			if normalized_target[index] != normalized_formal[index]:
				blockers.append(_blocker("catalog_prefix_changed", "目录 v3 必须保持正式 40 人的原 ID 与顺序。"))
				break
		var suffix: Array[String] = []
		for index in range(40, normalized_target.size()):
			suffix.append(normalized_target[index])
		if not _same_id_set(suffix, normalized_expected):
			blockers.append(_blocker("catalog_suffix_mismatch", "目录 v3 新增 20 人与真人审核集合不一致。"))

	var expected_counts := {
		"catalog": 60,
		"formal": 40,
		"candidate_review": 20,
		"editorial_review": 0,
		"needs_material": 0,
		"portraits": 60,
		"fallbacks": 0,
	}
	for count_key in expected_counts:
		if int(catalog_counts.get(count_key, -1)) != int(expected_counts[count_key]):
			blockers.append(_blocker(
				"catalog_count_mismatch",
				"60 人研究目录计数不满足发布准备要求：%s。" % count_key
			))
			break

	if not (migration_contract is Dictionary):
		blockers.append(_blocker("migration_contract_invalid", "v15 迁移研究契约不可用。"))
	else:
		var contract: Dictionary = migration_contract
		var source: Dictionary = contract.get("source", {})
		var target: Dictionary = contract.get("target", {})
		var catalog_rule: Dictionary = contract.get("catalog_rule", {})
		var payload: Dictionary = contract.get("payload_rule", {})
		var transaction: Dictionary = contract.get("transaction_rule", {})
		var rollback: Dictionary = contract.get("rollback_rule", {})
		var changed_paths: Array = payload.get("changed_paths", [])
		if (
			int(contract.get("schema_version", 0)) != 1
			or str(contract.get("contract_id", "")) != "sandbox_v15_catalog_v3_migration_research_contract"
			or str(contract.get("status", "")) != "research_only_not_runtime"
			or int(source.get("save_version", 0)) != 14
			or int(source.get("character_catalog_version", 0)) != 2
			or int(source.get("character_count", 0)) != 40
			or int(target.get("save_version", 0)) != 15
			or int(target.get("character_catalog_version", 0)) != 3
			or int(target.get("character_count", 0)) != 60
			or str(catalog_rule.get("id_policy", "")) != "append_only_never_reuse"
			or int(catalog_rule.get("required_prefix_count", 0)) != 40
			or int(catalog_rule.get("required_append_count", 0)) != 20
			or bool(catalog_rule.get("reorder_existing_ids_allowed", true))
			or bool(catalog_rule.get("remove_existing_ids_allowed", true))
			or changed_paths.size() != 2
			or not _same_id_set(changed_paths, ["save_version", "character_catalog_version"])
			or not bool(payload.get("all_other_paths_must_be_deep_equal", false))
			or bool(payload.get("auto_create_new_character_cards", true))
			or bool(payload.get("auto_create_new_character_states", true))
			or bool(payload.get("auto_create_new_character_actions", true))
			or bool(payload.get("auto_create_new_character_troops", true))
			or bool(payload.get("auto_create_new_character_assignments", true))
			or bool(transaction.get("formal_runtime_hook_present", true))
			or bool(transaction.get("runtime_write_permitted", true))
			or not bool(transaction.get("raw_v14_backup_required_before_replace", false))
			or not bool(transaction.get("backup_must_be_byte_identical", false))
			or not bool(transaction.get("backup_sha256_required", false))
			or not bool(transaction.get("validate_before_replace", false))
			or not bool(transaction.get("atomic_replace_required", false))
			or str(transaction.get("write_failure_action", "")) != "preserve_original_and_block_writes"
			or str(transaction.get("validation_failure_action", "")) != "preserve_original_and_block_writes"
			or str(rollback.get("strategy", "")) != "restore_raw_v14_bytes"
			or bool(rollback.get("lossy_v15_to_v14_rewrite_allowed", true))
			or bool(rollback.get("rollback_without_raw_backup_allowed", true))
		):
			blockers.append(_blocker("migration_contract_mismatch", "v15 迁移契约缺少研究态、备份、校验或原子替换门禁。"))

	var release_order: Array[String] = []
	if normalized_target.size() == 60:
		for index in range(40, 60):
			release_order.append(normalized_target[index])
	return {
		"ok": blockers.is_empty(),
		"blocking_reasons": blockers,
		"release_order": release_order,
	}


static func _validate_review_document(
	review_document: Variant,
	overview_document: Variant,
	expected_review_ids: Array,
	expected_review_metadata: Dictionary,
	review_input_lock_sha256: String
) -> Dictionary:
	var blockers: Array[Dictionary] = []
	if not (review_document is Dictionary):
		return {
			"ok": false,
			"summary": {},
			"blocking_reasons": [_blocker("review_document_invalid", "真人审核草稿必须是 JSON 对象。")],
		}
	var review: Dictionary = review_document
	var overview: Dictionary = overview_document
	if not _has_exact_keys(review, [
		"schema_version",
		"record_type",
		"overview_id",
		"catalog_version",
		"baseline_formal_count",
		"exported_at",
		"promotion_allowed",
		"review_input_lock_sha256",
		"completion_state",
		"summary",
		"records",
	]):
		blockers.append(_blocker("review_top_level_fields_invalid", "真人审核草稿顶层字段不符合固定契约。"))
	if (
		int(review.get("schema_version", 0)) != 1
		or str(review.get("record_type", "")) != "human_character_review_overview_draft"
		or str(review.get("overview_id", "")) != str(overview.get("overview_id", ""))
		or int(review.get("catalog_version", 0)) != 3
		or int(review.get("baseline_formal_count", 0)) != 40
		or bool(review.get("promotion_allowed", true))
		or str(review.get("review_input_lock_sha256", "")) != review_input_lock_sha256
		or str(review.get("exported_at", "")).strip_edges().is_empty()
	):
		blockers.append(_blocker("review_contract_mismatch", "真人审核草稿的类型、版本或正式边界不一致。"))

	var values: Variant = review.get("records", [])
	if not (values is Array) or values.size() != 20:
		blockers.append(_blocker("review_record_count_invalid", "真人审核草稿必须完整保留 20 条人物记录。"))
		return {"ok": false, "summary": {}, "blocking_reasons": blockers}
	var expected_set := {}
	for character_id in expected_review_ids:
		expected_set[str(character_id)] = true
	var decisions := {}
	var seen := {}
	for value in values:
		if not (value is Dictionary):
			blockers.append(_blocker("review_record_invalid", "真人审核草稿包含非对象记录。"))
			continue
		var record: Dictionary = value
		var character_id := str(record.get("character_id", ""))
		var decision := str(record.get("decision", ""))
		if not _has_exact_keys(record, [
			"character_id",
			"name",
			"source_batch_id",
			"decision",
			"note",
		]):
			blockers.append(_blocker("review_record_fields_invalid", "真人审核逐人记录字段不符合固定契约。", [character_id]))
		if character_id.is_empty() or seen.has(character_id) or not expected_set.has(character_id):
			blockers.append(_blocker("review_character_invalid", "真人审核草稿包含空、重复或未知人物 ID。", [character_id]))
			continue
		if decision not in BatchPolicy.DECISIONS:
			blockers.append(_blocker("review_decision_invalid", "真人审核草稿包含未知审核结论。", [character_id]))
			continue
		var expected_metadata: Dictionary = expected_review_metadata.get(character_id, {})
		if (
			str(record.get("name", "")) != str(expected_metadata.get("name", ""))
			or str(record.get("source_batch_id", "")) != str(expected_metadata.get("source_batch_id", ""))
		):
			blockers.append(_blocker("review_identity_metadata_mismatch", "真人审核草稿中的姓名或来源批次与审核契约不一致。", [character_id]))
		seen[character_id] = true
		decisions[character_id] = decision
	if seen.size() != 20 or not _same_id_set(Array(seen.keys()), expected_review_ids):
		blockers.append(_blocker("review_character_set_mismatch", "真人审核草稿没有完整覆盖预期 20 人。"))

	var summary := BatchPolicy.summarize(expected_review_ids, decisions)
	var declared_summary: Variant = review.get("summary", {})
	if not (declared_summary is Dictionary):
		blockers.append(_blocker("review_summary_invalid", "真人审核草稿缺少汇总。"))
	else:
		for key in ["total", "pending", "approved", "revise", "deferred"]:
			if int((declared_summary as Dictionary).get(key, -1)) != int(summary.get(key, 0)):
				blockers.append(_blocker("review_summary_mismatch", "真人审核草稿汇总与逐人结论不一致。"))
				break
	var expected_completion := (
		"complete_for_release_planning"
		if int(summary.get("pending", 0)) == 0
		else "partial_review"
	)
	if str(review.get("completion_state", "")) != expected_completion:
		blockers.append(_blocker("review_completion_mismatch", "真人审核草稿完成状态与逐人结论不一致。"))
	return {
		"ok": blockers.is_empty(),
		"summary": summary,
		"decisions": decisions,
		"blocking_reasons": blockers,
	}


static func _report(
	status: String,
	ready: bool,
	release_order: Array,
	summary: Dictionary,
	approved_ids: Array,
	blocking_reasons: Array,
	next_action: String
) -> Dictionary:
	return {
		"schema_version": 1,
		"record_type": "character_release_readiness_report",
		"stage": "M4-A2.2",
		"status": status,
		"ready_for_release_candidate": ready,
		"formal_write_permitted": false,
		"automatic_promotion_permitted": false,
		"human_review": {
			"summary": summary.duplicate(true),
			"approved_ids": approved_ids.duplicate(),
		},
		"release_candidate": {
			"target_save_version": 15,
			"target_character_catalog_version": 3,
			"target_character_count": 60,
			"append_ids_in_catalog_order": release_order.duplicate(),
		},
		"blocking_reasons": blocking_reasons.duplicate(true),
		"next_action": next_action,
	}


static func _unique_ids(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var character_id := str(value)
		if character_id.is_empty() or character_id in result:
			continue
		result.append(character_id)
	return result


static func _same_id_set(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	var right_set := {}
	for value in right:
		right_set[str(value)] = true
	for value in left:
		if not right_set.has(str(value)):
			return false
	return true


static func _has_exact_keys(document: Dictionary, expected_keys: Array) -> bool:
	if document.size() != expected_keys.size():
		return false
	for key in expected_keys:
		if not document.has(key):
			return false
	return true


static func _blocker(code: String, message: String, character_ids: Array = []) -> Dictionary:
	return {
		"code": code,
		"message": message,
		"character_ids": character_ids.duplicate(),
	}
