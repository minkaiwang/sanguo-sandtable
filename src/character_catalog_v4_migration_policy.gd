class_name CharacterCatalogV4MigrationPolicy
extends RefCounted

## M4-B5：v15／目录 v3 → v16／目录 v4 纯迁移草案。
##
## 迁移只更新两个版本字段；既有人物摆放和所有玩家内容逐项保持。
## 新增 20 人留在人物背包的目录中，不自动生成任何本局记录。

const SOURCE_SAVE_VERSION := 15
const TARGET_SAVE_VERSION := 16
const SOURCE_CATALOG_VERSION := 3
const TARGET_CATALOG_VERSION := 4
const SOURCE_CHARACTER_COUNT := 60
const TARGET_CHARACTER_COUNT := 80

const REQUIRED_TOP_LEVEL_KEYS := [
	"save_version",
	"character_catalog_version",
	"metadata",
	"scenario_state",
	"chronicle",
	"player_strokes",
	"character_states",
	"character_actions",
	"character_troops",
	"map_id",
	"map_geometry_version",
	"camera",
	"cards",
	"annotations",
	"updated_at",
]


static func migrate_v15_catalog_v3_to_v16_catalog_v4(
	source_payload_value: Variant,
	source_character_ids_value: Variant,
	target_character_ids_value: Variant
) -> Dictionary:
	var catalog_result := _validate_catalog_extension(
		source_character_ids_value,
		target_character_ids_value
	)
	if not bool(catalog_result.get("ok", false)):
		return catalog_result
	if not (source_payload_value is Dictionary):
		return _failure("payload_not_dictionary", "迁移输入必须是完整 v15 沙盘对象。")

	var source_payload: Dictionary = source_payload_value
	var source_validation := _validate_payload(
		source_payload,
		SOURCE_SAVE_VERSION,
		SOURCE_CATALOG_VERSION,
		catalog_result.get("source_character_ids", [])
	)
	if not bool(source_validation.get("ok", false)):
		return source_validation

	var migrated := source_payload.duplicate(true)
	migrated["save_version"] = TARGET_SAVE_VERSION
	migrated["character_catalog_version"] = TARGET_CATALOG_VERSION
	var target_validation := _validate_payload(
		migrated,
		TARGET_SAVE_VERSION,
		TARGET_CATALOG_VERSION,
		catalog_result.get("target_character_ids", [])
	)
	if not bool(target_validation.get("ok", false)):
		return _failure(
			"migrated_payload_invalid",
			"迁移结果没有通过 v16／目录 v4 契约：%s" % str(target_validation.get("message", "未知错误。"))
		)
	if not _same_non_version_payload(source_payload, migrated):
		return _failure("unexpected_payload_mutation", "迁移除两个版本字段外修改了沙盘内容。")
	return {
		"ok": true,
		"payload": migrated,
		"source_save_version": SOURCE_SAVE_VERSION,
		"target_save_version": TARGET_SAVE_VERSION,
		"source_character_catalog_version": SOURCE_CATALOG_VERSION,
		"target_character_catalog_version": TARGET_CATALOG_VERSION,
		"source_character_count": SOURCE_CHARACTER_COUNT,
		"target_character_count": TARGET_CHARACTER_COUNT,
		"changed_paths": ["save_version", "character_catalog_version"],
		"added_character_records": 0,
		"removed_character_records": 0,
		"runtime_write_permitted": false,
	}


static func validate_v16_catalog_v4_payload(
	payload_value: Variant,
	target_character_ids_value: Variant
) -> Dictionary:
	var ids_result := _normalize_character_ids(
		target_character_ids_value,
		TARGET_CHARACTER_COUNT,
		"目录 v4"
	)
	if not bool(ids_result.get("ok", false)):
		return ids_result
	if not (payload_value is Dictionary):
		return _failure("payload_not_dictionary", "v16 沙盘必须是对象。")
	return _validate_payload(
		payload_value,
		TARGET_SAVE_VERSION,
		TARGET_CATALOG_VERSION,
		ids_result.get("ids", [])
	)


