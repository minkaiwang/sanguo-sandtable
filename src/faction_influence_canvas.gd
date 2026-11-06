class_name FactionInfluenceCanvas
extends Control

const DEFAULT_CELL_SIZE := 18.0
# A7: the influence layer describes a force's reach, not a surveyed border.
# Alpha therefore tapers all the way to zero at the radius instead of keeping a
# non-zero floor that creates a hard circular edge.
const STYLE_VERSION := "a7_city_centered_wash_v1"
const MIN_ALPHA := 0.0
const MAX_ALPHA := 0.50
const ALPHA_DRAW_EPSILON := 0.0015
const SOFT_EDGE_ALPHA_THRESHOLD := 0.060
const COLOR_WEIGHT_EXPONENT := 6.0
const CITY_INFLUENCE_RADIUS := 650.0

var content_rect := Rect2()
var cell_size := DEFAULT_CELL_SIZE
var _land_cells := PackedVector2Array()
var _influence_cells: Array[Dictionary] = []
var _ownership_markers: Array[Dictionary] = []
var _land_mask_build_usec := 0
var _influence_build_usec := 0
var _alpha_min_observed := 0.0
var _alpha_max_observed := 0.0
var _alpha_mean_observed := 0.0
var _soft_edge_cell_count := 0
var _mixed_cell_count := 0
var _dominant_cell_count := 0


func configure(next_content_rect: Rect2, land_data: Dictionary) -> void:
	content_rect = next_content_rect
	position = -content_rect.position
	size = content_rect.size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_land_cells(land_data)


func rebuild(
	ownership: Array,
	place_position_by_id: Dictionary,
	faction_color_by_id: Dictionary,
	faction_marker_by_id: Dictionary = {}
) -> Dictionary:
	var started_usec := Time.get_ticks_usec()
	var centers: Array[Dictionary] = []
	for ownership_value in ownership:
		if not (ownership_value is Dictionary):
			continue
		var record: Dictionary = ownership_value
		var place_id := str(record.get("place_id", "")).strip_edges()
		var faction_id := str(record.get("faction_id", "")).strip_edges()
		if not place_position_by_id.has(place_id) or not faction_color_by_id.has(faction_id):
			continue
		var center: Vector2 = place_position_by_id[place_id]
		# Keep the player's hue but lift it toward a parchment-friendly wash so
		# dark faction swatches do not read as soot over the terrain.
		var color := Color(str(faction_color_by_id[faction_id])).lightened(0.08)
		color.a = 1.0
		centers.append({
			"place_id": place_id,
			"faction_id": faction_id,
			"center": center,
			"color": color,
			"marker": str(faction_marker_by_id.get(faction_id, "")),
			"radius": CITY_INFLUENCE_RADIUS
		})

	_influence_cells.clear()
	_ownership_markers.clear()
	_alpha_min_observed = 0.0
	_alpha_max_observed = 0.0
	_alpha_mean_observed = 0.0
	_soft_edge_cell_count = 0
	_mixed_cell_count = 0
	_dominant_cell_count = 0
	for center_value in centers:
		var center_record: Dictionary = center_value
		var marker := str(center_record.get("marker", "")).strip_edges()
		if marker.is_empty():
			continue
		_ownership_markers.append({
			"place_id": str(center_record.get("place_id", "")),
			"faction_id": str(center_record.get("faction_id", "")),
			"marker": marker,
			"position": center_record.get("center", Vector2.ZERO),
			"color": center_record.get("color", Color.WHITE)
		})
	if not centers.is_empty():
		for cell in _land_cells:
			var weight_by_faction: Dictionary = {}
			var color_by_faction: Dictionary = {}
			for center_value in centers:
				var center_record: Dictionary = center_value
				var radius := float(center_record.get("radius", 250.0))
				var distance := cell.distance_to(center_record.get("center", Vector2.ZERO))
				if distance >= radius:
					continue
				var normalized := 1.0 - distance / radius
				var weight := normalized * normalized
				var faction_id := str(center_record.get("faction_id", ""))
				weight_by_faction[faction_id] = maxf(float(weight_by_faction.get(faction_id, 0.0)), weight)
				color_by_faction[faction_id] = center_record.get("color", Color.WHITE)
			if weight_by_faction.is_empty():
				continue
			var dominant_weight := 0.0
			var dominant_faction_id := ""
			for faction_id_value in weight_by_faction:
				var faction_id := str(faction_id_value)
				var weight := float(weight_by_faction[faction_id])
				if weight > dominant_weight:
					dominant_weight = weight
					dominant_faction_id = faction_id
			if dominant_weight <= 0.0:
				continue

			# Sharpen the color weights while keeping a continuous blend at
			# contested areas. Unlike winner-takes-all this does not create
			# artificial polygon borders when the dominant faction changes.
			var color_weight_total := 0.0
			var mixed := Color(0, 0, 0, 1)
			var faction_ids: Array = weight_by_faction.keys()
			faction_ids.sort()
			for faction_id_value in faction_ids:
				var faction_id := str(faction_id_value)
				var weight := float(weight_by_faction[faction_id])
				var color_weight := pow(weight, COLOR_WEIGHT_EXPONENT)
				color_weight_total += color_weight
				mixed += (color_by_faction[faction_id] as Color) * color_weight
			if color_weight_total <= 0.0:
				continue
			mixed /= color_weight_total
			var noise := 0.94 + 0.12 * _paper_noise(cell)
			mixed.a = clampf(dominant_weight * MAX_ALPHA * noise, MIN_ALPHA, MAX_ALPHA)
			if mixed.a < ALPHA_DRAW_EPSILON:
				continue
			if _influence_cells.is_empty():
				_alpha_min_observed = mixed.a
				_alpha_max_observed = mixed.a
			else:
				_alpha_min_observed = minf(_alpha_min_observed, mixed.a)
				_alpha_max_observed = maxf(_alpha_max_observed, mixed.a)
			_alpha_mean_observed += mixed.a
			if mixed.a < SOFT_EDGE_ALPHA_THRESHOLD:
				_soft_edge_cell_count += 1
			if weight_by_faction.size() > 1:
				_mixed_cell_count += 1
			_dominant_cell_count += 1
			_influence_cells.append({
				"position": cell,
				"color": mixed,
				"dominant_faction_id": dominant_faction_id
			})
	if not _influence_cells.is_empty():
		_alpha_mean_observed /= float(_influence_cells.size())
	_influence_build_usec = Time.get_ticks_usec() - started_usec
	queue_redraw()
	return get_build_state()


