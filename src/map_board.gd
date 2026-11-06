class_name MapBoard
extends Control

signal character_dropped(character_id: String, normalized_position: Vector2)
signal character_drag_released(character_id: String, global_position: Vector2, normalized_position: Vector2, valid_map_drop: bool)
signal character_group_drag_released(character_ids: Array, global_position: Vector2, normalized_positions: Dictionary, valid_map_drop: bool)
signal character_selected(character_id: String)
signal character_selection_changed(character_ids: Array)
signal character_return_requested(character_id: String)
signal character_details_requested(character_id: String)
signal character_attributes_requested(character_id: String)
signal character_troops_requested(character_id: String)
signal character_troop_adjust_requested(character_id: String, delta: int, reset_to_default: bool)
signal character_action_requested(character_id: String, action: String)
signal character_group_action_requested(character_ids: Array, action: String)
signal character_group_return_requested(character_ids: Array)
signal character_faction_assignment_requested(character_id: String, faction_id: String)
signal zoom_changed(zoom_value: float)
signal annotation_create_requested(normalized_position: Vector2)
signal annotation_drag_released(annotation_id: String, normalized_position: Vector2, valid_map_drop: bool)
signal annotation_edit_requested(annotation_id: String)
signal annotation_delete_requested(annotation_id: String)
signal annotation_tool_changed(active: bool)
signal annotation_type_visibility_changed(marker_type: String, visible: bool)
signal annotation_focused(annotation_id: String, label: String, index: int, total: int)
signal annotation_focus_unavailable()
signal player_stroke_draft_completed(points: Array)
signal player_stroke_edit_requested(stroke_id: String)
signal player_stroke_geometry_edit_completed(stroke_id: String, points: Array)
signal player_stroke_delete_requested(stroke_id: String)
signal player_stroke_tool_changed(active: bool)
signal player_stroke_visibility_changed(visible: bool)
signal player_stroke_focused(stroke_id: String, label: String, index: int, total: int)
signal player_stroke_focus_unavailable()
signal place_details_requested(place_id: String)
signal city_ownership_place_requested(place_id: String)
signal city_ownership_hover_changed(place_id: String)
signal historical_context_details_requested(context_id: String)
signal strategic_corridors_visibility_changed(visible: bool)
signal historical_context_visibility_changed(visible: bool)
signal historical_context_layer_visibility_changed(layer_id: String, visible: bool)
signal city_faction_window_toggled(place_name: String, faction_name: String, member_count: int, collapsed: bool)
signal city_faction_rename_requested(faction_id: String, faction_name: String)
signal city_faction_details_visibility_changed(visible: bool)
signal faction_influence_visibility_changed(visible: bool)
signal faction_legend_requested(faction_id: String)
signal simulation_session_end_requested

const CharacterCardScript = preload("res://src/character_card.gd")
const CharacterActionPolicyScript = preload("res://src/character_action_policy.gd")
const CityFactionWindowScript = preload("res://src/city_faction_window.gd")
const FactionPaletteScript = preload("res://src/faction_palette.gd")
const FactionInfluenceLayerScript = preload("res://src/faction_influence_layer.gd")
const FactionIdentityMarkerScript = preload("res://src/faction_identity_marker.gd")
const MapCanvasScript = preload("res://src/map_canvas.gd")
const MapPresentationPolicyScript = preload("res://src/map_presentation_policy.gd")
const PlacementGuideScript = preload("res://src/placement_guide.gd")
const TacticalMarkerScript = preload("res://src/tactical_marker.gd")
const PlayerStrokeLayerScript = preload("res://src/player_stroke_layer.gd")
const UiThemeScript = preload("res://src/ui_theme.gd")
const MAP_CONTENT_RECT: Rect2 = MapCanvasScript.MAP_CONTENT_RECT
# 最大 300% 缩放时，地形与结构注记缓存均保留约 1.33 个缓存像素／屏幕像素。
# 山纹、路线等低频结构继续复用离屏缓存；地点文字、州河山名、历史标签和
# 地点图标由实时语义层用 MSDF／程序化图形绘制，避免烘焙位图的二次采样。
const TERRAIN_CACHE_SCALE := 4.0
const ANNOTATION_CACHE_SCALE := 4.0
const TERRAIN_CACHE_BYTES_PER_PIXEL := 4
const CACHE_CLARITY_START_ZOOM := 1.40
const CACHE_CLARITY_FULL_ZOOM := 3.00
const CACHE_CLARITY_MAX_AMOUNT := 0.24
const CACHE_CLARITY_SHADER_CODE := """
shader_type canvas_item;

uniform float clarity_amount : hint_range(0.0, 0.4) = 0.0;

void fragment() {
	vec4 center = texture(TEXTURE, UV);
	vec4 output_color = center;
	if (clarity_amount > 0.001) {
		vec2 texel = TEXTURE_PIXEL_SIZE;
		vec4 neighbors = (
			texture(TEXTURE, UV + vec2(texel.x, 0.0))
			+ texture(TEXTURE, UV - vec2(texel.x, 0.0))
			+ texture(TEXTURE, UV + vec2(0.0, texel.y))
			+ texture(TEXTURE, UV - vec2(0.0, texel.y))
		) * 0.25;
		output_color = clamp(center + (center - neighbors) * clarity_amount, 0.0, 1.0);
	}
	COLOR = output_color * COLOR;
}
"""
const DRAG_WARMUP_FRAMES := 5
const DRAG_SAMPLE_LIMIT := 600
const DRAG_MIN_REPORT_SAMPLES := 60
const SLOW_FRAME_SECONDS := 1.0 / 30.0
const SEVERE_FRAME_SECONDS := 0.050
const SNAP_ENTER_RADIUS_SCREEN := 24.0
const SNAP_EXIT_RADIUS_SCREEN := 32.0
const SNAP_SWITCH_ADVANTAGE_SCREEN := 6.0
const PLACE_HOVER_RADIUS_SCREEN := 22.0
const PLACE_HOVER_PANEL_SIZE := Vector2(336.0, 120.0)
const PLACE_HOVER_PANEL_MARGIN_SCREEN := 12.0
const PLACE_HOVER_PANEL_GAP_SCREEN := 14.0
const SCENARIO_PREVIEW_CITY_RADIUS_SCREEN := 17.0
const SCENARIO_PREVIEW_PLACEMENT_RADIUS_SCREEN := 8.0
const FACTION_INSPECTION_CITY_RADIUS_SCREEN := 23.0
const FACTION_INSPECTION_CARD_MARGIN_SCREEN := 5.0
const PLACE_RELATION_SOURCE_RADIUS_SCREEN := 15.0
const PLACE_RELATION_TARGET_RADIUS_SCREEN := 19.0
const PLACE_RELATION_CONTEXT_MIN_ZOOM := 0.66
const PLACE_RELATION_CONTEXT_OUTER_WIDTH_SCREEN := 3.5
const PLACE_RELATION_CONTEXT_INNER_WIDTH_SCREEN := 1.25
const CITY_FACTION_UNASSIGNED_ID := "__unassigned__"
const CITY_FACTION_UNASSIGNED_NAME := "未编组"
const CITY_FACTION_WINDOW_WIDTH := 144.0
const CITY_FACTION_WINDOW_HEADER_HEIGHT := 28.0
const CITY_FACTION_WINDOW_CARD_TOP := 5.0
const CITY_FACTION_WINDOW_CARD_ROW := 50.0
const CITY_FACTION_WINDOW_BOTTOM := 4.0
const CITY_FACTION_WINDOW_GAP_SCREEN := 8.0
const CITY_FACTION_SUMMARY_ROW_GAP_SCREEN := 5.0
const CITY_FACTION_SUMMARY_MAX_ROWS := 3
const CITY_FACTION_COMPACT_ZOOM := 0.88
const OVERVIEW_CARD_GAP_SCREEN := 5.0
const OVERVIEW_CARD_MAX_RING := 4
const MIN_ZOOM := 0.52
const MAX_ZOOM := 3.00
const MARKER_FULL_SCALE_ZOOM := 1.75
const PLACE_DOCK_GAP_SCREEN := 12.0
const PLACE_DOCK_LABEL_MARGIN_SCREEN := 3.0
const PLACE_DOCK_NODE_CLEARANCE_SCREEN := 8.0
const PLACE_DOCK_FIXED_OVERLAY_MARGIN_SCREEN := 2.0
const PLACE_DOCK_FIXED_OVERLAY_PENALTY := 1000000.0
const PLACE_DOCK_BASE_CANDIDATE_RING_COUNT := 8
const PLACE_DOCK_EXTENDED_CANDIDATE_RING_COUNT := 10
const PLACE_DOCK_COLLISION_EPSILON := 0.05
const ANNOTATION_TYPES := ["note", "player_place", "player_event"]
const ANNOTATION_MENU_NOTE_ID := 100
const ANNOTATION_MENU_PLACE_ID := 101
const ANNOTATION_MENU_EVENT_ID := 102
const ANNOTATION_MENU_FOCUS_NEXT_ID := 110
const ANNOTATION_MENU_SHOW_ALL_ID := 111
const ANNOTATION_MENU_HIDE_ALL_ID := 112
const STROKE_MENU_VISIBLE_ID := 200
const STROKE_MENU_FOCUS_NEXT_ID := 201
const CHARACTER_CONTEXT_RETURN_ID := 300
const CHARACTER_CONTEXT_DETAILS_ID := 301
const CHARACTER_CONTEXT_ATTRIBUTES_ID := 302
const CHARACTER_CONTEXT_ACTION_MENU_ID := 303
const CHARACTER_CONTEXT_FACTION_MENU_ID := 304
const CHARACTER_CONTEXT_TROOPS_EXACT_ID := 305
const CHARACTER_CONTEXT_OVERLAP_MENU_ID := 306
const CHARACTER_CONTEXT_ACTION_STANDBY_ID := 310
const CHARACTER_CONTEXT_ACTION_ATTACK_ID := 311
const CHARACTER_CONTEXT_ACTION_DEFEND_ID := 312
const CHARACTER_CONTEXT_TROOPS_MINUS_1000_ID := 313
const CHARACTER_CONTEXT_TROOPS_MINUS_100_ID := 314
const CHARACTER_CONTEXT_TROOPS_MENU_ID := 315
const CHARACTER_CONTEXT_TROOPS_PLUS_100_ID := 316
const CHARACTER_CONTEXT_TROOPS_PLUS_1000_ID := 317
const CHARACTER_CONTEXT_TROOPS_RESET_ID := 318
const CHARACTER_CONTEXT_FACTION_HELP_ID := 329
const CHARACTER_CONTEXT_FACTION_TARGET_BASE_ID := 330
const CHARACTER_CONTEXT_OVERLAP_TARGET_BASE_ID := 380
const PLAYER_STROKE_LAYER_Z := 10
const PLAYER_STROKE_EDIT_LAYER_Z := 2500
const PLAYER_STROKE_HANDLE_DRAG_THRESHOLD_SCREEN := 5.0
const CHARACTER_BASE_Z_NORMALIZE_THRESHOLD := 1900
const CHARACTER_SELECTED_FOCUS_Z := 2200
const CHARACTER_HOVER_FOCUS_Z := 2300
const CHARACTER_ATTENTION_DIM_ALPHA := 0.46
const CHARACTER_ATTENTION_MARGIN_SCREEN := 4.0
const CHARACTER_OVERLAP_MIN_RATIO := 0.28
const WORLD_GEOGRAPHIC_BOUNDS := {
	"min_lon": 93.5, "max_lon": 130.5,
	"min_lat": 18.0, "max_lat": 44.5
}
const HAN_THEATER_GEOGRAPHIC_BOUNDS := {
	"min_lon": 99.5, "max_lon": 122.5,
	"min_lat": 20.0, "max_lat": 41.5
}
const HOME_MARGIN_SCREEN := 28.0
const HOME_WORLD_OVERVIEW := "world_overview"
const HOME_HAN_THEATER := "han_theater"
const FACTION_INFLUENCE_LEGEND_MAX_ROWS := 12
const FACTION_IDENTITY_MARKER_OFFSET_SCREEN := Vector2(-18.0, -17.0)
const PASS_SYMBOL_VARIANT_V3 := MapCanvasScript.PASS_SYMBOL_VARIANT_V3
const PASS_SYMBOL_VARIANT_PAPER_INK_V1 := MapCanvasScript.PASS_SYMBOL_VARIANT_PAPER_INK_V1
const TERRAIN_RELIEF_VARIANT_LR_V1 := MapCanvasScript.TERRAIN_RELIEF_VARIANT_LR_V1
const TERRAIN_RELIEF_VARIANT_HR_V1 := MapCanvasScript.TERRAIN_RELIEF_VARIANT_HR_V1
const TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1 := MapCanvasScript.TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1
const TERRAIN_VISUAL_PROFILE_ANTIQUE_TOPOGRAPHIC_V1 := MapCanvasScript.TERRAIN_VISUAL_PROFILE_ANTIQUE_TOPOGRAPHIC_V1
const TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1 := MapCanvasScript.TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1

var world_size := MAP_CONTENT_RECT.size
var zoom := 0.8
var pan := Vector2.ZERO
var min_zoom := MIN_ZOOM
var max_zoom := MAX_ZOOM
var _render_pan := Vector2.ZERO
var _render_origin_output_px := Vector2.ZERO
var _render_origin_phase_px := Vector2.ZERO

var _world_layer: Control
var _cached_map_layer: Control
var _user_annotation_layer: Control
var _player_stroke_layer: PlayerStrokeLayer
var _dock_connector_layer: Control
var _scenario_preview_overlay: Control
var _faction_inspection_overlay: Control
var _place_relation_overlay: Control
var _drag_layer: Control
var _stroke_input_overlay: Control
var _terrain_viewport: SubViewport
var _terrain_canvas: MapCanvas
var _terrain_texture: TextureRect
var _faction_influence_layer: FactionInfluenceLayer
var _faction_identity_marker_layer: Control
var _faction_identity_marker_by_place: Dictionary = {}
var _faction_identity_marker_signature := ""
var _faction_identity_marker_rebuilds := 0
var _map_backdrop: ColorRect
var _annotation_viewport: SubViewport
var _annotation_texture: TextureRect
var _canvas: MapCanvas
var _semantic_canvas: MapCanvas
var _cache_clarity_material: ShaderMaterial
var _jade_terrain_material: ShaderMaterial
var _cache_clarity_amount := 0.0
var _placement_guide
var _place_hover_panel: PanelContainer
var _place_hover_title: Label
var _place_hover_historical: Label
var _place_hover_status: Label
var _place_hover_note: Label
var _strategic_corridor_button: Button
var _historical_context_button: Button
var _historical_context_menu: MenuButton
var _simulation_session_end_button: Button
var _map_tools_panel: Panel
var _map_tools_visible := true
var _simulation_session_active_ui := false
var _faction_influence_toggle_panel: PanelContainer
var _faction_influence_toggle: CheckButton
var _city_faction_details_toggle_panel: PanelContainer
var _city_faction_details_toggle: CheckButton
var _faction_influence_legend_panel: PanelContainer
var _faction_influence_legend_title: Button
var _faction_influence_legend_collapsed := false
var _faction_influence_legend_rows_host: VBoxContainer
var _faction_influence_legend_more_label: Label
var _faction_influence_legend_rows: Array[Dictionary] = []
var _faction_influence_legend_signature := ""
var _faction_influence_legend_rebuilds := 0
var _faction_influence_legend_context_suppressed := false
var _annotation_manager_menu: MenuButton
var _stroke_manager_menu: MenuButton
var _stroke_guide_panel: PanelContainer
var _stroke_guide_label: Label
var _stroke_finish_button: Button
var _stroke_undo_point_button: Button
var _stroke_cancel_button: Button
var _stroke_action_panel: PanelContainer
var _stroke_action_label: Label
var _character_context_menu: PopupMenu
var _character_troop_menu: PopupMenu
var _character_action_menu: PopupMenu
var _character_faction_menu: PopupMenu
var _character_overlap_menu: PopupMenu
var _character_faction_target_by_menu_id: Dictionary = {}
var _character_overlap_target_by_menu_id: Dictionary = {}
var _character_context_id := ""
var _character_context_group_ids: Array[String] = []
var _placements: Dictionary = {}
var _character_states: Dictionary = {}
var _character_actions: Dictionary = {}
var _character_troops: Dictionary = {}
var _character_portraits: Dictionary = {}
var _annotations: Dictionary = {}
var _player_strokes: Array[Dictionary] = []
var _character_by_id: Dictionary = {}
var _character_order_by_id: Dictionary = {}
var _places: Array = []
var _routes: Array = []
var _land_data: Dictionary = {}
var _river_data: Dictionary = {}
var _lake_data: Dictionary = {}
var _mountains: Array = []
var _geographic_context_records: Array[Dictionary] = []
var _historical_context_layer: Dictionary = {}
var _historical_context_layers: Array[Dictionary] = []
var _historical_context_layers_by_id: Dictionary = {}
var _historical_context_layer_order: Array[String] = []
var _historical_context_visibility_by_id: Dictionary = {}
var _scenario_context_signature := ""
var _scenario_context_year := 0
var _scenario_context_label := "本局背景"
var _card_by_id: Dictionary = {}
var _annotation_by_id: Dictionary = {}
var _panning := false
var _camera_pan_dirty := false
var _pan_layout_dirty := false
var _camera_initialized := false
var _active_drag_id := ""
var _active_drag_ids: Array[String] = []
var _active_drag_screen_offsets_by_id: Dictionary = {}
var _active_group_drag_layout_offsets_by_id: Dictionary = {}
var _drag_grab_offset_screen := Vector2.ZERO
var _drag_pointer_override_enabled := false
var _drag_pointer_override_screen := Vector2.ZERO
var _drag_snap_bypass_override_enabled := false
var _drag_snap_bypass_override_value := false
var _native_drag_avoid_rect := Rect2()
var _active_annotation_drag_id := ""
var _selected_annotation_id := ""
var _annotation_drag_grab_offset_screen := Vector2.ZERO
var _drag_total_frames := 0
var _drag_frame_samples: Array[float] = []
var _drag_update_samples_usec: Array[int] = []
var _last_drag_stats: Dictionary = {}
var _static_cache_builds := 0
var _annotation_cache_builds := 0
var _annotation_cache_dirty := false
var _place_world_positions := PackedVector2Array()
var _place_normalized_positions := PackedVector2Array()
var _place_ids := PackedStringArray()
var _place_names := PackedStringArray()
var _place_name_by_id: Dictionary = {}
var _place_types := PackedStringArray()
var _place_historical_names := PackedStringArray()
var _place_confidences := PackedStringArray()
var _place_coordinate_bases := PackedStringArray()
var _place_notes := PackedStringArray()
var _hover_place_index := -1
var _snap_candidate_index := -1
var _last_drop_context: Dictionary = {}
var _selected_character_id := ""
var _selected_character_ids: Array[String] = []
var _hovered_character_id := ""
var _next_card_z := 100
var _card_base_z_by_id: Dictionary = {}
var _attention_dimmed_character_ids: Array[String] = []
var _attention_dimmed_annotation_ids: Array[String] = []
var _attention_dimmed_city_group_keys: Array[String] = []
var _stack_members_by_place: Dictionary = {}
var _character_stack_place: Dictionary = {}
var _stack_offset_screen_by_id: Dictionary = {}
var _overview_declutter_offset_screen_by_id: Dictionary = {}
var _scenario_state: Dictionary = {"factions": [], "character_assignments": []}
var _faction_name_by_id: Dictionary = {}
var _faction_order_by_id: Dictionary = {}
var _faction_color_by_id: Dictionary = {}
var _faction_by_character: Dictionary = {}
var _city_group_members: Dictionary = {}
var _city_group_meta: Dictionary = {}
var _city_group_keys_by_place: Dictionary = {}
var _city_group_by_character: Dictionary = {}
var _city_group_rect_screen: Dictionary = {}
var _city_faction_window_by_key: Dictionary = {}
var _collapsed_city_group_keys: Dictionary = {}
var _city_detail_compact := false
var _city_faction_details_visible := true
var _place_dock_offset_screen_by_id: Dictionary = {}
var _place_dock_rect_screen_by_id: Dictionary = {}
var _place_dock_layout_builds := 0
var _place_dock_collision_count := 0
var _place_dock_fixed_overlay_collision_count := 0
var _place_dock_overlay_refresh_queued := false
var _annotation_tool_active := false
var _city_ownership_tool_active := false
var _city_ownership_hover_place_id := ""
var _player_stroke_tool_active := false
var _player_stroke_type := "advance"
var _player_stroke_draft_points: Array[Vector2] = []
var _selected_player_stroke_id := ""
var _player_strokes_visible := true
var _player_stroke_point_edit_active := false
var _player_stroke_point_edit_id := ""
var _player_stroke_point_original_points: Array[Vector2] = []
var _player_stroke_point_preview_points: Array[Vector2] = []
var _player_stroke_point_active_index := -1
var _player_stroke_point_press_screen := Vector2.ZERO
var _player_stroke_point_drag_start := Vector2.ZERO
var _player_stroke_point_dragging := false
var _annotation_visibility_by_type := {
	"note": true,
	"player_place": true,
	"player_event": true
}
var _strategic_corridors_visible := true
var _near_hachures_visible := true
var _historical_context_visible := false
var _scenario_preview_faction_id := ""
var _scenario_preview_faction_name := ""
var _scenario_preview_color := Color("#A77B27")
var _scenario_preview_city_place_ids: Array[String] = []
var _scenario_preview_placement_place_ids: Array[String] = []
var _scenario_preview_normalized_positions: Array[Vector2] = []
var _scenario_preview_drawn_placement_place_count := 0
var _scenario_preview_drawn_normalized_position_count := 0
var _faction_inspection_id := ""
var _faction_inspection_name := ""
var _faction_inspection_color := Color("#A77B27")
var _faction_inspection_city_place_ids: Array[String] = []
var _faction_inspection_character_ids: Array[String] = []
var _place_relation_source_id := ""
var _place_relation_target_id := ""
var _place_relation_route_index := -1
var _place_relation_neighbor_ids: Array[String] = []
var _place_relation_route_indices: Array[int] = []
var _place_relation_hover_target_id := ""
var _place_relation_hover_route_index := -1


