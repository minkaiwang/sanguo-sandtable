class_name MapGeographicContextPolicy
extends RefCounted


const SCHEMA_VERSION := 1
const MAP_ID := "map_three_kingdoms_alpha"
const MAP_GEOMETRY_VERSION := 4
const SEMANTIC_LAYER := "project_cartographic_context"
const VERIFICATION_STATUS := "not_historical_boundary"
const INTERACTION_POLICY := "read_only_no_hit_no_snap_no_route_no_save"
const COORDINATE_POLICY := "editorial_lon_lat_anchor_for_overview_only"
const RECORD_LIMIT := 12
const ALLOWED_KINDS := {"macro_region": true, "water_body": true}
const ALLOWED_ROOT_KEYS := {
	"schema_version": true,
	"map_id": true,
	"map_geometry_version": true,
	"semantic_layer": true,
	"verification_status": true,
	"interaction_policy": true,
	"coordinate_policy": true,
	"records": true,
}
const ALLOWED_RECORD_KEYS := {
	"id": true,
	"kind": true,
	"label": true,
	"lon": true,
	"lat": true,
	"min_zoom": true,
	"max_zoom": true,
	"rotation_deg": true,
	"priority": true,
	"source_note": true,
}
const FORBIDDEN_RECORD_KEYS := {
	"x": true,
	"y": true,
	"place_id": true,
	"from": true,
	"to": true,
	"route": true,
	"faction": true,
	"character_id": true,
	"interactive": true,
	"snap": true,
	"hitbox": true,
}


static func decode_document(value: Variant, projection_bounds: Dictionary) -> Dictionary:
	if not value is Dictionary:
		return _failure("document_not_dictionary", "外围地理参照数据必须是对象。")
	var document: Dictionary = value
	for key_value in document.keys():
		var key := str(key_value)
		if not ALLOWED_ROOT_KEYS.has(key):
			return _failure("unknown_root_field", "外围地理参照根对象含未知字段：%s。" % key)
	if int(document.get("schema_version", -1)) != SCHEMA_VERSION:
		return _failure("unsupported_schema", "外围地理参照 schema 版本不受支持。")
	if str(document.get("map_id", "")) != MAP_ID \
			or int(document.get("map_geometry_version", -1)) != MAP_GEOMETRY_VERSION:
		return _failure("map_mismatch", "外围地理参照必须匹配当前地图与 geometry v4。")
	if str(document.get("semantic_layer", "")) != SEMANTIC_LAYER \
			or str(document.get("verification_status", "")) != VERIFICATION_STATUS \
			or str(document.get("interaction_policy", "")) != INTERACTION_POLICY \
			or str(document.get("coordinate_policy", "")) != COORDINATE_POLICY:
		return _failure("policy_mismatch", "外围地理参照必须保持只读、非边界复原与不可交互策略。")
	var bounds_result := _decode_bounds(projection_bounds)
	if not bool(bounds_result.get("ok", false)):
		return bounds_result
	var records_value: Variant = document.get("records", null)
	if not records_value is Array:
		return _failure("records_not_array", "外围地理参照 records 必须是数组。")
	var records: Array = records_value
	if records.is_empty() or records.size() > RECORD_LIMIT:
		return _failure("record_count_out_of_range", "外围地理参照必须包含 1—%d 条记录。" % RECORD_LIMIT)
	var bounds: Dictionary = bounds_result.get("bounds", {})
	var seen_ids := {}
	var decoded_records: Array[Dictionary] = []
	for index in range(records.size()):
		var record_result := _decode_record(records[index], index, bounds, seen_ids)
		if not bool(record_result.get("ok", false)):
			return record_result
		decoded_records.append((record_result.get("record", {}) as Dictionary).duplicate(true))
	return {
		"ok": true,
		"records": decoded_records,
		"count": decoded_records.size(),
		"semantic_layer": SEMANTIC_LAYER,
		"verification_status": VERIFICATION_STATUS,
		"interactive": false,
	}


static func visible_records(records: Array, zoom: float) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not is_finite(zoom):
		return result
	for record_value in records:
		if not record_value is Dictionary:
			continue
		var record: Dictionary = record_value
		if zoom + 0.0001 < float(record.get("min_zoom", 0.0)) \
				or zoom - 0.0001 > float(record.get("max_zoom", 0.0)):
			continue
		result.append(record)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var priority_a := int(a.get("priority", 99))
		var priority_b := int(b.get("priority", 99))
		if priority_a != priority_b:
			return priority_a < priority_b
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	return result


static func project_record(record: Dictionary, projection_bounds: Dictionary) -> Vector2:
	var west := float(projection_bounds.get("west", 0.0))
	var east := float(projection_bounds.get("east", 0.0))
	var south := float(projection_bounds.get("south", 0.0))
	var north := float(projection_bounds.get("north", 0.0))
	return Vector2(
		(float(record.get("lon", west)) - west) / (east - west),
		(north - float(record.get("lat", north))) / (north - south)
	)


