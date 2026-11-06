class_name MapCanvas
extends Control

const MapGeographicContextPolicyScript = preload("res://src/map_geographic_context_policy.gd")
const ReliefTexture := preload("res://assets/map_relief.png")
const TERRAIN_RELIEF_LR_PATH := "res://assets/terrain_candidates/map_relief_lr_v1.png"
const SurfaceTexture := preload("res://assets/map_silk_paper.png")
const PlayableTheaterTexture := preload("res://assets/map_playable_theater_v1.png")
const MountainHachureAtlas: Texture2D = preload("res://assets/map_mountain_hachures_v1.png")
const MapFont := preload("res://assets/fonts/Source_Han_Serif.otf")
const PASS_PAPER_INK_PATH := "res://assets/map/place_symbols/pass_paper_ink_v1.svg"
const MAP_CONTENT_RECT := Rect2(Vector2.ZERO, Vector2(1500, 1075))
const MAP_BACKDROP_COLOR := Color("#B8C1B2")
const MAP_EDGE_FADE_WIDTH := 64.0
const MAP_EDGE_FADE_STEPS := 32
const MAP_DAYLIGHT_WASH_COLOR := Color("#F2E8C4")
const MAP_DAYLIGHT_WASH_ALPHA := 0.68
const TERRAIN_HIERARCHY_STYLE_VERSION := 1
const RELIEF_BASE_TINT := Color(1.0, 0.98, 0.88, 0.50)
const RELIEF_DETAIL_TINT := Color(0.92, 0.89, 0.72, 0.42)
const COAST_OUTER_COLOR := Color(0.32, 0.35, 0.30, 0.48)
const COAST_INNER_COLOR := Color(0.74, 0.67, 0.43, 0.42)
const COAST_OUTER_WIDTH := 1.8
const COAST_INNER_WIDTH := 0.75
const LAKE_FILL_COLOR := Color(0.58, 0.69, 0.64, 0.72)
const LAKE_OUTLINE_COLOR := Color(0.30, 0.46, 0.44, 0.50)
const LAKE_OUTLINE_WIDTH := 0.8
const RIVER_OUTER_COLOR := Color(0.30, 0.46, 0.45, 0.50)
const RIVER_INNER_COLOR := Color(0.68, 0.80, 0.75, 0.76)
const RIVER_MAJOR_OUTER_WIDTH := 2.6
const RIVER_MEDIUM_OUTER_WIDTH := 1.55
const RIVER_MINOR_OUTER_WIDTH := 0.9
const RIVER_MAJOR_INNER_WIDTH := 0.95
const RIVER_MEDIUM_INNER_WIDTH := 0.58
const RIVER_MINOR_INNER_WIDTH := 0.34
const PLACE_LABEL_INK_COLOR := Color("#1B140D")
const PLACE_LABEL_HALO_COLOR := Color("#FFF4D7")
const PLACE_LABEL_OUTLINE_PX := 2
const STRATEGIC_BOARD_STYLE_VERSION := 4
const STRATEGIC_BOARD_STYLE_ID := "original_ink_sandtable"
const MAP_PROJECTION_BOUNDS := {
	"west": 93.5,
	"east": 130.5,
	"south": 18.0,
	"north": 44.5,
}

const OVERVIEW_ZOOM_THRESHOLD := 0.66
const FAR_ZOOM_THRESHOLD := 0.88
const NEAR_ZOOM_THRESHOLD := 1.40
const NEAR_HACHURE_MIN_ZOOM := NEAR_ZOOM_THRESHOLD
const NEAR_HACHURE_FULL_DETAIL_ZOOM := 1.66
const NEAR_HACHURE_ATLAS_GRID := Vector2i(2, 2)
const NEAR_HACHURE_STYLE_VERSION := 3
const NEAR_HACHURE_DRAW_EPSILON := 0.0001
const MOUNTAIN_GROWTH_REFERENCE_ZOOM := NEAR_ZOOM_THRESHOLD
const MOUNTAIN_GROWTH_EXPONENT := 0.40
const MOUNTAIN_GROWTH_MAX := 1.35
# 每档布局从最密集边界起算，并在档内关键倍率同时验算，避免固定偏移随缩放重新相撞。
const LABEL_LAYOUT_ZOOM := {"overview": 0.52, "far": 0.66, "middle": 0.88, "near": 1.40}
const LABEL_LAYOUT_SAMPLES := {
	"overview": [0.52, 0.659],
	"far": [0.66, 0.75, 0.879],
	"middle": [0.88, 1.0, 1.399],
	"near": [1.40, 1.75, 2.50, 3.00]
}
const LABEL_HALO_MARGIN_SCREEN := 3.0
const LABEL_SYMBOL_CLEARANCE_SCREEN := 9.0
const LABEL_COLLISION_EPSILON := 0.05
const PLACE_SYMBOL_STYLE_VERSION := 3
const FAR_CITY_SYMBOL_STYLE_VERSION := 5
const CITY_HIERARCHY_STYLE_VERSION := 2
const ROUTE_HIERARCHY_STYLE_VERSION := 1
const STRATEGIC_NODE_STYLE_VERSION := 1
const MOUNTAIN_RIDGE_STYLE_VERSION := 3
const MOUNTAIN_MEMORY_TIER := 1
const MOUNTAIN_NEAR_RIDGE_WIDTH_SCREEN := 64.0
const MOUNTAIN_NEAR_RIDGE_HEIGHT_SCREEN := 10.0
const MOUNTAIN_NEAR_RIDGE_ALPHA := 0.065
const PASS_SYMBOL_REVIEW_STYLE_VERSION := 4
const PASS_SYMBOL_VARIANT_V3 := "programmatic_v3"
const PASS_SYMBOL_VARIANT_PAPER_INK_V1 := "pass_paper_ink_v1"
const TERRAIN_RELIEF_VARIANT_LR_V1 := "relief_lr_v1"
const TERRAIN_RELIEF_VARIANT_HR_V1 := "relief_hr_v1"
const TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1 := "classic_daylight_v1"
const TERRAIN_VISUAL_PROFILE_ANTIQUE_TOPOGRAPHIC_V1 := "antique_topographic_v1"
const TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1 := "jade_pixel_v1"
const TERRAIN_VISUAL_PROFILE_STYLE_VERSION := 2
const PASS_SYMBOL_REVIEW_DISPLAY_PX := 18.0
const SEMANTIC_RENDER_STYLE_VERSION := 2
const GEOGRAPHIC_ANNOTATION_STYLE_VERSION := 1
const STRATEGIC_PLACE_IDS := {
	"wuwei": true, "changan": true, "luoyang": true, "ye": true,
	"guangzong": true, "zhuo": true, "xuchang": true,
	"xiapi": true, "shouchun": true, "moling": true, "xiangyang": true,
	"jiangling": true, "hanzhong": true, "chengdu": true, "changsha": true,
	"jiaozhi": true
}
const OVERVIEW_PLACE_IDS := {
	"wuwei": true, "changan": true, "luoyang": true, "ye": true,
	"zhuo": true, "xuchang": true, "xiapi": true, "moling": true,
	"xiangyang": true, "hanzhong": true, "chengdu": true,
	"changsha": true, "jiaozhi": true
}
const REGIONAL_PLACE_IDS := {
	"tianshui": true, "jinyang": true, "ji": true, "beihai": true,
	"chenliu": true, "luyang": true, "wan": true, "lujiang": true, "wu": true,
	"shangyong": true, "zitong": true, "chaisang": true, "wuling": true,
	"lingling": true, "yunnan": true
}
const STRATEGIC_ROUTE_KEYS := {
	"wuwei|tianshui": true, "tianshui|changan": true,
	"changan|luoyang": true, "changan|hanzhong": true,
	"luoyang|ye": true, "luoyang|chenliu": true,
	"luoyang|luyang": true, "luyang|wan": true,
	"ye|guangzong": true, "guangzong|zhuo": true, "zhuo|ji": true,
	"ji|beiping": true, "chenliu|xuchang": true,
	"xuchang|xiaopei": true, "xiaopei|xiapi": true,
	"xiapi|shouchun": true, "shouchun|moling": true,
	"wan|xinye": true, "xinye|xiangyang": true, "xiangyang|jiangling": true,
	"jiangling|changsha": true, "jiangling|fankou": true,
	"fankou|chaisang": true,
	"chaisang|moling": true, "hanzhong|zitong": true,
	"zitong|chengdu": true
}
const PLACE_LABEL_OFFSETS := {
	"ji": Vector2(-30, -9), "zhuo": Vector2(8, 16),
	"guangzong": Vector2(8, -8), "pingyuan": Vector2(8, 15),
	"nanpi": Vector2(8, -8), "puyang": Vector2(8, -8),
	"chenliu": Vector2(8, 15), "moling": Vector2(8, -8),
	"changshe_battlefield": Vector2(-58, 30), "luyang": Vector2(-52, -12),
	"wu": Vector2(8, 15), "chaisang": Vector2(8, -8),
	"hulao_pass": Vector2(-58, -10), "tongguan_pass": Vector2(8, -10),
	"yangping_pass": Vector2(-58, -10), "ruxukou_water_gate": Vector2(8, -10)
}
const PROVINCE_LABELS := [
	{"name": "凉州", "point": Vector2(0.274054, 0.259245)},
	{"name": "并州", "point": Vector2(0.497838, 0.243019)},
	{"name": "幽州", "point": Vector2(0.615946, 0.194340)},
	{"name": "冀州", "point": Vector2(0.572432, 0.291698)},
	{"name": "青州", "point": Vector2(0.665676, 0.316038)},
	{"name": "司隶", "point": Vector2(0.454324, 0.380943)},
	{"name": "兖州", "point": Vector2(0.553784, 0.389057)},
	{"name": "豫州", "point": Vector2(0.553784, 0.421509)},
	{"name": "徐州", "point": Vector2(0.640811, 0.405283)},
	{"name": "荆州", "point": Vector2(0.472973, 0.543208)},
	{"name": "益州", "point": Vector2(0.317568, 0.551321)},
	{"name": "扬州", "point": Vector2(0.615946, 0.535094)},
	{"name": "交州", "point": Vector2(0.410811, 0.819057)}
]

var places: Array = []
var routes: Array = []
var land_data: Dictionary = {}
var river_data: Dictionary = {}
var lake_data: Dictionary = {}
var mountains: Array = []
var geographic_context_records: Array[Dictionary] = []
var historical_context_records: Array = []
var historical_context_visibility_by_layer: Dictionary = {}
var world_size := MAP_CONTENT_RECT.size
var draw_base_layers := true
var draw_annotation_layers := true
var draw_structural_annotations := true
var draw_semantic_annotations := true
var show_strategic_corridors := true
var show_historical_context := false
var show_near_hachures := true
var pass_symbol_variant := PASS_SYMBOL_VARIANT_V3
var terrain_relief_variant := TERRAIN_RELIEF_VARIANT_HR_V1
var terrain_visual_profile := TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1
var redraw_count := 0
var view_zoom := 0.8
var semantic_visible_world_rect := Rect2()
var _place_display_tiers: Dictionary = {}
var _place_label_layout_cache: Dictionary = {}
var _place_label_layout_builds := 0
var _historical_context_layout_cache: Dictionary = {}
var _pass_paper_ink_texture: ImageTexture
var _terrain_relief_texture: Texture2D = ReliefTexture
var _screen_space_draw_active := false


func _ready() -> void:
	custom_minimum_size = world_size
	size = world_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _load_pass_paper_ink_texture() -> void:
	if _pass_paper_ink_texture != null:
		return
	var svg_text := FileAccess.get_file_as_string(PASS_PAPER_INK_PATH)
	if svg_text.is_empty():
		push_warning("关隘纸墨候选运行资源缺失；保持程序化 V3")
		return
	var image := Image.new()
	if image.load_svg_from_string(svg_text) != OK:
		push_warning("关隘纸墨候选无法解析；保持程序化 V3")
		return
	_pass_paper_ink_texture = ImageTexture.create_from_image(image)


func set_data(
	places_value: Array,
	routes_value: Array,
	land_value: Dictionary = {},
	river_value: Dictionary = {},
	lake_value: Dictionary = {},
	mountains_value: Array = [],
	geographic_context_value: Array = []
) -> void:
	places = places_value
	routes = routes_value
	_compile_place_display_tiers()
	_place_label_layout_cache.clear()
	_place_label_layout_builds = 0
	_historical_context_layout_cache.clear()
	land_data = land_value
	river_data = river_value
	lake_data = lake_value
	mountains = mountains_value
	geographic_context_records.clear()
	for record_value in geographic_context_value:
		if record_value is Dictionary:
			geographic_context_records.append((record_value as Dictionary).duplicate(true))
	if draw_annotation_layers:
		_ensure_place_label_layout()
	queue_redraw()


func set_view_zoom(value: float) -> bool:
	var next_zoom := maxf(value, 0.1)
	if is_equal_approx(view_zoom, next_zoom):
		return false
	view_zoom = next_zoom
	_historical_context_layout_cache.clear()
	if draw_annotation_layers:
		_ensure_place_label_layout()
	queue_redraw()
	return true


func set_semantic_visible_world_rect(value: Rect2) -> bool:
	if semantic_visible_world_rect.position.is_equal_approx(value.position) \
			and semantic_visible_world_rect.size.is_equal_approx(value.size):
		return false
	if semantic_visible_world_rect.size.x > 0.0 and semantic_visible_world_rect.size.y > 0.0 \
			and semantic_visible_world_rect.size.is_equal_approx(value.size):
		# 语义绘制自身另有 160 px 外扩；这里保留 96 px 相机移动保护带，
		# 避免地图每平移 1 px 都重建显示列表，同时确保视口边缘不会漏字。
		var camera_guard := _screen_pixels(96.0)
		if semantic_visible_world_rect.grow(camera_guard).encloses(value):
			return false
	semantic_visible_world_rect = value
	if draw_annotation_layers and draw_semantic_annotations:
		queue_redraw()
	return true


func set_pass_symbol_variant(value: String) -> bool:
	if value not in [PASS_SYMBOL_VARIANT_V3, PASS_SYMBOL_VARIANT_PAPER_INK_V1]:
		return false
	if pass_symbol_variant == value:
		return false
	if value == PASS_SYMBOL_VARIANT_PAPER_INK_V1:
		_load_pass_paper_ink_texture()
		if _pass_paper_ink_texture == null:
			return false
	pass_symbol_variant = value
	queue_redraw()
	return true


func get_pass_symbol_variant() -> String:
	return pass_symbol_variant


func get_pass_symbol_review_contract() -> Dictionary:
	var detail_level := _detail_level()
	var candidate_applied := (
		pass_symbol_variant == PASS_SYMBOL_VARIANT_PAPER_INK_V1
		and detail_level in ["middle", "near"]
	)
	return {
		"default_variant": PASS_SYMBOL_VARIANT_V3,
		"active_variant": pass_symbol_variant,
		"available_variants": [PASS_SYMBOL_VARIANT_V3, PASS_SYMBOL_VARIANT_PAPER_INK_V1],
		"candidate_display_px": PASS_SYMBOL_REVIEW_DISPLAY_PX,
		"candidate_lods": ["middle", "near"],
		"detail_level": detail_level,
		"render_variant": PASS_SYMBOL_VARIANT_PAPER_INK_V1 if candidate_applied else (
			"programmatic_v3_far" if pass_symbol_variant == PASS_SYMBOL_VARIANT_PAPER_INK_V1 else PASS_SYMBOL_VARIANT_V3
		),
		"candidate_applied": candidate_applied,
		"candidate_resource_loaded": _pass_paper_ink_texture != null,
		"far_fallback": PASS_SYMBOL_VARIANT_V3,
		"persistent": false,
		"visual_only": true
	}


