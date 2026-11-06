class_name MapPresentationPolicy
extends RefCounted


static func build_frame(content_rect: Rect2, bleed: Vector2, fade_width: float) -> Dictionary:
	if content_rect.size.x <= 0.0 or content_rect.size.y <= 0.0:
		return _failure("invalid_content_rect", "地图地理内容区必须具有正尺寸。")
	if bleed.x < 0.0 or bleed.y < 0.0:
		return _failure("invalid_bleed", "地图视觉延伸区不得为负数。")
	if not is_finite(fade_width) or fade_width <= 0.0 \
			or fade_width * 2.0 >= minf(content_rect.size.x, content_rect.size.y):
		return _failure("invalid_fade_width", "地图柔边宽度必须为正数，且不得吞没地理内容区。")
	var visual_rect := Rect2(
		content_rect.position - bleed,
		content_rect.size + bleed * 2.0
	)
	return {
		"ok": true,
		"content_rect": content_rect,
		"interaction_rect": content_rect,
		"visual_rect": visual_rect,
		"bleed": bleed,
		"fade_width": fade_width,
		"hard_border": false,
	}


static func edge_opacity(world_point: Vector2, content_rect: Rect2, fade_width: float) -> float:
	if fade_width <= 0.0 or not content_rect.has_point(world_point):
		return 0.0
	var distance_left := world_point.x - content_rect.position.x
	var distance_right := content_rect.end.x - world_point.x
	var distance_top := world_point.y - content_rect.position.y
	var distance_bottom := content_rect.end.y - world_point.y
	var horizontal := _smoothstep01(minf(distance_left, distance_right) / fade_width)
	var vertical := _smoothstep01(minf(distance_top, distance_bottom) / fade_width)
	return horizontal * vertical


static func fit_rect(
	viewport_size: Vector2,
	target_rect: Rect2,
	margin_screen: float,
	zoom_limits: Vector2
) -> Dictionary:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return _failure("invalid_viewport_size", "地图视口必须具有正尺寸。")
	if target_rect.size.x <= 0.0 or target_rect.size.y <= 0.0:
		return _failure("invalid_target_rect", "归位目标区必须具有正尺寸。")
	if not is_finite(margin_screen) or margin_screen < 0.0 \
			or viewport_size.x <= margin_screen * 2.0 \
			or viewport_size.y <= margin_screen * 2.0:
		return _failure("invalid_margin", "归位留白必须能被当前视口容纳。")
	if zoom_limits.x <= 0.0 or zoom_limits.y < zoom_limits.x:
		return _failure("invalid_zoom_limits", "地图缩放上下限无效。")
	var available := viewport_size - Vector2.ONE * margin_screen * 2.0
	var raw_zoom := minf(
		available.x / target_rect.size.x,
		available.y / target_rect.size.y
	)
	var zoom := clampf(raw_zoom, zoom_limits.x, zoom_limits.y)
	var pan := viewport_size * 0.5 - target_rect.get_center() * zoom
	var visible_world_rect := Rect2(-pan / zoom, viewport_size / zoom)
	var target_screen_rect := world_rect_to_screen(target_rect, {"x": pan.x, "y": pan.y, "zoom": zoom})
	return {
		"ok": true,
		"x": pan.x,
		"y": pan.y,
		"zoom": zoom,
		"raw_zoom": raw_zoom,
		"target_rect": target_rect,
		"target_screen_rect": target_screen_rect,
		"visible_world_rect": visible_world_rect,
		"target_fits_margin": raw_zoom >= zoom_limits.x and raw_zoom <= zoom_limits.y,
	}


static func build_focus_state(
	viewport_size: Vector2,
	content_rect: Rect2,
	focus_world: Vector2,
	zoom: float,
	screen_anchor := Vector2(0.5, 0.5)
) -> Dictionary:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return _failure("invalid_viewport_size", "地图视口必须具有正尺寸。")
	if content_rect.size.x <= 0.0 or content_rect.size.y <= 0.0:
		return _failure("invalid_content_rect", "地图地理内容区必须具有正尺寸。")
	if not is_finite(focus_world.x) or not is_finite(focus_world.y):
		return _failure("invalid_focus", "地图聚焦点必须是有效坐标。")
	if not is_finite(zoom) or zoom <= 0.0:
		return _failure("invalid_zoom", "地图聚焦倍率必须为正数。")
	if (
		not is_finite(screen_anchor.x)
		or not is_finite(screen_anchor.y)
		or screen_anchor.x < 0.0
		or screen_anchor.x > 1.0
		or screen_anchor.y < 0.0
		or screen_anchor.y > 1.0
	):
		return _failure("invalid_screen_anchor", "地图聚焦锚点必须位于视口内。")
	var bounded_focus := Vector2(
		clampf(focus_world.x, content_rect.position.x, content_rect.end.x),
		clampf(focus_world.y, content_rect.position.y, content_rect.end.y)
	)
	var requested_pan := viewport_size * screen_anchor - bounded_focus * zoom
	var pan := Vector2(
		_constrain_focus_axis(
			requested_pan.x,
			viewport_size.x,
			content_rect.position.x,
			content_rect.end.x,
			zoom
		),
		_constrain_focus_axis(
			requested_pan.y,
			viewport_size.y,
			content_rect.position.y,
			content_rect.end.y,
			zoom
		)
	)
	var content_screen_rect := world_rect_to_screen(
		content_rect,
		{"x": pan.x, "y": pan.y, "zoom": zoom}
	)
	return {
		"ok": true,
		"x": pan.x,
		"y": pan.y,
		"zoom": zoom,
		"requested_pan": requested_pan,
		"focus_world": bounded_focus,
		"focus_screen": pan + bounded_focus * zoom,
		"content_screen_rect": content_screen_rect,
		"visible_world_rect": Rect2(-pan / zoom, viewport_size / zoom),
		"x_constrained": not is_equal_approx(pan.x, requested_pan.x),
		"y_constrained": not is_equal_approx(pan.y, requested_pan.y),
		"free_pan_changed": false,
	}


