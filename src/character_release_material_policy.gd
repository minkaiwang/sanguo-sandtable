class_name CharacterReleaseMaterialPolicy
extends RefCounted

## M4-A2.2.1：对 20 位候选的真实发布材料做纯函数预检。
##
## 只回答“材料是否闭合”，不包含真人视觉批准，不写正式资料或玩家存档。

const PromotionPolicy = preload("res://src/character_promotion_policy.gd")

const STATUS_READY := "material_inputs_ready_for_human_gate"
const STATUS_INVALID := "invalid_material_inputs"
const TARGET_COUNT := 60
const FORMAL_COUNT := 40
const CANDIDATE_COUNT := 20


static func evaluate(
	runtime_characters_value: Variant,
	source_payload_value: Variant,
	target_characters_value: Variant,
	catalog_draft_value: Variant,
	roster_value: Variant,
	fact_documents: Array,
	editorial_documents: Array,
	portrait_manifest_value: Variant,
	asset_lock_value: Variant
) -> Dictionary:
	var blockers: Array[Dictionary] = []
	if not (runtime_characters_value is Array):
		blockers.append(_blocker("runtime_characters_invalid", "正式 40 人人物文件不是数组。"))
	if not (source_payload_value is Dictionary):
		blockers.append(_blocker("source_registry_invalid", "正式人物来源注册表不是对象。"))
	if not (target_characters_value is Array):
		blockers.append(_blocker("target_characters_invalid", "目标 60 人人物文件不是数组。"))
	if not (catalog_draft_value is Dictionary):
		blockers.append(_blocker("catalog_draft_invalid", "目录 v3 草案不是对象。"))
	if not (roster_value is Dictionary):
		blockers.append(_blocker("candidate_roster_invalid", "20 人候选 roster 不是对象。"))
	if not (portrait_manifest_value is Dictionary):
		blockers.append(_blocker("portrait_manifest_invalid", "候选头像 manifest 不是对象。"))
	if not (asset_lock_value is Dictionary):
		blockers.append(_blocker("asset_lock_invalid", "审核头像输入锁不是对象。"))
	if not blockers.is_empty():
		return _report(false, [], blockers)

	var runtime_characters: Array = runtime_characters_value
	var source_payload: Dictionary = source_payload_value
	var target_characters: Array = target_characters_value
	var catalog_draft: Dictionary = catalog_draft_value
	var roster: Dictionary = roster_value
	var portrait_manifest: Dictionary = portrait_manifest_value
	var asset_lock: Dictionary = asset_lock_value

	var runtime_index := _index_unique(runtime_characters, "id")
	var target_index := _index_unique(target_characters, "id")
	if runtime_characters.size() != FORMAL_COUNT or int(runtime_index.get("count", 0)) != FORMAL_COUNT:
		blockers.append(_blocker("formal_catalog_invalid", "正式人物基线必须恰好是 40 个唯一 ID。"))
	if target_characters.size() != TARGET_COUNT or int(target_index.get("count", 0)) != TARGET_COUNT:
		blockers.append(_blocker("target_catalog_invalid", "目标人物草案必须恰好是 60 个唯一 ID。"))
	var runtime_ids: Array = runtime_index.get("ids", [])
	var target_ids: Array = target_index.get("ids", [])
	if runtime_ids.size() == FORMAL_COUNT and target_ids.size() == TARGET_COUNT:
		for index in range(FORMAL_COUNT):
			if str(runtime_ids[index]) != str(target_ids[index]):
				blockers.append(_blocker("formal_prefix_changed", "目标目录改变了正式 40 人的 ID 或顺序。"))
				break

	var candidate_ids: Array = target_ids.slice(FORMAL_COUNT, TARGET_COUNT) if target_ids.size() == TARGET_COUNT else []
	if (
		int(catalog_draft.get("schema_version", 0)) != 1
		or str(catalog_draft.get("status", "")) != "research_catalog_draft_not_runtime"
		or str(catalog_draft.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized"
		or int(catalog_draft.get("character_catalog_version", 0)) != 3
		or int(catalog_draft.get("baseline_runtime_character_count", 0)) != FORMAL_COUNT
		or int(catalog_draft.get("target_runtime_character_count", 0)) != TARGET_COUNT
		or catalog_draft.get("character_ids", []) != target_ids
	):
		blockers.append(_blocker("catalog_draft_mismatch", "目录 v3 草案与目标 60 人或研究隔离边界不一致。"))

	var roster_values: Variant = roster.get("candidates", [])
	var roster_index := _index_unique(roster_values, "id")
	if (
		int(roster.get("schema_version", 0)) != 1
		or str(roster.get("status", "")) != "research_candidates_not_runtime"
		or str(roster.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized"
		or int(roster.get("candidate_count", 0)) != CANDIDATE_COUNT
		or int(roster.get("target_character_catalog_version", 0)) != 3
		or roster_index.get("ids", []) != candidate_ids
	):
		blockers.append(_blocker("candidate_roster_mismatch", "20 人 roster 与目录 v3 后缀顺序或隔离边界不一致。"))

	var facts_result := _merge_fact_documents(fact_documents)
	if not bool(facts_result.get("ok", false)):
		blockers.append(_blocker("fact_batches_invalid", str(facts_result.get("message", "人物事实批次无效。"))))
	var editorial_result := _merge_editorial_documents(editorial_documents)
	if not bool(editorial_result.get("ok", false)):
		blockers.append(_blocker("editorial_batches_invalid", str(editorial_result.get("message", "人物展示资料批次无效。"))))

	var portrait_index := _index_unique(portrait_manifest.get("approved_records", []), "character_id")
	if (
		int(portrait_manifest.get("schema_version", 0)) != 1
		or int(portrait_manifest.get("character_catalog_version", 0)) != 3
		or str(portrait_manifest.get("status", "")) != "generated_pending_visual_review"
		or int(portrait_index.get("count", 0)) != TARGET_COUNT
	):
		blockers.append(_blocker("portrait_manifest_mismatch", "候选头像 manifest 必须保持目录 v3／60 人和待真人视觉审核状态。"))
	var asset_index := _index_unique(asset_lock.get("portrait_assets", []), "character_id")
	if (
		not bool(asset_lock.get("all_inputs_valid", false))
		or asset_lock.get("candidate_ids_in_target_catalog_order", []) != candidate_ids
		or int(asset_index.get("count", 0)) != CANDIDATE_COUNT
	):
		blockers.append(_blocker("portrait_asset_lock_mismatch", "头像输入锁没有完整覆盖目录新增 20 人。"))

	if not blockers.is_empty():
		return _report(false, [], blockers)

	var target_by_id: Dictionary = target_index.get("records", {})
	var roster_by_id: Dictionary = roster_index.get("records", {})
	var fact_characters_by_id: Dictionary = facts_result.get("characters_by_id", {})
	var claims_by_character: Dictionary = facts_result.get("claims_by_character", {})
	var attributes_by_id: Dictionary = editorial_result.get("attributes_by_id", {})
	var profiles_by_id: Dictionary = editorial_result.get("profiles_by_id", {})
	var groups_by_id: Dictionary = editorial_result.get("groups_by_id", {})
	var portraits_by_id: Dictionary = portrait_index.get("records", {})
	var assets_by_id: Dictionary = asset_index.get("records", {})
	var source_ids := {}
	for source_value in source_payload.get("sources", []):
		if source_value is Dictionary:
			var source_id := str((source_value as Dictionary).get("id", ""))
			if not source_id.is_empty():
				source_ids[source_id] = true

	var character_results: Array[Dictionary] = []
	var passed := 0
	for character_id_value in candidate_ids:
		var character_id := str(character_id_value)
		var character_blockers: Array[Dictionary] = []
		var target: Dictionary = target_by_id.get(character_id, {})
		var roster_record: Dictionary = roster_by_id.get(character_id, {})
		var fact_character: Dictionary = fact_characters_by_id.get(character_id, {})
		var attribute: Dictionary = attributes_by_id.get(character_id, {})
		var profile: Dictionary = profiles_by_id.get(character_id, {})
		var group_review: Dictionary = groups_by_id.get(character_id, {})
		var portrait: Dictionary = portraits_by_id.get(character_id, {})
		var asset: Dictionary = assets_by_id.get(character_id, {})
		var promotion_character := {}

		if (
			target.is_empty()
			or roster_record.is_empty()
			or fact_character.is_empty()
			or attribute.is_empty()
			or profile.is_empty()
			or group_review.is_empty()
			or portrait.is_empty()
			or asset.is_empty()
		):
			character_blockers.append(_blocker("candidate_material_missing", "人物的 roster、事实、展示资料或头像材料不完整。", [character_id]))
		else:
			if (
				not _has_exact_keys(target, ["id", "name", "group", "aliases", "affiliations", "source_refs"])
				or not (target.get("aliases", null) is Array)
				or not (target.get("affiliations", null) is Array)
				or not (target.get("source_refs", null) is Array)
				or str(target.get("id", "")) != character_id
				or str(target.get("name", "")) != str(roster_record.get("name", ""))
				or str(target.get("name", "")) != str(fact_character.get("name", ""))
				or str(target.get("group", "")) != str(roster_record.get("proposed_group", ""))
				or str(target.get("group", "")) != str(fact_character.get("proposed_group", ""))
				or str(target.get("group", "")) != str(group_review.get("proposed_group", ""))
			):
				character_blockers.append(_blocker("candidate_identity_mismatch", "目录占位记录、roster、事实批次或原型复核的人物身份不一致。", [character_id]))

			var claims: Array = claims_by_character.get(character_id, [])
			var identity_claims: Array = []
			for claim_value in claims:
				if claim_value is Dictionary and str((claim_value as Dictionary).get("field", "")) == "identity":
					identity_claims.append(claim_value)
			if (
				identity_claims.size() != 1
				or str((identity_claims[0] as Dictionary).get("id", "")) != str(fact_character.get("identity_claim_id", ""))
				or str((identity_claims[0] as Dictionary).get("value", "")) != str(target.get("name", ""))
			):
				character_blockers.append(_blocker("identity_claim_mismatch", "规范姓名事实与人物缓存不一致。", [character_id]))

			# 早期 60 人目录只负责锁定 ID／姓名／原型顺序。最终人物缓存必须由
			# 已验证事实批次组装，不能把旧占位记录的空来源当成发布数据。
			promotion_character = {
				"id": character_id,
				"name": str(fact_character.get("name", "")),
				"group": str(fact_character.get("proposed_group", "")),
				"aliases": (fact_character.get("aliases", []) as Array).duplicate(true),
				"affiliations": (fact_character.get("affiliations", []) as Array).duplicate(true),
				"source_refs": (fact_character.get("source_refs", []) as Array).duplicate(true),
			}
			var promotion_result := PromotionPolicy.validate_initial_promotion(
				promotion_character,
				attribute,
				{"schema_version": 2, "claims": claims},
				runtime_characters,
				source_payload
			)
			if not bool(promotion_result.get("ok", false)):
				character_blockers.append(_blocker(
					"atomic_promotion_package_invalid",
					str(promotion_result.get("message", "人物原子提升包无效。")),
					[character_id]
				))

			var profile_result := _validate_profile(profile, character_id, promotion_character, source_ids)
			if not bool(profile_result.get("ok", false)):
				character_blockers.append(_blocker("profile_invalid", str(profile_result.get("message", "人物小传无效。")), [character_id]))

			if (
				str(portrait.get("status", "")) != "approved_portrait"
				or str((portrait.get("qa", {}) as Dictionary).get("status", "")) != "pending_visual_review"
				or not bool(asset.get("valid", false))
				or not _portrait_paths_match(portrait, asset)
			):
				character_blockers.append(_blocker("portrait_material_invalid", "人物头像三档材料、哈希或待人审边界不一致。", [character_id]))

		var character_ok := character_blockers.is_empty()
		if character_ok:
			passed += 1
		else:
			blockers.append_array(character_blockers)
		character_results.append({
			"character_id": character_id,
			"name": str(target.get("name", roster_record.get("name", ""))),
			"material_ready": character_ok,
			"human_visual_approval": false,
			"promotion_character": promotion_character if not fact_character.is_empty() else {},
			"display_attributes": attribute.duplicate(true),
			"profile": profile.duplicate(true),
			"blocking_reasons": character_blockers,
		})

	return _report(passed == CANDIDATE_COUNT and blockers.is_empty(), character_results, blockers)


static func _merge_fact_documents(documents: Array) -> Dictionary:
	if documents.size() != 3:
		return {"ok": false, "message": "人物事实必须恰好来自三个研究批次。"}
	var characters_by_id := {}
	var claims_by_character := {}
	var claim_ids := {}
	for value in documents:
		if not (value is Dictionary):
			return {"ok": false, "message": "人物事实批次不是对象。"}
		var document: Dictionary = value
		if (
			int(document.get("schema_version", 0)) != 1
			or int(document.get("claim_schema_version", 0)) != 2
			or str(document.get("status", "")) != "validated_identity_facts_not_runtime"
			or str(document.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized"
			or int(document.get("target_character_catalog_version", 0)) != 3
		):
			return {"ok": false, "message": "人物事实批次版本或研究隔离边界无效。"}
		for character_value in document.get("characters", []):
			if not (character_value is Dictionary):
				return {"ok": false, "message": "人物事实批次包含非对象人物。"}
			var character: Dictionary = character_value
			var character_id := str(character.get("id", ""))
			if character_id.is_empty() or characters_by_id.has(character_id):
				return {"ok": false, "message": "人物事实批次包含空或重复人物 ID。"}
			characters_by_id[character_id] = character
		for claim_value in document.get("claims", []):
			if not (claim_value is Dictionary):
				return {"ok": false, "message": "人物事实批次包含非对象 claim。"}
			var claim: Dictionary = claim_value
			var claim_id := str(claim.get("id", ""))
			var character_id := str(claim.get("character_id", ""))
			if claim_id.is_empty() or claim_ids.has(claim_id) or character_id.is_empty():
				return {"ok": false, "message": "人物事实批次包含空或重复 claim。"}
			claim_ids[claim_id] = true
			if not claims_by_character.has(character_id):
				claims_by_character[character_id] = []
			(claims_by_character[character_id] as Array).append(claim)
	if characters_by_id.size() != CANDIDATE_COUNT:
		return {"ok": false, "message": "人物事实批次没有完整覆盖 20 位候选。"}
	return {
		"ok": true,
		"characters_by_id": characters_by_id,
		"claims_by_character": claims_by_character,
	}


static func _merge_editorial_documents(documents: Array) -> Dictionary:
	if documents.size() != 3:
		return {"ok": false, "message": "人物展示资料必须恰好来自三个研究批次。"}
	var attributes_by_id := {}
	var profiles_by_id := {}
	var groups_by_id := {}
	for value in documents:
		if not (value is Dictionary):
			return {"ok": false, "message": "人物展示资料批次不是对象。"}
		var document: Dictionary = value
		if (
			int(document.get("schema_version", 0)) != 1
			or str(document.get("status", "")) != "validated_editorial_draft_not_runtime"
			or str(document.get("runtime_policy", "")) != "not_loaded_not_searchable_not_serialized"
			or int(document.get("target_character_catalog_version", 0)) != 3
		):
			return {"ok": false, "message": "人物展示资料批次版本或研究隔离边界无效。"}
		for pair in [
			[document.get("display_attributes", []), attributes_by_id],
			[document.get("profiles", []), profiles_by_id],
			[document.get("group_reviews", []), groups_by_id],
		]:
			for record_value in pair[0]:
				if not (record_value is Dictionary):
					return {"ok": false, "message": "人物展示资料包含非对象记录。"}
				var record: Dictionary = record_value
				var character_id := str(record.get("character_id", ""))
				var target: Dictionary = pair[1]
				if character_id.is_empty() or target.has(character_id):
					return {"ok": false, "message": "人物展示资料包含空或重复人物 ID。"}
				target[character_id] = record
	if attributes_by_id.size() != CANDIDATE_COUNT or profiles_by_id.size() != CANDIDATE_COUNT or groups_by_id.size() != CANDIDATE_COUNT:
		return {"ok": false, "message": "人物展示资料没有按四维、小传和原型复核完整覆盖 20 人。"}
	return {
		"ok": true,
		"attributes_by_id": attributes_by_id,
		"profiles_by_id": profiles_by_id,
		"groups_by_id": groups_by_id,
	}


static func _validate_profile(
	profile: Dictionary,
	character_id: String,
	character: Dictionary,
	source_ids: Dictionary
) -> Dictionary:
	if not _has_exact_keys(profile, ["character_id", "headline", "biography", "source_refs"]):
		return {"ok": false, "message": "小传字段不完整或含未知字段。"}
	var headline := str(profile.get("headline", "")).strip_edges()
	var biography := str(profile.get("biography", "")).strip_edges()
	var profile_sources: Variant = profile.get("source_refs", [])
	if str(profile.get("character_id", "")) != character_id or headline.is_empty() or headline.length() > 24:
		return {"ok": false, "message": "小传人物或标题无效。"}
	if biography.length() < 80 or biography.length() > 160:
		return {"ok": false, "message": "原创小传长度必须为 80—160 字。"}
	if not (profile_sources is Array) or profile_sources.is_empty():
		return {"ok": false, "message": "小传必须登记至少一项来源。"}
	var character_sources: Array = character.get("source_refs", [])
	var includes_identity_source := false
	for source_id_value in profile_sources:
		var source_id := str(source_id_value)
		if not source_ids.has(source_id):
			return {"ok": false, "message": "小传引用了未登记来源。"}
		if source_id in character_sources:
			includes_identity_source = true
	if not includes_identity_source:
		return {"ok": false, "message": "小传必须至少包含人物身份事实来源。"}
	return {"ok": true}


static func _portrait_paths_match(portrait: Dictionary, asset: Dictionary) -> bool:
	for pair in [
		["source_path", "source"],
		["master_path", "master_512"],
		["runtime_path", "runtime_128"],
	]:
		var evidence: Dictionary = asset.get(pair[1], {})
		if str(portrait.get(pair[0], "")) != str(evidence.get("path", "")):
			return false
	return true


static func _index_unique(values: Variant, id_key: String) -> Dictionary:
	var result := {"ids": [], "records": {}, "count": 0}
	if not (values is Array):
		return result
	var ids: Array = result["ids"]
	var records: Dictionary = result["records"]
	for value in values:
		if not (value is Dictionary):
			return {"ids": [], "records": {}, "count": -1}
		var record: Dictionary = value
		var record_id := str(record.get(id_key, ""))
		if record_id.is_empty() or records.has(record_id):
			return {"ids": [], "records": {}, "count": -1}
		ids.append(record_id)
		records[record_id] = record
	result["count"] = ids.size()
	return result


static func _has_exact_keys(document: Dictionary, expected_keys: Array) -> bool:
	if document.size() != expected_keys.size():
		return false
	for key in expected_keys:
		if not document.has(key):
			return false
	return true


static func _report(
	ready: bool,
	character_results: Array,
	blocking_reasons: Array
) -> Dictionary:
	var passed := 0
	for value in character_results:
		if value is Dictionary and bool((value as Dictionary).get("material_ready", false)):
			passed += 1
	return {
		"schema_version": 1,
		"record_type": "character_release_material_preflight_report",
		"stage": "M4-A2.2.1",
		"status": STATUS_READY if ready else STATUS_INVALID,
		"all_material_inputs_valid": ready,
		"human_approval_included": false,
		"formal_write_permitted": false,
		"automatic_promotion_permitted": false,
		"summary": {
			"total": CANDIDATE_COUNT,
			"passed": passed,
			"failed": CANDIDATE_COUNT - passed,
		},
		"characters": character_results.duplicate(true),
		"blocking_reasons": blocking_reasons.duplicate(true),
	}


static func _blocker(code: String, message: String, character_ids: Array = []) -> Dictionary:
	return {
		"code": code,
		"message": message,
		"character_ids": character_ids.duplicate(),
	}
