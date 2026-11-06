class_name MapGeometryMigration
extends RefCounted


const EPSILON := 0.000001


static func bounds_from_projection(projection_value: Variant) -> Dictionary:
	if not projection_value is Dictionary:
		return _failure("projection_not_dictionary", "投影配置必须是对象。")
	var projection: Dictionary = projection_value
	var geographic_value: Variant = projection.get("geographic_bounds", null)
	if not geographic_value is Dictionary:
		return _failure("missing_geographic_bounds", "投影配置缺少 geographic_bounds。")
	var geographic: Dictionary = geographic_value
	var required := ["min_lon", "max_lon", "min_lat", "max_lat"]
	for key in required:
		var value: Variant = geographic.get(key, null)
		if not _is_finite_number(value):
			return _failure("invalid_geographic_bound", "投影边界 %s 不是有限数字。" % key)
	var west := float(geographic.get("min_lon"))
	var east := float(geographic.get("max_lon"))
	var south := float(geographic.get("min_lat"))
	var north := float(geographic.get("max_lat"))
	if east - west <= EPSILON or north - south <= EPSILON:
		return _failure("degenerate_geographic_bounds", "投影经纬范围必须具有正跨度。")
	return {
		"ok": true,
		"bounds": {
			"west": west,
			"east": east,
			"south": south,
			"north": north
		}
	}


static func reproject_normalized(point: Vector2, source_bounds: Dictionary, target_bounds: Dictionary) -> Dictionary:
	var lon_lat_result := normalized_to_lon_lat(point, source_bounds)
	if not bool(lon_lat_result.get("ok", false)):
		return lon_lat_result
	var lon_lat: Vector2 = lon_lat_result.get("lon_lat")
	var normalized_result := lon_lat_to_normalized(lon_lat, target_bounds)
	if not bool(normalized_result.get("ok", false)):
		return normalized_result
	if not bool(normalized_result.get("inside", false)):
		return _failure("target_point_out_of_bounds", "源坐标不在目标投影覆盖范围内，迁移已停止。")
	return {
		"ok": true,
		"point": normalized_result.get("normalized"),
		"longitude": lon_lat.x,
		"latitude": lon_lat.y
	}


static func normalized_to_lon_lat(point: Vector2, bounds: Dictionary) -> Dictionary:
	var bounds_check := _validate_bounds(bounds, "source")
	if not bool(bounds_check.get("ok", false)):
		return bounds_check
	if not is_finite(point.x) or not is_finite(point.y) \
			or point.x < -EPSILON or point.x > 1.0 + EPSILON \
			or point.y < -EPSILON or point.y > 1.0 + EPSILON:
		return _failure("source_point_out_of_bounds", "源归一化坐标必须位于 0—1。")
	var source_point := Vector2(clampf(point.x, 0.0, 1.0), clampf(point.y, 0.0, 1.0))
	return {
		"ok": true,
		"lon_lat": Vector2(
			lerpf(float(bounds.get("west")), float(bounds.get("east")), source_point.x),
			lerpf(float(bounds.get("north")), float(bounds.get("south")), source_point.y)
		)
	}


static func lon_lat_to_normalized(lon_lat: Vector2, bounds: Dictionary) -> Dictionary:
	var bounds_check := _validate_bounds(bounds, "target")
	if not bool(bounds_check.get("ok", false)):
		return bounds_check
	if not is_finite(lon_lat.x) or not is_finite(lon_lat.y):
		return _failure("invalid_lon_lat", "经纬度必须是有限数字。")
	var normalized := Vector2(
		inverse_lerp(float(bounds.get("west")), float(bounds.get("east")), lon_lat.x),
		inverse_lerp(float(bounds.get("north")), float(bounds.get("south")), lon_lat.y)
	)
	var inside := normalized.x >= -EPSILON and normalized.x <= 1.0 + EPSILON \
		and normalized.y >= -EPSILON and normalized.y <= 1.0 + EPSILON
	return {
		"ok": true,
		"normalized": Vector2(clampf(normalized.x, 0.0, 1.0), clampf(normalized.y, 0.0, 1.0)) if inside else normalized,
		"inside": inside
	}


