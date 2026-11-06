class_name PlayerStrokeLayer
extends Control

## 玩家手动画线的轻量绘制层。
## 这里不保存路线计算、距离、结果或史实依据；颜色与线型只由 stroke_type 派生。

const STROKE_TYPES := ["advance", "reinforcement", "retreat", "plan"]
const BASE_LINE_WIDTH_SCREEN := 3.0
const SELECTED_LINE_WIDTH_SCREEN := 7.0
const ARROW_LENGTH_SCREEN := 13.0
const ARROW_HALF_WIDTH_SCREEN := 6.0
const LABEL_MIN_ZOOM := 0.82
const HANDLE_RADIUS_SCREEN := 6.0
const HANDLE_ACTIVE_RADIUS_SCREEN := 8.0
const HANDLE_HIT_RADIUS_SCREEN := 12.0

var map_rect := Rect2()
var view_zoom := 1.0
var strokes: Array[Dictionary] = []
var selected_stroke_id := ""
var draft_points: Array[Vector2] = []
var draft_hover := Vector2(-1.0, -1.0)
var draft_type := "advance"
var strokes_visible := true
var draw_builds := 0
var point_edit_stroke_id := ""
var point_edit_points: Array[Vector2] = []
var point_edit_active_index := -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func configure(content_rect: Rect2) -> void:
	map_rect = content_rect
	size = content_rect.end
	queue_redraw()


func set_view_zoom(value: float) -> void:
	var next_zoom := maxf(value, 0.01)
	if is_equal_approx(view_zoom, next_zoom):
		return
	view_zoom = next_zoom
	queue_redraw()


func set_strokes(value: Array) -> void:
	strokes.clear()
	for stroke_value in value:
		if stroke_value is Dictionary:
			strokes.append((stroke_value as Dictionary).duplicate(true))
	if not selected_stroke_id.is_empty() and _find_stroke(selected_stroke_id).is_empty():
		selected_stroke_id = ""
	queue_redraw()


func set_strokes_visible(value: bool) -> void:
	if strokes_visible == value:
		return
	strokes_visible = value
	queue_redraw()


func set_selected_stroke(stroke_id: String) -> void:
	if selected_stroke_id == stroke_id:
		return
	selected_stroke_id = stroke_id
	queue_redraw()


func set_draft(points: Array, hover_normalized: Vector2, stroke_type: String) -> void:
	draft_points.clear()
	for point_value in points:
		if point_value is Vector2:
			draft_points.append(point_value)
	draft_hover = hover_normalized
	draft_type = stroke_type if STROKE_TYPES.has(stroke_type) else "advance"
	queue_redraw()


func clear_draft() -> void:
	if draft_points.is_empty() and draft_hover.x < 0.0:
		return
	draft_points.clear()
	draft_hover = Vector2(-1.0, -1.0)
	queue_redraw()


func set_point_edit_preview(stroke_id: String, points: Array, active_point_index := -1) -> void:
	point_edit_stroke_id = stroke_id
	point_edit_points.clear()
	for point_value in points:
		if point_value is Vector2:
			point_edit_points.append(point_value)
	point_edit_active_index = active_point_index
	queue_redraw()


func clear_point_edit_preview() -> void:
	if point_edit_stroke_id.is_empty() and point_edit_points.is_empty() and point_edit_active_index < 0:
		return
	point_edit_stroke_id = ""
	point_edit_points.clear()
	point_edit_active_index = -1
	queue_redraw()


func find_point_edit_handle_at_world(world_position: Vector2, tolerance_world := -1.0) -> int:
	if point_edit_stroke_id.is_empty() or point_edit_points.is_empty():
		return -1
	var resolved_tolerance := tolerance_world if tolerance_world >= 0.0 else HANDLE_HIT_RADIUS_SCREEN / view_zoom
	var best_index := -1
	var best_distance := resolved_tolerance
	for index in range(point_edit_points.size()):
		var distance := world_position.distance_to(_normalized_to_world(point_edit_points[index]))
		if distance <= best_distance:
			best_distance = distance
			best_index = index
	return best_index


func find_stroke_at_world(world_position: Vector2, tolerance_world: float) -> String:
	if not strokes_visible:
		return ""
	for index in range(strokes.size() - 1, -1, -1):
		var stroke: Dictionary = strokes[index]
		var points := _world_points(stroke.get("points", []))
		for segment_index in range(points.size() - 1):
			if _distance_to_segment(world_position, points[segment_index], points[segment_index + 1]) <= tolerance_world:
				return str(stroke.get("id", ""))
	return ""


