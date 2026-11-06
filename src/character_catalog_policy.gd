class_name CharacterCatalogPolicy
extends RefCounted


const SCHEMA_VERSION := 1
const CATALOG_ID := "three_kingdoms_character_catalog"
const ROOT_KEYS := [
	"schema_version", "catalog_id", "character_catalog_version",
	"runtime_character_count", "id_policy", "compatibility_policy",
	"character_ids"
]


static func decode_manifest(document_value: Variant, runtime_characters_value: Variant) -> Dictionary:
	if not document_value is Dictionary:
		return _failure("manifest_not_dictionary", "人物目录清单顶层必须是对象。")
	if not runtime_characters_value is Array:
		return _failure("characters_not_array", "运行人物必须是数组。")
	var document: Dictionary = document_value
	var runtime_characters: Array = runtime_characters_value
	if not _has_exact_keys(document, ROOT_KEYS):
		return _failure("invalid_manifest_keys", "人物目录清单字段不完整或包含未登记字段。")
	if not _is_positive_integer(document.get("schema_version", null)) or int(document.get("schema_version")) != SCHEMA_VERSION:
		return _failure("unsupported_manifest_schema", "人物目录清单版本不受支持。")
	if str(document.get("catalog_id", "")) != CATALOG_ID:
		return _failure("wrong_catalog_id", "人物目录标识不匹配。")
	if not _is_positive_integer(document.get("character_catalog_version", null)):
		return _failure("invalid_catalog_version", "人物目录版本必须是正整数。")
	if str(document.get("id_policy", "")) != "append_only_never_reuse":
		return _failure("unsafe_id_policy", "人物 ID 必须只追加、永不复用。")
	if str(document.get("compatibility_policy", "")) != "reject_newer_catalog_no_silent_drop":
		return _failure("unsafe_compatibility_policy", "人物目录必须拒绝静默丢弃新人物。")
	var ids_value: Variant = document.get("character_ids", null)
	if not ids_value is Array:
		return _failure("character_ids_not_array", "人物目录 ID 必须是数组。")
	var ids: Array = ids_value
	if not _is_positive_integer(document.get("runtime_character_count", null)) or int(document.get("runtime_character_count")) != ids.size():
		return _failure("character_count_mismatch", "人物目录声明数量与 ID 数量不一致。")
	if runtime_characters.size() != ids.size():
		return _failure("runtime_count_mismatch", "人物目录与运行人物数量不一致。")
	var seen_ids := {}
	for index in range(ids.size()):
		if not ids[index] is String:
			return _failure("invalid_character_id", "人物目录 ID 必须是字符串。")
		var character_id := str(ids[index]).strip_edges()
		if not _is_safe_id(character_id) or seen_ids.has(character_id):
			return _failure("invalid_or_duplicate_character_id", "人物目录 ID 无效或重复：%s。" % character_id)
		seen_ids[character_id] = true
		var runtime_character: Variant = runtime_characters[index]
		if not runtime_character is Dictionary or str((runtime_character as Dictionary).get("id", "")).strip_edges() != character_id:
			return _failure("runtime_order_mismatch", "人物目录必须与运行人物稳定顺序完全一致：%s。" % character_id)
	return {
		"ok": true,
		"catalog_version": int(document.get("character_catalog_version")),
		"character_count": ids.size(),
		"character_ids": ids.duplicate(),
	}