func set_terrain_relief_variant(value: String) -> bool:
	if value not in [TERRAIN_RELIEF_VARIANT_LR_V1, TERRAIN_RELIEF_VARIANT_HR_V1]:
		return false
	if terrain_relief_variant == value:
		return false
	var next_texture: Texture2D = ReliefTexture
	if value == TERRAIN_RELIEF_VARIANT_LR_V1:
		var control_resource := load(TERRAIN_RELIEF_LR_PATH)
		if not control_resource is Texture2D:
			push_warning("旧地形对照无法加载；保持高精正式地形")
			return false
		next_texture = control_resource as Texture2D
	terrain_relief_variant = value
	_terrain_relief_texture = next_texture
	queue_redraw()
	return true


func get_terrain_relief_variant() -> String:
	return terrain_relief_variant


func get_terrain_relief_review_contract() -> Dictionary:
	var texture_size := _terrain_relief_texture.get_size() if _terrain_relief_texture != null else Vector2.ZERO
	return {
		"default_variant": TERRAIN_RELIEF_VARIANT_HR_V1,
		"active_variant": terrain_relief_variant,
		"available_variants": [TERRAIN_RELIEF_VARIANT_LR_V1, TERRAIN_RELIEF_VARIANT_HR_V1],
		"active_texture_size": Vector2i(roundi(texture_size.x), roundi(texture_size.y)),
		"formal_path": "res://assets/map_relief.png",
		"control_path": TERRAIN_RELIEF_LR_PATH,
		"formalized_stage": "M2-D29",
		"control_only": terrain_relief_variant == TERRAIN_RELIEF_VARIANT_LR_V1,
		"persistent": false,
		"visual_only": true,
		"coordinate_model_changed": false,
		"save_schema_changed": false,
	}


func set_terrain_visual_profile(value: String) -> bool:
	if value not in [
		TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1,
		TERRAIN_VISUAL_PROFILE_ANTIQUE_TOPOGRAPHIC_V1,
		TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1,
	]:
		return false
	if terrain_visual_profile == value:
		return false
	terrain_visual_profile = value
	queue_redraw()
	return true


func get_terrain_visual_profile() -> String:
	return terrain_visual_profile


func get_terrain_visual_profile_review_contract() -> Dictionary:
	var palette := _terrain_palette()
	return {
		"style_version": TERRAIN_VISUAL_PROFILE_STYLE_VERSION,
		"default_profile": TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1,
		"active_profile": terrain_visual_profile,
		"available_profiles": [
			TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1,
			TERRAIN_VISUAL_PROFILE_ANTIQUE_TOPOGRAPHIC_V1,
			TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1,
		],
		"candidate_only": terrain_visual_profile != TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1,
		"palette": palette.duplicate(true),
		"terrain_emphasis": str(palette.get("terrain_emphasis", "balanced_daylight")),
		"river_valley_underlay": bool(palette.get("river_valley_underlay", false)),
		"visual_scope": "static_terrain_only",
		"runtime_dependency": "offline_existing_assets_only",
		"persistent": false,
		"visual_only": true,
		"coordinate_model_changed": false,
		"save_schema_changed": false,
	}


func _terrain_palette() -> Dictionary:
	if terrain_visual_profile == TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1:
		return {
			"backdrop": MAP_BACKDROP_COLOR,
			"sea": Color("#ADD0D0"),
			"land": Color("#B6C399"),
			"daylight_wash": Color("#EFF0D7"),
			"daylight_wash_alpha": 0.0,
			"relief_base": Color(1.0, 1.0, 1.0, 0.0),
			"relief_detail": Color(1.0, 1.0, 1.0, 0.0),
			"coast_outer": Color(0.24, 0.43, 0.40, 0.42),
			"coast_inner": Color(0.83, 0.91, 0.76, 0.55),
			"lake_fill": Color("#70B3BD"),
			"lake_outline": Color("#548D98"),
			"river_outer": Color(0.24, 0.48, 0.53, 0.72),
			"river_inner": Color(0.64, 0.85, 0.85, 0.82),
			"river_valley_underlay": false,
			"terrain_emphasis": "jade_daylight_light_pixel",
			"surface_alpha": 0.015,
		}
	if terrain_visual_profile == TERRAIN_VISUAL_PROFILE_ANTIQUE_TOPOGRAPHIC_V1:
		return {
			"backdrop": Color("#D9DED4"),
			"land": Color("#D6CFA8"),
			"daylight_wash": Color("#F7ECC9"),
			"daylight_wash_alpha": 0.54,
			"relief_base": Color(1.0, 0.96, 0.84, 0.64),
			"relief_detail": Color(0.72, 0.69, 0.52, 0.60),
			"coast_outer": Color(0.27, 0.34, 0.31, 0.54),
			"coast_inner": Color(0.76, 0.64, 0.40, 0.36),
			"lake_fill": Color(0.54, 0.72, 0.74, 0.72),
			"lake_outline": Color(0.24, 0.47, 0.50, 0.58),
			"river_outer": Color(0.24, 0.45, 0.49, 0.58),
			"river_inner": Color(0.72, 0.87, 0.85, 0.82),
			"river_valley": Color(0.47, 0.57, 0.49, 0.11),
			"river_valley_underlay": true,
			"terrain_emphasis": "relief_and_major_valleys_v2",
			"surface_alpha": 0.055,
		}
	return {
		"backdrop": MAP_BACKDROP_COLOR,
		"land": Color("#B6B490"),
		"daylight_wash": MAP_DAYLIGHT_WASH_COLOR,
		"daylight_wash_alpha": MAP_DAYLIGHT_WASH_ALPHA,
		"relief_base": RELIEF_BASE_TINT,
		"relief_detail": RELIEF_DETAIL_TINT,
		"coast_outer": COAST_OUTER_COLOR,
		"coast_inner": COAST_INNER_COLOR,
		"lake_fill": LAKE_FILL_COLOR,
		"lake_outline": LAKE_OUTLINE_COLOR,
		"river_outer": RIVER_OUTER_COLOR,
		"river_inner": RIVER_INNER_COLOR,
		"river_valley_underlay": false,
		"terrain_emphasis": "balanced_daylight",
		"surface_alpha": 0.065,
	}


func set_strategic_corridors_visible(value: bool) -> bool:
	if show_strategic_corridors == value:
		return false
	show_strategic_corridors = value
	queue_redraw()
	return true


func set_near_hachures_visible(value: bool) -> bool:
	if show_near_hachures == value:
		return false
	show_near_hachures = value
	queue_redraw()
	return true


func get_near_hachure_contract() -> Dictionary:
	var eligible_ids: Array[String] = []
	var drawn_ids: Array[String] = []
	var entries: Array[Dictionary] = []
	for mountain_index in range(mountains.size()):
		var mountain_value = mountains[mountain_index]
		if not (mountain_value is Dictionary):
			continue
		var mountain := mountain_value as Dictionary
		var mountain_id := str(mountain.get("id", ""))
		var metrics := _mountain_hachure_metrics(mountain)
		var eligible := bool(metrics.get("eligible", false))
		var drawn := show_near_hachures and bool(metrics.get("drawn", false))
		if eligible:
			eligible_ids.append(mountain_id)
		if drawn:
			drawn_ids.append(mountain_id)
		entries.append({
			"id": mountain_id,
			"tier": int(metrics.get("tier", 3)),
			"anchor": Vector2(float(mountain.get("x", 0.5)), float(mountain.get("y", 0.5))),
			"rotation_deg": float(mountain.get("rotation_deg", 0.0)),
			"atlas_region": mountain_index % (NEAR_HACHURE_ATLAS_GRID.x * NEAR_HACHURE_ATLAS_GRID.y),
			"base_width_screen": float(metrics.get("base_width_screen", 0.0)),
			"width_screen": float(metrics.get("width_screen", 0.0)),
			"growth_factor": float(metrics.get("growth_factor", 1.0)),
			"target_opacity": float(metrics.get("target_opacity", 0.0)),
			"effective_opacity": float(metrics.get("effective_opacity", 0.0)),
			"fade_start_zoom": float(metrics.get("fade_start_zoom", 0.0)),
			"fade_end_zoom": float(metrics.get("fade_end_zoom", 0.0)),
			"transition_factor": float(metrics.get("transition_factor", 0.0)),
			"eligible": eligible,
			"drawn": drawn,
		})
	return {
		"style_version": NEAR_HACHURE_STYLE_VERSION,
		"visible": not drawn_ids.is_empty(),
		"visible_count": drawn_ids.size(),
		"drawn_count": drawn_ids.size(),
		"drawn_ids": drawn_ids,
		"eligible_count": eligible_ids.size(),
		"eligible_ids": eligible_ids,
		"entries": entries,
		"maximum_count": mountains.size(),
		"minimum_zoom": NEAR_HACHURE_MIN_ZOOM,
		"full_detail_zoom": NEAR_HACHURE_FULL_DETAIL_ZOOM,
		"atlas_regions": NEAR_HACHURE_ATLAS_GRID.x * NEAR_HACHURE_ATLAS_GRID.y,
		"atlas_size": MountainHachureAtlas.get_size(),
		"texture_backed": true,
		"transition_model": "tiered_smoothstep_zoom",
		"continuous_zoom_blend": true,
		"per_frame_update": false,
		"screen_constant": false,
		"scale_model": "bounded_partial_world_growth",
		"growth_reference_zoom": MOUNTAIN_GROWTH_REFERENCE_ZOOM,
		"growth_exponent": MOUNTAIN_GROWTH_EXPONENT,
		"max_growth": MOUNTAIN_GROWTH_MAX,
		"stroke_screen_constant": true,
		"deterministic": true,
		"placement_source": "mountain_anchors",
		"after_layer": "mountain_memory_ridges",
		"draw_order": "before_routes",
		"meaning": "visual_only_not_boundary"
	}


func get_mountain_ridge_contract() -> Dictionary:
	var visible_ids: Array[String] = []
	var continuity_ids: Array[String] = []
	var entries: Array[Dictionary] = []
	for mountain_value in mountains:
		if not (mountain_value is Dictionary):
			continue
		var mountain := mountain_value as Dictionary
		if int(mountain.get("tier", 3)) == MOUNTAIN_MEMORY_TIER:
			continuity_ids.append(str(mountain.get("id", "")))
		if not _is_mountain_ridge_visible(mountain):
			continue
		var mountain_id := str(mountain.get("id", ""))
		var metrics := _mountain_ridge_metrics(mountain)
		visible_ids.append(mountain_id)
		entries.append({
			"id": mountain_id,
			"tier": int(mountain.get("tier", 3)),
			"anchor": Vector2(float(mountain.get("x", 0.5)), float(mountain.get("y", 0.5))),
			"rotation_deg": float(mountain.get("rotation_deg", 0.0)),
			"base_width_screen": float(metrics.get("base_width_screen", 0.0)),
			"base_height_screen": float(metrics.get("base_height_screen", 0.0)),
			"width_screen": float(metrics.get("width_screen", 0.0)),
			"height_screen": float(metrics.get("height_screen", 0.0)),
			"growth_factor": float(metrics.get("growth_factor", 1.0)),
			"opacity": float(metrics.get("opacity", 0.0)),
			"memory_identity": int(mountain.get("tier", 3)) == MOUNTAIN_MEMORY_TIER,
		})
	return {
		"style_version": MOUNTAIN_RIDGE_STYLE_VERSION,
		"visible": not visible_ids.is_empty(),
		"visible_count": visible_ids.size(),
		"visible_ids": visible_ids,
		"entries": entries,
		"maximum_count": mountains.size(),
		"continuity_ids": continuity_ids,
		"continuity_count": continuity_ids.size(),
		"near_continuity_count": continuity_ids.size() if _detail_level() == "near" else 0,
		"near_overlay": _detail_level() == "near",
		"connected_path": false,
		"geometry_model": "independent_anchor_glyphs",
		"screen_constant": false,
		"scale_model": "bounded_partial_world_growth",
		"growth_reference_zoom": MOUNTAIN_GROWTH_REFERENCE_ZOOM,
		"growth_exponent": MOUNTAIN_GROWTH_EXPONENT,
		"max_growth": MOUNTAIN_GROWTH_MAX,
		"stroke_screen_constant": true,
		"deterministic": true,
		"texture_backed": false,
		"placement_source": "mountain_anchors",
		"draw_order": "before_hachures_and_routes",
		"meaning": "visual_only_not_boundary"
	}


func set_historical_context_layer(value: Dictionary) -> void:
	historical_context_records.clear()
	for record_value in value.get("records", []):
		if record_value is Dictionary:
			historical_context_records.append((record_value as Dictionary).duplicate(true))
	_historical_context_layout_cache.clear()
	queue_redraw()


func set_historical_context_visible(value: bool) -> bool:
	if show_historical_context == value:
		return false
	show_historical_context = value
	_historical_context_layout_cache.clear()
	queue_redraw()
	return true


func set_historical_context_visibility_by_layer(value: Dictionary) -> bool:
	var normalized := {}
	var any_visible := false
	for layer_id_value in value.keys():
		var layer_id := str(layer_id_value)
		var visible := bool(value.get(layer_id_value, false))
		normalized[layer_id] = visible
		any_visible = any_visible or visible
	if historical_context_visibility_by_layer == normalized and show_historical_context == any_visible:
		return false
	historical_context_visibility_by_layer = normalized
	show_historical_context = any_visible
	_historical_context_layout_cache.clear()
	queue_redraw()
	return true


func get_historical_context_tag_rects_world() -> Dictionary:
	var layout := _ensure_historical_context_layout()
	var result := {}
	var entries: Dictionary = layout.get("entries", {})
	for context_id in entries:
		result[str(context_id)] = (entries[context_id] as Dictionary).get("rect", Rect2())
	return result


func find_historical_context_at_world(world_position: Vector2) -> String:
	var layout := _ensure_historical_context_layout()
	var entries: Dictionary = layout.get("entries", {})
	var draw_order: Array = layout.get("draw_order", [])
	if draw_order.is_empty():
		return ""
	for index in range(draw_order.size() - 1, -1, -1):
		var context_id := str(draw_order[index])
		if not entries.has(context_id):
			continue
		var hit_rect: Rect2 = (entries[context_id] as Dictionary).get("rect", Rect2())
		if hit_rect.grow(_screen_pixels(3.0)).has_point(world_position):
			return context_id
	return ""