static func evaluate_rollback_request(
	current_payload_value: Variant,
	raw_v15_backup_available: bool
) -> Dictionary:
	if not (current_payload_value is Dictionary):
		return _failure("payload_not_dictionary", "回退检查需要 v16 沙盘对象。")
	var payload: Dictionary = current_payload_value
	if (
		int(payload.get("save_version", 0)) != TARGET_SAVE_VERSION
		or int(payload.get("character_catalog_version", 0)) != TARGET_CATALOG_VERSION
	):
		return _failure("not_v16_catalog_v4", "当前内容不是 v16／目录 v4。")
	if not raw_v15_backup_available:
		return _failure("raw_backup_required", "没有逐字节 v15 原始备份时禁止回退。")
	return {
		"ok": true,
		"strategy": "restore_raw_v15_bytes",
		"lossy_downgrade_allowed": false,
		"rewrite_v16_as_v15_allowed": false,
	}


static func _validate_catalog_extension(
	source_character_ids_value: Variant,
	target_character_ids_value: Variant
) -> Dictionary:
	var source_result := _normalize_character_ids(
		source_character_ids_value,
		SOURCE_CHARACTER_COUNT,
		"目录 v3"
	)
	if not bool(source_result.get("ok", false)):
		return source_result
	var target_result := _normalize_character_ids(
		target_character_ids_value,
		TARGET_CHARACTER_COUNT,
		"目录 v4"
	)
	if not bool(target_result.get("ok", false)):
		return target_result
	var source_ids: Array = source_result.get("ids", [])
	var target_ids: Array = target_result.get("ids", [])
	if target_ids.slice(0, SOURCE_CHARACTER_COUNT) != source_ids:
		return _failure("catalog_prefix_changed", "目录 v4 的前 60 个 ID 必须逐位等于目录 v3。")
	return {
		"ok": true,
		"source_character_ids": source_ids,
		"target_character_ids": target_ids,
	}


static func _normalize_character_ids(
	values: Variant,
	expected_count: int,
	label: String
) -> Dictionary:
	if not (values is Array):
		return _failure("catalog_ids_not_array", "%s ID 必须是数组。" % label)
	var result: Array[String] = []
	var seen := {}
	for value in values:
		if not (value is String):
			return _failure("catalog_id_not_string", "%s 包含非字符串 ID。" % label)
		var character_id := str(value).strip_edges()
		if character_id.is_empty() or seen.has(character_id):
			return _failure("catalog_id_empty_or_duplicate", "%s 包含空 ID 或重复 ID：%s。" % [label, character_id])
		seen[character_id] = true
		result.append(character_id)
	if result.size() != expected_count:
		return _failure("catalog_count_mismatch", "%s 必须恰好包含 %d 个 ID。" % [label, expected_count])
	return {"ok": true, "ids": result}