static func reproject_lon_lat_record(record_value: Variant, target_bounds: Dictionary) -> Dictionary:
	if not record_value is Dictionary:
		return _failure("invalid_lon_lat_record", "经纬度记录必须是对象。")
	var record: Dictionary = (record_value as Dictionary).duplicate(true)
	var lon_value: Variant = record.get("lon", null)
	var lat_value: Variant = record.get("lat", null)
	if not _is_finite_number(lon_value) or not _is_finite_number(lat_value):
		return _failure("invalid_lon_lat_record", "记录的 lon/lat 必须是有限数字。")
	var projected := lon_lat_to_normalized(Vector2(float(lon_value), float(lat_value)), target_bounds)
	if not bool(projected.get("ok", false)):
		return projected
	if not bool(projected.get("inside", false)):
		return _failure("lon_lat_out_of_target", "记录的 lon/lat 不在目标投影范围内。")
	var normalized: Vector2 = projected.get("normalized")
	record["x"] = normalized.x
	record["y"] = normalized.y
	return {"ok": true, "record": record}


static func reproject_xy_record(record_value: Variant, source_bounds: Dictionary, target_bounds: Dictionary) -> Dictionary:
	return _migrate_xy_record(record_value, source_bounds, target_bounds, "制图锚点")


static func reproject_point_array(points_value: Variant, source_bounds: Dictionary, target_bounds: Dictionary) -> Dictionary:
	if not points_value is Array:
		return _failure("invalid_point_array", "坐标点集合必须是数组。")
	var migrated_points: Array[Dictionary] = []
	for point_index in range((points_value as Array).size()):
		var result := _migrate_xy_record(
			(points_value as Array)[point_index],
			source_bounds,
			target_bounds,
			"第 %d 个坐标点" % (point_index + 1)
		)
		if not bool(result.get("ok", false)):
			return result
		migrated_points.append((result.get("record") as Dictionary).duplicate(true))
	return {"ok": true, "points": migrated_points}