func get_annotation_lod_state() -> Dictionary:
	var label_layout: Dictionary = _ensure_place_label_layout() if draw_annotation_layers else {}
	var visible_places := 0
	var visible_place_symbols := 0
	var visible_strategic_nodes := 0
	var total_strategic_nodes := 0
	var visible_battlefields := 0
	var total_battlefields := 0
	for place in places:
		var is_visible := _is_place_visible(str(place.get("id", "")))
		if is_visible:
			visible_places += 1
		if _is_place_symbol_visible(str(place.get("id", ""))):
			visible_place_symbols += 1
		var place_type := str(place.get("type", "city"))
		if place_type in ["pass", "ferry", "water_gate"]:
			total_strategic_nodes += 1
			if is_visible:
				visible_strategic_nodes += 1
		if place_type == "battlefield":
			total_battlefields += 1
			if is_visible:
				visible_battlefields += 1
	var visible_routes := 0
	for route in routes:
		if _is_route_visible(route):
			visible_routes += 1
	var corridor_ids := {}
	var visible_corridor_ids := {}
	for route in routes:
		var corridor_id := str(route.get("corridor_id", "")).strip_edges()
		if corridor_id.is_empty():
			continue
		corridor_ids[corridor_id] = true
		if _is_corridor_route_visible(route):
			visible_corridor_ids[corridor_id] = true
	var visible_mountains := 0
	for mountain in mountains:
		if _is_mountain_visible(mountain):
			visible_mountains += 1
	var visible_river_labels := 0
	for river_label in river_data.get("labels", []):
		if river_label is Dictionary and _is_river_label_visible(river_label):
			visible_river_labels += 1
	var visible_historical_contexts := 0
	var visible_historical_contexts_by_layer := {}
	for context_record in historical_context_records:
		if context_record is Dictionary and _is_historical_context_visible(context_record):
			visible_historical_contexts += 1
			var runtime_layer_id := str(context_record.get("_runtime_layer_id", "legacy"))
			visible_historical_contexts_by_layer[runtime_layer_id] = int(visible_historical_contexts_by_layer.get(runtime_layer_id, 0)) + 1
	var near_hachures := get_near_hachure_contract()
	var mountain_ridges := get_mountain_ridge_contract()
	var geographic_context_contract := get_geographic_context_contract()
	return {
		"level": _detail_level(),
		"zoom": view_zoom,
		"visible_places": visible_places,
		"visible_place_symbols": visible_place_symbols,
		"visible_routes": visible_routes,
		"visible_board_network_segments": routes.size(),
		"visible_strategic_corridors": visible_corridor_ids.size(),
		"strategic_corridors_visible": show_strategic_corridors,
		"historical_context_visible": show_historical_context,
		"visible_historical_contexts": visible_historical_contexts,
		"visible_historical_contexts_by_layer": visible_historical_contexts_by_layer,
		"visible_mountains": visible_mountains,
		"visible_mountain_ridges": int(mountain_ridges.get("visible_count", 0)),
		"visible_near_hachures": int(near_hachures.get("visible_count", 0)),
		"near_hachures_visible": bool(near_hachures.get("visible", false)),
		"visible_river_labels": visible_river_labels,
		"visible_geographic_contexts": int(geographic_context_contract.get("visible_count", 0)),
		"visible_strategic_nodes": visible_strategic_nodes,
		"visible_battlefields": visible_battlefields,
		"place_label_layout_builds": _place_label_layout_builds,
		"place_label_collisions": int(label_layout.get("collision_count", 0)),
		"total_places": places.size(),
		"total_routes": routes.size(),
		"total_strategic_corridors": corridor_ids.size(),
		"total_historical_contexts": historical_context_records.size(),
		"total_mountains": mountains.size(),
		"total_near_hachures": int(near_hachures.get("maximum_count", 0)),
		"total_river_labels": river_data.get("labels", []).size(),
		"total_geographic_contexts": geographic_context_records.size(),
		"total_strategic_nodes": total_strategic_nodes,
		"total_battlefields": total_battlefields
	}


func get_semantic_render_contract() -> Dictionary:
	return {
		"style_version": SEMANTIC_RENDER_STYLE_VERSION,
		"coordinate_model": "world_anchor_screen_space_glyph",
		"font_rasterization": "target_screen_size",
		"icon_geometry": "screen_space_primitives",
		"halo_model": "single_msdf_outline",
		"world_zoom_cancelled": true,
		"pixel_aligned_anchors": true,
		"msdf": true,
		"screen_constant": true,
	}


func get_geographic_annotation_hierarchy_contract() -> Dictionary:
	var near_hachures := get_near_hachure_contract()
	return {
		"style_version": GEOGRAPHIC_ANNOTATION_STYLE_VERSION,
		"zoom": view_zoom,
		"detail_level": _detail_level(),
		"province_labels": {
			"visible_count": _visible_province_label_entries().size(),
			"font_size_screen": roundi(_province_label_target_size()),
			"ink_alpha": _province_label_alpha(),
			"outline_alpha_factor": 0.68,
		},
		"river_labels": {
			"visible_count": _visible_river_label_count(),
			"tier_alpha": {
				"1": _river_label_alpha(1),
				"2": _river_label_alpha(2),
				"3": _river_label_alpha(3),
			},
		},
		"mountain_labels": {
			"visible_count": _visible_mountain_label_count(),
			"tier_alpha": {
				"1": _mountain_label_alpha(1),
				"2": _mountain_label_alpha(2),
				"3": _mountain_label_alpha(3),
			},
		},
		"near_hachures": {
			"visible_count": int(near_hachures.get("visible_count", 0)),
			"tier_target_opacity": {
				"1": _near_hachure_target_opacity(1),
				"2": _near_hachure_target_opacity(2),
				"3": _near_hachure_target_opacity(3),
			},
			"maximum_growth": MOUNTAIN_GROWTH_MAX,
		},
		"macro_direction_labels": false,
		"source_layers": ["map_mountains", "map_rivers", "province_label_anchors"],
		"interactive": false,
		"persistent": false,
		"coordinate_model_changed": false,
		"save_schema_changed": false,
	}


func get_strategic_board_style_contract() -> Dictionary:
	return {
		"style_version": STRATEGIC_BOARD_STYLE_VERSION,
		"style_id": STRATEGIC_BOARD_STYLE_ID,
		"stage_metaphor": "physical_sandtable",
		"outside_material": "pale_sage_table",
		"brightness_model": "daylight_parchment_map",
		"playable_theater_mask": "organic_visual_stage",
		"playable_theater_boundary_semantics": "visual_only_not_historical",
		"terrain_first": true,
		"terrain_hierarchy_style_version": TERRAIN_HIERARCHY_STYLE_VERSION,
		"terrain_relief_model": "daylight_underlay_plus_detail_glaze",
		"terrain_detail_after_daylight_wash": true,
		"water_visual_weight": "secondary_geographic_skeleton",
		"coast_visual_weight": "secondary_geographic_skeleton",
		"board_network_source": "map_routes",
		"board_network_interactive": false,
		"board_network_geometry": "deterministic_quadratic_curves",
		"overview_node_style": "city_hierarchy_silhouettes_v5",
		"far_city_node_style": "city_hierarchy_silhouettes_v5",
		"city_hierarchy_style_version": CITY_HIERARCHY_STYLE_VERSION,
		"mountain_ridge_style": "persistent_memory_ridge_v3",
		"mountain_ridge_continuity": "tier1_across_all_lods",
		"mountain_ridge_draw_order": "before_routes",
		"overview_macro_context_default": false,
		"overview_water_context_default": true,
		"copyrighted_game_assets_used": false,
		"coordinate_model_changed": false,
		"save_schema_changed": false,
	}


func get_route_hierarchy_contract() -> Dictionary:
	var route_tier_counts := {"strategic": 0, "regional": 0, "ordinary": 0}
	var corridor_tier_counts := {"strategic": 0, "regional": 0}
	for route in routes:
		var route_tier := _route_hierarchy_tier(route)
		route_tier_counts[route_tier] = int(route_tier_counts.get(route_tier, 0)) + 1
		var corridor_tier := str(route.get("corridor_tier", ""))
		if corridor_tier_counts.has(corridor_tier):
			corridor_tier_counts[corridor_tier] = int(corridor_tier_counts[corridor_tier]) + 1
	return {
		"style_version": ROUTE_HIERARCHY_STYLE_VERSION,
		"route_tier_counts": route_tier_counts,
		"corridor_segment_tier_counts": corridor_tier_counts,
		"base_network_segments": routes.size(),
		"base_network_geometry": "deterministic_quadratic_curves",
		"route_overlay_geometry": "straight_dashed_abstract_links",
		"corridor_geometry": "straight_dashed_abstract_links",
		"middle_styles": {
			"strategic": _route_overlay_style("strategic", "middle"),
			"regional": _route_overlay_style("regional", "middle"),
			"ordinary": _route_overlay_style("ordinary", "middle"),
		},
		"near_styles": {
			"strategic": _route_overlay_style("strategic", "near"),
			"regional": _route_overlay_style("regional", "near"),
			"ordinary": _route_overlay_style("ordinary", "near"),
		},
		"corridor_middle_styles": {
			"strategic": _corridor_style("strategic", "middle"),
			"regional": _corridor_style("regional", "middle"),
		},
		"corridor_near_styles": {
			"strategic": _corridor_style("strategic", "near"),
			"regional": _corridor_style("regional", "near"),
		},
		"screen_constant": true,
		"interactive": false,
		"route_data_changed": false,
		"movement_rules_added": false,
	}


func get_terrain_hierarchy_style_contract() -> Dictionary:
	return {
		"style_version": TERRAIN_HIERARCHY_STYLE_VERSION,
		"composite_order": [
			"surface_texture",
			"relief_base",
			"daylight_wash",
			"relief_detail",
			"lakes",
			"rivers",
			"edge_fade",
		],
		"relief_model": "same_public_domain_source_two_stage",
		"daylight_wash_alpha": MAP_DAYLIGHT_WASH_ALPHA,
		"relief_base_alpha": RELIEF_BASE_TINT.a,
		"relief_detail_alpha": RELIEF_DETAIL_TINT.a,
		"coast_outer_width": COAST_OUTER_WIDTH,
		"coast_outer_alpha": COAST_OUTER_COLOR.a,
		"river_major_outer_width": RIVER_MAJOR_OUTER_WIDTH,
		"river_major_outer_alpha": RIVER_OUTER_COLOR.a,
		"lake_outline_alpha": LAKE_OUTLINE_COLOR.a,
		"static_cache_only": true,
		"coordinate_model_changed": false,
		"save_schema_changed": false,
	}


func get_place_label_layout_state() -> Dictionary:
	var layout: Dictionary = _ensure_place_label_layout()
	return {
		"level": _detail_level(),
		"label_level": _place_label_level(),
		"builds": _place_label_layout_builds,
		"canonical_zoom": float(layout.get("canonical_zoom", 0.0)),
		"collision_count": int(layout.get("collision_count", 0)),
		"entries": (layout.get("entries", {}) as Dictionary).duplicate(true),
		"draw_order": (layout.get("draw_order", []) as Array).duplicate()
	}


func get_place_label_rects_screen(target_zoom := -1.0) -> Dictionary:
	var layout: Dictionary = _ensure_place_label_layout()
	var canonical_zoom := float(layout.get("canonical_zoom", 1.0))
	var actual_zoom := view_zoom if target_zoom <= 0.0 else maxf(target_zoom, 0.1)
	var result := {}
	var entries: Dictionary = layout.get("entries", {})
	for place_id in entries:
		var entry: Dictionary = entries[place_id]
		var point: Vector2 = entry.get("point", Vector2.ZERO)
		var canonical_rect: Rect2 = entry.get("rect_screen", Rect2())
		var relative_position := canonical_rect.position - point * canonical_zoom
		result[str(place_id)] = Rect2(point * actual_zoom + relative_position, canonical_rect.size)
	return result


func is_place_visible(place_id: String) -> bool:
	return _is_place_visible(place_id)


func is_place_symbol_visible(place_id: String) -> bool:
	return _is_place_symbol_visible(place_id)


func _draw() -> void:
	redraw_count += 1
	if draw_base_layers:
		_draw_parchment()
		_draw_land()
		_draw_playable_theater()
		_draw_surface_texture()
		_draw_relief()
		_draw_daylight_wash()
		_draw_relief_detail()
		_draw_lakes()
		_draw_rivers()
		_draw_edge_fade()
	if draw_annotation_layers:
		if draw_structural_annotations:
			_draw_mountain_ridge_marks()
			_draw_near_mountain_hachures()
			_draw_board_network()
			_draw_routes()
			_draw_strategic_corridors()
		if draw_semantic_annotations:
			_draw_historical_contexts()
			_draw_geographic_context()
			_draw_river_labels()
			_draw_mountain_labels()
			_draw_province_labels()
			_draw_places()


func get_geographic_context_contract() -> Dictionary:
	var raw_visible := MapGeographicContextPolicyScript.visible_records(
		geographic_context_records,
		view_zoom
	)
	var entries := _visible_geographic_context_entries()
	var visible_ids: Array[String] = []
	for entry in entries:
		visible_ids.append(str(entry.get("id", "")))
	return {
		"configured_count": geographic_context_records.size(),
		"raw_visible_count": raw_visible.size(),
		"visible_count": entries.size(),
		"visible_ids": visible_ids,
		"interactive": false,
		"saved": false,
		"view_zoom": view_zoom,
	}


func _draw_geographic_context() -> void:
	var overview := _place_label_level() == "overview"
	var target_size := 19.0 if overview else 17.0
	var font_size := maxi(8, roundi(target_size))
	var halo_step := 0.75
	var alpha := 0.18 if overview else 0.14
	for entry in _visible_geographic_context_entries():
		var text := str(entry.get("label", ""))
		var text_size := MapFont.get_string_size(
			text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size
		)
		var origin := Vector2(-text_size.x * 0.5, font_size * 0.35)
		var point: Vector2 = entry.get("point_world", Vector2.ZERO)
		if not _semantic_point_visible(point):
			continue
		var rotation := deg_to_rad(float(entry.get("rotation_deg", 0.0)))
		var is_water := str(entry.get("kind", "")) == "water_body"
		var text_color := Color(0.63, 0.76, 0.72, alpha * 1.9) if is_water else Color(0.24, 0.23, 0.16, alpha)
		var halo_color := Color(0.06, 0.08, 0.07, alpha * 1.15) if is_water else Color(0.88, 0.86, 0.68, alpha * 0.62)
		_begin_screen_space_draw(_snap_to_screen_pixel(point), rotation)
		draw_string_outline(
			MapFont,
			origin,
			text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			maxi(1, roundi(halo_step)),
			halo_color
		)
		draw_string(
			MapFont,
			origin,
			text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
				text_color
			)
		_end_screen_space_draw()


func _visible_geographic_context_entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var visible_records := MapGeographicContextPolicyScript.visible_records(
		geographic_context_records,
		view_zoom
	)
	if visible_records.is_empty():
		return result
	var target_size := 21.0 if _place_label_level() == "overview" else 18.0
	var font_size_screen := maxi(8, roundi(target_size))
	var ascent := MapFont.get_ascent(font_size_screen)
	var descent := MapFont.get_descent(font_size_screen)
	var place_rects: Dictionary = get_place_label_rects_screen(view_zoom)
	var province_entries := _visible_province_label_entries()
	var occupied_context_rects: Array[Rect2] = []
	var map_screen_rect := Rect2(MAP_CONTENT_RECT.position * view_zoom, MAP_CONTENT_RECT.size * view_zoom)
	for record in visible_records:
		# 默认只保留渤海、东海、南海等稳定水域参照；“方向／边缘／走廊”
		# 仍保留在研究数据中，但不再用编辑性文字填补沙盘外围。
		if str(record.get("kind", "")) != "water_body":
			continue
		var normalized := MapGeographicContextPolicyScript.project_record(
			record,
			MAP_PROJECTION_BOUNDS
		)
		var point_world := _geo_point(normalized)
		var point_screen := point_world * view_zoom
		var text := str(record.get("label", ""))
		var text_size_screen := MapFont.get_string_size(
			text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size_screen
		)
		var rect_screen := Rect2(
			Vector2(
				point_screen.x - text_size_screen.x * 0.5,
				point_screen.y - ascent
			),
			Vector2(text_size_screen.x, ascent + descent)
		).grow(4.0)
		if not map_screen_rect.encloses(rect_screen):
			continue
		var blocked := false
		for place_rect_value in place_rects.values():
			var place_rect: Rect2 = place_rect_value
			if rect_screen.intersects(place_rect.grow(5.0)):
				blocked = true
				break
		if blocked:
			continue
		for province_entry in province_entries:
			var province_rect: Rect2 = province_entry.get("rect_screen", Rect2())
			if rect_screen.intersects(province_rect.grow(5.0)):
				blocked = true
				break
		if blocked:
			continue
		for occupied_rect in occupied_context_rects:
			if rect_screen.intersects(occupied_rect.grow(6.0)):
				blocked = true
				break
		if blocked:
			continue
		occupied_context_rects.append(rect_screen)
		result.append({
			"id": str(record.get("id", "")),
			"kind": str(record.get("kind", "")),
			"label": text,
			"point_world": point_world,
			"rect_screen": rect_screen,
			"rotation_deg": float(record.get("rotation_deg", 0.0)),
			"priority": int(record.get("priority", 2)),
		})
	return result