func _ready() -> void:
	add_to_group("native_drag_feedback_targets")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(760, 600)
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	var frame := Panel.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame_style := UiThemeScript.make_shell_panel(
		UiThemeScript.INK_BOARD,
		UiThemeScript.BORDER_BOARD,
		1,
		3
	)
	frame.add_theme_stylebox_override("panel", frame_style)
	add_child(frame)

	_map_backdrop = ColorRect.new()
	_map_backdrop.name = "MapBackdrop"
	_map_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_map_backdrop.color = MapCanvasScript.MAP_BACKDROP_COLOR
	_map_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_map_backdrop)

	_world_layer = Control.new()
	_world_layer.name = "WorldLayer"
	_world_layer.size = world_size
	_world_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_world_layer)

	_cached_map_layer = Control.new()
	_cached_map_layer.name = "CachedMapLayer"
	_cached_map_layer.size = world_size
	_cached_map_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world_layer.add_child(_cached_map_layer)

	_terrain_viewport = SubViewport.new()
	_terrain_viewport.name = "StaticTerrainViewport"
	_terrain_viewport.size = Vector2i(
		roundi(world_size.x * TERRAIN_CACHE_SCALE),
		roundi(world_size.y * TERRAIN_CACHE_SCALE)
	)
	_terrain_viewport.disable_3d = true
	_terrain_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_terrain_viewport)

	_terrain_canvas = MapCanvasScript.new()
	_terrain_canvas.name = "StaticTerrainCanvas"
	_terrain_canvas.world_size = world_size
	_terrain_canvas.draw_base_layers = true
	_terrain_canvas.draw_annotation_layers = false
	_terrain_canvas.scale = Vector2.ONE * TERRAIN_CACHE_SCALE
	_terrain_viewport.add_child(_terrain_canvas)

	_terrain_texture = TextureRect.new()
	_terrain_texture.name = "StaticTerrainTexture"
	_terrain_texture.size = world_size
	_terrain_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_terrain_texture.stretch_mode = TextureRect.STRETCH_SCALE
	_terrain_texture.texture = _terrain_viewport.get_texture()
	_terrain_texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_terrain_texture.material = _make_cache_clarity_material()
	_terrain_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_terrain_texture.z_index = 0
	_cached_map_layer.add_child(_terrain_texture)

	_faction_influence_layer = FactionInfluenceLayerScript.new()
	_faction_influence_layer.name = "FactionInfluenceLayer"
	_faction_influence_layer.z_index = 1
	_cached_map_layer.add_child(_faction_influence_layer)

	_faction_identity_marker_layer = Control.new()
	_faction_identity_marker_layer.name = "FactionIdentityMarkers"
	_faction_identity_marker_layer.size = world_size
	_faction_identity_marker_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_faction_identity_marker_layer.z_index = 3
	_world_layer.add_child(_faction_identity_marker_layer)

	_annotation_viewport = SubViewport.new()
	_annotation_viewport.name = "AnnotationViewport"
	_annotation_viewport.size = Vector2i(
		roundi(MAP_CONTENT_RECT.size.x * ANNOTATION_CACHE_SCALE),
		roundi(MAP_CONTENT_RECT.size.y * ANNOTATION_CACHE_SCALE)
	)
	_annotation_viewport.disable_3d = true
	_annotation_viewport.transparent_bg = true
	_annotation_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	_annotation_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_annotation_viewport)

	_canvas = MapCanvasScript.new()
	_canvas.name = "MapAnnotations"
	_canvas.world_size = world_size
	_canvas.draw_base_layers = false
	_canvas.draw_annotation_layers = true
	_canvas.draw_structural_annotations = true
	_canvas.draw_semantic_annotations = false
	_canvas.position = -MAP_CONTENT_RECT.position * ANNOTATION_CACHE_SCALE
	_canvas.scale = Vector2.ONE * ANNOTATION_CACHE_SCALE
	_annotation_viewport.add_child(_canvas)

	_annotation_texture = TextureRect.new()
	_annotation_texture.name = "AnnotationTexture"
	_annotation_texture.position = MAP_CONTENT_RECT.position
	_annotation_texture.size = MAP_CONTENT_RECT.size
	_annotation_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_annotation_texture.stretch_mode = TextureRect.STRETCH_SCALE
	_annotation_texture.texture = _annotation_viewport.get_texture()
	_annotation_texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_annotation_texture.material = _cache_clarity_material
	_annotation_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_annotation_texture.z_index = 2
	_cached_map_layer.add_child(_annotation_texture)

	_place_relation_overlay = Control.new()
	_place_relation_overlay.name = "PlaceRelationHighlight"
	_place_relation_overlay.custom_minimum_size = world_size
	_place_relation_overlay.size = world_size
	_place_relation_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place_relation_overlay.z_index = 2
	_place_relation_overlay.visible = false
	_place_relation_overlay.draw.connect(_draw_place_relation_highlight)
	_cached_map_layer.add_child(_place_relation_overlay)

	_semantic_canvas = MapCanvasScript.new()
	_semantic_canvas.name = "LiveSemanticAnnotations"
	_semantic_canvas.world_size = world_size
	_semantic_canvas.draw_base_layers = false
	_semantic_canvas.draw_annotation_layers = true
	_semantic_canvas.draw_structural_annotations = false
	_semantic_canvas.draw_semantic_annotations = true
	_semantic_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 语义文字与地点图标覆盖路线／山纹，但继续让玩法势力身份标记位于上层，
	# 保持 M2-D22 之前“注记 z2、势力标记 z3”的可读顺序。
	_semantic_canvas.z_index = 2
	_cached_map_layer.add_child(_semantic_canvas)

	_player_stroke_layer = PlayerStrokeLayerScript.new()
	_player_stroke_layer.name = "PlayerStrokeLayer"
	_player_stroke_layer.configure(MAP_CONTENT_RECT)
	_player_stroke_layer.z_index = PLAYER_STROKE_LAYER_Z
	_world_layer.add_child(_player_stroke_layer)

	_user_annotation_layer = Control.new()
	_user_annotation_layer.name = "UserAnnotationLayer"
	_user_annotation_layer.size = world_size
	_user_annotation_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_user_annotation_layer.z_index = 20
	_world_layer.add_child(_user_annotation_layer)

	_scenario_preview_overlay = Control.new()
	_scenario_preview_overlay.name = "ScenarioPreviewOverlay"
	_scenario_preview_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scenario_preview_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scenario_preview_overlay.z_index = 70
	_scenario_preview_overlay.visible = false
	_scenario_preview_overlay.draw.connect(_draw_scenario_preview_highlight)
	add_child(_scenario_preview_overlay)

	_faction_inspection_overlay = Control.new()
	_faction_inspection_overlay.name = "FactionInspectionOverlay"
	_faction_inspection_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_faction_inspection_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_faction_inspection_overlay.z_index = 75
	_faction_inspection_overlay.visible = false
	_faction_inspection_overlay.draw.connect(_draw_faction_inspection_highlight)
	add_child(_faction_inspection_overlay)

	_dock_connector_layer = Control.new()
	_dock_connector_layer.name = "PlaceDockConnectors"
	_dock_connector_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dock_connector_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dock_connector_layer.z_index = 80
	_dock_connector_layer.draw.connect(_draw_place_dock_connectors)
	add_child(_dock_connector_layer)

	_drag_layer = Control.new()
	_drag_layer.name = "DragLayer"
	_drag_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_drag_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_drag_layer)

	_stroke_input_overlay = Control.new()
	_stroke_input_overlay.name = "PlayerStrokeInputOverlay"
	_stroke_input_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stroke_input_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_stroke_input_overlay.mouse_default_cursor_shape = Control.CURSOR_CROSS
	_stroke_input_overlay.z_index = 2900
	_stroke_input_overlay.visible = false
	_stroke_input_overlay.gui_input.connect(_on_stroke_overlay_input)
	add_child(_stroke_input_overlay)

	_placement_guide = PlacementGuideScript.new()
	_placement_guide.name = "PlacementGuide"
	add_child(_placement_guide)
	_build_place_hover_panel()

	var sidebar_normal := StyleBoxFlat.new()
	_map_tools_panel = Panel.new()
	_map_tools_panel.name = "MapToolsPanel"
	_map_tools_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_map_tools_panel.z_index = 2999
	_map_tools_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_map_tools_panel.add_theme_stylebox_override("panel", UiThemeScript.make_floating_tool_panel(0.98, 7, Vector4(8, 8, 8, 8)))
	add_child(_map_tools_panel)
	sidebar_normal.bg_color = Color(0.96, 0.94, 0.86, 0.94)
	sidebar_normal.border_color = UiThemeScript.BORDER_SHELL
	sidebar_normal.set_border_width_all(1)
	sidebar_normal.corner_radius_top_left = 7
	sidebar_normal.corner_radius_top_right = 7
	sidebar_normal.corner_radius_bottom_left = 7
	sidebar_normal.corner_radius_bottom_right = 7

	_simulation_session_end_button = Button.new()
	_simulation_session_end_button.name = "SimulationSessionEndButton"
	_simulation_session_end_button.text = "结束并复盘"
	_simulation_session_end_button.visible = false
	_simulation_session_end_button.tooltip_text = "结束当前推演，比较起点与现状，并写入玩家纪事"
	_simulation_session_end_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_simulation_session_end_button.position = Vector2(-142, 18)
	_simulation_session_end_button.size = Vector2(124, 34)
	_simulation_session_end_button.z_index = 3001
	_simulation_session_end_button.add_theme_font_size_override("font_size", 13)
	var session_end_normal := sidebar_normal.duplicate() as StyleBoxFlat
	session_end_normal.bg_color = Color(0.98, 0.94, 0.82, 0.97)
	session_end_normal.border_color = UiThemeScript.BORDER_BRASS
	_simulation_session_end_button.add_theme_stylebox_override("normal", session_end_normal)
	var session_end_hover := session_end_normal.duplicate() as StyleBoxFlat
	session_end_hover.bg_color = Color("#FFF2CB")
	session_end_hover.border_color = UiThemeScript.GOLD_FOCUS
	_simulation_session_end_button.add_theme_stylebox_override("hover", session_end_hover)
	_simulation_session_end_button.add_theme_stylebox_override("pressed", session_end_hover)
	_simulation_session_end_button.add_theme_stylebox_override("focus", session_end_hover)
	_simulation_session_end_button.add_theme_color_override("font_color", UiThemeScript.TEXT_BUTTON)
	_simulation_session_end_button.add_theme_color_override("font_hover_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_simulation_session_end_button.add_theme_color_override("font_pressed_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_simulation_session_end_button.pressed.connect(_on_simulation_session_end_pressed)
	add_child(_simulation_session_end_button)

	_historical_context_menu = MenuButton.new()
	_historical_context_menu.name = "HistoricalContextMenu"
	_historical_context_menu.text = "本局背景"
	_historical_context_menu.flat = false
	_historical_context_menu.visible = false
	_historical_context_menu.tooltip_text = "显示与当前开局相配的只读背景；不参与人物吸附、路线、事件或存档"
	_historical_context_menu.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_historical_context_menu.position = Vector2(-142, 18)
	_historical_context_menu.size = Vector2(124, 34)
	_historical_context_menu.z_index = 3000
	_historical_context_menu.add_theme_font_size_override("font_size", 13)
	var context_normal := sidebar_normal.duplicate() as StyleBoxFlat
	context_normal.border_color = UiThemeScript.BORDER_SHELL
	_historical_context_menu.add_theme_stylebox_override("normal", context_normal)
	var context_pressed := context_normal.duplicate() as StyleBoxFlat
	context_pressed.bg_color = Color("#E2DABF")
	context_pressed.border_color = UiThemeScript.GOLD_FOCUS
	_historical_context_menu.add_theme_stylebox_override("pressed", context_pressed)
	_historical_context_menu.add_theme_stylebox_override("hover_pressed", context_pressed)
	_historical_context_menu.add_theme_color_override("font_color", UiThemeScript.TEXT_BUTTON)
	_historical_context_menu.add_theme_color_override("font_pressed_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_historical_context_menu.get_popup().id_pressed.connect(_on_historical_context_menu_id_pressed)
	_historical_context_button = _historical_context_menu
	add_child(_historical_context_menu)

	_annotation_manager_menu = MenuButton.new()
	_annotation_manager_menu.name = "AnnotationManagerMenu"
	_annotation_manager_menu.text = "我的标记 0"
	_annotation_manager_menu.flat = false
	_annotation_manager_menu.tooltip_text = "分别显隐玩家便签、地点和事件；定位只移动视角，不改变标记数据"
	_annotation_manager_menu.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_annotation_manager_menu.position = Vector2(-142, 60)
	_annotation_manager_menu.size = Vector2(124, 34)
	_annotation_manager_menu.z_index = 3000
	_annotation_manager_menu.add_theme_font_size_override("font_size", 13)
	var annotation_menu_normal := sidebar_normal.duplicate() as StyleBoxFlat
	annotation_menu_normal.border_color = UiThemeScript.BORDER_SHELL
	_annotation_manager_menu.add_theme_stylebox_override("normal", annotation_menu_normal)
	var annotation_menu_pressed := annotation_menu_normal.duplicate() as StyleBoxFlat
	annotation_menu_pressed.bg_color = Color("#E4E4D1")
	annotation_menu_pressed.border_color = Color("#758C72")
	_annotation_manager_menu.add_theme_stylebox_override("pressed", annotation_menu_pressed)
	_annotation_manager_menu.add_theme_stylebox_override("hover_pressed", annotation_menu_pressed)
	_annotation_manager_menu.add_theme_color_override("font_color", UiThemeScript.TEXT_BUTTON)
	_annotation_manager_menu.add_theme_color_override("font_pressed_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_annotation_manager_menu.get_popup().id_pressed.connect(_on_annotation_manager_menu_id_pressed)
	add_child(_annotation_manager_menu)
	_rebuild_annotation_manager_menu()

	_stroke_manager_menu = MenuButton.new()
	_stroke_manager_menu.name = "PlayerStrokeManagerMenu"
	_stroke_manager_menu.text = "我的推演线 0"
	_stroke_manager_menu.flat = false
	_stroke_manager_menu.tooltip_text = "这些线只记录玩家自己的推演意图，不代表史实路线或自动行军"
	_stroke_manager_menu.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_stroke_manager_menu.position = Vector2(-142, 102)
	_stroke_manager_menu.size = Vector2(124, 34)
	_stroke_manager_menu.z_index = 3000
	_stroke_manager_menu.add_theme_font_size_override("font_size", 13)
	var stroke_menu_normal := annotation_menu_normal.duplicate() as StyleBoxFlat
	stroke_menu_normal.bg_color = Color(0.97, 0.94, 0.84, 0.95)
	stroke_menu_normal.border_color = UiThemeScript.BORDER_BRASS
	_stroke_manager_menu.add_theme_stylebox_override("normal", stroke_menu_normal)
	var stroke_menu_hover := stroke_menu_normal.duplicate() as StyleBoxFlat
	stroke_menu_hover.bg_color = Color("#FFF2CB")
	stroke_menu_hover.border_color = UiThemeScript.GOLD_FOCUS
	_stroke_manager_menu.add_theme_stylebox_override("hover", stroke_menu_hover)
	_stroke_manager_menu.add_theme_stylebox_override("pressed", stroke_menu_hover)
	_stroke_manager_menu.add_theme_stylebox_override("hover_pressed", stroke_menu_hover)
	_stroke_manager_menu.add_theme_color_override("font_color", UiThemeScript.TEXT_BUTTON)
	_stroke_manager_menu.add_theme_color_override("font_pressed_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_stroke_manager_menu.get_popup().id_pressed.connect(_on_player_stroke_manager_id_pressed)
	add_child(_stroke_manager_menu)
	_rebuild_player_stroke_manager_menu()

	_faction_influence_toggle_panel = PanelContainer.new()
	_faction_influence_toggle_panel.name = "FactionInfluenceTogglePanel"
	_faction_influence_toggle_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_faction_influence_toggle_panel.position = Vector2(-142, 144)
	_faction_influence_toggle_panel.size = Vector2(124, 34)
	_faction_influence_toggle_panel.custom_minimum_size = Vector2(124, 34)
	_faction_influence_toggle_panel.z_index = 3000
	_faction_influence_toggle_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var influence_panel_style := sidebar_normal.duplicate() as StyleBoxFlat
	influence_panel_style.border_color = UiThemeScript.BORDER_SHELL
	_faction_influence_toggle_panel.add_theme_stylebox_override("panel", influence_panel_style)
	add_child(_faction_influence_toggle_panel)

	_faction_influence_toggle = CheckButton.new()
	_faction_influence_toggle.name = "FactionInfluenceToggle"
	_faction_influence_toggle.text = "势力范围"
	_faction_influence_toggle.button_pressed = true
	_faction_influence_toggle.tooltip_text = "显示或隐藏当前沙盘中由城池归属形成的势力色块"
	_faction_influence_toggle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_faction_influence_toggle.add_theme_font_size_override("font_size", 13)
	_faction_influence_toggle.add_theme_color_override("font_color", UiThemeScript.TEXT_BUTTON)
	_faction_influence_toggle.add_theme_color_override("font_hover_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_faction_influence_toggle.add_theme_color_override("font_pressed_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_faction_influence_toggle.add_theme_color_override("font_hover_pressed_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_faction_influence_toggle.add_theme_color_override("font_focus_color", UiThemeScript.TEXT_BUTTON_HOVER)
	var influence_toggle_empty := StyleBoxEmpty.new()
	# 文字与开关作为一个整体向卡片中部收拢，避免两端贴边。
	influence_toggle_empty.set_content_margin(SIDE_LEFT, 9.0)
	influence_toggle_empty.set_content_margin(SIDE_RIGHT, 9.0)
	influence_toggle_empty.set_content_margin(SIDE_TOP, 0.0)
	influence_toggle_empty.set_content_margin(SIDE_BOTTOM, 0.0)
	for style_name in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		_faction_influence_toggle.add_theme_stylebox_override(style_name, influence_toggle_empty)
	_faction_influence_toggle.toggled.connect(_on_faction_influence_toggled)
	_faction_influence_toggle_panel.add_child(_faction_influence_toggle)

	_city_faction_details_toggle_panel = PanelContainer.new()
	_city_faction_details_toggle_panel.name = "CityFactionDetailsTogglePanel"
	_city_faction_details_toggle_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_city_faction_details_toggle_panel.position = Vector2(-142, 186)
	_city_faction_details_toggle_panel.size = Vector2(124, 34)
	_city_faction_details_toggle_panel.custom_minimum_size = Vector2(124, 34)
	_city_faction_details_toggle_panel.z_index = 3000
	_city_faction_details_toggle_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var city_details_panel_style := sidebar_normal.duplicate() as StyleBoxFlat
	city_details_panel_style.border_color = UiThemeScript.BORDER_SHELL
	_city_faction_details_toggle_panel.add_theme_stylebox_override("panel", city_details_panel_style)
	add_child(_city_faction_details_toggle_panel)

	_city_faction_details_toggle = CheckButton.new()
	_city_faction_details_toggle.name = "CityFactionDetailsToggle"
	_city_faction_details_toggle.text = "驻城详情"
	_city_faction_details_toggle.button_pressed = true
	_city_faction_details_toggle.tooltip_text = "展开驻城人物；关闭后只保留各势力摘要。52%／75% 总览会自动简化"
	_city_faction_details_toggle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_city_faction_details_toggle.add_theme_font_size_override("font_size", 13)
	_city_faction_details_toggle.add_theme_color_override("font_color", UiThemeScript.TEXT_BUTTON)
	_city_faction_details_toggle.add_theme_color_override("font_hover_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_city_faction_details_toggle.add_theme_color_override("font_pressed_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_city_faction_details_toggle.add_theme_color_override("font_hover_pressed_color", UiThemeScript.TEXT_BUTTON_HOVER)
	_city_faction_details_toggle.add_theme_color_override("font_focus_color", UiThemeScript.TEXT_BUTTON_HOVER)
	var city_details_toggle_empty := StyleBoxEmpty.new()
	city_details_toggle_empty.set_content_margin(SIDE_LEFT, 9.0)
	city_details_toggle_empty.set_content_margin(SIDE_RIGHT, 9.0)
	city_details_toggle_empty.set_content_margin(SIDE_TOP, 0.0)
	city_details_toggle_empty.set_content_margin(SIDE_BOTTOM, 0.0)
	for style_name in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		_city_faction_details_toggle.add_theme_stylebox_override(style_name, city_details_toggle_empty)
	_city_faction_details_toggle.toggled.connect(_on_city_faction_details_toggled)
	_city_faction_details_toggle_panel.add_child(_city_faction_details_toggle)
	_build_faction_influence_legend()
	_layout_right_sidebar_controls()

	_build_player_stroke_guide()
	_build_player_stroke_action_panel()
	_build_character_context_menu()

	var help := Label.new()
	help.name = "MapHelp"
	help.text = "滚轮缩放 · 中键/右键拖空白画布 · Alt 拖动自由落点 · 右键人物或势力标题打开操作"
	help.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	help.position = Vector2(22, -38)
	help.add_theme_font_size_override("font_size", 13)
	help.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	help.add_theme_color_override("font_outline_color", Color(0.98, 0.95, 0.85, 0.94))
	help.add_theme_constant_override("outline_size", 3)
	help.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(help)

	resized.connect(_on_resized)
	mouse_exited.connect(_hide_place_hover)
	set_process(false)
	call_deferred("_fit_initial")


func _build_character_context_menu() -> void:
	_character_context_menu = PopupMenu.new()
	_character_context_menu.name = "CharacterContextMenu"
	_character_context_menu.transient = true
	_character_context_menu.exclusive = false
	_character_context_menu.id_pressed.connect(_on_character_context_menu_id_pressed)
	add_child(_character_context_menu)
	_character_troop_menu = PopupMenu.new()
	_character_troop_menu.name = "CharacterTroopSubmenu"
	_character_troop_menu.id_pressed.connect(_on_character_context_menu_id_pressed)
	_character_context_menu.add_child(_character_troop_menu)
	_character_action_menu = PopupMenu.new()
	_character_action_menu.name = "CharacterActionSubmenu"
	_character_action_menu.id_pressed.connect(_on_character_context_menu_id_pressed)
	_character_context_menu.add_child(_character_action_menu)
	_character_faction_menu = PopupMenu.new()
	_character_faction_menu.name = "CharacterFactionSubmenu"
	_character_faction_menu.id_pressed.connect(_on_character_faction_menu_id_pressed)
	_character_context_menu.add_child(_character_faction_menu)
	_character_overlap_menu = PopupMenu.new()
	_character_overlap_menu.name = "CharacterOverlapSubmenu"
	_character_overlap_menu.id_pressed.connect(_on_character_overlap_menu_id_pressed)
	_character_context_menu.add_child(_character_overlap_menu)
	_rebuild_character_context_menu()


func _rebuild_character_context_menu() -> void:
	if _character_context_menu == null:
		return
	_character_context_menu.clear()
	_character_overlap_target_by_menu_id.clear()
	if _character_overlap_menu != null:
		_character_overlap_menu.clear()
	var group_ids := _valid_character_context_group_ids()
	if group_ids.size() > 1:
		var group_action := _character_group_action_state(group_ids)
		_character_context_menu.add_separator("已选 %d 人" % group_ids.size())
		_rebuild_character_action_menu(group_action)
		_character_context_menu.add_submenu_node_item(
			"批量行动：%s" % (
				"行动不一" if group_action == "mixed" else _character_action_label(group_action)
			),
			_character_action_menu,
			CHARACTER_CONTEXT_ACTION_MENU_ID
		)
		_character_context_menu.set_item_tooltip(
			_character_context_menu.get_item_index(CHARACTER_CONTEXT_ACTION_MENU_ID),
			"一次把所选人物统一设为待命、进攻或防御；只产生一条撤销记录"
		)
		_character_context_menu.add_separator()
		_character_context_menu.add_item(
			"整组收回背包（%d 人）" % group_ids.size(),
			CHARACTER_CONTEXT_RETURN_ID
		)
		_character_context_menu.set_item_tooltip(
			_character_context_menu.get_item_index(CHARACTER_CONTEXT_RETURN_ID),
			"一次收回所选人物；各自的兵力、四维、行动和本局势力仍保留"
		)
		return
	var character_name := str(_character_by_id.get(_character_context_id, {}).get("name", "人物"))
	_character_context_menu.add_item("查看%s人物卡…" % character_name, CHARACTER_CONTEXT_DETAILS_ID)
	_character_context_menu.set_item_tooltip(
		_character_context_menu.get_item_index(CHARACTER_CONTEXT_DETAILS_ID),
		"查看人物简介、四维、兵力、当前落点与玩家分组"
	)
	var overlap_targets := _rebuild_character_overlap_menu(_character_context_id)
	if overlap_targets.size() > 1:
		_character_context_menu.add_submenu_node_item(
			"切换重叠人物（%d 张）" % overlap_targets.size(),
			_character_overlap_menu,
			CHARACTER_CONTEXT_OVERLAP_MENU_ID
		)
		_character_context_menu.set_item_tooltip(
			_character_context_menu.get_item_index(CHARACTER_CONTEXT_OVERLAP_MENU_ID),
			"直接选择被当前卡压住的人物；只切换焦点与显示顺序，不移动卡牌"
		)
	var troop_count := int(_character_troops.get(_character_context_id, CharacterCardScript.DEFAULT_TROOP_COUNT))
	_rebuild_character_troop_menu(troop_count)
	_character_context_menu.add_submenu_node_item(
		"兵力：%s" % _format_troop_count_exact(troop_count),
		_character_troop_menu,
		CHARACTER_CONTEXT_TROOPS_MENU_ID
	)
	_character_context_menu.set_item_tooltip(
		_character_context_menu.get_item_index(CHARACTER_CONTEXT_TROOPS_MENU_ID),
		"就地增减或精确设置这名人物的本局兵力"
	)
	_character_context_menu.add_item("调整%s人物资料…" % character_name, CHARACTER_CONTEXT_ATTRIBUTES_ID)
	_character_context_menu.set_item_tooltip(
		_character_context_menu.get_item_index(CHARACTER_CONTEXT_ATTRIBUTES_ID),
		"调整人物卡中的武力、智力、统率、魅力"
	)
	_character_context_menu.add_separator()
	var current_action := str(_character_actions.get(_character_context_id, "standby"))
	_rebuild_character_action_menu(current_action)
	_character_context_menu.add_submenu_node_item("当前行动：%s" % _character_action_label(current_action), _character_action_menu, CHARACTER_CONTEXT_ACTION_MENU_ID)
	_character_context_menu.set_item_tooltip(
		_character_context_menu.get_item_index(CHARACTER_CONTEXT_ACTION_MENU_ID),
		"选择一个行动标记；修改可撤销"
	)
	var current_faction_id := str(_faction_by_character.get(_character_context_id, ""))
	var current_faction_name := str(_faction_name_by_id.get(current_faction_id, CITY_FACTION_UNASSIGNED_NAME))
	_rebuild_character_faction_menu()
	_character_context_menu.add_submenu_node_item(
		"所属势力：%s" % _compact_character_context_text(current_faction_name, 12),
		_character_faction_menu,
		CHARACTER_CONTEXT_FACTION_MENU_ID
	)
	_character_context_menu.set_item_tooltip(
		_character_context_menu.get_item_index(CHARACTER_CONTEXT_FACTION_MENU_ID),
		"把人物编入当前沙盘的势力；人物位置保持不变"
	)
	_character_context_menu.add_separator()
	_character_context_menu.add_item("收回%s至背包" % character_name, CHARACTER_CONTEXT_RETURN_ID)
	_character_context_menu.set_item_tooltip(
		_character_context_menu.get_item_index(CHARACTER_CONTEXT_RETURN_ID),
		"从地图移除这张人物卡；兵力与行动仍随当前沙盘保留"
	)


func _rebuild_character_troop_menu(current_troops: int) -> void:
	if _character_troop_menu == null:
		return
	_character_troop_menu.clear()
	var troop_entries := [
		{"id": CHARACTER_CONTEXT_TROOPS_MINUS_1000_ID, "label": "−1,000", "delta": -1000},
		{"id": CHARACTER_CONTEXT_TROOPS_MINUS_100_ID, "label": "−100", "delta": -100}
	]
	for troop_entry in troop_entries:
		_add_character_troop_delta_item(troop_entry, current_troops)
	_character_troop_menu.add_separator()
	_character_troop_menu.add_item("精确调整…", CHARACTER_CONTEXT_TROOPS_EXACT_ID)
	_character_troop_menu.set_item_tooltip(
		_character_troop_menu.get_item_index(CHARACTER_CONTEXT_TROOPS_EXACT_ID),
		"输入 0—999,999 的任意兵力"
	)
	_character_troop_menu.add_separator()
	for troop_entry in [
		{"id": CHARACTER_CONTEXT_TROOPS_PLUS_100_ID, "label": "+100", "delta": 100},
		{"id": CHARACTER_CONTEXT_TROOPS_PLUS_1000_ID, "label": "+1,000", "delta": 1000}
	]:
		_add_character_troop_delta_item(troop_entry, current_troops)
	_character_troop_menu.add_separator()
	_character_troop_menu.add_item("恢复默认 1,000", CHARACTER_CONTEXT_TROOPS_RESET_ID)
	var reset_index := _character_troop_menu.get_item_index(CHARACTER_CONTEXT_TROOPS_RESET_ID)
	_character_troop_menu.set_item_disabled(
		reset_index,
		current_troops == CharacterCardScript.DEFAULT_TROOP_COUNT
	)
	_character_troop_menu.set_item_tooltip(
		reset_index,
		"清除这名人物的本局兵力覆盖"
	)


func _add_character_troop_delta_item(entry: Dictionary, current_troops: int) -> void:
	var item_id := int(entry.get("id", -1))
	var delta := int(entry.get("delta", 0))
	var next_troops := clampi(
		current_troops + delta,
		CharacterCardScript.MIN_TROOP_COUNT,
		CharacterCardScript.MAX_TROOP_COUNT
	)
	_character_troop_menu.add_item(str(entry.get("label", "")), item_id)
	var item_index := _character_troop_menu.get_item_index(item_id)
	_character_troop_menu.set_item_disabled(item_index, next_troops == current_troops)
	_character_troop_menu.set_item_tooltip(
		item_index,
		"%s → %s" % [
			_format_troop_count_exact(current_troops),
			_format_troop_count_exact(next_troops)
		]
	)


func _rebuild_character_action_menu(current_action: String) -> void:
	if _character_action_menu == null:
		return
	_character_action_menu.clear()
	var previous_section := ""
	for definition_value in CharacterActionPolicyScript.definitions():
		if not (definition_value is Dictionary):
			continue
		var definition: Dictionary = definition_value
		var action := str(definition.get("action", ""))
		var item_id := _character_action_menu_id(action)
		if item_id < 0:
			continue
		var section := str(definition.get("section", "战场"))
		if section != previous_section:
			if not previous_section.is_empty():
				_character_action_menu.add_separator()
			_character_action_menu.add_separator(section)
			previous_section = section
		_character_action_menu.add_radio_check_item(str(definition.get("label", "")), item_id)
		var item_index := _character_action_menu.get_item_index(item_id)
		_character_action_menu.set_item_checked(
			item_index,
			current_action != "mixed" and action == current_action
		)
		_character_action_menu.set_item_tooltip(item_index, str(definition.get("hint", "")))


func _character_action_menu_id(action: String) -> int:
	match action:
		CharacterActionPolicyScript.ACTION_STANDBY:
			return CHARACTER_CONTEXT_ACTION_STANDBY_ID
		CharacterActionPolicyScript.ACTION_ATTACK:
			return CHARACTER_CONTEXT_ACTION_ATTACK_ID
		CharacterActionPolicyScript.ACTION_DEFEND:
			return CHARACTER_CONTEXT_ACTION_DEFEND_ID
		_:
			return -1


func _character_action_for_menu_id(item_id: int) -> String:
	for definition_value in CharacterActionPolicyScript.definitions():
		if not (definition_value is Dictionary):
			continue
		var definition: Dictionary = definition_value
		if _character_action_menu_id(str(definition.get("action", ""))) == item_id:
			return str(definition.get("action", ""))
	return ""


func _rebuild_character_overlap_menu(character_id: String) -> Array[Dictionary]:
	if _character_overlap_menu == null:
		return []
	_character_overlap_menu.clear()
	_character_overlap_target_by_menu_id.clear()
	var targets := get_overlapping_character_targets(character_id)
	for target_index in range(targets.size()):
		var target: Dictionary = targets[target_index]
		var item_id := CHARACTER_CONTEXT_OVERLAP_TARGET_BASE_ID + target_index
		var target_id := str(target.get("character_id", ""))
		var target_name := str(target.get("name", "人物"))
		var is_current := target_id == character_id
		_character_overlap_menu.add_radio_check_item(target_name, item_id)
		var item_index := _character_overlap_menu.get_item_index(item_id)
		_character_overlap_menu.set_item_checked(item_index, is_current)
		_character_overlap_menu.set_item_disabled(item_index, is_current)
		_character_overlap_menu.set_item_tooltip(
			item_index,
			"当前位于最上层" if is_current else "切换到%s；卡牌仍留在原位" % target_name
		)
		_character_overlap_target_by_menu_id[item_id] = target_id
	return targets


func _valid_character_context_group_ids() -> Array[String]:
	var result: Array[String] = []
	for character_id in _character_context_group_ids:
		if _placements.has(character_id) and _card_by_id.has(character_id) and character_id not in result:
			result.append(character_id)
	return result


func _character_group_action_state(character_ids: Array[String]) -> String:
	var shared_action := ""
	for character_id in character_ids:
		var action := CharacterActionPolicyScript.normalize(str(_character_actions.get(character_id, CharacterActionPolicyScript.DEFAULT_ACTION)))
		if shared_action.is_empty():
			shared_action = action
		elif shared_action != action:
			return "mixed"
	return shared_action if not shared_action.is_empty() else CharacterActionPolicyScript.DEFAULT_ACTION


func _rebuild_character_faction_menu() -> void:
	if _character_faction_menu == null:
		return
	_character_faction_menu.clear()
	_character_faction_target_by_menu_id.clear()
	var targets := _character_faction_assignment_targets(_character_context_id)
	for target_index in range(targets.size()):
		var target: Dictionary = targets[target_index]
		var item_id := CHARACTER_CONTEXT_FACTION_TARGET_BASE_ID + target_index
		var faction_id := str(target.get("faction_id", ""))
		_character_faction_menu.add_radio_check_item(str(target.get("label", CITY_FACTION_UNASSIGNED_NAME)), item_id)
		var item_index := _character_faction_menu.get_item_index(item_id)
		_character_faction_menu.set_item_checked(item_index, bool(target.get("checked", false)))
		_character_faction_menu.set_item_disabled(item_index, not bool(target.get("enabled", false)))
		_character_faction_menu.set_item_tooltip(item_index, str(target.get("tooltip", "")))
		_character_faction_target_by_menu_id[item_id] = faction_id
	var guidance := _character_faction_guidance(_character_context_id)
	if not guidance.is_empty():
		_character_faction_menu.add_separator()
		_character_faction_menu.add_item(guidance, CHARACTER_CONTEXT_FACTION_HELP_ID)
		var guidance_index := _character_faction_menu.get_item_index(CHARACTER_CONTEXT_FACTION_HELP_ID)
		_character_faction_menu.set_item_disabled(guidance_index, true)
		_character_faction_menu.set_item_tooltip(guidance_index, guidance)


func _character_faction_assignment_targets(character_id: String) -> Array[Dictionary]:
	var targets: Array[Dictionary] = []
	var current_faction_id := str(_faction_by_character.get(character_id, ""))
	var current_member_count := _character_faction_member_count(current_faction_id)
	var locks_alternate_targets := not current_faction_id.is_empty() and current_member_count <= 1
	targets.append({
		"faction_id": "",
		"label": CITY_FACTION_UNASSIGNED_NAME,
		"checked": current_faction_id.is_empty(),
		"enabled": current_faction_id.is_empty() or not locks_alternate_targets,
		"tooltip": (
			"这名人物当前未编入势力"
			if current_faction_id.is_empty()
			else (
				"该势力仅剩这名人物；请先从“沙盘”菜单调整势力成员"
				if locks_alternate_targets
				else "设为未编组；人物位置保持不变"
			)
		)
	})
	var faction_ids := _faction_name_by_id.keys()
	faction_ids.sort_custom(func(first: Variant, second: Variant) -> bool:
		return int(_faction_order_by_id.get(str(first), 0)) < int(_faction_order_by_id.get(str(second), 0))
	)
	for faction_id_value in faction_ids:
		var faction_id := str(faction_id_value)
		var is_current := faction_id == current_faction_id
		var enabled := is_current or not locks_alternate_targets
		targets.append({
			"faction_id": faction_id,
			"label": str(_faction_name_by_id.get(faction_id, "未命名势力")),
			"checked": is_current,
			"enabled": enabled,
			"tooltip": (
				"当前所属势力"
				if is_current
				else (
					"该势力仅剩这名人物；请先从“沙盘”菜单调整势力成员"
					if not enabled
					else "编入该势力；人物位置保持不变"
				)
			)
		})
	return targets


func _character_faction_member_count(faction_id: String) -> int:
	if faction_id.is_empty():
		return 0
	var member_count := 0
	for assigned_faction_id_value in _faction_by_character.values():
		if str(assigned_faction_id_value) == faction_id:
			member_count += 1
	return member_count


func _character_faction_guidance(character_id: String) -> String:
	if _faction_name_by_id.is_empty():
		return "可从“沙盘”菜单建立势力"
	var current_faction_id := str(_faction_by_character.get(character_id, ""))
	if not current_faction_id.is_empty() and _character_faction_member_count(current_faction_id) <= 1:
		return "该势力仅剩一人，请先调整其他成员"
	return ""


func _compact_character_context_text(value: String, max_characters: int) -> String:
	if value.length() <= max_characters:
		return value
	return "%s…" % value.left(maxi(1, max_characters - 1))


func _character_action_label(action: String) -> String:
	match action:
		"attack":
			return "进攻"
		"defend":
			return "防御"
		_:
			return "待命"


func open_character_context_menu(character_id: String, local_position: Vector2) -> bool:
	if (
		_character_context_menu == null
		or character_id.is_empty()
		or not _placements.has(character_id)
		or not _card_by_id.has(character_id)
		or _annotation_tool_active
		or _player_stroke_tool_active
		or _player_stroke_point_edit_active
	):
		return false
	_character_context_group_ids.clear()
	if _selected_character_ids.size() > 1 and _selected_character_ids.has(character_id):
		# 右键已选成员时保留整组；它只是本次菜单的主动人物，不改变选择集合。
		_selected_character_id = character_id
		_character_context_group_ids.assign(get_selected_character_ids())
		_refresh_character_selection_presentation()
		_raise_card_base_order(character_id)
	else:
		_select_only_character(character_id)
	# 人物操作菜单已经承接鼠标注意力；隐藏地点悬停札记，避免两层浮窗互相遮挡。
	_hide_place_hover()
	_character_context_id = character_id
	_rebuild_character_context_menu()
	var single_popup_height := 308.0 if get_overlapping_character_targets(character_id).size() > 1 else 276.0
	var popup_size := Vector2(326.0, 150.0 if _character_context_group_ids.size() > 1 else single_popup_height)
	var bounded := Vector2(
		clampf(local_position.x, 8.0, maxf(8.0, size.x - popup_size.x - 8.0)),
		clampf(local_position.y, 8.0, maxf(8.0, size.y - popup_size.y - 8.0))
	)
	_character_context_menu.position = Vector2i(roundi(global_position.x + bounded.x), roundi(global_position.y + bounded.y))
	_character_context_menu.popup()
	return true


func activate_character_context_action(character_id: String, action_id: int) -> bool:
	if character_id.is_empty() or not _placements.has(character_id):
		return false
	_character_context_id = character_id
	if _character_context_group_ids.size() > 1 and action_id not in [
		CHARACTER_CONTEXT_ACTION_STANDBY_ID,
		CHARACTER_CONTEXT_ACTION_ATTACK_ID,
		CHARACTER_CONTEXT_ACTION_DEFEND_ID,
		CHARACTER_CONTEXT_RETURN_ID,
	]:
		return false
	if action_id not in [
		CHARACTER_CONTEXT_DETAILS_ID,
		CHARACTER_CONTEXT_TROOPS_MINUS_1000_ID,
		CHARACTER_CONTEXT_TROOPS_MINUS_100_ID,
		CHARACTER_CONTEXT_TROOPS_EXACT_ID,
		CHARACTER_CONTEXT_TROOPS_PLUS_100_ID,
		CHARACTER_CONTEXT_TROOPS_PLUS_1000_ID,
		CHARACTER_CONTEXT_TROOPS_RESET_ID,
		CHARACTER_CONTEXT_ATTRIBUTES_ID,
		CHARACTER_CONTEXT_ACTION_STANDBY_ID,
		CHARACTER_CONTEXT_ACTION_ATTACK_ID,
		CHARACTER_CONTEXT_ACTION_DEFEND_ID,
		CHARACTER_CONTEXT_RETURN_ID
	]:
		return false
	_on_character_context_menu_id_pressed(action_id)
	return true


func activate_character_faction_assignment(character_id: String, faction_id: String) -> bool:
	if character_id.is_empty() or not _placements.has(character_id):
		return false
	_character_context_id = character_id
	for target in _character_faction_assignment_targets(character_id):
		if str(target.get("faction_id", "")) != faction_id:
			continue
		if not bool(target.get("enabled", false)):
			return false
		if _character_context_menu != null:
			_character_context_menu.hide()
		if _character_faction_menu != null:
			_character_faction_menu.hide()
		character_faction_assignment_requested.emit(character_id, faction_id)
		_character_context_id = ""
		return true
	return false


func get_overlapping_character_targets(character_id: String) -> Array[Dictionary]:
	var targets: Array[Dictionary] = []
	if character_id.is_empty() or not _placements.has(character_id) or not _card_by_id.has(character_id):
		return targets
	var source_card: CharacterCard = _card_by_id[character_id]
	var source_rect := _visible_control_global_rect(source_card)
	if not source_rect.has_area():
		return targets
	var overlapping_ids: Array[String] = [character_id]
	var overlap_ratio_by_id := {character_id: 1.0}
	for candidate_id_value in _card_by_id:
		var candidate_id := str(candidate_id_value)
		if candidate_id == character_id or _active_drag_ids.has(candidate_id):
			continue
		var candidate_card: CharacterCard = _card_by_id[candidate_id]
		var candidate_rect := _visible_control_global_rect(candidate_card)
		var overlap_ratio := _character_screen_overlap_ratio(source_rect, candidate_rect)
		if overlap_ratio + 0.0001 < CHARACTER_OVERLAP_MIN_RATIO:
			continue
		overlapping_ids.append(candidate_id)
		overlap_ratio_by_id[candidate_id] = overlap_ratio
	if overlapping_ids.size() <= 1:
		return targets
	overlapping_ids.sort_custom(_sort_character_ids_by_z)
	overlapping_ids.reverse()
	for target_id in overlapping_ids:
		targets.append({
			"character_id": target_id,
			"name": str(_character_by_id.get(target_id, {}).get("name", target_id)),
			"current": target_id == character_id,
			"overlap_ratio": snappedf(float(overlap_ratio_by_id.get(target_id, 0.0)), 0.001)
		})
	return targets


func activate_character_overlap_target(target_id: String) -> bool:
	var source_id := _character_context_id
	if source_id.is_empty() or target_id.is_empty() or source_id == target_id:
		return false
	var target_available := false
	for target in get_overlapping_character_targets(source_id):
		if str(target.get("character_id", "")) == target_id:
			target_available = true
			break
	if not target_available:
		return false
	if _character_context_menu != null:
		_character_context_menu.hide()
	if _character_overlap_menu != null:
		_character_overlap_menu.hide()
	_character_context_id = ""
	_character_context_group_ids.clear()
	_hovered_character_id = ""
	_select_only_character(target_id)
	return true


func get_character_context_contract() -> Dictionary:
	var current_faction_id := str(_faction_by_character.get(_character_context_id, ""))
	var group_ids := _valid_character_context_group_ids()
	if group_ids.size() > 1:
		return {
			"actions": _character_action_contract_entries(true) + [
				{"id": CHARACTER_CONTEXT_RETURN_ID, "key": "return_group_to_backpack", "label": "整组收回背包"},
			],
			"character_id": _character_context_id,
			"character_ids": group_ids,
			"selection_count": group_ids.size(),
			"group_mode": true,
			"current_action": _character_group_action_state(group_ids),
			"right_click": true,
			"extensible": true,
		}
	var overlap_targets := get_overlapping_character_targets(_character_context_id)
	var context_actions: Array[Dictionary] = [
		{"id": CHARACTER_CONTEXT_DETAILS_ID, "key": "view_details", "label": "查看人物卡"}
	]
	if overlap_targets.size() > 1:
		context_actions.append({
			"id": CHARACTER_CONTEXT_OVERLAP_MENU_ID,
			"key": "switch_overlapping_character",
			"label": "切换重叠人物"
		})
	context_actions.append_array([
		{"id": CHARACTER_CONTEXT_TROOPS_EXACT_ID, "key": "edit_troops", "label": "精确调整兵力"},
		{"id": CHARACTER_CONTEXT_ATTRIBUTES_ID, "key": "edit_sandbox_attributes", "label": "调整人物资料"},
	])
	context_actions.append_array(_character_action_contract_entries(false))
	context_actions.append_array([
		{"id": CHARACTER_CONTEXT_FACTION_MENU_ID, "key": "assign_sandbox_faction", "label": "所属势力"},
		{"id": CHARACTER_CONTEXT_RETURN_ID, "key": "return_to_backpack", "label": "收回背包"}
	])
	return {
		"actions": context_actions,
		"character_id": _character_context_id,
		"character_ids": [_character_context_id] if not _character_context_id.is_empty() else [],
		"selection_count": 1 if not _character_context_id.is_empty() else 0,
		"group_mode": false,
		"troop_count": int(_character_troops.get(_character_context_id, CharacterCardScript.DEFAULT_TROOP_COUNT)),
		"troop_adjustments": [
			{"id": CHARACTER_CONTEXT_TROOPS_MINUS_1000_ID, "key": "troops_minus_1000", "label": "−1,000", "delta": -1000},
			{"id": CHARACTER_CONTEXT_TROOPS_MINUS_100_ID, "key": "troops_minus_100", "label": "−100", "delta": -100},
			{"id": CHARACTER_CONTEXT_TROOPS_EXACT_ID, "key": "edit_troops", "label": "精确调整…", "delta": 0},
			{"id": CHARACTER_CONTEXT_TROOPS_PLUS_100_ID, "key": "troops_plus_100", "label": "+100", "delta": 100},
			{"id": CHARACTER_CONTEXT_TROOPS_PLUS_1000_ID, "key": "troops_plus_1000", "label": "+1,000", "delta": 1000},
			{"id": CHARACTER_CONTEXT_TROOPS_RESET_ID, "key": "troops_reset_default", "label": "恢复默认 1,000", "reset_to_default": true}
		],
		"current_action": str(_character_actions.get(_character_context_id, "standby")),
		"faction_assignment": {
			"current_faction_id": current_faction_id,
			"current_faction_name": str(_faction_name_by_id.get(current_faction_id, CITY_FACTION_UNASSIGNED_NAME)),
			"targets": _character_faction_assignment_targets(_character_context_id),
			"guidance": _character_faction_guidance(_character_context_id)
		},
		"overlap_access": {
			"available": overlap_targets.size() > 1,
			"targets": overlap_targets,
			"minimum_overlap_ratio": CHARACTER_OVERLAP_MIN_RATIO,
			"moves_cards": false,
			"persistent": false
		},
		"right_click": true,
		"extensible": true
	}


func _character_action_contract_entries(group_mode: bool) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var key_prefix := "set_group_action_" if group_mode else "set_action_"
	var label_prefix := "整组" if group_mode else ""
	for definition_value in CharacterActionPolicyScript.definitions():
		if not (definition_value is Dictionary):
			continue
		var definition: Dictionary = definition_value
		var action := str(definition.get("action", ""))
		var item_id := _character_action_menu_id(action)
		if item_id < 0:
			continue
		entries.append({
			"id": item_id,
			"key": "%s%s" % [key_prefix, action],
			"label": "%s%s" % [label_prefix, str(definition.get("label", ""))],
			"action": action,
			"section": str(definition.get("section", "战场")),
			"short": str(definition.get("short", "")),
		})
	return entries


func get_character_card(character_id: String) -> CharacterCard:
	return _card_by_id.get(character_id) as CharacterCard


func _on_map_card_context_requested(character_id: String, viewport_position: Vector2) -> void:
	open_character_context_menu(character_id, viewport_position - global_position)


func _on_character_context_menu_id_pressed(item_id: int) -> void:
	var character_id := _character_context_id
	var group_ids := _valid_character_context_group_ids()
	if not character_id.is_empty() and _placements.has(character_id):
		if _character_context_menu != null:
			_character_context_menu.hide()
		if group_ids.size() > 1 and item_id == CHARACTER_CONTEXT_ACTION_STANDBY_ID:
			character_group_action_requested.emit(group_ids, "standby")
		elif group_ids.size() > 1 and item_id == CHARACTER_CONTEXT_ACTION_ATTACK_ID:
			character_group_action_requested.emit(group_ids, "attack")
		elif group_ids.size() > 1 and item_id == CHARACTER_CONTEXT_ACTION_DEFEND_ID:
			character_group_action_requested.emit(group_ids, "defend")
		elif group_ids.size() > 1 and item_id == CHARACTER_CONTEXT_RETURN_ID:
			character_group_return_requested.emit(group_ids)
		elif item_id == CHARACTER_CONTEXT_DETAILS_ID:
			character_details_requested.emit(character_id)
		elif item_id == CHARACTER_CONTEXT_TROOPS_EXACT_ID:
			character_troops_requested.emit(character_id)
		elif item_id == CHARACTER_CONTEXT_TROOPS_MINUS_1000_ID:
			character_troop_adjust_requested.emit(character_id, -1000, false)
		elif item_id == CHARACTER_CONTEXT_TROOPS_MINUS_100_ID:
			character_troop_adjust_requested.emit(character_id, -100, false)
		elif item_id == CHARACTER_CONTEXT_TROOPS_PLUS_100_ID:
			character_troop_adjust_requested.emit(character_id, 100, false)
		elif item_id == CHARACTER_CONTEXT_TROOPS_PLUS_1000_ID:
			character_troop_adjust_requested.emit(character_id, 1000, false)
		elif item_id == CHARACTER_CONTEXT_TROOPS_RESET_ID:
			character_troop_adjust_requested.emit(character_id, 0, true)
		elif item_id == CHARACTER_CONTEXT_ATTRIBUTES_ID:
			character_attributes_requested.emit(character_id)
		elif item_id == CHARACTER_CONTEXT_ACTION_STANDBY_ID:
			character_action_requested.emit(character_id, "standby")
		elif item_id == CHARACTER_CONTEXT_ACTION_ATTACK_ID:
			character_action_requested.emit(character_id, "attack")
		elif item_id == CHARACTER_CONTEXT_ACTION_DEFEND_ID:
			character_action_requested.emit(character_id, "defend")
		elif item_id == CHARACTER_CONTEXT_RETURN_ID:
			character_return_requested.emit(character_id)
	_character_context_id = ""
	_character_context_group_ids.clear()


func _on_character_faction_menu_id_pressed(item_id: int) -> void:
	if not _character_faction_target_by_menu_id.has(item_id):
		return
	var character_id := _character_context_id
	var faction_id := str(_character_faction_target_by_menu_id.get(item_id, ""))
	activate_character_faction_assignment(character_id, faction_id)


func _on_character_overlap_menu_id_pressed(item_id: int) -> void:
	if not _character_overlap_target_by_menu_id.has(item_id):
		return
	activate_character_overlap_target(str(_character_overlap_target_by_menu_id.get(item_id, "")))


func _build_player_stroke_guide() -> void:
	_stroke_guide_panel = PanelContainer.new()
	_stroke_guide_panel.name = "PlayerStrokeGuide"
	_stroke_guide_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_stroke_guide_panel.position = Vector2(-300, -68)
	_stroke_guide_panel.size = Vector2(600, 46)
	_stroke_guide_panel.z_index = 3100
	_stroke_guide_panel.visible = false
	var style := UiThemeScript.make_floating_tool_panel(
		0.96,
		3,
		Vector4(12, 6, 8, 6)
	)
	_stroke_guide_panel.add_theme_stylebox_override("panel", style)
	add_child(_stroke_guide_panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_stroke_guide_panel.add_child(row)
	_stroke_guide_label = Label.new()
	_stroke_guide_label.text = "单击落点，双击或 Enter 完成"
	_stroke_guide_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stroke_guide_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_stroke_guide_label.add_theme_font_size_override("font_size", 13)
	_stroke_guide_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	row.add_child(_stroke_guide_label)
	_stroke_undo_point_button = Button.new()
	_stroke_undo_point_button.text = "撤一点"
	_stroke_undo_point_button.custom_minimum_size = Vector2(68, 32)
	_stroke_undo_point_button.pressed.connect(undo_player_stroke_draft_point)
	row.add_child(_stroke_undo_point_button)
	_stroke_finish_button = Button.new()
	_stroke_finish_button.text = "完成"
	_stroke_finish_button.custom_minimum_size = Vector2(62, 32)
	_stroke_finish_button.pressed.connect(finish_player_stroke_interaction)
	row.add_child(_stroke_finish_button)
	_stroke_cancel_button = Button.new()
	_stroke_cancel_button.text = "取消"
	_stroke_cancel_button.custom_minimum_size = Vector2(62, 32)
	_stroke_cancel_button.pressed.connect(cancel_player_stroke_interaction)
	row.add_child(_stroke_cancel_button)
	_refresh_player_stroke_guide()


func _build_player_stroke_action_panel() -> void:
	_stroke_action_panel = PanelContainer.new()
	_stroke_action_panel.name = "PlayerStrokeActionPanel"
	_stroke_action_panel.size = Vector2(280, 42)
	_stroke_action_panel.z_index = 3050
	_stroke_action_panel.visible = false
	var style := UiThemeScript.make_floating_tool_panel(
		0.95,
		3,
		Vector4(10, 5, 6, 5)
	)
	_stroke_action_panel.add_theme_stylebox_override("panel", style)
	add_child(_stroke_action_panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	_stroke_action_panel.add_child(row)
	_stroke_action_label = Label.new()
	_stroke_action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stroke_action_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_stroke_action_label.add_theme_font_size_override("font_size", 13)
	_stroke_action_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	row.add_child(_stroke_action_label)
	var route_button := Button.new()
	route_button.text = "路线"
	route_button.tooltip_text = "拖动已有折点调整路线；保存时只形成一步撤销"
	route_button.custom_minimum_size = Vector2(46, 30)
	route_button.pressed.connect(_request_selected_player_stroke_geometry_edit)
	row.add_child(route_button)
	var edit_button := Button.new()
	edit_button.text = "信息"
	edit_button.tooltip_text = "修改推演线类型和说明"
	edit_button.custom_minimum_size = Vector2(46, 30)
	edit_button.pressed.connect(_request_selected_player_stroke_edit)
	row.add_child(edit_button)
	var delete_button := Button.new()
	delete_button.text = "删除"
	delete_button.custom_minimum_size = Vector2(46, 30)
	delete_button.pressed.connect(_request_selected_player_stroke_delete)
	row.add_child(delete_button)


func set_data(
	characters: Array,
	places_value: Array,
	routes_value: Array,
	placements_value: Dictionary,
	land_value: Dictionary = {},
	river_value: Dictionary = {},
	lake_value: Dictionary = {},
	mountains_value: Array = [],
	geographic_context_value: Array = []
) -> void:
	_character_by_id.clear()
	_character_order_by_id.clear()
	for index in range(characters.size()):
		var character: Dictionary = characters[index]
		_character_by_id[str(character.get("id", ""))] = character
		_character_order_by_id[str(character.get("id", ""))] = index
	_places = places_value
	_routes = routes_value
	_land_data = land_value
	_river_data = river_value
	_lake_data = lake_value
	_mountains = mountains_value
	_geographic_context_records.clear()
	for record_value in geographic_context_value:
		if record_value is Dictionary:
			_geographic_context_records.append((record_value as Dictionary).duplicate(true))
	_compile_place_targets()
	_revalidate_place_relation_context()
	_placements = placements_value
	if _faction_influence_layer != null:
		_faction_influence_layer.configure(MAP_CONTENT_RECT, _places, _land_data)
		_faction_influence_layer.set_view_zoom(zoom)
	if _terrain_canvas != null:
		_terrain_canvas.set_data([], [], _land_data, _river_data, _lake_data, [])
		_rebuild_static_cache()
	if _canvas != null:
		_canvas.set_data(
			_places,
			_routes,
			{},
			_river_data,
			{},
			_mountains,
			_geographic_context_records
		)
		_canvas.set_near_hachures_visible(_near_hachures_visible)
		_canvas.set_strategic_corridors_visible(_strategic_corridors_visible)
		_canvas.set_view_zoom(zoom)
		_request_annotation_cache_rebuild()
	if _semantic_canvas != null:
		_semantic_canvas.set_data(
			_places,
			_routes,
			{},
			_river_data,
			{},
			_mountains,
			_geographic_context_records
		)
		_semantic_canvas.set_near_hachures_visible(_near_hachures_visible)
		_semantic_canvas.set_strategic_corridors_visible(_strategic_corridors_visible)
		_semantic_canvas.set_view_zoom(zoom)
	_sync_historical_context_canvas(false)
	if _faction_influence_layer != null:
		_faction_influence_layer.set_scenario_state(_scenario_state)
	_rebuild_faction_identity_markers(true)
	_refresh_placed_cards()


func set_pass_symbol_variant(value: String) -> bool:
	var changed := false
	if _canvas != null:
		changed = _canvas.set_pass_symbol_variant(value) or changed
	if _semantic_canvas != null:
		changed = _semantic_canvas.set_pass_symbol_variant(value) or changed
	return changed


func get_pass_symbol_variant() -> String:
	if _semantic_canvas != null:
		return _semantic_canvas.get_pass_symbol_variant()
	return _canvas.get_pass_symbol_variant() if _canvas != null else PASS_SYMBOL_VARIANT_V3


func get_pass_symbol_review_contract() -> Dictionary:
	if _semantic_canvas != null:
		return _semantic_canvas.get_pass_symbol_review_contract()
	return _canvas.get_pass_symbol_review_contract() if _canvas != null else {}


func set_terrain_relief_variant(value: String) -> bool:
	if _terrain_canvas == null:
		return false
	var changed := _terrain_canvas.set_terrain_relief_variant(value)
	if changed and not _land_data.is_empty():
		_rebuild_static_cache()
	return changed


func get_terrain_relief_variant() -> String:
	return (
		_terrain_canvas.get_terrain_relief_variant()
		if _terrain_canvas != null
		else TERRAIN_RELIEF_VARIANT_HR_V1
	)


func get_terrain_relief_review_contract() -> Dictionary:
	return (
		_terrain_canvas.get_terrain_relief_review_contract()
		if _terrain_canvas != null
		else {}
	)


func set_terrain_visual_profile(value: String) -> bool:
	if _terrain_canvas == null:
		return false
	if value == TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1 and _jade_terrain_material == null:
		# Load once on demand; default daylight does not retain this extra texture.
		var relief_delta := load("res://assets/jade_relief_delta.res") as Texture2D
		if relief_delta == null:
			push_error("Cannot load jade relief detail; keeping the current map profile")
			return false
		_jade_terrain_material = ShaderMaterial.new()
		_jade_terrain_material.shader = preload("res://src/jade_terrain.gdshader")
		_jade_terrain_material.set_shader_parameter("relief_delta_texture", relief_delta)
	var changed := _terrain_canvas.set_terrain_visual_profile(value)
	if changed:
		if _semantic_canvas != null:
			_semantic_canvas.set_terrain_visual_profile(value)
		if value == TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1:
			_terrain_texture.material = _jade_terrain_material
		else:
			_terrain_texture.material = _cache_clarity_material
		_update_cache_clarity()
	if changed and not _land_data.is_empty():
		_rebuild_static_cache()
	return changed


func get_terrain_visual_profile() -> String:
	return (
		_terrain_canvas.get_terrain_visual_profile()
		if _terrain_canvas != null
		else TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1
	)


func get_terrain_visual_profile_review_contract() -> Dictionary:
	return (
		_terrain_canvas.get_terrain_visual_profile_review_contract()
		if _terrain_canvas != null
		else {}
	)


func set_scenario_state(value: Dictionary) -> void:
	_scenario_state = value.duplicate(true)
	_faction_name_by_id.clear()
	_faction_order_by_id.clear()
	_faction_color_by_id.clear()
	_faction_by_character.clear()
	for index in range((_scenario_state.get("factions", []) as Array).size()):
		var faction_value: Variant = (_scenario_state.get("factions", []) as Array)[index]
		if not (faction_value is Dictionary):
			continue
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", "")).strip_edges()
		var faction_name := str(faction.get("name", "")).strip_edges()
		var faction_color := FactionPaletteScript.normalize_hex(faction.get("color", ""))
		if faction_color.is_empty():
			faction_color = FactionPaletteScript.default_hex(index)
		if faction_id.is_empty() or faction_name.is_empty() or _faction_name_by_id.has(faction_id):
			continue
		_faction_name_by_id[faction_id] = faction_name
		_faction_order_by_id[faction_id] = index
		_faction_color_by_id[faction_id] = faction_color
	for assignment_value in _scenario_state.get("character_assignments", []):
		if not (assignment_value is Dictionary):
			continue
		var assignment: Dictionary = assignment_value
		var character_id := str(assignment.get("character_id", "")).strip_edges()
		var faction_id := str(assignment.get("faction_id", "")).strip_edges()
		if _character_by_id.has(character_id) and _faction_name_by_id.has(faction_id):
			_faction_by_character[character_id] = faction_id
	if _faction_influence_layer != null:
		_faction_influence_layer.set_scenario_state(_scenario_state)
	_rebuild_faction_identity_markers()
	_rebuild_faction_influence_legend()
	_refresh_faction_inspection_highlight()
	_refresh_annotations()
	for character_id_value in _card_by_id:
		var character_id := str(character_id_value)
		(_card_by_id[character_id] as CharacterCard).set_accent(_accent_for_character(character_id))
	if _world_layer != null:
		_rebuild_stack_layout()
		_layout_all_cards()


func set_simulation_session_active(value: bool, session_name := "") -> void:
	var changed := _simulation_session_active_ui != value
	_simulation_session_active_ui = value
	if _simulation_session_end_button != null:
		_simulation_session_end_button.visible = value
		_simulation_session_end_button.tooltip_text = (
			"结束“%s”，比较起点与现状，并写入玩家纪事" % session_name
			if value and not session_name.strip_edges().is_empty()
			else "结束当前推演，比较起点与现状，并写入玩家纪事"
		)
	_layout_right_sidebar_controls()
	if changed:
		_queue_place_dock_overlay_refresh()


func _layout_right_sidebar_controls() -> void:
	for control in [_map_tools_panel, _annotation_manager_menu, _stroke_manager_menu, _faction_influence_toggle_panel, _city_faction_details_toggle_panel]:
		if control != null:
			control.visible = _map_tools_visible
	if _historical_context_menu != null:
		_historical_context_menu.visible = _map_tools_visible and not _historical_context_layer_order.is_empty()
	if _simulation_session_end_button != null:
		_simulation_session_end_button.visible = _map_tools_visible and _simulation_session_active_ui
	var session_offset := 38.0 if _simulation_session_active_ui else 0.0
	if _map_tools_panel != null:
		_set_top_right_control_rect(_map_tools_panel, 184.0, 18.0, 202.0 + session_offset)
	var top := 26.0
	for control in [_simulation_session_end_button, _historical_context_menu, _annotation_manager_menu, _stroke_manager_menu, _faction_influence_toggle_panel, _city_faction_details_toggle_panel]:
		if control == null or (control == _simulation_session_end_button and not _simulation_session_active_ui):
			continue
		_set_top_right_control_rect(control, 168.0, top, 34.0)
		control.offset_left -= 8.0
		control.offset_right -= 8.0
		top += 38.0
	if _faction_influence_legend_panel != null:
		_set_top_right_control_rect(_faction_influence_legend_panel, 184.0, 226.0 + session_offset, _faction_influence_legend_panel.size.y)
	_sync_faction_influence_legend_visibility(is_faction_influence_visible())


func set_map_tools_visible(value: bool) -> void:
	if _map_tools_visible == value:
		return
	_map_tools_visible = value
	if not value:
		for menu in [_historical_context_menu, _annotation_manager_menu, _stroke_manager_menu]:
			if menu != null:
				menu.get_popup().hide()
	_layout_right_sidebar_controls()
	_queue_place_dock_overlay_refresh()


func is_map_tools_visible() -> bool:
	return _map_tools_visible


func _set_top_right_control_rect(control: Control, width: float, top: float, height: float) -> void:
	control.offset_left = -width - 18.0
	control.offset_right = -18.0
	control.offset_top = top
	control.offset_bottom = top + maxf(height, control.custom_minimum_size.y)


func _on_simulation_session_end_pressed() -> void:
	simulation_session_end_requested.emit()


func set_character_states(value: Dictionary) -> void:
	_character_states = value.duplicate(true)
	var card_size_changed := false
	for character_id_value in _card_by_id:
		var character_id := str(character_id_value)
		var card: CharacterCard = _card_by_id[character_id]
		card_size_changed = card.set_runtime_attributes(_character_states.get(character_id, {})) or card_size_changed
	if _world_layer != null:
		if card_size_changed:
			_rebuild_stack_layout()
		_layout_all_cards()


func set_character_actions(value: Dictionary) -> void:
	_character_actions = value.duplicate(true)
	for character_id_value in _card_by_id:
		var character_id := str(character_id_value)
		(_card_by_id[character_id] as CharacterCard).set_action_state(str(_character_actions.get(character_id, "standby")))
	if _world_layer != null:
		_rebuild_stack_layout()
		_layout_all_cards()


func set_character_troops(value: Dictionary) -> void:
	_character_troops = value.duplicate(true)
	for character_id_value in _card_by_id:
		var character_id := str(character_id_value)
		(_card_by_id[character_id] as CharacterCard).set_troop_count(
			int(_character_troops.get(character_id, CharacterCardScript.DEFAULT_TROOP_COUNT))
		)
	if _character_context_menu != null and _character_context_menu.visible:
		_rebuild_character_context_menu()


func set_character_portraits(value: Dictionary) -> void:
	_character_portraits = value.duplicate()
	for character_id_value in _card_by_id:
		var character_id := str(character_id_value)
		(_card_by_id[character_id] as CharacterCard).set_portrait_texture(
			_character_portraits.get(character_id) as Texture2D
		)


func get_character_troop_count(character_id: String) -> int:
	return int(_character_troops.get(character_id, CharacterCardScript.DEFAULT_TROOP_COUNT))


func get_character_portrait_available(character_id: String) -> bool:
	return _character_portraits.get(character_id) is Texture2D


func get_character_action(character_id: String) -> String:
	return str(_character_actions.get(character_id, "standby"))


func get_character_state(character_id: String) -> Dictionary:
	return (_character_states.get(character_id, {}) as Dictionary).duplicate(true)


func set_strategic_corridors_visible(value: bool) -> void:
	if _strategic_corridors_visible == value:
		if _strategic_corridor_button != null:
			_strategic_corridor_button.set_pressed_no_signal(value)
		return
	_strategic_corridors_visible = value
	if _strategic_corridor_button != null:
		_strategic_corridor_button.set_pressed_no_signal(value)
	if _canvas != null and _canvas.set_strategic_corridors_visible(value):
		_request_annotation_cache_rebuild()
	strategic_corridors_visibility_changed.emit(value)


func are_strategic_corridors_visible() -> bool:
	return _strategic_corridors_visible


func set_near_hachures_visible(value: bool) -> void:
	if _near_hachures_visible == value:
		return
	_near_hachures_visible = value
	if _canvas != null and _canvas.set_near_hachures_visible(value):
		_request_annotation_cache_rebuild()


func are_near_hachures_visible() -> bool:
	return _near_hachures_visible


func set_historical_context_layer(value: Dictionary) -> void:
	set_historical_context_layers([value])


func set_historical_context_layers(values: Array) -> void:
	_historical_context_layers.clear()
	_historical_context_layers_by_id.clear()
	_historical_context_layer_order.clear()
	_historical_context_visibility_by_id.clear()
	_historical_context_layer.clear()
	for layer_value in values:
		if not (layer_value is Dictionary):
			continue
		var layer: Dictionary = (layer_value as Dictionary).duplicate(true)
		var layer_id := str(layer.get("id", "")).strip_edges()
		if layer_id.is_empty() or _historical_context_layers_by_id.has(layer_id):
			continue
		_historical_context_layers.append(layer)
		_historical_context_layers_by_id[layer_id] = layer
		_historical_context_layer_order.append(layer_id)
		_historical_context_visibility_by_id[layer_id] = bool(layer.get("default_visible", false))
		if layer_id == "context_184":
			_historical_context_layer = layer.duplicate(true)
	_historical_context_visible = bool(_historical_context_visibility_by_id.get("context_184", false))
	_rebuild_historical_context_menu()
	_sync_historical_context_canvas(true)


func set_scenario_context(value: Dictionary) -> bool:
	var next_year := int(value.get("year", 0))
	var next_label := str(value.get("label", "")).strip_edges()
	if next_label.is_empty():
		next_label = "%d年背景" % next_year if next_year > 0 else "本局背景"
	var next_signature := "%d|%s" % [next_year, next_label]
	if next_signature == _scenario_context_signature:
		return false
	_scenario_context_signature = next_signature
	_scenario_context_year = next_year
	_scenario_context_label = next_label
	for layer_id in _historical_context_layer_order:
		var layer: Dictionary = _historical_context_layers_by_id.get(layer_id, {})
		_historical_context_visibility_by_id[layer_id] = next_year > 0 and int(layer.get("year", 0)) == next_year
	_historical_context_visible = bool(_historical_context_visibility_by_id.get("context_184", false))
	_rebuild_historical_context_menu()
	_sync_historical_context_canvas(true)
	return true


func get_scenario_context_contract() -> Dictionary:
	return {
		"year": _scenario_context_year,
		"label": _scenario_context_label,
		"signature": _scenario_context_signature,
		"matched_layer_id": "context_%d" % _scenario_context_year
		if _historical_context_layers_by_id.has("context_%d" % _scenario_context_year)
		else ""
	}


func _rebuild_historical_context_menu() -> void:
	if _historical_context_menu == null:
		return
	_historical_context_menu.text = _scenario_context_label
	_historical_context_menu.tooltip_text = "%s\n只读背景；不参与人物吸附、路线、事件或存档" % _scenario_context_label
	var popup := _historical_context_menu.get_popup()
	popup.clear()
	for index in range(_historical_context_layer_order.size()):
		var layer_id := _historical_context_layer_order[index]
		var layer: Dictionary = _historical_context_layers_by_id.get(layer_id, {})
		popup.add_check_item(str(layer.get("name", layer_id)), index)
		popup.set_item_checked(index, bool(_historical_context_visibility_by_id.get(layer_id, false)))
	var has_layers := not _historical_context_layer_order.is_empty()
	_historical_context_menu.visible = has_layers and _map_tools_visible
	_historical_context_menu.disabled = not has_layers


func _on_historical_context_menu_id_pressed(item_id: int) -> void:
	if item_id < 0 or item_id >= _historical_context_layer_order.size():
		return
	var layer_id := _historical_context_layer_order[item_id]
	set_historical_context_layer_visible(layer_id, not bool(_historical_context_visibility_by_id.get(layer_id, false)))


func _sync_historical_context_canvas(_rebuild_cache: bool) -> void:
	if _canvas == null and _semantic_canvas == null:
		return
	var flattened_records: Array[Dictionary] = []
	for layer_id in _historical_context_layer_order:
		var layer: Dictionary = _historical_context_layers_by_id.get(layer_id, {})
		var layer_year := int(layer.get("year", 0))
		for record_value in layer.get("records", []):
			if not (record_value is Dictionary):
				continue
			var record: Dictionary = (record_value as Dictionary).duplicate(true)
			record["_runtime_layer_id"] = layer_id
			record["_runtime_layer_year"] = layer_year
			flattened_records.append(record)
	if _canvas != null:
		_canvas.set_historical_context_layer({"records": flattened_records})
		_canvas.set_historical_context_visibility_by_layer(_historical_context_visibility_by_id)
	if _semantic_canvas != null:
		_semantic_canvas.set_historical_context_layer({"records": flattened_records})
		_semantic_canvas.set_historical_context_visibility_by_layer(_historical_context_visibility_by_id)


func set_historical_context_layer_visible(layer_id: String, value: bool) -> void:
	if not _historical_context_layers_by_id.has(layer_id):
		return
	var layer: Dictionary = _historical_context_layers_by_id[layer_id]
	var next_value := value and not (layer.get("records", []) as Array).is_empty()
	if bool(_historical_context_visibility_by_id.get(layer_id, false)) == next_value:
		_rebuild_historical_context_menu()
		return
	_historical_context_visibility_by_id[layer_id] = next_value
	_historical_context_visible = bool(_historical_context_visibility_by_id.get("context_184", false))
	_rebuild_historical_context_menu()
	if _canvas != null:
		_canvas.set_historical_context_visibility_by_layer(_historical_context_visibility_by_id)
	if _semantic_canvas != null:
		_semantic_canvas.set_historical_context_visibility_by_layer(_historical_context_visibility_by_id)
	historical_context_layer_visibility_changed.emit(layer_id, next_value)
	historical_context_visibility_changed.emit(_has_visible_historical_context_layer())


func _has_visible_historical_context_layer() -> bool:
	for layer_id in _historical_context_layer_order:
		if bool(_historical_context_visibility_by_id.get(layer_id, false)):
			return true
	return false


func set_historical_context_visible(value: bool) -> void:
	set_historical_context_layer_visible("context_184", value)


func is_historical_context_visible() -> bool:
	return is_historical_context_layer_visible("context_184")


func is_historical_context_layer_visible(layer_id: String) -> bool:
	return bool(_historical_context_visibility_by_id.get(layer_id, false))


func get_historical_context_visibility() -> Dictionary:
	return _historical_context_visibility_by_id.duplicate(true)


func set_placements(value: Dictionary) -> void:
	_placements = value
	_refresh_placed_cards()
	_refresh_faction_inspection_highlight()


func set_annotations(value: Dictionary) -> void:
	_annotations = value
	_refresh_annotations()


func set_player_strokes(value: Array) -> void:
	if _player_stroke_point_edit_active:
		_end_player_stroke_point_edit(false)
	_player_strokes.clear()
	for stroke_value in value:
		if stroke_value is Dictionary:
			_player_strokes.append((stroke_value as Dictionary).duplicate(true))
	if not _selected_player_stroke_id.is_empty() and _find_player_stroke(_selected_player_stroke_id).is_empty():
		_clear_player_stroke_selection()
	if _player_stroke_layer != null:
		_player_stroke_layer.set_strokes(_player_strokes)
	_rebuild_player_stroke_manager_menu()
	_refresh_player_stroke_action_panel()
	_layout_player_stroke_action_panel()


func get_player_strokes() -> Array[Dictionary]:
	return _player_strokes.duplicate(true)


func set_player_stroke_tool_active(value: bool, stroke_type := "advance") -> void:
	if value:
		if _player_stroke_point_edit_active:
			_end_player_stroke_point_edit(false)
		if not PlayerStrokeLayerScript.STROKE_TYPES.has(stroke_type):
			stroke_type = "advance"
		if _annotation_tool_active:
			set_annotation_tool_active(false)
		_player_stroke_type = stroke_type
		_clear_player_stroke_selection()
		_clear_map_selection()
		_clear_annotation_selection()
	var changed := _player_stroke_tool_active != value
	_player_stroke_tool_active = value
	if not value:
		_player_stroke_draft_points.clear()
	mouse_default_cursor_shape = Control.CURSOR_CROSS if value else Control.CURSOR_ARROW
	_update_player_stroke_draft(Vector2(-1.0, -1.0))
	_refresh_player_stroke_interaction_ui()
	_hide_place_hover()
	_clear_snap_candidate()
	if changed:
		player_stroke_tool_changed.emit(value)


func is_player_stroke_tool_active() -> bool:
	return _player_stroke_tool_active


func finish_player_stroke_draft() -> void:
	if not _player_stroke_tool_active or _player_stroke_draft_points.size() < 2:
		_refresh_player_stroke_guide()
		return
	var completed_points: Array = _player_stroke_draft_points.duplicate()
	set_player_stroke_tool_active(false)
	player_stroke_draft_completed.emit(completed_points)


func finish_player_stroke_interaction() -> void:
	if _player_stroke_point_edit_active:
		finish_player_stroke_point_edit()
	else:
		finish_player_stroke_draft()


func undo_player_stroke_draft_point() -> void:
	if not _player_stroke_tool_active or _player_stroke_draft_points.is_empty():
		return
	_player_stroke_draft_points.pop_back()
	_update_player_stroke_draft(Vector2(-1.0, -1.0))
	_refresh_player_stroke_guide()


func cancel_player_stroke_draft() -> void:
	set_player_stroke_tool_active(false)


func cancel_player_stroke_interaction() -> void:
	if _player_stroke_point_edit_active:
		cancel_player_stroke_point_edit()
	else:
		cancel_player_stroke_draft()


func get_player_stroke_draft_points() -> Array[Vector2]:
	return _player_stroke_draft_points.duplicate()


func begin_player_stroke_point_edit(stroke_id: String) -> bool:
	var stroke := _find_player_stroke(stroke_id)
	if stroke.is_empty() or not _player_strokes_visible:
		return false
	if _annotation_tool_active:
		set_annotation_tool_active(false)
	if _player_stroke_tool_active:
		set_player_stroke_tool_active(false)
	var points := _player_stroke_points_as_vectors(stroke)
	if points.size() < 2:
		return false
	_clear_map_selection()
	_clear_annotation_selection()
	_selected_player_stroke_id = stroke_id
	_player_stroke_point_edit_active = true
	_player_stroke_point_edit_id = stroke_id
	_player_stroke_point_original_points = points.duplicate()
	_player_stroke_point_preview_points = points.duplicate()
	_player_stroke_point_active_index = -1
	_player_stroke_point_dragging = false
	_panning = false
	if _player_stroke_layer != null:
		_player_stroke_layer.z_index = PLAYER_STROKE_EDIT_LAYER_Z
		_player_stroke_layer.set_selected_stroke(stroke_id)
		_player_stroke_layer.set_point_edit_preview(stroke_id, _player_stroke_point_preview_points)
	if _stroke_action_panel != null:
		_stroke_action_panel.visible = false
	_refresh_player_stroke_interaction_ui()
	_hide_place_hover()
	_clear_snap_candidate()
	player_stroke_tool_changed.emit(true)
	return true


func finish_player_stroke_point_edit() -> void:
	if not _player_stroke_point_edit_active:
		return
	_cancel_active_player_stroke_point_drag()
	var stroke_id := _player_stroke_point_edit_id
	var completed_points: Array = _player_stroke_point_preview_points.duplicate()
	var changed := not _player_stroke_vector_points_match(_player_stroke_point_original_points, _player_stroke_point_preview_points)
	_end_player_stroke_point_edit(true)
	if changed:
		player_stroke_geometry_edit_completed.emit(stroke_id, completed_points)


func cancel_player_stroke_point_edit() -> void:
	if not _player_stroke_point_edit_active:
		return
	_end_player_stroke_point_edit(true)


func is_player_stroke_point_edit_active() -> bool:
	return _player_stroke_point_edit_active


func is_pointer_interaction_active() -> bool:
	return (
		not _active_drag_id.is_empty()
		or not _active_annotation_drag_id.is_empty()
		or _panning
		or _player_stroke_point_dragging
	)


func get_player_stroke_point_edit_state() -> Dictionary:
	return {
		"active": _player_stroke_point_edit_active,
		"stroke_id": _player_stroke_point_edit_id,
		"original_points": _player_stroke_point_original_points.duplicate(),
		"preview_points": _player_stroke_point_preview_points.duplicate(),
		"active_point_index": _player_stroke_point_active_index,
		"dragging": _player_stroke_point_dragging,
		"changed": not _player_stroke_vector_points_match(_player_stroke_point_original_points, _player_stroke_point_preview_points),
		"handle_radius_screen": PlayerStrokeLayerScript.HANDLE_RADIUS_SCREEN,
		"handle_hit_radius_screen": PlayerStrokeLayerScript.HANDLE_HIT_RADIUS_SCREEN,
		"overlay_visible": _stroke_input_overlay != null and _stroke_input_overlay.visible
	}


func get_player_stroke_handle_screen_positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for point in _player_stroke_point_preview_points:
		result.append(map_normalized_to_world(point) * zoom + pan)
	return result


func _end_player_stroke_point_edit(restore_action_panel: bool) -> void:
	var was_active := _player_stroke_point_edit_active
	_player_stroke_point_edit_active = false
	_player_stroke_point_edit_id = ""
	_player_stroke_point_original_points.clear()
	_player_stroke_point_preview_points.clear()
	_player_stroke_point_active_index = -1
	_player_stroke_point_dragging = false
	_panning = false
	if _player_stroke_layer != null:
		_player_stroke_layer.clear_point_edit_preview()
		_player_stroke_layer.z_index = PLAYER_STROKE_LAYER_Z
		_player_stroke_layer.set_selected_stroke(_selected_player_stroke_id)
	_refresh_player_stroke_interaction_ui()
	if restore_action_panel:
		_refresh_player_stroke_action_panel()
		_layout_player_stroke_action_panel()
	if was_active:
		player_stroke_tool_changed.emit(false)


func _player_stroke_points_as_vectors(stroke: Dictionary) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var values: Variant = stroke.get("points", [])
	if not (values is Array):
		return result
	for value in values:
		if not (value is Dictionary):
			return []
		var point: Dictionary = value
		result.append(Vector2(float(point.get("x", 0.5)), float(point.get("y", 0.5))))
	return result


func _player_stroke_vector_points_match(first: Array[Vector2], second: Array[Vector2]) -> bool:
	if first.size() != second.size():
		return false
	for index in range(first.size()):
		if not first[index].is_equal_approx(second[index]):
			return false
	return true


func set_player_strokes_visible(value: bool) -> void:
	if _player_strokes_visible == value:
		_rebuild_player_stroke_manager_menu()
		return
	_player_strokes_visible = value
	if not value and _player_stroke_point_edit_active:
		_end_player_stroke_point_edit(false)
	if _player_stroke_layer != null:
		_player_stroke_layer.set_strokes_visible(value)
	if not value:
		_clear_player_stroke_selection()
	_rebuild_player_stroke_manager_menu()
	player_stroke_visibility_changed.emit(value)


func are_player_strokes_visible() -> bool:
	return _player_strokes_visible


func get_selected_player_stroke_id() -> String:
	return _selected_player_stroke_id


func get_player_stroke_draw_state() -> Dictionary:
	return _player_stroke_layer.get_draw_state() if _player_stroke_layer != null else {}


func set_annotation_type_visible(marker_type: String, value: bool) -> void:
	if not ANNOTATION_TYPES.has(marker_type):
		return
	if bool(_annotation_visibility_by_type.get(marker_type, true)) == value:
		_rebuild_annotation_manager_menu()
		return
	_annotation_visibility_by_type[marker_type] = value
	_refresh_annotation_control_visibility()
	_rebuild_annotation_manager_menu()
	annotation_type_visibility_changed.emit(marker_type, value)


func is_annotation_type_visible(marker_type: String) -> bool:
	return bool(_annotation_visibility_by_type.get(marker_type, true))


func get_annotation_visibility() -> Dictionary:
	return _annotation_visibility_by_type.duplicate(true)


func show_all_annotation_types() -> void:
	var changed_types: Array[String] = []
	for marker_type in ANNOTATION_TYPES:
		if not bool(_annotation_visibility_by_type.get(marker_type, true)):
			_annotation_visibility_by_type[marker_type] = true
			changed_types.append(marker_type)
	_refresh_annotation_control_visibility()
	_rebuild_annotation_manager_menu()
	for marker_type in changed_types:
		annotation_type_visibility_changed.emit(marker_type, true)


func hide_all_annotation_types() -> void:
	var changed_types: Array[String] = []
	for marker_type in ANNOTATION_TYPES:
		if bool(_annotation_visibility_by_type.get(marker_type, true)):
			_annotation_visibility_by_type[marker_type] = false
			changed_types.append(marker_type)
	_refresh_annotation_control_visibility()
	_rebuild_annotation_manager_menu()
	for marker_type in changed_types:
		annotation_type_visibility_changed.emit(marker_type, false)


func focus_annotation(annotation_id: String) -> bool:
	if not _annotations.has(annotation_id) or not _annotation_by_id.has(annotation_id):
		return false
	var annotation: Dictionary = _annotations[annotation_id]
	var marker_type := str(annotation.get("marker_type", "note"))
	if not is_annotation_type_visible(marker_type):
		return false
	set_annotation_tool_active(false)
	_hide_place_hover()
	_clear_snap_candidate()
	var normalized := Vector2(float(annotation.get("x", 0.5)), float(annotation.get("y", 0.5)))
	var world_center := map_normalized_to_world(normalized)
	if not _focus_world_point(world_center):
		return false
	zoom_changed.emit(zoom)
	_on_annotation_marker_selected(annotation_id)
	return true


func focus_next_visible_annotation() -> String:
	var visible_ids: Array[String] = []
	for annotation_id_value in _annotations.keys():
		var annotation_id := str(annotation_id_value)
		var annotation: Dictionary = _annotations.get(annotation_id, {})
		if is_annotation_type_visible(str(annotation.get("marker_type", "note"))):
			visible_ids.append(annotation_id)
	visible_ids.sort_custom(_annotation_id_sort_less)
	if visible_ids.is_empty():
		annotation_focus_unavailable.emit()
		return ""
	var next_index := 0
	var selected_index := visible_ids.find(_selected_annotation_id)
	if selected_index >= 0:
		next_index = (selected_index + 1) % visible_ids.size()
	var annotation_id := visible_ids[next_index]
	if not focus_annotation(annotation_id):
		annotation_focus_unavailable.emit()
		return ""
	var annotation: Dictionary = _annotations.get(annotation_id, {})
	annotation_focused.emit(annotation_id, str(annotation.get("label", "")), next_index + 1, visible_ids.size())
	return annotation_id


func _annotation_id_sort_less(first_id: String, second_id: String) -> bool:
	var first_suffix := first_id.trim_prefix("marker_") if first_id.begins_with("marker_") else ""
	var second_suffix := second_id.trim_prefix("marker_") if second_id.begins_with("marker_") else ""
	if first_suffix.is_valid_int() and second_suffix.is_valid_int():
		return first_suffix.to_int() < second_suffix.to_int()
	return first_id < second_id


func show_annotation_manager_menu() -> void:
	if _annotation_manager_menu != null:
		_annotation_manager_menu.show_popup()


func _annotation_type_for_menu_id(item_id: int) -> String:
	match item_id:
		ANNOTATION_MENU_NOTE_ID:
			return "note"
		ANNOTATION_MENU_PLACE_ID:
			return "player_place"
		ANNOTATION_MENU_EVENT_ID:
			return "player_event"
	return ""


func _annotation_type_menu_label(marker_type: String) -> String:
	var type_name := "便签"
	match marker_type:
		"player_place":
			type_name = "玩家地点"
		"player_event":
			type_name = "玩家事件"
	var count := 0
	for annotation_value in _annotations.values():
		if annotation_value is Dictionary and str(annotation_value.get("marker_type", "note")) == marker_type:
			count += 1
	return "%s · %d" % [type_name, count]


func _rebuild_annotation_manager_menu() -> void:
	if _annotation_manager_menu == null:
		return
	_annotation_manager_menu.text = "我的标记 %d" % _annotations.size()
	var popup := _annotation_manager_menu.get_popup()
	popup.clear()
	var menu_ids := [ANNOTATION_MENU_NOTE_ID, ANNOTATION_MENU_PLACE_ID, ANNOTATION_MENU_EVENT_ID]
	for index in range(ANNOTATION_TYPES.size()):
		var marker_type := str(ANNOTATION_TYPES[index])
		var item_id := int(menu_ids[index])
		popup.add_check_item(_annotation_type_menu_label(marker_type), item_id)
		popup.set_item_checked(popup.get_item_index(item_id), is_annotation_type_visible(marker_type))
	popup.add_separator()
	popup.add_item("定位下一个可见标记", ANNOTATION_MENU_FOCUS_NEXT_ID)
	popup.set_item_disabled(popup.get_item_index(ANNOTATION_MENU_FOCUS_NEXT_ID), _visible_annotation_count() == 0)
	popup.add_item("全部显示", ANNOTATION_MENU_SHOW_ALL_ID)
	var all_visible := true
	var any_visible := _visible_annotation_count() > 0
	for marker_type in ANNOTATION_TYPES:
		all_visible = all_visible and is_annotation_type_visible(str(marker_type))
	popup.set_item_disabled(popup.get_item_index(ANNOTATION_MENU_SHOW_ALL_ID), all_visible)
	popup.add_item("全部隐藏", ANNOTATION_MENU_HIDE_ALL_ID)
	popup.set_item_disabled(popup.get_item_index(ANNOTATION_MENU_HIDE_ALL_ID), not any_visible)


func _on_annotation_manager_menu_id_pressed(item_id: int) -> void:
	var marker_type := _annotation_type_for_menu_id(item_id)
	if not marker_type.is_empty():
		set_annotation_type_visible(marker_type, not is_annotation_type_visible(marker_type))
		return
	match item_id:
		ANNOTATION_MENU_FOCUS_NEXT_ID:
			focus_next_visible_annotation()
		ANNOTATION_MENU_SHOW_ALL_ID:
			show_all_annotation_types()
		ANNOTATION_MENU_HIDE_ALL_ID:
			hide_all_annotation_types()


func _rebuild_player_stroke_manager_menu() -> void:
	if _stroke_manager_menu == null:
		return
	_stroke_manager_menu.text = "我的推演线 %d" % _player_strokes.size()
	var popup := _stroke_manager_menu.get_popup()
	popup.clear()
	popup.add_check_item("显示推演线", STROKE_MENU_VISIBLE_ID)
	popup.set_item_checked(popup.get_item_index(STROKE_MENU_VISIBLE_ID), _player_strokes_visible)
	popup.add_separator()
	popup.add_item("定位下一条", STROKE_MENU_FOCUS_NEXT_ID)
	popup.set_item_disabled(popup.get_item_index(STROKE_MENU_FOCUS_NEXT_ID), _player_strokes.is_empty() or not _player_strokes_visible)


func _on_player_stroke_manager_id_pressed(item_id: int) -> void:
	match item_id:
		STROKE_MENU_VISIBLE_ID:
			set_player_strokes_visible(not _player_strokes_visible)
		STROKE_MENU_FOCUS_NEXT_ID:
			focus_next_player_stroke()


func focus_next_player_stroke() -> void:
	if _player_strokes.is_empty() or not _player_strokes_visible:
		player_stroke_focus_unavailable.emit()
		return
	var current_index := -1
	for index in range(_player_strokes.size()):
		if str(_player_strokes[index].get("id", "")) == _selected_player_stroke_id:
			current_index = index
			break
	var next_index := (current_index + 1) % _player_strokes.size()
	var stroke: Dictionary = _player_strokes[next_index]
	var stroke_id := str(stroke.get("id", ""))
	_select_player_stroke(stroke_id)
	if _player_stroke_layer != null:
		var center_world := _player_stroke_layer.stroke_world_center(stroke_id)
		_focus_world_point(center_world)
	var label := str(stroke.get("label", "")).strip_edges()
	if label.is_empty():
		label = _player_stroke_type_label(str(stroke.get("stroke_type", "advance")))
	player_stroke_focused.emit(stroke_id, label, next_index + 1, _player_strokes.size())


func _select_player_stroke(stroke_id: String) -> void:
	if _player_stroke_point_edit_active and stroke_id != _player_stroke_point_edit_id:
		_end_player_stroke_point_edit(false)
	if _find_player_stroke(stroke_id).is_empty():
		_clear_player_stroke_selection()
		return
	_clear_map_selection()
	_clear_annotation_selection()
	_selected_player_stroke_id = stroke_id
	if _player_stroke_layer != null:
		_player_stroke_layer.set_selected_stroke(stroke_id)
	_refresh_player_stroke_action_panel()
	_layout_player_stroke_action_panel()


func _clear_player_stroke_selection() -> void:
	if _player_stroke_point_edit_active:
		_end_player_stroke_point_edit(false)
	if _selected_player_stroke_id.is_empty():
		if _stroke_action_panel != null:
			_stroke_action_panel.visible = false
		return
	_selected_player_stroke_id = ""
	if _player_stroke_layer != null:
		_player_stroke_layer.set_selected_stroke("")
	if _stroke_action_panel != null:
		_stroke_action_panel.visible = false


func _refresh_player_stroke_action_panel() -> void:
	if _stroke_action_panel == null:
		return
	var stroke := _find_player_stroke(_selected_player_stroke_id)
	_stroke_action_panel.visible = not stroke.is_empty() and _player_strokes_visible and not _player_stroke_tool_active and not _player_stroke_point_edit_active
	if stroke.is_empty():
		return
	var label := str(stroke.get("label", "")).strip_edges()
	var type_label := _player_stroke_type_label(str(stroke.get("stroke_type", "advance")))
	_stroke_action_label.text = type_label if label.is_empty() else "%s · %s" % [type_label, label]


func _layout_player_stroke_action_panel() -> void:
	if _stroke_action_panel == null or not _stroke_action_panel.visible or _player_stroke_layer == null:
		return
	var center_world := _player_stroke_layer.stroke_world_center(_selected_player_stroke_id)
	var center_screen := center_world * zoom + pan
	var candidates := [
		center_screen + Vector2(12.0, -58.0),
		center_screen + Vector2(-_stroke_action_panel.size.x - 12.0, -58.0),
		center_screen + Vector2(12.0, 16.0),
		center_screen + Vector2(-_stroke_action_panel.size.x - 12.0, 16.0)
	]
	var blockers: Array[Rect2] = []
	for control_value in [find_child("MapBadge", true, false), _strategic_corridor_button, _historical_context_menu, _annotation_manager_menu, _stroke_manager_menu]:
		if control_value is Control and (control_value as Control).visible:
			var control := control_value as Control
			blockers.append(Rect2(control.position, control.size).grow(6.0))
	var fallback := _clamp_player_stroke_action_target(candidates[0])
	for candidate_value in candidates:
		var candidate := _clamp_player_stroke_action_target(candidate_value)
		var candidate_rect := Rect2(candidate, _stroke_action_panel.size)
		var blocked := false
		for blocker in blockers:
			if candidate_rect.intersects(blocker):
				blocked = true
				break
		if not blocked:
			_stroke_action_panel.position = candidate
			return
	_stroke_action_panel.position = fallback


func _clamp_player_stroke_action_target(target: Vector2) -> Vector2:
	return Vector2(
		clampf(target.x, 10.0, maxf(10.0, size.x - _stroke_action_panel.size.x - 10.0)),
		clampf(target.y, 10.0, maxf(10.0, size.y - _stroke_action_panel.size.y - 10.0))
	)


func _request_selected_player_stroke_edit() -> void:
	if not _selected_player_stroke_id.is_empty():
		player_stroke_edit_requested.emit(_selected_player_stroke_id)


func _request_selected_player_stroke_geometry_edit() -> void:
	if not _selected_player_stroke_id.is_empty():
		begin_player_stroke_point_edit(_selected_player_stroke_id)


func _request_selected_player_stroke_delete() -> void:
	if not _selected_player_stroke_id.is_empty():
		player_stroke_delete_requested.emit(_selected_player_stroke_id)


func _find_player_stroke(stroke_id: String) -> Dictionary:
	for stroke in _player_strokes:
		if str(stroke.get("id", "")) == stroke_id:
			return stroke
	return {}


func _player_stroke_type_label(stroke_type: String) -> String:
	match stroke_type:
		"reinforcement":
			return "援军"
		"retreat":
			return "撤退"
		"plan":
			return "计划"
		_:
			return "进军"


func _visible_annotation_count() -> int:
	var count := 0
	for annotation_value in _annotations.values():
		if annotation_value is Dictionary and is_annotation_type_visible(str(annotation_value.get("marker_type", "note"))):
			count += 1
	return count


func _refresh_annotation_control_visibility() -> void:
	var selected_hidden := false
	for annotation_id_value in _annotation_by_id.keys():
		var annotation_id := str(annotation_id_value)
		var marker = _annotation_by_id[annotation_id]
		var annotation: Dictionary = _annotations.get(annotation_id, {})
		var type_visible := is_annotation_type_visible(str(annotation.get("marker_type", "note")))
		marker.visible = type_visible
		if annotation_id == _selected_annotation_id and not type_visible:
			selected_hidden = true
	if selected_hidden:
		_clear_annotation_selection()


func set_annotation_tool_active(value: bool) -> void:
	if value and _player_stroke_point_edit_active:
		_end_player_stroke_point_edit(false)
	if value and _player_stroke_tool_active:
		set_player_stroke_tool_active(false)
	if _annotation_tool_active == value:
		return
	_annotation_tool_active = value
	if value:
		_clear_annotation_selection()
		_clear_player_stroke_selection()
	mouse_default_cursor_shape = Control.CURSOR_CROSS if value else Control.CURSOR_ARROW
	_hide_place_hover()
	_clear_snap_candidate()
	annotation_tool_changed.emit(value)


func is_annotation_tool_active() -> bool:
	return _annotation_tool_active


func set_city_ownership_tool_active(value: bool) -> void:
	if _city_ownership_tool_active == value:
		return
	if value:
		if _player_stroke_point_edit_active:
			_end_player_stroke_point_edit(false)
		if _player_stroke_tool_active:
			set_player_stroke_tool_active(false)
		if _annotation_tool_active:
			set_annotation_tool_active(false)
		_clear_map_selection()
		_clear_annotation_selection()
		_clear_player_stroke_selection()
	_city_ownership_tool_active = value
	_panning = false
	if not value:
		_set_city_ownership_hover_place("")
	_hide_place_hover()
	_clear_snap_candidate()
	_refresh_player_stroke_interaction_ui()


func is_city_ownership_tool_active() -> bool:
	return _city_ownership_tool_active


func get_city_ownership_tool_state() -> Dictionary:
	return {
		"active": _city_ownership_tool_active,
		"hover_place_id": _city_ownership_hover_place_id,
		"overlay_visible": _stroke_input_overlay != null and _stroke_input_overlay.visible
	}


func _refresh_annotations() -> void:
	if _user_annotation_layer == null:
		return
	for existing_id in _annotation_by_id.keys():
		if not _annotations.has(existing_id):
			var removed_marker = _annotation_by_id[existing_id]
			removed_marker.queue_free()
			_annotation_by_id.erase(existing_id)
			if str(existing_id) == _selected_annotation_id:
				_selected_annotation_id = ""
	for annotation_id in _annotations:
		var annotation: Dictionary = _annotations[annotation_id]
		var marker
		if _annotation_by_id.has(annotation_id):
			marker = _annotation_by_id[annotation_id]
			marker.set_label_text(str(annotation.get("label", "")))
			marker.set_marker_type(str(annotation.get("marker_type", "note")))
		else:
			marker = TacticalMarkerScript.new()
			marker.setup(str(annotation_id), str(annotation.get("label", "")), str(annotation.get("marker_type", "note")))
			marker.marker_drag_started.connect(_on_annotation_drag_started)
			marker.marker_drag_ended.connect(_on_annotation_drag_ended)
			marker.marker_selected.connect(_on_annotation_marker_selected)
			marker.edit_requested.connect(_on_annotation_edit_button)
			marker.delete_requested.connect(_on_annotation_delete_button)
			_user_annotation_layer.add_child(marker)
			_annotation_by_id[annotation_id] = marker
		var faction_id := str(annotation.get("faction_id", "")).strip_edges()
		if _faction_name_by_id.has(faction_id):
			marker.set_faction_affiliation(
				faction_id,
				str(_faction_name_by_id.get(faction_id, "未命名势力")),
				FactionPaletteScript.render_on_dark(
					_faction_color_by_id.get(faction_id, FactionPaletteScript.UNASSIGNED_HEX)
				)
			)
		else:
			marker.set_faction_affiliation("", "", Color.TRANSPARENT)
		marker.set_selected(str(annotation_id) == _selected_annotation_id)
	_refresh_annotation_control_visibility()
	_rebuild_annotation_manager_menu()
	_layout_all_annotations()


func _on_annotation_marker_selected(annotation_id: String) -> void:
	if not _annotation_by_id.has(annotation_id):
		return
	_clear_map_selection()
	_clear_player_stroke_selection()
	if not _selected_annotation_id.is_empty() and _annotation_by_id.has(_selected_annotation_id):
		_annotation_by_id[_selected_annotation_id].set_selected(false)
	_selected_annotation_id = annotation_id
	_annotation_by_id[annotation_id].set_selected(true)


func _clear_annotation_selection() -> void:
	if _selected_annotation_id.is_empty():
		return
	if _annotation_by_id.has(_selected_annotation_id):
		_annotation_by_id[_selected_annotation_id].set_selected(false)
	_selected_annotation_id = ""


func get_selected_annotation_id() -> String:
	return _selected_annotation_id


func _on_annotation_edit_button(annotation_id: String) -> void:
	set_annotation_tool_active(false)
	_on_annotation_marker_selected(annotation_id)
	annotation_edit_requested.emit(annotation_id)


func _on_annotation_delete_button(annotation_id: String) -> void:
	set_annotation_tool_active(false)
	_on_annotation_marker_selected(annotation_id)
	annotation_delete_requested.emit(annotation_id)


func _layout_annotation(annotation_id: String) -> void:
	if annotation_id == _active_annotation_drag_id or not _annotation_by_id.has(annotation_id) or not _annotations.has(annotation_id):
		return
	var marker = _annotation_by_id[annotation_id]
	var annotation: Dictionary = _annotations[annotation_id]
	var world_center := map_normalized_to_world(Vector2(float(annotation.get("x", 0.5)), float(annotation.get("y", 0.5))))
	var screen_scale := _annotation_screen_scale()
	marker.scale = Vector2.ONE * (screen_scale / zoom)
	marker.position = world_center - marker.size * marker.scale * 0.5


func _layout_all_annotations() -> void:
	for annotation_id in _annotation_by_id:
		_layout_annotation(str(annotation_id))
	_refresh_character_attention_presentation()


func get_annotation_control(annotation_id: String) -> Control:
	return _annotation_by_id.get(annotation_id) as Control


func _on_annotation_drag_started(annotation_id: String, grab_local: Vector2) -> void:
	if not _annotation_by_id.has(annotation_id) or not _active_drag_id.is_empty() or _panning:
		return
	set_annotation_tool_active(false)
	_on_annotation_marker_selected(annotation_id)
	_hide_place_hover()
	_clear_snap_candidate()
	_active_annotation_drag_id = annotation_id
	var marker = _annotation_by_id[annotation_id]
	var screen_scale := _annotation_screen_scale()
	_annotation_drag_grab_offset_screen = grab_local * screen_scale
	marker.reparent(_drag_layer)
	marker.scale = Vector2.ONE * screen_scale
	marker.position = get_local_mouse_position() - _annotation_drag_grab_offset_screen
	marker.z_index = 4094
	set_process(true)


func _update_active_annotation_drag_position() -> void:
	if _active_annotation_drag_id.is_empty() or not _annotation_by_id.has(_active_annotation_drag_id):
		return
	var marker = _annotation_by_id[_active_annotation_drag_id]
	marker.position = get_local_mouse_position() - _annotation_drag_grab_offset_screen


func _on_annotation_drag_ended(annotation_id: String, _global_position: Vector2) -> void:
	if annotation_id != _active_annotation_drag_id or not _annotation_by_id.has(annotation_id):
		return
	_update_active_annotation_drag_position()
	var marker = _annotation_by_id[annotation_id]
	var screen_center: Vector2 = marker.position + marker.size * marker.scale * 0.5
	var world_center := screen_to_world(screen_center)
	var valid := Rect2(Vector2.ZERO, size).has_point(screen_center) and MAP_CONTENT_RECT.has_point(world_center)
	var normalized := world_to_map_normalized(world_center)
	normalized.x = clampf(normalized.x, 0.0, 1.0)
	normalized.y = clampf(normalized.y, 0.0, 1.0)
	marker.reparent(_user_annotation_layer)
	marker.z_index = 0
	_active_annotation_drag_id = ""
	if _active_drag_id.is_empty() and not _panning and not _camera_pan_dirty:
		set_process(false)
	annotation_drag_released.emit(annotation_id, normalized, valid)
	_layout_annotation(annotation_id)


func _refresh_placed_cards() -> void:
	if _world_layer == null:
		return
	for existing_id in _card_by_id.keys():
		if not _placements.has(existing_id):
			var removed_card: CharacterCard = _card_by_id[existing_id]
			removed_card.queue_free()
			_card_by_id.erase(existing_id)
			_card_base_z_by_id.erase(existing_id)
			if existing_id == _hovered_character_id:
				_hovered_character_id = ""
			if _selected_character_ids.has(existing_id):
				_selected_character_ids.erase(existing_id)
				if existing_id == _selected_character_id:
					_selected_character_id = _selected_character_ids.back() if not _selected_character_ids.is_empty() else ""
			if existing_id == _character_context_id:
				_character_context_id = ""
				if _character_context_menu != null:
					_character_context_menu.hide()

	for character_id in _placements:
		if not _character_by_id.has(character_id):
			continue
		var card: CharacterCard
		if _card_by_id.has(character_id):
			card = _card_by_id[character_id]
		else:
			var character: Dictionary = _character_by_id[character_id]
			card = CharacterCardScript.new()
			card.setup(
				character_id,
				str(character.get("name", character_id)),
				"map",
				_accent_for_character(str(character_id)),
				_character_portraits.get(character_id) as Texture2D
			)
			card.set_runtime_attributes(_character_states.get(character_id, {}))
			card.set_action_state(str(_character_actions.get(character_id, "standby")))
			card.set_troop_count(int(_character_troops.get(character_id, CharacterCardScript.DEFAULT_TROOP_COUNT)))
			card.map_selected.connect(_on_map_card_selected)
			card.map_hover_changed.connect(_on_map_card_hover_changed)
			card.map_context_requested.connect(_on_map_card_context_requested)
			card.map_drag_started.connect(_on_map_card_drag_started)
			card.map_drag_ended.connect(_on_map_card_drag_ended)
			_world_layer.add_child(card)
			# 先进入场景树再切换远景布局，确保容器最小尺寸按当前可见行重新计算，
			# 避免首次在 52% 启动时仍保留 136×46 的近景占位。
			card.set_map_compact_detail(_city_detail_compact)
			_card_by_id[character_id] = card
			_next_card_z += 1
			_card_base_z_by_id[character_id] = _next_card_z
			card.z_index = _next_card_z
		if not _card_base_z_by_id.has(character_id):
			_card_base_z_by_id[character_id] = card.z_index
		card.set_selected(_selected_character_ids.has(character_id))
		card.set_selection_context(_selected_character_ids.size() if _selected_character_ids.has(character_id) else 0)
	_rebuild_stack_layout()
	_layout_all_cards()


func _on_map_card_selected(character_id: String, additive := false) -> void:
	if _annotation_tool_active or _player_stroke_tool_active:
		return
	if not _card_by_id.has(character_id):
		return
	_clear_annotation_selection()
	_clear_player_stroke_selection()
	if additive:
		if _selected_character_ids.has(character_id):
			_selected_character_ids.erase(character_id)
			if _selected_character_id == character_id:
				_selected_character_id = _selected_character_ids.back() if not _selected_character_ids.is_empty() else ""
		else:
			_selected_character_ids.append(character_id)
			_selected_character_id = character_id
	elif _selected_character_ids.size() <= 1 or not _selected_character_ids.has(character_id):
		_selected_character_ids.clear()
		_selected_character_ids.append(character_id)
		_selected_character_id = character_id
	else:
		# 普通按下已在多选中的人物时保留整组，随后拖动即可“一把拿起”。
		_selected_character_id = character_id
	_refresh_character_selection_presentation()
	if _selected_character_id.is_empty():
		character_selected.emit("")
		character_selection_changed.emit(get_selected_character_ids())
		return
	_raise_card_base_order(_selected_character_id)
	character_selected.emit(_selected_character_id)
	character_selection_changed.emit(get_selected_character_ids())


func get_selected_character_id() -> String:
	return _selected_character_id


func get_selected_character_ids() -> Array[String]:
	return _selected_character_ids.duplicate()


func get_character_selection_state() -> Dictionary:
	var faction_ids: Dictionary = {}
	for character_id in _selected_character_ids:
		faction_ids[str(_faction_by_character.get(character_id, CITY_FACTION_UNASSIGNED_ID))] = true
	return {
		"character_ids": get_selected_character_ids(),
		"count": _selected_character_ids.size(),
		"faction_count": faction_ids.size(),
		"active_character_id": _selected_character_id
	}


func focus_character(character_id: String) -> bool:
	if _player_stroke_point_edit_active or not _placements.has(character_id) or not _card_by_id.has(character_id):
		return false
	set_annotation_tool_active(false)
	set_player_stroke_tool_active(false)
	_hide_place_hover()
	_clear_snap_candidate()
	var placement: Dictionary = _placements.get(character_id, {})
	var x_value: Variant = placement.get("x", null)
	var y_value: Variant = placement.get("y", null)
	if (
		not (typeof(x_value) in [TYPE_INT, TYPE_FLOAT])
		or not (typeof(y_value) in [TYPE_INT, TYPE_FLOAT])
		or not is_finite(float(x_value))
		or not is_finite(float(y_value))
	):
		return false
	var normalized := Vector2(clampf(float(x_value), 0.0, 1.0), clampf(float(y_value), 0.0, 1.0))
	var city_group_key := str(_city_group_by_character.get(character_id, ""))
	if not city_group_key.is_empty() and _collapsed_city_group_keys.has(city_group_key):
		set_city_faction_group_collapsed(city_group_key, false)
	var world_center := map_normalized_to_world(normalized)
	if not _focus_world_point(world_center):
		return false
	_select_only_character(character_id)
	return _selected_character_id == character_id


func _clear_map_selection() -> void:
	if _selected_character_ids.is_empty():
		return
	_selected_character_ids.clear()
	_selected_character_id = ""
	_refresh_character_selection_presentation()
	character_selected.emit("")
	character_selection_changed.emit(get_selected_character_ids())


func cancel_character_multiselection() -> bool:
	if _selected_character_ids.size() <= 1:
		return false
	_clear_map_selection()
	return true


func _select_only_character(character_id: String) -> void:
	if not _card_by_id.has(character_id):
		return
	_selected_character_ids.clear()
	_selected_character_ids.append(character_id)
	_selected_character_id = character_id
	_refresh_character_selection_presentation()
	_raise_card_base_order(character_id)
	character_selected.emit(character_id)
	character_selection_changed.emit(get_selected_character_ids())


func _refresh_character_selection_presentation() -> void:
	var selection_size := _selected_character_ids.size()
	for character_id_value in _card_by_id:
		var character_id := str(character_id_value)
		var card: CharacterCard = _card_by_id[character_id]
		var is_selected := _selected_character_ids.has(character_id)
		card.set_selected(is_selected)
		card.set_selection_context(selection_size if is_selected else 0)
	_refresh_character_attention_presentation()


func _on_map_card_hover_changed(character_id: String, value: bool) -> void:
	if not _card_by_id.has(character_id):
		return
	if value:
		_hovered_character_id = character_id
	elif _hovered_character_id == character_id:
		_hovered_character_id = ""
	_refresh_character_attention_presentation()


func get_character_stack_state(character_id: String) -> Dictionary:
	var place_id := str(_character_stack_place.get(character_id, ""))
	var members: Array = _stack_members_by_place.get(place_id, [])
	var group_key := str(_city_group_by_character.get(character_id, ""))
	var group_members: Array = _city_group_members.get(group_key, [])
	var group_meta: Dictionary = _city_group_meta.get(group_key, {})
	var faction_id := str(group_meta.get("faction_id", ""))
	return {
		"place_id": place_id,
		"place_name": str(_place_name_by_id.get(place_id, "")),
		"count": members.size() if not place_id.is_empty() else 1,
		"group_key": group_key,
		"faction_id": faction_id,
		"faction_name": str(group_meta.get("faction_name", "")),
		"group_count": group_members.size() if not group_key.is_empty() else 1,
		"city_faction_count": (_city_group_keys_by_place.get(place_id, []) as Array).size() if not place_id.is_empty() else 0,
		"has_window": _city_faction_window_by_key.has(group_key),
		"collapsed": _collapsed_city_group_keys.has(group_key),
		"expanded": not group_key.is_empty() and not _collapsed_city_group_keys.has(group_key)
	}


func _rebuild_stack_layout() -> void:
	for window_value in _city_faction_window_by_key.values():
		var old_window: Control = window_value
		if old_window.get_parent() != null:
			old_window.get_parent().remove_child(old_window)
		old_window.queue_free()
	_city_faction_window_by_key.clear()
	_stack_members_by_place.clear()
	_character_stack_place.clear()
	_stack_offset_screen_by_id.clear()
	_city_group_members.clear()
	_city_group_meta.clear()
	_city_group_keys_by_place.clear()
	_city_group_by_character.clear()
	_city_group_rect_screen.clear()
	_overview_declutter_offset_screen_by_id.clear()
	for character_id in _card_by_id:
		var card: CharacterCard = _card_by_id[character_id]
		card.set_stack_state(1, false, false)
		card.set_city_faction_context("")
		if not _placements.has(character_id):
			continue
		var placement: Dictionary = _placements[character_id]
		var place_id := str(placement.get("place_id", ""))
		if place_id.is_empty() or not _place_name_by_id.has(place_id):
			continue
		_character_stack_place[character_id] = place_id
		if not _stack_members_by_place.has(place_id):
			_stack_members_by_place[place_id] = []
		var members: Array = _stack_members_by_place[place_id]
		members.append(character_id)
		_stack_members_by_place[place_id] = members
		var faction_id := str(_faction_by_character.get(character_id, CITY_FACTION_UNASSIGNED_ID))
		var faction_name := str(_faction_name_by_id.get(faction_id, CITY_FACTION_UNASSIGNED_NAME))
		var group_key := _city_group_key(place_id, faction_id)
		_city_group_by_character[character_id] = group_key
		if not _city_group_members.has(group_key):
			_city_group_members[group_key] = []
			_city_group_meta[group_key] = {
				"place_id": place_id,
				"place_name": str(_place_name_by_id.get(place_id, place_id)),
				"faction_id": faction_id,
				"faction_name": faction_name,
				"faction_color": FactionPaletteScript.UNASSIGNED_HEX if faction_id == CITY_FACTION_UNASSIGNED_ID else str(_faction_color_by_id.get(faction_id, FactionPaletteScript.UNASSIGNED_HEX)),
				"faction_marker": "" if faction_id == CITY_FACTION_UNASSIGNED_ID else str(int(_faction_order_by_id.get(faction_id, -1)) + 1)
			}
			if not _city_group_keys_by_place.has(place_id):
				_city_group_keys_by_place[place_id] = []
			var place_group_keys: Array = _city_group_keys_by_place[place_id]
			place_group_keys.append(group_key)
			_city_group_keys_by_place[place_id] = place_group_keys
		var group_members: Array = _city_group_members[group_key]
		group_members.append(character_id)
		_city_group_members[group_key] = group_members

	var active_group_keys: Dictionary = {}
	for place_id in _stack_members_by_place:
		var members: Array = _stack_members_by_place[place_id]
		members.sort_custom(_sort_character_ids_stable)
		_stack_members_by_place[place_id] = members
		var group_keys: Array = _city_group_keys_by_place.get(place_id, [])
		group_keys.sort_custom(_sort_city_group_keys)
		_city_group_keys_by_place[place_id] = group_keys
		for group_key_value in group_keys:
			var group_key := str(group_key_value)
			active_group_keys[group_key] = true
			var group_members: Array = _city_group_members.get(group_key, [])
			group_members.sort_custom(_sort_character_ids_stable)
			_city_group_members[group_key] = group_members
		if members.size() <= 1:
			var single_id := str(members[0]) if not members.is_empty() else ""
			if not single_id.is_empty():
				var single_group_key := str(_city_group_by_character.get(single_id, ""))
				var single_meta: Dictionary = _city_group_meta.get(single_group_key, {})
				(_card_by_id[single_id] as CharacterCard).set_city_faction_context(str(single_meta.get("faction_name", "")))
			continue
		_layout_city_faction_groups_for_place(str(place_id), group_keys)

	for collapsed_key in _collapsed_city_group_keys.keys():
		if not active_group_keys.has(collapsed_key):
			_collapsed_city_group_keys.erase(collapsed_key)
	_rebuild_place_dock_layout()


func _city_group_key(place_id: String, faction_id: String) -> String:
	return "%s::%s" % [place_id, faction_id]


func _sort_character_ids_stable(first_id: Variant, second_id: Variant) -> bool:
	var first_text := str(first_id)
	var second_text := str(second_id)
	var first_order := int(_character_order_by_id.get(first_text, 1000000))
	var second_order := int(_character_order_by_id.get(second_text, 1000000))
	return first_order < second_order if first_order != second_order else first_text.naturalnocasecmp_to(second_text) < 0


func _sort_city_group_keys(first_key_value: Variant, second_key_value: Variant) -> bool:
	var first_key := str(first_key_value)
	var second_key := str(second_key_value)
	var first_meta: Dictionary = _city_group_meta.get(first_key, {})
	var second_meta: Dictionary = _city_group_meta.get(second_key, {})
	var first_faction := str(first_meta.get("faction_id", CITY_FACTION_UNASSIGNED_ID))
	var second_faction := str(second_meta.get("faction_id", CITY_FACTION_UNASSIGNED_ID))
	var first_order := int(_faction_order_by_id.get(first_faction, 1000000))
	var second_order := int(_faction_order_by_id.get(second_faction, 1000000))
	return first_order < second_order if first_order != second_order else first_faction.naturalnocasecmp_to(second_faction) < 0


func _city_faction_window_accent(faction_id: String) -> Color:
	if faction_id == CITY_FACTION_UNASSIGNED_ID:
		return FactionPaletteScript.render_on_dark(FactionPaletteScript.UNASSIGNED_HEX)
	return FactionPaletteScript.render_on_dark(_faction_color_by_id.get(faction_id, FactionPaletteScript.UNASSIGNED_HEX))


func _city_group_natural_height(member_count: int, collapsed: bool) -> float:
	if collapsed:
		return CITY_FACTION_WINDOW_HEADER_HEIGHT + 4.0
	return CITY_FACTION_WINDOW_HEADER_HEIGHT \
		+ CITY_FACTION_WINDOW_CARD_TOP \
		+ float(maxi(1, member_count)) * CITY_FACTION_WINDOW_CARD_ROW \
		+ CITY_FACTION_WINDOW_BOTTOM


func _city_group_visually_collapsed(group_key: String) -> bool:
	return _city_detail_compact \
		or not _city_faction_details_visible \
		or _collapsed_city_group_keys.has(group_key)


func _city_faction_summary_grid_shape(group_keys: Array) -> Vector2i:
	var group_count := group_keys.size()
	if group_count <= 0:
		return Vector2i.ZERO
	for group_key_value in group_keys:
		if not _city_group_visually_collapsed(str(group_key_value)):
			return Vector2i(group_count, 1)
	var columns := ceili(float(group_count) / float(CITY_FACTION_SUMMARY_MAX_ROWS))
	var rows := ceili(float(group_count) / float(maxi(1, columns)))
	return Vector2i(maxi(1, columns), maxi(1, rows))


func _refresh_city_faction_screen_geometry() -> void:
	# 势力窗保持屏幕像素大小，缩放时其摘要网格／展开分栏、驻城避让和人物偏移也必须
	# 使用当前 marker scale 重新计算，不能沿用上一次重建窗口时的缓存。
	_city_group_rect_screen.clear()
	_stack_offset_screen_by_id.clear()
	for place_id_value in _stack_members_by_place:
		var place_id := str(place_id_value)
		var members: Array = _stack_members_by_place.get(place_id, [])
		if members.size() <= 1:
			continue
		_refresh_city_faction_screen_geometry_for_place(
			place_id,
			_city_group_keys_by_place.get(place_id, [])
		)


func _refresh_city_faction_screen_geometry_for_place(place_id: String, group_keys: Array) -> void:
	if group_keys.is_empty():
		return
	var marker_scale := _screen_marker_scale()
	var natural_heights: Dictionary = {}
	var max_height_screen := 0.0
	for group_key_value in group_keys:
		var group_key := str(group_key_value)
		var group_members: Array = _city_group_members.get(group_key, [])
		var natural_height := _city_group_natural_height(
			group_members.size(),
			_city_group_visually_collapsed(group_key)
		)
		natural_heights[group_key] = natural_height
		max_height_screen = maxf(max_height_screen, natural_height * marker_scale)
	var width_screen := CITY_FACTION_WINDOW_WIDTH * marker_scale
	var summary_shape := _city_faction_summary_grid_shape(group_keys)
	var summary_grid := summary_shape.y > 1
	var total_width_screen := float(summary_shape.x) * width_screen \
		+ float(maxi(0, summary_shape.x - 1)) * CITY_FACTION_WINDOW_GAP_SCREEN
	var x_origin_screen := -total_width_screen * 0.5
	var top_screen := -max_height_screen * 0.5
	for group_index in range(group_keys.size()):
		var group_key_value = group_keys[group_index]
		var group_key := str(group_key_value)
		var group_members: Array = _city_group_members.get(group_key, [])
		var collapsed := _city_group_visually_collapsed(group_key)
		var natural_height := float(natural_heights.get(group_key, CITY_FACTION_WINDOW_HEADER_HEIGHT))
		var x_screen := x_origin_screen + float(group_index) * (width_screen + CITY_FACTION_WINDOW_GAP_SCREEN)
		var y_screen := top_screen
		if summary_grid:
			var column_index := group_index / summary_shape.y
			var row_index := group_index % summary_shape.y
			var column_item_count := mini(summary_shape.y, group_keys.size() - column_index * summary_shape.y)
			var column_height_screen := float(column_item_count) * max_height_screen \
				+ float(maxi(0, column_item_count - 1)) * CITY_FACTION_SUMMARY_ROW_GAP_SCREEN
			x_screen = x_origin_screen + float(column_index) * (width_screen + CITY_FACTION_WINDOW_GAP_SCREEN)
			y_screen = -column_height_screen * 0.5 \
				+ float(row_index) * (max_height_screen + CITY_FACTION_SUMMARY_ROW_GAP_SCREEN)
		var rect_screen := Rect2(
			Vector2(x_screen, y_screen),
			Vector2(width_screen, natural_height * marker_scale)
		)
		_city_group_rect_screen[group_key] = rect_screen
		if not collapsed:
			for index in range(group_members.size()):
				var member_id := str(group_members[index])
				_stack_offset_screen_by_id[member_id] = Vector2(
					rect_screen.position.x + rect_screen.size.x * 0.5,
					rect_screen.position.y + (
						CITY_FACTION_WINDOW_HEADER_HEIGHT
						+ CITY_FACTION_WINDOW_CARD_TOP
						+ 16.0
						+ float(index) * CITY_FACTION_WINDOW_CARD_ROW
					) * marker_scale
				)


func _character_action_summary(member_ids: Array) -> Dictionary:
	var counts := CharacterActionPolicyScript.empty_counts()
	var troop_total := 0
	for member_id_value in member_ids:
		var member_id := str(member_id_value)
		var action := CharacterActionPolicyScript.normalize(str(_character_actions.get(member_id, CharacterActionPolicyScript.DEFAULT_ACTION)))
		if not counts.has(action):
			action = CharacterActionPolicyScript.DEFAULT_ACTION
		counts[action] = int(counts.get(action, 0)) + 1
		troop_total += int(_character_troops.get(member_id, CharacterCardScript.DEFAULT_TROOP_COUNT))
	var active_types := 0
	var short_label := CharacterActionPolicyScript.short_label(CharacterActionPolicyScript.DEFAULT_ACTION)
	for definition_value in CharacterActionPolicyScript.definitions():
		if not (definition_value is Dictionary):
			continue
		var definition: Dictionary = definition_value
		var action := str(definition.get("action", ""))
		if int(counts.get(action, 0)) > 0:
			active_types += 1
			short_label = CharacterActionPolicyScript.short_label(action)
	if active_types > 1:
		short_label = "混"
	var detail_parts: Array[String] = []
	for definition_value in CharacterActionPolicyScript.definitions():
		if not (definition_value is Dictionary):
			continue
		var definition: Dictionary = definition_value
		var action := str(definition.get("action", ""))
		detail_parts.append("%s %d" % [str(definition.get("label", "")), int(counts.get(action, 0))])
	return {
		"short": short_label,
		"detail": "行动：%s" % "｜".join(detail_parts),
		"counts": counts,
		"troop_total": troop_total,
		"troop_detail": "合计兵力：%s" % _format_troop_count_exact(troop_total)
	}


func _format_troop_count_exact(value: int) -> String:
	var digits := str(maxi(0, value))
	var grouped := ""
	for index in range(digits.length()):
		if index > 0 and (digits.length() - index) % 3 == 0:
			grouped += ","
		grouped += digits[index]
	return grouped


func _layout_city_faction_groups_for_place(place_id: String, group_keys: Array) -> void:
	if group_keys.is_empty() or _world_layer == null:
		return
	_refresh_city_faction_screen_geometry_for_place(place_id, group_keys)
	for group_key_value in group_keys:
		var group_key := str(group_key_value)
		var meta: Dictionary = _city_group_meta.get(group_key, {})
		var group_members: Array = _city_group_members.get(group_key, [])
		var collapsed := _city_group_visually_collapsed(group_key)
		var natural_height := _city_group_natural_height(group_members.size(), collapsed)
		var faction_window = CityFactionWindowScript.new()
		faction_window.setup(
			group_key,
			str(meta.get("place_name", place_id)),
			str(meta.get("faction_name", CITY_FACTION_UNASSIGNED_NAME)),
			group_members.size(),
			collapsed,
			_city_faction_window_accent(str(meta.get("faction_id", CITY_FACTION_UNASSIGNED_ID))),
			Vector2(CITY_FACTION_WINDOW_WIDTH, natural_height),
			_city_detail_compact,
			_character_action_summary(group_members),
			str(meta.get("faction_marker", ""))
		)
		faction_window.z_index = 85
		faction_window.collapsed_changed.connect(_on_city_faction_window_collapsed_changed)
		faction_window.rename_requested.connect(_on_city_faction_window_rename_requested)
		_world_layer.add_child(faction_window)
		_city_faction_window_by_key[group_key] = faction_window
		for member_id_value in group_members:
			var member_id := str(member_id_value)
			var member_card: CharacterCard = _card_by_id[member_id]
			member_card.set_city_faction_context(str(meta.get("faction_name", CITY_FACTION_UNASSIGNED_NAME)))
			member_card.set_stack_state(
				group_members.size(),
				not collapsed,
				false,
				str(meta.get("place_name", place_id)),
				collapsed
			)


func _on_city_faction_window_collapsed_changed(group_key: String, collapsed: bool) -> void:
	set_city_faction_group_collapsed(group_key, collapsed)


func _on_city_faction_window_rename_requested(group_key: String) -> void:
	var meta: Dictionary = _city_group_meta.get(group_key, {})
	var faction_id := str(meta.get("faction_id", CITY_FACTION_UNASSIGNED_ID))
	if faction_id == CITY_FACTION_UNASSIGNED_ID:
		return
	city_faction_rename_requested.emit(faction_id, str(meta.get("faction_name", "")))


func set_city_faction_group_collapsed(group_key: String, collapsed: bool) -> bool:
	if not _city_faction_window_by_key.has(group_key):
		return false
	if collapsed:
		_collapsed_city_group_keys[group_key] = true
	else:
		_collapsed_city_group_keys.erase(group_key)
	var meta: Dictionary = _city_group_meta.get(group_key, {})
	var member_count := (_city_group_members.get(group_key, []) as Array).size()
	_rebuild_stack_layout()
	_layout_all_cards()
	city_faction_window_toggled.emit(
		str(meta.get("place_name", "城池")),
		str(meta.get("faction_name", CITY_FACTION_UNASSIGNED_NAME)),
		member_count,
		collapsed
	)
	return true


func set_city_faction_details_visible(value: bool) -> void:
	if _city_faction_details_toggle != null:
		_city_faction_details_toggle.set_pressed_no_signal(value)
	if _city_faction_details_visible == value:
		return
	_city_faction_details_visible = value
	if _world_layer != null:
		_rebuild_stack_layout()
		_layout_all_cards()


func is_city_faction_details_visible() -> bool:
	return _city_faction_details_visible


func _on_city_faction_details_toggled(value: bool) -> void:
	set_city_faction_details_visible(value)
	city_faction_details_visibility_changed.emit(value)


func get_city_faction_window_state(place_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var group_keys: Array = _city_group_keys_by_place.get(place_id, [])
	var summary_shape := _city_faction_summary_grid_shape(group_keys)
	for group_key_value in group_keys:
		var group_key := str(group_key_value)
		var meta: Dictionary = _city_group_meta.get(group_key, {})
		result.append({
			"group_key": group_key,
			"place_id": place_id,
			"place_name": str(meta.get("place_name", "")),
			"faction_id": str(meta.get("faction_id", "")),
			"faction_name": str(meta.get("faction_name", "")),
			"faction_color": str(meta.get("faction_color", FactionPaletteScript.UNASSIGNED_HEX)),
			"faction_marker": str(meta.get("faction_marker", "")),
			"render_accent": _city_faction_window_accent(str(meta.get("faction_id", CITY_FACTION_UNASSIGNED_ID))),
			"member_ids": (_city_group_members.get(group_key, []) as Array).duplicate(),
			"member_count": (_city_group_members.get(group_key, []) as Array).size(),
			"action_summary": _character_action_summary(_city_group_members.get(group_key, [])),
			"collapsed": _collapsed_city_group_keys.has(group_key),
			"visual_collapsed": _city_group_visually_collapsed(group_key),
			"auto_compact": _city_detail_compact,
			"global_details_visible": _city_faction_details_visible,
			"summary_grid": summary_shape.y > 1,
			"summary_columns": summary_shape.x,
			"summary_rows": summary_shape.y,
			"rect_screen": _city_group_rect_screen.get(group_key, Rect2()),
			"has_window": _city_faction_window_by_key.has(group_key)
		})
	return result


func get_city_faction_window(group_key: String) -> Control:
	return _city_faction_window_by_key.get(group_key) as Control


func _map_card_screen_size(card: CharacterCard) -> Vector2:
	var natural_card_size := Vector2(
		maxf(card.size.x, card.custom_minimum_size.x),
		maxf(card.size.y, card.custom_minimum_size.y)
	)
	if natural_card_size.x < 1.0 or natural_card_size.y < 1.0:
		natural_card_size = Vector2(84, 32)
	return natural_card_size * _screen_marker_scale()


func _place_stack_footprint_screen(place_id: String, members: Array) -> Rect2:
	var footprint := Rect2()
	var initialized := false
	for group_key_value in _city_group_keys_by_place.get(place_id, []):
		var group_rect_value: Variant = _city_group_rect_screen.get(str(group_key_value), null)
		if group_rect_value is Rect2:
			var group_rect: Rect2 = group_rect_value
			footprint = footprint.merge(group_rect) if initialized else group_rect
			initialized = true
	if initialized:
		return footprint
	for member_id_value in members:
		var member_id := str(member_id_value)
		if not _card_by_id.has(member_id):
			continue
		var card: CharacterCard = _card_by_id[member_id]
		var card_size := _map_card_screen_size(card)
		var stack_offset: Vector2 = _stack_offset_screen_by_id.get(member_id, Vector2.ZERO)
		var card_rect := Rect2(stack_offset - card_size * 0.5, card_size)
		footprint = footprint.merge(card_rect) if initialized else card_rect
		initialized = true
	return footprint if initialized else Rect2(Vector2(-42, -16), Vector2(84, 32))


func _rebuild_place_dock_layout() -> void:
	_place_dock_offset_screen_by_id.clear()
	_place_dock_rect_screen_by_id.clear()
	_place_dock_collision_count = 0
	_place_dock_fixed_overlay_collision_count = 0
	if _canvas == null or _stack_members_by_place.is_empty():
		_queue_place_dock_connectors()
		return
	var label_state: Dictionary = _canvas.get_place_label_layout_state()
	var label_entries: Dictionary = label_state.get("entries", {})
	var label_rects: Dictionary = _canvas.get_place_label_rects_screen(zoom)
	var occupied: Array[Dictionary] = []
	for place_id_value in _stack_members_by_place:
		var place_id := str(place_id_value)
		var members: Array = _stack_members_by_place[place_id]
		if members.is_empty():
			continue
		var top_character_id := str(members.back())
		if not _card_by_id.has(top_character_id):
			continue
		var entry: Dictionary = label_entries.get(place_id, {})
		occupied.append({
			"place_id": place_id,
			"priority": int(entry.get("priority", 0)),
			"footprint": _place_stack_footprint_screen(place_id, members)
		})
	occupied.sort_custom(_sort_place_dock_priority)
	var node_rects := _visible_place_node_rects_screen(label_rects)
	var fixed_overlay_rects := _visible_place_dock_fixed_overlay_rects_screen()
	var map_content_rect := Rect2(MAP_CONTENT_RECT.position * zoom, MAP_CONTENT_RECT.size * zoom)
	# 卡组布局使用未加 pan 的世界屏幕坐标，因此当前可见窗口需转换为 -pan。
	# 这样切到较近的默认汉地视角时，驻城卡组不会越过窗口顶边或侧边。
	var viewport_safe_rect := Rect2()
	if size.x > 20.0 and size.y > 20.0:
		viewport_safe_rect = Rect2(-pan + Vector2(10.0, 10.0), size - Vector2(20.0, 20.0))
	var content_rect := map_content_rect.intersection(viewport_safe_rect) if viewport_safe_rect.has_area() else map_content_rect
	if not content_rect.has_area():
		content_rect = map_content_rect

	# 第一遍使用八圈停靠，不把固定 HUD 加入评分。这样所有原本
	# 不遮挡图例的窗口保持原位置，避免一个东部窗口移动后引发全图连锁换位。
	var baseline_by_place: Dictionary = {}
	var baseline_accepted_rects: Array[Rect2] = []
	for occupied_entry in occupied:
		var place_id := str(occupied_entry.get("place_id", ""))
		var place_index := _place_ids.find(place_id)
		if place_index < 0:
			continue
		var node_screen := _place_world_positions[place_index] * zoom
		# 地点圆点刚进入视口边缘时，驻城窗口也应优先回收到可视区；否则在
		# 超近景下会出现“城名可见、人物窗口被裁掉”的半可见状态。
		var node_near_viewport := viewport_safe_rect.grow(
			PLACE_DOCK_NODE_CLEARANCE_SCREEN * 2.0
		).has_point(node_screen)
		var placement_content_rect := content_rect if node_near_viewport else map_content_rect
		var footprint: Rect2 = occupied_entry.get("footprint", Rect2(Vector2(-42, -16), Vector2(84, 32)))
		var own_label_rect: Rect2 = label_rects.get(place_id, Rect2(node_screen, Vector2.ZERO))
		var label_delta := own_label_rect.get_center() - node_screen
		var baseline_choice := _choose_place_dock_candidate(
			node_screen,
			footprint,
			label_delta,
			place_id,
			label_rects,
			node_rects,
			baseline_accepted_rects,
			{},
			placement_content_rect,
			PLACE_DOCK_BASE_CANDIDATE_RING_COUNT
		)
		baseline_choice["node_screen"] = node_screen
		baseline_choice["footprint"] = footprint
		baseline_choice["label_delta"] = label_delta
		baseline_choice["content_rect"] = placement_content_rect
		baseline_by_place[place_id] = baseline_choice
		baseline_accepted_rects.append(baseline_choice.get("rect", Rect2()))

	# 第二遍只移动确实压到固定 HUD 的窗口；未受影响的 A10 窗口作为保留矩形，
	# 冲突窗口在它们周围重选有限候选，不反向推动已经稳定的窗口。
	var final_by_place := baseline_by_place.duplicate(true)
	var reserved_rects: Array[Rect2] = []
	for occupied_entry in occupied:
		var place_id := str(occupied_entry.get("place_id", ""))
		if not baseline_by_place.has(place_id):
			continue
		var baseline_rect: Rect2 = baseline_by_place[place_id].get("rect", Rect2())
		if not _rect_intersects_any(baseline_rect, fixed_overlay_rects.values()):
			reserved_rects.append(baseline_rect)
	for occupied_entry in occupied:
		var place_id := str(occupied_entry.get("place_id", ""))
		if not baseline_by_place.has(place_id):
			continue
		var baseline_choice: Dictionary = baseline_by_place[place_id]
		var baseline_rect: Rect2 = baseline_choice.get("rect", Rect2())
		if not _rect_intersects_any(baseline_rect, fixed_overlay_rects.values()):
			continue
		var adjusted_choice := _choose_place_dock_candidate(
			baseline_choice.get("node_screen", Vector2.ZERO),
			baseline_choice.get("footprint", Rect2(Vector2(-42, -16), Vector2(84, 32))),
			baseline_choice.get("label_delta", Vector2.ZERO),
			place_id,
			label_rects,
			node_rects,
			reserved_rects,
			fixed_overlay_rects,
			baseline_choice.get("content_rect", content_rect),
			PLACE_DOCK_EXTENDED_CANDIDATE_RING_COUNT
		)
		final_by_place[place_id] = adjusted_choice
		reserved_rects.append(adjusted_choice.get("rect", Rect2()))

	for occupied_entry in occupied:
		var place_id := str(occupied_entry.get("place_id", ""))
		if not final_by_place.has(place_id):
			continue
		var final_choice: Dictionary = final_by_place[place_id]
		var final_rect: Rect2 = final_choice.get("rect", Rect2())
		if float(final_choice.get("score", INF)) > PLACE_DOCK_COLLISION_EPSILON:
			_place_dock_collision_count += 1
		_place_dock_offset_screen_by_id[place_id] = final_choice.get("offset", Vector2.ZERO)
		_place_dock_rect_screen_by_id[place_id] = final_rect
		if _rect_intersects_any(final_rect, fixed_overlay_rects.values()):
			_place_dock_fixed_overlay_collision_count += 1
	_place_dock_layout_builds += 1
	_queue_place_dock_connectors()


func _choose_place_dock_candidate(
	node_screen: Vector2,
	footprint: Rect2,
	label_delta: Vector2,
	place_id: String,
	label_rects: Dictionary,
	node_rects: Dictionary,
	accepted_rects: Array[Rect2],
	fixed_overlay_rects: Dictionary,
	content_rect: Rect2,
	ring_count: int
) -> Dictionary:
	var candidates := _place_dock_candidates_screen(label_delta, footprint, ring_count)
	var best_offset := Vector2.ZERO
	var best_rect := Rect2(node_screen + footprint.position, footprint.size)
	var best_score := INF
	for candidate_index in range(candidates.size()):
		var offset: Vector2 = candidates[candidate_index]
		var candidate_rect := Rect2((node_screen + offset + footprint.position).round(), footprint.size)
		var score := _place_dock_collision_score(
			candidate_rect,
			place_id,
			label_rects,
			node_rects,
			accepted_rects,
			fixed_overlay_rects,
			content_rect
		)
		if score < best_score:
			best_score = score
			best_offset = offset
			best_rect = candidate_rect
		if score <= PLACE_DOCK_COLLISION_EPSILON:
			break
	return {
		"offset": best_offset,
		"rect": best_rect,
		"score": best_score
	}


func _queue_place_dock_connectors() -> void:
	if _dock_connector_layer != null:
		_dock_connector_layer.queue_redraw()


func _draw_place_dock_connectors() -> void:
	if _dock_connector_layer == null:
		return
	for place_id_value in _place_dock_offset_screen_by_id:
		var place_id := str(place_id_value)
		var place_index := _place_ids.find(place_id)
		if place_index < 0:
			continue
		var dock_offset: Vector2 = _place_dock_offset_screen_by_id[place_id]
		if dock_offset.length() < 18.0:
			continue
		var node_screen := pan + _place_world_positions[place_index] * zoom
		var dock_anchor := node_screen + dock_offset
		_dock_connector_layer.draw_line(node_screen, dock_anchor, Color(0.10, 0.12, 0.08, 0.55), 3.0, true)
		_dock_connector_layer.draw_line(node_screen, dock_anchor, Color(0.79, 0.67, 0.36, 0.78), 1.2, true)
		_dock_connector_layer.draw_circle(node_screen, 3.0, Color(0.90, 0.77, 0.42, 0.82))
		var group_keys: Array = _city_group_keys_by_place.get(place_id, [])
		for group_index in range(mini(group_keys.size(), 12)):
			var group_key := str(group_keys[group_index])
			var meta: Dictionary = _city_group_meta.get(group_key, {})
			var faction_id := str(meta.get("faction_id", CITY_FACTION_UNASSIGNED_ID))
			var chip_color := _city_faction_window_accent(faction_id)
			var column := group_index % 4
			var row := group_index / 4
			var chip_rect := Rect2(
				node_screen + Vector2(-10.0 + float(column) * 5.5, -11.0 - float(row) * 5.5),
				Vector2(4.5, 4.5)
			)
			_dock_connector_layer.draw_rect(chip_rect.grow(1.0), Color(0.05, 0.07, 0.05, 0.82), true)
			_dock_connector_layer.draw_rect(chip_rect, chip_color, true)
	if _city_detail_compact:
		for character_id_value in _overview_declutter_offset_screen_by_id:
			var character_id := str(character_id_value)
			var offset: Vector2 = _overview_declutter_offset_screen_by_id.get(character_id, Vector2.ZERO)
			if offset.length() < 8.0 or not _placements.has(character_id):
				continue
			var placement: Dictionary = _placements[character_id]
			var place_id := str(placement.get("place_id", ""))
			var dock_offset: Vector2 = _place_dock_offset_screen_by_id.get(place_id, Vector2.ZERO) \
				if not place_id.is_empty() else Vector2.ZERO
			var stack_offset: Vector2 = _stack_offset_screen_by_id.get(character_id, Vector2.ZERO)
			var anchor_screen := pan + map_normalized_to_world(
				Vector2(float(placement.get("x", 0.5)), float(placement.get("y", 0.5)))
			) * zoom + dock_offset + stack_offset
			var target_screen := anchor_screen + offset
			var accent := _accent_for_character(character_id)
			_dock_connector_layer.draw_line(
				anchor_screen,
				target_screen,
				Color(accent, 0.48),
				1.2,
				true
			)
			_dock_connector_layer.draw_circle(anchor_screen, 2.4, Color(accent, 0.72))


func _sort_place_dock_priority(a: Dictionary, b: Dictionary) -> bool:
	var a_priority := int(a.get("priority", 0))
	var b_priority := int(b.get("priority", 0))
	if a_priority != b_priority:
		return a_priority > b_priority
	return str(a.get("place_id", "")).naturalnocasecmp_to(str(b.get("place_id", ""))) < 0


func _place_dock_candidates_screen(
	label_delta: Vector2,
	footprint: Rect2,
	ring_count := PLACE_DOCK_BASE_CANDIDATE_RING_COUNT
) -> Array[Vector2]:
	var left_offset := -PLACE_DOCK_GAP_SCREEN - footprint.end.x
	var right_offset := PLACE_DOCK_GAP_SCREEN - footprint.position.x
	var above_offset := -PLACE_DOCK_GAP_SCREEN - footprint.end.y
	var below_offset := PLACE_DOCK_GAP_SCREEN - footprint.position.y
	var horizontal_sign := -1.0 if label_delta.x >= 0.0 else 1.0
	var vertical_sign := -1.0 if label_delta.y >= 0.0 else 1.0
	var horizontal_primary := Vector2(left_offset if horizontal_sign < 0.0 else right_offset, 0)
	var horizontal_other := Vector2(right_offset if horizontal_sign < 0.0 else left_offset, 0)
	var vertical_primary := Vector2(0, above_offset if vertical_sign < 0.0 else below_offset)
	var vertical_other := Vector2(0, below_offset if vertical_sign < 0.0 else above_offset)
	var diagonal_primary := Vector2(horizontal_primary.x, vertical_primary.y)
	var diagonal_other_y := Vector2(horizontal_primary.x, vertical_other.y)
	var diagonal_other_x := Vector2(horizontal_other.x, vertical_primary.y)
	var diagonal_opposite := Vector2(horizontal_other.x, vertical_other.y)
	var candidates: Array[Vector2] = []
	if absf(label_delta.y) > absf(label_delta.x):
		candidates.assign([vertical_primary, diagonal_primary, horizontal_primary, diagonal_other_x, horizontal_other, diagonal_other_y, vertical_other, diagonal_opposite])
	else:
		candidates.assign([horizontal_primary, diagonal_primary, vertical_primary, diagonal_other_y, vertical_other, diagonal_other_x, horizontal_other, diagonal_opposite])
	var base_candidates := candidates.duplicate()
	# 展开后的同城组可能同时遇到多倍率地点标签；基础使用八圈。
	# 固定 HUD 或边界发生冲突时，由调用方继续追加到十圈。
	for ring in range(1, maxi(1, ring_count) + 1):
		for candidate in base_candidates:
			var extra := Vector2(
				signf(candidate.x) * 18.0 * ring if not is_zero_approx(candidate.x) else 0.0,
				signf(candidate.y) * 12.0 * ring if not is_zero_approx(candidate.y) else 0.0
			)
			candidates.append(candidate + extra)
	return candidates


func _visible_place_node_rects_screen(label_rects: Dictionary) -> Dictionary:
	var result := {}
	for place_id_value in label_rects:
		var place_id := str(place_id_value)
		var place_index := _place_ids.find(place_id)
		if place_index < 0:
			continue
		var node_screen := _place_world_positions[place_index] * zoom
		result[place_id] = Rect2(node_screen - Vector2.ONE * PLACE_DOCK_NODE_CLEARANCE_SCREEN, Vector2.ONE * PLACE_DOCK_NODE_CLEARANCE_SCREEN * 2.0)
	return result


func _visible_place_dock_fixed_overlay_rects_screen() -> Dictionary:
	var result := {}
	var board_global_rect := get_global_rect()
	for overlay_record in [
		{"id": "map_tools", "control": _map_tools_panel},
		{"id": "faction_influence_toggle", "control": _faction_influence_toggle_panel},
		{"id": "city_faction_details_toggle", "control": _city_faction_details_toggle_panel},
		{"id": "faction_influence_legend", "control": _faction_influence_legend_panel}
	]:
		var overlay := overlay_record.get("control") as Control
		if overlay == null or not overlay.visible or overlay.size.x <= 1.0 or overlay.size.y <= 1.0:
			continue
		# 驻城窗口使用“未加 pan 的世界屏幕坐标”；固定 HUD 使用面板局部屏幕坐标。
		# 因此先把固定工具卡换算到 MapBoard 局部坐标，再减去 pan，供同一套候选评分使用。
		var overlay_global_rect := overlay.get_global_rect()
		var overlay_local_rect := Rect2(
			overlay_global_rect.position - board_global_rect.position,
			overlay_global_rect.size
		)
		result[str(overlay_record.get("id", "overlay"))] = Rect2(
			overlay_local_rect.position - pan,
			overlay_local_rect.size
		).grow(PLACE_DOCK_FIXED_OVERLAY_MARGIN_SCREEN)
	return result


func _place_dock_collision_score(
	rect: Rect2,
	place_id: String,
	label_rects: Dictionary,
	node_rects: Dictionary,
	accepted_rects: Array[Rect2],
	fixed_overlay_rects: Dictionary,
	content_rect: Rect2
) -> float:
	var outside_area := _rect_outside_area(rect, content_rect)
	var score := outside_area * 8.0
	for label_rect_value in label_rects.values():
		var label_rect: Rect2 = (label_rect_value as Rect2).grow(PLACE_DOCK_LABEL_MARGIN_SCREEN)
		if rect.intersects(label_rect):
			score += rect.intersection(label_rect).get_area() * 4.0
	for node_place_id in node_rects:
		var node_rect: Rect2 = node_rects[node_place_id]
		if rect.intersects(node_rect):
			score += rect.intersection(node_rect).get_area() * (6.0 if str(node_place_id) == place_id else 3.0)
	for accepted_rect in accepted_rects:
		if rect.intersects(accepted_rect):
			score += rect.intersection(accepted_rect).get_area() * 3.0
	for overlay_rect_value in fixed_overlay_rects.values():
		var overlay_rect: Rect2 = overlay_rect_value
		if rect.intersects(overlay_rect):
			score += PLACE_DOCK_FIXED_OVERLAY_PENALTY \
				+ rect.intersection(overlay_rect).get_area() * 8.0
	return score


func _rect_intersects_any(rect: Rect2, other_rects: Array) -> bool:
	for other_rect_value in other_rects:
		var other_rect: Rect2 = other_rect_value
		if rect.intersects(other_rect):
			return true
	return false


func _rect_outside_area(rect: Rect2, boundary: Rect2) -> float:
	var inside_area := rect.intersection(boundary).get_area() if rect.intersects(boundary) else 0.0
	return maxf(0.0, rect.get_area() - inside_area)


func get_place_dock_layout_state() -> Dictionary:
	return {
		"builds": _place_dock_layout_builds,
		"collision_count": _place_dock_collision_count,
		"fixed_overlay_collision_count": _place_dock_fixed_overlay_collision_count,
		"fixed_overlay_margin_screen": PLACE_DOCK_FIXED_OVERLAY_MARGIN_SCREEN,
		"fixed_overlay_rects_screen": _visible_place_dock_fixed_overlay_rects_screen(),
		"city_auto_compact": _city_detail_compact,
		"city_auto_compact_zoom": CITY_FACTION_COMPACT_ZOOM,
		"character_overview_mode": _city_detail_compact,
		"character_overview_size": CharacterCardScript.MAP_OVERVIEW_SIZE,
		"character_overview_declutter_offsets": _overview_declutter_offset_screen_by_id.duplicate(true),
		"offsets": _place_dock_offset_screen_by_id.duplicate(true),
		"rects_screen": _place_dock_rect_screen_by_id.duplicate(true),
		"label_rects_screen": _canvas.get_place_label_rects_screen(zoom) if _canvas != null else {}
	}


func _sort_character_ids_by_z(first_id: Variant, second_id: Variant) -> bool:
	var first_key := str(first_id)
	var second_key := str(second_id)
	var first_z := int(_card_base_z_by_id.get(first_key, 100 + int(_character_order_by_id.get(first_key, 0))))
	var second_z := int(_card_base_z_by_id.get(second_key, 100 + int(_character_order_by_id.get(second_key, 0))))
	if first_z == second_z:
		return int(_character_order_by_id.get(first_key, 0)) < int(_character_order_by_id.get(second_key, 0))
	return first_z < second_z


func _normalize_card_z_if_needed() -> void:
	if _next_card_z < CHARACTER_BASE_Z_NORMALIZE_THRESHOLD:
		return
	var ids := _card_by_id.keys()
	ids.sort_custom(_sort_character_ids_by_z)
	_next_card_z = 100
	for character_id in ids:
		_next_card_z += 1
		var card: CharacterCard = _card_by_id[character_id]
		_card_base_z_by_id[str(character_id)] = _next_card_z
		if not _active_drag_ids.has(str(character_id)):
			card.z_index = _next_card_z
	_refresh_character_attention_presentation()


func _raise_card_base_order(character_id: String, refresh_presentation := true) -> void:
	if not _card_by_id.has(character_id):
		return
	_normalize_card_z_if_needed()
	_next_card_z += 1
	_card_base_z_by_id[character_id] = _next_card_z
	if refresh_presentation:
		_refresh_character_attention_presentation()


func _set_attention_alpha(control: CanvasItem, alpha: float) -> void:
	if control == null:
		return
	var next_modulate := control.modulate
	next_modulate.a = clampf(alpha, 0.0, 1.0)
	if not control.modulate.is_equal_approx(next_modulate):
		control.modulate = next_modulate


func _visible_control_global_rect(control: Control) -> Rect2:
	if control == null or not control.is_inside_tree() or not control.is_visible_in_tree():
		return Rect2()
	return control.get_global_rect()


func _character_screen_overlap_ratio(first_rect: Rect2, second_rect: Rect2) -> float:
	if not first_rect.has_area() or not second_rect.has_area() or not first_rect.intersects(second_rect):
		return 0.0
	var intersection := first_rect.intersection(second_rect)
	var smaller_area := minf(first_rect.get_area(), second_rect.get_area())
	if not intersection.has_area() or smaller_area <= 0.001:
		return 0.0
	return clampf(intersection.get_area() / smaller_area, 0.0, 1.0)


func _refresh_character_attention_presentation() -> void:
	_attention_dimmed_character_ids.clear()
	_attention_dimmed_annotation_ids.clear()
	_attention_dimmed_city_group_keys.clear()
	var attention_ids: Array[String] = []
	for selected_id in _selected_character_ids:
		if _card_by_id.has(selected_id) and (_card_by_id[selected_id] as CharacterCard).is_visible_in_tree():
			attention_ids.append(selected_id)
	if not _hovered_character_id.is_empty() and _card_by_id.has(_hovered_character_id):
		var hovered_card: CharacterCard = _card_by_id[_hovered_character_id]
		if hovered_card.is_visible_in_tree() and not attention_ids.has(_hovered_character_id):
			attention_ids.append(_hovered_character_id)

	for character_id_value in _card_by_id:
		var character_id := str(character_id_value)
		var card: CharacterCard = _card_by_id[character_id]
		if _active_drag_ids.has(character_id):
			continue
		_set_attention_alpha(card, 1.0)
		card.z_index = int(_card_base_z_by_id.get(character_id, card.z_index))
	for marker_value in _annotation_by_id.values():
		var marker := marker_value as Control
		if marker != null and marker != _annotation_by_id.get(_active_annotation_drag_id):
			_set_attention_alpha(marker, 1.0)
	for faction_window_value in _city_faction_window_by_key.values():
		_set_attention_alpha(faction_window_value as Control, 1.0)

	var selected_focus_index := 0
	for selected_id in _selected_character_ids:
		if not attention_ids.has(selected_id) or _active_drag_ids.has(selected_id):
			continue
		(_card_by_id[selected_id] as CharacterCard).z_index = CHARACTER_SELECTED_FOCUS_Z + selected_focus_index
		selected_focus_index += 1
	if attention_ids.has(_hovered_character_id) and not _active_drag_ids.has(_hovered_character_id):
		(_card_by_id[_hovered_character_id] as CharacterCard).z_index = CHARACTER_HOVER_FOCUS_Z

	if attention_ids.is_empty():
		return
	var focus_rects: Array[Rect2] = []
	for attention_id in attention_ids:
		var attention_rect := _visible_control_global_rect(_card_by_id[attention_id] as CharacterCard)
		if attention_rect.has_area():
			focus_rects.append(attention_rect.grow(CHARACTER_ATTENTION_MARGIN_SCREEN))
	if focus_rects.is_empty():
		return

	for character_id_value in _card_by_id:
		var character_id := str(character_id_value)
		if attention_ids.has(character_id) or _active_drag_ids.has(character_id):
			continue
		var card: CharacterCard = _card_by_id[character_id]
		var card_rect := _visible_control_global_rect(card)
		if card_rect.has_area() and _rect_intersects_any(card_rect, focus_rects):
			_set_attention_alpha(card, CHARACTER_ATTENTION_DIM_ALPHA)
			_attention_dimmed_character_ids.append(character_id)
	for group_key_value in _city_faction_window_by_key:
		var group_key := str(group_key_value)
		var faction_window := _city_faction_window_by_key[group_key] as Control
		var window_rect := _visible_control_global_rect(faction_window)
		if window_rect.has_area() and _rect_intersects_any(window_rect, focus_rects):
			_set_attention_alpha(faction_window, CHARACTER_ATTENTION_DIM_ALPHA)
			_attention_dimmed_city_group_keys.append(group_key)
	for annotation_id_value in _annotation_by_id:
		var annotation_id := str(annotation_id_value)
		if annotation_id == _active_annotation_drag_id:
			continue
		var marker := _annotation_by_id[annotation_id] as Control
		var marker_rect := _visible_control_global_rect(marker)
		if marker_rect.has_area() and _rect_intersects_any(marker_rect, focus_rects):
			_set_attention_alpha(marker, CHARACTER_ATTENTION_DIM_ALPHA)
			_attention_dimmed_annotation_ids.append(annotation_id)
	_attention_dimmed_character_ids.sort()
	_attention_dimmed_annotation_ids.sort()
	_attention_dimmed_city_group_keys.sort()


func get_character_attention_state() -> Dictionary:
	var attention_ids: Array[String] = []
	for character_id in _selected_character_ids:
		if _card_by_id.has(character_id) and (_card_by_id[character_id] as CharacterCard).is_visible_in_tree():
			attention_ids.append(character_id)
	if not _hovered_character_id.is_empty() and _card_by_id.has(_hovered_character_id) \
		and (_card_by_id[_hovered_character_id] as CharacterCard).is_visible_in_tree() \
		and not attention_ids.has(_hovered_character_id):
		attention_ids.append(_hovered_character_id)
	return {
		"hovered_character_id": _hovered_character_id,
		"selected_character_ids": get_selected_character_ids(),
		"attention_character_ids": attention_ids,
		"base_z_by_character": _card_base_z_by_id.duplicate(true),
		"dimmed_character_ids": _attention_dimmed_character_ids.duplicate(),
		"dimmed_annotation_ids": _attention_dimmed_annotation_ids.duplicate(),
		"dimmed_city_group_keys": _attention_dimmed_city_group_keys.duplicate(),
		"selected_focus_z": CHARACTER_SELECTED_FOCUS_Z,
		"hover_focus_z": CHARACTER_HOVER_FOCUS_Z,
		"dim_alpha": CHARACTER_ATTENTION_DIM_ALPHA,
		"input_contract": "unchanged"
	}


func _screen_marker_scale() -> float:
	# 175% 已经是人物卡的完整屏幕尺寸；更深近景只扩大地图间距，
	# 不再把卡牌、驻城窗口与交互命中区继续放大。
	var full_scale_zoom := minf(max_zoom, MARKER_FULL_SCALE_ZOOM)
	var t := clampf(inverse_lerp(min_zoom, full_scale_zoom, zoom), 0.0, 1.0)
	return lerpf(0.72, 1.0, t)


func _annotation_screen_scale() -> float:
	# 援军、地点和事件都是与人物卡并列的沙盘摆件。它们共用同一屏幕
	# 层级：天下总览适度收束，175% 起保持完整尺寸，300% 不继续膨胀。
	return _screen_marker_scale()


func _make_cache_clarity_material() -> ShaderMaterial:
	if _cache_clarity_material != null:
		return _cache_clarity_material
	var clarity_shader := Shader.new()
	clarity_shader.code = CACHE_CLARITY_SHADER_CODE
	_cache_clarity_material = ShaderMaterial.new()
	_cache_clarity_material.shader = clarity_shader
	_cache_clarity_material.set_shader_parameter("clarity_amount", 0.0)
	return _cache_clarity_material


func _update_cache_clarity() -> void:
	var progress := smoothstep(CACHE_CLARITY_START_ZOOM, CACHE_CLARITY_FULL_ZOOM, zoom)
	_cache_clarity_amount = CACHE_CLARITY_MAX_AMOUNT * progress
	if _cache_clarity_material != null:
		_cache_clarity_material.set_shader_parameter("clarity_amount", _cache_clarity_amount)
	if _jade_terrain_material != null:
		_jade_terrain_material.set_shader_parameter("clarity_amount", _cache_clarity_amount)
		# 远景保持连续色调，近景才逐步显出细色阶，避免缩小时闪烁。
		_jade_terrain_material.set_shader_parameter("pixel_mix", 0.12 * progress)


func _layout_card(character_id: String) -> void:
	if _active_drag_ids.has(character_id) or not _card_by_id.has(character_id) or not _placements.has(character_id):
		return
	var card: CharacterCard = _card_by_id[character_id]
	var placement: Dictionary = _placements[character_id]
	var world_center := map_normalized_to_world(Vector2(float(placement.get("x", 0.5)), float(placement.get("y", 0.5))))
	var stack_offset_screen: Vector2 = _stack_offset_screen_by_id.get(character_id, Vector2.ZERO)
	var overview_offset_screen: Vector2 = _overview_declutter_offset_screen_by_id.get(character_id, Vector2.ZERO)
	var place_id := str(placement.get("place_id", ""))
	var dock_offset_screen: Vector2 = _place_dock_offset_screen_by_id.get(place_id, Vector2.ZERO) if not place_id.is_empty() else Vector2.ZERO
	card.scale = Vector2.ONE * (_screen_marker_scale() / zoom)
	card.position = world_center + (dock_offset_screen + stack_offset_screen + overview_offset_screen) / zoom - card.size * card.scale * 0.5


func _layout_all_cards() -> void:
	_refresh_overview_declutter_offsets()
	_layout_all_city_faction_windows()
	for character_id in _card_by_id:
		_layout_card(character_id)
	_refresh_character_attention_presentation()
	if _faction_inspection_overlay != null and _faction_inspection_overlay.visible:
		_faction_inspection_overlay.queue_redraw()


func _refresh_overview_declutter_offsets() -> void:
	_overview_declutter_offset_screen_by_id.clear()
	if not _city_detail_compact:
		return
	var accepted_rects: Array[Rect2] = []
	var character_ids := _card_by_id.keys()
	character_ids.sort_custom(_sort_character_ids_stable)
	for character_id_value in character_ids:
		var character_id := str(character_id_value)
		var card: CharacterCard = _card_by_id.get(character_id)
		if card == null or not card.visible or not _placements.has(character_id):
			continue
		var placement: Dictionary = _placements[character_id]
		var world_center := map_normalized_to_world(
			Vector2(float(placement.get("x", 0.5)), float(placement.get("y", 0.5)))
		)
		var place_id := str(placement.get("place_id", ""))
		var dock_offset: Vector2 = _place_dock_offset_screen_by_id.get(place_id, Vector2.ZERO) \
			if not place_id.is_empty() else Vector2.ZERO
		var stack_offset: Vector2 = _stack_offset_screen_by_id.get(character_id, Vector2.ZERO)
		var base_center_screen: Vector2 = world_center * zoom + dock_offset + stack_offset
		var card_size: Vector2 = _map_card_screen_size(card)
		var candidates: Array[Vector2] = [Vector2.ZERO]
		for ring in range(1, OVERVIEW_CARD_MAX_RING + 1):
			var horizontal := (card_size.x + OVERVIEW_CARD_GAP_SCREEN) * float(ring)
			var vertical := (card_size.y + OVERVIEW_CARD_GAP_SCREEN) * float(ring)
			candidates.append_array([
				Vector2(0, -vertical),
				Vector2(0, vertical),
				Vector2(-horizontal, 0),
				Vector2(horizontal, 0),
				Vector2(-horizontal, -vertical),
				Vector2(horizontal, -vertical),
				Vector2(-horizontal, vertical),
				Vector2(horizontal, vertical)
			])
		var selected_offset := Vector2.ZERO
		var selected_rect := Rect2(base_center_screen - card_size * 0.5, card_size)
		for candidate in candidates:
			var candidate_rect := Rect2(base_center_screen + candidate - card_size * 0.5, card_size)
			if not _rect_intersects_any(candidate_rect.grow(OVERVIEW_CARD_GAP_SCREEN * 0.5), accepted_rects):
				selected_offset = candidate
				selected_rect = candidate_rect
				break
		# 极端密集时仍登记回退矩形，确保后续人物不会全部误判为空白并叠到同一点。
		# 这种情况只影响会话显示偏移，不改变人物的归一化地图坐标。
		accepted_rects.append(selected_rect)
		_overview_declutter_offset_screen_by_id[character_id] = selected_offset
	_queue_place_dock_connectors()


func _layout_all_city_faction_windows() -> void:
	for group_key_value in _city_faction_window_by_key:
		var group_key := str(group_key_value)
		var faction_window: Control = _city_faction_window_by_key[group_key]
		var meta: Dictionary = _city_group_meta.get(group_key, {})
		var place_id := str(meta.get("place_id", ""))
		var place_index := _place_ids.find(place_id)
		if place_index < 0:
			continue
		var rect_screen: Rect2 = _city_group_rect_screen.get(group_key, Rect2())
		var dock_offset_screen: Vector2 = _place_dock_offset_screen_by_id.get(place_id, Vector2.ZERO)
		var world_center: Vector2 = _place_world_positions[place_index]
		faction_window.scale = Vector2.ONE * (_screen_marker_scale() / zoom)
		faction_window.position = world_center + (dock_offset_screen + rect_screen.position) / zoom


func _on_map_card_drag_started(character_id: String, grab_local: Vector2) -> void:
	if _annotation_tool_active or not _active_annotation_drag_id.is_empty():
		return
	if not _card_by_id.has(character_id):
		return
	_hide_place_hover()
	if not _selected_character_ids.has(character_id):
		_select_only_character(character_id)
	_active_drag_id = character_id
	_drag_snap_bypass_override_enabled = false
	_drag_snap_bypass_override_value = false
	_active_drag_ids.clear()
	if _selected_character_ids.size() > 1:
		_active_drag_ids.append_array(get_selected_character_ids())
	else:
		_active_drag_ids.append(character_id)
	_active_drag_screen_offsets_by_id.clear()
	_active_group_drag_layout_offsets_by_id.clear()
	var screen_scale := _screen_marker_scale()
	var card: CharacterCard = _card_by_id[character_id]
	var anchor_screen_center := _map_card_screen_center(card, screen_scale)
	_drag_grab_offset_screen = grab_local * screen_scale
	for index in range(_active_drag_ids.size()):
		var dragged_id := _active_drag_ids[index]
		if not _card_by_id.has(dragged_id):
			continue
		var dragged_card: CharacterCard = _card_by_id[dragged_id]
		var dragged_screen_center := _map_card_screen_center(dragged_card, screen_scale)
		_active_drag_screen_offsets_by_id[dragged_id] = dragged_screen_center - anchor_screen_center
		if _active_drag_ids.size() > 1:
			var dragged_placement: Dictionary = _placements.get(dragged_id, {})
			var dragged_place_id := str(dragged_placement.get("place_id", ""))
			var dock_offset: Vector2 = _place_dock_offset_screen_by_id.get(dragged_place_id, Vector2.ZERO) \
				if not dragged_place_id.is_empty() else Vector2.ZERO
			_active_group_drag_layout_offsets_by_id[dragged_id] = (
				dock_offset
				+ (_stack_offset_screen_by_id.get(dragged_id, Vector2.ZERO) as Vector2)
				+ (_overview_declutter_offset_screen_by_id.get(dragged_id, Vector2.ZERO) as Vector2)
			)
		dragged_card.reparent(_drag_layer)
		dragged_card.scale = Vector2.ONE * screen_scale
		dragged_card.z_index = 4000 + index
	card.z_index = 4095
	_update_active_drag_position()
	_drag_total_frames = 0
	_drag_frame_samples.clear()
	_drag_update_samples_usec.clear()
	set_process(true)


func _process(_delta: float) -> void:
	if not _active_drag_id.is_empty():
		_drag_total_frames += 1
		var update_started := Time.get_ticks_usec()
		_update_active_drag_position()
		var update_usec := int(Time.get_ticks_usec() - update_started)
		if _drag_total_frames > DRAG_WARMUP_FRAMES and _drag_frame_samples.size() < DRAG_SAMPLE_LIMIT:
			_drag_frame_samples.append(_delta)
			_drag_update_samples_usec.append(update_usec)
	if not _active_annotation_drag_id.is_empty():
		_update_active_annotation_drag_position()
	if _camera_pan_dirty:
		_apply_camera(false)
		_camera_pan_dirty = false
	if _active_drag_id.is_empty() and _active_annotation_drag_id.is_empty() and not _panning and not _camera_pan_dirty:
		set_process(false)


func _update_active_drag_position() -> void:
	if _active_drag_id.is_empty() or not _card_by_id.has(_active_drag_id):
		return
	var anchor_card: CharacterCard = _card_by_id[_active_drag_id]
	var anchor_target := _drag_pointer_screen() - _drag_grab_offset_screen
	var anchor_center := anchor_target + anchor_card.size * anchor_card.scale * 0.5
	for dragged_id in _active_drag_ids:
		if not _card_by_id.has(dragged_id):
			continue
		var dragged_card: CharacterCard = _card_by_id[dragged_id]
		var dragged_center: Vector2 = anchor_center + _active_drag_screen_offsets_by_id.get(dragged_id, Vector2.ZERO)
		var target := dragged_center - dragged_card.size * dragged_card.scale * 0.5
		if not dragged_card.position.is_equal_approx(target):
			dragged_card.position = target
	if _active_drag_ids.size() > 1 or _is_snap_bypass_active():
		_clear_snap_candidate()
	else:
		_update_snap_candidate(anchor_center)


func _on_map_card_drag_ended(character_id: String, global_position: Vector2) -> void:
	if character_id != _active_drag_id or not _card_by_id.has(character_id):
		return
	_update_active_drag_position()
	if _active_drag_ids.size() > 1:
		_finish_character_group_drag(global_position)
		return
	var snap_bypassed := _is_snap_bypass_active()
	var card: CharacterCard = _card_by_id[character_id]
	var local_cursor := _drag_pointer_screen()
	var world_cursor := screen_to_world(local_cursor)
	var valid_map_drop := Rect2(Vector2.ZERO, size).has_point(local_cursor) and MAP_CONTENT_RECT.has_point(world_cursor)
	var screen_center := card.position + card.size * card.scale * 0.5
	var resolved := _resolve_drop_at_screen(screen_center, snap_bypassed)
	var normalized: Vector2 = resolved.get("normalized", Vector2(0.5, 0.5))
	_last_drop_context = resolved
	_last_drop_context["character_id"] = character_id
	card.reparent(_world_layer)
	_last_drag_stats = _build_drag_stats()
	_active_drag_id = ""
	_active_drag_ids.clear()
	_active_drag_screen_offsets_by_id.clear()
	_active_group_drag_layout_offsets_by_id.clear()
	_drag_pointer_override_enabled = false
	_drag_snap_bypass_override_enabled = false
	_drag_snap_bypass_override_value = false
	_clear_snap_candidate()
	set_process(false)
	_raise_card_base_order(character_id)
	character_drag_released.emit(character_id, global_position, normalized, valid_map_drop)
	_layout_card(character_id)


func _finish_character_group_drag(global_position: Vector2) -> void:
	var dragged_ids := _active_drag_ids.duplicate()
	var normalized_positions: Dictionary = {}
	var valid_map_drop := true
	for dragged_id in dragged_ids:
		if not _card_by_id.has(dragged_id):
			valid_map_drop = false
			continue
		var dragged_card: CharacterCard = _card_by_id[dragged_id]
		var screen_center := dragged_card.position + dragged_card.size * dragged_card.scale * 0.5
		# 远景避让、驻城停靠和同城栈偏移都只是显示位移；整组落点必须剥离这些
		# 会话级偏移，才能让所有人物保持完全相同的地图位移。
		var logical_screen_center: Vector2 = screen_center - (
			_active_group_drag_layout_offsets_by_id.get(dragged_id, Vector2.ZERO) as Vector2
		)
		var world_center := screen_to_world(logical_screen_center)
		if not Rect2(Vector2.ZERO, size).has_point(logical_screen_center) or not MAP_CONTENT_RECT.has_point(world_center):
			valid_map_drop = false
		normalized_positions[dragged_id] = world_to_map_normalized(world_center)
	_last_drop_context = {}
	_last_drag_stats = _build_drag_stats()
	_active_drag_id = ""
	_active_drag_ids.clear()
	_active_drag_screen_offsets_by_id.clear()
	_active_group_drag_layout_offsets_by_id.clear()
	_drag_pointer_override_enabled = false
	_drag_snap_bypass_override_enabled = false
	_drag_snap_bypass_override_value = false
	_clear_snap_candidate()
	for dragged_id in dragged_ids:
		if not _card_by_id.has(dragged_id):
			continue
		var dragged_card: CharacterCard = _card_by_id[dragged_id]
		dragged_card.reparent(_world_layer)
		_raise_card_base_order(str(dragged_id), false)
	_refresh_character_attention_presentation()
	set_process(false)
	character_group_drag_released.emit(dragged_ids, global_position, normalized_positions, valid_map_drop)
	for dragged_id in dragged_ids:
		_layout_card(dragged_id)


func _map_card_screen_center(card: CharacterCard, screen_scale: float) -> Vector2:
	return pan + card.position * zoom + card.size * screen_scale * 0.5


func _accent_for_group(group: String) -> Color:
	match group:
		"刘备军":
			return Color("4f8c62")
		"黄巾军":
			return Color("c99b36")
		"汉廷":
			return Color("a84d43")
		"孙氏":
			return Color("4d7fa8")
		"曹氏":
			return Color("6a6f98")
		_:
			return Color("8d6534")


func _accent_for_character(character_id: String) -> Color:
	var faction_id := str(_faction_by_character.get(character_id, ""))
	if not faction_id.is_empty() and _faction_color_by_id.has(faction_id):
		return FactionPaletteScript.render_on_light(_faction_color_by_id[faction_id])
	var character: Dictionary = _character_by_id.get(character_id, {})
	return _accent_for_group(str(character.get("group", "群雄")))


func _on_stroke_overlay_input(event: InputEvent) -> void:
	if _player_stroke_point_edit_active:
		_on_player_stroke_point_edit_input(event)
		return
	if _city_ownership_tool_active:
		_on_city_ownership_overlay_input(event)
		return
	if not _player_stroke_tool_active:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(event.position, 1.12)
			_stroke_input_overlay.accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(event.position, 1.0 / 1.12)
			_stroke_input_overlay.accept_event()
		elif event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			_panning = event.pressed
			_stroke_input_overlay.mouse_default_cursor_shape = Control.CURSOR_DRAG if _panning else Control.CURSOR_CROSS
			if _panning:
				set_process(true)
			_stroke_input_overlay.accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var resolved := screen_to_valid_map_normalized(event.position)
			if bool(resolved.get("valid", false)):
				var normalized: Vector2 = resolved.get("normalized", Vector2(0.5, 0.5))
				var append_point := _player_stroke_draft_points.is_empty()
				if not append_point:
					var previous_world := map_normalized_to_world(_player_stroke_draft_points[-1])
					append_point = previous_world.distance_to(map_normalized_to_world(normalized)) * zoom >= 4.0
				if append_point and _player_stroke_draft_points.size() < 48:
					_player_stroke_draft_points.append(normalized)
				_update_player_stroke_draft(normalized)
				_refresh_player_stroke_guide()
				if event.double_click and _player_stroke_draft_points.size() >= 2:
					finish_player_stroke_draft()
				elif _player_stroke_draft_points.size() >= 48:
					finish_player_stroke_draft()
			_stroke_input_overlay.accept_event()
	elif event is InputEventMouseMotion:
		if _panning:
			pan += event.relative
			_camera_pan_dirty = true
			set_process(true)
		else:
			var resolved := screen_to_valid_map_normalized(event.position)
			_update_player_stroke_draft(resolved.get("normalized", Vector2(-1.0, -1.0)) if bool(resolved.get("valid", false)) else Vector2(-1.0, -1.0))
		_stroke_input_overlay.accept_event()


func _on_city_ownership_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(event.position, 1.12)
			_stroke_input_overlay.accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(event.position, 1.0 / 1.12)
			_stroke_input_overlay.accept_event()
		elif event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			_panning = event.pressed
			_stroke_input_overlay.mouse_default_cursor_shape = Control.CURSOR_DRAG if _panning else Control.CURSOR_CROSS
			if _panning:
				_set_city_ownership_hover_place("")
				set_process(true)
			_stroke_input_overlay.accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var place_index := _find_visible_place_index_at_screen(event.position)
			if _is_city_ownership_editable_place_index(place_index):
				var place_id := _place_ids[place_index]
				_set_city_ownership_hover_place(place_id)
				city_ownership_place_requested.emit(place_id)
			_stroke_input_overlay.accept_event()
	elif event is InputEventMouseMotion:
		if _panning:
			pan += event.relative
			_camera_pan_dirty = true
			_set_city_ownership_hover_place("")
			set_process(true)
		else:
			var place_index := _find_visible_place_index_at_screen(event.position)
			if _is_city_ownership_editable_place_index(place_index):
				_set_city_ownership_hover_place(_place_ids[place_index])
				_stroke_input_overlay.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			else:
				_set_city_ownership_hover_place("")
				_stroke_input_overlay.mouse_default_cursor_shape = Control.CURSOR_CROSS
		_stroke_input_overlay.accept_event()


func _is_city_ownership_editable_place_index(place_index: int) -> bool:
	return (
		place_index >= 0
		and place_index < _place_types.size()
		and _place_types[place_index] in ["city", "capital"]
	)


func _set_city_ownership_hover_place(place_id: String) -> void:
	if _city_ownership_hover_place_id == place_id:
		return
	_city_ownership_hover_place_id = place_id
	city_ownership_hover_changed.emit(place_id)


func _on_player_stroke_point_edit_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed and _player_stroke_point_active_index < 0:
			_zoom_at(event.position, 1.12)
			_stroke_input_overlay.accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and _player_stroke_point_active_index < 0:
			_zoom_at(event.position, 1.0 / 1.12)
			_stroke_input_overlay.accept_event()
		elif (event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT) and _player_stroke_point_active_index < 0:
			_panning = event.pressed
			_stroke_input_overlay.mouse_default_cursor_shape = Control.CURSOR_DRAG if _panning else Control.CURSOR_POINTING_HAND
			if _panning:
				set_process(true)
			_stroke_input_overlay.accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var index := -1
			if _player_stroke_layer != null:
				index = _player_stroke_layer.find_point_edit_handle_at_world(screen_to_world(event.position), PlayerStrokeLayerScript.HANDLE_HIT_RADIUS_SCREEN / zoom)
			if index >= 0 and index < _player_stroke_point_preview_points.size():
				_player_stroke_point_active_index = index
				_player_stroke_point_press_screen = event.position
				_player_stroke_point_drag_start = _player_stroke_point_preview_points[index]
				_player_stroke_point_dragging = false
				_update_player_stroke_point_edit_preview()
				_refresh_player_stroke_guide()
			_stroke_input_overlay.accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and _player_stroke_point_active_index >= 0:
			var resolved := screen_to_valid_map_normalized(event.position)
			if _player_stroke_point_dragging and bool(resolved.get("valid", false)):
				_player_stroke_point_preview_points[_player_stroke_point_active_index] = resolved.get("normalized", _player_stroke_point_drag_start)
			else:
				_player_stroke_point_preview_points[_player_stroke_point_active_index] = _player_stroke_point_drag_start
			_player_stroke_point_active_index = -1
			_player_stroke_point_dragging = false
			_update_player_stroke_point_edit_preview()
			_refresh_player_stroke_guide()
			_stroke_input_overlay.accept_event()
	elif event is InputEventMouseMotion:
		if _player_stroke_point_active_index >= 0:
			if not _player_stroke_point_dragging and event.position.distance_to(_player_stroke_point_press_screen) >= PLAYER_STROKE_HANDLE_DRAG_THRESHOLD_SCREEN:
				_player_stroke_point_dragging = true
			if _player_stroke_point_dragging:
				var resolved := screen_to_valid_map_normalized(event.position)
				if bool(resolved.get("valid", false)):
					_player_stroke_point_preview_points[_player_stroke_point_active_index] = resolved.get("normalized", _player_stroke_point_drag_start)
			_update_player_stroke_point_edit_preview()
			_refresh_player_stroke_guide()
		elif _panning:
			pan += event.relative
			_camera_pan_dirty = true
			set_process(true)
		else:
			var handle_index := -1
			if _player_stroke_layer != null:
				handle_index = _player_stroke_layer.find_point_edit_handle_at_world(screen_to_world(event.position), PlayerStrokeLayerScript.HANDLE_HIT_RADIUS_SCREEN / zoom)
			_stroke_input_overlay.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if handle_index >= 0 else Control.CURSOR_ARROW
		_stroke_input_overlay.accept_event()


func _update_player_stroke_point_edit_preview() -> void:
	if _player_stroke_layer != null:
		_player_stroke_layer.set_point_edit_preview(_player_stroke_point_edit_id, _player_stroke_point_preview_points, _player_stroke_point_active_index)


func _cancel_active_player_stroke_point_drag() -> void:
	if _player_stroke_point_active_index >= 0 and _player_stroke_point_active_index < _player_stroke_point_preview_points.size():
		_player_stroke_point_preview_points[_player_stroke_point_active_index] = _player_stroke_point_drag_start
	_player_stroke_point_active_index = -1
	_player_stroke_point_dragging = false
	_update_player_stroke_point_edit_preview()


func _update_player_stroke_draft(hover_normalized: Vector2) -> void:
	if _player_stroke_layer != null:
		_player_stroke_layer.set_draft(_player_stroke_draft_points, hover_normalized, _player_stroke_type)


func _refresh_player_stroke_guide() -> void:
	if _stroke_guide_label == null:
		return
	if _player_stroke_point_edit_active:
		var changed := not _player_stroke_vector_points_match(_player_stroke_point_original_points, _player_stroke_point_preview_points)
		_stroke_guide_label.text = "调整路线 · 拖动金色折点 · Enter 保存，Esc 取消"
		if _stroke_undo_point_button != null:
			_stroke_undo_point_button.visible = false
		if _stroke_finish_button != null:
			_stroke_finish_button.text = "保存"
			_stroke_finish_button.visible = true
			_stroke_finish_button.disabled = not changed or _player_stroke_point_active_index >= 0
		return
	var count := _player_stroke_draft_points.size()
	_stroke_guide_label.text = "%s · 已落 %d 点 · 单击落点，双击或 Enter 完成" % [_player_stroke_type_label(_player_stroke_type), count]
	if _stroke_undo_point_button != null:
		_stroke_undo_point_button.visible = true
		_stroke_undo_point_button.disabled = count == 0
	if _stroke_finish_button != null:
		_stroke_finish_button.text = "完成"
		_stroke_finish_button.visible = true
		_stroke_finish_button.disabled = count < 2


func _refresh_player_stroke_interaction_ui() -> void:
	var active := _player_stroke_tool_active or _player_stroke_point_edit_active
	if _stroke_input_overlay != null:
		_stroke_input_overlay.visible = active or _city_ownership_tool_active
		_stroke_input_overlay.mouse_default_cursor_shape = (
			Control.CURSOR_POINTING_HAND
			if _player_stroke_point_edit_active
			else Control.CURSOR_CROSS
		)
	if _stroke_guide_panel != null:
		_stroke_guide_panel.visible = active
	mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
		if _player_stroke_point_edit_active
		else Control.CURSOR_CROSS
		if _player_stroke_tool_active or _city_ownership_tool_active
		else Control.CURSOR_ARROW
	)
	_refresh_player_stroke_guide()


func _unhandled_key_input(event: InputEvent) -> void:
	if (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_ESCAPE
		and cancel_character_multiselection()
	):
		get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(event.position, 1.12)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(event.position, 1.0 / 1.12)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			var was_panning := _panning
			_panning = event.pressed
			mouse_default_cursor_shape = Control.CURSOR_DRAG if _panning else (Control.CURSOR_CROSS if _annotation_tool_active else Control.CURSOR_ARROW)
			if _panning:
				_hide_place_hover()
				_pan_layout_dirty = false
				set_process(true)
			elif was_panning and _pan_layout_dirty:
				# 平移期间只移动既有世界层；松手后至多重排一次，避免固定 HUD
				# 与驻城窗口因相机移动重新相交。
				_camera_pan_dirty = false
				_pan_layout_dirty = false
				_apply_camera()
			accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _annotation_tool_active:
				var resolved := screen_to_valid_map_normalized(event.position)
				if bool(resolved.get("valid", false)):
					set_annotation_tool_active(false)
					annotation_create_requested.emit(resolved.get("normalized", Vector2(0.5, 0.5)))
				accept_event()
				return
			var place_index := _find_visible_place_index_at_screen(event.position)
			var context_id := "" if place_index >= 0 else _find_historical_context_id_at_screen(event.position)
			var stroke_id := ""
			if place_index < 0 and context_id.is_empty() and _player_stroke_layer != null:
				stroke_id = _player_stroke_layer.find_stroke_at_world(screen_to_world(event.position), 8.0 / zoom)
			_clear_map_selection()
			_clear_annotation_selection()
			if stroke_id.is_empty():
				_clear_player_stroke_selection()
			if place_index >= 0:
				_hide_place_hover()
				place_details_requested.emit(_place_ids[place_index])
			elif not context_id.is_empty():
				_hide_place_hover()
				historical_context_details_requested.emit(context_id)
			elif not stroke_id.is_empty():
				_hide_place_hover()
				_select_player_stroke(stroke_id)
			accept_event()
	elif event is InputEventMouseMotion:
		if _panning:
			pan += event.relative
			_camera_pan_dirty = true
			_pan_layout_dirty = true
			set_process(true)
			accept_event()
		else:
			if _annotation_tool_active or not _active_annotation_drag_id.is_empty():
				_hide_place_hover()
			else:
				var place_index := _find_visible_place_index_at_screen(event.position)
				if place_index >= 0:
					mouse_default_cursor_shape = Control.CURSOR_ARROW
					_update_place_hover(event.position)
				elif not _find_historical_context_id_at_screen(event.position).is_empty():
					_hide_place_hover()
					mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				else:
					_hide_place_hover()
					mouse_default_cursor_shape = Control.CURSOR_ARROW


func _zoom_at(cursor: Vector2, factor: float) -> void:
	_hide_place_hover()
	var before := screen_to_world(cursor)
	zoom = clampf(zoom * factor, min_zoom, max_zoom)
	pan = cursor - before * zoom
	_apply_camera()
	zoom_changed.emit(zoom)


func screen_to_world(local_position: Vector2) -> Vector2:
	return (local_position - pan) / zoom


func map_normalized_to_world(normalized_position: Vector2) -> Vector2:
	return MAP_CONTENT_RECT.position + normalized_position * MAP_CONTENT_RECT.size


func world_to_map_normalized(world_position: Vector2) -> Vector2:
	return Vector2(
		(world_position.x - MAP_CONTENT_RECT.position.x) / MAP_CONTENT_RECT.size.x,
		(world_position.y - MAP_CONTENT_RECT.position.y) / MAP_CONTENT_RECT.size.y
	)


func screen_to_valid_map_normalized(screen_position: Vector2) -> Dictionary:
	var world_position := screen_to_world(screen_position)
	if not MAP_CONTENT_RECT.has_point(world_position):
		return {"valid": false}
	var normalized := world_to_map_normalized(world_position)
	normalized.x = clampf(normalized.x, 0.0, 1.0)
	normalized.y = clampf(normalized.y, 0.0, 1.0)
	return {"valid": true, "normalized": normalized}


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not _is_valid_backpack_drag_data(data):
		clear_native_drag_feedback()
		return false
	_hide_place_hover()
	_update_native_drag_avoid_rect(at_position, data)
	var world_position := screen_to_world(at_position)
	var valid := MAP_CONTENT_RECT.has_point(world_position)
	if valid and not _is_snap_bypass_active():
		_update_snap_candidate(at_position)
	else:
		clear_native_drag_feedback()
	return valid


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not _is_valid_backpack_drag_data(data):
		clear_native_drag_feedback()
		return
	var world_position := screen_to_world(at_position)
	if not MAP_CONTENT_RECT.has_point(world_position):
		clear_native_drag_feedback()
		return
	_update_native_drag_avoid_rect(at_position, data)
	var character_id := str(data.get("character_id", ""))
	var resolved := _resolve_drop_at_screen(at_position, _is_snap_bypass_active())
	var normalized: Vector2 = resolved.get("normalized", Vector2(0.5, 0.5))
	_last_drop_context = resolved
	_last_drop_context["character_id"] = character_id
	clear_native_drag_feedback()
	character_dropped.emit(character_id, normalized)


func _is_valid_backpack_drag_data(data: Variant) -> bool:
	if not (data is Dictionary):
		return false
	var character_id := str(data.get("character_id", ""))
	return data.get("kind", "") == "character_card" \
		and data.get("source", "") == "backpack" \
		and not character_id.is_empty() \
		and _character_by_id.has(character_id) \
		and not _placements.has(character_id)


func _update_native_drag_avoid_rect(pointer_position: Vector2, data: Dictionary) -> void:
	var preview_size: Variant = data.get("preview_size", CharacterCardScript.BACKPACK_DRAG_PREVIEW_SIZE)
	if not (preview_size is Vector2):
		preview_size = CharacterCardScript.BACKPACK_DRAG_PREVIEW_SIZE
	var bounded_size := Vector2(
		clampf(preview_size.x, 24.0, 180.0),
		clampf(preview_size.y, 20.0, 100.0)
	)
	_native_drag_avoid_rect = Rect2(pointer_position - bounded_size * 0.5, bounded_size)


func clear_native_drag_feedback() -> void:
	_native_drag_avoid_rect = Rect2()
	_clear_snap_candidate()


func _compile_place_targets() -> void:
	_place_world_positions = PackedVector2Array()
	_place_normalized_positions = PackedVector2Array()
	_place_ids = PackedStringArray()
	_place_names = PackedStringArray()
	_place_types = PackedStringArray()
	_place_historical_names = PackedStringArray()
	_place_confidences = PackedStringArray()
	_place_coordinate_bases = PackedStringArray()
	_place_notes = PackedStringArray()
	_place_name_by_id.clear()
	for place in _places:
		var normalized_position := Vector2(float(place.get("x", 0.5)), float(place.get("y", 0.5)))
		var place_id := str(place.get("id", ""))
		var place_name := str(place.get("name", ""))
		_place_world_positions.append(map_normalized_to_world(normalized_position))
		_place_normalized_positions.append(normalized_position)
		_place_ids.append(place_id)
		_place_names.append(place_name)
		_place_types.append(str(place.get("type", "city")))
		_place_historical_names.append(str(place.get("historical_name_190", place_name)))
		_place_confidences.append(str(place.get("confidence", "")) if place.has("coordinate_basis") else "research_reference")
		_place_coordinate_bases.append(str(place.get("coordinate_basis", "")))
		_place_notes.append(_place_hover_summary(place))
		_place_name_by_id[place_id] = place_name
	_hide_place_hover()


func _build_place_hover_panel() -> void:
	_place_hover_panel = PanelContainer.new()
	_place_hover_panel.name = "PlaceHoverPanel"
	_place_hover_panel.custom_minimum_size = PLACE_HOVER_PANEL_SIZE
	_place_hover_panel.size = _place_hover_panel.custom_minimum_size
	_place_hover_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place_hover_panel.z_index = 4000
	var panel_style := UiThemeScript.make_record_panel(
		0.97,
		7,
		Vector4(13, 8, 11, 8)
	)
	_place_hover_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(_place_hover_panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 1)
	_place_hover_panel.add_child(content)

	_place_hover_title = Label.new()
	_place_hover_title.add_theme_font_size_override("font_size", 18)
	_place_hover_title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	content.add_child(_place_hover_title)

	_place_hover_historical = Label.new()
	_place_hover_historical.add_theme_font_size_override("font_size", 13)
	_place_hover_historical.add_theme_color_override("font_color", UiThemeScript.TEXT_HISTORICAL)
	_place_hover_historical.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	content.add_child(_place_hover_historical)

	_place_hover_status = Label.new()
	_place_hover_status.add_theme_font_size_override("font_size", 13)
	_place_hover_status.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	_place_hover_status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	content.add_child(_place_hover_status)

	_place_hover_note = Label.new()
	_place_hover_note.add_theme_font_size_override("font_size", 13)
	_place_hover_note.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	_place_hover_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place_hover_note.max_lines_visible = 2
	_place_hover_note.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	content.add_child(_place_hover_note)
	_place_hover_panel.hide()


func _update_place_hover(anchor_screen: Vector2) -> int:
	if not _active_drag_id.is_empty() or _panning or _place_world_positions.is_empty():
		_hide_place_hover()
		return -1
	var nearest_index := _find_visible_place_index_at_screen(anchor_screen)
	if nearest_index < 0:
		_hide_place_hover()
		return -1
	_show_place_hover(nearest_index, pan + _place_world_positions[nearest_index] * zoom)
	return nearest_index


func _find_visible_place_index_at_screen(anchor_screen: Vector2, radius_screen: float = PLACE_HOVER_RADIUS_SCREEN) -> int:
	if _place_world_positions.is_empty():
		return -1
	var nearest_index := -1
	var nearest_distance_squared := INF
	for index in range(_place_world_positions.size()):
		if _canvas != null and not _canvas.is_place_visible(_place_ids[index]):
			continue
		var place_screen := pan + _place_world_positions[index] * zoom
		var distance_squared := anchor_screen.distance_squared_to(place_screen)
		if distance_squared < nearest_distance_squared:
			nearest_distance_squared = distance_squared
			nearest_index = index
	if nearest_index < 0 or nearest_distance_squared > radius_screen * radius_screen:
		return -1
	return nearest_index


func get_place_screen_position(place_id: String) -> Vector2:
	var index := _place_ids.find(place_id)
	if index < 0 or index >= _place_world_positions.size():
		return Vector2(-1.0, -1.0)
	return pan + _place_world_positions[index] * zoom


func _find_place_relation_route_index(source_id: String, target_id: String) -> int:
	if source_id.is_empty() or target_id.is_empty() or source_id == target_id:
		return -1
	if _place_ids.find(source_id) < 0 or _place_ids.find(target_id) < 0:
		return -1
	for route_index in range(_routes.size()):
		var route_value: Variant = _routes[route_index]
		if not (route_value is Dictionary):
			continue
		var route: Dictionary = route_value
		var from_id := str(route.get("from", ""))
		var to_id := str(route.get("to", ""))
		if (from_id == source_id and to_id == target_id) or (from_id == target_id and to_id == source_id):
			return route_index
	return -1


func _revalidate_place_relation_context() -> void:
	if _place_relation_source_id.is_empty() or _place_relation_neighbor_ids.is_empty():
		if (
			not _place_relation_source_id.is_empty()
			or not _place_relation_neighbor_ids.is_empty()
			or not _place_relation_target_id.is_empty()
			or not _place_relation_hover_target_id.is_empty()
		):
			clear_place_relation_highlight()
		return
	var source_id := _place_relation_source_id
	var neighbor_ids: Array[String] = _place_relation_neighbor_ids.duplicate()
	var committed_target_id := _place_relation_target_id
	var hover_target_id := _place_relation_hover_target_id
	if not set_place_relation_context(source_id, neighbor_ids):
		return
	if not committed_target_id.is_empty() and _place_relation_neighbor_ids.has(committed_target_id):
		set_place_relation_highlight(source_id, committed_target_id)
	if not hover_target_id.is_empty() and _place_relation_neighbor_ids.has(hover_target_id):
		set_place_relation_hover_target(hover_target_id)


func set_place_relation_context(source_id: String, neighbor_ids_value: Array) -> bool:
	var requested_source := source_id.strip_edges()
	if requested_source.is_empty() or _place_ids.find(requested_source) < 0:
		clear_place_relation_highlight()
		return false
	var valid_neighbor_ids: Array[String] = []
	var valid_route_indices: Array[int] = []
	for neighbor_value in neighbor_ids_value:
		var neighbor_id := str(neighbor_value).strip_edges()
		if neighbor_id.is_empty() or neighbor_id == requested_source or valid_neighbor_ids.has(neighbor_id):
			continue
		var route_index := _find_place_relation_route_index(requested_source, neighbor_id)
		if route_index < 0:
			continue
		valid_neighbor_ids.append(neighbor_id)
		valid_route_indices.append(route_index)
	if valid_neighbor_ids.is_empty():
		clear_place_relation_highlight()
		return false
	_place_relation_source_id = requested_source
	_place_relation_neighbor_ids = valid_neighbor_ids
	_place_relation_route_indices = valid_route_indices
	_place_relation_target_id = ""
	_place_relation_route_index = -1
	_place_relation_hover_target_id = ""
	_place_relation_hover_route_index = -1
	if _place_relation_overlay != null:
		_place_relation_overlay.visible = true
		_place_relation_overlay.queue_redraw()
	return true


func set_place_relation_highlight(source_id: String, target_id: String) -> bool:
	var requested_source := source_id.strip_edges()
	var requested_target := target_id.strip_edges()
	var route_index := _find_place_relation_route_index(requested_source, requested_target)
	if route_index < 0:
		clear_place_relation_highlight()
		return false
	if requested_source != _place_relation_source_id or not _place_relation_neighbor_ids.has(requested_target):
		if not set_place_relation_context(requested_source, [requested_target]):
			return false
	_place_relation_source_id = requested_source
	_place_relation_target_id = requested_target
	_place_relation_route_index = route_index
	if _place_relation_overlay != null:
		_place_relation_overlay.visible = true
		_place_relation_overlay.queue_redraw()
	return true


func clear_place_relation_target() -> void:
	_place_relation_target_id = ""
	_place_relation_route_index = -1
	_place_relation_hover_target_id = ""
	_place_relation_hover_route_index = -1
	if _place_relation_overlay != null:
		_place_relation_overlay.visible = not _place_relation_source_id.is_empty() and not _place_relation_neighbor_ids.is_empty()
		_place_relation_overlay.queue_redraw()


func set_place_relation_hover_target(target_id: String) -> bool:
	var requested_target := target_id.strip_edges()
	var neighbor_index := _place_relation_neighbor_ids.find(requested_target)
	if _place_relation_source_id.is_empty() or neighbor_index < 0 or neighbor_index >= _place_relation_route_indices.size():
		return false
	_place_relation_hover_target_id = requested_target
	_place_relation_hover_route_index = _place_relation_route_indices[neighbor_index]
	if _place_relation_overlay != null:
		_place_relation_overlay.visible = true
		_place_relation_overlay.queue_redraw()
	return true


func clear_place_relation_hover_target(target_id: String = "") -> void:
	var requested_target := target_id.strip_edges()
	if not requested_target.is_empty() and requested_target != _place_relation_hover_target_id:
		return
	_place_relation_hover_target_id = ""
	_place_relation_hover_route_index = -1
	if _place_relation_overlay != null and _place_relation_overlay.visible:
		_place_relation_overlay.queue_redraw()


func clear_place_relation_highlight() -> void:
	_place_relation_source_id = ""
	_place_relation_target_id = ""
	_place_relation_route_index = -1
	_place_relation_neighbor_ids.clear()
	_place_relation_route_indices.clear()
	_place_relation_hover_target_id = ""
	_place_relation_hover_route_index = -1
	if _place_relation_overlay != null:
		_place_relation_overlay.visible = false
		_place_relation_overlay.queue_redraw()


func get_place_relation_highlight_state() -> Dictionary:
	var context_active := not _place_relation_source_id.is_empty() and not _place_relation_neighbor_ids.is_empty()
	var committed_active := _place_relation_route_index >= 0 and not _place_relation_target_id.is_empty()
	var display_target_id := _place_relation_hover_target_id if _place_relation_hover_route_index >= 0 else _place_relation_target_id
	var display_route_index := _place_relation_hover_route_index if _place_relation_hover_route_index >= 0 else _place_relation_route_index
	var weak_relations_visible := context_active and zoom >= PLACE_RELATION_CONTEXT_MIN_ZOOM
	var visible_relation_count := _place_relation_route_indices.size() if weak_relations_visible else (1 if display_route_index >= 0 else 0)
	var route_from_id := ""
	var route_to_id := ""
	if _place_relation_route_index >= 0 and _place_relation_route_index < _routes.size():
		var route_value: Variant = _routes[_place_relation_route_index]
		if route_value is Dictionary:
			var route: Dictionary = route_value
			route_from_id = str(route.get("from", ""))
			route_to_id = str(route.get("to", ""))
	return {
		"active": committed_active,
		"context_active": context_active,
		"overlay_visible": _place_relation_overlay != null and _place_relation_overlay.visible,
		"source_id": _place_relation_source_id,
		"target_id": _place_relation_target_id,
		"route_index": _place_relation_route_index,
		"hover_target_id": _place_relation_hover_target_id,
		"display_target_id": display_target_id,
		"display_route_index": display_route_index,
		"neighbor_ids": _place_relation_neighbor_ids.duplicate(),
		"route_indices": _place_relation_route_indices.duplicate(),
		"weak_relations_visible": weak_relations_visible,
		"visible_relation_count": visible_relation_count,
		"context_min_zoom": PLACE_RELATION_CONTEXT_MIN_ZOOM,
		"context_outer_width_screen": PLACE_RELATION_CONTEXT_OUTER_WIDTH_SCREEN,
		"context_inner_width_screen": PLACE_RELATION_CONTEXT_INNER_WIDTH_SCREEN,
		"route_from_id": route_from_id,
		"route_to_id": route_to_id,
		"outer_width_screen": 7.0,
		"inner_width_screen": 3.0,
		"source_radius_screen": PLACE_RELATION_SOURCE_RADIUS_SCREEN,
		"target_radius_screen": PLACE_RELATION_TARGET_RADIUS_SCREEN
	}


func _draw_place_relation_highlight() -> void:
	if _place_relation_overlay == null or not _place_relation_overlay.visible:
		return
	var source_index := _place_ids.find(_place_relation_source_id)
	if source_index < 0:
		return
	var world_per_screen := 1.0 / maxf(zoom, 0.001)
	if zoom >= PLACE_RELATION_CONTEXT_MIN_ZOOM:
		for route_index in _place_relation_route_indices:
			var weak_points := _place_relation_route_points(route_index)
			if weak_points.size() < 2:
				continue
			_place_relation_overlay.draw_polyline(weak_points, Color(0.31, 0.23, 0.13, 0.24), PLACE_RELATION_CONTEXT_OUTER_WIDTH_SCREEN * world_per_screen, true)
			_place_relation_overlay.draw_polyline(weak_points, Color(0.69, 0.49, 0.15, 0.42), PLACE_RELATION_CONTEXT_INNER_WIDTH_SCREEN * world_per_screen, true)
	var display_target_id := _place_relation_hover_target_id if _place_relation_hover_route_index >= 0 else _place_relation_target_id
	var display_route_index := _place_relation_hover_route_index if _place_relation_hover_route_index >= 0 else _place_relation_route_index
	if display_route_index >= 0:
		var strong_points := _place_relation_route_points(display_route_index)
		if strong_points.size() >= 2:
			_place_relation_overlay.draw_polyline(strong_points, Color(0.31, 0.23, 0.13, 0.72), 7.0 * world_per_screen, true)
			_place_relation_overlay.draw_polyline(strong_points, Color(0.69, 0.49, 0.15, 0.96), 3.0 * world_per_screen, true)
			_place_relation_overlay.draw_polyline(strong_points, Color(1.0, 0.94, 0.78, 0.30), 1.0 * world_per_screen, true)
	var source_world := _place_world_positions[source_index]
	var source_radius := PLACE_RELATION_SOURCE_RADIUS_SCREEN * world_per_screen
	_place_relation_overlay.draw_circle(source_world, source_radius, Color(0.31, 0.23, 0.13, 0.14))
	_place_relation_overlay.draw_arc(source_world, source_radius, 0.0, TAU, 40, Color(0.31, 0.23, 0.13, 0.92), 2.5 * world_per_screen, true)
	_place_relation_overlay.draw_arc(source_world, source_radius - 4.0 * world_per_screen, 0.0, TAU, 36, Color(1.0, 0.94, 0.78, 0.72), 1.0 * world_per_screen, true)
	var target_index := _place_ids.find(display_target_id)
	if target_index < 0:
		return
	var target_world := _place_world_positions[target_index]
	var target_radius := PLACE_RELATION_TARGET_RADIUS_SCREEN * world_per_screen
	_place_relation_overlay.draw_circle(target_world, target_radius, Color(0.69, 0.49, 0.15, 0.18))
	_place_relation_overlay.draw_arc(target_world, target_radius, 0.0, TAU, 48, Color(0.69, 0.49, 0.15, 0.98), 3.0 * world_per_screen, true)
	_place_relation_overlay.draw_arc(target_world, target_radius - 5.0 * world_per_screen, 0.0, TAU, 40, Color(1.0, 0.94, 0.78, 0.86), 1.2 * world_per_screen, true)
	_place_relation_overlay.draw_circle(target_world, 3.0 * world_per_screen, Color(0.69, 0.49, 0.15, 0.98))


func _place_relation_route_points(route_index: int) -> PackedVector2Array:
	if route_index < 0 or route_index >= _routes.size():
		return PackedVector2Array()
	var route_value: Variant = _routes[route_index]
	if not (route_value is Dictionary):
		return PackedVector2Array()
	var route: Dictionary = route_value
	# 必须按资料中的 from/to 顺序重放；反向浏览时交换端点会让二次曲线弯向另一侧。
	var route_from_index := _place_ids.find(str(route.get("from", "")))
	var route_to_index := _place_ids.find(str(route.get("to", "")))
	if route_from_index < 0 or route_to_index < 0:
		return PackedVector2Array()
	return MapCanvasScript.board_route_curve(
		_place_world_positions[route_from_index],
		_place_world_positions[route_to_index],
		route_index
	)


func set_scenario_preview_highlight(record: Dictionary) -> void:
	_scenario_preview_faction_id = str(record.get("id", ""))
	_scenario_preview_faction_name = str(record.get("name", _scenario_preview_faction_id))
	_scenario_preview_color = Color(str(record.get("color", "#A77B27")))
	_scenario_preview_city_place_ids = _preview_string_array(record.get("city_place_ids", []))
	_scenario_preview_placement_place_ids = _preview_string_array(record.get("placement_place_ids", []))
	_scenario_preview_normalized_positions.clear()
	_scenario_preview_drawn_placement_place_count = 0
	_scenario_preview_drawn_normalized_position_count = 0
	for position_value in record.get("placement_positions", []):
		if position_value is Vector2:
			_scenario_preview_normalized_positions.append(position_value)
		elif position_value is Dictionary:
			var position_record: Dictionary = position_value
			_scenario_preview_normalized_positions.append(Vector2(
				clampf(float(position_record.get("x", 0.5)), 0.0, 1.0),
				clampf(float(position_record.get("y", 0.5)), 0.0, 1.0)
			))
	var has_targets := (
		not _scenario_preview_city_place_ids.is_empty()
		or not _scenario_preview_placement_place_ids.is_empty()
		or not _scenario_preview_normalized_positions.is_empty()
	)
	if _scenario_preview_overlay != null:
		_scenario_preview_overlay.visible = has_targets
		_scenario_preview_overlay.queue_redraw()


func clear_scenario_preview_highlight() -> void:
	_scenario_preview_faction_id = ""
	_scenario_preview_faction_name = ""
	_scenario_preview_city_place_ids.clear()
	_scenario_preview_placement_place_ids.clear()
	_scenario_preview_normalized_positions.clear()
	_scenario_preview_drawn_placement_place_count = 0
	_scenario_preview_drawn_normalized_position_count = 0
	if _scenario_preview_overlay != null:
		_scenario_preview_overlay.visible = false
		_scenario_preview_overlay.queue_redraw()


func get_scenario_preview_highlight_state() -> Dictionary:
	return {
		"active": _scenario_preview_overlay != null and _scenario_preview_overlay.visible,
		"faction_id": _scenario_preview_faction_id,
		"faction_name": _scenario_preview_faction_name,
		"color": _scenario_preview_color.to_html(false),
		"city_place_ids": _scenario_preview_city_place_ids.duplicate(),
		"placement_place_ids": _scenario_preview_placement_place_ids.duplicate(),
		"placement_positions": _scenario_preview_normalized_positions.duplicate(),
		"drawn_placement_place_count": _scenario_preview_drawn_placement_place_count,
		"drawn_normalized_position_count": _scenario_preview_drawn_normalized_position_count,
	}


func _preview_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			var text := str(item).strip_edges()
			if not text.is_empty() and text not in result:
				result.append(text)
	return result


func _draw_scenario_preview_highlight() -> void:
	_scenario_preview_drawn_placement_place_count = 0
	_scenario_preview_drawn_normalized_position_count = 0
	if _scenario_preview_overlay == null or not _scenario_preview_overlay.visible:
		return
	var fill := Color(_scenario_preview_color, 0.18)
	var line := Color(_scenario_preview_color, 0.94)
	var inner := Color(1.0, 0.97, 0.84, 0.96)
	for place_id in _scenario_preview_city_place_ids:
		var screen_position := get_place_screen_position(place_id)
		if screen_position.x < 0.0:
			continue
		_scenario_preview_overlay.draw_circle(screen_position, SCENARIO_PREVIEW_CITY_RADIUS_SCREEN, fill)
		_scenario_preview_overlay.draw_arc(screen_position, SCENARIO_PREVIEW_CITY_RADIUS_SCREEN, 0.0, TAU, 40, line, 2.5, true)
	for place_id in _scenario_preview_placement_place_ids:
		var screen_position := get_place_screen_position(place_id)
		if screen_position.x < 0.0:
			continue
		_scenario_preview_overlay.draw_circle(screen_position, SCENARIO_PREVIEW_PLACEMENT_RADIUS_SCREEN + 3.0, Color(_scenario_preview_color, 0.24))
		_scenario_preview_overlay.draw_circle(screen_position, SCENARIO_PREVIEW_PLACEMENT_RADIUS_SCREEN, inner)
		_scenario_preview_overlay.draw_arc(screen_position, SCENARIO_PREVIEW_PLACEMENT_RADIUS_SCREEN, 0.0, TAU, 28, line, 2.0, true)
		_scenario_preview_drawn_placement_place_count += 1
	for normalized_position in _scenario_preview_normalized_positions:
		var world_position := MAP_CONTENT_RECT.position + normalized_position * MAP_CONTENT_RECT.size
		var screen_position := pan + world_position * zoom
		_scenario_preview_overlay.draw_circle(screen_position, SCENARIO_PREVIEW_PLACEMENT_RADIUS_SCREEN, inner)
		_scenario_preview_overlay.draw_arc(screen_position, SCENARIO_PREVIEW_PLACEMENT_RADIUS_SCREEN, 0.0, TAU, 28, line, 2.0, true)
		_scenario_preview_drawn_normalized_position_count += 1


func set_faction_inspection_highlight(faction_id: String) -> bool:
	var requested_id := faction_id.strip_edges()
	if requested_id.is_empty() or not _faction_name_by_id.has(requested_id):
		clear_faction_inspection_highlight()
		return false
	_faction_inspection_id = requested_id
	_refresh_faction_inspection_highlight()
	return _faction_inspection_overlay != null and _faction_inspection_overlay.visible


func clear_faction_inspection_highlight() -> void:
	_faction_inspection_id = ""
	_faction_inspection_name = ""
	_faction_inspection_city_place_ids.clear()
	_faction_inspection_character_ids.clear()
	if _faction_inspection_overlay != null:
		_faction_inspection_overlay.visible = false
		_faction_inspection_overlay.queue_redraw()


func _refresh_faction_inspection_highlight() -> void:
	if _faction_inspection_id.is_empty():
		return
	if not _faction_name_by_id.has(_faction_inspection_id):
		clear_faction_inspection_highlight()
		return
	_faction_inspection_name = str(_faction_name_by_id.get(_faction_inspection_id, _faction_inspection_id))
	_faction_inspection_color = FactionPaletteScript.to_color(
		_faction_color_by_id.get(_faction_inspection_id, FactionPaletteScript.UNASSIGNED_HEX)
	)
	_faction_inspection_city_place_ids.clear()
	for ownership_value in _scenario_state.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			continue
		var ownership: Dictionary = ownership_value
		if str(ownership.get("faction_id", "")) != _faction_inspection_id:
			continue
		var place_id := str(ownership.get("place_id", "")).strip_edges()
		if not place_id.is_empty() and place_id not in _faction_inspection_city_place_ids:
			_faction_inspection_city_place_ids.append(place_id)
	_faction_inspection_character_ids.clear()
	for assignment_value in _scenario_state.get("character_assignments", []):
		if not (assignment_value is Dictionary):
			continue
		var assignment: Dictionary = assignment_value
		if str(assignment.get("faction_id", "")) != _faction_inspection_id:
			continue
		var character_id := str(assignment.get("character_id", "")).strip_edges()
		if _placements.has(character_id) and character_id not in _faction_inspection_character_ids:
			_faction_inspection_character_ids.append(character_id)
	var has_targets := not _faction_inspection_city_place_ids.is_empty() or not _faction_inspection_character_ids.is_empty()
	if _faction_inspection_overlay != null:
		_faction_inspection_overlay.visible = has_targets
		_faction_inspection_overlay.queue_redraw()


func get_faction_inspection_highlight_state() -> Dictionary:
	return {
		"active": _faction_inspection_overlay != null and _faction_inspection_overlay.visible,
		"faction_id": _faction_inspection_id,
		"faction_name": _faction_inspection_name,
		"color": _faction_inspection_color.to_html(false),
		"city_place_ids": _faction_inspection_city_place_ids.duplicate(),
		"character_ids": _faction_inspection_character_ids.duplicate()
	}


func _draw_faction_inspection_highlight() -> void:
	if _faction_inspection_overlay == null or not _faction_inspection_overlay.visible:
		return
	var fill := Color(_faction_inspection_color, 0.20)
	var line := Color(_faction_inspection_color, 0.98)
	var inner := Color(1.0, 0.96, 0.78, 0.96)
	for place_id in _faction_inspection_city_place_ids:
		var screen_position := get_place_screen_position(place_id)
		if screen_position.x < 0.0:
			continue
		_faction_inspection_overlay.draw_circle(screen_position, FACTION_INSPECTION_CITY_RADIUS_SCREEN, fill)
		_faction_inspection_overlay.draw_arc(screen_position, FACTION_INSPECTION_CITY_RADIUS_SCREEN, 0.0, TAU, 48, line, 3.0, true)
		_faction_inspection_overlay.draw_arc(screen_position, FACTION_INSPECTION_CITY_RADIUS_SCREEN - 5.0, 0.0, TAU, 40, inner, 1.0, true)
	for character_id in _faction_inspection_character_ids:
		if not _card_by_id.has(character_id) or not _placements.has(character_id):
			continue
		var card: CharacterCard = _card_by_id[character_id]
		if not card.visible:
			var hidden_placement: Dictionary = _placements[character_id]
			var hidden_world := map_normalized_to_world(Vector2(
				float(hidden_placement.get("x", 0.5)),
				float(hidden_placement.get("y", 0.5))
			))
			var hidden_screen := pan + hidden_world * zoom
			_faction_inspection_overlay.draw_circle(hidden_screen, 10.0, fill)
			_faction_inspection_overlay.draw_arc(hidden_screen, 10.0, 0.0, TAU, 32, line, 2.0, true)
			continue
		var card_size := _map_card_screen_size(card)
		var card_center := _map_card_screen_center(card, _screen_marker_scale())
		var card_rect := Rect2(card_center - card_size * 0.5, card_size).grow(FACTION_INSPECTION_CARD_MARGIN_SCREEN)
		_faction_inspection_overlay.draw_rect(card_rect, fill, true)
		_faction_inspection_overlay.draw_rect(card_rect, line, false, 3.0, true)
func focus_place(place_id: String) -> bool:
	var index := _place_ids.find(place_id)
	if index < 0 or index >= _place_world_positions.size():
		return false
	set_annotation_tool_active(false)
	set_player_stroke_tool_active(false)
	_hide_place_hover()
	_clear_snap_candidate()
	var world_center := _place_world_positions[index]
	return _focus_world_point(world_center)


func get_place_focus_camera_state(place_id: String, screen_anchor := Vector2(0.5, 0.5)) -> Dictionary:
	var index := _place_ids.find(place_id)
	if index < 0 or index >= _place_world_positions.size():
		return {}
	return get_focus_camera_state(_place_world_positions[index], screen_anchor)


func get_focus_camera_state(world_focus: Vector2, screen_anchor := Vector2(0.5, 0.5)) -> Dictionary:
	return MapPresentationPolicyScript.build_focus_state(
		size,
		MAP_CONTENT_RECT,
		world_focus,
		zoom,
		screen_anchor
	)


func _focus_world_point(world_focus: Vector2, screen_anchor := Vector2(0.5, 0.5)) -> bool:
	var state := get_focus_camera_state(world_focus, screen_anchor)
	if not bool(state.get("ok", false)):
		return false
	pan = Vector2(float(state.get("x", pan.x)), float(state.get("y", pan.y)))
	_camera_initialized = true
	_apply_camera()
	return true


func get_place_group_camera_state(
	place_ids: Array,
	requested_zoom: float,
	screen_anchor := Vector2(0.5, 0.5)
) -> Dictionary:
	# 为开局等只读预设计算一组地点的镜头，不直接改变当前画面。
	if size.x < 10.0 or size.y < 10.0:
		return get_camera_state()
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	var found := false
	for place_id_value in place_ids:
		var index := _place_ids.find(str(place_id_value))
		if index < 0 or index >= _place_world_positions.size():
			continue
		var world_position: Vector2 = _place_world_positions[index]
		minimum.x = minf(minimum.x, world_position.x)
		minimum.y = minf(minimum.y, world_position.y)
		maximum.x = maxf(maximum.x, world_position.x)
		maximum.y = maxf(maximum.y, world_position.y)
		found = true
	if not found:
		return get_home_camera_state(HOME_HAN_THEATER)
	var target_zoom := clampf(requested_zoom, min_zoom, max_zoom)
	var anchor_ratio := Vector2(
		clampf(screen_anchor.x, 0.1, 0.9),
		clampf(screen_anchor.y, 0.1, 0.9)
	)
	var group_center := (minimum + maximum) * 0.5
	return MapPresentationPolicyScript.build_focus_state(
		size,
		MAP_CONTENT_RECT,
		group_center,
		target_zoom,
		anchor_ratio
	)


func _find_historical_context_id_at_screen(screen_position: Vector2) -> String:
	if not _has_visible_historical_context_layer() or _canvas == null:
		return ""
	return _canvas.find_historical_context_at_world(screen_to_world(screen_position))


func get_historical_context_tag_rects_screen() -> Dictionary:
	var result := {}
	if not _has_visible_historical_context_layer() or _canvas == null:
		return result
	var world_rects: Dictionary = _canvas.get_historical_context_tag_rects_world()
	for context_id in world_rects:
		var world_rect: Rect2 = world_rects[context_id]
		result[str(context_id)] = Rect2(pan + world_rect.position * zoom, world_rect.size * zoom)
	return result


func _show_place_hover(index: int, place_screen: Vector2) -> void:
	if _place_hover_panel == null or index < 0 or index >= _place_ids.size():
		return
	_hover_place_index = index
	_place_hover_title.text = _place_names[index]
	_place_hover_historical.text = _place_historical_names[index]
	_place_hover_status.text = "%s · 单击札记" % _place_type_text(_place_types[index])
	_place_hover_note.text = _place_notes[index]
	var panel_size := PLACE_HOVER_PANEL_SIZE
	var target := place_screen + Vector2.ONE * PLACE_HOVER_PANEL_GAP_SCREEN
	if target.x + panel_size.x > size.x - PLACE_HOVER_PANEL_MARGIN_SCREEN:
		target.x = place_screen.x - panel_size.x - PLACE_HOVER_PANEL_GAP_SCREEN
	if target.y + panel_size.y > size.y - PLACE_HOVER_PANEL_MARGIN_SCREEN:
		target.y = place_screen.y - panel_size.y - PLACE_HOVER_PANEL_GAP_SCREEN
	target.x = clampf(target.x, PLACE_HOVER_PANEL_MARGIN_SCREEN, maxf(PLACE_HOVER_PANEL_MARGIN_SCREEN, size.x - panel_size.x - PLACE_HOVER_PANEL_MARGIN_SCREEN))
	target.y = clampf(target.y, PLACE_HOVER_PANEL_MARGIN_SCREEN, maxf(PLACE_HOVER_PANEL_MARGIN_SCREEN, size.y - panel_size.y - PLACE_HOVER_PANEL_MARGIN_SCREEN))
	_place_hover_panel.position = target
	_place_hover_panel.show()


func _hide_place_hover() -> void:
	_hover_place_index = -1
	if _place_hover_panel != null:
		_place_hover_panel.hide()


func _place_hover_summary(place: Dictionary) -> String:
	var explicit_summary := str(place.get("hover_note", "")).strip_edges()
	if not explicit_summary.is_empty():
		return explicit_summary
	var place_type := str(place.get("type", "city"))
	match place_type:
		"capital":
			return "汉末重要都城，可用于朝廷、人物与势力局势推演。"
		"pass":
			return "战略关隘，可用于驻守、通道控制与进军推演。"
		"water_gate", "ferry", "port":
			return "水陆交通节点，可用于集结、支援与进军推演。"
		"battlefield":
			return "历史战场区域，可用于集结、对峙与战役推演。"
		_:
			return "汉末城池，可用于人物驻扎、势力集结与局势推演。"


func _place_type_text(place_type: String) -> String:
	match place_type:
		"capital":
			return "都城"
		"port":
			return "港口"
		"pass":
			return "关隘"
		"ferry":
			return "渡口"
		"water_gate":
			return "水路要冲"
		"battlefield":
			return "战场区域"
		_:
			return "城池"


func _update_snap_candidate(anchor_screen: Vector2) -> int:
	if _place_world_positions.is_empty():
		_clear_snap_candidate()
		return -1
	var nearest_index := -1
	var nearest_distance_squared := INF
	for index in range(_place_world_positions.size()):
		if _canvas != null and not _canvas.is_place_visible(_place_ids[index]):
			continue
		var place_screen := pan + _place_world_positions[index] * zoom
		var distance_squared := anchor_screen.distance_squared_to(place_screen)
		if distance_squared < nearest_distance_squared:
			nearest_distance_squared = distance_squared
			nearest_index = index
	if _snap_candidate_index >= 0 and _snap_candidate_index < _place_world_positions.size():
		var current_id := _place_ids[_snap_candidate_index]
		var current_screen := pan + _place_world_positions[_snap_candidate_index] * zoom
		var current_distance := anchor_screen.distance_to(current_screen)
		var current_visible := _canvas == null or _canvas.is_place_visible(current_id)
		if current_visible and current_distance <= SNAP_EXIT_RADIUS_SCREEN:
			if nearest_index >= 0 and nearest_index != _snap_candidate_index:
				var nearest_distance := sqrt(nearest_distance_squared)
				if nearest_distance <= SNAP_ENTER_RADIUS_SCREEN and nearest_distance + SNAP_SWITCH_ADVANTAGE_SCREEN < current_distance:
					_show_snap_candidate(nearest_index, pan + _place_world_positions[nearest_index] * zoom)
					return nearest_index
			_show_snap_candidate(_snap_candidate_index, current_screen)
			return _snap_candidate_index
	if nearest_index >= 0 and nearest_distance_squared <= SNAP_ENTER_RADIUS_SCREEN * SNAP_ENTER_RADIUS_SCREEN:
		_show_snap_candidate(nearest_index, pan + _place_world_positions[nearest_index] * zoom)
		return nearest_index
	_clear_snap_candidate()
	return -1


func _show_snap_candidate(index: int, screen_position: Vector2) -> void:
	_snap_candidate_index = index
	if _placement_guide != null:
		var avoid_rect := _active_drag_card_screen_rect()
		if not avoid_rect.has_area():
			avoid_rect = _native_drag_avoid_rect
		_placement_guide.show_target(screen_position, _place_names[index], avoid_rect)


func _clear_snap_candidate() -> void:
	_snap_candidate_index = -1
	if _placement_guide != null:
		_placement_guide.hide_target()


func _drag_pointer_screen() -> Vector2:
	return _drag_pointer_override_screen if _drag_pointer_override_enabled else get_local_mouse_position()


func _is_snap_bypass_active() -> bool:
	if _drag_pointer_override_enabled:
		return _drag_snap_bypass_override_value if _drag_snap_bypass_override_enabled else false
	return Input.is_key_pressed(KEY_ALT)


func _active_drag_card_screen_rect() -> Rect2:
	if _active_drag_id.is_empty() or not _card_by_id.has(_active_drag_id):
		return Rect2()
	var result := Rect2()
	var has_rect := false
	for dragged_id in _active_drag_ids:
		if not _card_by_id.has(dragged_id):
			continue
		var card: CharacterCard = _card_by_id[dragged_id]
		var card_rect := Rect2(card.position, card.size * card.scale)
		result = result.merge(card_rect) if has_rect else card_rect
		has_rect = true
	return result


func begin_drag_benchmark(character_id: String, screen_center: Vector2) -> bool:
	if not _card_by_id.has(character_id) or not _active_drag_id.is_empty():
		return false
	var card: CharacterCard = _card_by_id[character_id]
	_drag_pointer_override_enabled = true
	_drag_pointer_override_screen = screen_center
	_on_map_card_drag_started(character_id, card.size * 0.5)
	var started := _active_drag_id == character_id
	if not started:
		_drag_pointer_override_enabled = false
	return started


func set_drag_benchmark_pointer(screen_center: Vector2) -> void:
	if not _drag_pointer_override_enabled or _active_drag_id.is_empty():
		return
	_drag_pointer_override_screen = screen_center


func set_drag_benchmark_snap_bypass(enabled: bool) -> void:
	if not _drag_pointer_override_enabled or _active_drag_id.is_empty():
		return
	_drag_snap_bypass_override_enabled = true
	_drag_snap_bypass_override_value = enabled
	_update_active_drag_position()


func get_drag_benchmark_state() -> Dictionary:
	var candidate_id := ""
	if _snap_candidate_index >= 0 and _snap_candidate_index < _place_ids.size():
		candidate_id = _place_ids[_snap_candidate_index]
	return {
		"active": not _active_drag_id.is_empty(),
		"character_id": _active_drag_id,
		"character_ids": _active_drag_ids.duplicate(),
		"group_count": _active_drag_ids.size(),
		"snap_bypassed": _is_snap_bypass_active(),
		"candidate_id": candidate_id,
		"guide": _placement_guide.get_layout_contract() if _placement_guide != null else {}
	}


func get_native_drag_feedback_state() -> Dictionary:
	var candidate_id := ""
	if _snap_candidate_index >= 0 and _snap_candidate_index < _place_ids.size():
		candidate_id = _place_ids[_snap_candidate_index]
	return {
		"candidate_id": candidate_id,
		"snap_bypassed": _is_snap_bypass_active(),
		"avoid_rect": _native_drag_avoid_rect,
		"guide": _placement_guide.get_layout_contract() if _placement_guide != null else {}
	}


func finish_drag_benchmark() -> Dictionary:
	if _active_drag_id.is_empty() or not _card_by_id.has(_active_drag_id):
		_drag_pointer_override_enabled = false
		return {}
	var dragged_ids := _active_drag_ids.duplicate()
	_last_drag_stats = _build_drag_stats()
	_active_drag_id = ""
	_active_drag_ids.clear()
	_active_drag_screen_offsets_by_id.clear()
	_active_group_drag_layout_offsets_by_id.clear()
	_drag_pointer_override_enabled = false
	_drag_snap_bypass_override_enabled = false
	_drag_snap_bypass_override_value = false
	_clear_snap_candidate()
	for dragged_id in dragged_ids:
		if not _card_by_id.has(dragged_id):
			continue
		var card: CharacterCard = _card_by_id[dragged_id]
		card.reparent(_world_layer)
		_raise_card_base_order(str(dragged_id), false)
	_refresh_character_attention_presentation()
	if _active_annotation_drag_id.is_empty() and not _panning and not _camera_pan_dirty:
		set_process(false)
	for dragged_id in dragged_ids:
		_layout_card(dragged_id)
	return _last_drag_stats.duplicate()


func _resolve_drop_at_screen(anchor_screen: Vector2, snap_bypassed: bool = false) -> Dictionary:
	var world_position := screen_to_world(anchor_screen)
	world_position.x = clampf(world_position.x, MAP_CONTENT_RECT.position.x + 20.0, MAP_CONTENT_RECT.end.x - 20.0)
	world_position.y = clampf(world_position.y, MAP_CONTENT_RECT.position.y + 20.0, MAP_CONTENT_RECT.end.y - 20.0)
	if snap_bypassed:
		_clear_snap_candidate()
		return {
			"normalized": world_to_map_normalized(world_position),
			"snapped": false,
			"snap_bypassed": true,
			"place_id": "",
			"place_name": ""
		}
	var candidate_index := _update_snap_candidate(anchor_screen)
	if candidate_index >= 0:
		return {
			"normalized": world_to_map_normalized(_place_world_positions[candidate_index]),
			"snapped": true,
			"snap_bypassed": false,
			"place_id": _place_ids[candidate_index],
			"place_name": _place_names[candidate_index]
		}
	return {
		"normalized": world_to_map_normalized(world_position),
		"snapped": false,
		"snap_bypassed": false,
		"place_id": "",
		"place_name": ""
	}


func take_last_drop_context(character_id: String) -> Dictionary:
	var result: Dictionary = {}
	if str(_last_drop_context.get("character_id", "")) == character_id:
		result = _last_drop_context.duplicate(true)
	_last_drop_context.clear()
	return result


func _fit_initial() -> void:
	if _camera_initialized or size.x < 10.0 or size.y < 10.0:
		return
	var home_camera := get_home_camera_state(HOME_HAN_THEATER)
	zoom = float(home_camera.get("zoom", zoom))
	pan = Vector2(float(home_camera.get("x", pan.x)), float(home_camera.get("y", pan.y)))
	_camera_initialized = true
	_apply_camera()
	zoom_changed.emit(zoom)


func focus_home(preset_id := HOME_HAN_THEATER) -> void:
	set_camera_state(get_home_camera_state(preset_id))


func _on_resized() -> void:
	if not _camera_initialized:
		call_deferred("_fit_initial")
	else:
		_queue_place_dock_overlay_refresh()
		# canvas_items stretch 或容器尺寸变化后，地图原点对应的输出像素相位
		# 可能改变；延后一帧重新对齐，避免 300% 时整层被线性采样发软。
		call_deferred("_apply_camera", false)


func _apply_camera(update_card_layout := true) -> void:
	if _world_layer == null:
		return
	var next_city_detail_compact := zoom < CITY_FACTION_COMPACT_ZOOM
	var city_detail_changed := next_city_detail_compact != _city_detail_compact
	if city_detail_changed:
		_city_detail_compact = next_city_detail_compact
		for card_value in _card_by_id.values():
			var card: CharacterCard = card_value
			card.set_map_compact_detail(_city_detail_compact)
		_rebuild_stack_layout()
	else:
		_refresh_city_faction_screen_geometry()
	_render_pan = _pixel_aligned_camera_pan(pan)
	_world_layer.position = pan
	_world_layer.scale = Vector2.ONE * zoom
	_update_cache_clarity()
	if _cached_map_layer != null:
		# 只把离屏缓存对齐到输出像素；人物卡、玩家标记与推演线继续使用
		# 逻辑镜头坐标，避免清晰度优化让释放点和交互对象产生亚像素偏移。
		_cached_map_layer.position = (_render_pan - pan) / zoom
	if _semantic_canvas != null:
		# 实时语义层只保留当前视口附近的绘制命令。缩放／平移会更新裁切，
		# 普通人物拖拽不会重绘，从而避免“全图 41 个地点实时绘制”的旧实验开销。
		_semantic_canvas.set_semantic_visible_world_rect(
			Rect2(-_render_pan / zoom, size / zoom)
		)
	if _faction_influence_layer != null:
		# View-dependent opacity is a cheap TextureRect modulation only. The
		# cached influence wash must not rebuild while the player pans or zooms.
		_faction_influence_layer.set_view_zoom(zoom)
	_layout_faction_identity_markers()
	if _player_stroke_layer != null:
		_player_stroke_layer.set_view_zoom(zoom)
	if _scenario_preview_overlay != null and _scenario_preview_overlay.visible:
		_scenario_preview_overlay.queue_redraw()
	if _faction_inspection_overlay != null and _faction_inspection_overlay.visible:
		_faction_inspection_overlay.queue_redraw()
	if _place_relation_overlay != null and _place_relation_overlay.visible:
		_place_relation_overlay.queue_redraw()
	_queue_place_dock_connectors()
	if _canvas != null and _canvas.set_view_zoom(zoom):
		_request_annotation_cache_rebuild()
	if _semantic_canvas != null:
		_semantic_canvas.set_view_zoom(zoom)
	if update_card_layout:
		_rebuild_place_dock_layout()
		_layout_all_cards()
		_layout_all_annotations()
	_layout_player_stroke_action_panel()


func _pixel_aligned_camera_pan(candidate_pan: Vector2) -> Vector2:
	if not is_inside_tree():
		_render_origin_output_px = candidate_pan
		_render_origin_phase_px = Vector2.ZERO
		return candidate_pan
	var viewport := get_viewport()
	if viewport == null:
		_render_origin_output_px = candidate_pan
		_render_origin_phase_px = Vector2.ZERO
		return candidate_pan
	var local_to_output := viewport.get_final_transform() * get_global_transform_with_canvas()
	if is_zero_approx(local_to_output.determinant()):
		_render_origin_output_px = candidate_pan
		_render_origin_phase_px = Vector2.ZERO
		return candidate_pan
	var output_origin := local_to_output * candidate_pan
	var snapped_output_origin := output_origin.round()
	var aligned_pan := local_to_output.affine_inverse() * snapped_output_origin
	_render_origin_output_px = snapped_output_origin
	_render_origin_phase_px = output_origin - snapped_output_origin
	return aligned_pan


func get_render_alignment_state() -> Dictionary:
	var viewport := get_viewport()
	var local_to_output := Transform2D.IDENTITY
	if viewport != null and is_inside_tree():
		local_to_output = viewport.get_final_transform() * get_global_transform_with_canvas()
	var output_origin := local_to_output * _render_pan
	var render_delta_output := local_to_output.basis_xform(_render_pan - pan)
	var output_scale := Vector2(
		local_to_output.basis_xform(Vector2.RIGHT).length(),
		local_to_output.basis_xform(Vector2.DOWN).length()
	)
	return {
		"mode": "output_pixel_aligned",
		"logical_pan": pan,
		"render_pan": _render_pan,
		"render_delta_output": render_delta_output,
		"render_delta_output_length": render_delta_output.length(),
		"output_origin": output_origin,
		"output_origin_rounded": output_origin.round(),
		"output_phase": output_origin - output_origin.round(),
		"last_pre_snap_phase": _render_origin_phase_px,
		"output_scale": output_scale,
		"max_phase_error": maxf(
			absf(output_origin.x - roundf(output_origin.x)),
			absf(output_origin.y - roundf(output_origin.y))
		)
	}


func get_map_detail_state() -> Dictionary:
	return _canvas.get_annotation_lod_state() if _canvas != null else {}


func get_geographic_context_contract() -> Dictionary:
	if _semantic_canvas != null:
		return _semantic_canvas.get_geographic_context_contract()
	return _canvas.get_geographic_context_contract() if _canvas != null else {}


func get_geographic_annotation_hierarchy_contract() -> Dictionary:
	if _semantic_canvas != null:
		return _semantic_canvas.get_geographic_annotation_hierarchy_contract()
	return _canvas.get_geographic_annotation_hierarchy_contract() if _canvas != null else {}


func get_map_content_rect() -> Rect2:
	return MAP_CONTENT_RECT


func get_camera_state() -> Dictionary:
	return {"x": pan.x, "y": pan.y, "zoom": zoom}


func get_zoom_contract() -> Dictionary:
	return {
		"minimum": min_zoom,
		"maximum": max_zoom,
		"marker_full_scale_zoom": MARKER_FULL_SCALE_ZOOM,
		"deep_near_enabled": max_zoom > MARKER_FULL_SCALE_ZOOM
	}


func get_home_camera_state(preset_id := HOME_WORLD_OVERVIEW) -> Dictionary:
	# 只计算预设视角，不触碰当前相机；事务写盘失败时，画面也能保持原样。
	if size.x < 10.0 or size.y < 10.0:
		return get_camera_state()
	var states := MapPresentationPolicyScript.build_home_states(
		size,
		MAP_CONTENT_RECT,
		WORLD_GEOGRAPHIC_BOUNDS,
		HAN_THEATER_GEOGRAPHIC_BOUNDS,
		HOME_MARGIN_SCREEN,
		Vector2(min_zoom, minf(max_zoom, 1.0))
	)
	if not bool(states.get("ok", false)):
		return get_camera_state()
	var normalized_preset := preset_id if preset_id in [HOME_WORLD_OVERVIEW, HOME_HAN_THEATER] else HOME_WORLD_OVERVIEW
	var state: Dictionary = states.get(normalized_preset, {})
	return {
		"x": float(state.get("x", pan.x)),
		"y": float(state.get("y", pan.y)),
		"zoom": float(state.get("zoom", zoom))
	}


func get_home_preset_contract() -> Dictionary:
	return {
		"default": HOME_HAN_THEATER,
		"presets": [
			{"id": HOME_WORLD_OVERVIEW, "label": "天下全图"},
			{"id": HOME_HAN_THEATER, "label": "汉地战区"}
		],
		"map_geometry_version": 4,
		"content_rect": MAP_CONTENT_RECT,
		"hard_border": false,
		"soft_edge_width": MapCanvasScript.MAP_EDGE_FADE_WIDTH,
		"interaction_rect": MAP_CONTENT_RECT
	}


func get_last_drag_stats() -> Dictionary:
	return _last_drag_stats.duplicate()


func _build_drag_stats() -> Dictionary:
	return calculate_drag_stats(_drag_frame_samples, _drag_update_samples_usec, _drag_total_frames)


func calculate_drag_stats(frame_samples: Array, update_samples_usec: Array, total_frames: int = 0) -> Dictionary:
	var frame_total := 0.0
	var slow_frames := 0
	var severe_frames := 0
	for sample_value in frame_samples:
		var sample := float(sample_value)
		frame_total += sample
		if sample > SLOW_FRAME_SECONDS:
			slow_frames += 1
		if sample > SEVERE_FRAME_SECONDS:
			severe_frames += 1
	var sorted_frames := frame_samples.duplicate()
	sorted_frames.sort()
	var sorted_updates := update_samples_usec.duplicate()
	sorted_updates.sort()
	var sample_count := frame_samples.size()
	return {
		"frames": sample_count,
		"total_frames": total_frames,
		"warmup_frames": mini(DRAG_WARMUP_FRAMES, total_frames),
		"sample_sufficient": sample_count >= DRAG_MIN_REPORT_SAMPLES,
		"average_fps": float(sample_count) / frame_total if frame_total > 0.0 else 0.0,
		"p50_frame_ms": _percentile_sorted(sorted_frames, 0.50) * 1000.0,
		"p95_frame_ms": _percentile_sorted(sorted_frames, 0.95) * 1000.0,
		"p99_frame_ms": _percentile_sorted(sorted_frames, 0.99) * 1000.0,
		"max_frame_ms": _percentile_sorted(sorted_frames, 1.0) * 1000.0,
		"slow_33ms_percent": float(slow_frames) * 100.0 / float(sample_count) if sample_count > 0 else 0.0,
		"severe_50ms_percent": float(severe_frames) * 100.0 / float(sample_count) if sample_count > 0 else 0.0,
		"update_p95_ms": _percentile_sorted(sorted_updates, 0.95) / 1000.0,
		"update_max_ms": _percentile_sorted(sorted_updates, 1.0) / 1000.0
	}


func _percentile_sorted(sorted_values: Array, fraction: float) -> float:
	if sorted_values.is_empty():
		return 0.0
	var index := clampi(ceili(float(sorted_values.size()) * fraction) - 1, 0, sorted_values.size() - 1)
	return float(sorted_values[index])


func _rebuild_static_cache() -> void:
	if _terrain_canvas == null or _terrain_viewport == null:
		return
	_static_cache_builds += 1
	_terrain_canvas.queue_redraw()
	_terrain_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func _request_annotation_cache_rebuild() -> void:
	if _canvas == null or _annotation_viewport == null:
		return
	if _annotation_cache_dirty:
		return
	_annotation_cache_dirty = true
	call_deferred("_flush_annotation_cache_rebuild")


func _flush_annotation_cache_rebuild() -> void:
	_annotation_cache_dirty = false
	if _canvas == null or _annotation_viewport == null:
		return
	_annotation_cache_builds += 1
	_canvas.queue_redraw()
	_annotation_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func get_static_cache_state() -> Dictionary:
	var influence_state := _faction_influence_layer.get_cache_state() if _faction_influence_layer != null else {}
	var semantic_render_contract := _semantic_canvas.get_semantic_render_contract() if _semantic_canvas != null else {}
	var terrain_viewport_size := _terrain_viewport.size if _terrain_viewport != null else Vector2i.ZERO
	var terrain_estimated_bytes := (
		terrain_viewport_size.x
		* terrain_viewport_size.y
		* TERRAIN_CACHE_BYTES_PER_PIXEL
	)
	var annotation_viewport_size := _annotation_viewport.size if _annotation_viewport != null else Vector2i.ZERO
	var annotation_estimated_bytes := (
		annotation_viewport_size.x
		* annotation_viewport_size.y
		* TERRAIN_CACHE_BYTES_PER_PIXEL
	)
	return {
		"viewport_size": terrain_viewport_size,
		"texture_ready": _terrain_texture != null and _terrain_texture.texture != null,
		"terrain_mode": "cached_raster",
		"terrain_cache_scale": TERRAIN_CACHE_SCALE,
		"terrain_estimated_bytes": terrain_estimated_bytes,
		"terrain_pixels_per_screen_at_max": TERRAIN_CACHE_SCALE / MAX_ZOOM,
		"terrain_relief": get_terrain_relief_review_contract(),
		"annotation_mode": "cached_structural_4x_plus_live_semantic_msdf",
		"annotation_cache_scale": ANNOTATION_CACHE_SCALE,
		"annotation_estimated_bytes": annotation_estimated_bytes,
		"annotation_pixels_per_screen_at_max": ANNOTATION_CACHE_SCALE / MAX_ZOOM,
		"declared_map_target_bytes": terrain_estimated_bytes + annotation_estimated_bytes,
		"annotation_texture_ready": _annotation_texture != null and _annotation_texture.texture != null,
		"cache_clarity_model": "bounded_near_zoom_unsharp",
		"cache_clarity_start_zoom": CACHE_CLARITY_START_ZOOM,
		"cache_clarity_full_zoom": CACHE_CLARITY_FULL_ZOOM,
		"cache_clarity_max_amount": CACHE_CLARITY_MAX_AMOUNT,
		"cache_clarity_amount": _cache_clarity_amount,
		"cache_clarity_shared_material": (
			_cache_clarity_material != null
			and _terrain_texture != null
			and _annotation_texture != null
			and _terrain_texture.material == _cache_clarity_material
			and _annotation_texture.material == _cache_clarity_material
		),
		"static_builds": _static_cache_builds,
		"annotation_builds": _annotation_cache_builds,
		"update_mode": _terrain_viewport.render_target_update_mode if _terrain_viewport != null else -1,
		"annotation_update_mode": _annotation_viewport.render_target_update_mode if _annotation_viewport != null else -1,
		"annotation_viewport_size": annotation_viewport_size,
		"annotation_transparent": _annotation_viewport.transparent_bg if _annotation_viewport != null else false,
		"annotation_cache_dirty": _annotation_cache_dirty,
		"base_redraw_count": _terrain_canvas.redraw_count if _terrain_canvas != null else -1,
		"annotation_redraw_count": _canvas.redraw_count if _canvas != null else -1,
		"semantic_redraw_count": _semantic_canvas.redraw_count if _semantic_canvas != null else -1,
		"semantic_live": _semantic_canvas != null and _semantic_canvas.get_parent() == _cached_map_layer,
		"semantic_msdf": true,
		"semantic_render_contract": semantic_render_contract,
		"semantic_world_zoom_cancelled": bool(semantic_render_contract.get("world_zoom_cancelled", false)),
		"semantic_target_size_rasterization": str(semantic_render_contract.get("font_rasterization", "")) == "target_screen_size",
		"semantic_view_culling": _semantic_canvas != null and _semantic_canvas.semantic_visible_world_rect.size.x > 0.0,
		"semantic_visible_world_rect": _semantic_canvas.semantic_visible_world_rect if _semantic_canvas != null else Rect2(),
		"semantic_z_index": _semantic_canvas.z_index if _semantic_canvas != null else -1,
		"faction_identity_z_index": _faction_identity_marker_layer.z_index if _faction_identity_marker_layer != null else -1,
		"lake_count": _terrain_canvas.lake_data.get("lakes", []).size() if _terrain_canvas != null else 0,
		"base_only": _terrain_canvas != null and _terrain_canvas.draw_base_layers and not _terrain_canvas.draw_annotation_layers,
		"annotations_only": _canvas != null and not _canvas.draw_base_layers and _canvas.draw_annotation_layers,
		"structural_cache_only": _canvas != null and _canvas.draw_structural_annotations and not _canvas.draw_semantic_annotations,
		"semantic_live_only": _semantic_canvas != null and not _semantic_canvas.draw_structural_annotations and _semantic_canvas.draw_semantic_annotations,
		"influence": influence_state
	}


func set_faction_influence_visible(value: bool) -> void:
	if _faction_influence_layer != null:
		_faction_influence_layer.set_influence_visible(value)
	if _faction_influence_toggle != null:
		_faction_influence_toggle.set_pressed_no_signal(value)
	if _faction_identity_marker_layer != null:
		_faction_identity_marker_layer.visible = value
	_sync_faction_influence_legend_visibility(value)


func is_faction_influence_visible() -> bool:
	return _faction_influence_layer != null and _faction_influence_layer.is_influence_visible()


func _on_faction_influence_toggled(value: bool) -> void:
	if _faction_influence_layer != null:
		_faction_influence_layer.set_influence_visible(value)
	if _faction_identity_marker_layer != null:
		_faction_identity_marker_layer.visible = value
	_sync_faction_influence_legend_visibility(value)
	faction_influence_visibility_changed.emit(value)


func _faction_identity_marker_state_signature() -> String:
	var parts: Array[String] = []
	for faction_id_value in _faction_order_by_id:
		var faction_id := str(faction_id_value)
		parts.append(
			"f:%s:%d:%s" % [
				faction_id,
				int(_faction_order_by_id.get(faction_id, -1)),
				str(_faction_color_by_id.get(faction_id, ""))
			]
		)
	for ownership_value in _scenario_state.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			continue
		var ownership: Dictionary = ownership_value
		parts.append(
			"o:%s:%s" % [
				str(ownership.get("place_id", "")).strip_edges(),
				str(ownership.get("faction_id", "")).strip_edges()
			]
		)
	parts.sort()
	return "|".join(parts)


func _rebuild_faction_identity_markers(force := false) -> void:
	if _faction_identity_marker_layer == null:
		return
	var next_signature := _faction_identity_marker_state_signature()
	if not force and next_signature == _faction_identity_marker_signature:
		_faction_identity_marker_layer.visible = is_faction_influence_visible()
		_layout_faction_identity_markers()
		return
	_faction_identity_marker_signature = next_signature
	_faction_identity_marker_rebuilds += 1
	for child in _faction_identity_marker_layer.get_children():
		_faction_identity_marker_layer.remove_child(child)
		child.queue_free()
	_faction_identity_marker_by_place.clear()
	var place_position_by_id: Dictionary = {}
	for index in range(_place_ids.size()):
		place_position_by_id[str(_place_ids[index])] = _place_world_positions[index]
	for ownership_value in _scenario_state.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			continue
		var ownership: Dictionary = ownership_value
		var place_id := str(ownership.get("place_id", "")).strip_edges()
		var faction_id := str(ownership.get("faction_id", "")).strip_edges()
		if place_id.is_empty() or _faction_identity_marker_by_place.has(place_id) \
			or not place_position_by_id.has(place_id) or not _faction_order_by_id.has(faction_id):
			continue
		var marker = FactionIdentityMarkerScript.new()
		marker.name = "FactionIdentity_%s" % place_id
		marker.setup(
			faction_id,
			str(int(_faction_order_by_id.get(faction_id, -1)) + 1),
			FactionPaletteScript.to_color(_faction_color_by_id.get(faction_id, FactionPaletteScript.UNASSIGNED_HEX))
		)
		marker.set_meta("place_id", place_id)
		marker.set_meta("world_position", place_position_by_id[place_id])
		_faction_identity_marker_layer.add_child(marker)
		_faction_identity_marker_by_place[place_id] = marker
	_faction_identity_marker_layer.visible = is_faction_influence_visible()
	_layout_faction_identity_markers()


func _layout_faction_identity_markers() -> void:
	if _faction_identity_marker_layer == null or zoom <= 0.0:
		return
	var inverse_zoom := 1.0 / zoom
	for place_id_value in _faction_identity_marker_by_place:
		var place_id := str(place_id_value)
		var marker: Control = _faction_identity_marker_by_place[place_id]
		var world_position: Vector2 = marker.get_meta("world_position", Vector2.ZERO)
		marker.scale = Vector2.ONE * inverse_zoom
		marker.position = world_position + (
			FACTION_IDENTITY_MARKER_OFFSET_SCREEN
			- FactionIdentityMarkerScript.MARKER_SIZE * 0.5
		) * inverse_zoom


func get_faction_identity_marker_state() -> Dictionary:
	var markers: Array[Dictionary] = []
	for place_id_value in _faction_identity_marker_by_place:
		var place_id := str(place_id_value)
		var marker = _faction_identity_marker_by_place[place_id]
		markers.append({
			"place_id": place_id,
			"faction_id": str(marker.faction_id),
			"marker": str(marker.marker_text),
			"screen_size": FactionIdentityMarkerScript.MARKER_SIZE,
			"scale": marker.scale
		})
	markers.sort_custom(func(first: Dictionary, second: Dictionary): return str(first.get("place_id", "")) < str(second.get("place_id", "")))
	return {
		"visible": _faction_identity_marker_layer != null and _faction_identity_marker_layer.visible,
		"count": markers.size(),
		"markers": markers,
		"rebuild_count": _faction_identity_marker_rebuilds,
		"signature": _faction_identity_marker_signature
	}


func _build_faction_influence_legend() -> void:
	_faction_influence_legend_panel = PanelContainer.new()
	_faction_influence_legend_panel.name = "FactionInfluenceLegend"
	_faction_influence_legend_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_faction_influence_legend_panel.position = Vector2(-202, 182)
	_faction_influence_legend_panel.custom_minimum_size = Vector2(184, 0)
	_faction_influence_legend_panel.z_index = 3000
	_faction_influence_legend_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_faction_influence_legend_panel.tooltip_text = "编号、名称和颜色对应当前沙盘的全部势力；右侧显示本局归属城池数"
	_faction_influence_legend_panel.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_floating_tool_panel(0.98, 3, Vector4(8, 7, 8, 7))
	)
	add_child(_faction_influence_legend_panel)

	var content := VBoxContainer.new()
	content.name = "LegendContent"
	content.mouse_filter = Control.MOUSE_FILTER_STOP
	content.add_theme_constant_override("separation", 4)
	_faction_influence_legend_panel.add_child(content)

	_faction_influence_legend_title = Button.new()
	_faction_influence_legend_title.flat = true
	_faction_influence_legend_title.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_faction_influence_legend_title.custom_minimum_size.y = 32
	_faction_influence_legend_title.focus_mode = Control.FOCUS_ALL
	_faction_influence_legend_title.pressed.connect(func() -> void:
		set_faction_legend_collapsed(not _faction_influence_legend_collapsed)
	)
	_faction_influence_legend_title.name = "LegendTitle"
	_faction_influence_legend_title.text = "势力图例"
	_faction_influence_legend_title.mouse_filter = Control.MOUSE_FILTER_STOP
	_faction_influence_legend_title.add_theme_font_size_override("font_size", 14)
	_faction_influence_legend_title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	content.add_child(_faction_influence_legend_title)

	_faction_influence_legend_rows_host = VBoxContainer.new()
	_faction_influence_legend_rows_host.name = "LegendRows"
	_faction_influence_legend_rows_host.mouse_filter = Control.MOUSE_FILTER_STOP
	_faction_influence_legend_rows_host.add_theme_constant_override("separation", 2)
	content.add_child(_faction_influence_legend_rows_host)

	_faction_influence_legend_more_label = Label.new()
	_faction_influence_legend_more_label.name = "LegendMore"
	_faction_influence_legend_more_label.visible = false
	_faction_influence_legend_more_label.mouse_filter = Control.MOUSE_FILTER_STOP
	_faction_influence_legend_more_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_faction_influence_legend_more_label.add_theme_font_size_override("font_size", 12)
	_faction_influence_legend_more_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	content.add_child(_faction_influence_legend_more_label)
	_rebuild_faction_influence_legend()


func _collect_faction_influence_legend_rows() -> Array[Dictionary]:
	var ownership_counts: Dictionary = {}
	for ownership_value in _scenario_state.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			continue
		var ownership: Dictionary = ownership_value
		var place_id := str(ownership.get("place_id", "")).strip_edges()
		var faction_id := str(ownership.get("faction_id", "")).strip_edges()
		if place_id.is_empty() or not _faction_name_by_id.has(faction_id):
			continue
		ownership_counts[faction_id] = int(ownership_counts.get(faction_id, 0)) + 1

	var rows: Array[Dictionary] = []
	for faction_value in _scenario_state.get("factions", []):
		if not (faction_value is Dictionary):
			continue
		var faction_id := str((faction_value as Dictionary).get("id", "")).strip_edges()
		var city_count := int(ownership_counts.get(faction_id, 0))
		if not _faction_name_by_id.has(faction_id):
			continue
		rows.append({
			"faction_id": faction_id,
			"name": str(_faction_name_by_id.get(faction_id, "未命名势力")),
			"color": str(_faction_color_by_id.get(faction_id, FactionPaletteScript.UNASSIGNED_HEX)),
			"marker": str(int(_faction_order_by_id.get(faction_id, rows.size())) + 1),
			"city_count": city_count
		})
	return rows


func _rebuild_faction_influence_legend() -> void:
	if _faction_influence_legend_panel == null or _faction_influence_legend_rows_host == null:
		return
	var next_rows := _collect_faction_influence_legend_rows()
	var next_signature := JSON.stringify(next_rows)
	if next_signature == _faction_influence_legend_signature:
		_sync_faction_influence_legend_visibility(is_faction_influence_visible())
		return
	_faction_influence_legend_signature = next_signature
	_faction_influence_legend_rows.clear()
	for row_value in next_rows:
		_faction_influence_legend_rows.append((row_value as Dictionary).duplicate(true))
	for child in _faction_influence_legend_rows_host.get_children():
		_faction_influence_legend_rows_host.remove_child(child)
		child.queue_free()

	var visible_row_count := mini(next_rows.size(), FACTION_INFLUENCE_LEGEND_MAX_ROWS)
	for index in range(visible_row_count):
		_faction_influence_legend_rows_host.add_child(_make_faction_influence_legend_row(next_rows[index]))
	var hidden_count := maxi(next_rows.size() - visible_row_count, 0)
	_faction_influence_legend_more_label.text = "另有 %d 方" % hidden_count
	_faction_influence_legend_more_label.visible = hidden_count > 0
	_sync_legend_fold()
	_faction_influence_legend_rebuilds += 1
	_sync_faction_influence_legend_visibility(is_faction_influence_visible())
	_faction_influence_legend_panel.reset_size()
	_queue_place_dock_overlay_refresh()


func set_faction_legend_collapsed(value: bool) -> void:
	if _faction_influence_legend_collapsed == value:
		return
	# When a row is focused, folding must not leave keyboard focus on a hidden child.
	var focused := get_viewport().gui_get_focus_owner()
	if value and focused != null and _faction_influence_legend_rows_host.is_ancestor_of(focused):
		_faction_influence_legend_title.grab_focus()
	_faction_influence_legend_collapsed = value
	_sync_legend_fold()


func _sync_legend_fold() -> void:
	_faction_influence_legend_rows_host.visible = not _faction_influence_legend_collapsed
	_faction_influence_legend_more_label.visible = not _faction_influence_legend_collapsed and _faction_influence_legend_rows.size() > FACTION_INFLUENCE_LEGEND_MAX_ROWS
	_faction_influence_legend_title.text = "%s 势力图例 · %d" % ["▸" if _faction_influence_legend_collapsed else "▾", _faction_influence_legend_rows.size()]
	_faction_influence_legend_title.tooltip_text = "展开势力列表" if _faction_influence_legend_collapsed else "收起势力列表，腾出地图空间（不隐藏势力色块）"
	_faction_influence_legend_panel.reset_size()
	# Container minimum sizes settle next frame; then update card avoidance geometry.
	_faction_influence_legend_panel.call_deferred("reset_size")
	_queue_place_dock_overlay_refresh()


func _make_faction_influence_legend_row(row_state: Dictionary) -> Button:
	var row := Button.new()
	row.name = "LegendRow_%s" % str(row_state.get("marker", "0"))
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.focus_mode = Control.FOCUS_ALL
	row.flat = true
	row.custom_minimum_size = Vector2(168, 28)
	row.tooltip_text = "查看%s · %d 座城池" % [
		str(row_state.get("name", "未命名势力")),
		int(row_state.get("city_count", 0))
	]
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0, 0, 0, 0)
	normal_style.set_corner_radius_all(3)
	row.add_theme_stylebox_override("normal", normal_style)
	var hover_style := normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(1.0, 0.95, 0.78, 0.32)
	row.add_theme_stylebox_override("hover", hover_style)
	row.add_theme_stylebox_override("pressed", hover_style)
	var focus_style := hover_style.duplicate() as StyleBoxFlat
	focus_style.border_color = UiThemeScript.GOLD_FOCUS
	focus_style.set_border_width_all(1)
	row.add_theme_stylebox_override("focus", focus_style)
	var faction_id := str(row_state.get("faction_id", ""))
	row.pressed.connect(func() -> void: faction_legend_requested.emit(faction_id))

	var content := HBoxContainer.new()
	content.name = "LegendRowContent_%s" % str(row_state.get("marker", "0"))
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 2.0
	content.offset_top = 2.0
	content.offset_right = -2.0
	content.offset_bottom = -2.0
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 5)
	row.add_child(content)

	var marker_panel := PanelContainer.new()
	marker_panel.custom_minimum_size = Vector2(24, 24)
	marker_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var marker_color := FactionPaletteScript.to_color(row_state.get("color", FactionPaletteScript.UNASSIGNED_HEX))
	var marker_style := StyleBoxFlat.new()
	marker_style.bg_color = marker_color
	marker_style.border_color = FactionPaletteScript.render_on_dark(row_state.get("color", FactionPaletteScript.UNASSIGNED_HEX))
	marker_style.set_border_width_all(1)
	marker_style.set_corner_radius_all(2)
	marker_panel.add_theme_stylebox_override("panel", marker_style)
	content.add_child(marker_panel)

	var marker_label := Label.new()
	marker_label.name = "LegendMarker_%s" % str(row_state.get("marker", "0"))
	marker_label.text = str(row_state.get("marker", "?"))
	marker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker_label.add_theme_font_size_override("font_size", 12)
	var white_ratio := FactionPaletteScript.contrast_ratio(Color.WHITE, marker_color)
	var black_ratio := FactionPaletteScript.contrast_ratio(Color.BLACK, marker_color)
	marker_label.add_theme_color_override("font_color", Color.WHITE if white_ratio >= black_ratio else Color.BLACK)
	marker_panel.add_child(marker_label)

	var name_label := Label.new()
	name_label.name = "LegendName_%s" % str(row_state.get("marker", "0"))
	name_label.text = str(row_state.get("name", "未命名势力"))
	name_label.tooltip_text = name_label.text
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.clip_text = true
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PRIMARY)
	content.add_child(name_label)

	var count_label := Label.new()
	count_label.name = "LegendCityCount_%s" % str(row_state.get("marker", "0"))
	count_label.text = "%d 城" % int(row_state.get("city_count", 0))
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_label.add_theme_font_size_override("font_size", 12)
	count_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	content.add_child(count_label)
	return row


func _sync_faction_influence_legend_visibility(influence_visible: bool) -> void:
	if _faction_influence_legend_panel != null:
		var next_visible := influence_visible \
			and _map_tools_visible \
			and not _faction_influence_legend_context_suppressed \
			and not _faction_influence_legend_rows.is_empty()
		var visibility_changed := _faction_influence_legend_panel.visible != next_visible
		_faction_influence_legend_panel.visible = next_visible
		if visibility_changed:
			_queue_place_dock_overlay_refresh()


func _queue_place_dock_overlay_refresh() -> void:
	if _place_dock_overlay_refresh_queued or not is_inside_tree():
		return
	_place_dock_overlay_refresh_queued = true
	call_deferred("_flush_place_dock_overlay_refresh")


func _flush_place_dock_overlay_refresh() -> void:
	_place_dock_overlay_refresh_queued = false
	if _world_layer == null:
		return
	_rebuild_place_dock_layout()
	_layout_all_cards()


func set_faction_influence_legend_context_suppressed(value: bool) -> void:
	_faction_influence_legend_context_suppressed = value
	_sync_faction_influence_legend_visibility(is_faction_influence_visible())


func get_faction_influence_legend_state() -> Dictionary:
	var rows: Array[Dictionary] = []
	for row_value in _faction_influence_legend_rows:
		rows.append((row_value as Dictionary).duplicate(true))
	return {
		"visible": _faction_influence_legend_panel != null and _faction_influence_legend_panel.visible,
		"context_suppressed": _faction_influence_legend_context_suppressed,
		"collapsed": _faction_influence_legend_collapsed,
		"row_count": rows.size(),
		"displayed_row_count": 0 if _faction_influence_legend_collapsed else mini(rows.size(), FACTION_INFLUENCE_LEGEND_MAX_ROWS),
		"hidden_row_count": maxi(rows.size() - FACTION_INFLUENCE_LEGEND_MAX_ROWS, 0),
		"max_rows": FACTION_INFLUENCE_LEGEND_MAX_ROWS,
		"rebuild_count": _faction_influence_legend_rebuilds,
		"rows": rows
	}


func set_camera_state(value: Dictionary) -> void:
	if value.is_empty():
		return
	zoom = clampf(float(value.get("zoom", zoom)), min_zoom, max_zoom)
	pan = Vector2(float(value.get("x", pan.x)), float(value.get("y", pan.y)))
	_camera_initialized = true
	_apply_camera()
	zoom_changed.emit(zoom)


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		clear_native_drag_feedback()