static func migrate_sandbox_payload(
		payload_value: Variant,
		source_geometry_version: int,
		target_geometry_version: int,
		source_bounds: Dictionary,
		target_bounds: Dictionary,
		target_places_by_id: Dictionary
	) -> Dictionary:
	if source_geometry_version <= 0 or target_geometry_version <= 0 or source_geometry_version == target_geometry_version:
		return _failure("invalid_geometry_transition", "地图几何迁移必须指定不同的正整数版本。")
	if not payload_value is Dictionary:
		return _failure("invalid_sandbox_payload", "沙盘 payload 必须是对象。")
	var payload: Dictionary = (payload_value as Dictionary).duplicate(true)
	var geometry_value: Variant = payload.get("map_geometry_version", null)
	if not _is_integer_number(geometry_value) or int(geometry_value) != source_geometry_version:
		return _failure("unexpected_sandbox_geometry", "沙盘不是 geometry v%d，迁移已停止。" % source_geometry_version)
	var cards_value: Variant = payload.get("cards", null)
	var annotations_value: Variant = payload.get("annotations", null)
	if not cards_value is Array or not annotations_value is Array:
		return _failure("invalid_sandbox_coordinate_collections", "沙盘缺少人物卡或标记数组。")
	var migrated_cards: Array[Dictionary] = []
	var anchored_count := 0
	var free_count := 0
	var unknown_place_count := 0
	var warnings: Array[String] = []
	for card_index in range((cards_value as Array).size()):
		var card_value: Variant = (cards_value as Array)[card_index]
		if not card_value is Dictionary:
			return _failure("invalid_sandbox_card", "第 %d 条人物卡不是对象。" % (card_index + 1))
		var card: Dictionary = (card_value as Dictionary).duplicate(true)
		var point_result := _point_from_record(card, "第 %d 条人物卡" % (card_index + 1))
		if not bool(point_result.get("ok", false)):
			return point_result
		var place_id := str(card.get("place_id", "")).strip_edges()
		if not place_id.is_empty() and target_places_by_id.has(place_id):
			var target_place_value: Variant = target_places_by_id.get(place_id)
			if not target_place_value is Dictionary:
				return _failure("invalid_target_place", "目标地点 %s 不是对象。" % place_id)
			var target_place_result := _point_from_record(target_place_value, "目标地点 %s" % place_id)
			if not bool(target_place_result.get("ok", false)):
				return target_place_result
			var target_point: Vector2 = target_place_result.get("point")
			card["x"] = target_point.x
			card["y"] = target_point.y
			card["place_id"] = place_id
			anchored_count += 1
		else:
			var migrated := reproject_normalized(point_result.get("point"), source_bounds, target_bounds)
			if not bool(migrated.get("ok", false)):
				return _with_context(migrated, "第 %d 条人物卡" % (card_index + 1))
			var migrated_point: Vector2 = migrated.get("point")
			card["x"] = migrated_point.x
			card["y"] = migrated_point.y
			if not place_id.is_empty():
				card.erase("place_id")
				unknown_place_count += 1
				warnings.append("人物卡 %s 的未知地点 %s 已降级为自由摆放。" % [str(card.get("character_id", card_index + 1)), place_id])
			free_count += 1
		migrated_cards.append(card)

	var migrated_annotations: Array[Dictionary] = []
	for annotation_index in range((annotations_value as Array).size()):
		var annotation_result := _migrate_xy_record(
			(annotations_value as Array)[annotation_index],
			source_bounds,
			target_bounds,
			"第 %d 个玩家标记" % (annotation_index + 1)
		)
		if not bool(annotation_result.get("ok", false)):
			return annotation_result
		migrated_annotations.append((annotation_result.get("record") as Dictionary).duplicate(true))

	var migrated_stroke_count := 0
	var migrated_stroke_point_count := 0
	if payload.has("player_strokes"):
		var player_strokes_value: Variant = payload.get("player_strokes")
		if not player_strokes_value is Dictionary:
			return _failure("invalid_sandbox_player_strokes", "沙盘推演线根结构不是对象。")
		var player_strokes_root: Dictionary = (player_strokes_value as Dictionary).duplicate(true)
		var strokes_value: Variant = player_strokes_root.get("strokes", null)
		if not strokes_value is Array:
			return _failure("invalid_sandbox_player_strokes", "沙盘推演线缺少 strokes 数组。")
		var migrated_strokes: Array[Dictionary] = []
		for stroke_index in range((strokes_value as Array).size()):
			var stroke_value: Variant = (strokes_value as Array)[stroke_index]
			if not stroke_value is Dictionary:
				return _failure("invalid_sandbox_player_stroke", "第 %d 条推演线不是对象。" % (stroke_index + 1))
			var stroke: Dictionary = (stroke_value as Dictionary).duplicate(true)
			var points_result := reproject_point_array(stroke.get("points", null), source_bounds, target_bounds)
			if not bool(points_result.get("ok", false)):
				return _with_context(points_result, "第 %d 条推演线" % (stroke_index + 1))
			var migrated_points: Array = points_result.get("points", [])
			stroke["points"] = migrated_points
			migrated_stroke_point_count += migrated_points.size()
			migrated_strokes.append(stroke)
			migrated_stroke_count += 1
		player_strokes_root["strokes"] = migrated_strokes
		payload["player_strokes"] = player_strokes_root

	payload["map_geometry_version"] = target_geometry_version
	payload["camera"] = {}
	payload["cards"] = migrated_cards
	payload["annotations"] = migrated_annotations
	return {
		"ok": true,
		"payload": payload,
		"reset_camera": true,
		"warnings": warnings,
		"stats": {
			"anchored_cards_rebound": anchored_count,
			"free_cards_migrated": free_count,
			"unknown_places_downgraded": unknown_place_count,
			"annotations_migrated": migrated_annotations.size(),
			"player_strokes_migrated": migrated_stroke_count,
			"stroke_points_migrated": migrated_stroke_point_count
		}
	}


