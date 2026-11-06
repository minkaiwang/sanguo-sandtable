class_name FactionInfluenceLayer
extends Control

const FactionInfluenceCanvasScript = preload("res://src/faction_influence_canvas.gd")
const CACHE_SCALE := 0.5
const VIEW_ALPHA_ANCHORS := [
	Vector2(0.52, 1.00),
	Vector2(0.75, 0.94),
	Vector2(1.00, 0.82),
	Vector2(1.75, 0.66),
	Vector2(2.50, 0.58),
	Vector2(3.00, 0.54)
]

var _content_rect := Rect2()
var _viewport: SubViewport
var _canvas: FactionInfluenceCanvas
var _texture_rect: TextureRect
var _place_position_by_id: Dictionary = {}
var _signature := ""
var _build_count := 0
var _visible_in_session := true
var _view_zoom := 1.0
var _view_alpha := 0.82
var _last_state: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_cache_nodes()


func configure(content_rect: Rect2, places: Array, land_data: Dictionary) -> void:
	_content_rect = content_rect
	size = content_rect.end
	_place_position_by_id.clear()
	for place_value in places:
		if not (place_value is Dictionary):
			continue
		var place: Dictionary = place_value
		var place_id := str(place.get("id", "")).strip_edges()
		if place_id.is_empty():
			continue
		_place_position_by_id[place_id] = content_rect.position + Vector2(
			float(place.get("x", 0.0)),
			float(place.get("y", 0.0))
		) * content_rect.size
	_ensure_cache_nodes()
	_viewport.size = Vector2i(
		maxi(1, roundi(content_rect.size.x * CACHE_SCALE)),
		maxi(1, roundi(content_rect.size.y * CACHE_SCALE))
	)
	_canvas.configure(content_rect, land_data)
	# Canvas draws in map-world coordinates. Its offset must be scaled exactly like
	# the annotation cache; otherwise most influence cells land outside the cache.
	_canvas.position = -content_rect.position * CACHE_SCALE
	_canvas.scale = Vector2.ONE * CACHE_SCALE
	_texture_rect.position = content_rect.position
	_texture_rect.size = content_rect.size
	_signature = ""


func set_scenario_state(scenario_state: Dictionary) -> bool:
	_ensure_cache_nodes()
	var faction_color_by_id: Dictionary = {}
	var faction_marker_by_id: Dictionary = {}
	var signature_parts: Array[String] = []
	var faction_values: Array = scenario_state.get("factions", [])
	for index in range(faction_values.size()):
		var faction_value: Variant = faction_values[index]
		if not (faction_value is Dictionary):
			continue
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", "")).strip_edges()
		var color_hex := str(faction.get("color", "")).strip_edges()
		if faction_id.is_empty() or color_hex.is_empty():
			continue
		faction_color_by_id[faction_id] = color_hex
		faction_marker_by_id[faction_id] = str(index + 1)
		signature_parts.append("f:%s:%s:%d" % [faction_id, color_hex.to_lower(), index + 1])
	var ownership: Array = []
	for ownership_value in scenario_state.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			continue
		var record: Dictionary = ownership_value
		var place_id := str(record.get("place_id", "")).strip_edges()
		var faction_id := str(record.get("faction_id", "")).strip_edges()
		if place_id.is_empty() or faction_id.is_empty():
			continue
		ownership.append({"place_id": place_id, "faction_id": faction_id})
		signature_parts.append("o:%s:%s" % [place_id, faction_id])
	signature_parts.sort()
	var next_signature := "|".join(signature_parts)
	if next_signature == _signature:
		return false
	_signature = next_signature
	_build_count += 1
	_last_state = _canvas.rebuild(ownership, _place_position_by_id, faction_color_by_id, faction_marker_by_id)
	_last_state["ownership_count"] = ownership.size()
	_last_state["faction_count"] = faction_color_by_id.size()
	_last_state["build_count"] = _build_count
	_last_state["signature"] = _signature
	_last_state["visible"] = _visible_in_session
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	return true


func set_influence_visible(value: bool) -> void:
	_visible_in_session = value
	if _texture_rect != null:
		_texture_rect.visible = value
	_last_state["visible"] = value


func set_view_zoom(value: float) -> bool:
	var next_zoom := maxf(value, 0.01)
	var next_alpha := _alpha_for_zoom(next_zoom)
	var changed := not is_equal_approx(next_alpha, _view_alpha)
	_view_zoom = next_zoom
	_view_alpha = next_alpha
	_apply_view_alpha()
	_last_state["view_zoom"] = _view_zoom
	_last_state["view_alpha"] = _view_alpha
	return changed


func is_influence_visible() -> bool:
	return _visible_in_session


func get_cache_state() -> Dictionary:
	var result := _last_state.duplicate(true)
	result["build_count"] = _build_count
	result["signature"] = _signature
	result["visible"] = _visible_in_session
	result["view_zoom"] = _view_zoom
	result["view_alpha"] = _view_alpha
	result["texture_ready"] = _texture_rect != null and _texture_rect.texture != null
	result["update_mode"] = _viewport.render_target_update_mode if _viewport != null else -1
	return result


func _ensure_cache_nodes() -> void:
	if _viewport == null or _canvas == null or _texture_rect == null:
		_build_cache_nodes()


func _build_cache_nodes() -> void:
	if _viewport != null:
		return
	_viewport = SubViewport.new()
	_viewport.name = "FactionInfluenceViewport"
	_viewport.disable_3d = true
	_viewport.transparent_bg = true
	_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)

	_canvas = FactionInfluenceCanvasScript.new()
	_canvas.name = "FactionInfluenceCanvas"
	_viewport.add_child(_canvas)

	_texture_rect = TextureRect.new()
	_texture_rect.name = "FactionInfluenceTexture"
	_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_texture_rect.texture = _viewport.get_texture()
	_texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texture_rect.visible = _visible_in_session
	add_child(_texture_rect)
	_apply_view_alpha()


func _apply_view_alpha() -> void:
	if _texture_rect != null:
		_texture_rect.self_modulate = Color(1.0, 1.0, 1.0, _view_alpha)


func _alpha_for_zoom(value: float) -> float:
	if value <= (VIEW_ALPHA_ANCHORS[0] as Vector2).x:
		return (VIEW_ALPHA_ANCHORS[0] as Vector2).y
	for index in range(1, VIEW_ALPHA_ANCHORS.size()):
		var previous: Vector2 = VIEW_ALPHA_ANCHORS[index - 1]
		var current: Vector2 = VIEW_ALPHA_ANCHORS[index]
		if value <= current.x:
			var t := inverse_lerp(previous.x, current.x, value)
			return lerpf(previous.y, current.y, t)
	return (VIEW_ALPHA_ANCHORS[-1] as Vector2).y
