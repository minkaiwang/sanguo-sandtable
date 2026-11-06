class_name CharacterNameplateReleasePolicy
extends RefCounted

## M4-B4：目录 v4／80 人的名牌发布材料门禁。
##
## 只校验正式 60 人前缀与下一批 20 人的身份、四维、小传和稳定顺序。
## 头像登记、图片文件、头像审核草稿与返工结论不属于本策略输入。

const STATUS_READY := "ready_for_catalog_v4_release_candidate"
const STATUS_INVALID := "invalid_nameplate_release_materials"
const PRESENTATION_MODE := "nameplate"
const FORMAL_CATALOG_VERSION := 3
const TARGET_CATALOG_VERSION := 4
const FORMAL_COUNT := 60
const CANDIDATE_COUNT := 20
const ATTRIBUTE_KEYS := ["character_id", "might", "intelligence", "leadership", "charisma"]


static func evaluate(
	formal_catalog_value: Variant,
	formal_characters_value: Variant,
	candidate_catalog_value: Variant
) -> Dictionary:
	var blockers: Array[Dictionary] = []
	if not (formal_catalog_value is Dictionary):
		blockers.append(_blocker("formal_catalog_invalid", "正式人物目录不是 JSON 对象。"))
	if not (formal_characters_value is Array):
		blockers.append(_blocker("formal_characters_invalid", "正式人物资料不是数组。"))
	if not (candidate_catalog_value is Dictionary):
		blockers.append(_blocker("candidate_catalog_invalid", "下一批人物资料不是对象。"))
	if not blockers.is_empty():
		return _report(false, [], blockers, {})

	var formal_catalog: Dictionary = formal_catalog_value
	var formal_characters: Array = formal_characters_value
	var candidate_catalog: Dictionary = candidate_catalog_value
	var formal_ids_value: Variant = formal_catalog.get("character_ids", [])
	if not (formal_ids_value is Array):
		blockers.append(_blocker("formal_catalog_ids_invalid", "正式人物目录缺少稳定 ID 数组。"))
		return _report(false, [], blockers, {})
	var formal_ids: Array = formal_ids_value
	if (
		int(formal_catalog.get("schema_version", 0)) != 1
		or int(formal_catalog.get("character_catalog_version", 0)) != FORMAL_CATALOG_VERSION
		or int(formal_catalog.get("runtime_character_count", 0)) != FORMAL_COUNT
		or formal_ids.size() != FORMAL_COUNT
		or _unique_strings(formal_ids).size() != FORMAL_COUNT
	):
		blockers.append(_blocker("formal_catalog_contract_mismatch", "正式人物目录必须保持 v3／60 人且 ID 唯一。"))

	var formal_names := {}
	var formal_character_ids: Array[String] = []
	for value in formal_characters:
		if not (value is Dictionary):
			blockers.append(_blocker("formal_character_invalid", "正式人物资料包含非对象记录。"))
			continue
		var character: Dictionary = value
		var character_id := str(character.get("id", "")).strip_edges()
		var character_name := str(character.get("name", "")).strip_edges()
		if character_id.is_empty() or character_name.is_empty() or formal_names.has(character_name):
			blockers.append(_blocker("formal_character_identity_invalid", "正式人物 ID 或姓名为空、重复。", [character_id]))
			continue
		formal_character_ids.append(character_id)
		formal_names[character_name] = true
	if formal_characters.size() != FORMAL_COUNT or formal_character_ids != formal_ids:
		blockers.append(_blocker("formal_character_order_mismatch", "正式 60 人人物资料必须与目录 v3 顺序一致。"))

	var records_value: Variant = candidate_catalog.get("records", [])
	if (
		not bool(candidate_catalog.get("ok", false))
		or int(candidate_catalog.get("catalog_version", 0)) != TARGET_CATALOG_VERSION
		or str(candidate_catalog.get("runtime_policy", "")) != "research_review_memory_only_no_formal_writes"
		or not (records_value is Array)
	):
		blockers.append(_blocker("candidate_catalog_contract_mismatch", "下一批资料必须来自隔离的目录 v4 适配器。"))
		return _report(false, [], blockers, {})
	var records: Array = records_value
	var counts_value: Variant = candidate_catalog.get("counts", {})
	if not (counts_value is Dictionary):
		blockers.append(_blocker("candidate_counts_invalid", "下一批资料缺少计数。"))
	else:
		var counts: Dictionary = counts_value
		if (
			int(counts.get("catalog", 0)) != CANDIDATE_COUNT
			or int(counts.get("formal_baseline", 0)) != FORMAL_COUNT
			or int(counts.get("candidate_review", 0)) != CANDIDATE_COUNT
		):
			blockers.append(_blocker("candidate_counts_mismatch", "下一批资料必须是正式 60 人后的 20 人。"))
	if records.size() != CANDIDATE_COUNT:
		blockers.append(_blocker("candidate_count_mismatch", "目录 v4 新增段必须恰好包含 20 人。"))

	var formal_id_set := {}
	for formal_id_value in formal_ids:
		formal_id_set[str(formal_id_value)] = true
	var seen_ids := {}
	var seen_names := formal_names.duplicate()
	var candidate_ids: Array[String] = []
	var identity_ready := 0
	var attributes_ready := 0
	var editorial_ready := 0
	var nameplate_ready := 0
	for index in range(records.size()):
		var value: Variant = records[index]
		if not (value is Dictionary):
			blockers.append(_blocker("candidate_record_invalid", "下一批人物包含非对象记录。"))
			continue
		var record: Dictionary = value
		var character_id := str(record.get("id", "")).strip_edges()
		var character_name := str(record.get("name", "")).strip_edges()
		candidate_ids.append(character_id)
		var character_blockers: Array[Dictionary] = []
		if (
			character_id.is_empty()
			or character_name.is_empty()
			or seen_ids.has(character_id)
			or formal_id_set.has(character_id)
			or seen_names.has(character_name)
			or int(record.get("catalog_index", 0)) != FORMAL_COUNT + index + 1
			or str(record.get("group", "")).strip_edges() in ["", "待定"]
			or not (record.get("aliases", null) is Array)
			or not (record.get("affiliations", null) is Array)
			or not (record.get("source_refs", null) is Array)
			or (record.get("source_refs", []) as Array).is_empty()
			or str(record.get("status_id", "")) != "candidate_review"
		):
			character_blockers.append(_blocker("candidate_identity_invalid", "人物身份、来源、分组或目录顺序不完整。", [character_id]))
		else:
			identity_ready += 1
		seen_ids[character_id] = true
		seen_names[character_name] = true

		var attributes_value: Variant = record.get("attributes", {})
		if not _valid_attributes(attributes_value, character_id):
			character_blockers.append(_blocker("candidate_attributes_invalid", "人物四维必须完整且为 0—100 整数。", [character_id]))
		else:
			attributes_ready += 1
		if (
			str(record.get("headline", "")).strip_edges().is_empty()
			or str(record.get("biography", "")).strip_edges().is_empty()
			or not (record.get("profile_source_refs", null) is Array)
			or (record.get("profile_source_refs", []) as Array).is_empty()
		):
			character_blockers.append(_blocker("candidate_editorial_invalid", "人物标题或小传为空。", [character_id]))
		else:
			editorial_ready += 1
		if (
			str(record.get("presentation_mode", "")) != PRESENTATION_MODE
			or str(record.get("nameplate_display_name", "")) != character_name
			or bool(record.get("requires_portrait", true))
		):
			character_blockers.append(_blocker("candidate_nameplate_invalid", "人物必须以姓名名牌发布，且不要求头像。", [character_id]))
		else:
			nameplate_ready += 1
		blockers.append_array(character_blockers)

	var summary := {
		"formal_baseline": formal_ids.size(),
		"candidates": records.size(),
		"identity_ready": identity_ready,
		"attributes_ready": attributes_ready,
		"editorial_ready": editorial_ready,
		"nameplate_ready": nameplate_ready,
	}
	return _report(blockers.is_empty(), candidate_ids, blockers, summary, formal_ids)