static func _decode_record(
	value: Variant,
	index: int,
	bounds: Dictionary,
	seen_ids: Dictionary
) -> Dictionary:
	if not value is Dictionary:
		return _failure("record_not_dictionary", "外围地理参照第 %d 条必须是对象。" % (index + 1))
	var record: Dictionary = value
	for key_value in record.keys():
		var key := str(key_value)
		if FORBIDDEN_RECORD_KEYS.has(key):
			return _failure("forbidden_interaction_field", "外围地理参照不得包含交互字段：%s。" % key)
		if not ALLOWED_RECORD_KEYS.has(key):
			return _failure("unknown_record_field", "外围地理参照含未知字段：%s。" % key)
	var record_id := str(record.get("id", ""))
	if not record_id.begins_with("context_") or not record_id.is_valid_identifier():
		return _failure("invalid_record_id", "外围地理参照 ID 必须是 context_ 开头的安全标识符。")
	if seen_ids.has(record_id):
		return _failure("duplicate_record_id", "外围地理参照 ID 重复：%s。" % record_id)
	seen_ids[record_id] = true
	var kind := str(record.get("kind", ""))
	if not ALLOWED_KINDS.has(kind):
		return _failure("unknown_kind", "外围地理参照类型不受支持：%s。" % kind)
	var label := str(record.get("label", "")).strip_edges()
	if label.is_empty() or label.length() > 8:
		return _failure("invalid_label", "外围地理参照标签必须为 1—8 字。")
	var lon_value: Variant = record.get("lon", null)
	var lat_value: Variant = record.get("lat", null)
	if not _is_number(lon_value) or not _is_number(lat_value):
		return _failure("invalid_coordinate", "外围地理参照必须提供有限 lon/lat。")
	var lon := float(lon_value)
	var lat := float(lat_value)
	if lon < float(bounds.get("west")) or lon > float(bounds.get("east")) \
			or lat < float(bounds.get("south")) or lat > float(bounds.get("north")):
		return _failure("coordinate_out_of_bounds", "外围地理参照坐标超出范围 B。")
	var min_zoom_value: Variant = record.get("min_zoom", null)
	var max_zoom_value: Variant = record.get("max_zoom", null)
	var rotation_value: Variant = record.get("rotation_deg", null)
	if not _is_number(min_zoom_value) or not _is_number(max_zoom_value) \
			or not _is_number(rotation_value):
		return _failure("invalid_display_number", "外围地理参照缩放与旋转必须为有限数值。")
	var min_zoom := float(min_zoom_value)
	var max_zoom := float(max_zoom_value)
	var rotation := float(rotation_value)
	if min_zoom < 0.4 or max_zoom > 0.88 or min_zoom >= max_zoom:
		return _failure("invalid_zoom_range", "外围地理参照只能在 40%—88% 的远景范围内显示。")
	if rotation < -15.0 or rotation > 15.0:
		return _failure("invalid_rotation", "外围地理参照旋转必须在 ±15° 内。")
	var priority_value: Variant = record.get("priority", null)
	if not _is_integer_number(priority_value) or int(priority_value) < 1 or int(priority_value) > 2:
		return _failure("invalid_priority", "外围地理参照优先级只能为 1 或 2。")
	var source_note := str(record.get("source_note", "")).strip_edges()
	if source_note.length() < 12 or source_note.length() > 120:
		return _failure("invalid_source_note", "外围地理参照必须提供 12—120 字的使用边界说明。")
	return {
		"ok": true,
		"record": {
			"id": record_id,
			"kind": kind,
			"label": label,
			"lon": lon,
			"lat": lat,
			"min_zoom": min_zoom,
			"max_zoom": max_zoom,
			"rotation_deg": rotation,
			"priority": int(priority_value),
			"source_note": source_note,
		},
	}


static func _decode_bounds(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return _failure("bounds_not_dictionary", "外围地理参照投影范围必须是对象。")
	var bounds: Dictionary = value
	for key in ["west", "east", "south", "north"]:
		if not _is_number(bounds.get(key, null)):
			return _failure("invalid_bounds", "外围地理参照投影范围缺少有限坐标。")
	if float(bounds.get("west")) >= float(bounds.get("east")) \
			or float(bounds.get("south")) >= float(bounds.get("north")):
		return _failure("reversed_bounds", "外围地理参照投影范围方向无效。")
	return {"ok": true, "bounds": bounds.duplicate(true)}


static func _is_number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value))


static func _is_integer_number(value: Variant) -> bool:
	return _is_number(value) and is_equal_approx(float(value), round(float(value)))


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
