class_name CharacterNextContentPolicy
extends RefCounted


const ResearchPolicy = preload("res://src/character_next_research_policy.gd")
const TextPolicy = preload("res://src/character_next_text_policy.gd")

const EXPECTED_BATCH_05_IDS := [
	"cao_ren", "xu_chu", "guo_jia", "yan_liang", "wen_chou",
	"tian_feng", "ju_shou", "zhang_he", "yu_jin", "ma_chao",
]
const COSTUME_ROOT_KEYS := [
	"schema_version", "gate_id", "created_at", "scope", "runtime_policy",
	"source_use_policy", "sources", "global_rules", "records",
]
const COSTUME_SOURCE_KEYS := [
	"source_id", "institution", "title", "url", "accessed_at", "claims_used",
	"asset_license",
]
const COSTUME_RECORD_KEYS := [
	"character_id", "name", "fact_anchor", "inferred_visuals",
	"art_abstraction", "recognition_anchor_32px",
]
const BATCH_SPEC_ROOT_KEYS := [
	"schema_version", "batch_id", "display_title", "status", "runtime_policy",
	"target_character_catalog_version", "target_catalog_size",
	"existing_research_portrait_count", "planned_source_count",
	"generated_source_count", "planned_candidate_portrait_count", "records",
	"guardrails",
]
const VISUAL_ROOT_KEYS := [
	"schema_version", "batch_id", "status", "created_at", "purpose",
	"runtime_policy", "identity_fact_package", "editorial_draft", "costume_gate",
	"style_reference", "framing_spec", "records",
]
const VISUAL_RECORD_KEYS := [
	"character_id", "name", "prompt_path", "source_path", "fact_anchor",
	"inferred_visuals", "art_abstraction", "visual_intent",
	"period_costume_direction", "composition_profile", "recognition_anchor_32px",
	"differentiation_targets", "forbidden_visual_signals", "prompt_status",
	"source_status", "historicity_status",
]
const REQUIRED_BATCH_GUARDRAILS := [
	"formal_runtime_catalog_remains_v2_40",
	"formal_runtime_portrait_registry_remains_40_of_40",
	"existing_catalog_v3_review_roster_remains_20",
	"all_new_material_remains_under_research_reference_or_artifact_paths",
	"promotion_allowed_is_false",
	"source_generation_has_not_started",
	"no_source_manifest_staging_or_promotion_result_is_created",
	"catalog_v4_and_future_save_migration_are_not_implemented_in_this_stage",
	"no_commercial_game_film_television_or_unlicensed_character_art_is_used",
]