static func migrate_runtime_state(
		placements_value: Variant,
		annotations_value: Variant,
		strokes_value: Variant,
		source_bounds: Dictionary,
		target_bounds: Dictionary
	) -> Dictionary:
	if not placements_value is Dictionary:
		return _failure("invalid_placements", "人物摆放集合必须是对象。")
	if not annotations_value is Dictionary:
		return _failure("invalid_annotations", "玩家标记集合必须是对象。")
	if not strokes_value is Array:
		return _failure("invalid_player_strokes", "玩家推演线集合必须是数组。")
	var migrated_placements: Dictionary = {}
	var anchored_placement_count := 0
	var free_placement_count := 0
	for character_id_value in (placements_value as Dictionary).keys():
		var character_id := str(character_id_value)
		var placement_value: Variant = (placements_value as Dictionary).get(character_id_value)
		if not placement_value is Dictionary:
			return _failure("invalid_placement_record", "人物 %s 的摆放记录不是对象。" % character_id)
		var placement: Dictionary = (placement_value as Dictionary).duplicate(true)
		var coordinate_check := _point_from_record(placement, "人物 %s" % character_id)
		if not bool(coordinate_check.get("ok", false)):
			return coordinate_check
		if not str(placement.get("place_id", "")).strip_edges().is_empty():
			migrated_placements[character_id] = placement
			anchored_placement_count += 1
			continue
		var migrated := reproject_normalized(coordinate_check.get("point"), source_bounds, target_bounds)
		if not bool(migrated.get("ok", false)):
			return _with_context(migrated, "人物 %s" % character_id)
		var point: Vector2 = migrated.get("point")
		placement["x"] = point.x
		placement["y"] = point.y
		migrated_placements[character_id] = placement
		free_placement_count += 1

	var migrated_annotations: Dictionary = {}
	for annotation_id_value in (annotations_value as Dictionary).keys():
		var annotation_id := str(annotation_id_value)
		var annotation_result := _migrate_xy_record(
			(annotations_value as Dictionary).get(annotation_id_value),
			source_bounds,
			target_bounds,
			"标记 %s" % annotation_id
		)
		if not bool(annotation_result.get("ok", false)):
			return annotation_result
		migrated_annotations[annotation_id] = (annotation_result.get("record") as Dictionary).duplicate(true)

	var migrated_strokes: Array[Dictionary] = []
	var stroke_point_count := 0
	for stroke_index in range((strokes_value as Array).size()):
		var stroke_value: Variant = (strokes_value as Array)[stroke_index]
		if not stroke_value is Dictionary:
			return _failure("invalid_player_stroke_record", "第 %d 条推演线不是对象。" % (stroke_index + 1))
		var stroke: Dictionary = (stroke_value as Dictionary).duplicate(true)
		var points_value: Variant = stroke.get("points", null)
		if not points_value is Array:
			return _failure("invalid_player_stroke_points", "第 %d 条推演线缺少落点数组。" % (stroke_index + 1))
		var migrated_points: Array[Dictionary] = []
		for point_index in range((points_value as Array).size()):
			var point_result := _migrate_xy_record(
				(points_value as Array)[point_index],
				source_bounds,
				target_bounds,
				"第 %d 条推演线第 %d 点" % [stroke_index + 1, point_index + 1]
			)
			if not bool(point_result.get("ok", false)):
				return point_result
			migrated_points.append((point_result.get("record") as Dictionary).duplicate(true))
			stroke_point_count += 1
		stroke["points"] = migrated_points
		migrated_strokes.append(stroke)

	return {
		"ok": true,
		"placements": migrated_placements,
		"annotations": migrated_annotations,
		"player_strokes": migrated_strokes,
		"reset_camera": true,
		"stats": {
			"anchored_placements_preserved": anchored_placement_count,
			"free_placements_migrated": free_placement_count,
			"annotations_migrated": migrated_annotations.size(),
			"player_strokes_migrated": migrated_strokes.size(),
			"stroke_points_migrated": stroke_point_count
		}
	}