func stroke_world_center(stroke_id: String) -> Vector2:
	var stroke := _find_stroke(stroke_id)
	var points := _world_points(stroke.get("points", []))
	if points.is_empty():
		return map_rect.get_center()
	var total_length := 0.0
	for index in range(points.size() - 1):
		total_length += points[index].distance_to(points[index + 1])
	if total_length <= 0.001:
		return points[0]
	var halfway := total_length * 0.5
	var walked := 0.0
	for index in range(points.size() - 1):
		var segment_length := points[index].distance_to(points[index + 1])
		if walked + segment_length >= halfway:
			return points[index].lerp(points[index + 1], (halfway - walked) / maxf(segment_length, 0.001))
		walked += segment_length
	return points[-1]


func get_draw_state() -> Dictionary:
	return {
		"draw_builds": draw_builds,
		"stroke_count": strokes.size(),
		"draft_point_count": draft_points.size(),
		"selected_stroke_id": selected_stroke_id,
		"visible": strokes_visible,
		"point_edit_stroke_id": point_edit_stroke_id,
		"point_edit_point_count": point_edit_points.size(),
		"point_edit_active_index": point_edit_active_index,
		"handle_radius_screen": HANDLE_RADIUS_SCREEN,
		"handle_hit_radius_screen": HANDLE_HIT_RADIUS_SCREEN
	}


func _draw() -> void:
	draw_builds += 1
	if not point_edit_stroke_id.is_empty():
		if strokes_visible:
			var editing_stroke := _find_stroke(point_edit_stroke_id)
			if not editing_stroke.is_empty():
				_draw_stroke(editing_stroke, true)
				_draw_point_edit_handles()
		return
	if strokes_visible:
		for stroke in strokes:
			_draw_stroke(stroke, str(stroke.get("id", "")) == selected_stroke_id)
	_draw_draft()


func _draw_stroke(stroke: Dictionary, selected: bool) -> void:
	var points := _world_points(stroke.get("points", []))
	if str(stroke.get("id", "")) == point_edit_stroke_id and not point_edit_points.is_empty():
		points = _world_points(point_edit_points)
	if points.size() < 2:
		return
	var stroke_type := str(stroke.get("stroke_type", "advance"))
	var color := _color_for_type(stroke_type)
	var width := BASE_LINE_WIDTH_SCREEN / view_zoom
	if selected:
		_draw_path(points, Color(0.98, 0.90, 0.62, 0.72), SELECTED_LINE_WIDTH_SCREEN / view_zoom, "solid")
	_draw_path(points, color, width, _pattern_for_type(stroke_type))
	_draw_arrowhead(points, color, width, stroke_type == "plan")
	if stroke_type == "reinforcement":
		_draw_start_diamond(points[0], color)
	var label := str(stroke.get("label", "")).strip_edges()
	if not label.is_empty() and (view_zoom >= LABEL_MIN_ZOOM or selected):
		_draw_label(label, _polyline_center(points), color)


func _draw_point_edit_handles() -> void:
	for index in range(point_edit_points.size()):
		var center := _normalized_to_world(point_edit_points[index])
		var active := index == point_edit_active_index
		var radius_screen := HANDLE_ACTIVE_RADIUS_SCREEN if active else HANDLE_RADIUS_SCREEN
		var radius := radius_screen / view_zoom
		var edge_width := (2.0 if active else 1.5) / view_zoom
		draw_circle(center, radius + 2.0 / view_zoom, Color(0.07, 0.08, 0.065, 0.90))
		if index == 0 or index == point_edit_points.size() - 1:
			draw_circle(center, radius, Color("f0ce72") if not active else Color("fff0a3"))
		else:
			draw_circle(center, radius, Color(0.12, 0.15, 0.12, 0.96))
		draw_arc(center, radius, 0.0, TAU, 24, Color("fff0a3") if active else Color("d8b85d"), edge_width, true)


func _draw_draft() -> void:
	if draft_points.is_empty():
		return
	var preview: Array[Vector2] = []
	for point in draft_points:
		preview.append(_normalized_to_world(point))
	if draft_hover.x >= 0.0 and draft_hover.y >= 0.0:
		var hover_world := _normalized_to_world(draft_hover)
		if preview[-1].distance_to(hover_world) > 0.5:
			preview.append(hover_world)
	var color := _color_for_type(draft_type)
	if preview.size() >= 2:
		_draw_path(preview, Color(color, 0.78), BASE_LINE_WIDTH_SCREEN / view_zoom, "dash")
		_draw_arrowhead(preview, Color(color, 0.78), BASE_LINE_WIDTH_SCREEN / view_zoom, true)
	for point in draft_points:
		draw_circle(_normalized_to_world(point), 4.2 / view_zoom, Color(0.98, 0.90, 0.64, 0.92))