static func evaluate_payload_catalog(
	payload_value: Variant,
	current_catalog_version: int,
	catalog_required_save_version: int,
	current_catalog_save_version := 0,
	previous_catalog_version := 0,
	previous_catalog_max_save_version := 0,
	historical_catalog_max_save_versions: Dictionary = {},
	previous_catalog_min_save_version := 0
) -> Dictionary:
	if not payload_value is Dictionary:
		return _failure("payload_not_dictionary", "沙盘 payload 必须是对象。")
	if current_catalog_version < 1 or catalog_required_save_version < 2:
		return _failure("invalid_policy_configuration", "目录兼容策略配置无效。")
	var current_activation_version := (
		catalog_required_save_version
		if current_catalog_save_version <= 0
		else current_catalog_save_version
	)
	if current_activation_version < catalog_required_save_version:
		return _failure("invalid_policy_configuration", "当前目录启用版本不能早于目录字段启用版本。")
	if (
		(previous_catalog_version == 0) != (previous_catalog_max_save_version == 0)
		or previous_catalog_version < 0
		or previous_catalog_max_save_version < 0
		or previous_catalog_version >= current_catalog_version
	):
		return _failure("invalid_policy_configuration", "上一版目录迁移配置无效。")
	var previous_minimum := (
		catalog_required_save_version
		if previous_catalog_min_save_version <= 0
		else previous_catalog_min_save_version
	)
	if previous_catalog_version > 0 and (
		previous_minimum < catalog_required_save_version
		or previous_minimum > previous_catalog_max_save_version
	):
		return _failure("invalid_policy_configuration", "上一版目录迁移版本范围无效。")
	for catalog_version_value in historical_catalog_max_save_versions:
		var maximum_save_version_value: Variant = historical_catalog_max_save_versions[catalog_version_value]
		if (
			not _is_positive_integer(catalog_version_value)
			or not _is_positive_integer(maximum_save_version_value)
			or int(catalog_version_value) >= current_catalog_version
			or int(catalog_version_value) == previous_catalog_version
		):
			return _failure("invalid_policy_configuration", "历史目录迁移配置无效。")
	var payload: Dictionary = payload_value
	var save_version_value: Variant = payload.get("save_version", null)
	if not _is_positive_integer(save_version_value):
		return _failure("invalid_save_version", "沙盘版本必须是正整数。")
	var save_version := int(save_version_value)
	if save_version < catalog_required_save_version:
		if payload.has("character_catalog_version"):
			return _failure("legacy_payload_has_catalog", "旧版沙盘不得提前携带人物目录字段。")
		return {
			"ok": true,
			"source_catalog_version": 1,
			"catalog_migration_required": current_catalog_version > 1,
			"compatibility": "legacy_catalog_v1",
		}
	var catalog_version_value: Variant = payload.get("character_catalog_version", null)
	if not _is_positive_integer(catalog_version_value):
		return _failure("missing_or_invalid_catalog_version", "当前沙盘必须声明有效人物目录版本。")
	var source_catalog_version := int(catalog_version_value)
	if source_catalog_version > current_catalog_version:
		return _failure("newer_character_catalog", "该沙盘使用更新的人物目录，请升级游戏后再试。")
	if source_catalog_version < current_catalog_version:
		if (
			source_catalog_version == previous_catalog_version
			and save_version >= previous_minimum
			and save_version <= previous_catalog_max_save_version
		):
			return {
				"ok": true,
				"source_catalog_version": source_catalog_version,
				"catalog_migration_required": true,
				"compatibility": "explicit_previous_catalog_migration",
			}
		if (
			historical_catalog_max_save_versions.has(source_catalog_version)
			and save_version <= int(historical_catalog_max_save_versions[source_catalog_version])
		):
			return {
				"ok": true,
				"source_catalog_version": source_catalog_version,
				"catalog_migration_required": true,
				"compatibility": "explicit_historical_catalog_migration",
			}
		return _failure(
			"older_character_catalog_in_current_save",
			"当前版本沙盘必须使用当前人物目录；旧目录只能随旧版沙盘进入显式迁移。"
		)
	if save_version < current_activation_version:
		return _failure(
			"current_catalog_before_activation",
			"人物目录版本与沙盘版本不属于同一发布组合。"
		)
	return {
		"ok": true,
		"source_catalog_version": source_catalog_version,
		"catalog_migration_required": false,
		"compatibility": "current_catalog",
	}


static func _has_exact_keys(record: Dictionary, allowed: Array) -> bool:
	if record.size() != allowed.size():
		return false
	for key in record.keys():
		if not allowed.has(str(key)):
			return false
	return true


static func _is_positive_integer(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] \
		and is_finite(float(value)) \
		and is_equal_approx(float(value), roundf(float(value))) \
		and int(value) >= 1


static func _is_safe_id(value: String) -> bool:
	if value.is_empty() or value.length() > 80:
		return false
	var pattern := RegEx.new()
	return pattern.compile("^[a-z0-9][a-z0-9_]*$") == OK and pattern.search(value) != null


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
