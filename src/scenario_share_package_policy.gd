extends RefCounted

const FORMAT := "sanguo_scenario_start_package"
const FORMAT_VERSION := 1
const FILE_EXTENSION := ".sanguostart"

const _ROOT_KEYS := {
	"format": true,
	"format_version": true,
	"package_id": true,
	"exported_at": true,
	"character_catalog_version": true,
	"map_id": true,
	"map_geometry_version": true,
	"template": true
}


static func build_document(
	template: Dictionary,
	package_id: String,
	exported_at: String,
	character_catalog_version: int,
	map_id: String,
	map_geometry_version: int
) -> Dictionary:
	return {
		"format": FORMAT,
		"format_version": FORMAT_VERSION,
		"package_id": package_id,
		"exported_at": exported_at,
		"character_catalog_version": character_catalog_version,
		"map_id": map_id,
		"map_geometry_version": map_geometry_version,
		"template": template.duplicate(true)
	}


static func decode_outer_document(
	document: Variant,
	expected_character_catalog_version: int,
	expected_map_id: String,
	expected_map_geometry_version: int
) -> Dictionary:
	if not (document is Dictionary):
		return _failure("开局包顶层必须是对象。")
	var root: Dictionary = document
	if root.size() != _ROOT_KEYS.size():
		return _failure("开局包顶层字段不完整或含未定义内容。")
	for key in root.keys():
		if not _ROOT_KEYS.has(str(key)):
			return _failure("开局包含未定义顶层字段：%s。" % str(key))
	if str(root.get("format", "")) != FORMAT:
		return _failure("这不是三国推演志开局包。")
	if not _is_integer_number(root.get("format_version", null)):
		return _failure("开局包版本无效。")
	var format_version := int(root.get("format_version", -1))
	if format_version > FORMAT_VERSION:
		return _failure("这个开局包由更新版本创建，请升级游戏后再试。", "future_version")
	if format_version != FORMAT_VERSION:
		return _failure("开局包版本不受支持。", "unsupported_version")
	var package_id := str(root.get("package_id", "")).strip_edges()
	if not _is_safe_record_id(package_id):
		return _failure("开局包 ID 无效。")
	var exported_at := str(root.get("exported_at", "")).strip_edges()
	if exported_at.is_empty() or exported_at.length() > 64 or "\n" in exported_at or "\r" in exported_at:
		return _failure("开局包导出时间无效。")
	if not _is_integer_number(root.get("character_catalog_version", null)):
		return _failure("开局包人物目录版本无效。")
	var catalog_version := int(root.get("character_catalog_version", -1))
	if catalog_version > expected_character_catalog_version:
		return _failure("这个开局包引用了更新的人物目录，请升级游戏后再试。", "future_catalog")
	if catalog_version != expected_character_catalog_version:
		return _failure("这个开局包的人物目录版本不兼容。", "catalog_mismatch")
	if str(root.get("map_id", "")) != expected_map_id:
		return _failure("开局包使用了不同的地图。", "map_mismatch")
	if not _is_integer_number(root.get("map_geometry_version", null)):
		return _failure("开局包地图版本无效。")
	var geometry_version := int(root.get("map_geometry_version", -1))
	if geometry_version > expected_map_geometry_version:
		return _failure("这个开局包使用了更新的地图版本，请升级游戏后再试。", "future_geometry")
	if geometry_version != expected_map_geometry_version:
		return _failure("这个开局包的地图版本不兼容。", "geometry_mismatch")
	var template_value: Variant = root.get("template", null)
	if not (template_value is Dictionary):
		return _failure("开局包缺少有效的开局模板。")
	return {
		"ok": true,
		"error_code": "",
		"package_id": package_id,
		"exported_at": exported_at,
		"template": (template_value as Dictionary).duplicate(true)
	}


static func normalized_path(path: String) -> String:
	return path if path.to_lower().ends_with(FILE_EXTENSION) else path + FILE_EXTENSION


static func _failure(message: String, error_code := "invalid_package") -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}


static func _is_integer_number(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	return typeof(value) == TYPE_FLOAT and is_finite(float(value)) and is_equal_approx(float(value), roundf(float(value)))


static func _is_safe_record_id(value: String) -> bool:
	if value.length() < 3 or value.length() > 96:
		return false
	for character in value:
		var code := character.unicode_at(0)
		if not ((code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or character in ["_", "-"]):
			return false
	return true