func clear_influence() -> void:
	_influence_cells.clear()
	_ownership_markers.clear()
	_influence_build_usec = 0
	_alpha_min_observed = 0.0
	_alpha_max_observed = 0.0
	_alpha_mean_observed = 0.0
	_soft_edge_cell_count = 0
	_mixed_cell_count = 0
	_dominant_cell_count = 0
	queue_redraw()


func get_build_state() -> Dictionary:
	return {
		"land_cell_count": _land_cells.size(),
		"influence_cell_count": _influence_cells.size(),
		"land_mask_ms": float(_land_mask_build_usec) / 1000.0,
		"last_rebuild_ms": float(_influence_build_usec) / 1000.0,
		"cell_size": cell_size,
		"style_version": STYLE_VERSION,
		"color_model": "continuous_dominant_weighted_mix",
		"alpha_model": "dominant_weight_soft_taper",
		"radius": CITY_INFLUENCE_RADIUS,
		"alpha_min": MIN_ALPHA,
		"alpha_max": MAX_ALPHA,
		"alpha_min_observed": _alpha_min_observed,
		"alpha_max_observed": _alpha_max_observed,
		"alpha_mean_observed": _alpha_mean_observed,
		"soft_edge_cell_count": _soft_edge_cell_count,
		"mixed_cell_count": _mixed_cell_count,
		"dominant_cell_count": _dominant_cell_count,
		"outer_boundary": false,
		"ownership_marker_count": _ownership_markers.size(),
		"ownership_markers": _ownership_markers.duplicate(true)
	}


func _draw() -> void:
	var half := Vector2.ONE * cell_size * 0.52
	for cell_value in _influence_cells:
		var cell: Dictionary = cell_value
		var center: Vector2 = cell.get("position", Vector2.ZERO)
		var color: Color = cell.get("color", Color.TRANSPARENT)
		draw_rect(Rect2(center - half, half * 2.0), color, true)


func _build_land_cells(land_data: Dictionary) -> void:
	var started_usec := Time.get_ticks_usec()
	_land_cells = PackedVector2Array()
	var polygons: Array[Dictionary] = []
	for polygon_value in land_data.get("polygons", []):
		if not (polygon_value is Array) or (polygon_value as Array).size() < 3:
			continue
		var points := PackedVector2Array()
		for point_value in polygon_value:
			if not (point_value is Array) or (point_value as Array).size() < 2:
				continue
			var normalized := Vector2(float(point_value[0]), float(point_value[1]))
			points.append(content_rect.position + normalized * content_rect.size)
		if points.size() < 3:
			continue
		polygons.append({"points": points, "bounds": _bounds_for_points(points)})
	if polygons.is_empty():
		_land_mask_build_usec = Time.get_ticks_usec() - started_usec
		return
	var columns := ceili(content_rect.size.x / cell_size)
	var rows := ceili(content_rect.size.y / cell_size)
	for row in range(rows):
		for column in range(columns):
			var point := content_rect.position + Vector2(
				(float(column) + 0.5) * cell_size,
				(float(row) + 0.5) * cell_size
			)
			if _point_is_on_land(point, polygons):
				_land_cells.append(point)
	_land_mask_build_usec = Time.get_ticks_usec() - started_usec


func _point_is_on_land(point: Vector2, polygons: Array[Dictionary]) -> bool:
	for polygon in polygons:
		var bounds: Rect2 = polygon.get("bounds", Rect2())
		if not bounds.has_point(point):
			continue
		var points: PackedVector2Array = polygon.get("points", PackedVector2Array())
		if Geometry2D.is_point_in_polygon(point, points):
			return true
	return false


func _bounds_for_points(points: PackedVector2Array) -> Rect2:
	var minimum := points[0]
	var maximum := points[0]
	for point in points:
		minimum.x = minf(minimum.x, point.x)
		minimum.y = minf(minimum.y, point.y)
		maximum.x = maxf(maximum.x, point.x)
		maximum.y = maxf(maximum.y, point.y)
	return Rect2(minimum, maximum - minimum)


func _paper_noise(point: Vector2) -> float:
	var x := int(floor(point.x / cell_size))
	var y := int(floor(point.y / cell_size))
	var value := (x * 73856093) ^ (y * 19349663) ^ 83492791
	return float(abs(value) % 1000) / 999.0
