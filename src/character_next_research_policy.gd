class_name CharacterNextResearchPolicy
extends RefCounted


const QUEUE_ROOT_KEYS := [
	"schema_version", "queue_id", "status", "runtime_policy",
	"formal_catalog_version", "formal_character_count",
	"review_target_catalog_version", "review_candidate_count",
	"target_character_catalog_version", "target_runtime_count",
	"interpretation", "batches", "candidates", "release_gates",
]
const BATCH_KEYS := [
	"id", "name", "sequence", "character_ids", "identity_fact_package",
	"identity_status", "next_stage",
]
const CANDIDATE_KEYS := [
	"id", "name", "batch_id", "priority", "content_lane", "target_scenarios",
	"prototype_group_candidate", "prototype_group_status", "planned_source_refs",
	"source_lookup", "source_plan_status", "identity_status", "editorial_status",
	"portrait_status", "human_review_status", "promotion_status",
]
const FACT_ROOT_KEYS := [
	"schema_version", "claim_schema_version", "batch_id", "queue_ref", "status",
	"runtime_policy", "retrieved_at", "target_character_catalog_version",
	"selected_character_count", "selection_rationale", "source_registry_reuse",
	"source_registry_additions", "characters", "claims",
	"source_boundary_decisions", "release_gates",
]
const FACT_CHARACTER_KEYS := [
	"id", "name", "batch_id", "prototype_group_candidate", "aliases",
	"affiliations", "source_refs", "identity_claim_id", "alias_claim_ids",
	"source_status", "locator_status", "aliases_status", "editorial_status",
	"portrait_status", "human_review_status", "promotion_status",
]
const CLAIM_KEYS := [
	"id", "character_id", "field", "value", "layer", "source_refs",
	"source_locator", "confidence",
]
const SOURCE_KEYS := [
	"id", "work_title", "citation_title", "layer", "kind", "author",
	"annotator", "url", "permalink", "license", "license_url",
	"usage_status", "roles", "notes",
]
const REQUIRED_QUEUE_GATES := [
	"catalog_v3_60_promotion_complete_before_any_v4_runtime_work",
	"all_20_portrait_candidates_generated_pending_visual_review",
	"batch_05_identity_facts_complete",
	"batch_06_identity_facts_complete",
	"all_20_editorial_portrait_and_human_review_required",
	"catalog_v4_and_future_save_migration_atomic",
	"runtime_files_must_not_reference_queue",
]
const REQUIRED_FACT_GATES := {
	"fixed_source_locator": "completed",
	"identity_and_alias_facts": "completed",
	"existing_20_human_review": "blocked",
	"project_editorial_package": "blocked",
	"portrait_pipeline": "blocked",
	"catalog_and_save_migration": "blocked",
}
const ALLOWED_PROTOTYPE_GROUPS := ["刘备军", "群雄", "曹氏", "孙氏"]