func _draw_near_mountain_hachures() -> void:
	if not show_near_hachures or MountainHachureAtlas == null:
		return
	var atlas_size: Vector2 = MountainHachureAtlas.get_size()
	var source_size: Vector2 = atlas_size / Vector2(NEAR_HACHURE_ATLAS_GRID)
	for mountain_index in range(mountains.size()):
		var mountain: Dictionary = mountains[mountain_index]
		var metrics := _mountain_hachure_metrics(mountain)
		if not bool(metrics.get("drawn", false)):
			continue
		var width_screen := float(metrics.get("width_screen", 0.0))
		var draw_size := Vector2.ONE * _screen_pixels(width_screen)
		var variant := mountain_index % (NEAR_HACHURE_ATLAS_GRID.x * NEAR_HACHURE_ATLAS_GRID.y)
		var source_column := variant % NEAR_HACHURE_ATLAS_GRID.x
		var source_row := floori(float(variant) / float(NEAR_HACHURE_ATLAS_GRID.x))
		var source_rect := Rect2(Vector2(source_column, source_row) * source_size, source_size)
		var point := _geo_point(Vector2(float(mountain.get("x", 0.5)), float(mountain.get("y", 0.5))))
		var rotation := deg_to_rad(float(mountain.get("rotation_deg", 0.0)))
		var opacity := float(metrics.get("effective_opacity", 0.0))
		draw_set_transform(point, rotation, Vector2.ONE)
		var draw_rect := Rect2(-draw_size * 0.5 - Vector2(0, draw_size.y * 0.12), draw_size)
		draw_texture_rect_region(MountainHachureAtlas, draw_rect, source_rect, Color(0.54, 0.52, 0.35, opacity))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _mountain_hachure_metrics(mountain: Dictionary) -> Dictionary:
	var tier := clampi(int(mountain.get("tier", 3)), 1, 3)
	var fade_start_zoom := 1.40 if tier == 1 else (1.46 if tier == 2 else 1.52)
	var fade_end_zoom := 1.50 if tier == 1 else (1.58 if tier == 2 else 1.66)
	var base_width_screen := 100.0 if tier == 1 else (88.0 if tier == 2 else 78.0)
	var growth_factor := _mountain_structure_growth()
	var width_screen := base_width_screen * growth_factor
	var target_opacity := _near_hachure_target_opacity(tier)
	var transition_factor := _smooth_zoom_factor(view_zoom, fade_start_zoom, fade_end_zoom)
	var effective_opacity := target_opacity * transition_factor
	return {
		"tier": tier,
		"fade_start_zoom": fade_start_zoom,
		"fade_end_zoom": fade_end_zoom,
		"base_width_screen": base_width_screen,
		"width_screen": width_screen,
		"growth_factor": growth_factor,
		"target_opacity": target_opacity,
		"transition_factor": transition_factor,
		"effective_opacity": effective_opacity,
		"eligible": view_zoom + NEAR_HACHURE_DRAW_EPSILON >= fade_start_zoom,
		"drawn": effective_opacity > NEAR_HACHURE_DRAW_EPSILON,
	}


func _near_hachure_target_opacity(tier: int) -> float:
	return 0.18 if tier == 1 else (0.15 if tier == 2 else 0.12)


func _smooth_zoom_factor(zoom_value: float, start_zoom: float, end_zoom: float) -> float:
	if end_zoom <= start_zoom:
		return 1.0 if zoom_value >= end_zoom else 0.0
	var linear_factor := clampf((zoom_value - start_zoom) / (end_zoom - start_zoom), 0.0, 1.0)
	return linear_factor * linear_factor * (3.0 - 2.0 * linear_factor)


func _mountain_structure_growth() -> float:
	var ratio := maxf(view_zoom, MOUNTAIN_GROWTH_REFERENCE_ZOOM) / MOUNTAIN_GROWTH_REFERENCE_ZOOM
	return clampf(pow(ratio, MOUNTAIN_GROWTH_EXPONENT), 1.0, MOUNTAIN_GROWTH_MAX)