static func validate_pipeline(
	queue: Dictionary,
	batch_05_facts: Dictionary,
	batch_05_editorial: Dictionary,
	batch_06_facts: Dictionary,
	batch_06_editorial: Dictionary,
	costume_gate: Dictionary,
	batch_spec: Dictionary,
	visual_briefs: Dictionary,
	formal_catalog: Dictionary,
	review_roster: Dictionary,
	scenarios: Dictionary,
	formal_sources: Dictionary,
	formal_attributes: Dictionary,
	formal_portraits: Dictionary,
	require_visual_files_absent: bool = true
) -> Dictionary:
	var queue_result: Dictionary = ResearchPolicy.validate_queue(
		queue, formal_catalog, review_roster, scenarios
	)
	if not bool(queue_result.get("ok", false)):
		return queue_result
	if (
		int(queue_result.get("completed_identity_count", 0)) != 20
		or int(queue_result.get("completed_editorial_count", 0)) != 20
		or int(queue_result.get("pending_source_count", -1)) != 0
	):
		return _failure(
			"content_progress_mismatch",
			"M2-D50 必须保持身份 20／20、编辑 20／20、待选固定来源 0。"
		)

	var fact_05_result: Dictionary = ResearchPolicy.validate_identity_package(
		batch_05_facts, queue, formal_catalog, review_roster, formal_sources
	)
	if not bool(fact_05_result.get("ok", false)):
		return fact_05_result
	var fact_06_result: Dictionary = ResearchPolicy.validate_identity_package(
		batch_06_facts, queue, formal_catalog, review_roster, formal_sources
	)
	if not bool(fact_06_result.get("ok", false)):
		return fact_06_result

	var editorial_05_result: Dictionary = TextPolicy.validate_editorial_package(
		batch_05_editorial,
		batch_05_facts,
		queue,
		formal_sources,
		formal_attributes
	)
	if not bool(editorial_05_result.get("ok", false)):
		return editorial_05_result
	var editorial_06_result: Dictionary = TextPolicy.validate_editorial_package(
		batch_06_editorial,
		batch_06_facts,
		queue,
		formal_sources,
		formal_attributes,
		"m2_d50_batch_06_editorial_draft",
		"references/candidates/character_promotion_batch_06_facts.json"
	)
	if not bool(editorial_06_result.get("ok", false)):
		return editorial_06_result

	var costume_result: Dictionary = validate_costume_gate(costume_gate, batch_05_facts)
	if not bool(costume_result.get("ok", false)):
		return costume_result
	var spec_result: Dictionary = validate_batch_spec(batch_spec, batch_05_facts)
	if not bool(spec_result.get("ok", false)):
		return spec_result
	var brief_result: Dictionary = validate_visual_briefs(
		visual_briefs, costume_gate, batch_05_facts, require_visual_files_absent
	)
	if not bool(brief_result.get("ok", false)):
		return brief_result

	var formal_portrait_ids: Array[String] = []
	for value in formal_portraits.get("records", []):
		if not value is Dictionary:
			return _failure("invalid_formal_portrait_record", "正式头像登记包含无效记录。")
		formal_portrait_ids.append(str((value as Dictionary).get("character_id", "")))
	if formal_portrait_ids.size() != 40:
		return _failure("invalid_formal_portrait_count", "正式头像登记必须保持 40／40。")
	for character_id in EXPECTED_BATCH_05_IDS:
		if character_id in formal_portrait_ids:
			return _failure(
				"research_portrait_entered_formal_registry",
				"研究人物不得进入正式头像登记：%s。" % character_id
			)

	return {
		"ok": true,
		"formal_count": int(queue_result.get("formal_count", 0)),
		"review_count": int(queue_result.get("review_count", 0)),
		"research_count": int(queue_result.get("candidate_count", 0)),
		"identity_count": int(fact_05_result.get("identity_count", 0))
			+ int(fact_06_result.get("identity_count", 0)),
		"identity_claim_count": int(fact_05_result.get("claim_count", 0))
			+ int(fact_06_result.get("claim_count", 0)),
		"editorial_count": int(editorial_05_result.get("character_count", 0))
			+ int(editorial_06_result.get("character_count", 0)),
		"profile_count": int(editorial_05_result.get("profile_count", 0))
			+ int(editorial_06_result.get("profile_count", 0)),
		"attribute_count": int(editorial_05_result.get("attribute_count", 0))
			+ int(editorial_06_result.get("attribute_count", 0)),
		"visual_brief_count": int(brief_result.get("character_count", 0)),
		"generated_portrait_count": 0,
		"formal_portrait_count": formal_portrait_ids.size(),
	}