func _draw_path(points: Array[Vector2], color: Color, width: float, pattern: String) -> void:
	if pattern == "solid":
		draw_polyline(PackedVector2Array(points), color, width, true)
		return
	var dash_screen := 11.0 if pattern == "dash" else 3.0
	var gap_screen := 7.0 if pattern == "dash" else 6.0
	var dash_world := dash_screen / view_zoom
	var gap_world := gap_screen / view_zoom
	for index in range(points.size() - 1):
		_draw_dashed_segment(points[index], points[index + 1], color, width, dash_world, gap_world)


func _draw_dashed_segment(start: Vector2, finish: Vector2, color: Color, width: float, dash: float, gap: float) -> void:
	var length := start.distance_to(finish)
	if length <= 0.001:
		return
	var direction := (finish - start) / length
	var cursor := 0.0
	while cursor < length:
		var segment_end := minf(cursor + dash, length)
		draw_line(start + direction * cursor, start + direction * segment_end, color, width, true)
		cursor += dash + gap


func _draw_arrowhead(points: Array[Vector2], color: Color, width: float, open_head: bool) -> void:
	var finish := points[-1]
	var previous := points[-2]
	var direction := (finish - previous).normalized()
	if direction.length_squared() <= 0.0001:
		return
	var normal := Vector2(-direction.y, direction.x)
	var base := finish - direction * (ARROW_LENGTH_SCREEN / view_zoom)
	var left := base + normal * (ARROW_HALF_WIDTH_SCREEN / view_zoom)
	var right := base - normal * (ARROW_HALF_WIDTH_SCREEN / view_zoom)
	if open_head:
		draw_line(finish, left, color, width, true)
		draw_line(finish, right, color, width, true)
	else:
		draw_colored_polygon(PackedVector2Array([finish, left, right]), color)


func _draw_start_diamond(center: Vector2, color: Color) -> void:
	var radius := 5.0 / view_zoom
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(0.0, -radius), center + Vector2(radius, 0.0),
		center + Vector2(0.0, radius), center + Vector2(-radius, 0.0)
	]), color)


func _draw_label(label: String, center: Vector2, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var font_size := maxi(10, roundi(14.0 / view_zoom))
	var offset := Vector2(8.0, -8.0) / view_zoom
	draw_string(font, center + offset, label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color("171712"))
	draw_string(font, center + offset + Vector2(-1.0, -1.0) / view_zoom, label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)


func _find_stroke(stroke_id: String) -> Dictionary:
	for stroke in strokes:
		if str(stroke.get("id", "")) == stroke_id:
			return stroke
	return {}


func _world_points(values: Variant) -> Array[Vector2]:
	var result: Array[Vector2] = []
	if not (values is Array):
		return result
	for value in values:
		if value is Dictionary:
			result.append(_normalized_to_world(Vector2(float(value.get("x", 0.5)), float(value.get("y", 0.5)))))
		elif value is Vector2:
			result.append(_normalized_to_world(value))
	return result


func _normalized_to_world(point: Vector2) -> Vector2:
	return map_rect.position + point * map_rect.size


func _polyline_center(points: Array[Vector2]) -> Vector2:
	if points.is_empty():
		return map_rect.get_center()
	return stroke_world_center_from_points(points)


func stroke_world_center_from_points(points: Array[Vector2]) -> Vector2:
	var total_length := 0.0
	for index in range(points.size() - 1):
		total_length += points[index].distance_to(points[index + 1])
	if total_length <= 0.001:
		return points[0]
	var halfway := total_length * 0.5
	var walked := 0.0
	for index in range(points.size() - 1):
		var segment_length := points[index].distance_to(points[index + 1])
		if walked + segment_length >= halfway:
			return points[index].lerp(points[index + 1], (halfway - walked) / maxf(segment_length, 0.001))
		walked += segment_length
	return points[-1]


func _distance_to_segment(point: Vector2, start: Vector2, finish: Vector2) -> float:
	var segment := finish - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.000001:
		return point.distance_to(start)
	var ratio := clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(start + segment * ratio)


func _color_for_type(stroke_type: String) -> Color:
	match stroke_type:
		"reinforcement":
			return Color("4f9b72")
		"retreat":
			return Color("587d91")
		"plan":
			return Color("c79a3b")
		_:
			return Color("b74c3b")


func _pattern_for_type(stroke_type: String) -> String:
	match stroke_type:
		"retreat":
			return "dash"
		"plan":
			return "dot"
		_:
			return "solid"