func _draw_mountain_ridge_marks() -> void:
	for mountain_value in mountains:
		if not (mountain_value is Dictionary):
			continue
		var mountain := mountain_value as Dictionary
		if not _is_mountain_ridge_visible(mountain):
			continue
		var metrics := _mountain_ridge_metrics(mountain)
		var width_screen := float(metrics.get("width_screen", 0.0))
		var height_screen := float(metrics.get("height_screen", 0.0))
		var half_width := _screen_pixels(width_screen * 0.5)
		var ridge_height := _screen_pixels(height_screen)
		var point := _geo_point(Vector2(float(mountain.get("x", 0.5)), float(mountain.get("y", 0.5))))
		var rotation := deg_to_rad(float(mountain.get("rotation_deg", 0.0)))
		var alpha := float(metrics.get("opacity", 0.0))
		var ridge := PackedVector2Array([
			Vector2(-half_width, ridge_height * 0.10),
			Vector2(-half_width * 0.58, -ridge_height * 0.30),
			Vector2(-half_width * 0.24, -ridge_height * 0.04),
			Vector2(half_width * 0.08, -ridge_height * 0.72),
			Vector2(half_width * 0.43, -ridge_height * 0.18),
			Vector2(half_width, -ridge_height * 0.42),
		])
		var lower_ridge := PackedVector2Array()
		for ridge_point in ridge:
			lower_ridge.append(ridge_point + Vector2(0, ridge_height * 0.48))
		draw_set_transform(point, rotation, Vector2.ONE)
		draw_polyline(ridge, Color(0.20, 0.22, 0.14, alpha), _screen_pixels(1.25), true)
		draw_polyline(lower_ridge, Color(0.24, 0.25, 0.16, alpha * 0.72), _screen_pixels(0.85), true)
		for hatch_index in range(1, 5):
			var t := float(hatch_index) / 5.0
			var hatch_x := lerpf(-half_width * 0.72, half_width * 0.72, t)
			var hatch_top := Vector2(hatch_x, -ridge_height * (0.22 + 0.18 * float(hatch_index % 2)))
			var hatch_bottom := hatch_top + Vector2(
				_screen_pixels(4.0 * float(metrics.get("growth_factor", 1.0))),
				ridge_height * 0.72
			)
			draw_line(hatch_top, hatch_bottom, Color(0.24, 0.25, 0.16, alpha * 0.62), _screen_pixels(0.75), true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _is_mountain_ridge_visible(mountain: Dictionary) -> bool:
	if not _is_mountain_visible(mountain):
		return false
	if _detail_level() != "near":
		return true
	return int(mountain.get("tier", 3)) == MOUNTAIN_MEMORY_TIER


func _mountain_ridge_metrics(mountain: Dictionary) -> Dictionary:
	var tier := clampi(int(mountain.get("tier", 3)), 1, 3)
	var level := _detail_level()
	var base_width_screen := 0.0
	var base_height_screen := 0.0
	var opacity := 0.0
	if level == "near":
		base_width_screen = MOUNTAIN_NEAR_RIDGE_WIDTH_SCREEN
		base_height_screen = MOUNTAIN_NEAR_RIDGE_HEIGHT_SCREEN
		opacity = MOUNTAIN_NEAR_RIDGE_ALPHA
	elif level == "middle":
		base_width_screen = 64.0 if tier == 1 else (56.0 if tier == 2 else 48.0)
		base_height_screen = 11.0
		opacity = 0.15
	else:
		base_width_screen = 54.0 if tier == 1 else (48.0 if tier == 2 else 42.0)
		base_height_screen = 8.5
		opacity = 0.10
	var growth_factor := _mountain_structure_growth()
	return {
		"base_width_screen": base_width_screen,
		"base_height_screen": base_height_screen,
		"width_screen": base_width_screen * growth_factor,
		"height_screen": base_height_screen * growth_factor,
		"growth_factor": growth_factor,
		"opacity": opacity,
	}


func _draw_parchment() -> void:
	# 外围不再模拟现代 GIS 海面，而作为承托浅绢地图的暖墨桌面。
	# 地理坐标和可交互范围保持不变，只改变静态舞台材质。
	var palette := _terrain_palette()
	draw_rect(Rect2(Vector2.ZERO, world_size), palette.get("backdrop", MAP_BACKDROP_COLOR))
	if palette.has("sea"):
		draw_rect(MAP_CONTENT_RECT, palette["sea"])
	for x in range(int(MAP_CONTENT_RECT.position.x), int(MAP_CONTENT_RECT.end.x) + 1, 70):
		draw_line(Vector2(x, MAP_CONTENT_RECT.position.y), Vector2(x, MAP_CONTENT_RECT.end.y), Color(0.64, 0.56, 0.35, 0.020), 1.0)
	for y in range(int(MAP_CONTENT_RECT.position.y), int(MAP_CONTENT_RECT.end.y) + 1, 70):
		draw_line(Vector2(MAP_CONTENT_RECT.position.x, y), Vector2(MAP_CONTENT_RECT.end.x, y), Color(0.64, 0.56, 0.35, 0.020), 1.0)

	for i in range(26):
		var center := MAP_CONTENT_RECT.position + Vector2(
			45 + ((i * 233) % int(MAP_CONTENT_RECT.size.x - 90.0)),
			45 + ((i * 137) % int(MAP_CONTENT_RECT.size.y - 90.0))
		)
		var radius := 30.0 + float((i * 29) % 90)
		draw_circle(center, radius, Color(0.72, 0.62, 0.38, 0.010))


func _draw_land() -> void:
	var palette := _terrain_palette()
	var land_color: Color = palette.get("land", Color("#B6B490"))
	var coast_outer: Color = palette.get("coast_outer", COAST_OUTER_COLOR)
	var coast_inner: Color = palette.get("coast_inner", COAST_INNER_COLOR)
	var source_polygons: Array = land_data.get("polygons", [])
	if not source_polygons.is_empty():
		for source_polygon in source_polygons:
			if not (source_polygon is Array) or source_polygon.size() < 3:
				continue
			var projected := PackedVector2Array()
			for point in source_polygon:
				if point is Array and point.size() >= 2:
					projected.append(_geo_point(Vector2(float(point[0]), float(point[1]))))
			if projected.size() < 3:
				continue
			draw_colored_polygon(projected, land_color)
			var closed_polygon := PackedVector2Array(projected)
			closed_polygon.append(projected[0])
			draw_polyline(closed_polygon, coast_outer, COAST_OUTER_WIDTH, true)
			draw_polyline(closed_polygon, coast_inner, COAST_INNER_WIDTH, true)
		return

	var normalized := [
		Vector2(0.16, 0.25), Vector2(0.24, 0.14), Vector2(0.37, 0.09),
		Vector2(0.51, 0.10), Vector2(0.64, 0.14), Vector2(0.75, 0.20),
		Vector2(0.87, 0.27), Vector2(0.91, 0.36), Vector2(0.85, 0.44),
		Vector2(0.86, 0.55), Vector2(0.79, 0.62), Vector2(0.76, 0.73),
		Vector2(0.67, 0.78), Vector2(0.59, 0.88), Vector2(0.48, 0.91),
		Vector2(0.39, 0.86), Vector2(0.30, 0.80), Vector2(0.20, 0.77),
		Vector2(0.12, 0.67), Vector2(0.10, 0.56), Vector2(0.15, 0.46),
		Vector2(0.11, 0.36)
	]
	var polygon := PackedVector2Array()
	for point in normalized:
		polygon.append(_geo_point(point))
	draw_colored_polygon(polygon, land_color)

	var closed := PackedVector2Array(polygon)
	closed.append(polygon[0])
	draw_polyline(closed, coast_outer, COAST_OUTER_WIDTH, true)
	draw_polyline(closed, coast_inner, COAST_INNER_WIDTH, true)

	var coast_marks := [
		[Vector2(0.78, 0.49), Vector2(0.84, 0.46)],
		[Vector2(0.74, 0.70), Vector2(0.81, 0.66)],
		[Vector2(0.61, 0.86), Vector2(0.65, 0.91)]
	]
	for mark in coast_marks:
		draw_line(_geo_point(mark[0]), _geo_point(mark[1]), Color(0.32, 0.40, 0.36, 0.35), 2.0)


func _draw_surface_texture() -> void:
	# 表面底纹只增加纸绢质感，不携带地名、坐标或地理判断；随静态地形缓存一次绘制。
	var surface_alpha := float(_terrain_palette().get("surface_alpha", 0.065))
	draw_texture_rect(SurfaceTexture, MAP_CONTENT_RECT, false, Color(1.0, 0.97, 0.88, surface_alpha))


func _draw_relief() -> void:
	# 白昼洗色前只保留温暖的低透明度地形底纹，避免旧橄榄底色重新压暗纸面。
	var relief_base: Color = _terrain_palette().get("relief_base", RELIEF_BASE_TINT)
	draw_texture_rect(_terrain_relief_texture, MAP_CONTENT_RECT, false, relief_base)


func _draw_daylight_wash() -> void:
	# 旧地形透明纹理保留山川细节，但底色偏橄榄；一次静态浅绢罩染把纸面提到白昼层级。
	# 它位于河湖、路线、地点与人物下方，不改变任何玩法状态或交互坐标。
	var palette := _terrain_palette()
	var wash_color: Color = palette.get("daylight_wash", MAP_DAYLIGHT_WASH_COLOR)
	var wash_alpha := float(palette.get("daylight_wash_alpha", MAP_DAYLIGHT_WASH_ALPHA))
	draw_rect(
		MAP_CONTENT_RECT,
		Color(wash_color, wash_alpha),
		true
	)


func _draw_relief_detail() -> void:
	# 复用同一开放地形纹理，在洗色后恢复山地、盆地与高原明暗。
	# 该层仍随 4× 静态地形缓存一次绘制，不进入平移、缩放或人物拖拽帧。
	var relief_detail: Color = _terrain_palette().get("relief_detail", RELIEF_DETAIL_TINT)
	draw_texture_rect(_terrain_relief_texture, MAP_CONTENT_RECT, false, relief_detail)


func _draw_playable_theater() -> void:
	if terrain_visual_profile == TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1:
		return # 旧暖黄舞台罩染不参与青绿试用；地理与标注仍使用原数据。
	if PlayableTheaterTexture == null:
		return
	draw_texture_rect(PlayableTheaterTexture, MAP_CONTENT_RECT, false)


func _draw_edge_fade() -> void:
	# 用静态条带把地形逐步融入板面背景；只影响视觉，不改变投放、吸附或坐标范围。
	var step_width := MAP_EDGE_FADE_WIDTH / float(MAP_EDGE_FADE_STEPS)
	var backdrop: Color = _terrain_palette().get("backdrop", MAP_BACKDROP_COLOR)
	for step_index in range(MAP_EDGE_FADE_STEPS):
		var distance_from_edge := float(step_index) * step_width
		var inside_ratio := (distance_from_edge + step_width * 0.5) / MAP_EDGE_FADE_WIDTH
		var smooth := inside_ratio * inside_ratio * (3.0 - 2.0 * inside_ratio)
		var alpha := 1.0 - smooth
		var color := Color(backdrop, alpha)
		draw_rect(
			Rect2(
				MAP_CONTENT_RECT.position + Vector2(distance_from_edge, distance_from_edge),
				Vector2(step_width, MAP_CONTENT_RECT.size.y - distance_from_edge * 2.0)
			),
			color
		)
		draw_rect(
			Rect2(
				Vector2(MAP_CONTENT_RECT.end.x - distance_from_edge - step_width, MAP_CONTENT_RECT.position.y + distance_from_edge),
				Vector2(step_width, MAP_CONTENT_RECT.size.y - distance_from_edge * 2.0)
			),
			color
		)
		draw_rect(
			Rect2(
				MAP_CONTENT_RECT.position + Vector2(distance_from_edge, distance_from_edge),
				Vector2(MAP_CONTENT_RECT.size.x - distance_from_edge * 2.0, step_width)
			),
			color
		)
		draw_rect(
			Rect2(
				Vector2(MAP_CONTENT_RECT.position.x + distance_from_edge, MAP_CONTENT_RECT.end.y - distance_from_edge - step_width),
				Vector2(MAP_CONTENT_RECT.size.x - distance_from_edge * 2.0, step_width)
			),
			color
		)


func _draw_lakes() -> void:
	var palette := _terrain_palette()
	var lake_fill: Color = palette.get("lake_fill", LAKE_FILL_COLOR)
	var lake_outline: Color = palette.get("lake_outline", LAKE_OUTLINE_COLOR)
	var lakes: Array = lake_data.get("lakes", [])
	for lake in lakes:
		var source_points: Array = lake.get("points", [])
		if source_points.size() < 3:
			continue
		var polygon := PackedVector2Array()
		for point in source_points:
			if point is Array and point.size() >= 2:
				polygon.append(_geo_point(Vector2(float(point[0]), float(point[1]))))
		if polygon.size() < 3:
			continue
		draw_colored_polygon(polygon, lake_fill)
		var closed := PackedVector2Array(polygon)
		closed.append(polygon[0])
		draw_polyline(closed, lake_outline, LAKE_OUTLINE_WIDTH, true)


func _draw_rivers() -> void:
	var palette := _terrain_palette()
	var river_outer: Color = palette.get("river_outer", RIVER_OUTER_COLOR)
	var river_inner: Color = palette.get("river_inner", RIVER_INNER_COLOR)
	var river_valley_underlay := bool(palette.get("river_valley_underlay", false))
	var river_valley: Color = palette.get("river_valley", Color(0.47, 0.57, 0.49, 0.0))
	var source_rivers: Array = river_data.get("rivers", [])
	if not source_rivers.is_empty():
		for river in source_rivers:
			var source_points: Array = river.get("points", [])
			if source_points.size() < 2:
				continue
			var line := PackedVector2Array()
			for point in source_points:
				if point is Array and point.size() >= 2:
					line.append(_geo_point(Vector2(float(point[0]), float(point[1]))))
			if line.size() < 2:
				continue
			var rank := int(river.get("scalerank", 9))
			var outer_width := RIVER_MAJOR_OUTER_WIDTH if rank <= 3 else (RIVER_MEDIUM_OUTER_WIDTH if rank <= 6 else RIVER_MINOR_OUTER_WIDTH)
			var inner_width := RIVER_MAJOR_INNER_WIDTH if rank <= 3 else (RIVER_MEDIUM_INNER_WIDTH if rank <= 6 else RIVER_MINOR_INNER_WIDTH)
			if river_valley_underlay and rank <= 6:
				var valley_width := 9.0 if rank <= 3 else 5.5
				draw_polyline(line, river_valley, valley_width, true)
			draw_polyline(line, river_outer, outer_width, true)
			draw_polyline(line, river_inner, inner_width, true)
		return

	var yellow_river := PackedVector2Array([
		_geo_point(Vector2(0.15, 0.25)), _geo_point(Vector2(0.22, 0.29)),
		_geo_point(Vector2(0.30, 0.31)), _geo_point(Vector2(0.38, 0.27)),
		_geo_point(Vector2(0.43, 0.31)), _geo_point(Vector2(0.50, 0.32)),
		_geo_point(Vector2(0.58, 0.31)), _geo_point(Vector2(0.66, 0.29)),
		_geo_point(Vector2(0.73, 0.27)), _geo_point(Vector2(0.80, 0.26))
	])
	var yangtze := PackedVector2Array([
		_geo_point(Vector2(0.19, 0.55)), _geo_point(Vector2(0.25, 0.52)),
		_geo_point(Vector2(0.33, 0.48)), _geo_point(Vector2(0.40, 0.51)),
		_geo_point(Vector2(0.48, 0.50)), _geo_point(Vector2(0.55, 0.52)),
		_geo_point(Vector2(0.61, 0.50)), _geo_point(Vector2(0.69, 0.52)),
		_geo_point(Vector2(0.76, 0.48)), _geo_point(Vector2(0.84, 0.45))
	])
	var han_river := PackedVector2Array([
		_geo_point(Vector2(0.35, 0.40)), _geo_point(Vector2(0.41, 0.42)),
		_geo_point(Vector2(0.47, 0.44)), _geo_point(Vector2(0.54, 0.45)),
		_geo_point(Vector2(0.59, 0.49))
	])
	for river in [yellow_river, yangtze, han_river]:
		draw_polyline(river, river_outer, 8.0, true)
		draw_polyline(river, river_inner, 3.0, true)


func _route_hierarchy_tier(route: Dictionary) -> String:
	var display_tier := str(route.get("display_tier", ""))
	if display_tier == "strategic":
		return "strategic"
	if display_tier == "regional":
		return "regional"
	var from_id := str(route.get("from", ""))
	var to_id := str(route.get("to", ""))
	if STRATEGIC_ROUTE_KEYS.has("%s|%s" % [from_id, to_id]) or STRATEGIC_ROUTE_KEYS.has("%s|%s" % [to_id, from_id]):
		return "strategic"
	return "ordinary"


func _board_network_style(route_tier: String, level: String, overview: bool = false) -> Dictionary:
	if overview:
		return {"outer_alpha": 0.42, "inner_alpha": 0.58, "outer_width": 4.4, "inner_width": 2.0}
	if level == "far":
		return {"outer_alpha": 0.34, "inner_alpha": 0.50, "outer_width": 4.0, "inner_width": 1.8}
	if level == "middle":
		match route_tier:
			"strategic":
				return {"outer_alpha": 0.28, "inner_alpha": 0.42, "outer_width": 3.2, "inner_width": 1.35}
			"regional":
				return {"outer_alpha": 0.19, "inner_alpha": 0.29, "outer_width": 2.8, "inner_width": 1.10}
			_:
				return {"outer_alpha": 0.11, "inner_alpha": 0.17, "outer_width": 2.4, "inner_width": 0.90}
	match route_tier:
		"strategic":
			return {"outer_alpha": 0.16, "inner_alpha": 0.24, "outer_width": 3.2, "inner_width": 1.35}
		"regional":
			return {"outer_alpha": 0.10, "inner_alpha": 0.16, "outer_width": 2.8, "inner_width": 1.10}
		_:
			return {"outer_alpha": 0.06, "inner_alpha": 0.09, "outer_width": 2.3, "inner_width": 0.85}


func _route_overlay_style(route_tier: String, level: String) -> Dictionary:
	if level == "middle":
		match route_tier:
			"strategic":
				return {"alpha": 0.30, "width": 1.25, "dash": 7.0}
			"regional":
				return {"alpha": 0.20, "width": 1.0, "dash": 6.0}
			_:
				return {"alpha": 0.11, "width": 0.85, "dash": 4.5}
	match route_tier:
		"strategic":
			return {"alpha": 0.34, "width": 1.35, "dash": 7.0}
		"regional":
			return {"alpha": 0.22, "width": 1.05, "dash": 6.0}
		_:
			return {"alpha": 0.12, "width": 0.85, "dash": 4.5}


func _corridor_style(corridor_tier: String, level: String) -> Dictionary:
	if level == "far":
		return {"outer_alpha": 0.18, "inner_alpha": 0.52, "outer_width": 8.0, "inner_width": 2.0, "dash": 11.0}
	if level == "middle":
		if corridor_tier == "strategic":
			return {"outer_alpha": 0.20, "inner_alpha": 0.58, "outer_width": 9.0, "inner_width": 2.3, "dash": 10.0}
		return {"outer_alpha": 0.11, "inner_alpha": 0.34, "outer_width": 6.5, "inner_width": 1.5, "dash": 8.0}
	if corridor_tier == "strategic":
		return {"outer_alpha": 0.14, "inner_alpha": 0.48, "outer_width": 7.5, "inner_width": 2.0, "dash": 9.0}
	return {"outer_alpha": 0.09, "inner_alpha": 0.38, "outer_width": 5.5, "inner_width": 1.35, "dash": 7.0}


func _draw_routes() -> void:
	var by_id := {}
	for place in places:
		by_id[str(place.get("id", ""))] = _geo_point(Vector2(float(place.get("x", 0.5)), float(place.get("y", 0.5))))
	var level := _detail_level()
	for route in routes:
		if not _is_route_visible(route):
			continue
		var from_id := str(route.get("from", ""))
		var to_id := str(route.get("to", ""))
		if not by_id.has(from_id) or not by_id.has(to_id):
			continue
		var style := _route_overlay_style(_route_hierarchy_tier(route), level)
		draw_dashed_line(
			by_id[from_id], by_id[to_id],
			Color(0.30, 0.25, 0.16, float(style.get("alpha", 0.0))),
			_screen_pixels(float(style.get("width", 1.0))), _screen_pixels(float(style.get("dash", 6.0))), true, true
		)


func _draw_board_network() -> void:
	# 城池之间的连线是自由推演用的沙盘关系网，不是历史道路复原。
	# 它只读取既有 map_routes，不参与命中、吸附、行动或存档。
	var by_id := {}
	for place in places:
		by_id[str(place.get("id", ""))] = _geo_point(Vector2(float(place.get("x", 0.5)), float(place.get("y", 0.5))))
	var level := _detail_level()
	var overview := _place_label_level() == "overview"
	for route_index in range(routes.size()):
		var route: Dictionary = routes[route_index]
		var from_id := str(route.get("from", ""))
		var to_id := str(route.get("to", ""))
		if not by_id.has(from_id) or not by_id.has(to_id):
			continue
		var from_point: Vector2 = by_id[from_id]
		var to_point: Vector2 = by_id[to_id]
		var route_points := board_route_curve(from_point, to_point, route_index)
		var style := _board_network_style(_route_hierarchy_tier(route), level, overview)
		draw_polyline(route_points, Color(0.08, 0.09, 0.07, float(style.get("outer_alpha", 0.0))), _screen_pixels(float(style.get("outer_width", 1.0))), true)
		draw_polyline(route_points, Color(0.91, 0.84, 0.64, float(style.get("inner_alpha", 0.0))), _screen_pixels(float(style.get("inner_width", 1.0))), true)


static func board_route_curve(from_point: Vector2, to_point: Vector2, route_index: int) -> PackedVector2Array:
	var result := PackedVector2Array()
	var delta := to_point - from_point
	var distance := delta.length()
	if distance <= 0.001:
		result.append(from_point)
		result.append(to_point)
		return result
	var normal := Vector2(-delta.y, delta.x).normalized()
	var direction := -1.0 if route_index % 2 == 0 else 1.0
	var bend := clampf(distance * 0.065, 7.0, 30.0) * direction
	var control := (from_point + to_point) * 0.5 + normal * bend
	for sample in range(17):
		var t := float(sample) / 16.0
		var inverse := 1.0 - t
		result.append(
			from_point * inverse * inverse
			+ control * 2.0 * inverse * t
			+ to_point * t * t
		)
	return result


func _draw_strategic_corridors() -> void:
	if not show_strategic_corridors:
		return
	var by_id := {}
	for place in places:
		by_id[str(place.get("id", ""))] = _geo_point(Vector2(float(place.get("x", 0.5)), float(place.get("y", 0.5))))
	var level := _detail_level()
	for route in routes:
		if not _is_corridor_route_visible(route):
			continue
		var from_id := str(route.get("from", ""))
		var to_id := str(route.get("to", ""))
		if not by_id.has(from_id) or not by_id.has(to_id):
			continue
		var from_point: Vector2 = by_id[from_id]
		var to_point: Vector2 = by_id[to_id]
		var style := _corridor_style(str(route.get("corridor_tier", "regional")), level)
		draw_line(from_point, to_point, Color(0.85, 0.67, 0.27, float(style.get("outer_alpha", 0.0))), _screen_pixels(float(style.get("outer_width", 6.0))), true)
		draw_dashed_line(from_point, to_point, Color(0.43, 0.28, 0.08, float(style.get("inner_alpha", 0.0))), _screen_pixels(float(style.get("inner_width", 1.5))), _screen_pixels(float(style.get("dash", 8.0))), true, true)


func _draw_historical_contexts() -> void:
	var layout := _ensure_historical_context_layout()
	var entries: Dictionary = layout.get("entries", {})
	for context_id_value in layout.get("draw_order", []):
		var context_id := str(context_id_value)
		if not entries.has(context_id):
			continue
		var entry: Dictionary = entries[context_id]
		var anchor: Vector2 = entry.get("anchor", Vector2.ZERO)
		var tag_rect: Rect2 = entry.get("rect", Rect2())
		if not _semantic_rect_visible(tag_rect) and not _semantic_point_visible(anchor, 48.0):
			continue
		var is_romance := bool(entry.get("is_romance", false))
		var label_text := str(entry.get("label_text", ""))
		var font_size := int(entry.get("font_size", 8))
		var padding_screen: Vector2 = entry.get("padding_screen", Vector2.ZERO)
		var text_size_screen: Vector2 = entry.get("text_size_screen", Vector2.ZERO)
		var historical_tint := Color(0.28, 0.39, 0.27, 0.82)
		var romance_tint := Color(0.43, 0.28, 0.31, 0.82)
		var tint := romance_tint if is_romance else historical_tint
		draw_line(anchor, tag_rect.get_center(), Color(tint.r, tint.g, tint.b, 0.36), _screen_pixels(1.0), true)
		_begin_screen_space_draw(_snap_to_screen_pixel(anchor))
		draw_circle(Vector2.ZERO, 3.2, Color(0.88, 0.80, 0.58, 0.90))
		draw_circle(Vector2.ZERO, 2.0, tint)
		_end_screen_space_draw()
		_begin_screen_space_draw(_snap_to_screen_pixel(tag_rect.position))
		var tag_size_screen := tag_rect.size * maxf(view_zoom, 0.1)
		var local_tag_rect := Rect2(Vector2.ZERO, tag_size_screen)
		draw_rect(local_tag_rect, Color(0.82, 0.79, 0.62, 0.88), true)
		draw_rect(local_tag_rect, Color(tint.r, tint.g, tint.b, 0.70), false, 1.0, true)
		var text_position := padding_screen + Vector2(0.0, text_size_screen.y * 0.78)
		var halo_step := 0.8
		draw_string_outline(MapFont, text_position, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, maxi(1, roundi(halo_step)), Color(0.88, 0.84, 0.68, 0.78))
		draw_string(MapFont, text_position, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(tint.r * 0.58, tint.g * 0.58, tint.b * 0.58, 0.96))
		_end_screen_space_draw()


func _ensure_historical_context_layout() -> Dictionary:
	if not _historical_context_layout_cache.is_empty():
		return _historical_context_layout_cache
	var entries := {}
	var draw_order: Array[String] = []
	if show_historical_context and not historical_context_records.is_empty():
		var place_points := {}
		for place in places:
			if place is Dictionary:
				place_points[str(place.get("id", ""))] = _geo_point(Vector2(float(place.get("x", 0.5)), float(place.get("y", 0.5))))
		for record_value in historical_context_records:
			if not (record_value is Dictionary):
				continue
			var record: Dictionary = record_value
			if not _is_historical_context_visible(record):
				continue
			var context_id := str(record.get("id", "")).strip_edges()
			var anchor_place_id := str(record.get("anchor_place_id", ""))
			if context_id.is_empty() or not place_points.has(anchor_place_id):
				continue
			var anchor: Vector2 = place_points[anchor_place_id]
			var offset_value: Array = record.get("label_offset", [14, -32])
			var offset_screen := Vector2(float(offset_value[0]), float(offset_value[1]))
			var label_origin := anchor + offset_screen / maxf(view_zoom, 0.1)
			var is_romance := str(record.get("layer", "")) == "romance"
			var runtime_year := int(record.get("_runtime_layer_year", (record.get("date", {}) as Dictionary).get("year", 0)))
			var prefix := "演义 · " if is_romance else "%d · " % runtime_year
			var label_text := prefix + str(record.get("label", ""))
			var font_size := 12
			var text_size_screen := MapFont.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			var padding_screen := Vector2(5.0, 3.0)
			var world_per_screen_pixel := 1.0 / maxf(view_zoom, 0.1)
			entries[context_id] = {
				"anchor": anchor,
				"anchor_place_id": anchor_place_id,
				"rect": Rect2(
					label_origin,
					(text_size_screen + padding_screen * 2.0) * world_per_screen_pixel
				),
				"is_romance": is_romance,
				"label_text": label_text,
				"font_size": font_size,
				"padding_screen": padding_screen,
				"text_size_screen": text_size_screen
			}
			draw_order.append(context_id)
	_historical_context_layout_cache = {"entries": entries, "draw_order": draw_order}
	return _historical_context_layout_cache


func _draw_river_labels() -> void:
	for river_label in river_data.get("labels", []):
		if not (river_label is Dictionary) or not _is_river_label_visible(river_label):
			continue
		var tier := int(river_label.get("tier", 3))
		var target_size := 18.0 if tier == 1 else (16.0 if tier == 2 else 15.0)
		var font_size := maxi(8, roundi(target_size))
		var label_text := str(river_label.get("name", ""))
		if label_text.is_empty():
			continue
		var point := _geo_point(Vector2(float(river_label.get("x", 0.5)), float(river_label.get("y", 0.5))))
		if not _semantic_point_visible(point):
			continue
		var rotation := deg_to_rad(float(river_label.get("rotation_deg", 0.0)))
		var text_size := MapFont.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var origin := Vector2(-text_size.x * 0.5, font_size * 0.36)
		var halo_step := 1.0
		var text_alpha := _river_label_alpha(tier)
		_begin_screen_space_draw(_snap_to_screen_pixel(point), rotation)
		draw_string_outline(MapFont, origin, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, maxi(1, roundi(halo_step)), _geographic_label_halo(Color(0.84, 0.86, 0.72, text_alpha * 0.78)))
		draw_string(MapFont, origin, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.12, 0.29, 0.29, text_alpha))
		_end_screen_space_draw()