static func _validate_payload(
	payload: Dictionary,
	expected_save_version: int,
	expected_catalog_version: int,
	allowed_character_ids: Array
) -> Dictionary:
	if payload.size() != REQUIRED_TOP_LEVEL_KEYS.size():
		return _failure("top_level_shape_mismatch", "沙盘顶层必须恰好包含 %d 个规范字段。" % REQUIRED_TOP_LEVEL_KEYS.size())
	for key in REQUIRED_TOP_LEVEL_KEYS:
		if not payload.has(key):
			return _failure("missing_top_level_key", "沙盘缺少必要顶层字段：%s。" % key)
	for key_value in payload.keys():
		if str(key_value) not in REQUIRED_TOP_LEVEL_KEYS:
			return _failure("unknown_top_level_key", "沙盘包含未定义顶层字段：%s。" % str(key_value))
	if int(payload.get("save_version", 0)) != expected_save_version:
		return _failure("unexpected_save_version", "沙盘版本必须为 v%d。" % expected_save_version)
	if int(payload.get("character_catalog_version", 0)) != expected_catalog_version:
		return _failure("unexpected_character_catalog_version", "人物目录版本必须为 v%d。" % expected_catalog_version)

	var allowed_ids := {}
	for character_id_value in allowed_character_ids:
		allowed_ids[str(character_id_value)] = true
	var cards_result := _validate_record_references(payload.get("cards", null), "cards", allowed_ids)
	if not bool(cards_result.get("ok", false)):
		return cards_result
	var scenario_value: Variant = payload.get("scenario_state", null)
	if not (scenario_value is Dictionary):
		return _failure("scenario_state_not_dictionary", "剧本状态必须是对象。")
	var scenario: Dictionary = scenario_value
	var featured_result := _validate_id_list(
		scenario.get("featured_character_ids", null),
		"featured_character_ids",
		allowed_ids
	)
	if not bool(featured_result.get("ok", false)):
		return featured_result
	var assignments_result := _validate_record_references(
		scenario.get("character_assignments", null),
		"character_assignments",
		allowed_ids
	)
	if not bool(assignments_result.get("ok", false)):
		return assignments_result
	for payload_key in ["character_states", "character_actions", "character_troops"]:
		var collection_value: Variant = payload.get(payload_key, null)
		if not (collection_value is Dictionary):
			return _failure("%s_not_dictionary" % payload_key, "%s 必须是对象。" % payload_key)
		var result := _validate_record_references(
			(collection_value as Dictionary).get("records", null),
			payload_key,
			allowed_ids
		)
		if not bool(result.get("ok", false)):
			return result
	return {
		"ok": true,
		"save_version": expected_save_version,
		"character_catalog_version": expected_catalog_version,
		"available_character_count": allowed_ids.size(),
	}


static func _validate_id_list(values: Variant, label: String, allowed_ids: Dictionary) -> Dictionary:
	if not (values is Array):
		return _failure("%s_not_array" % label, "%s 必须是数组。" % label)
	var seen := {}
	for value in values:
		if not (value is String):
			return _failure("%s_invalid_character" % label, "%s 包含非字符串人物 ID。" % label)
		var character_id := str(value).strip_edges()
		if not allowed_ids.has(character_id):
			return _failure("%s_unknown_character" % label, "%s 引用了目录之外的人物：%s。" % [label, character_id])
		if seen.has(character_id):
			return _failure("%s_duplicate_character" % label, "%s 重复引用人物：%s。" % [label, character_id])
		seen[character_id] = true
	return {"ok": true}


static func _validate_record_references(values: Variant, label: String, allowed_ids: Dictionary) -> Dictionary:
	if not (values is Array):
		return _failure("%s_not_array" % label, "%s 记录必须是数组。" % label)
	var seen := {}
	for value in values:
		if not (value is Dictionary):
			return _failure("%s_record_not_dictionary" % label, "%s 包含非对象记录。" % label)
		var character_id_value: Variant = (value as Dictionary).get("character_id", null)
		if not (character_id_value is String):
			return _failure("%s_invalid_character" % label, "%s 的人物 ID 必须是字符串。" % label)
		var character_id := str(character_id_value).strip_edges()
		if not allowed_ids.has(character_id):
			return _failure("%s_unknown_character" % label, "%s 引用了目录之外的人物：%s。" % [label, character_id])
		if seen.has(character_id):
			return _failure("%s_duplicate_character" % label, "%s 重复引用人物：%s。" % [label, character_id])
		seen[character_id] = true
	return {"ok": true}


static func _same_non_version_payload(source_payload: Dictionary, target_payload: Dictionary) -> bool:
	var source_copy := source_payload.duplicate(true)
	var target_copy := target_payload.duplicate(true)
	source_copy.erase("save_version")
	source_copy.erase("character_catalog_version")
	target_copy.erase("save_version")
	target_copy.erase("character_catalog_version")
	return source_copy == target_copy


static func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": code, "message": message}