static func validate_costume_gate(gate: Dictionary, facts: Dictionary) -> Dictionary:
	if not _has_exact_keys(gate, COSTUME_ROOT_KEYS):
		return _failure("invalid_costume_gate_root_keys", "冠服门禁根字段不完整或夹带未登记字段。")
	if int(gate.get("schema_version", 0)) != 1:
		return _failure("unsupported_costume_gate_schema", "冠服门禁只接受 schema v1。")
	if str(gate.get("gate_id", "")) != "late_eastern_han_batch05_male_costume_v1":
		return _failure("invalid_costume_gate_id", "冠服门禁编号不一致。")
	if str(gate.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized_no_promotion_command":
		return _failure("invalid_costume_runtime_policy", "冠服门禁不得进入运行、搜索、存档或提升命令。")
	if str(gate.get("scope", "")).strip_edges().is_empty() or str(gate.get("source_use_policy", "")).strip_edges().is_empty():
		return _failure("missing_costume_boundary", "冠服门禁缺少用途或来源边界。")

	var sources: Variant = gate.get("sources", null)
	if not sources is Array or (sources as Array).size() != 5:
		return _failure("invalid_costume_source_count", "冠服门禁必须登记五个既有参考来源。")
	var source_ids: Array[String] = []
	for value in sources:
		if not value is Dictionary or not _has_exact_keys(value as Dictionary, COSTUME_SOURCE_KEYS):
			return _failure("invalid_costume_source", "冠服门禁来源记录无效。")
		var source: Dictionary = value
		var source_id := str(source.get("source_id", ""))
		if source_id.is_empty() or source_id in source_ids:
			return _failure("duplicate_costume_source", "冠服门禁来源为空或重复。")
		source_ids.append(source_id)
		if not str(source.get("asset_license", "")).contains("not_used") and not str(source.get("asset_license", "")).contains("text_reference_only"):
			return _failure("costume_asset_use_unbounded", "冠服参考来源必须明确不作为素材或生成输入。")

	var rules: Variant = gate.get("global_rules", null)
	if not rules is Dictionary or not _has_exact_keys(rules as Dictionary, ["required", "forbidden"]):
		return _failure("invalid_costume_rules", "冠服门禁全局规则无效。")
	var required_result: Dictionary = _unique_strings((rules as Dictionary).get("required", []))
	var forbidden_result: Dictionary = _unique_strings((rules as Dictionary).get("forbidden", []))
	if not bool(required_result.get("ok", false)) or (required_result.get("values", []) as Array).size() < 5:
		return _failure("insufficient_costume_requirements", "冠服门禁缺少必要构图与服饰要求。")
	if not bool(forbidden_result.get("ok", false)) or (forbidden_result.get("values", []) as Array).size() < 7:
		return _failure("insufficient_costume_rejections", "冠服门禁缺少跨时代与商业造型拒收项。")
	var forbidden_text := "｜".join(forbidden_result.get("values", []))
	for keyword in ["帽翅", "明清补服", "笼冠", "明光铠", "毛领", "日式", "商业"]:
		if not forbidden_text.contains(keyword):
			return _failure("missing_costume_rejection_keyword", "冠服门禁缺少拒收关键词：%s。" % keyword)

	var expected_ids: Array[String] = _fact_ids(facts)
	if expected_ids != EXPECTED_BATCH_05_IDS:
		return _failure("unexpected_costume_fact_roster", "冠服门禁事实包人物顺序不一致。")
	var record_result: Dictionary = _validate_named_records(
		gate.get("records", []), expected_ids, COSTUME_RECORD_KEYS, "costume", facts
	)
	if not bool(record_result.get("ok", false)):
		return record_result
	for record_value in gate.get("records", []):
		var record: Dictionary = record_value
		for key in ["fact_anchor", "inferred_visuals", "art_abstraction", "recognition_anchor_32px"]:
			if str(record.get(key, "")).strip_edges().is_empty():
				return _failure("missing_costume_record_text", "冠服门禁人物字段为空：%s／%s。" % [record.get("character_id", ""), key])
	return {"ok": true, "character_count": expected_ids.size(), "source_count": source_ids.size()}


static func validate_batch_spec(spec: Dictionary, facts: Dictionary) -> Dictionary:
	if not _has_exact_keys(spec, BATCH_SPEC_ROOT_KEYS):
		return _failure("invalid_portrait_batch_spec_keys", "头像批次规格根字段不完整或夹带未登记字段。")
	if (
		int(spec.get("schema_version", 0)) != 1
		or str(spec.get("batch_id", "")) != "batch_v4_01_research"
		or str(spec.get("status", "")) != "visual_briefs_ready_sources_not_generated"
		or str(spec.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized_no_promotion_command"
	):
		return _failure("invalid_portrait_batch_spec_identity", "头像批次规格身份或研究状态不一致。")
	if (
		int(spec.get("target_character_catalog_version", 0)) != 4
		or int(spec.get("target_catalog_size", 0)) != 80
		or int(spec.get("existing_research_portrait_count", 0)) != 60
		or int(spec.get("planned_source_count", 0)) != 10
		or int(spec.get("generated_source_count", -1)) != 0
		or int(spec.get("planned_candidate_portrait_count", 0)) != 10
	):
		return _failure("invalid_portrait_batch_counts", "头像批次规格必须保持 v4／80、既有 60、计划 10、已生成 0。")
	var record_result: Dictionary = _validate_named_records(
		spec.get("records", []),
		_fact_ids(facts),
		["character_id", "name"],
		"portrait_batch",
		facts
	)
	if not bool(record_result.get("ok", false)):
		return record_result
	if spec.get("guardrails", []) != REQUIRED_BATCH_GUARDRAILS:
		return _failure("invalid_portrait_batch_guardrails", "头像批次规格的研究隔离门禁不完整或顺序改变。")
	return {"ok": true, "character_count": EXPECTED_BATCH_05_IDS.size()}


static func validate_visual_briefs(
	briefs: Dictionary,
	costume_gate: Dictionary,
	facts: Dictionary,
	require_files_absent: bool = true
) -> Dictionary:
	if not _has_exact_keys(briefs, VISUAL_ROOT_KEYS):
		return _failure("invalid_visual_brief_root_keys", "视觉 brief 根字段不完整或夹带未登记字段。")
	if (
		int(briefs.get("schema_version", 0)) != 1
		or str(briefs.get("batch_id", "")) != "batch_v4_01_research"
		or str(briefs.get("status", "")) != "visual_briefs_ready_sources_not_generated"
		or str(briefs.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized_no_promotion_command"
	):
		return _failure("invalid_visual_brief_identity", "视觉 brief 身份或研究状态不一致。")
	if (
		str(briefs.get("identity_fact_package", ""))
			!= "res://references/candidates/character_promotion_batch_05_facts.json"
		or str(briefs.get("editorial_draft", ""))
			!= "res://references/candidates/character_promotion_batch_05_editorial_draft.json"
		or str(briefs.get("costume_gate", ""))
			!= "res://references/candidates/character_portrait_han_costume_gate_batch05_v1.json"
		or str(briefs.get("framing_spec", ""))
			!= "res://artifacts/character_portraits/v2/framing_spec.json"
	):
		return _failure("invalid_visual_brief_references", "视觉 brief 引用了错误的事实、编辑、冠服或裁切资料。")
	for path in [
		str(briefs.get("identity_fact_package", "")),
		str(briefs.get("editorial_draft", "")),
		str(briefs.get("costume_gate", "")),
		str(briefs.get("framing_spec", "")),
	]:
		if not FileAccess.file_exists(path):
			return _failure("missing_visual_brief_reference", "视觉 brief 依赖文件不存在：%s。" % path)
	var style_reference: Variant = briefs.get("style_reference", null)
	if not style_reference is Dictionary or not _has_exact_keys(
		style_reference as Dictionary, ["path", "use", "permitted_features", "forbidden_copying"]
	):
		return _failure("invalid_visual_style_reference", "视觉 brief 风格参考字段无效。")
	if not FileAccess.file_exists(str((style_reference as Dictionary).get("path", ""))):
		return _failure("missing_visual_style_reference", "项目自产风格参考不存在。")
	if not str((style_reference as Dictionary).get("use", "")).contains("style vocabulary"):
		return _failure("visual_style_reference_overreach", "风格参考只能提供项目自产视觉词汇。")

	var expected_ids: Array[String] = _fact_ids(facts)
	var record_result: Dictionary = _validate_named_records(
		briefs.get("records", []), expected_ids, VISUAL_RECORD_KEYS, "visual_brief", facts
	)
	if not bool(record_result.get("ok", false)):
		return record_result
	var gate_records := {}
	for value in costume_gate.get("records", []):
		if value is Dictionary:
			gate_records[str((value as Dictionary).get("character_id", ""))] = value
	var anchors: Array[String] = []
	for value in briefs.get("records", []):
		var record: Dictionary = value
		var character_id := str(record.get("character_id", ""))
		var gate_record: Dictionary = gate_records.get(character_id, {})
		for key in ["fact_anchor", "inferred_visuals", "recognition_anchor_32px"]:
			if str(record.get(key, "")) != str(gate_record.get(key, "")):
				return _failure("visual_gate_mismatch", "视觉 brief 与冠服门禁不一致：%s／%s。" % [character_id, key])
		for key in ["art_abstraction", "visual_intent", "period_costume_direction"]:
			if str(record.get(key, "")).strip_edges().is_empty():
				return _failure("missing_visual_brief_text", "视觉 brief 人物字段为空：%s／%s。" % [character_id, key])
		var composition: Variant = record.get("composition_profile", null)
		if not composition is Dictionary or not _has_exact_keys(composition as Dictionary, ["view", "shoulder_width", "palette"]):
			return _failure("invalid_visual_composition", "视觉 brief 构图资料无效：%s。" % character_id)
		var palette_result: Dictionary = _unique_strings((composition as Dictionary).get("palette", []))
		if not bool(palette_result.get("ok", false)) or (palette_result.get("values", []) as Array).size() != 4:
			return _failure("invalid_visual_palette", "视觉 brief 每人必须有四个唯一色彩锚点：%s。" % character_id)
		var anchor := str(record.get("recognition_anchor_32px", ""))
		if anchor.is_empty() or anchor in anchors:
			return _failure("duplicate_visual_anchor", "32px 识别锚点为空或重复：%s。" % character_id)
		anchors.append(anchor)
		var targets_result: Dictionary = _unique_strings(record.get("differentiation_targets", []))
		if not bool(targets_result.get("ok", false)) or (targets_result.get("values", []) as Array).size() < 3:
			return _failure("insufficient_visual_differentiation", "视觉 brief 缺少差异化对象：%s。" % character_id)
		if character_id in targets_result.get("values", []):
			return _failure("visual_self_differentiation", "人物不能把自己列为差异化对象：%s。" % character_id)
		var forbidden_result: Dictionary = _unique_strings(record.get("forbidden_visual_signals", []))
		if not bool(forbidden_result.get("ok", false)) or (forbidden_result.get("values", []) as Array).size() < 5:
			return _failure("insufficient_visual_rejections", "视觉 brief 至少需要五项逐人拒收信号：%s。" % character_id)
		if str(record.get("prompt_status", "")) != "planned_not_written" or str(record.get("source_status", "")) != "not_generated":
			return _failure("premature_visual_generation_status", "M2-D50 只能完成 brief，不得虚报提示词或源图：%s。" % character_id)
		if str(record.get("historicity_status", "")) != "original_interpretation_not_historical_likeness":
			return _failure("invalid_visual_historicity_status", "头像设计必须声明为原创解释而非历史肖像：%s。" % character_id)
		for path_key in ["prompt_path", "source_path"]:
			var planned_path := str(record.get(path_key, ""))
			if not planned_path.begins_with("res://artifacts/character_portraits/source_batches/batch_v4_01_research/"):
				return _failure("visual_path_outside_batch", "视觉生产路径越出研究批次：%s／%s。" % [character_id, path_key])
			if require_files_absent and FileAccess.file_exists(planned_path):
				return _failure("premature_visual_file", "M2-D50 不得提前存在提示词或源图：%s。" % planned_path)
	return {"ok": true, "character_count": expected_ids.size(), "recognition_anchor_count": anchors.size()}


static func _validate_named_records(
	values: Variant,
	expected_ids: Array[String],
	expected_keys: Array,
	label: String,
	facts: Dictionary
) -> Dictionary:
	if not values is Array:
		return _failure("invalid_%s_records" % label, "%s 记录必须是数组。" % label)
	var fact_names := {}
	for value in facts.get("characters", []):
		if value is Dictionary:
			fact_names[str((value as Dictionary).get("id", ""))] = str((value as Dictionary).get("name", ""))
	var ids: Array[String] = []
	for value in values:
		if not value is Dictionary or not _has_exact_keys(value as Dictionary, expected_keys):
			return _failure("invalid_%s_record_keys" % label, "%s 记录字段无效。" % label)
		var record: Dictionary = value
		var character_id := str(record.get("character_id", ""))
		ids.append(character_id)
		if str(record.get("name", "")) != str(fact_names.get(character_id, "")):
			return _failure("%s_name_mismatch" % label, "%s 人物姓名与事实包不一致：%s。" % [label, character_id])
	if ids != expected_ids:
		return _failure("%s_order_mismatch" % label, "%s 人物顺序必须与事实包一致。" % label)
	return {"ok": true, "character_count": ids.size()}


static func _fact_ids(facts: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for value in facts.get("characters", []):
		if value is Dictionary:
			result.append(str((value as Dictionary).get("id", "")))
	return result


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