func _river_label_alpha(tier: int) -> float:
	if terrain_visual_profile == TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1:
		return 0.96 if tier == 1 else (0.90 if tier == 2 else 0.84)
	if _detail_level() == "near":
		return 0.82 if tier == 1 else (0.74 if tier == 2 else 0.66)
	if _detail_level() == "middle":
		return 0.78 if tier == 1 else (0.70 if tier == 2 else 0.62)
	return 0.74 if tier == 1 else (0.66 if tier == 2 else 0.58)


func _visible_river_label_count() -> int:
	var count := 0
	for river_label in river_data.get("labels", []):
		if river_label is Dictionary and _is_river_label_visible(river_label):
			count += 1
	return count


func _draw_mountain_labels() -> void:
	for mountain in mountains:
		if not _is_mountain_visible(mountain):
			continue
		var tier := int(mountain.get("tier", 3))
		var target_size := 15.0 if tier == 1 else (14.0 if tier == 2 else 13.0)
		var font_size := maxi(8, roundi(target_size))
		var text := str(mountain.get("name", ""))
		var text_size := MapFont.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var point := _geo_point(Vector2(float(mountain.get("x", 0.5)), float(mountain.get("y", 0.5))))
		if not _semantic_point_visible(point):
			continue
		var rotation := deg_to_rad(float(mountain.get("rotation_deg", 0.0)))
		var origin := Vector2(-text_size.x * 0.5, font_size * 0.35)
		var halo_step := 0.8
		var text_alpha := _mountain_label_alpha(tier)
		_begin_screen_space_draw(_snap_to_screen_pixel(point), rotation)
		draw_string_outline(MapFont, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, maxi(1, roundi(halo_step)), _geographic_label_halo(Color(0.84, 0.82, 0.66, text_alpha * 0.76)))
		draw_string(MapFont, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.18, 0.24, 0.17, text_alpha))
		_end_screen_space_draw()


func _mountain_label_alpha(tier: int) -> float:
	if terrain_visual_profile == TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1:
		return 0.86 if tier == 1 else (0.78 if tier == 2 else 0.70)
	if _detail_level() == "near":
		return 0.72 if tier == 1 else (0.62 if tier == 2 else 0.52)
	if _detail_level() == "middle":
		return 0.66 if tier == 1 else (0.56 if tier == 2 else 0.46)
	return 0.58 if tier == 1 else (0.48 if tier == 2 else 0.40)


func _visible_mountain_label_count() -> int:
	var count := 0
	for mountain in mountains:
		if mountain is Dictionary and _is_mountain_visible(mountain):
			count += 1
	return count


func _draw_province_labels() -> void:
	if _place_label_level() == "overview" or _detail_level() == "far":
		return
	var target_size := _province_label_target_size()
	var font_size := maxi(8, roundi(target_size))
	var label_width := 130.0
	var color_alpha := _province_label_alpha()
	for entry in _visible_province_label_entries():
		var point_world: Vector2 = entry.get("point_world", Vector2.ZERO)
		if not _semantic_point_visible(point_world):
			continue
		var origin := Vector2(-label_width * 0.5, 0)
		var text := str(entry.get("name", ""))
		_begin_screen_space_draw(_snap_to_screen_pixel(point_world))
		draw_string_outline(MapFont, origin, text, HORIZONTAL_ALIGNMENT_CENTER, label_width, font_size, 1, _geographic_label_halo(Color(0.96, 0.90, 0.72, color_alpha * 0.68)))
		draw_string(MapFont, origin, text, HORIZONTAL_ALIGNMENT_CENTER, label_width, font_size, Color(0.13, 0.16, 0.10, color_alpha))
		_end_screen_space_draw()


func _province_label_alpha() -> float:
	if terrain_visual_profile == TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1:
		return 0.62 if _detail_level() in ["near", "middle"] else 0.0
	if _detail_level() == "near":
		return 0.30
	if _detail_level() == "middle":
		return 0.34
	return 0.0


func _geographic_label_halo(original: Color) -> Color:
	# A thin screen-space halo separates text from relief without enlarging labels.
	if terrain_visual_profile == TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1:
		return Color(0.96, 0.96, 0.85, 0.80)
	return original


func _province_label_target_size() -> float:
	if _place_label_level() == "overview":
		return 23.0
	return 25.0 if _detail_level() == "far" else (22.0 if _detail_level() == "middle" else 19.0)


func _visible_province_label_entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if _place_label_level() == "overview" or _detail_level() == "far":
		return result
	var target_size := _province_label_target_size()
	var font_size_screen := maxi(8, roundi(target_size))
	var ascent := MapFont.get_ascent(font_size_screen)
	var descent := MapFont.get_descent(font_size_screen)
	var label_width_screen := 130.0
	var place_rects: Dictionary = get_place_label_rects_screen(view_zoom)
	for raw_entry in PROVINCE_LABELS:
		var entry: Dictionary = raw_entry
		var point_world := _geo_point(entry.get("point", Vector2.ZERO))
		var point_screen := point_world * view_zoom
		var rect_screen := Rect2(
			Vector2(point_screen.x - label_width_screen * 0.5, point_screen.y - ascent),
			Vector2(label_width_screen, ascent + descent)
		).grow(3.0)
		var blocked := false
		for place_rect_value in place_rects.values():
			var place_rect: Rect2 = place_rect_value
			if rect_screen.intersects(place_rect.grow(4.0)):
				blocked = true
				break
		if blocked:
			continue
		result.append({
			"name": str(entry.get("name", "")),
			"point_world": point_world,
			"rect_screen": rect_screen
		})
	return result


func _draw_places() -> void:
	var layout: Dictionary = _place_label_layout_cache.get(_place_label_level(), {})
	if layout.is_empty():
		layout = _ensure_place_label_layout()
	var layout_entries: Dictionary = layout.get("entries", {})
	# 节点先统一绘制，文字再按低优先级到高优先级叠放；无法完全避开的情况下，战略名称仍保持在最上层。
	for place in places:
		var place_id := str(place.get("id", ""))
		if not _is_place_symbol_visible(place_id):
			continue
		var point := _geo_point(Vector2(float(place.get("x", 0.5)), float(place.get("y", 0.5))))
		if not _semantic_point_visible(point, 48.0):
			continue
		var place_type := str(place.get("type", "city"))
		var tier := _place_tier(place_id)
		_begin_screen_space_draw(_snap_to_screen_pixel(point))
		_draw_place_symbol(Vector2.ZERO, place_type, tier)
		_end_screen_space_draw()
	for place_id_value in layout.get("draw_order", []):
		var place_id := str(place_id_value)
		if not layout_entries.has(place_id):
			continue
		var entry: Dictionary = layout_entries[place_id]
		var point: Vector2 = entry.get("point", Vector2.ZERO)
		if not _semantic_point_visible(point):
			continue
		var label_offset: Vector2 = entry.get("offset_screen", Vector2(8, 5))
		var label_origin := _snap_to_screen_pixel(point + label_offset / maxf(view_zoom, 0.1))
		var font_size := maxi(8, roundi(float(entry.get("target_font_size", 17.0))))
		_begin_screen_space_draw(label_origin)
		_draw_place_label(Vector2.ZERO, str(entry.get("text", "")), font_size)
		_end_screen_space_draw()


func _ensure_place_label_layout() -> Dictionary:
	var key := _place_label_level()
	if not _place_label_layout_cache.has(key):
		_place_label_layout_cache[key] = _build_place_label_layout(key)
		_place_label_layout_builds += 1
	return _place_label_layout_cache.get(key, {})


func _build_place_label_layout(level: String) -> Dictionary:
	var canonical_zoom := float(LABEL_LAYOUT_ZOOM.get(level, 1.0))
	var sample_zooms: Array[float] = []
	for sample_value in LABEL_LAYOUT_SAMPLES.get(level, [canonical_zoom]):
		sample_zooms.append(float(sample_value))
	var visible_entries: Array[Dictionary] = []
	var symbol_rect_sets: Array[Dictionary] = []
	var content_rects: Array[Rect2] = []
	for sample_zoom in sample_zooms:
		symbol_rect_sets.append({})
		content_rects.append(Rect2(MAP_CONTENT_RECT.position * sample_zoom, MAP_CONTENT_RECT.size * sample_zoom))
	for place in places:
		var place_id := str(place.get("id", ""))
		if not _is_place_visible(place_id):
			continue
		var tier := _place_tier(place_id)
		var text := str(place.get("map_label", place.get("name", "")))
		var target_font_size := _place_target_font_size(str(place.get("type", "city")), tier)
		var font_size := roundi(target_font_size)
		var text_size := MapFont.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var point := _geo_point(Vector2(float(place.get("x", 0.5)), float(place.get("y", 0.5))))
		var point_screen := point * canonical_zoom
		var symbol_clearance := _place_symbol_clearance_screen(str(place.get("type", "city")))
		var symbol_side := symbol_clearance * 2.0
		for sample_index in range(sample_zooms.size()):
			var sample_point_screen := point * sample_zooms[sample_index]
			symbol_rect_sets[sample_index][place_id] = Rect2(sample_point_screen - Vector2.ONE * symbol_clearance, Vector2.ONE * symbol_side)
		visible_entries.append({
			"id": place_id,
			"text": text,
			"point": point,
			"point_screen": point_screen,
			"tier": tier,
			"priority": _place_label_priority(place, tier),
			"target_font_size": target_font_size,
			"font_size": font_size,
			"text_size": text_size,
			"place": place
		})
	visible_entries.sort_custom(_sort_place_label_priority)
	var accepted_rect_sets: Array = []
	for _sample_zoom in sample_zooms:
		var empty_rects: Array[Rect2] = []
		accepted_rect_sets.append(empty_rects)
	var entries: Dictionary = {}
	var collision_count := 0
	for raw_entry in visible_entries:
		var entry: Dictionary = raw_entry
		var place: Dictionary = entry.get("place", {})
		var candidates := _place_label_candidates_screen(place, float((entry.get("text_size", Vector2.ZERO) as Vector2).x))
		var best_offset := Vector2(8, 5)
		var best_rect := Rect2()
		var best_score := INF
		var best_candidate_index := 0
		var best_sample_rects: Array[Rect2] = []
		for candidate_index in range(candidates.size()):
			var offset: Vector2 = candidates[candidate_index]
			var sample_rects: Array[Rect2] = []
			var score := 0.0
			for sample_index in range(sample_zooms.size()):
				var sample_origin: Vector2 = (entry.get("point", Vector2.ZERO) as Vector2) * sample_zooms[sample_index] + offset
				sample_origin = sample_origin.round()
				var sample_rect := _place_label_rect_screen(sample_origin, entry.get("text_size", Vector2.ZERO), int(entry.get("font_size", 17)))
				sample_rects.append(sample_rect)
				score += _place_label_collision_score(sample_rect, str(entry.get("id", "")), accepted_rect_sets[sample_index], symbol_rect_sets[sample_index], content_rects[sample_index])
			if score < best_score:
				best_score = score
				best_offset = offset
				var canonical_origin := ((entry.get("point", Vector2.ZERO) as Vector2) * canonical_zoom + offset).round()
				best_rect = _place_label_rect_screen(canonical_origin, entry.get("text_size", Vector2.ZERO), int(entry.get("font_size", 17)))
				best_candidate_index = candidate_index
				best_sample_rects = sample_rects
			if score <= LABEL_COLLISION_EPSILON:
				break
		if best_score > LABEL_COLLISION_EPSILON:
			collision_count += 1
		for sample_index in range(sample_zooms.size()):
			accepted_rect_sets[sample_index].append(best_sample_rects[sample_index])
		entries[str(entry.get("id", ""))] = {
			"text": str(entry.get("text", "")),
			"point": entry.get("point", Vector2.ZERO),
			"offset_screen": best_offset,
			"rect_screen": best_rect,
			"target_font_size": float(entry.get("target_font_size", 17.0)),
			"priority": int(entry.get("priority", 0)),
			"tier": int(entry.get("tier", 3)),
			"candidate_index": best_candidate_index,
			"collision_score": best_score
		}
	var draw_order: Array[String] = []
	for index in range(visible_entries.size() - 1, -1, -1):
		draw_order.append(str(visible_entries[index].get("id", "")))
	return {
		"canonical_zoom": canonical_zoom,
		"collision_count": collision_count,
		"entries": entries,
		"draw_order": draw_order
	}