static func _valid_attributes(value: Variant, character_id: String) -> bool:
	if not (value is Dictionary):
		return false
	var attributes: Dictionary = value
	if attributes.size() != ATTRIBUTE_KEYS.size():
		return false
	for key in ATTRIBUTE_KEYS:
		if not attributes.has(key):
			return false
	if str(attributes.get("character_id", "")) != character_id:
		return false
	for key in ["might", "intelligence", "leadership", "charisma"]:
		var score: Variant = attributes.get(key, null)
		if not (typeof(score) in [TYPE_INT, TYPE_FLOAT]):
			return false
		var numeric := float(score)
		if not is_finite(numeric) or not is_equal_approx(numeric, roundf(numeric)):
			return false
		if int(numeric) < 0 or int(numeric) > 100:
			return false
	return true


static func _unique_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(value).strip_edges()
		if text.is_empty() or text in result:
			continue
		result.append(text)
	return result


static func _report(
	ready: bool,
	candidate_ids: Array,
	blockers: Array,
	summary: Dictionary,
	formal_ids: Array = []
) -> Dictionary:
	var target_ids: Array = formal_ids.duplicate()
	target_ids.append_array(candidate_ids)
	return {
		"schema_version": 1,
		"record_type": "character_nameplate_release_readiness_report",
		"stage": "M4-B4",
		"status": STATUS_READY if ready else STATUS_INVALID,
		"ready_for_release_candidate": ready,
		"formal_write_permitted": false,
		"automatic_promotion_permitted": false,
		"presentation": {
			"mode": PRESENTATION_MODE,
			"requires_portrait_assets": false,
			"map_compact_display": "姓名首字",
			"profile_display": "完整姓名竖排名牌",
		},
		"excluded_inputs": [
			"portrait_registry",
			"portrait_image_assets",
			"portrait_review_drafts",
			"portrait_revision_decisions",
		],
		"summary": summary.duplicate(true),
		"candidate_ids_in_catalog_order": candidate_ids.duplicate(),
		"target_character_ids": target_ids,
		"blocking_reasons": blockers.duplicate(true),
		"next_action": (
			"组装目录 v4／80 人发布候选与存档 v16 迁移草案。"
			if ready
			else "补齐阻断的人物身份、四维、小传或名牌字段后重新检查。"
		),
	}


static func _blocker(code: String, message: String, character_ids: Array = []) -> Dictionary:
	return {
		"code": code,
		"message": message,
		"character_ids": character_ids.duplicate(),
	}