static func migrate_personal_template_records(
		template_values: Variant,
		source_geometry_version: int,
		target_geometry_version: int,
		source_bounds: Dictionary,
		target_bounds: Dictionary
	) -> Dictionary:
	if source_geometry_version <= 0 or target_geometry_version <= 0 or source_geometry_version == target_geometry_version:
		return _failure("invalid_geometry_transition", "地图几何迁移必须指定不同的正整数版本。")
	if not template_values is Array:
		return _failure("invalid_template_records", "个人模板列表必须是数组。")
	var migrated_templates: Array[Dictionary] = []
	var anchored_placement_count := 0
	var free_placement_count := 0
	var annotation_count := 0
	for template_index in range((template_values as Array).size()):
		var template_value: Variant = (template_values as Array)[template_index]
		if not template_value is Dictionary:
			return _failure("invalid_template_record", "第 %d 个个人模板不是对象。" % (template_index + 1))
		var template: Dictionary = (template_value as Dictionary).duplicate(true)
		var geometry_value: Variant = template.get("map_geometry_version", null)
		if not _is_integer_number(geometry_value) or int(geometry_value) != source_geometry_version:
			return _failure("unexpected_template_geometry", "第 %d 个个人模板不是 geometry v%d，整库迁移已停止。" % [template_index + 1, source_geometry_version])
		var placements_value: Variant = template.get("placements", null)
		var annotations_value: Variant = template.get("annotations", null)
		if not placements_value is Array or not annotations_value is Array:
			return _failure("invalid_template_coordinates", "第 %d 个个人模板缺少摆放或标记数组。" % (template_index + 1))
		var migrated_placements: Array[Dictionary] = []
		for placement_index in range((placements_value as Array).size()):
			var placement_value: Variant = (placements_value as Array)[placement_index]
			if not placement_value is Dictionary:
				return _failure("invalid_template_placement", "第 %d 个个人模板的第 %d 个人物摆放不是对象。" % [template_index + 1, placement_index + 1])
			var placement: Dictionary = (placement_value as Dictionary).duplicate(true)
			if not str(placement.get("place_id", "")).strip_edges().is_empty():
				migrated_placements.append(placement)
				anchored_placement_count += 1
				continue
			var placement_result := _migrate_xy_record(
				placement,
				source_bounds,
				target_bounds,
				"第 %d 个个人模板的第 %d 个人物" % [template_index + 1, placement_index + 1]
			)
			if not bool(placement_result.get("ok", false)):
				return placement_result
			migrated_placements.append((placement_result.get("record") as Dictionary).duplicate(true))
			free_placement_count += 1
		var migrated_annotations: Array[Dictionary] = []
		for annotation_index in range((annotations_value as Array).size()):
			var annotation_result := _migrate_xy_record(
				(annotations_value as Array)[annotation_index],
				source_bounds,
				target_bounds,
				"第 %d 个个人模板的第 %d 个标记" % [template_index + 1, annotation_index + 1]
			)
			if not bool(annotation_result.get("ok", false)):
				return annotation_result
			migrated_annotations.append((annotation_result.get("record") as Dictionary).duplicate(true))
			annotation_count += 1
		template["map_geometry_version"] = target_geometry_version
		template["placements"] = migrated_placements
		template["annotations"] = migrated_annotations
		migrated_templates.append(template)
	return {
		"ok": true,
		"templates": migrated_templates,
		"stats": {
			"templates_migrated": migrated_templates.size(),
			"anchored_placements_preserved": anchored_placement_count,
			"free_placements_migrated": free_placement_count,
			"annotations_migrated": annotation_count
		}
	}


static func _migrate_xy_record(
		record_value: Variant,
		source_bounds: Dictionary,
		target_bounds: Dictionary,
		context: String
	) -> Dictionary:
	if not record_value is Dictionary:
		return _failure("invalid_coordinate_record", "%s的坐标记录不是对象。" % context)
	var record: Dictionary = (record_value as Dictionary).duplicate(true)
	var point_result := _point_from_record(record, context)
	if not bool(point_result.get("ok", false)):
		return point_result
	var migrated := reproject_normalized(point_result.get("point"), source_bounds, target_bounds)
	if not bool(migrated.get("ok", false)):
		return _with_context(migrated, context)
	var point: Vector2 = migrated.get("point")
	record["x"] = point.x
	record["y"] = point.y
	return {"ok": true, "record": record}


static func _point_from_record(record: Dictionary, context: String) -> Dictionary:
	var x_value: Variant = record.get("x", null)
	var y_value: Variant = record.get("y", null)
	if not _is_finite_number(x_value) or not _is_finite_number(y_value):
		return _failure("invalid_coordinate", "%s的 x/y 必须是有限数字。" % context)
	var point := Vector2(float(x_value), float(y_value))
	if point.x < -EPSILON or point.x > 1.0 + EPSILON or point.y < -EPSILON or point.y > 1.0 + EPSILON:
		return _failure("coordinate_out_of_bounds", "%s的 x/y 必须位于 0—1。" % context)
	return {"ok": true, "point": Vector2(clampf(point.x, 0.0, 1.0), clampf(point.y, 0.0, 1.0))}


static func _validate_bounds(bounds: Dictionary, label: String) -> Dictionary:
	for key in ["west", "east", "south", "north"]:
		if not _is_finite_number(bounds.get(key, null)):
			return _failure("invalid_%s_bounds" % label, "%s 投影边界 %s 不是有限数字。" % [label, key])
	if float(bounds.get("east")) - float(bounds.get("west")) <= EPSILON \
			or float(bounds.get("north")) - float(bounds.get("south")) <= EPSILON:
		return _failure("degenerate_%s_bounds" % label, "%s 投影边界必须具有正跨度。" % label)
	return {"ok": true}


static func _with_context(result: Dictionary, context: String) -> Dictionary:
	return _failure(
		str(result.get("error_code", "projection_failed")),
		"%s：%s" % [context, str(result.get("message", "坐标迁移失败。"))]
	)


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}


static func _is_finite_number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value))


static func _is_integer_number(value: Variant) -> bool:
	return _is_finite_number(value) and is_equal_approx(float(value), roundf(float(value)))