static func validate_queue(
	queue_value: Variant,
	formal_catalog_value: Variant,
	review_roster_value: Variant,
	scenario_templates_value: Variant
) -> Dictionary:
	if not queue_value is Dictionary:
		return _failure("queue_not_dictionary", "下一批人物队列必须是对象。")
	if not formal_catalog_value is Dictionary:
		return _failure("formal_catalog_not_dictionary", "正式人物目录必须是对象。")
	if not review_roster_value is Dictionary:
		return _failure("review_roster_not_dictionary", "待审人物表必须是对象。")
	if not scenario_templates_value is Dictionary:
		return _failure("scenarios_not_dictionary", "剧本模板必须是对象。")
	var queue: Dictionary = queue_value
	var formal_catalog: Dictionary = formal_catalog_value
	var review_roster: Dictionary = review_roster_value
	var scenario_templates: Dictionary = scenario_templates_value
	if not _has_exact_keys(queue, QUEUE_ROOT_KEYS):
		return _failure("invalid_queue_root_keys", "下一批人物队列根字段不完整或夹带未登记字段。")
	if int(queue.get("schema_version", 0)) != 1:
		return _failure("unsupported_queue_schema", "下一批人物队列只接受 schema v1。")
	if not _is_safe_id(str(queue.get("queue_id", ""))):
		return _failure("invalid_queue_id", "下一批人物队列编号无效。")
	if str(queue.get("status", "")) != "research_queue_not_runtime":
		return _failure("invalid_queue_status", "下一批人物队列必须保持研究态。")
	if str(queue.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized":
		return _failure("invalid_queue_runtime_policy", "下一批人物队列不得进入运行、搜索或存档。")
	if (
		int(queue.get("formal_catalog_version", 0)) != 3
		or int(queue.get("formal_character_count", 0)) != 60
		or int(queue.get("review_target_catalog_version", 0)) != 3
		or int(queue.get("review_candidate_count", -1)) != 0
		or int(queue.get("target_character_catalog_version", 0)) != 4
		or int(queue.get("target_runtime_count", 0)) != 80
	):
		return _failure("invalid_queue_versions", "下一批人物队列必须绑定正式目录 v3／60 人，并指向未来目录 v4／80 人。")
	if str(queue.get("interpretation", "")).strip_edges().is_empty():
		return _failure("missing_queue_interpretation", "下一批人物队列缺少用途说明。")

	var formal_ids_result := _unique_strings(formal_catalog.get("character_ids", []))
	if not bool(formal_ids_result.get("ok", false)):
		return _failure("invalid_formal_ids", "正式人物目录 ID 为空或重复。")
	var formal_ids: Array = formal_ids_result.get("values", [])
	if (
		int(formal_catalog.get("character_catalog_version", 0)) != 3
		or int(formal_catalog.get("runtime_character_count", 0)) != 60
		or formal_ids.size() != 60
	):
		return _failure("invalid_formal_baseline", "下一批人物队列必须绑定正式目录 v3／60 人。")
	var review_ids: Array[String] = []
	for candidate_value in review_roster.get("candidates", []):
		if not candidate_value is Dictionary:
			return _failure("invalid_review_candidate", "待审人物表含有无效记录。")
		var candidate_id := str((candidate_value as Dictionary).get("id", "")).strip_edges()
		if candidate_id.is_empty() or candidate_id in review_ids:
			return _failure("invalid_review_ids", "待审人物 ID 为空或重复。")
		review_ids.append(candidate_id)
	if review_ids.size() != 20:
		return _failure("invalid_review_count", "目录 v3 提升记录必须完整保留原 20 人审核批次。")
	for promoted_id in review_ids:
		if promoted_id not in formal_ids:
			return _failure("review_promotion_incomplete", "原审核批次尚未完整进入正式目录 v3：%s。" % promoted_id)

	var historical_scenario_ids: Array[String] = []
	for template_value in scenario_templates.get("templates", []):
		if not template_value is Dictionary:
			continue
		var template: Dictionary = template_value
		if str(template.get("scenario_kind", "")) != "historical_start":
			continue
		var scenario_id := str(template.get("scenario_id", "")).strip_edges()
		if scenario_id.is_empty() or scenario_id in historical_scenario_ids:
			return _failure("invalid_historical_scenario_ids", "历史开局编号为空或重复。")
		historical_scenario_ids.append(scenario_id)
	if historical_scenario_ids.size() != 5:
		return _failure("invalid_historical_scenario_count", "下一批人物队列当前需要五个历史开局。")

	var batches_value: Variant = queue.get("batches", null)
	if not batches_value is Array or (batches_value as Array).size() != 2:
		return _failure("invalid_batches", "下一批 20 人必须拆成两个十人生产批次。")
	var batches_by_id := {}
	var batch_character_ids: Array[String] = []
	for batch_index in range((batches_value as Array).size()):
		var batch_value: Variant = (batches_value as Array)[batch_index]
		if not batch_value is Dictionary:
			return _failure("batch_not_dictionary", "人物生产批次必须是对象。")
		var batch: Dictionary = batch_value
		if not _has_exact_keys(batch, BATCH_KEYS):
			return _failure("invalid_batch_keys", "人物生产批次字段不完整或夹带未登记字段。")
		var batch_id := str(batch.get("id", "")).strip_edges()
		if not _is_safe_id(batch_id) or batches_by_id.has(batch_id):
			return _failure("invalid_batch_id", "人物生产批次编号为空、重复或无效。")
		if str(batch.get("name", "")).strip_edges().is_empty():
			return _failure("missing_batch_name", "人物生产批次缺少名称。")
		if int(batch.get("sequence", 0)) != batch_index + 1:
			return _failure("invalid_batch_sequence", "人物生产批次顺序必须连续。")
		var ids_result := _unique_strings(batch.get("character_ids", []))
		if not bool(ids_result.get("ok", false)) or (ids_result.get("values", []) as Array).size() != 10:
			return _failure("invalid_batch_character_ids", "每个人物生产批次必须恰好包含 10 个唯一 ID。")
		var identity_status := str(batch.get("identity_status", ""))
		if identity_status not in ["completed", "planned"]:
			return _failure("invalid_batch_identity_status", "人物生产批次身份状态无效。")
		var fact_path := str(batch.get("identity_fact_package", "")).strip_edges()
		if identity_status == "completed" and (fact_path.is_empty() or not FileAccess.file_exists(fact_path)):
			return _failure("missing_completed_fact_package", "已完成身份核验的批次缺少事实包。")
		if identity_status == "planned" and not fact_path.is_empty():
			return _failure("premature_planned_fact_package", "计划中批次不得预填事实包路径。")
		if str(batch.get("next_stage", "")).strip_edges().is_empty():
			return _failure("missing_batch_next_stage", "人物生产批次缺少下一环节。")
		batches_by_id[batch_id] = batch
		for character_id in ids_result.get("values", []):
			if str(character_id) in batch_character_ids:
				return _failure("candidate_in_multiple_batches", "人物不能进入多个生产批次：%s。" % character_id)
			batch_character_ids.append(str(character_id))

	var candidates_value: Variant = queue.get("candidates", null)
	if not candidates_value is Array or (candidates_value as Array).size() != 20:
		return _failure("invalid_queue_candidate_count", "下一批人物队列必须恰好包含 20 人。")
	var candidates_by_id := {}
	var completed_identity_count := 0
	var completed_editorial_count := 0
	var pending_source_count := 0
	for candidate_value in candidates_value:
		if not candidate_value is Dictionary:
			return _failure("queue_candidate_not_dictionary", "下一批人物记录必须是对象。")
		var candidate: Dictionary = candidate_value
		if not _has_exact_keys(candidate, CANDIDATE_KEYS):
			return _failure("invalid_queue_candidate_keys", "下一批人物字段不完整或夹带未登记字段。")
		var candidate_id := str(candidate.get("id", "")).strip_edges()
		var candidate_name := str(candidate.get("name", "")).strip_edges()
		var batch_id := str(candidate.get("batch_id", "")).strip_edges()
		if not _is_safe_id(candidate_id) or candidates_by_id.has(candidate_id) or candidate_name.is_empty():
			return _failure("invalid_queue_candidate_identity", "下一批人物 ID 或姓名无效：%s。" % candidate_id)
		if candidate_id in formal_ids or candidate_id in review_ids:
			return _failure("queue_candidate_collision", "下一批人物与正式或待审人物重复：%s。" % candidate_id)
		if not batches_by_id.has(batch_id) or candidate_id not in ((batches_by_id[batch_id] as Dictionary).get("character_ids", []) as Array):
			return _failure("candidate_batch_mismatch", "下一批人物与生产批次不一致：%s。" % candidate_id)
		if str(candidate.get("priority", "")) not in ["P0", "P1"]:
			return _failure("invalid_candidate_priority", "下一批人物优先级无效：%s。" % candidate_id)
		if str(candidate.get("content_lane", "")).strip_edges().is_empty():
			return _failure("missing_content_lane", "下一批人物缺少内容线：%s。" % candidate_id)
		if str(candidate.get("prototype_group_candidate", "")) not in ALLOWED_PROTOTYPE_GROUPS:
			return _failure("invalid_prototype_group", "下一批人物原型分类候选无效：%s。" % candidate_id)
		if str(candidate.get("prototype_group_status", "")) != "research_suggestion_not_affiliation":
			return _failure("invalid_prototype_group_status", "原型分类必须明确保持研究建议：%s。" % candidate_id)
		var target_result := _unique_strings(candidate.get("target_scenarios", []), true)
		if not bool(target_result.get("ok", false)):
			return _failure("invalid_target_scenarios", "下一批人物剧本标签无效：%s。" % candidate_id)
		for scenario_id in target_result.get("values", []):
			if str(scenario_id) not in historical_scenario_ids:
				return _failure("unknown_target_scenario", "下一批人物引用未知历史开局：%s。" % scenario_id)
		var source_result := _unique_strings(candidate.get("planned_source_refs", []), true)
		var lookup_result := _unique_strings(candidate.get("source_lookup", []))
		if not bool(source_result.get("ok", false)) or not bool(lookup_result.get("ok", false)):
			return _failure("invalid_source_plan", "下一批人物来源计划无效：%s。" % candidate_id)
		var source_status := str(candidate.get("source_plan_status", ""))
		if source_status not in ["fixed_source_selected", "fixed_source_lookup_pending"]:
			return _failure("invalid_source_plan_status", "下一批人物来源状态无效：%s。" % candidate_id)
		if source_status == "fixed_source_selected" and (source_result.get("values", []) as Array).is_empty():
			return _failure("selected_source_missing_ref", "已选固定来源的人物缺少来源 ID：%s。" % candidate_id)
		if source_status == "fixed_source_lookup_pending":
			pending_source_count += 1
		var identity_status := str(candidate.get("identity_status", ""))
		if identity_status not in ["completed", "required_not_completed"]:
			return _failure("invalid_candidate_identity_status", "下一批人物身份状态无效：%s。" % candidate_id)
		if identity_status == "completed":
			completed_identity_count += 1
			if source_status != "fixed_source_selected":
				return _failure("completed_identity_without_fixed_source", "完成身份核验的人物必须已有固定来源：%s。" % candidate_id)
		var editorial_status := str(candidate.get("editorial_status", ""))
		if editorial_status not in ["required_not_completed", "completed"]:
			return _failure("invalid_candidate_editorial_status", "下一批人物编辑状态无效：%s。" % candidate_id)
		if editorial_status == "completed":
			if identity_status != "completed":
				return _failure("editorial_without_identity", "人物完成编辑前必须先完成身份核验：%s。" % candidate_id)
			completed_editorial_count += 1
		if str(candidate.get("portrait_status", "")) != "required_not_completed":
			return _failure("premature_candidate_portrait", "下一批人物尚不得提前完成头像：%s。" % candidate_id)
		if str(candidate.get("human_review_status", "")) != "required_not_started":
			return _failure("invalid_human_review_status", "下一批人物真人审核尚未开始：%s。" % candidate_id)
		if str(candidate.get("promotion_status", "")) != "blocked_research_only":
			return _failure("invalid_candidate_promotion_status", "下一批人物必须保持研究态阻断：%s。" % candidate_id)
		candidates_by_id[candidate_id] = candidate
	if candidates_by_id.size() != 20 or batch_character_ids != candidates_by_id.keys():
		return _failure("queue_batch_order_mismatch", "下一批人物顺序必须与两个生产批次完全一致。")
	if queue.get("release_gates", []) != REQUIRED_QUEUE_GATES:
		return _failure("invalid_queue_release_gates", "下一批人物队列发布门禁不完整或顺序改变。")
	return {
		"ok": true,
		"formal_count": formal_ids.size(),
		"review_count": 0,
		"promoted_count": review_ids.size(),
		"candidate_count": candidates_by_id.size(),
		"batch_count": batches_by_id.size(),
		"completed_identity_count": completed_identity_count,
		"pending_identity_count": candidates_by_id.size() - completed_identity_count,
		"completed_editorial_count": completed_editorial_count,
		"pending_editorial_count": candidates_by_id.size() - completed_editorial_count,
		"pending_source_count": pending_source_count,
	}


static func validate_identity_package(
	package_value: Variant,
	queue_value: Variant,
	formal_catalog_value: Variant,
	review_roster_value: Variant,
	source_payload_value: Variant
) -> Dictionary:
	if not package_value is Dictionary:
		return _failure("fact_package_not_dictionary", "人物身份事实包必须是对象。")
	if not queue_value is Dictionary or not formal_catalog_value is Dictionary:
		return _failure("fact_package_context_invalid", "人物身份事实包缺少队列或正式目录。")
	if not review_roster_value is Dictionary or not source_payload_value is Dictionary:
		return _failure("fact_package_sources_invalid", "人物身份事实包缺少待审表或来源登记。")
	var package: Dictionary = package_value
	var queue: Dictionary = queue_value
	var formal_catalog: Dictionary = formal_catalog_value
	var review_roster: Dictionary = review_roster_value
	var source_payload: Dictionary = source_payload_value
	if not _has_exact_keys(package, FACT_ROOT_KEYS):
		return _failure("invalid_fact_root_keys", "人物身份事实包根字段不完整或夹带未登记字段。")
	if int(package.get("schema_version", 0)) != 1 or int(package.get("claim_schema_version", 0)) != 2:
		return _failure("unsupported_fact_schema", "人物身份事实包只接受 schema v1／claim v2。")
	if str(package.get("status", "")) != "validated_identity_facts_not_runtime":
		return _failure("invalid_fact_status", "人物身份事实包必须保持已核验研究态。")
	if str(package.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized":
		return _failure("invalid_fact_runtime_policy", "人物身份事实包不得进入运行、搜索或存档。")
	if not _is_date(str(package.get("retrieved_at", ""))):
		return _failure("invalid_fact_date", "人物身份事实包缺少有效核验日期。")
	if int(package.get("target_character_catalog_version", 0)) != int(queue.get("target_character_catalog_version", -1)):
		return _failure("fact_target_catalog_mismatch", "人物身份事实包目标目录与研究队列不一致。")
	if str(package.get("queue_ref", "")) != "res://references/candidates/character_research_queue_v1.json":
		return _failure("invalid_queue_ref", "人物身份事实包必须绑定当前研究队列。")
	if not package.get("selection_rationale", null) is Array or (package.get("selection_rationale", []) as Array).is_empty():
		return _failure("missing_fact_rationale", "人物身份事实包缺少分批说明。")

	var batches_by_id := {}
	for batch_value in queue.get("batches", []):
		if batch_value is Dictionary:
			batches_by_id[str((batch_value as Dictionary).get("id", ""))] = batch_value
	var batch_id := str(package.get("batch_id", ""))
	if not batches_by_id.has(batch_id):
		return _failure("unknown_fact_batch", "人物身份事实包不属于当前研究队列。")
	var expected_ids: Array = ((batches_by_id[batch_id] as Dictionary).get("character_ids", []) as Array).duplicate()
	if int(package.get("selected_character_count", 0)) != expected_ids.size():
		return _failure("fact_selected_count_mismatch", "人物身份事实包数量与生产批次不一致。")
	var queue_candidates_by_id := {}
	for candidate_value in queue.get("candidates", []):
		if candidate_value is Dictionary:
			queue_candidates_by_id[str((candidate_value as Dictionary).get("id", ""))] = candidate_value

	var forbidden_ids := {}
	for character_id in formal_catalog.get("character_ids", []):
		forbidden_ids[str(character_id)] = true
	for candidate_value in review_roster.get("candidates", []):
		if candidate_value is Dictionary:
			forbidden_ids[str((candidate_value as Dictionary).get("id", ""))] = true

	var sources_by_id := {}
	for source_value in source_payload.get("sources", []):
		if not source_value is Dictionary:
			return _failure("invalid_registered_source", "正式来源登记含有无效记录。")
		var source_id := str((source_value as Dictionary).get("id", ""))
		if source_id.is_empty() or sources_by_id.has(source_id):
			return _failure("invalid_registered_source_ids", "正式来源 ID 为空或重复。")
		sources_by_id[source_id] = source_value
	var reused_source_ids: Array[String] = []
	for source_id_value in package.get("source_registry_reuse", []):
		var source_id := str(source_id_value).strip_edges()
		if source_id.is_empty() or source_id in reused_source_ids or not sources_by_id.has(source_id):
			return _failure("unknown_or_duplicate_reused_source", "人物身份事实包复用来源不存在或重复：%s。" % source_id)
		reused_source_ids.append(source_id)
	var added_source_ids: Array[String] = []
	for source_value in package.get("source_registry_additions", []):
		var source_result := _validate_source(source_value)
		if not bool(source_result.get("ok", false)):
			return source_result
		var source: Dictionary = source_result.get("source", {})
		var source_id := str(source.get("id", ""))
		if sources_by_id.has(source_id) or source_id in added_source_ids:
			return _failure("fact_source_collision", "人物身份事实包新增来源与现有来源冲突：%s。" % source_id)
		added_source_ids.append(source_id)
		sources_by_id[source_id] = source

	var characters_value: Variant = package.get("characters", null)
	var claims_value: Variant = package.get("claims", null)
	if not characters_value is Array or not claims_value is Array:
		return _failure("invalid_fact_arrays", "人物身份事实包人物与事实必须是数组。")
	if (characters_value as Array).size() != expected_ids.size():
		return _failure("fact_character_count_mismatch", "人物身份事实包人物数量与生产批次不一致。")
	var fact_characters_by_id := {}
	var observed_ids: Array[String] = []
	for character_value in characters_value:
		if not character_value is Dictionary:
			return _failure("fact_character_not_dictionary", "人物身份事实记录必须是对象。")
		var character: Dictionary = character_value
		if not _has_exact_keys(character, FACT_CHARACTER_KEYS):
			return _failure("invalid_fact_character_keys", "人物身份事实记录字段不完整或夹带未登记字段。")
		var character_id := str(character.get("id", ""))
		observed_ids.append(character_id)
		if fact_characters_by_id.has(character_id) or forbidden_ids.has(character_id):
			return _failure("fact_character_collision", "人物身份事实包人物重复或已在前置目录：%s。" % character_id)
		if not queue_candidates_by_id.has(character_id):
			return _failure("fact_character_not_in_queue", "人物身份事实包人物不在研究队列：%s。" % character_id)
		var queue_candidate: Dictionary = queue_candidates_by_id[character_id]
		for key in ["name", "batch_id", "prototype_group_candidate"]:
			if character.get(key) != queue_candidate.get(key):
				return _failure("fact_character_queue_mismatch", "人物身份事实与研究队列不一致：%s／%s。" % [character_id, key])
		if character.get("source_refs", []) != queue_candidate.get("planned_source_refs", []):
			return _failure("fact_character_source_mismatch", "人物身份事实来源与研究队列不一致：%s。" % character_id)
		for source_id_value in character.get("source_refs", []):
			if not sources_by_id.has(str(source_id_value)):
				return _failure("fact_character_unknown_source", "人物身份事实引用未登记来源：%s。" % source_id_value)
		if not (character.get("affiliations", null) is Array) or not (character.get("affiliations", []) as Array).is_empty():
			return _failure("fact_character_inferred_affiliation", "人物身份事实包不得从生产分组推导归属：%s。" % character_id)
		if str(character.get("source_status", "")) != "identity_ready_for_editorial" or str(character.get("locator_status", "")) != "completed":
			return _failure("fact_character_identity_not_ready", "人物身份事实包人物尚未完成身份核验：%s。" % character_id)
		var aliases: Array = character.get("aliases", [])
		var expected_alias_status := "completed_explicit_empty" if aliases.is_empty() else "completed_text_explicit"
		if str(character.get("aliases_status", "")) != expected_alias_status:
			return _failure("fact_character_alias_status", "人物身份事实别名状态不一致：%s。" % character_id)
		for status_key in ["editorial_status", "portrait_status"]:
			if str(character.get(status_key, "")) != "required_not_completed":
				return _failure("fact_character_premature_stage", "人物身份事实包不得提前完成编辑或头像：%s。" % character_id)
		if str(character.get("human_review_status", "")) != "required_not_started":
			return _failure("fact_character_human_review_started", "人物身份事实包真人审核尚未开始：%s。" % character_id)
		if str(character.get("promotion_status", "")) != "blocked_pending_editorial_visual_review_and_catalog_migration":
			return _failure("fact_character_promotion_unblocked", "人物身份事实包人物必须保持完整提升阻断：%s。" % character_id)
		fact_characters_by_id[character_id] = character
	if observed_ids != expected_ids:
		return _failure("fact_character_order_mismatch", "人物身份事实包顺序必须与生产批次一致。")

	var claims_by_id := {}
	var identity_counts := {}
	var alias_values_by_character := {}
	var alias_ids_by_character := {}
	for claim_value in claims_value:
		if not claim_value is Dictionary:
			return _failure("fact_claim_not_dictionary", "人物身份事实 claim 必须是对象。")
		var claim: Dictionary = claim_value
		if not _has_exact_keys(claim, CLAIM_KEYS):
			return _failure("invalid_fact_claim_keys", "人物身份事实 claim 字段不完整或夹带未登记字段。")
		var claim_id := str(claim.get("id", "")).strip_edges()
		var character_id := str(claim.get("character_id", "")).strip_edges()
		var field := str(claim.get("field", ""))
		if not _is_safe_id(claim_id) or claims_by_id.has(claim_id) or not fact_characters_by_id.has(character_id):
			return _failure("invalid_fact_claim_identity", "人物身份事实 claim ID 或人物无效：%s。" % claim_id)
		if field not in ["identity", "alias"] or str(claim.get("value", "")).strip_edges().is_empty():
			return _failure("invalid_fact_claim_field", "人物身份事实只接受非空 identity／alias。")
		if str(claim.get("layer", "")) != "historical" or str(claim.get("confidence", "")) != "text_explicit":
			return _failure("invalid_fact_claim_boundary", "人物姓名与字必须保持正史层原文明载。")
		if str(claim.get("source_locator", "")).strip_edges().length() < 12:
			return _failure("missing_fact_claim_locator", "人物身份事实 claim 缺少人物级短定位：%s。" % claim_id)
		var claim_sources_result := _unique_strings(claim.get("source_refs", []))
		if not bool(claim_sources_result.get("ok", false)):
			return _failure("invalid_fact_claim_sources", "人物身份事实 claim 来源为空或重复：%s。" % claim_id)
		var character_sources: Array = (fact_characters_by_id[character_id] as Dictionary).get("source_refs", [])
		for source_id in claim_sources_result.get("values", []):
			if str(source_id) not in character_sources or not sources_by_id.has(str(source_id)):
				return _failure("fact_claim_source_mismatch", "人物身份事实 claim 使用了人物计划外来源：%s。" % claim_id)
		if field == "identity":
			if str(claim.get("value", "")) != str((fact_characters_by_id[character_id] as Dictionary).get("name", "")):
				return _failure("fact_identity_name_mismatch", "人物 identity 与显示名不一致：%s。" % character_id)
			identity_counts[character_id] = int(identity_counts.get(character_id, 0)) + 1
		else:
			var values: Array = alias_values_by_character.get(character_id, [])
			values.append(str(claim.get("value", "")))
			alias_values_by_character[character_id] = values
			var ids: Array = alias_ids_by_character.get(character_id, [])
			ids.append(claim_id)
			alias_ids_by_character[character_id] = ids
		claims_by_id[claim_id] = claim
	for character_id in expected_ids:
		var character: Dictionary = fact_characters_by_id[character_id]
		if int(identity_counts.get(character_id, 0)) != 1:
			return _failure("fact_identity_count_mismatch", "人物必须恰有一个 identity：%s。" % character_id)
		var identity_claim_id := str(character.get("identity_claim_id", ""))
		if not claims_by_id.has(identity_claim_id) or str((claims_by_id[identity_claim_id] as Dictionary).get("field", "")) != "identity":
			return _failure("fact_identity_claim_missing", "人物声明的 identity claim 不存在：%s。" % character_id)
		if character.get("aliases", []) != alias_values_by_character.get(character_id, []):
			return _failure("fact_alias_values_mismatch", "人物别名缓存与 alias claims 不一致：%s。" % character_id)
		if character.get("alias_claim_ids", []) != alias_ids_by_character.get(character_id, []):
			return _failure("fact_alias_ids_mismatch", "人物 alias claim ID 与实际 claims 不一致：%s。" % character_id)

	var decision_ids: Array[String] = []
	for decision_value in package.get("source_boundary_decisions", []):
		if not decision_value is Dictionary or not _has_exact_keys(decision_value, ["character_id", "decision"]):
			return _failure("invalid_source_boundary_decision", "人物来源边界记录无效。")
		var decision: Dictionary = decision_value
		var character_id := str(decision.get("character_id", ""))
		if character_id not in expected_ids or character_id in decision_ids or str(decision.get("decision", "")).strip_edges().is_empty():
			return _failure("invalid_source_boundary_character", "人物来源边界缺失、重复或越界：%s。" % character_id)
		decision_ids.append(character_id)
	if decision_ids != expected_ids:
		return _failure("source_boundary_order_mismatch", "人物来源边界必须逐人覆盖并保持批次顺序。")

	var gate_statuses := {}
	for gate_value in package.get("release_gates", []):
		if not gate_value is Dictionary or not _has_exact_keys(gate_value, ["id", "status", "requirement"]):
			return _failure("invalid_fact_gate", "人物身份事实发布门禁无效。")
		var gate: Dictionary = gate_value
		var gate_id := str(gate.get("id", ""))
		if gate_statuses.has(gate_id) or str(gate.get("requirement", "")).strip_edges().is_empty():
			return _failure("invalid_fact_gate_identity", "人物身份事实发布门禁重复或缺少要求：%s。" % gate_id)
		gate_statuses[gate_id] = str(gate.get("status", ""))
	if gate_statuses != REQUIRED_FACT_GATES:
		return _failure("invalid_fact_gate_statuses", "人物身份事实包只能完成来源定位与姓名／字核验。")
	return {
		"ok": true,
		"batch_id": batch_id,
		"character_count": fact_characters_by_id.size(),
		"claim_count": claims_by_id.size(),
		"identity_count": fact_characters_by_id.size(),
		"alias_count": claims_by_id.size() - fact_characters_by_id.size(),
		"reused_source_count": reused_source_ids.size(),
		"new_source_count": added_source_ids.size(),
	}


static func _validate_source(source_value: Variant) -> Dictionary:
	if not source_value is Dictionary:
		return _failure("fact_source_not_dictionary", "新增固定来源必须是对象。")
	var source: Dictionary = source_value
	if not _has_exact_keys(source, SOURCE_KEYS):
		return _failure("invalid_fact_source_keys", "新增固定来源字段不完整或夹带未登记字段。")
	var source_id := str(source.get("id", "")).strip_edges()
	if not _is_safe_id(source_id):
		return _failure("invalid_fact_source_id", "新增固定来源 ID 无效。")
	for field in [
		"work_title", "citation_title", "kind", "author", "annotator", "url",
		"permalink", "license", "license_url", "usage_status", "notes",
	]:
		if str(source.get(field, "")).strip_edges().is_empty():
			return _failure("missing_fact_source_text", "新增固定来源缺少字段：%s。" % field)
	if str(source.get("layer", "")) != "historical" or str(source.get("kind", "")) != "digitized_primary_text":
		return _failure("invalid_fact_source_kind", "新增人物来源必须是历史层数字化原始文本。")
	if str(source.get("permalink", "")).find("oldid=") == -1:
		return _failure("fact_source_not_fixed", "新增人物来源必须使用 oldid 固定版本。")
	if str(source.get("usage_status", "")) != "reference_only":
		return _failure("invalid_fact_source_usage", "新增人物来源只作引用。")
	var license := str(source.get("license", ""))
	if not license.contains("public_domain_work") or not license.contains("cc_by_sa_4_0"):
		return _failure("invalid_fact_source_license", "新增人物来源必须分别登记古籍原作与页面许可。")
	var roles: Array = source.get("roles", [])
	if not roles.has("character_identity") or not roles.has("character_alias"):
		return _failure("invalid_fact_source_roles", "新增人物来源缺少姓名／字核验用途。")
	return {"ok": true, "source": source.duplicate(true)}


static func _unique_strings(values: Variant, allow_empty: bool = false) -> Dictionary:
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
	if result.is_empty() and not allow_empty:
		return {"ok": false, "values": []}
	return {"ok": true, "values": result}


static func _has_exact_keys(record: Dictionary, expected: Array) -> bool:
	if record.size() != expected.size():
		return false
	for key in record.keys():
		if str(key) not in expected:
			return false
	return true


static func _is_safe_id(value: String) -> bool:
	if value.is_empty() or value.length() > 120:
		return false
	var pattern := RegEx.new()
	return pattern.compile("^[a-z0-9][a-z0-9_]*$") == OK and pattern.search(value) != null


static func _is_date(value: String) -> bool:
	var pattern := RegEx.new()
	return pattern.compile("^\\d{4}-\\d{2}-\\d{2}$") == OK and pattern.search(value) != null


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