static func build_home_states(
	viewport_size: Vector2,
	content_rect: Rect2,
	candidate_bounds: Dictionary,
	legacy_bounds: Dictionary,
	margin_screen: float,
	zoom_limits: Vector2
) -> Dictionary:
	var candidate_result := _decode_geographic_bounds(candidate_bounds, "候选投影")
	if not bool(candidate_result.get("ok", false)):
		return candidate_result
	var legacy_result := _decode_geographic_bounds(legacy_bounds, "汉地战区")
	if not bool(legacy_result.get("ok", false)):
		return legacy_result
	var candidate: Dictionary = candidate_result.get("bounds", {})
	var legacy: Dictionary = legacy_result.get("bounds", {})
	if float(legacy.get("min_lon", 0.0)) < float(candidate.get("min_lon", 0.0)) \
			or float(legacy.get("max_lon", 0.0)) > float(candidate.get("max_lon", 0.0)) \
			or float(legacy.get("min_lat", 0.0)) < float(candidate.get("min_lat", 0.0)) \
			or float(legacy.get("max_lat", 0.0)) > float(candidate.get("max_lat", 0.0)):
		return _failure("theater_outside_candidate", "汉地战区必须完整落在候选天下范围内。")
	var lon_span := float(candidate.get("max_lon")) - float(candidate.get("min_lon"))
	var lat_span := float(candidate.get("max_lat")) - float(candidate.get("min_lat"))
	var normalized_min := Vector2(
		(float(legacy.get("min_lon")) - float(candidate.get("min_lon"))) / lon_span,
		(float(candidate.get("max_lat")) - float(legacy.get("max_lat"))) / lat_span
	)
	var normalized_max := Vector2(
		(float(legacy.get("max_lon")) - float(candidate.get("min_lon"))) / lon_span,
		(float(candidate.get("max_lat")) - float(legacy.get("min_lat"))) / lat_span
	)
	var theater_rect := Rect2(
		content_rect.position + normalized_min * content_rect.size,
		(normalized_max - normalized_min) * content_rect.size
	)
	var overview := fit_rect(viewport_size, content_rect, margin_screen, zoom_limits)
	if not bool(overview.get("ok", false)):
		return overview
	var theater := fit_rect(viewport_size, theater_rect, margin_screen, zoom_limits)
	if not bool(theater.get("ok", false)):
		return theater
	return {
		"ok": true,
		"world_overview": overview,
		"han_theater": theater,
		"han_theater_normalized_rect": Rect2(normalized_min, normalized_max - normalized_min),
	}


static func world_rect_to_screen(world_rect: Rect2, camera: Dictionary) -> Rect2:
	var zoom := float(camera.get("zoom", 0.0))
	var pan := Vector2(float(camera.get("x", 0.0)), float(camera.get("y", 0.0)))
	return Rect2(pan + world_rect.position * zoom, world_rect.size * zoom)


static func _decode_geographic_bounds(value: Variant, label: String) -> Dictionary:
	if not value is Dictionary:
		return _failure("bounds_not_dictionary", "%s经纬范围必须是对象。" % label)
	var bounds: Dictionary = value
	for key in ["min_lon", "max_lon", "min_lat", "max_lat"]:
		var coordinate: Variant = bounds.get(key, null)
		if not (typeof(coordinate) in [TYPE_INT, TYPE_FLOAT]) or not is_finite(float(coordinate)):
			return _failure("invalid_bounds_coordinate", "%s缺少有效坐标：%s。" % [label, key])
	if float(bounds.get("min_lon")) >= float(bounds.get("max_lon")) \
			or float(bounds.get("min_lat")) >= float(bounds.get("max_lat")):
		return _failure("reversed_bounds", "%s经纬范围方向无效。" % label)
	return {
		"ok": true,
		"bounds": {
			"min_lon": float(bounds.get("min_lon")),
			"max_lon": float(bounds.get("max_lon")),
			"min_lat": float(bounds.get("min_lat")),
			"max_lat": float(bounds.get("max_lat")),
		}
	}


static func _smoothstep01(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


static func _constrain_focus_axis(
	requested_pan: float,
	viewport_extent: float,
	content_start: float,
	content_end: float,
	zoom: float
) -> float:
	var content_extent := (content_end - content_start) * zoom
	if content_extent <= viewport_extent:
		return (viewport_extent - content_extent) * 0.5 - content_start * zoom
	return clampf(
		requested_pan,
		viewport_extent - content_end * zoom,
		-content_start * zoom
	)


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