func _sort_place_label_priority(a: Dictionary, b: Dictionary) -> bool:
	var a_priority := int(a.get("priority", 0))
	var b_priority := int(b.get("priority", 0))
	if a_priority != b_priority:
		return a_priority > b_priority
	var a_tier := int(a.get("tier", 3))
	var b_tier := int(b.get("tier", 3))
	if a_tier != b_tier:
		return a_tier < b_tier
	return str(a.get("id", "")).naturalnocasecmp_to(str(b.get("id", ""))) < 0


func _place_target_font_size(place_type_or_tier: Variant, tier := -1) -> float:
	var place_type := str(place_type_or_tier)
	var resolved_tier := tier
	if resolved_tier < 0:
		resolved_tier = int(place_type_or_tier)
		place_type = "city"
	var normalized_type := _normalize_place_symbol_type(place_type)
	if _place_label_level() == "overview":
		return 17.0 if resolved_tier == 1 else 15.0
	if _detail_level() == "far":
		return 17.0 if resolved_tier == 1 else (15.0 if resolved_tier == 2 else 14.0)
	if _detail_level() == "middle":
		if normalized_type == "capital":
			return 19.0
		return 18.0 if resolved_tier == 1 else (16.0 if resolved_tier == 2 else 15.0)
	if normalized_type == "capital":
		return 20.0
	return 19.0 if resolved_tier == 1 else (17.0 if resolved_tier == 2 else 16.0)


func _place_label_priority(place: Dictionary, tier: int) -> int:
	if place.has("label_priority"):
		return clampi(int(place.get("label_priority", 0)), 0, 200)
	var place_type := str(place.get("type", "city"))
	if place_type == "capital":
		return 120
	if place_type in ["pass", "ferry", "water_gate"]:
		return 110
	if place_type == "battlefield":
		return 105
	return 100 if tier == 1 else (70 if tier == 2 else 40)


func _place_symbol_clearance_screen(place_type: String) -> float:
	var normalized_type := _normalize_place_symbol_type(place_type)
	var detail_level := _detail_level()
	if normalized_type == "battlefield":
		if detail_level == "near":
			return 12.0
		if detail_level == "middle":
			return 11.0
		return 10.0
	if normalized_type in ["city", "capital"]:
		if detail_level == "near":
			return 11.0
		if detail_level == "middle":
			return 10.0
	return LABEL_SYMBOL_CLEARANCE_SCREEN


func get_place_symbol_contract(place_type: String, tier: int) -> Dictionary:
	var normalized_type := _normalize_place_symbol_type(place_type)
	var safe_tier := clampi(tier, 1, 3)
	var shape := "city_gate_seal"
	match normalized_type:
		"capital":
			shape = "capital_gatehouse_seal"
		"pass":
			shape = "mountain_gate"
		"port":
			shape = "harbor_ring"
		"water_gate":
			shape = "sluice_diamond"
		"ferry":
			shape = "ferry_diamond"
		"battlefield":
			shape = "broken_field_ring"
	var candidate_pass_applied := (
		normalized_type == "pass"
		and pass_symbol_variant == PASS_SYMBOL_VARIANT_PAPER_INK_V1
		and _detail_level() in ["middle", "near"]
	)
	if candidate_pass_applied:
		return {
			"style_version": PASS_SYMBOL_REVIEW_STYLE_VERSION,
			"place_type": normalized_type,
			"shape": "mountain_gate_paper_ink",
			"variant_id": PASS_SYMBOL_VARIANT_PAPER_INK_V1,
			"max_diameter_screen": PASS_SYMBOL_REVIEW_DISPLAY_PX,
			"clearance_screen": _place_symbol_clearance_screen(normalized_type),
			"screen_constant": true,
			"texture_backed": true,
			"candidate_only": true
		}
	var hierarchy_role := _city_hierarchy_role(normalized_type, safe_tier)
	var hierarchy_metrics := {}
	if not hierarchy_role.is_empty():
		hierarchy_metrics = (
			_far_city_symbol_metrics(normalized_type, safe_tier)
			if _detail_level() == "far"
			else _detail_city_symbol_metrics(normalized_type, safe_tier)
		)
	var base_diameter := _place_symbol_extent_screen(normalized_type, safe_tier) * 2.0
	var width_screen := float(hierarchy_metrics.get("width_screen", base_diameter))
	var height_screen := float(hierarchy_metrics.get("height_screen", base_diameter))
	var lod_shape := str(hierarchy_metrics.get("outer_shape", shape))
	var strategic_node_role := _strategic_node_role(normalized_type, safe_tier)
	return {
		"style_version": PLACE_SYMBOL_STYLE_VERSION,
		"lod_style_version": FAR_CITY_SYMBOL_STYLE_VERSION if _detail_level() == "far" and not hierarchy_metrics.is_empty() else PLACE_SYMBOL_STYLE_VERSION,
		"hierarchy_style_version": CITY_HIERARCHY_STYLE_VERSION,
		"hierarchy_role": hierarchy_role,
		"place_type": normalized_type,
		"shape": shape,
		"lod_shape": lod_shape,
		"outer_shape": lod_shape,
		"variant_id": PASS_SYMBOL_VARIANT_V3,
		"width_screen": width_screen,
		"height_screen": height_screen,
		"max_diameter_screen": maxf(width_screen, height_screen),
		"clearance_screen": _place_symbol_clearance_screen(normalized_type),
		"screen_constant": true,
		"texture_backed": false,
		"identity_channel": "silhouette_not_color" if not hierarchy_role.is_empty() else ("silhouette_and_material_tint" if not strategic_node_role.is_empty() else "symbol_type"),
		"strategic_node_style_version": STRATEGIC_NODE_STYLE_VERSION if not strategic_node_role.is_empty() else 0,
		"strategic_node_role": strategic_node_role,
		"material_tint": _strategic_node_material_tint(normalized_type),
		"label_font_size_screen": _place_target_font_size(normalized_type, safe_tier),
	}


func _city_hierarchy_role(normalized_type: String, tier: int) -> String:
	if normalized_type == "capital":
		return "capital"
	if normalized_type == "city":
		if tier == 1:
			return "strategic_city"
		if tier == 2:
			return "regional_city"
		return "local_city"
	return ""


func _strategic_node_role(normalized_type: String, tier: int) -> String:
	match normalized_type:
		"pass":
			return "strategic_pass" if tier == 1 else "regional_pass"
		"water_gate", "ferry":
			return "water_gate"
		"battlefield":
			return "battlefield_zone"
	return ""


func _strategic_node_material_tint(normalized_type: String) -> String:
	match normalized_type:
		"pass":
			return "ink_brown"
		"water_gate", "ferry":
			return "river_teal"
		"battlefield":
			return "rust_red"
	return ""


func _far_city_symbol_metrics(normalized_type: String, tier: int) -> Dictionary:
	var hierarchy_role := _city_hierarchy_role(normalized_type, tier)
	match hierarchy_role:
		"capital":
			return {
				"width_screen": 17.0,
				"height_screen": 17.0,
				"outer_shape": "capital_double_frame_gatehouse"
			}
		"strategic_city":
			return {
				"width_screen": 16.0,
				"height_screen": 12.0,
				"outer_shape": "strategic_twin_tower_city"
			}
		"regional_city":
			return {
				"width_screen": 12.0,
				"height_screen": 10.0,
				"outer_shape": "regional_wall_gate_city"
			}
		"local_city":
			return {
				"width_screen": 10.0,
				"height_screen": 8.0,
				"outer_shape": "local_single_gate_city"
			}
	return {}


func _detail_city_symbol_metrics(normalized_type: String, tier: int) -> Dictionary:
	match _city_hierarchy_role(normalized_type, tier):
		"capital":
			return {
				"width_screen": 20.0,
				"height_screen": 20.0,
				"outer_shape": "capital_double_frame_gatehouse"
			}
		"strategic_city":
			return {
				"width_screen": 19.0,
				"height_screen": 15.0,
				"outer_shape": "strategic_twin_tower_city"
			}
		"regional_city":
			return {
				"width_screen": 15.0,
				"height_screen": 12.0,
				"outer_shape": "regional_wall_gate_city"
			}
		"local_city":
			return {
				"width_screen": 11.0,
				"height_screen": 9.0,
				"outer_shape": "local_single_gate_city"
			}
	return {}


func _normalize_place_symbol_type(place_type: String) -> String:
	if place_type in ["capital", "pass", "port", "water_gate", "ferry", "battlefield"]:
		return place_type
	return "city"


func _place_symbol_extent_screen(place_type: String, tier: int) -> float:
	var safe_tier := clampi(tier, 1, 3)
	match _normalize_place_symbol_type(place_type):
		"capital":
			return 8.4 if safe_tier == 1 else 7.6
		"pass":
			return 7.4 if safe_tier == 1 else (6.6 if safe_tier == 2 else 5.8)
		"port", "water_gate", "ferry":
			return 7.1 if safe_tier == 1 else (6.4 if safe_tier == 2 else 5.6)
		"battlefield":
			return 9.0 if safe_tier <= 2 else 8.2
		_:
			return 9.0 if safe_tier == 1 else (8.0 if safe_tier == 2 else 7.0)


func _place_label_candidates_screen(place: Dictionary, text_width: float) -> Array[Vector2]:
	var place_id := str(place.get("id", ""))
	var preferred: Vector2 = PLACE_LABEL_OFFSETS.get(place_id, Vector2(8, 5))
	var raw_offset: Variant = place.get("label_offset", null)
	if raw_offset is Array and raw_offset.size() == 2:
		preferred = Vector2(float(raw_offset[0]), float(raw_offset[1]))
	var left_x := -text_width - 8.0
	var candidate_values: Array[Vector2] = [
		preferred,
		Vector2(8, -7), Vector2(8, 18),
		Vector2(left_x, -7), Vector2(left_x, 18),
		Vector2(-text_width * 0.5, -12), Vector2(-text_width * 0.5, 26),
		Vector2(20, -7), Vector2(20, 20),
		Vector2(-text_width - 20.0, -7), Vector2(-text_width - 20.0, 20),
		Vector2(-text_width * 0.5, -24), Vector2(-text_width * 0.5, 40),
		# 最小 LOD 边界的相邻节点最密集；仅在近邻候选都冲突时使用外圈位置。
		Vector2(32, -20), Vector2(32, 36),
		Vector2(-text_width - 32.0, -20), Vector2(-text_width - 32.0, 36),
		Vector2(-text_width * 0.5, -44), Vector2(-text_width * 0.5, 58),
		Vector2(-text_width - 80.0, -44), Vector2(-text_width - 80.0, 36)
	]
	var unique: Array[Vector2] = []
	for candidate in candidate_values:
		var duplicate := false
		for existing in unique:
			if existing.distance_squared_to(candidate) < 0.01:
				duplicate = true
				break
		if not duplicate:
			unique.append(candidate)
	return unique


func _place_label_rect_screen(origin_screen: Vector2, text_size_value: Variant, font_size: int) -> Rect2:
	var text_size: Vector2 = text_size_value if text_size_value is Vector2 else Vector2.ZERO
	var ascent := MapFont.get_ascent(font_size)
	var descent := MapFont.get_descent(font_size)
	var rect := Rect2(Vector2(origin_screen.x, origin_screen.y - ascent), Vector2(text_size.x, ascent + descent))
	return rect.grow(LABEL_HALO_MARGIN_SCREEN)


func _place_label_collision_score(rect: Rect2, place_id: String, accepted_rects: Array[Rect2], symbol_rects: Dictionary, content_rect: Rect2) -> float:
	var score := _rect_outside_area(rect, content_rect) * 4.0
	for accepted in accepted_rects:
		if rect.intersects(accepted):
			score += rect.intersection(accepted).get_area()
	for blocker_id in symbol_rects:
		if str(blocker_id) == place_id:
			continue
		var blocker: Rect2 = symbol_rects[blocker_id]
		if rect.intersects(blocker):
			score += rect.intersection(blocker).get_area() * 2.0
	return score


func _rect_outside_area(rect: Rect2, boundary: Rect2) -> float:
	var inside_area := rect.intersection(boundary).get_area() if rect.intersects(boundary) else 0.0
	return maxf(0.0, rect.get_area() - inside_area)


func _draw_place_symbol(point: Vector2, place_type: String, tier: int) -> void:
	var normalized_type := _normalize_place_symbol_type(place_type)
	var extent_screen := _place_symbol_extent_screen(normalized_type, tier)
	var extent := _screen_pixels(extent_screen)
	var parchment := Color(0.96, 0.89, 0.70, 0.94)
	var ink := Color(0.27, 0.17, 0.11, 0.94)
	var ink_soft := Color(0.27, 0.17, 0.11, 0.68)
	var water_ink := Color(0.16, 0.37, 0.39, 0.94)
	var outline := _screen_pixels(0.9)

	if _detail_level() == "far":
		var hierarchy_metrics := _far_city_symbol_metrics(normalized_type, tier)
		if not hierarchy_metrics.is_empty():
			_draw_far_city_hierarchy_symbol(
				point,
				normalized_type,
				tier,
				hierarchy_metrics,
				parchment,
				ink,
				ink_soft
			)
			return
		var overview_extent := _screen_pixels(4.8 if tier == 1 else (4.0 if tier == 2 else 3.4))
		if normalized_type in ["pass", "water_gate", "ferry"]:
			var diamond := PackedVector2Array([
				point + Vector2(0, -overview_extent),
				point + Vector2(overview_extent, 0),
				point + Vector2(0, overview_extent),
				point + Vector2(-overview_extent, 0),
			])
			draw_colored_polygon(diamond, parchment)
			draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), ink, _screen_pixels(1.0), true)
		else:
			draw_circle(point, overview_extent + _screen_pixels(1.4), Color(0.08, 0.09, 0.07, 0.82))
			draw_circle(point, overview_extent, parchment)
			draw_arc(point, overview_extent, 0.0, TAU, 18, ink, _screen_pixels(1.0), true)
		return

	if normalized_type == "battlefield":
		var blade_half := extent * 0.57
		var stroke := _screen_pixels(1.15)
		var battlefield_ink := Color(0.45, 0.22, 0.12, 0.82)
		draw_circle(point, extent, Color(0.63, 0.35, 0.22, 0.18))
		# 两段不闭合的范围环明确它是“区域参照”，而不是精确城点或史实边界。
		draw_arc(point, extent, -2.86, -0.28, 14, battlefield_ink, _screen_pixels(1.35), true)
		draw_arc(point, extent, 0.28, 2.86, 14, battlefield_ink, _screen_pixels(1.35), true)
		draw_line(point + Vector2(-blade_half, -blade_half), point + Vector2(blade_half, blade_half), battlefield_ink, stroke, true)
		draw_line(point + Vector2(-blade_half, blade_half), point + Vector2(blade_half, -blade_half), battlefield_ink, stroke, true)
		draw_circle(point, _screen_pixels(1.25), parchment)
		return

	var hierarchy_role := _city_hierarchy_role(normalized_type, tier)
	if not hierarchy_role.is_empty():
		_draw_detail_city_hierarchy_symbol(
			point,
			hierarchy_role,
			_detail_city_symbol_metrics(normalized_type, tier),
			parchment,
			ink,
			ink_soft
		)
		return

	if normalized_type == "pass":
		if pass_symbol_variant == PASS_SYMBOL_VARIANT_PAPER_INK_V1 and _pass_paper_ink_texture != null:
			var candidate_size := _screen_pixels(PASS_SYMBOL_REVIEW_DISPLAY_PX)
			var candidate_rect := Rect2(
				point - Vector2.ONE * candidate_size * 0.5,
				Vector2.ONE * candidate_size
			)
			draw_texture_rect(_pass_paper_ink_texture, candidate_rect, false)
			return
		var gate_stroke := _screen_pixels(1.35)
		draw_circle(point, extent, parchment)
		draw_arc(point, extent, 0.0, TAU, 24, ink_soft, outline, true)
		var roof_y := point.y - extent * 0.35
		draw_line(point + Vector2(-extent * 0.64, -extent * 0.24), Vector2(point.x, point.y - extent * 0.62), ink, gate_stroke, true)
		draw_line(Vector2(point.x, point.y - extent * 0.62), point + Vector2(extent * 0.64, -extent * 0.24), ink, gate_stroke, true)
		draw_line(point + Vector2(-extent * 0.45, -extent * 0.16), point + Vector2(-extent * 0.45, extent * 0.54), ink, gate_stroke, true)
		draw_line(point + Vector2(extent * 0.45, -extent * 0.16), point + Vector2(extent * 0.45, extent * 0.54), ink, gate_stroke, true)
		draw_line(Vector2(point.x - extent * 0.45, roof_y), Vector2(point.x + extent * 0.45, roof_y), ink, gate_stroke, true)
		return

	if normalized_type == "port":
		var inner_radius := extent * 0.58
		draw_circle(point, extent, parchment)
		draw_arc(point, extent, 0.0, TAU, 24, water_ink, outline, true)
		draw_circle(point, inner_radius, water_ink)
		draw_arc(point + Vector2(0, inner_radius * 0.08), inner_radius * 0.62, 0.1, PI - 0.1, 10, parchment, _screen_pixels(1.0), true)
		return

	if normalized_type in ["water_gate", "ferry"]:
		var inner_radius := extent * 0.62
		var outer := PackedVector2Array([
			point + Vector2(0, -extent), point + Vector2(extent, 0),
			point + Vector2(0, extent), point + Vector2(-extent, 0)
		])
		var inner := PackedVector2Array([
			point + Vector2(0, -inner_radius), point + Vector2(inner_radius, 0),
			point + Vector2(0, inner_radius), point + Vector2(-inner_radius, 0)
		])
		draw_colored_polygon(outer, parchment)
		draw_polyline(PackedVector2Array([outer[0], outer[1], outer[2], outer[3], outer[0]]), water_ink, outline, true)
		draw_colored_polygon(inner, water_ink)
		if normalized_type == "water_gate":
			var gate_y := point.y - inner_radius * 0.16
			var post_top := point.y - inner_radius * 0.48
			var post_bottom := point.y + inner_radius * 0.42
			draw_line(Vector2(point.x - inner_radius * 0.72, gate_y), Vector2(point.x + inner_radius * 0.72, gate_y), parchment, _screen_pixels(1.0), true)
			draw_line(Vector2(point.x - inner_radius * 0.38, post_top), Vector2(point.x - inner_radius * 0.38, post_bottom), parchment, _screen_pixels(0.9), true)
			draw_line(Vector2(point.x + inner_radius * 0.38, post_top), Vector2(point.x + inner_radius * 0.38, post_bottom), parchment, _screen_pixels(0.9), true)
		else:
			draw_line(point + Vector2(-inner_radius * 0.72, -inner_radius * 0.22), point + Vector2(inner_radius * 0.72, -inner_radius * 0.22), parchment, _screen_pixels(0.9), true)
			draw_line(point + Vector2(-inner_radius * 0.56, inner_radius * 0.28), point + Vector2(inner_radius * 0.56, inner_radius * 0.28), parchment, _screen_pixels(0.9), true)
		return



func _draw_detail_city_hierarchy_symbol(
	point: Vector2,
	role: String,
	metrics: Dictionary,
	parchment: Color,
	ink: Color,
	ink_soft: Color
) -> void:
	var width := _screen_pixels(float(metrics.get("width_screen", 12.0)))
	var height := _screen_pixels(float(metrics.get("height_screen", 10.0)))
	var outline := _screen_pixels(1.0)
	match role:
		"capital":
			var outer := Rect2(point - Vector2(width, height) * 0.5, Vector2(width, height))
			draw_rect(outer, parchment, true)
			draw_rect(outer, ink, false, outline, true)
			var inner := outer.grow(-_screen_pixels(2.0))
			draw_rect(inner, Color(ink.r, ink.g, ink.b, 0.08), true)
			draw_rect(inner, ink_soft, false, _screen_pixels(0.8), true)
			var roof_y := point.y - height * 0.12
			draw_polyline(PackedVector2Array([
				Vector2(point.x - width * 0.22, roof_y),
				Vector2(point.x, point.y - height * 0.34),
				Vector2(point.x + width * 0.22, roof_y)
			]), ink, _screen_pixels(1.2), true)
			var gate := Rect2(point + Vector2(-width * 0.09, height * 0.08), Vector2(width * 0.18, height * 0.27))
			draw_rect(gate, ink_soft, true)
		"strategic_city":
			var wall := Rect2(point + Vector2(-width * 0.38, -height * 0.10), Vector2(width * 0.76, height * 0.46))
			draw_rect(wall, parchment, true)
			draw_rect(wall, ink, false, outline, true)
			var tower_size := Vector2(width * 0.24, height * 0.68)
			for tower_center_x in [point.x - width * 0.33, point.x + width * 0.33]:
				var tower := Rect2(Vector2(tower_center_x, point.y - height * 0.16) - tower_size * 0.5, tower_size)
				draw_rect(tower, parchment, true)
				draw_rect(tower, ink, false, outline, true)
			var gate := Rect2(point + Vector2(-width * 0.09, height * 0.03), Vector2(width * 0.18, height * 0.31))
			draw_rect(gate, ink_soft, true)
		"regional_city":
			var wall := Rect2(point - Vector2(width, height) * 0.5, Vector2(width, height))
			draw_rect(wall, parchment, true)
			draw_rect(wall, ink_soft, false, outline, true)
			var parapet_y := point.y - height * 0.18
			draw_line(Vector2(point.x - width * 0.36, parapet_y), Vector2(point.x + width * 0.36, parapet_y), ink, _screen_pixels(1.0), true)
			for post_x in [point.x - width * 0.30, point.x, point.x + width * 0.30]:
				draw_line(Vector2(post_x, parapet_y), Vector2(post_x, parapet_y - height * 0.20), ink, _screen_pixels(0.9), true)
			var gate := Rect2(point + Vector2(-width * 0.09, height * 0.09), Vector2(width * 0.18, height * 0.28))
			draw_rect(gate, ink_soft, true)
		"local_city":
			var wall := Rect2(point - Vector2(width, height) * 0.5, Vector2(width, height))
			draw_rect(wall, parchment, true)
			draw_rect(wall, ink_soft, false, _screen_pixels(0.9), true)
			var gate := Rect2(point + Vector2(-width * 0.11, height * 0.02), Vector2(width * 0.22, height * 0.34))
			draw_rect(gate, ink_soft, true)


func _draw_far_city_hierarchy_symbol(
	point: Vector2,
	_normalized_type: String,
	tier: int,
	metrics: Dictionary,
	parchment: Color,
	ink: Color,
	ink_soft: Color
) -> void:
	var width := _screen_pixels(float(metrics.get("width_screen", 10.0)))
	var height := _screen_pixels(float(metrics.get("height_screen", 8.0)))
	var role := _city_hierarchy_role(_normalized_type, tier)
	var backing := Color(0.08, 0.09, 0.07, 0.82)
	var outline := _screen_pixels(1.1)

	match role:
		"capital":
			var outer := Rect2(point - Vector2(width, height) * 0.5, Vector2(width, height))
			draw_rect(outer, backing, true)
			var inner := outer.grow(-_screen_pixels(1.35))
			draw_rect(inner, parchment, true)
			draw_rect(inner, ink, false, outline, true)
			var second_frame := inner.grow(-_screen_pixels(2.1))
			draw_rect(second_frame, Color(ink.r, ink.g, ink.b, 0.08), true)
			draw_rect(second_frame, ink_soft, false, _screen_pixels(0.8), true)
			var roof_y := point.y - height * 0.18
			var roof := PackedVector2Array([
				Vector2(point.x - width * 0.25, roof_y),
				Vector2(point.x, point.y - height * 0.39),
				Vector2(point.x + width * 0.25, roof_y)
			])
			draw_polyline(roof, ink, _screen_pixels(1.15), true)
			var gate := Rect2(
				point + Vector2(-width * 0.105, height * 0.08),
				Vector2(width * 0.21, height * 0.28)
			)
			draw_rect(gate, ink_soft, true)
		"strategic_city":
			var outer := Rect2(point - Vector2(width, height) * 0.5, Vector2(width, height))
			draw_rect(outer, backing, true)
			var wall := Rect2(
				point + Vector2(-width * 0.40, -height * 0.12),
				Vector2(width * 0.80, height * 0.48)
			)
			draw_rect(wall, parchment, true)
			draw_rect(wall, ink, false, outline, true)
			var tower_size := Vector2(width * 0.25, height * 0.65)
			for tower_center_x in [point.x - width * 0.33, point.x + width * 0.33]:
				var tower := Rect2(
					Vector2(tower_center_x, point.y - height * 0.18) - tower_size * 0.5,
					tower_size
				)
				draw_rect(tower, parchment, true)
				draw_rect(tower, ink, false, outline, true)
			var gate := Rect2(
				point + Vector2(-width * 0.095, height * 0.04),
				Vector2(width * 0.19, height * 0.31)
			)
			draw_rect(gate, ink_soft, true)
		"regional_city":
			var outer := Rect2(point - Vector2(width, height) * 0.5, Vector2(width, height))
			draw_rect(outer, backing, true)
			var wall := outer.grow(-_screen_pixels(1.0))
			draw_rect(wall, parchment, true)
			draw_rect(wall, ink_soft, false, _screen_pixels(0.9), true)
			var gate := Rect2(
				point + Vector2(-width * 0.10, height * 0.08),
				Vector2(width * 0.20, height * 0.27)
			)
			draw_rect(gate, ink_soft, true)
		"local_city":
			var outer := Rect2(point - Vector2(width, height) * 0.5, Vector2(width, height))
			draw_rect(outer, backing, true)
			var wall := outer.grow(-_screen_pixels(1.0))
			draw_rect(wall, parchment, true)
			draw_rect(wall, ink_soft, false, _screen_pixels(0.8), true)
			var gate := Rect2(
				point + Vector2(-width * 0.11, height * 0.04),
				Vector2(width * 0.22, height * 0.30)
			)
			draw_rect(gate, ink_soft, true)


func _draw_place_label(origin: Vector2, text: String, font_size: int) -> void:
	draw_string_outline(
		MapFont,
		origin,
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		PLACE_LABEL_OUTLINE_PX,
		PLACE_LABEL_HALO_COLOR
	)
	draw_string(
		MapFont,
		origin,
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		PLACE_LABEL_INK_COLOR
	)


func _snap_to_screen_pixel(point: Vector2) -> Vector2:
	var safe_zoom := maxf(view_zoom, 0.1)
	return Vector2(round(point.x * safe_zoom), round(point.y * safe_zoom)) / safe_zoom


func _begin_screen_space_draw(world_anchor: Vector2, rotation := 0.0) -> void:
	_screen_space_draw_active = true
	draw_set_transform(
		world_anchor,
		rotation,
		Vector2.ONE / maxf(view_zoom, 0.1)
	)


func _end_screen_space_draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_screen_space_draw_active = false


func _semantic_point_visible(point: Vector2, margin_screen := 160.0) -> bool:
	if semantic_visible_world_rect.size.x <= 0.0 or semantic_visible_world_rect.size.y <= 0.0:
		return true
	return semantic_visible_world_rect.grow(_screen_pixels(margin_screen)).has_point(point)


func _semantic_rect_visible(rect: Rect2, margin_screen := 48.0) -> bool:
	if semantic_visible_world_rect.size.x <= 0.0 or semantic_visible_world_rect.size.y <= 0.0:
		return true
	return semantic_visible_world_rect.grow(_screen_pixels(margin_screen)).intersects(rect)


func _detail_level() -> String:
	if view_zoom < FAR_ZOOM_THRESHOLD:
		return "far"
	if view_zoom < NEAR_ZOOM_THRESHOLD:
		return "middle"
	return "near"


func _place_label_level() -> String:
	if view_zoom < OVERVIEW_ZOOM_THRESHOLD:
		return "overview"
	return _detail_level()


func _is_place_visible(place_id: String) -> bool:
	if _place_label_level() == "overview":
		return OVERVIEW_PLACE_IDS.has(place_id)
	var level := _detail_level()
	var tier := _place_tier(place_id)
	if level == "far":
		return tier == 1
	if level == "middle":
		return tier <= 2
	return true


func _is_place_symbol_visible(_place_id: String) -> bool:
	# 地图缩小时保留全部城池棋子和连通关系，只按 LOD 减少文字。
	# 这样总览仍可用于投放与悬停，同时不会重现低倍地名重叠。
	return true


func _is_mountain_visible(mountain: Dictionary) -> bool:
	return view_zoom + 0.001 >= float(mountain.get("min_zoom", NEAR_ZOOM_THRESHOLD))


func _is_river_label_visible(river_label: Dictionary) -> bool:
	return view_zoom + 0.001 >= float(river_label.get("min_zoom", NEAR_ZOOM_THRESHOLD))


func _is_historical_context_visible(record: Dictionary) -> bool:
	if not show_historical_context:
		return false
	var runtime_layer_id := str(record.get("_runtime_layer_id", ""))
	if not runtime_layer_id.is_empty() and not bool(historical_context_visibility_by_layer.get(runtime_layer_id, false)):
		return false
	if _detail_level() == "far":
		return int(record.get("display_tier", 2)) == 1
	return true


func _place_tier(place_id: String) -> int:
	if _place_display_tiers.has(place_id):
		return int(_place_display_tiers[place_id])
	if STRATEGIC_PLACE_IDS.has(place_id):
		return 1
	if REGIONAL_PLACE_IDS.has(place_id):
		return 2
	return 3


func _is_route_visible(route: Dictionary) -> bool:
	var level := _detail_level()
	if level == "far":
		return false
	if level == "near":
		return true
	var display_tier := str(route.get("display_tier", ""))
	if not display_tier.is_empty():
		return display_tier == "strategic"
	var from_id := str(route.get("from", ""))
	var to_id := str(route.get("to", ""))
	return STRATEGIC_ROUTE_KEYS.has("%s|%s" % [from_id, to_id]) or STRATEGIC_ROUTE_KEYS.has("%s|%s" % [to_id, from_id])


func _is_corridor_route_visible(route: Dictionary) -> bool:
	if not show_strategic_corridors or str(route.get("corridor_id", "")).strip_edges().is_empty():
		return false
	if _detail_level() != "far":
		return true
	return str(route.get("corridor_tier", "")) == "strategic"


func _compile_place_display_tiers() -> void:
	_place_display_tiers.clear()
	for place in places:
		var place_id := str(place.get("id", ""))
		var display_tier := str(place.get("display_tier", ""))
		match display_tier:
			"strategic":
				_place_display_tiers[place_id] = 1
			"regional":
				_place_display_tiers[place_id] = 2
			"local":
				_place_display_tiers[place_id] = 3


func _screen_pixels(value: float) -> float:
	return value if _screen_space_draw_active else value / maxf(view_zoom, 0.1)


func _geo_point(normalized: Vector2) -> Vector2:
	return MAP_CONTENT_RECT.position + normalized * MAP_CONTENT_RECT.size
