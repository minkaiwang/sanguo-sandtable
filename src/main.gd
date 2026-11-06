extends Control

const BackpackPanelScript = preload("res://src/backpack_panel.gd")
const MapBoardScript = preload("res://src/map_board.gd")
const MapGeometryMigrationScript = preload("res://src/map_geometry_migration.gd")
const MapGeographicContextPolicyScript = preload("res://src/map_geographic_context_policy.gd")
const FactionPaletteScript = preload("res://src/faction_palette.gd")
const CharacterCatalogPolicyScript = preload("res://src/character_catalog_policy.gd")
const CharacterIdentityPolicyScript = preload("res://src/character_identity_policy.gd")
const CharacterProfilePolicyScript = preload("res://src/character_profile_policy.gd")
const CharacterCatalogReferencePolicyScript = preload("res://src/character_catalog_reference_policy.gd")
const SimulationSessionDiffScript = preload("res://src/simulation_session_diff.gd")
const PlayerAdjudicatedSiegePolicyScript = preload("res://src/player_adjudicated_siege_policy.gd")
const ScenarioSharePackagePolicyScript = preload("res://src/scenario_share_package_policy.gd")
const ScenarioFactionOverviewScript = preload("res://src/scenario_faction_overview.gd")
const ScenarioCharacterPreviewScript = preload("res://src/scenario_character_preview.gd")
const CharacterNameplateScript = preload("res://src/character_nameplate.gd")
const CharacterActionPolicyScript = preload("res://src/character_action_policy.gd")
const UiThemeScript = preload("res://src/ui_theme.gd")

const CHARACTERS_PATH := "res://data/characters.json"
const CHARACTER_CATALOG_PATH := "res://data/character_catalog.json"
const CHARACTER_DISPLAY_ATTRIBUTES_PATH := "res://data/character_display_attributes.json"
const CHARACTER_PORTRAITS_PATH := "res://data/character_portraits.json"
const CHARACTER_PRESENTATION_MODE := "nameplate"
const CHARACTER_SOURCES_PATH := "res://data/character_sources.json"
const CHARACTER_PROFILES_PATH := "res://data/character_profiles.json"
const SCENARIO_TEMPLATES_PATH := "res://data/scenario_templates.json"
const HISTORICAL_CONTEXT_PATH := "res://data/historical_context_layers.json"
const PLACES_PATH := "res://data/map_places.json"
const MAP_SOURCES_PATH := "res://data/map_sources.json"
const ROUTES_PATH := "res://data/map_routes.json"
const LAND_PATH := "res://data/map_land.json"
const RIVERS_PATH := "res://data/map_rivers.json"
const LAKES_PATH := "res://data/map_lakes.json"
const MOUNTAINS_PATH := "res://data/map_mountains.json"
const GEOGRAPHIC_CONTEXT_PATH := "res://data/map_geographic_context.json"
const SAVE_PATH := "user://sandbox_save.json"
const LEGACY_PREFERENCES_PATH := "user://backpack_preferences.json"
const PREFERENCES_PATH := "user://backpack_preferences_v2.json"
const SNAPSHOTS_PATH := "user://sandbox_snapshots.json"
const PERSONAL_TEMPLATES_PATH := "user://personal_scenario_templates.json"
const BACKUP_DIR := "user://backups"
const M4_B7_RUNTIME_ARGUMENT := "--m4-b7-catalog-v4-isolated"
const AUTOMATED_PRIMARY_RECOVERY_PROMPT_ARGUMENT := "--automated-test-primary-recovery-prompt"
const M4_B7_CHARACTER_DATA_ROOT := "res://artifacts/m4_b5_catalog_v4_80_candidate/data"
const M4_B7_SAVE_PATH := "user://sandbox_save_m4_b7_catalog_v4.json"
const M4_B7_LEGACY_PREFERENCES_PATH := "user://backpack_preferences_m4_b7_catalog_v4.json"
const M4_B7_PREFERENCES_PATH := "user://backpack_preferences_v2_m4_b7_catalog_v4.json"
const M4_B7_SNAPSHOTS_PATH := "user://sandbox_snapshots_m4_b7_catalog_v4.json"
const M4_B7_PERSONAL_TEMPLATES_PATH := "user://personal_scenario_templates_m4_b7_catalog_v4.json"
const M4_B7_BACKUP_DIR := "user://backups_m4_b7_catalog_v4"
const M4_B7_AUTOMATED_SAVE_PATH := "user://sandbox_save_m4_b7_catalog_v4_automated_test.json"
const M4_B7_AUTOMATED_LEGACY_PREFERENCES_PATH := "user://backpack_preferences_m4_b7_catalog_v4_automated_test.json"
const M4_B7_AUTOMATED_PREFERENCES_PATH := "user://backpack_preferences_v2_m4_b7_catalog_v4_automated_test.json"
const M4_B7_AUTOMATED_SNAPSHOTS_PATH := "user://sandbox_snapshots_m4_b7_catalog_v4_automated_test.json"
const M4_B7_AUTOMATED_PERSONAL_TEMPLATES_PATH := "user://personal_scenario_templates_m4_b7_catalog_v4_automated_test.json"
const M4_B7_AUTOMATED_BACKUP_DIR := "user://backups_m4_b7_catalog_v4_automated_test"
const M4_B7_CAPTURE_SAVE_PATH := "user://sandbox_save_m4_b7_catalog_v4_capture.json"
const M4_B7_CAPTURE_LEGACY_PREFERENCES_PATH := "user://backpack_preferences_m4_b7_catalog_v4_capture.json"
const M4_B7_CAPTURE_PREFERENCES_PATH := "user://backpack_preferences_v2_m4_b7_catalog_v4_capture.json"
const M4_B7_CAPTURE_SNAPSHOTS_PATH := "user://sandbox_snapshots_m4_b7_catalog_v4_capture.json"
const M4_B7_CAPTURE_PERSONAL_TEMPLATES_PATH := "user://personal_scenario_templates_m4_b7_catalog_v4_capture.json"
const M4_B7_CAPTURE_BACKUP_DIR := "user://backups_m4_b7_catalog_v4_capture"
const MAP_ID := "map_three_kingdoms_alpha"
const SANDBOX_PACKAGE_FORMAT := "tianxia_sandbox_backup"
const SANDBOX_PACKAGE_VERSION := 1
const MAX_IMPORT_FILE_BYTES := 2 * 1024 * 1024
const MAX_SCENARIO_SHARE_FILE_BYTES := 1024 * 1024
const PRIMARY_RECOVERY_CANDIDATE_LIMIT := 12
const PRIMARY_LAST_GOOD_SUFFIX := ".last-good"
const MAX_IMPORT_ANNOTATIONS := 500
const ANNOTATION_TYPES := ["note", "player_place", "player_event"]
const ANNOTATION_STYLES := {
	"note": "amber",
	"player_place": "jade",
	"player_event": "cinnabar"
}
const ANNOTATION_SEMANTIC_LAYER := "player_authored"
const ANNOTATION_VERIFICATION_STATUS := "not_project_verified"
const ANNOTATION_FORBIDDEN_FIELDS := ["place_id", "anchor_place_id", "source_ref", "source_refs", "evidence", "confidence", "coordinate_basis", "lon", "lat", "historical_event_year", "period_context_refs", "route", "trigger", "result", "outcome", "ai_action"]
const MAP_GEOMETRY_VERSION := 4
const MAP_GEOMETRY_MIGRATABLE_VERSION := 3
const MAP_GEOMETRY_V3_BOUNDS := {
	"west": 99.5, "east": 122.5,
	"south": 20.0, "north": 41.5
}
const MAP_GEOMETRY_V4_BOUNDS := {
	"west": 93.5, "east": 130.5,
	"south": 18.0, "north": 44.5
}
const SAVE_VERSION := 18
const STRICT_CARD_FIELDS_SAVE_VERSION := 16
const PLACE_ID_SAVE_VERSION := 2
const SANDBOX_METADATA_SAVE_VERSION := 4
const SCENARIO_STATE_SAVE_VERSION := 5
const CHRONICLE_SAVE_VERSION := 6
const PLAYER_STROKE_SAVE_VERSION := 7
const LEGACY_CHARACTER_STATE_SAVE_VERSION := 8
const CHARACTER_STATE_SAVE_VERSION := 9
const SCENARIO_COLOR_SAVE_VERSION := 10
const CHARACTER_ACTION_SAVE_VERSION := 11
const CHARACTER_CATALOG_SAVE_VERSION := 13
const CHARACTER_TROOP_SAVE_VERSION := 14
const NEW_SANDBOX_DIALOG_SIZE := Vector2i(840, 600)
const HISTORICAL_SCENARIO_OPENING_IDS := [
	"yellow_turban_184",
	"coalition_190",
	"warlords_196",
	"guandu_200",
	"red_cliffs_208",
]
const HISTORICAL_SCENARIO_OPENING_ZOOM := 1.0
const HISTORICAL_SCENARIO_OPENING_SCREEN_ANCHOR := Vector2(0.44, 0.52)
const CURRENT_CHARACTER_CATALOG_VERSION := 6
const PREVIOUS_CHARACTER_CATALOG_VERSION := 5
const PREVIOUS_CHARACTER_CATALOG_COUNT := 87
const PREVIOUS_CHARACTER_CATALOG_MIN_SAVE_VERSION := 17
const PREVIOUS_CHARACTER_CATALOG_MAX_SAVE_VERSION := 17
const HISTORICAL_CHARACTER_CATALOG_COUNTS := {2: 40, 3: 60, 4: 80}
const HISTORICAL_CHARACTER_CATALOG_MAX_SAVE_VERSIONS := {2: 14, 3: 15, 4: 16}
const LEGACY_CHARACTER_CATALOG_COUNT := 30
const PREFERENCES_VERSION := 2
const SNAPSHOT_STORE_VERSION := 1
const SCENARIO_TEMPLATE_SCHEMA_VERSION := 4
const SCENARIO_TEMPLATE_MIN_SCHEMA_VERSION := 1
const PERSONAL_TEMPLATE_FORMAT := "tianxia_personal_template_store"
const PERSONAL_TEMPLATE_SCHEMA_VERSION := 4
const PERSONAL_TEMPLATE_MIN_SCHEMA_VERSION := 1
const HISTORICAL_CONTEXT_SCHEMA_VERSION := 3
const MAP_SOURCE_SCHEMA_VERSION := 2
const CHARACTER_PROFILE_SCHEMA_VERSION := 1
const CHARACTER_DISPLAY_ATTRIBUTES_SCHEMA_VERSION := 1
const SNAPSHOT_LIMIT := 50
const QUICK_SITUATION_BOOKMARK_MENU_ID := 17
const PLACE_SEARCH_MENU_ID := 18
const MAP_VISUAL_DAYLIGHT_MENU_ID := 19
const MAP_VISUAL_ANTIQUE_MENU_ID := 20
const MAP_VISUAL_PROFILE_SUBMENU_ID := 21
const MAP_VISUAL_JADE_MENU_ID := 22
const MAP_TOOLS_VISIBLE_MENU_ID := 23
const CURRENT_ROSTER_MENU_ID := 22
const CURRENT_ROSTER_VIEW_FACTION := "faction"
const CURRENT_ROSTER_VIEW_PLACE := "place"
const SCENARIO_TEMPLATE_LIMIT := 20
const SCENARIO_TAKE_GUIDANCE_LIMIT := 8
const SCENARIO_CONDITIONAL_GUIDANCE_LIMIT := 20
const PERSONAL_TEMPLATE_LIMIT := 20
const SCENARIO_FACTION_LIMIT := 12
const CHRONICLE_ENTRY_LIMIT := 80
const CHRONICLE_ENTRY_TYPES := ["note", "battle", "reinforcement", "plot"]
const CHRONICLE_SEMANTIC_LAYER := "player_authored"
const CHRONICLE_VERIFICATION_STATUS := "not_project_verified"
const MAX_SANDBOX_TITLE_LENGTH := 24
const MAX_SANDBOX_NOTE_LENGTH := 120
const MAX_SANDBOX_SOURCE_LENGTH := 60
const MAX_SNAPSHOT_NAME_LENGTH := 30
const MAX_SNAPSHOT_NOTE_LENGTH := 120
const MAX_PERSONAL_TEMPLATE_NAME_LENGTH := 24
const MAX_PERSONAL_TEMPLATE_DESCRIPTION_LENGTH := 120
const MAX_CHRONICLE_TITLE_LENGTH := 36
const MAX_CHRONICLE_TIME_LABEL_LENGTH := 24
const MAX_CHRONICLE_BODY_LENGTH := 400
const MAX_SIMULATION_SESSION_NAME_LENGTH := 24
const MAX_SIMULATION_SESSION_TIME_LENGTH := 24
const MAX_SIMULATION_SESSION_NOTE_LENGTH := 220
const PLAYER_STROKE_LIMIT := 32
const PLAYER_STROKE_POINT_LIMIT := 48
const PLAYER_STROKE_TOTAL_POINT_LIMIT := 512
const MAX_PLAYER_STROKE_LABEL_LENGTH := 24
const PLAYER_STROKE_TYPES := ["advance", "reinforcement", "retreat", "plan"]
const PLAYER_STROKE_SEMANTIC_LAYER := "player_authored"
const PLAYER_STROKE_VERIFICATION_STATUS := "not_project_verified"
const PLAYER_STROKE_FORBIDDEN_FIELDS := ["style", "color", "width", "dash", "arrowhead", "from", "to", "place_id", "character_id", "faction_id", "source", "source_ref", "source_refs", "evidence", "route", "path", "cost", "duration", "result", "outcome", "trigger", "ai_action"]
const CHARACTER_STATE_SEMANTIC_LAYER := "player_authored"
const CHARACTER_STATE_VERIFICATION_STATUS := "not_project_verified"
const CHARACTER_STATE_SCHEMA_FOUR_DIMENSIONS := "four_dimensions_v1"
const CHARACTER_STATE_SCHEMA_LEGACY_V8_COMBAT := "legacy_v8_combat"
const CHARACTER_ATTRIBUTE_FIELDS := ["might", "intelligence", "leadership", "charisma"]
const CHARACTER_ATTRIBUTE_MIN := 0
const CHARACTER_ATTRIBUTE_MAX := 100
const CHARACTER_ATTRIBUTE_EDITOR_INITIAL := 50
const CHARACTER_ACTION_SEMANTIC_LAYER := "player_authored"
const CHARACTER_ACTION_VERIFICATION_STATUS := "not_project_verified"
const CHARACTER_ACTION_STANDBY := CharacterActionPolicyScript.ACTION_STANDBY
const CHARACTER_ACTION_ATTACK := CharacterActionPolicyScript.ACTION_ATTACK
const CHARACTER_ACTION_DEFEND := CharacterActionPolicyScript.ACTION_DEFEND
const CHARACTER_ACTION_VALUES := CharacterActionPolicyScript.ACTION_VALUES
const CHARACTER_ACTION_STORED_VALUES := CharacterActionPolicyScript.STORED_ACTION_VALUES
const CHARACTER_TROOP_SCHEMA_VERSION := 1
const CHARACTER_TROOP_SEMANTIC_LAYER := "player_authored"
const CHARACTER_TROOP_VERIFICATION_STATUS := "not_project_verified"
const CHARACTER_TROOP_DEFAULT := 1000
const CHARACTER_TROOP_MIN := 0
const CHARACTER_TROOP_MAX := 999999
const SCENARIO_KIND_CUSTOM := "custom"
const SCENARIO_KIND_HISTORICAL_START := "historical_start"
const SCENARIO_KINDS := [SCENARIO_KIND_CUSTOM, SCENARIO_KIND_HISTORICAL_START]
const ASSIGNABLE_PLACE_TYPES := ["city", "capital"]
const HISTORY_LIMIT := 50
const LEGACY_PLACE_MIGRATION_EPSILON := 0.0005
const DRAG_BENCHMARK_SCENE_WARMUP_FRAMES := 120
const DRAG_BENCHMARK_CACHE_WARMUP_FRAMES := 24
const DRAG_BENCHMARK_PATH_ID := "drag_path_core_v1"
const OPEN_SNAPSHOTS_META := "sandtable_open_snapshots_after_scene_change"
const OPEN_NEW_SANDBOX_META := "sandtable_open_new_sandbox_after_scene_change"
const TITLE_SCENE_PATH := "res://scenes/title_screen.tscn"
const SAVE_ICON_PATH := "res://assets/ui/icons/lucide_1_26_0/save.svg"
const SAVE_ICON := preload(SAVE_ICON_PATH)
const SYSTEM_ICON_SIZE := 16

var characters: Array = []
var runtime_profile_id := "formal_v%d_catalog_v%d" % [SAVE_VERSION, CURRENT_CHARACTER_CATALOG_VERSION]
var runtime_scenario_templates_path := SCENARIO_TEMPLATES_PATH
var isolated_catalog_v4_runtime := false
var runtime_character_data_root := "res://data"
var runtime_save_version := SAVE_VERSION
var runtime_current_character_catalog_version := CURRENT_CHARACTER_CATALOG_VERSION
var runtime_previous_character_catalog_version := PREVIOUS_CHARACTER_CATALOG_VERSION
var runtime_previous_character_catalog_count := PREVIOUS_CHARACTER_CATALOG_COUNT
var runtime_previous_character_catalog_min_save_version := PREVIOUS_CHARACTER_CATALOG_MIN_SAVE_VERSION
var runtime_previous_character_catalog_max_save_version := PREVIOUS_CHARACTER_CATALOG_MAX_SAVE_VERSION
var runtime_historical_character_catalog_counts: Dictionary = HISTORICAL_CHARACTER_CATALOG_COUNTS.duplicate()
var runtime_historical_character_catalog_max_save_versions: Dictionary = HISTORICAL_CHARACTER_CATALOG_MAX_SAVE_VERSIONS.duplicate()
var character_catalog_version := 0
var character_catalog_ids: Array[String] = []
var character_catalog_load_error := ""
var character_display_attributes_by_id: Dictionary = {}
var character_display_attributes_load_error := ""
var character_portraits_by_id: Dictionary = {}
var character_portrait_registry_load_error := ""
var character_profiles_by_id: Dictionary = {}
var character_profile_sources_by_id: Dictionary = {}
var character_profile_load_error := ""
var historical_context_layer: Dictionary = {}
var historical_context_layers: Array[Dictionary] = []
var historical_context_load_error := ""
var historical_context_sources_by_id: Dictionary = {}
var scenario_templates: Array[Dictionary] = []
var scenario_template_load_error := ""
var personal_scenario_templates: Array[Dictionary] = []
var personal_scenario_template_load_error := ""
var places: Array = []
var map_sources_by_id: Dictionary = {}
var map_source_load_error := ""
var routes: Array = []
var land_data: Dictionary = {}
var river_data: Dictionary = {}
var lake_data: Dictionary = {}
var mountains: Array = []
var geographic_context_records: Array[Dictionary] = []
var geographic_context_load_error := ""
var placements: Dictionary = {}
var annotations: Dictionary = {}
var loaded_camera: Dictionary = {}
var sandbox_metadata: Dictionary = {}
var scenario_state: Dictionary = {
	"scenario_id": "custom_blank",
	"start_year": null,
	"era_label": "完全自定义",
	"scenario_kind": "custom",
	"featured_character_ids": [],
	"history_layer_ids": [],
	"factions": [],
	"character_assignments": [],
	"city_ownership": []
}
var chronicle_entries: Array[Dictionary] = []
var player_strokes: Array[Dictionary] = []
var character_states: Dictionary = {}
var character_actions: Dictionary = {}
var character_troops: Dictionary = {}
var named_snapshots: Array[Dictionary] = []
var favorite_character_ids: Dictionary = {}

var backpack: BackpackPanel
var backpack_host: VBoxContainer
var backpack_restore_button: Button
var backpack_collapsed := false
var map_board: MapBoard
var status_label: Label
var zoom_label: Label
var detail_label: Label
var undo_button: Button
var redo_button: Button
var annotation_button: Button
var draw_tool_popup: PopupMenu
var annotation_dialog: ConfirmationDialog
var annotation_input: LineEdit
var annotation_type_select: OptionButton
var annotation_faction_select: OptionButton
var annotation_hint_label: Label
var player_stroke_dialog: ConfirmationDialog
var player_stroke_type_select: OptionButton
var player_stroke_label_input: LineEdit
var player_stroke_hint_label: Label
var player_stroke_delete_confirmation_dialog: ConfirmationDialog
var sandbox_file_menu: MenuButton
var map_visual_profile_menu: PopupMenu
var place_search_dialog: ConfirmationDialog
var place_search_input: LineEdit
var place_search_count_label: Label
var place_search_list: ItemList
var place_search_result_ids: Array[String] = []
var sandbox_subtitle_label: Label
var sandbox_info_dialog: ConfirmationDialog
var sandbox_title_input: LineEdit
var sandbox_note_input: TextEdit
var sandbox_source_input: LineEdit
var sandbox_info_summary_label: Label
var snapshot_create_dialog: ConfirmationDialog
var snapshot_name_input: LineEdit
var snapshot_note_input: TextEdit
var snapshot_create_summary_label: Label
var snapshot_manager_dialog: ConfirmationDialog
var snapshot_list: ItemList
var snapshot_detail_label: Label
var snapshot_rename_button: Button
var snapshot_export_button: Button
var snapshot_delete_button: Button
var snapshot_rename_dialog: ConfirmationDialog
var snapshot_rename_input: LineEdit
var snapshot_restore_confirmation_dialog: ConfirmationDialog
var snapshot_delete_confirmation_dialog: ConfirmationDialog
var new_sandbox_dialog: ConfirmationDialog
var new_sandbox_list: ItemList
var new_sandbox_detail_label: RichTextLabel
var new_sandbox_faction_overview
var new_sandbox_character_preview
var new_sandbox_title_input: LineEdit
var new_sandbox_edit_button: Button
var new_sandbox_delete_button: Button
var new_sandbox_confirmation_dialog: ConfirmationDialog
var personal_template_create_dialog: ConfirmationDialog
var personal_template_name_input: LineEdit
var personal_template_description_input: TextEdit
var personal_template_create_hint_label: Label
var personal_template_create_summary_label: Label
var personal_template_edit_dialog: ConfirmationDialog
var personal_template_edit_name_input: LineEdit
var personal_template_edit_description_input: TextEdit
var personal_template_edit_summary_label: Label
var personal_template_delete_confirmation_dialog: ConfirmationDialog
var scenario_editor_dialog: ConfirmationDialog
var scenario_editor_summary_label: Label
var scenario_editor_validation_label: Label
var scenario_faction_list: ItemList
var scenario_faction_new_button: Button
var scenario_faction_rename_button: Button
var scenario_faction_delete_button: Button
var scenario_faction_color_button: ColorPickerButton
var scenario_character_rows: VBoxContainer
var scenario_character_scroll: ScrollContainer
var scenario_character_scroll_top_button: Button
var scenario_character_scroll_bottom_button: Button
var scenario_character_scroll_range_label: Label
var scenario_faction_name_dialog: ConfirmationDialog
var scenario_faction_name_input: LineEdit
var scenario_faction_delete_confirmation_dialog: ConfirmationDialog
var scenario_editor_discard_confirmation_dialog: ConfirmationDialog
var chronicle_dialog: AcceptDialog
var chronicle_list: ItemList
var chronicle_detail_label: RichTextLabel
var chronicle_add_button: Button
var chronicle_edit_button: Button
var chronicle_delete_button: Button
var chronicle_editor_dialog: ConfirmationDialog
var chronicle_type_select: OptionButton
var chronicle_time_input: LineEdit
var chronicle_title_input: LineEdit
var chronicle_body_input: TextEdit
var chronicle_character_count_label: Label
var chronicle_delete_confirmation_dialog: ConfirmationDialog
var chronicle_editor_discard_confirmation_dialog: ConfirmationDialog
var branch_sandbox_dialog: ConfirmationDialog
var branch_sandbox_title_input: LineEdit
var branch_sandbox_summary_label: Label
var branch_sandbox_confirmation_dialog: ConfirmationDialog
var export_dialog: FileDialog
var import_dialog: FileDialog
var import_confirmation_dialog: ConfirmationDialog
var import_summary_label: Label
var export_overwrite_dialog: ConfirmationDialog
var message_dialog: AcceptDialog
var current_roster_dialog: AcceptDialog
var current_roster_summary_label: Label
var current_roster_faction_view_button: Button
var current_roster_place_view_button: Button
var current_roster_view_button_group: ButtonGroup
var current_roster_empty_label: Label
var current_roster_tree: Tree
var current_roster_locate_button: Button
var current_roster_profile_button: Button
var current_roster_character_ids: Array[String] = []
var current_roster_rows: Array[Dictionary] = []
var current_roster_groups: Array[Dictionary] = []
var current_roster_selected_id := ""
var current_roster_view_mode := CURRENT_ROSTER_VIEW_FACTION
var character_detail_dialog: AcceptDialog
var character_detail_nameplate: PanelContainer
var character_detail_text: RichTextLabel
var character_detail_character_id := ""
var character_detail_action_footer: HBoxContainer
var character_detail_place_button: Button
var character_detail_chronicle_button: Button
var character_detail_browser_footer: HBoxContainer
var character_detail_previous_button: Button
var character_detail_position_label: Label
var character_detail_next_button: Button
var character_detail_close_button: Button
var character_detail_browse_ids: Array[String] = []
var character_detail_browse_index := -1
var character_detail_return_focus: Control
var character_detail_restore_focus_on_close := false
var character_detail_restore_roster_on_close := false
var character_detail_opening_context: Dictionary = {}
var character_detail_opening_return_state: Dictionary = {}
var character_attribute_dialog: ConfirmationDialog
var character_attribute_might_spin: SpinBox
var character_attribute_intelligence_spin: SpinBox
var character_attribute_leadership_spin: SpinBox
var character_attribute_charisma_spin: SpinBox
var character_attribute_legacy_label: Label
var character_attribute_clear_button: Button
var character_attribute_pending_id := ""
var character_troop_dialog: ConfirmationDialog
var character_troop_spin: SpinBox
var character_troop_pending_id := ""
var simulation_session_bar: PanelContainer
var simulation_session_title_label: Label
var simulation_session_meta_label: Label
var simulation_session_start_dialog: ConfirmationDialog
var simulation_session_name_input: LineEdit
var simulation_session_type_select: OptionButton
var simulation_session_time_input: LineEdit
var simulation_session_participants_label: Label
var simulation_session_initial_action_select: OptionButton
var simulation_session_initial_action_label: Label
var simulation_session_siege_setup_panel: VBoxContainer
var simulation_session_siege_target_select: OptionButton
var simulation_session_siege_roster: VBoxContainer
var simulation_session_siege_role_selects: Dictionary = {}
var simulation_session_end_dialog: ConfirmationDialog
var simulation_session_end_summary: RichTextLabel
var simulation_session_siege_resolution_panel: VBoxContainer
var simulation_session_siege_outcome_select: OptionButton
var simulation_session_siege_handling_select: OptionButton
var simulation_session_siege_return_panel: VBoxContainer
var simulation_session_siege_return_list: VBoxContainer
var simulation_session_siege_return_checks: Dictionary = {}
var simulation_session_siege_owner_select: OptionButton
var simulation_session_end_title_input: LineEdit
var simulation_session_end_note_input: TextEdit
var simulation_session_end_snapshot_check: CheckBox
var simulation_session_cancel_dialog: ConfirmationDialog
var active_simulation_session: Dictionary = {}
var pending_simulation_session_participants: Array[String] = []
var place_detail_host: Control
var place_detail_panel: PanelContainer
var place_detail_title_label: Label
var place_detail_chronicle_button: Button
var place_detail_historical_label: Label
var place_detail_tags_label: Label
var place_detail_ownership_row: HBoxContainer
var place_detail_owner_swatch: ColorRect
var place_detail_owner_select: OptionButton
var place_detail_continuous_ownership_button: Button
var place_detail_action_row: HFlowContainer
var place_detail_locate_button: Button
var place_detail_note_button: Button
var place_detail_faction_button: Button
var place_detail_edit_faction_button: Button
var place_detail_relation_navigation_row: HBoxContainer
var place_detail_switch_button: Button
var place_detail_back_button: Button
var place_detail_scroll_hint_label: Label
var place_detail_body: RichTextLabel
var current_place_detail_id := ""
var current_place_connection_ids: Array[String] = []
var _place_detail_return_ids: Array[String] = []
var current_faction_detail_id := ""
var current_historical_context_detail_id := ""
var current_detail_anchor_place_id := ""
var _place_connection_cycle_index := -1
var _place_owner_select_syncing := false
var city_ownership_tool_panel: PanelContainer
var city_ownership_tool_target_select: OptionButton
var city_ownership_tool_hint_label: Label
var city_ownership_tool_undo_button: Button
var city_ownership_tool_active := false
var city_ownership_tool_target_faction_id := ""
var city_ownership_tool_hover_place_id := ""
var _city_ownership_tool_select_syncing := false
var _city_ownership_tool_restore_influence_visible := true
var _faction_city_cycle_index := -1
var _faction_character_cycle_index := -1
var capture_mode := false
var test_mode := false
var automated_test_mode := false
var _automated_atomic_write_failure_stage := ""
var _automated_exact_write_post_promote_bytes := PackedByteArray()
var _automated_last_good_failure_stage := ""
var save_path := SAVE_PATH
var preferences_path := PREFERENCES_PATH
var legacy_preferences_path := LEGACY_PREFERENCES_PATH
var snapshot_store_path := SNAPSHOTS_PATH
var personal_template_store_path := PERSONAL_TEMPLATES_PATH
var backup_dir := BACKUP_DIR
var capture_zoom := 0.0
var capture_historical_context := false
var capture_player_annotations := false
var capture_player_strokes := false
var capture_historical_context_layer_id := "context_184"
var capture_hover_place_id := ""
var capture_focus_place_id := ""
var capture_dialog := ""
var ui_review_dialog := ""
var capture_character_id := ""
var capture_scenario_id := ""
var capture_faction_influence_override := ""
var capture_near_hachures_override := ""
var capture_window_size := Vector2i.ZERO
var capture_size_argument_seen := false
var _capture_surface: SubViewport
var pass_symbol_variant_request := ""
var pass_symbol_variant := MapBoardScript.PASS_SYMBOL_VARIANT_V3
var terrain_relief_variant_request := ""
var terrain_relief_variant := MapBoardScript.TERRAIN_RELIEF_VARIANT_HR_V1
var terrain_visual_profile_request := ""
var terrain_visual_profile := MapBoardScript.TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1
var drag_benchmark_mode := false
var drag_benchmark_frames := 600
var drag_benchmark_zoom := 1.75
var drag_benchmark_window_size := Vector2i(1440, 900)
var drag_benchmark_run := 1
var _undo_stack: Array[Dictionary] = []
var _redo_stack: Array[Dictionary] = []
var _last_map_selection_count := 0
var _pending_annotation_id := ""
var _pending_annotation_position := Vector2(0.5, 0.5)
var _pending_annotation_type := "note"
var _pending_annotation_faction_id := ""
var _pending_player_stroke_id := ""
var _pending_player_stroke_type := "advance"
var _pending_player_stroke_label := ""
var _next_annotation_serial := 1
var _pending_import_result: Dictionary = {}
var _pending_import_path := ""
var _pending_export_path := ""
var _pending_export_snapshot_id := ""
var _pending_file_export_mode := ""
var _pending_file_import_mode := ""
var _pending_scenario_share_template: Dictionary = {}
var _personal_template_create_mode := "store"
var _pending_rename_snapshot_id := ""
var _pending_snapshot_id := ""
var _pending_scenario_template_id := ""
var _pending_scenario_template_source := ""
var _pending_new_sandbox_title := ""
var _pending_edit_personal_template_id := ""
var _pending_delete_personal_template_id := ""
var _pending_scenario_editor_state: Dictionary = {}
var _pending_scenario_faction_id := ""
var _pending_scenario_faction_name_mode := ""
var _scenario_assignment_selects: Dictionary = {}
var _scenario_editor_transient_error := ""
var _scenario_color_picker_syncing := false
var _pending_chronicle_id := ""
var _pending_chronicle_edit_id := ""
var _chronicle_editor_original: Dictionary = {}
var _chronicle_editor_return_context: Dictionary = {}
var _pending_branch_sandbox_title := ""
var _save_writes_blocked := false
var _save_write_block_reason := ""
var _primary_recovery_state: Dictionary = {}
var _primary_recovery_requires_reload := false
var primary_recovery_dialog: ConfirmationDialog
var primary_recovery_summary_label: Label
var _preferences_writes_blocked := false
var _preferences_write_block_reason := ""
var _snapshot_writes_blocked := false
var _snapshot_write_block_reason := ""
var _personal_template_writes_blocked := false
var _personal_template_write_block_reason := ""


func _is_test_script_invocation() -> bool:
	for argument in OS.get_cmdline_args():
		var normalized := str(argument).replace("\\", "/").to_lower()
		if normalized.find("tests/test_") != -1 and normalized.ends_with(".gd"):
			return true
	return false


func _automated_primary_recovery_prompt_requested(user_args: PackedStringArray) -> bool:
	return "--automated-test-mode" in user_args and AUTOMATED_PRIMARY_RECOVERY_PROMPT_ARGUMENT in user_args


func _configure_runtime_profile(user_args: PackedStringArray) -> void:
	var preview_available := (
		FileAccess.file_exists(M4_B7_CHARACTER_DATA_ROOT.path_join("character_catalog.json"))
		and FileAccess.file_exists("res://prototypes/m4_b7_catalog_v4_sandbox_preview/scenario_templates_v4_compatible.json")
	)
	isolated_catalog_v4_runtime = M4_B7_RUNTIME_ARGUMENT in user_args and preview_available
	if not isolated_catalog_v4_runtime:
		runtime_profile_id = "formal_v%d_catalog_v%d" % [SAVE_VERSION, CURRENT_CHARACTER_CATALOG_VERSION]
		runtime_scenario_templates_path = SCENARIO_TEMPLATES_PATH
		runtime_character_data_root = "res://data"
		runtime_save_version = SAVE_VERSION
		runtime_current_character_catalog_version = CURRENT_CHARACTER_CATALOG_VERSION
		runtime_previous_character_catalog_version = PREVIOUS_CHARACTER_CATALOG_VERSION
		runtime_previous_character_catalog_count = PREVIOUS_CHARACTER_CATALOG_COUNT
		runtime_previous_character_catalog_min_save_version = PREVIOUS_CHARACTER_CATALOG_MIN_SAVE_VERSION
		runtime_previous_character_catalog_max_save_version = PREVIOUS_CHARACTER_CATALOG_MAX_SAVE_VERSION
		runtime_historical_character_catalog_counts = HISTORICAL_CHARACTER_CATALOG_COUNTS.duplicate()
		runtime_historical_character_catalog_max_save_versions = HISTORICAL_CHARACTER_CATALOG_MAX_SAVE_VERSIONS.duplicate()
		return
	runtime_profile_id = "m4_b7_isolated_v16_catalog_v4"
	# 兼容夹具基于现行模板保留 v4 可用人物；不是旧版原始快照，不进入正式模式。
	runtime_scenario_templates_path = "res://prototypes/m4_b7_catalog_v4_sandbox_preview/scenario_templates_v4_compatible.json"
	runtime_character_data_root = M4_B7_CHARACTER_DATA_ROOT
	runtime_save_version = 16
	runtime_current_character_catalog_version = 4
	runtime_previous_character_catalog_version = 3
	runtime_previous_character_catalog_count = 60
	runtime_previous_character_catalog_min_save_version = 15
	runtime_previous_character_catalog_max_save_version = 15
	runtime_historical_character_catalog_counts = {2: 40}
	runtime_historical_character_catalog_max_save_versions = {2: 14}


func _runtime_character_data_path(file_name: String) -> String:
	return "%s/%s" % [runtime_character_data_root.trim_suffix("/"), file_name]


func _ready() -> void:
	# 原生子窗口可能回落到系统深色底板，而内容文字仍继承项目的深墨色。
	# 统一嵌入子窗口，让真实试玩与截图视口使用同一套浅绢弹窗表面。
	get_window().gui_embed_subwindows = true
	var user_args := OS.get_cmdline_user_args()
	_configure_runtime_profile(user_args)
	capture_mode = "--capture" in user_args
	drag_benchmark_mode = "--drag-benchmark" in user_args
	# 正常沙盘必须自行决定关闭时机，确保保存失败后窗口继续保持打开。
	# 截图与基准模式没有交互式存档流程，继续沿用 Godot 的默认关闭行为。
	get_tree().auto_accept_quit = capture_mode or drag_benchmark_mode
	capture_historical_context = "--capture-context" in user_args
	capture_player_annotations = "--capture-player-annotations" in user_args
	capture_player_strokes = "--capture-player-strokes" in user_args
	for argument in user_args:
		if str(argument).begins_with("--capture-zoom="):
			capture_zoom = clampf(
				str(argument).trim_prefix("--capture-zoom=").to_float(),
				0.0,
				MapBoardScript.MAX_ZOOM
			)
		elif str(argument).begins_with("--capture-hover="):
			capture_hover_place_id = str(argument).trim_prefix("--capture-hover=")
		elif str(argument).begins_with("--capture-focus="):
			capture_focus_place_id = str(argument).trim_prefix("--capture-focus=")
		elif str(argument).begins_with("--capture-dialog="):
			capture_dialog = str(argument).trim_prefix("--capture-dialog=")
		elif str(argument).begins_with("--ui-review-dialog="):
			ui_review_dialog = str(argument).trim_prefix("--ui-review-dialog=").strip_edges()
		elif str(argument).begins_with("--capture-character="):
			capture_character_id = str(argument).trim_prefix("--capture-character=").strip_edges()
		elif str(argument).begins_with("--capture-scenario="):
			capture_scenario_id = str(argument).trim_prefix("--capture-scenario=").strip_edges()
		elif str(argument).begins_with("--capture-influence="):
			var requested_influence := str(argument).trim_prefix("--capture-influence=").to_lower()
			if requested_influence in ["on", "off"]:
				capture_faction_influence_override = requested_influence
		elif str(argument).begins_with("--pass-symbol-variant="):
			pass_symbol_variant_request = str(argument).trim_prefix("--pass-symbol-variant=")
		elif str(argument).begins_with("--terrain-relief-variant="):
			terrain_relief_variant_request = str(argument).trim_prefix("--terrain-relief-variant=")
		elif str(argument).begins_with("--terrain-visual-profile="):
			terrain_visual_profile_request = str(argument).trim_prefix("--terrain-visual-profile=")
		elif str(argument).begins_with("--capture-near-hachures="):
			var requested_hachures := str(argument).trim_prefix("--capture-near-hachures=").to_lower()
			if requested_hachures in ["on", "off"]:
				capture_near_hachures_override = requested_hachures
		elif str(argument).begins_with("--capture-size="):
			capture_size_argument_seen = true
			capture_window_size = _parse_capture_window_size(str(argument).trim_prefix("--capture-size="))
		elif str(argument).begins_with("--capture-context-year="):
			var requested_context_year := str(argument).trim_prefix("--capture-context-year=")
			if requested_context_year in ["184", "190", "196"]:
				capture_historical_context = true
				capture_historical_context_layer_id = "context_%s" % requested_context_year
		elif str(argument).begins_with("--benchmark-frames="):
			drag_benchmark_frames = clampi(str(argument).trim_prefix("--benchmark-frames=").to_int(), MapBoardScript.DRAG_MIN_REPORT_SAMPLES, MapBoardScript.DRAG_SAMPLE_LIMIT)
		elif str(argument).begins_with("--benchmark-zoom="):
			drag_benchmark_zoom = clampf(
				str(argument).trim_prefix("--benchmark-zoom=").to_float(),
				0.75,
				MapBoardScript.MAX_ZOOM
			)
		elif str(argument).begins_with("--benchmark-size="):
			var requested_benchmark_size := str(argument).trim_prefix("--benchmark-size=").strip_edges().to_lower()
			if requested_benchmark_size == "1440x900":
				drag_benchmark_window_size = Vector2i(1440, 900)
		elif str(argument).begins_with("--benchmark-run="):
			drag_benchmark_run = maxi(1, str(argument).trim_prefix("--benchmark-run=").to_int())
	automated_test_mode = "--automated-test-mode" in OS.get_cmdline_user_args() or _is_test_script_invocation()
	test_mode = "--test-mode" in OS.get_cmdline_user_args() or automated_test_mode or isolated_catalog_v4_runtime
	var automated_primary_recovery_prompt := _automated_primary_recovery_prompt_requested(user_args)
	if isolated_catalog_v4_runtime:
		get_window().title = "三国推演志 · 80 人主沙盘隔离演练"
	if test_mode and not automated_test_mode and not capture_mode and not drag_benchmark_mode:
		# 测试窗口可能与更新前的旧进程同时存在。标题显式标出当前可读性验收窗口，
		# 让玩家无需凭任务栏缩略图猜测哪一个才是新启动的构建。
		if not isolated_catalog_v4_runtime:
			get_window().title = "三国推演志 · 测试模式 · 界面校验"
	if not pass_symbol_variant_request.is_empty():
		if pass_symbol_variant_request not in [
			MapBoardScript.PASS_SYMBOL_VARIANT_V3,
			MapBoardScript.PASS_SYMBOL_VARIANT_PAPER_INK_V1
		]:
			push_warning("忽略未知关隘符号候选：%s" % pass_symbol_variant_request)
		elif test_mode or capture_mode:
			pass_symbol_variant = pass_symbol_variant_request
		elif pass_symbol_variant_request != MapBoardScript.PASS_SYMBOL_VARIANT_V3:
			push_warning("关隘纸墨候选只允许在测试或截图模式启用；已回退 V3")
	if not terrain_relief_variant_request.is_empty():
		if terrain_relief_variant_request not in [
			MapBoardScript.TERRAIN_RELIEF_VARIANT_LR_V1,
			MapBoardScript.TERRAIN_RELIEF_VARIANT_HR_V1
		]:
			push_warning("忽略未知地形纹理候选：%s" % terrain_relief_variant_request)
		elif test_mode or capture_mode or drag_benchmark_mode:
			terrain_relief_variant = terrain_relief_variant_request
		elif terrain_relief_variant_request != MapBoardScript.TERRAIN_RELIEF_VARIANT_HR_V1:
			push_warning("旧地形对照只允许在测试、截图或基准模式启用；已使用高精正式地形")
	if not terrain_visual_profile_request.is_empty():
		if terrain_visual_profile_request not in [
			MapBoardScript.TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1,
			MapBoardScript.TERRAIN_VISUAL_PROFILE_ANTIQUE_TOPOGRAPHIC_V1,
			MapBoardScript.TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1,
		]:
			push_warning("忽略未知地图视觉候选：%s" % terrain_visual_profile_request)
		elif test_mode or capture_mode or drag_benchmark_mode:
			terrain_visual_profile = terrain_visual_profile_request
		elif terrain_visual_profile_request != MapBoardScript.TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1:
			push_warning("古地图地形候选只允许在测试或截图模式启用；已使用当前正式样式")
	if isolated_catalog_v4_runtime and automated_test_mode:
		save_path = M4_B7_AUTOMATED_SAVE_PATH
		preferences_path = M4_B7_AUTOMATED_PREFERENCES_PATH
		legacy_preferences_path = M4_B7_AUTOMATED_LEGACY_PREFERENCES_PATH
		snapshot_store_path = M4_B7_AUTOMATED_SNAPSHOTS_PATH
		personal_template_store_path = M4_B7_AUTOMATED_PERSONAL_TEMPLATES_PATH
		backup_dir = M4_B7_AUTOMATED_BACKUP_DIR
	elif isolated_catalog_v4_runtime and capture_mode:
		save_path = M4_B7_CAPTURE_SAVE_PATH
		preferences_path = M4_B7_CAPTURE_PREFERENCES_PATH
		legacy_preferences_path = M4_B7_CAPTURE_LEGACY_PREFERENCES_PATH
		snapshot_store_path = M4_B7_CAPTURE_SNAPSHOTS_PATH
		personal_template_store_path = M4_B7_CAPTURE_PERSONAL_TEMPLATES_PATH
		backup_dir = M4_B7_CAPTURE_BACKUP_DIR
	elif isolated_catalog_v4_runtime:
		save_path = M4_B7_SAVE_PATH
		preferences_path = M4_B7_PREFERENCES_PATH
		legacy_preferences_path = M4_B7_LEGACY_PREFERENCES_PATH
		snapshot_store_path = M4_B7_SNAPSHOTS_PATH
		personal_template_store_path = M4_B7_PERSONAL_TEMPLATES_PATH
		backup_dir = M4_B7_BACKUP_DIR
	elif capture_mode:
		save_path = "user://sandbox_save_capture.json"
		preferences_path = "user://backpack_preferences_v2_capture.json"
		legacy_preferences_path = "user://backpack_preferences_capture.json"
		snapshot_store_path = "user://sandbox_snapshots_capture.json"
		personal_template_store_path = "user://personal_scenario_templates_capture.json"
		backup_dir = "user://backups_capture"
	elif drag_benchmark_mode:
		save_path = "user://sandbox_save_benchmark.json"
		preferences_path = "user://backpack_preferences_v2_benchmark.json"
		legacy_preferences_path = "user://backpack_preferences_benchmark.json"
		snapshot_store_path = "user://sandbox_snapshots_benchmark.json"
		personal_template_store_path = "user://personal_scenario_templates_benchmark.json"
		backup_dir = "user://backups_benchmark"
	elif automated_test_mode:
		save_path = "user://sandbox_save_automated_test.json"
		preferences_path = "user://backpack_preferences_v2_automated_test.json"
		legacy_preferences_path = "user://backpack_preferences_automated_test.json"
		snapshot_store_path = "user://sandbox_snapshots_automated_test.json"
		personal_template_store_path = "user://personal_scenario_templates_automated_test.json"
		backup_dir = "user://backups_automated_test"
	elif test_mode:
		save_path = "user://sandbox_save_test.json"
		preferences_path = "user://backpack_preferences_v2_test.json"
		legacy_preferences_path = "user://backpack_preferences_test.json"
		snapshot_store_path = "user://sandbox_snapshots_test.json"
		personal_template_store_path = "user://personal_scenario_templates_test.json"
		backup_dir = "user://backups_test"
	else:
		save_path = SAVE_PATH
		preferences_path = PREFERENCES_PATH
		legacy_preferences_path = LEGACY_PREFERENCES_PATH
		snapshot_store_path = SNAPSHOTS_PATH
		personal_template_store_path = PERSONAL_TEMPLATES_PATH
		backup_dir = BACKUP_DIR
	if capture_mode and capture_size_argument_seen and capture_window_size == Vector2i.ZERO:
		push_error("不支持的截图尺寸；只允许 1366x768 或 1920x1080")
		get_tree().quit(2)
		return
	if capture_mode and capture_window_size != Vector2i.ZERO:
		call_deferred("_attach_capture_surface")
	_apply_theme()
	_load_reference_data()
	_load_scenario_templates()
	if capture_mode or drag_benchmark_mode:
		favorite_character_ids.clear()
		placements.clear()
		annotations.clear()
		loaded_camera.clear()
		sandbox_metadata = _new_sandbox_metadata()
		scenario_state = _empty_scenario_state()
		chronicle_entries.clear()
		player_strokes.clear()
		named_snapshots.clear()
		personal_scenario_templates.clear()
	else:
		_load_preferences()
		_primary_recovery_state = _inspect_primary_save_recovery()
		_apply_primary_recovery_write_guard()
		_load_save()
		if sandbox_metadata.is_empty():
			sandbox_metadata = _new_sandbox_metadata()
		_load_named_snapshots()
		_load_personal_scenario_templates()
	_build_interface()

	if capture_mode or drag_benchmark_mode:
		if capture_mode and capture_historical_context:
			placements.clear()
			annotations.clear()
		else:
			var luoyang_capture_placement := _capture_place_placement("luoyang", Vector2(0.570361, 0.315373))
			placements = {
				"liu_bei": luoyang_capture_placement.duplicate(true),
				"guan_yu": luoyang_capture_placement.duplicate(true),
				"zhang_fei": luoyang_capture_placement.duplicate(true),
				"zhang_jiao": _capture_v3_xy(Vector2(0.693, 0.211))
			}
			var marker_1_point := _capture_v3_point(Vector2(0.67, 0.49))
			annotations = {
				"marker_1": {"id": "marker_1", "kind": "marker", "marker_type": "note", "semantic_layer": "player_authored", "verification_status": "not_project_verified", "x": marker_1_point.x, "y": marker_1_point.y, "label": "援军集结", "style": "amber"}
			}
			if capture_player_annotations:
				var marker_2_point := _capture_v3_point(Vector2(0.47, 0.43))
				var marker_3_point := _capture_v3_point(Vector2(0.63, 0.61))
				annotations["marker_2"] = {"id": "marker_2", "kind": "marker", "marker_type": "player_place", "semantic_layer": "player_authored", "verification_status": "not_project_verified", "x": marker_2_point.x, "y": marker_2_point.y, "label": "卧龙岗别院", "style": "jade"}
				annotations["marker_3"] = {"id": "marker_3", "kind": "marker", "marker_type": "player_event", "semantic_layer": "player_authored", "verification_status": "not_project_verified", "x": marker_3_point.x, "y": marker_3_point.y, "label": "援军抵达", "style": "cinnabar"}
			if capture_player_strokes:
				player_strokes = [
					{"id": "stroke_capture_advance", "stroke_type": "advance", "label": "关羽北上", "points": [_capture_v3_xy(Vector2(0.46, 0.57)), _capture_v3_xy(Vector2(0.53, 0.48)), _capture_v3_xy(Vector2(0.61, 0.39))], "created_at": "2026-07-23T08:00:00", "updated_at": "2026-07-23T08:00:00"},
					{"id": "stroke_capture_reinforce", "stroke_type": "reinforcement", "label": "援军驰援", "points": [_capture_v3_xy(Vector2(0.76, 0.62)), _capture_v3_xy(Vector2(0.69, 0.54)), _capture_v3_xy(Vector2(0.61, 0.48))], "created_at": "2026-07-23T08:00:00", "updated_at": "2026-07-23T08:00:00"},
					{"id": "stroke_capture_plan", "stroke_type": "plan", "label": "迂回设想", "points": [_capture_v3_xy(Vector2(0.36, 0.45)), _capture_v3_xy(Vector2(0.41, 0.35)), _capture_v3_xy(Vector2(0.50, 0.31))], "created_at": "2026-07-23T08:00:00", "updated_at": "2026-07-23T08:00:00"}
				]
		if capture_mode and not capture_scenario_id.is_empty():
			var capture_candidate := _build_capture_scenario_candidate(capture_scenario_id)
			if not bool(capture_candidate.get("ok", false)):
				push_error(str(capture_candidate.get("message", "截图剧本无效。")))
				get_tree().quit(2)
				return
			var capture_template: Dictionary = capture_candidate.get("template", {})
			placements = (capture_candidate.get("placements", {}) as Dictionary).duplicate(true)
			annotations = (capture_candidate.get("annotations", {}) as Dictionary).duplicate(true)
			scenario_state = (capture_candidate.get("scenario_state", _empty_scenario_state()) as Dictionary).duplicate(true)
			sandbox_metadata["title"] = str(capture_template.get("title", capture_template.get("name", "确定性截图沙盘")))
			sandbox_metadata["scenario_source"] = str(capture_template.get("scenario_source", ""))
		elif drag_benchmark_mode:
			var benchmark_candidate := _build_capture_scenario_candidate("coalition_190")
			if not bool(benchmark_candidate.get("ok", false)):
				push_error(str(benchmark_candidate.get("message", "拖拽基准剧本无效。")))
				get_tree().quit(2)
				return
			scenario_state = (benchmark_candidate.get("scenario_state", _empty_scenario_state()) as Dictionary).duplicate(true)
			sandbox_metadata["title"] = "拖拽基准 · 讨董联盟"

	_refresh_views()
	_refresh_sandbox_identity_view()
	_update_history_buttons()
	if not loaded_camera.is_empty():
		map_board.set_camera_state(loaded_camera)
	if _save_writes_blocked:
		if _primary_recovery_can_confirm():
			_set_status("当前沙盘暂时打不开 · 找到一份可恢复版本")
		else:
			_set_status("当前沙盘暂时打不开 · 原文件没有改动")
	elif drag_benchmark_mode:
		_set_status("拖拽基准：%d%% 真实渲染帧采集中" % roundi(drag_benchmark_zoom * 100.0))
	elif test_mode:
		_set_pass_symbol_review_status()
	else:
		_set_status("沙盘已就绪：从左侧拖出人物卡")

	if capture_mode and not placements.is_empty():
		map_board._on_map_card_selected("liu_bei")
	if drag_benchmark_mode:
		call_deferred("_run_drag_benchmark")
	elif capture_mode:
		call_deferred("_capture_after_frames")
	elif test_mode and not ui_review_dialog.is_empty():
		call_deferred("_open_ui_review_dialog_after_frames")
	if get_tree().has_meta(OPEN_SNAPSHOTS_META):
		var open_snapshots_after_title := bool(get_tree().get_meta(OPEN_SNAPSHOTS_META, false))
		get_tree().remove_meta(OPEN_SNAPSHOTS_META)
		if open_snapshots_after_title and not capture_mode and not drag_benchmark_mode:
			call_deferred("_open_snapshot_manager")
	if get_tree().has_meta(OPEN_NEW_SANDBOX_META):
		var open_new_sandbox_after_title := bool(get_tree().get_meta(OPEN_NEW_SANDBOX_META, false))
		get_tree().remove_meta(OPEN_NEW_SANDBOX_META)
		if open_new_sandbox_after_title and not capture_mode and not drag_benchmark_mode and not _save_writes_blocked:
			call_deferred("_open_new_sandbox_dialog")
	if _save_writes_blocked and (not automated_test_mode or automated_primary_recovery_prompt) and not capture_mode and not drag_benchmark_mode:
		if _primary_recovery_can_confirm():
			call_deferred("_open_primary_recovery_dialog")
		else:
			call_deferred("_show_primary_recovery_unavailable_notice")


func _open_ui_review_dialog_after_frames() -> void:
	# 真实窗口复核入口：只允许测试模式使用，避免正式游玩被命令行参数改写。
	# 它不写入存档，只把指定界面打开在原生根窗口中，供 DPI/系统主题检查。
	for _frame in range(3):
		await get_tree().process_frame
	match ui_review_dialog:
		"place-search":
			_open_place_search_dialog()
			place_search_input.text = "南郑"
			_refresh_place_search_results()
		"scenario-editor-empty-40":
			scenario_state = _capture_custom_scenario_state([], [])
			_open_scenario_editor()
		"scenario-editor":
			_open_scenario_editor()
		_:
			push_warning("忽略未知真实窗口复核界面：%s" % ui_review_dialog)


func _parse_capture_window_size(value: String) -> Vector2i:
	var normalized := value.strip_edges().to_lower()
	var parts := normalized.split("x", false)
	if parts.size() != 2:
		return Vector2i.ZERO
	var width_text := str(parts[0]).strip_edges()
	var height_text := str(parts[1]).strip_edges()
	if not width_text.is_valid_int() or not height_text.is_valid_int():
		return Vector2i.ZERO
	var requested := Vector2i(width_text.to_int(), height_text.to_int())
	return requested if requested in [Vector2i(1366, 768), Vector2i(1920, 1080)] else Vector2i.ZERO


func _attach_capture_surface() -> void:
	if not capture_mode or capture_window_size == Vector2i.ZERO or _capture_surface != null:
		return
	var host_window := get_window()
	_capture_surface = SubViewport.new()
	_capture_surface.name = "CaptureSurface"
	_capture_surface.size = capture_window_size
	_capture_surface.disable_3d = true
	_capture_surface.gui_embed_subwindows = true
	_capture_surface.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_capture_surface.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	host_window.add_child(_capture_surface)
	reparent(_capture_surface, false)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func get_capture_window_contract() -> Dictionary:
	return {
		"requested_size": capture_window_size,
		"allowed_sizes": [Vector2i(1366, 768), Vector2i(1920, 1080)],
		"capture_only": true,
		"affects_save": false,
		"state_initialization": "deterministic_in_memory",
		"save_path": save_path
	}


func get_runtime_profile_contract() -> Dictionary:
	return {
		"profile_id": runtime_profile_id,
		"isolated_catalog_v4_runtime": isolated_catalog_v4_runtime,
		"character_data_root": runtime_character_data_root,
		"save_version": runtime_save_version,
		"current_character_catalog_version": runtime_current_character_catalog_version,
		"previous_character_catalog_version": runtime_previous_character_catalog_version,
		"previous_character_catalog_count": runtime_previous_character_catalog_count,
		"previous_character_catalog_min_save_version": runtime_previous_character_catalog_min_save_version,
		"previous_character_catalog_max_save_version": runtime_previous_character_catalog_max_save_version,
		"historical_character_catalog_counts": runtime_historical_character_catalog_counts.duplicate(),
		"historical_character_catalog_max_save_versions": runtime_historical_character_catalog_max_save_versions.duplicate(),
		"loaded_character_catalog_version": character_catalog_version,
		"loaded_character_count": characters.size(),
		"save_path": save_path,
		"preferences_path": preferences_path,
		"snapshot_store_path": snapshot_store_path,
		"personal_template_store_path": personal_template_store_path,
		"backup_dir": backup_dir,
		"presentation_mode": CHARACTER_PRESENTATION_MODE,
		"portrait_registry_loaded": not character_portraits_by_id.is_empty(),
		"formal_data_write_permitted": false,
	}


func _apply_theme() -> void:
	theme = UiThemeScript.build_base_theme(16)


func _build_interface() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = UiThemeScript.BACKGROUND_APP
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 18)
	outer.add_theme_constant_override("margin_right", 18)
	outer.add_theme_constant_override("margin_top", 16)
	outer.add_theme_constant_override("margin_bottom", 16)
	add_child(outer)

	var shell := VBoxContainer.new()
	shell.name = "ApplicationShell"
	shell.add_theme_constant_override("separation", 14)
	outer.add_child(shell)

	var toolbar := _build_toolbar()
	shell.add_child(toolbar)

	simulation_session_bar = _build_simulation_session_bar()
	shell.add_child(simulation_session_bar)

	var content := HBoxContainer.new()
	content.name = "ContentArea"
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	shell.add_child(content)

	backpack_host = VBoxContainer.new()
	backpack_host.name = "BackpackHost"
	backpack_host.custom_minimum_size = Vector2(292, 0)
	backpack_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(backpack_host)

	backpack = BackpackPanelScript.new()
	backpack.name = "BackpackPanel"
	backpack.character_returned.connect(_on_character_returned)
	backpack.favorite_toggled.connect(_on_favorite_toggled)
	backpack.placed_character_focus_requested.connect(_on_backpack_placed_character_focus_requested)
	backpack.character_details_requested.connect(_on_backpack_character_details_requested)
	backpack.hand_candidate_changed.connect(_on_backpack_hand_candidate_changed)
	backpack.hand_candidate_limit_reached.connect(_on_backpack_hand_candidate_limit_reached)
	backpack.scenario_take_completed.connect(_on_backpack_scenario_take_completed)
	backpack.collapse_requested.connect(_collapse_backpack)
	backpack_host.add_child(backpack)

	backpack_restore_button = Button.new()
	backpack_restore_button.name = "RestoreBackpackButton"
	backpack_restore_button.text = "人\n物\n背\n包\n›"
	backpack_restore_button.tooltip_text = "展开人物背包"
	backpack_restore_button.custom_minimum_size = Vector2(64, 0)
	backpack_restore_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	backpack_restore_button.focus_mode = Control.FOCUS_ALL
	backpack_restore_button.visible = false
	backpack_restore_button.pressed.connect(_expand_backpack)
	backpack_host.add_child(backpack_restore_button)

	map_board = MapBoardScript.new()
	map_board.name = "MapBoard"
	map_board.character_dropped.connect(_on_character_dropped)
	map_board.character_drag_released.connect(_on_map_character_drag_released)
	map_board.character_group_drag_released.connect(_on_map_character_group_drag_released)
	map_board.character_selected.connect(_on_map_character_selected)
	map_board.character_selection_changed.connect(_on_map_character_selection_changed)
	map_board.character_return_requested.connect(_on_character_returned)
	map_board.character_details_requested.connect(_on_character_details_requested)
	map_board.character_attributes_requested.connect(_on_character_attributes_requested)
	map_board.character_troops_requested.connect(_on_character_troops_requested)
	map_board.character_troop_adjust_requested.connect(_on_character_troop_adjust_requested)
	map_board.character_action_requested.connect(_on_character_action_requested)
	map_board.character_group_action_requested.connect(_on_character_group_action_requested)
	map_board.character_group_return_requested.connect(_on_character_group_returned)
	map_board.character_faction_assignment_requested.connect(_on_character_faction_assignment_requested)
	map_board.city_faction_window_toggled.connect(_on_city_faction_window_toggled)
	map_board.city_faction_rename_requested.connect(_on_city_faction_rename_requested)
	map_board.faction_legend_requested.connect(_on_faction_legend_requested)
	map_board.simulation_session_end_requested.connect(_open_simulation_session_end_dialog)
	map_board.zoom_changed.connect(_on_zoom_changed)
	map_board.annotation_create_requested.connect(_on_annotation_create_requested)
	map_board.annotation_drag_released.connect(_on_annotation_drag_released)
	map_board.annotation_edit_requested.connect(_on_annotation_edit_requested)
	map_board.annotation_delete_requested.connect(_on_annotation_delete_requested)
	map_board.annotation_tool_changed.connect(_on_annotation_tool_changed)
	map_board.annotation_type_visibility_changed.connect(_on_annotation_type_visibility_changed)
	map_board.annotation_focused.connect(_on_annotation_focused)
	map_board.annotation_focus_unavailable.connect(_on_annotation_focus_unavailable)
	map_board.player_stroke_draft_completed.connect(_on_player_stroke_draft_completed)
	map_board.player_stroke_edit_requested.connect(_on_player_stroke_edit_requested)
	map_board.player_stroke_geometry_edit_completed.connect(_on_player_stroke_geometry_edit_completed)
	map_board.player_stroke_delete_requested.connect(_on_player_stroke_delete_requested)
	map_board.player_stroke_tool_changed.connect(_on_player_stroke_tool_changed)
	map_board.player_stroke_focused.connect(_on_player_stroke_focused)
	map_board.player_stroke_focus_unavailable.connect(_on_player_stroke_focus_unavailable)
	map_board.place_details_requested.connect(_on_place_details_requested)
	map_board.city_ownership_place_requested.connect(_on_city_ownership_place_requested)
	map_board.city_ownership_hover_changed.connect(_on_city_ownership_hover_changed)
	map_board.historical_context_details_requested.connect(_on_historical_context_details_requested)
	map_board.strategic_corridors_visibility_changed.connect(_on_strategic_corridors_visibility_changed)
	map_board.historical_context_layer_visibility_changed.connect(_on_historical_context_layer_visibility_changed)
	map_board.resized.connect(_position_current_place_detail_panel)
	content.add_child(map_board)
	_build_place_detail_panel()
	_build_city_ownership_tool_ui()
	map_board.set_pass_symbol_variant(pass_symbol_variant)
	map_board.set_terrain_relief_variant(terrain_relief_variant)
	map_board.set_terrain_visual_profile(terrain_visual_profile)
	map_board.set_data(
		characters,
		places,
		routes,
		placements,
		land_data,
		river_data,
		lake_data,
		mountains,
		geographic_context_records
	)
	map_board.set_scenario_state(scenario_state)
	map_board.set_character_states(_display_character_attributes())
	map_board.set_character_actions(character_actions)
	map_board.set_character_troops(character_troops)
	map_board.set_character_portraits(character_portraits_by_id)
	if not capture_near_hachures_override.is_empty():
		map_board.set_near_hachures_visible(capture_near_hachures_override == "on")
	map_board.set_historical_context_layers(historical_context_layers)
	map_board.set_scenario_context(_current_scenario_context_contract())
	if capture_historical_context:
		map_board.set_historical_context_layer_visible(capture_historical_context_layer_id, true)
	backpack.set_characters(characters)
	backpack.set_favorites(favorite_character_ids)
	_build_character_detail_dialog()
	_build_current_roster_dialog()
	_build_character_attribute_dialog()
	_build_character_troop_dialog()
	_build_annotation_dialog()
	_build_player_stroke_dialogs()
	_build_sandbox_file_dialogs()
	_build_simulation_session_dialogs()
	_apply_shared_dialog_visual_language()
	# ScrollContainer、ItemList、RichTextLabel 以及 Tree 的内部滚动条
	# 都在运行时生成；统一在布局完成后扩大鼠标命中区与键盘焦点区。
	call_deferred("_style_secondary_scrollbars")


func _apply_shared_dialog_visual_language() -> void:
	var dialogs: Array[AcceptDialog] = []
	_collect_shared_dialogs(self, dialogs)
	for dialog in dialogs:
		_bind_dialog_visual_language(dialog)


func _collect_shared_dialogs(node: Node, output: Array[AcceptDialog]) -> void:
	for child in node.get_children():
		if child is AcceptDialog:
			output.append(child as AcceptDialog)
		_collect_shared_dialogs(child, output)


func _bind_dialog_visual_language(dialog: AcceptDialog) -> void:
	_refresh_dialog_visual_language(dialog)
	var refresh_callback := _refresh_dialog_visual_language.bind(dialog)
	if not dialog.about_to_popup.is_connected(refresh_callback):
		dialog.about_to_popup.connect(refresh_callback)


func _refresh_dialog_visual_language(dialog: AcceptDialog) -> void:
	if not is_instance_valid(dialog):
		return
	# 不只在创建时设置一次。真实 Windows 根窗口、场景往返和嵌套弹窗都可能
	# 让 Window 表面回落为 Godot 默认深灰，而子控件仍保留深墨文字。
	# 每次打开前重申主题与三类窗口底板，确保实际操作路径和截图路径一致。
	dialog.theme = theme
	UiThemeScript.apply_dialog_surface(dialog)
	call_deferred("_style_secondary_scrollbars")


func _style_secondary_scrollbars() -> void:
	if not is_inside_tree():
		return
	UiThemeScript.style_accessible_scrollbars_in(self)
	_update_scenario_character_scroll_navigation()


func _make_scenario_scroll_navigation_button(
	text_value: String,
	tooltip_text: String,
	node_name: String
) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text_value
	button.custom_minimum_size = Vector2(34, 32)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.tooltip_text = tooltip_text
	UiThemeScript.apply_toolbar_button_style(button, false)
	return button


func _scenario_character_scroll_limit() -> float:
	if scenario_character_scroll == null or not is_instance_valid(scenario_character_scroll):
		return 0.0
	var scroll_bar := scenario_character_scroll.get_v_scroll_bar()
	if scroll_bar == null:
		return 0.0
	return maxf(0.0, float(scroll_bar.max_value) - float(scroll_bar.page))


func _update_scenario_character_scroll_navigation() -> void:
	if scenario_character_scroll == null or not is_instance_valid(scenario_character_scroll):
		return
	var limit := _scenario_character_scroll_limit()
	var can_scroll := limit > 0.5
	var at_top := float(scenario_character_scroll.scroll_vertical) <= 0.5
	var at_bottom := float(scenario_character_scroll.scroll_vertical) >= limit - 0.5
	if scenario_character_scroll_top_button != null and is_instance_valid(scenario_character_scroll_top_button):
		scenario_character_scroll_top_button.disabled = not can_scroll or at_top
	if scenario_character_scroll_bottom_button != null and is_instance_valid(scenario_character_scroll_bottom_button):
		scenario_character_scroll_bottom_button.disabled = not can_scroll or at_bottom
	if scenario_character_scroll_range_label != null and is_instance_valid(scenario_character_scroll_range_label):
		var total := scenario_character_rows.get_child_count() if scenario_character_rows != null else 0
		var position_label := "顶部" if at_top else ("末尾" if at_bottom else "浏览中")
		scenario_character_scroll_range_label.text = "%d 人 · %s" % [total, position_label]


func _scroll_scenario_characters_to_top() -> void:
	if scenario_character_scroll == null or not is_instance_valid(scenario_character_scroll):
		return
	scenario_character_scroll.scroll_vertical = 0
	_update_scenario_character_scroll_navigation()


func _scroll_scenario_characters_to_bottom() -> void:
	if scenario_character_scroll == null or not is_instance_valid(scenario_character_scroll):
		return
	scenario_character_scroll.scroll_vertical = ceili(_scenario_character_scroll_limit())
	_update_scenario_character_scroll_navigation()


func _scroll_scenario_characters_page(direction: int) -> void:
	if scenario_character_scroll == null or direction == 0:
		return
	var scroll_bar := scenario_character_scroll.get_v_scroll_bar()
	if scroll_bar == null:
		return
	var page := maxf(float(scroll_bar.page), 96.0)
	var target := clampf(
		float(scenario_character_scroll.scroll_vertical) + page * float(signi(direction)),
		0.0,
		_scenario_character_scroll_limit()
	)
	scenario_character_scroll.scroll_vertical = roundi(target)
	_update_scenario_character_scroll_navigation()


func _on_scenario_character_scroll_gui_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	match key_event.keycode:
		KEY_HOME:
			_scroll_scenario_characters_to_top()
			get_viewport().set_input_as_handled()
		KEY_END:
			_scroll_scenario_characters_to_bottom()
			get_viewport().set_input_as_handled()
		KEY_PAGEUP:
			_scroll_scenario_characters_page(-1)
			get_viewport().set_input_as_handled()
		KEY_PAGEDOWN:
			_scroll_scenario_characters_page(1)
			get_viewport().set_input_as_handled()


func _on_scenario_character_scroll_value_changed(_value: float) -> void:
	_update_scenario_character_scroll_navigation()


func _on_scenario_character_scroll_layout_changed() -> void:
	call_deferred("_style_secondary_scrollbars")
	call_deferred("_update_scenario_character_scroll_navigation")


func _build_toolbar() -> PanelContainer:
	var toolbar := PanelContainer.new()
	toolbar.name = "Toolbar"
	toolbar.custom_minimum_size = Vector2(0, 68)
	var style := UiThemeScript.make_shell_panel(
		UiThemeScript.INK_SHELL,
		UiThemeScript.BORDER_SHELL,
		2,
		3,
		4
	)
	toolbar.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	toolbar.add_child(margin)

	var row := HBoxContainer.new()
	row.name = "ToolbarRow"
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 1)
	row.add_child(title_box)

	var title := Label.new()
	title.text = str(ProjectSettings.get_setting("application/config/name", "三国推演志"))
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	title_box.add_child(title)

	sandbox_subtitle_label = Label.new()
	sandbox_subtitle_label.text = "未命名沙盘 · 自由推演"
	sandbox_subtitle_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	sandbox_subtitle_label.add_theme_font_size_override("font_size", 13)
	sandbox_subtitle_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	title_box.add_child(sandbox_subtitle_label)

	status_label = Label.new()
	status_label.custom_minimum_size = Vector2(260, 0)
	status_label.clip_text = true
	status_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 13)
	status_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUCCESS)
	row.add_child(status_label)

	detail_label = Label.new()
	detail_label.text = "天下"
	detail_label.custom_minimum_size = Vector2(46, 0)
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	detail_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	detail_label.tooltip_text = "滚轮缩放后，地图会依次展开战区和城池细节"
	row.add_child(detail_label)

	zoom_label = Label.new()
	zoom_label.text = "100%"
	zoom_label.custom_minimum_size = Vector2(58, 0)
	zoom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zoom_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	zoom_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	row.add_child(zoom_label)

	undo_button = _make_button("撤销", false, 56)
	undo_button.pressed.connect(_on_undo_pressed)
	row.add_child(undo_button)

	redo_button = _make_button("重做", false, 56)
	redo_button.pressed.connect(_on_redo_pressed)
	row.add_child(redo_button)

	var home_button := _make_button("地图归位")
	home_button.name = "MapHomeButton"
	home_button.tooltip_text = "回到汉地核心战区，便于查看城池与人物（Home）"
	home_button.pressed.connect(_on_home_pressed)
	row.add_child(home_button)

	annotation_button = _make_button("＋绘制", false, 84)
	annotation_button.tooltip_text = "放置玩家标记，或画出进军、援军、撤退和计划线"
	annotation_button.pressed.connect(_on_draw_tool_button_pressed)
	row.add_child(annotation_button)
	draw_tool_popup = PopupMenu.new()
	draw_tool_popup.name = "DrawToolPopup"
	draw_tool_popup.add_item("放置点标记", 1)
	draw_tool_popup.add_item("绘制推演线…", 2)
	draw_tool_popup.id_pressed.connect(_on_draw_tool_popup_pressed)
	add_child(draw_tool_popup)

	sandbox_file_menu = MenuButton.new()
	sandbox_file_menu.text = "沙盘 ▾"
	sandbox_file_menu.focus_mode = Control.FOCUS_ALL
	sandbox_file_menu.custom_minimum_size = Vector2(92, 38)
	sandbox_file_menu.tooltip_text = "管理当前沙盘、开局分享、阶段快照与备份文件"
	_apply_toolbar_button_style(sandbox_file_menu, false)
	var file_popup := sandbox_file_menu.get_popup()
	file_popup.add_item("新建沙盘…", 7)
	file_popup.add_item("从当前局面另开…", 8)
	file_popup.add_separator()
	file_popup.add_item("定位地图地点…    Ctrl+G", PLACE_SEARCH_MENU_ID)
	file_popup.set_item_tooltip(
		file_popup.get_item_index(PLACE_SEARCH_MENU_ID),
		"按城池、关隘、战场或汉末旧称查找，并把它带到当前视野"
	)
	file_popup.add_item("本局人物一览…", CURRENT_ROSTER_MENU_ID)
	file_popup.set_item_tooltip(
		file_popup.get_item_index(CURRENT_ROSTER_MENU_ID),
		"按玩法势力查看当前已摆人物的地点、行动和兵力"
	)
	map_visual_profile_menu = PopupMenu.new()
	map_visual_profile_menu.name = "MapVisualProfileSubmenu"
	map_visual_profile_menu.add_radio_check_item("明亮白昼（默认）", MAP_VISUAL_DAYLIGHT_MENU_ID)
	map_visual_profile_menu.add_radio_check_item("古地图地形（试用）", MAP_VISUAL_ANTIQUE_MENU_ID)
	map_visual_profile_menu.add_radio_check_item("青绿微像素（试用）", MAP_VISUAL_JADE_MENU_ID)
	map_visual_profile_menu.set_item_tooltip(map_visual_profile_menu.get_item_index(MAP_VISUAL_JADE_MENU_ID), "保留原地图：青绿调色、地形明暗与近景轻色阶；不影响文字，仅当前会话生效")
	map_visual_profile_menu.set_item_tooltip(
		map_visual_profile_menu.get_item_index(MAP_VISUAL_DAYLIGHT_MENU_ID),
		"清亮浅绢、清晰城名；项目默认地图外观"
	)
	map_visual_profile_menu.set_item_tooltip(
		map_visual_profile_menu.get_item_index(MAP_VISUAL_ANTIQUE_MENU_ID),
		"使用现有离线地形数据增强山川层次；只影响当前会话显示"
	)
	map_visual_profile_menu.id_pressed.connect(_on_map_visual_profile_menu_pressed)
	file_popup.add_child(map_visual_profile_menu)
	file_popup.add_submenu_node_item("地图外观", map_visual_profile_menu, MAP_VISUAL_PROFILE_SUBMENU_ID)
	file_popup.set_item_tooltip(
		file_popup.get_item_index(MAP_VISUAL_PROFILE_SUBMENU_ID),
		"保持当前镜头和沙盘，直接比较两种离线地图外观"
	)
	_sync_map_visual_profile_menu()
	file_popup.add_check_item("显示地图工具（取消勾选可让出地图）", MAP_TOOLS_VISIBLE_MENU_ID)
	file_popup.set_item_checked(file_popup.get_item_index(MAP_TOOLS_VISIBLE_MENU_ID), true)
	file_popup.add_separator()
	file_popup.add_item("编辑沙盘信息…", 1)
	file_popup.add_item("编辑玩法分组…", 10)
	file_popup.add_item("玩家纪事…    Ctrl+J", 11)
	file_popup.set_item_tooltip(
		file_popup.get_item_index(11),
		"打开本局玩家纪事；空列表时可直接按 Enter 写一则（Ctrl+J）"
	)
	file_popup.add_item("开始一次推演…", 14)
	file_popup.add_item("保存当前沙盘    Ctrl+S", 2)
	var save_item_index := file_popup.get_item_index(2)
	file_popup.set_item_icon(save_item_index, SAVE_ICON)
	file_popup.set_item_icon_max_width(save_item_index, SYSTEM_ICON_SIZE)
	file_popup.set_item_icon_modulate(save_item_index, UiThemeScript.TEXT_BUTTON)
	file_popup.set_item_tooltip(save_item_index, "安全保存当前沙盘（Ctrl+S）")
	file_popup.add_item("留住此刻    Ctrl+Shift+S", QUICK_SITUATION_BOOKMARK_MENU_ID)
	file_popup.set_item_tooltip(
		file_popup.get_item_index(QUICK_SITUATION_BOOKMARK_MENU_ID),
		"一键留下当前局面，并自动记录与同一沙盘上次留存相比的变化（Ctrl+Shift+S）"
	)
	file_popup.add_item("保存为我的起步模板…", 9)
	file_popup.add_item("导出当前开局包…", 15)
	file_popup.add_item("导入开局包…", 16)
	file_popup.add_separator()
	file_popup.add_item("创建命名快照…", 3)
	file_popup.add_item("查看命名快照…", 4)
	file_popup.add_separator()
	file_popup.add_item("备份到文件…", 5)
	file_popup.add_item("从备份继续…", 6)
	file_popup.add_item("恢复上一份沙盘…", 13)
	file_popup.set_item_disabled(file_popup.get_item_index(13), not _primary_recovery_can_confirm())
	file_popup.add_separator()
	file_popup.add_item("返回标题", 12)
	file_popup.id_pressed.connect(_on_sandbox_file_menu_pressed)
	row.add_child(sandbox_file_menu)

	var clear_button := _make_button("收回人物", true)
	clear_button.tooltip_text = "把地图人物全部收回背包；标记、便签和推演线保留"
	clear_button.pressed.connect(_on_clear_pressed)
	row.add_child(clear_button)

	return toolbar


func _build_simulation_session_bar() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "SimulationSessionBar"
	panel.visible = false
	panel.custom_minimum_size = Vector2(0, 58)
	panel.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_record_panel(0.98, 3, Vector4(14, 8, 12, 8))
	)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 0)
	row.add_child(title_box)
	simulation_session_title_label = Label.new()
	simulation_session_title_label.text = "正在推演"
	simulation_session_title_label.add_theme_font_size_override("font_size", 18)
	simulation_session_title_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	title_box.add_child(simulation_session_title_label)
	simulation_session_meta_label = Label.new()
	simulation_session_meta_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	simulation_session_meta_label.add_theme_font_size_override("font_size", 13)
	simulation_session_meta_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	title_box.add_child(simulation_session_meta_label)

	var route_button := _make_button("画本次路线", false, 104)
	route_button.tooltip_text = "按本次推演类型选用线型，在地图上自由落点"
	route_button.pressed.connect(_open_active_session_route)
	row.add_child(route_button)
	var end_button := _make_button("结束并复盘", false, 104)
	end_button.tooltip_text = "比较起点与当前局面，写入一则纪事并可留存终点快照"
	end_button.pressed.connect(_open_simulation_session_end_dialog)
	row.add_child(end_button)
	var cancel_button := _make_button("取消助手", true, 88)
	cancel_button.tooltip_text = "关闭流程提示；地图修改和起点快照继续保留"
	cancel_button.pressed.connect(_open_simulation_session_cancel_dialog)
	row.add_child(cancel_button)
	return panel


func _build_simulation_session_dialogs() -> void:
	simulation_session_start_dialog = ConfirmationDialog.new()
	simulation_session_start_dialog.title = "开始一次推演"
	simulation_session_start_dialog.min_size = Vector2i(640, 500)
	simulation_session_start_dialog.ok_button_text = "留存起点并开始"
	simulation_session_start_dialog.cancel_button_text = "取消"
	simulation_session_start_dialog.confirmed.connect(_confirm_start_simulation_session)
	add_child(simulation_session_start_dialog)
	var start_column := VBoxContainer.new()
	start_column.custom_minimum_size = Vector2(600, 0)
	start_column.add_theme_constant_override("separation", 9)
	simulation_session_start_dialog.add_child(start_column)
	var start_hint := Label.new()
	start_hint.text = "把这一段桌面推演单独记下来。开始时自动保存起点；之后人物、兵力、势力、城池、标记和路线仍由你自由调整。"
	start_hint.custom_minimum_size = Vector2(590, 44)
	start_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	start_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	start_column.add_child(start_hint)
	var name_label := Label.new()
	name_label.text = "本次推演名称"
	name_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	start_column.add_child(name_label)
	simulation_session_name_input = LineEdit.new()
	simulation_session_name_input.max_length = MAX_SIMULATION_SESSION_NAME_LENGTH
	simulation_session_name_input.placeholder_text = "例如：刘备试攻广宗"
	start_column.add_child(simulation_session_name_input)

	var type_time_row := HBoxContainer.new()
	type_time_row.add_theme_constant_override("separation", 10)
	start_column.add_child(type_time_row)
	var type_box := VBoxContainer.new()
	type_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_time_row.add_child(type_box)
	var type_label := Label.new()
	type_label.text = "推演类型"
	type_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	type_box.add_child(type_label)
	simulation_session_type_select = OptionButton.new()
	for option in [
		{"label": "进军／交战", "value": "advance"},
		{"label": "援军／会合", "value": "reinforcement"},
		{"label": "撤退／转移", "value": "retreat"},
		{"label": "谋划／其他", "value": "plan"},
		{"label": "攻城（玩家裁定）", "value": "siege"},
	]:
		simulation_session_type_select.add_item(str(option["label"]))
		simulation_session_type_select.set_item_metadata(simulation_session_type_select.item_count - 1, str(option["value"]))
	simulation_session_type_select.item_selected.connect(_on_simulation_session_type_selected)
	type_box.add_child(simulation_session_type_select)
	var time_box := VBoxContainer.new()
	time_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_time_row.add_child(time_box)
	var time_label := Label.new()
	time_label.text = "时间标签（可选）"
	time_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	time_box.add_child(time_label)
	simulation_session_time_input = LineEdit.new()
	simulation_session_time_input.max_length = MAX_SIMULATION_SESSION_TIME_LENGTH
	simulation_session_time_input.placeholder_text = "例如：中平元年春"
	time_box.add_child(simulation_session_time_input)

	var participants_title := Label.new()
	participants_title.text = "参与人物"
	participants_title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	start_column.add_child(participants_title)
	simulation_session_participants_label = Label.new()
	simulation_session_participants_label.custom_minimum_size = Vector2(590, 52)
	simulation_session_participants_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	simulation_session_participants_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	start_column.add_child(simulation_session_participants_label)

	simulation_session_siege_setup_panel = VBoxContainer.new()
	simulation_session_siege_setup_panel.name = "SiegeSetupPanel"
	simulation_session_siege_setup_panel.visible = false
	simulation_session_siege_setup_panel.add_theme_constant_override("separation", 6)
	start_column.add_child(simulation_session_siege_setup_panel)
	var siege_target_label := Label.new()
	siege_target_label.text = "攻城目标"
	siege_target_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	simulation_session_siege_setup_panel.add_child(siege_target_label)
	simulation_session_siege_target_select = OptionButton.new()
	simulation_session_siege_target_select.name = "SiegeTargetSelect"
	simulation_session_siege_target_select.item_selected.connect(_on_simulation_session_siege_target_selected)
	simulation_session_siege_setup_panel.add_child(simulation_session_siege_target_select)
	var siege_roster_hint := Label.new()
	siege_roster_hint.text = "给地图上的人物指定攻方或守方；选择城池时会先把驻城人物列为守方，你仍可逐人修改。"
	siege_roster_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	siege_roster_hint.add_theme_font_size_override("font_size", 13)
	siege_roster_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	simulation_session_siege_setup_panel.add_child(siege_roster_hint)
	var siege_roster_scroll := ScrollContainer.new()
	siege_roster_scroll.name = "SiegeRosterScroll"
	siege_roster_scroll.custom_minimum_size = Vector2(0, 150)
	siege_roster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	siege_roster_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	siege_roster_scroll.follow_focus = true
	UiThemeScript.style_accessible_scrollbar(
		siege_roster_scroll.get_v_scroll_bar(),
		"拖动查看攻城名单；也可用滚轮或 ↑↓"
	)
	simulation_session_siege_setup_panel.add_child(siege_roster_scroll)
	simulation_session_siege_roster = VBoxContainer.new()
	simulation_session_siege_roster.name = "SiegeRoster"
	simulation_session_siege_roster.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	simulation_session_siege_roster.add_theme_constant_override("separation", 4)
	siege_roster_scroll.add_child(simulation_session_siege_roster)

	simulation_session_initial_action_label = Label.new()
	simulation_session_initial_action_label.text = "开始后的统一行动（可选）"
	simulation_session_initial_action_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	start_column.add_child(simulation_session_initial_action_label)
	simulation_session_initial_action_select = OptionButton.new()
	for option in [
		{"label": "保持人物当前行动", "value": "keep"},
		{"label": "全部设为待命", "value": CHARACTER_ACTION_STANDBY},
		{"label": "全部设为进攻", "value": CHARACTER_ACTION_ATTACK},
		{"label": "全部设为防御", "value": CHARACTER_ACTION_DEFEND},
	]:
		simulation_session_initial_action_select.add_item(str(option["label"]))
		simulation_session_initial_action_select.set_item_metadata(simulation_session_initial_action_select.item_count - 1, str(option["value"]))
	start_column.add_child(simulation_session_initial_action_select)
	var start_boundary := Label.new()
	start_boundary.text = "未选择人物时，流程按全局局面推演开始；胜负由你裁定。"
	start_boundary.custom_minimum_size = Vector2(590, 36)
	start_boundary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	start_boundary.add_theme_font_size_override("font_size", 13)
	start_boundary.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	start_column.add_child(start_boundary)
	var start_actions := HBoxContainer.new()
	start_actions.alignment = BoxContainer.ALIGNMENT_END
	start_actions.add_theme_constant_override("separation", 10)
	start_column.add_child(start_actions)
	var start_cancel_button := _make_button("取消", false, 84)
	start_cancel_button.pressed.connect(simulation_session_start_dialog.hide)
	start_actions.add_child(start_cancel_button)
	var start_confirm_button := _make_button("留存起点并开始", false, 156)
	start_confirm_button.pressed.connect(
		func() -> void:
			simulation_session_start_dialog.hide()
			_confirm_start_simulation_session()
	)
	start_actions.add_child(start_confirm_button)
	simulation_session_start_dialog.get_ok_button().visible = false
	simulation_session_start_dialog.get_cancel_button().visible = false

	simulation_session_end_dialog = ConfirmationDialog.new()
	simulation_session_end_dialog.title = "结束本次推演"
	simulation_session_end_dialog.min_size = Vector2i(700, 590)
	simulation_session_end_dialog.ok_button_text = "写入复盘"
	simulation_session_end_dialog.cancel_button_text = "继续推演"
	simulation_session_end_dialog.confirmed.connect(_confirm_end_simulation_session)
	add_child(simulation_session_end_dialog)
	var end_column := VBoxContainer.new()
	end_column.add_theme_constant_override("separation", 8)
	simulation_session_end_dialog.add_child(end_column)
	var summary_title := Label.new()
	summary_title.text = "起点与当前局面的变化"
	summary_title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	end_column.add_child(summary_title)
	simulation_session_end_summary = RichTextLabel.new()
	simulation_session_end_summary.bbcode_enabled = true
	simulation_session_end_summary.fit_content = false
	simulation_session_end_summary.custom_minimum_size = Vector2(0, 210)
	simulation_session_end_summary.add_theme_color_override("default_color", UiThemeScript.TEXT_BODY)
	UiThemeScript.style_accessible_scrollbar(
		simulation_session_end_summary.get_v_scroll_bar(),
		"拖动查看局面变化摘要；也可用滚轮或 ↑↓"
	)
	end_column.add_child(simulation_session_end_summary)

	simulation_session_siege_resolution_panel = VBoxContainer.new()
	simulation_session_siege_resolution_panel.name = "SiegeResolutionPanel"
	simulation_session_siege_resolution_panel.visible = false
	simulation_session_siege_resolution_panel.add_theme_constant_override("separation", 6)
	end_column.add_child(simulation_session_siege_resolution_panel)
	var siege_result_row := HBoxContainer.new()
	siege_result_row.add_theme_constant_override("separation", 10)
	simulation_session_siege_resolution_panel.add_child(siege_result_row)
	var siege_outcome_box := VBoxContainer.new()
	siege_outcome_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	siege_result_row.add_child(siege_outcome_box)
	var siege_outcome_label := Label.new()
	siege_outcome_label.text = "玩家裁定"
	siege_outcome_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	siege_outcome_box.add_child(siege_outcome_label)
	simulation_session_siege_outcome_select = OptionButton.new()
	for option in [
		{"label": "进攻方取胜", "value": "attacker_win"},
		{"label": "防守方取胜", "value": "defender_win"},
		{"label": "双方罢战／平局", "value": "truce"},
		{"label": "进攻方主动撤退", "value": "attacker_retreat"},
		{"label": "防守方主动撤退", "value": "defender_retreat"},
		{"label": "尚未分出结果", "value": "unresolved"},
	]:
		simulation_session_siege_outcome_select.add_item(str(option["label"]))
		simulation_session_siege_outcome_select.set_item_metadata(simulation_session_siege_outcome_select.item_count - 1, str(option["value"]))
	simulation_session_siege_outcome_select.item_selected.connect(_on_simulation_session_siege_resolution_changed)
	siege_outcome_box.add_child(simulation_session_siege_outcome_select)
	var siege_handling_box := VBoxContainer.new()
	siege_handling_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	siege_result_row.add_child(siege_handling_box)
	var siege_handling_label := Label.new()
	siege_handling_label.text = "战败方处理"
	siege_handling_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	siege_handling_box.add_child(siege_handling_label)
	simulation_session_siege_handling_select = OptionButton.new()
	for option in [
		{"label": "保持人物当前位置", "value": "keep"},
		{"label": "战败方整方收回卡包", "value": "return_all"},
		{"label": "选择战败人物收回", "value": "return_selected"},
		{"label": "暂不处理，返回地图", "value": "defer"},
	]:
		simulation_session_siege_handling_select.add_item(str(option["label"]))
		simulation_session_siege_handling_select.set_item_metadata(simulation_session_siege_handling_select.item_count - 1, str(option["value"]))
	simulation_session_siege_handling_select.item_selected.connect(_on_simulation_session_siege_resolution_changed)
	siege_handling_box.add_child(simulation_session_siege_handling_select)

	var siege_owner_label := Label.new()
	siege_owner_label.text = "城池归属（默认保持，不随胜负自动改变）"
	siege_owner_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	simulation_session_siege_resolution_panel.add_child(siege_owner_label)
	simulation_session_siege_owner_select = OptionButton.new()
	simulation_session_siege_owner_select.name = "SiegeOwnerSelect"
	simulation_session_siege_resolution_panel.add_child(simulation_session_siege_owner_select)

	simulation_session_siege_return_panel = VBoxContainer.new()
	simulation_session_siege_return_panel.visible = false
	simulation_session_siege_return_panel.add_theme_constant_override("separation", 4)
	simulation_session_siege_resolution_panel.add_child(simulation_session_siege_return_panel)
	var siege_return_label := Label.new()
	siege_return_label.text = "勾选本次退场人物"
	siege_return_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	simulation_session_siege_return_panel.add_child(siege_return_label)
	var siege_return_scroll := ScrollContainer.new()
	siege_return_scroll.name = "SiegeReturnScroll"
	siege_return_scroll.custom_minimum_size = Vector2(0, 82)
	siege_return_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	siege_return_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	siege_return_scroll.follow_focus = true
	UiThemeScript.style_accessible_scrollbar(
		siege_return_scroll.get_v_scroll_bar(),
		"拖动查看退场人物；也可用滚轮或 ↑↓"
	)
	simulation_session_siege_return_panel.add_child(siege_return_scroll)
	simulation_session_siege_return_list = VBoxContainer.new()
	simulation_session_siege_return_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	siege_return_scroll.add_child(simulation_session_siege_return_list)
	var result_title_label := Label.new()
	result_title_label.text = "纪事标题"
	result_title_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	end_column.add_child(result_title_label)
	simulation_session_end_title_input = LineEdit.new()
	simulation_session_end_title_input.max_length = MAX_CHRONICLE_TITLE_LENGTH
	end_column.add_child(simulation_session_end_title_input)
	var note_label := Label.new()
	note_label.text = "你的结论或后续设定（可选）"
	note_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	end_column.add_child(note_label)
	simulation_session_end_note_input = TextEdit.new()
	simulation_session_end_note_input.custom_minimum_size = Vector2(0, 90)
	simulation_session_end_note_input.placeholder_text = "例如：暂定刘备军受挫，等待援军后再攻。"
	simulation_session_end_note_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	end_column.add_child(simulation_session_end_note_input)
	simulation_session_end_snapshot_check = CheckBox.new()
	simulation_session_end_snapshot_check.text = "同时保存“推演后”命名快照"
	simulation_session_end_snapshot_check.button_pressed = true
	end_column.add_child(simulation_session_end_snapshot_check)

	simulation_session_cancel_dialog = ConfirmationDialog.new()
	simulation_session_cancel_dialog.title = "取消本次流程助手？"
	simulation_session_cancel_dialog.min_size = Vector2i(520, 240)
	simulation_session_cancel_dialog.ok_button_text = "保留现状并关闭助手"
	simulation_session_cancel_dialog.cancel_button_text = "继续推演"
	simulation_session_cancel_dialog.dialog_text = "关闭流程提示后，地图和起点快照继续保留。要生成局面变化摘要，请先返回并选择“结束并复盘”。"
	simulation_session_cancel_dialog.confirmed.connect(_confirm_cancel_simulation_session)
	add_child(simulation_session_cancel_dialog)


func _build_annotation_dialog() -> void:
	annotation_dialog = ConfirmationDialog.new()
	annotation_dialog.title = "添加沙盘标记"
	annotation_dialog.min_size = Vector2i(480, 286)
	annotation_dialog.ok_button_text = "放好"
	annotation_dialog.cancel_button_text = "取消"
	annotation_dialog.confirmed.connect(_confirm_annotation_dialog)
	annotation_dialog.canceled.connect(_cancel_annotation_dialog)
	add_child(annotation_dialog)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	annotation_dialog.add_child(column)
	annotation_hint_label = Label.new()
	annotation_hint_label.text = "把自己的地点、事件或战术便签放在桌面上。\n右键标记可再次修改；援军、集结等标记建议选择所属势力。"
	annotation_hint_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	annotation_hint_label.add_theme_font_size_override("font_size", 14)
	annotation_hint_label.custom_minimum_size = Vector2(410, 42)
	column.add_child(annotation_hint_label)
	var kind_row := HBoxContainer.new()
	kind_row.add_theme_constant_override("separation", 10)
	column.add_child(kind_row)
	var kind_label := Label.new()
	kind_label.text = "类型"
	kind_label.custom_minimum_size = Vector2(64, 0)
	kind_label.add_theme_color_override("font_color", UiThemeScript.TEXT_FIELD)
	kind_row.add_child(kind_label)
	annotation_type_select = OptionButton.new()
	annotation_type_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	annotation_type_select.add_item("战术便签")
	annotation_type_select.add_item("地点（玩家自定）")
	annotation_type_select.add_item("事件（玩家自定）")
	annotation_type_select.item_selected.connect(_on_annotation_type_selected)
	kind_row.add_child(annotation_type_select)
	var faction_row := HBoxContainer.new()
	faction_row.add_theme_constant_override("separation", 10)
	column.add_child(faction_row)
	var faction_label := Label.new()
	faction_label.text = "所属势力"
	faction_label.custom_minimum_size = Vector2(64, 0)
	faction_label.add_theme_color_override("font_color", UiThemeScript.TEXT_FIELD)
	faction_row.add_child(faction_label)
	annotation_faction_select = OptionButton.new()
	annotation_faction_select.name = "AnnotationFactionSelect"
	annotation_faction_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	annotation_faction_select.tooltip_text = "可选；选择后地图标记会显示势力名并使用对应势力色"
	annotation_faction_select.item_selected.connect(_on_annotation_faction_selected)
	faction_row.add_child(annotation_faction_select)
	annotation_input = LineEdit.new()
	annotation_input.max_length = 24
	annotation_input.placeholder_text = "例如：援军从这里来"
	annotation_input.text_submitted.connect(_on_annotation_text_submitted)
	column.add_child(annotation_input)


func _build_current_roster_dialog() -> void:
	current_roster_dialog = AcceptDialog.new()
	current_roster_dialog.name = "CurrentRosterDialog"
	current_roster_dialog.title = "本局人物一览"
	current_roster_dialog.min_size = Vector2i(820, 560)
	current_roster_dialog.max_size = Vector2i(1040, 700)
	current_roster_dialog.unresizable = false
	current_roster_dialog.ok_button_text = "收起"
	add_child(current_roster_dialog)
	current_roster_dialog.get_ok_button().hide()

	var column := VBoxContainer.new()
	column.name = "CurrentRosterContent"
	column.add_theme_constant_override("separation", 10)
	current_roster_dialog.add_child(column)

	current_roster_summary_label = Label.new()
	current_roster_summary_label.name = "CurrentRosterSummary"
	current_roster_summary_label.text = "当前没有人物摆在地图上"
	current_roster_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_roster_summary_label.add_theme_font_size_override("font_size", 16)
	current_roster_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	column.add_child(current_roster_summary_label)

	var view_row := HBoxContainer.new()
	view_row.name = "CurrentRosterViewRow"
	view_row.custom_minimum_size = Vector2(0, 38)
	view_row.add_theme_constant_override("separation", 8)
	column.add_child(view_row)

	var view_label := Label.new()
	view_label.name = "CurrentRosterViewLabel"
	view_label.text = "整理方式"
	view_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	view_label.add_theme_font_size_override("font_size", 15)
	view_label.add_theme_color_override("font_color", UiThemeScript.TEXT_FIELD)
	view_row.add_child(view_label)

	current_roster_view_button_group = ButtonGroup.new()
	current_roster_view_button_group.allow_unpress = false
	current_roster_faction_view_button = Button.new()
	current_roster_faction_view_button.name = "CurrentRosterFactionViewButton"
	current_roster_faction_view_button.text = "按势力"
	current_roster_faction_view_button.tooltip_text = "按本局玩法势力整理已摆人物"
	current_roster_faction_view_button.custom_minimum_size = Vector2(96, 34)
	current_roster_faction_view_button.focus_mode = Control.FOCUS_ALL
	current_roster_faction_view_button.toggle_mode = true
	current_roster_faction_view_button.button_group = current_roster_view_button_group
	current_roster_faction_view_button.button_pressed = true
	current_roster_faction_view_button.pressed.connect(
		_on_current_roster_view_mode_pressed.bind(CURRENT_ROSTER_VIEW_FACTION)
	)
	_apply_toolbar_button_style(current_roster_faction_view_button, false)
	view_row.add_child(current_roster_faction_view_button)

	current_roster_place_view_button = Button.new()
	current_roster_place_view_button.name = "CurrentRosterPlaceViewButton"
	current_roster_place_view_button.text = "按地点"
	current_roster_place_view_button.tooltip_text = "按地图地点整理驻扎人物，自由落点单独归组"
	current_roster_place_view_button.custom_minimum_size = Vector2(96, 34)
	current_roster_place_view_button.focus_mode = Control.FOCUS_ALL
	current_roster_place_view_button.toggle_mode = true
	current_roster_place_view_button.button_group = current_roster_view_button_group
	current_roster_place_view_button.pressed.connect(
		_on_current_roster_view_mode_pressed.bind(CURRENT_ROSTER_VIEW_PLACE)
	)
	_apply_toolbar_button_style(current_roster_place_view_button, false)
	view_row.add_child(current_roster_place_view_button)

	var view_spacer := Control.new()
	view_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view_row.add_child(view_spacer)

	current_roster_empty_label = Label.new()
	current_roster_empty_label.name = "CurrentRosterEmpty"
	current_roster_empty_label.text = "地图上还没有人物。可以从左侧人物背包拖出第一张卡。"
	current_roster_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_roster_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	current_roster_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_roster_empty_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	current_roster_empty_label.add_theme_font_size_override("font_size", 19)
	current_roster_empty_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(current_roster_empty_label)

	current_roster_tree = Tree.new()
	current_roster_tree.name = "CurrentRosterTree"
	current_roster_tree.hide_root = true
	current_roster_tree.columns = 4
	current_roster_tree.column_titles_visible = true
	current_roster_tree.set_column_title(0, "人物")
	current_roster_tree.set_column_title(1, "地点")
	current_roster_tree.set_column_title(2, "行动")
	current_roster_tree.set_column_title(3, "兵力")
	current_roster_tree.set_column_expand(0, true)
	current_roster_tree.set_column_expand(1, true)
	current_roster_tree.set_column_expand(2, false)
	current_roster_tree.set_column_expand(3, false)
	current_roster_tree.set_column_custom_minimum_width(0, 250)
	current_roster_tree.set_column_custom_minimum_width(1, 170)
	current_roster_tree.set_column_custom_minimum_width(2, 90)
	current_roster_tree.set_column_custom_minimum_width(3, 120)
	current_roster_tree.custom_minimum_size = Vector2(800, 390)
	current_roster_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	current_roster_tree.select_mode = Tree.SELECT_ROW
	current_roster_tree.allow_reselect = true
	current_roster_tree.item_selected.connect(_on_current_roster_item_selected)
	current_roster_tree.item_activated.connect(_on_current_roster_item_activated)
	column.add_child(current_roster_tree)
	call_deferred("_style_current_roster_tree_scrollbars")

	var footer := HBoxContainer.new()
	footer.name = "CurrentRosterFooter"
	footer.custom_minimum_size = Vector2(0, 40)
	footer.add_theme_constant_override("separation", 10)
	column.add_child(footer)

	current_roster_locate_button = Button.new()
	current_roster_locate_button.name = "CurrentRosterLocateButton"
	current_roster_locate_button.text = "定位到地图"
	current_roster_locate_button.tooltip_text = "收起一览并在地图上定位所选人物"
	current_roster_locate_button.custom_minimum_size = Vector2(126, 36)
	current_roster_locate_button.focus_mode = Control.FOCUS_ALL
	current_roster_locate_button.disabled = true
	current_roster_locate_button.pressed.connect(_on_current_roster_locate_pressed)
	_apply_toolbar_button_style(current_roster_locate_button, false)
	footer.add_child(current_roster_locate_button)

	current_roster_profile_button = Button.new()
	current_roster_profile_button.name = "CurrentRosterProfileButton"
	current_roster_profile_button.text = "人物卡"
	current_roster_profile_button.tooltip_text = "查看所选人物资料，并可顺看本局已摆人物"
	current_roster_profile_button.custom_minimum_size = Vector2(100, 36)
	current_roster_profile_button.focus_mode = Control.FOCUS_ALL
	current_roster_profile_button.disabled = true
	current_roster_profile_button.pressed.connect(_on_current_roster_profile_pressed)
	_apply_toolbar_button_style(current_roster_profile_button, false)
	footer.add_child(current_roster_profile_button)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)

	var close_button := Button.new()
	close_button.name = "CurrentRosterCloseButton"
	close_button.text = "收起"
	close_button.tooltip_text = "收起本局人物一览"
	close_button.custom_minimum_size = Vector2(88, 36)
	close_button.focus_mode = Control.FOCUS_ALL
	close_button.pressed.connect(_close_current_roster_dialog)
	_apply_toolbar_button_style(close_button, false)
	footer.add_child(close_button)


func _style_current_roster_tree_scrollbars() -> void:
	if current_roster_tree == null or not is_instance_valid(current_roster_tree):
		return
	for node in current_roster_tree.find_children("*", "ScrollBar", true, false):
		var bar := node as ScrollBar
		if bar == null:
			continue
		var tooltip := "横向查看人物一览" if bar is HScrollBar else "拖动查看本局人物；也可用滚轮或 ↑↓"
		UiThemeScript.style_accessible_scrollbar(bar, tooltip)


func _build_character_detail_dialog() -> void:
	character_detail_dialog = AcceptDialog.new()
	character_detail_dialog.name = "CharacterDetailDialog"
	character_detail_dialog.title = "人物卡"
	character_detail_dialog.min_size = Vector2i(720, 570)
	character_detail_dialog.max_size = Vector2i(820, 660)
	character_detail_dialog.unresizable = true
	character_detail_dialog.ok_button_text = "收起"
	character_detail_dialog.confirmed.connect(_on_character_detail_dialog_closed)
	character_detail_dialog.canceled.connect(_on_character_detail_dialog_closed)
	character_detail_dialog.close_requested.connect(_on_character_detail_dialog_closed)
	character_detail_dialog.window_input.connect(_on_character_detail_dialog_input)
	UiThemeScript.set_dialog_variant(
		character_detail_dialog,
		UiThemeScript.DIALOG_VARIANT_RECORD
	)
	var dialog_style := StyleBoxFlat.new()
	dialog_style.bg_color = UiThemeScript.INK_RECORD_BASE
	dialog_style.border_color = UiThemeScript.BORDER_BRASS
	dialog_style.set_border_width_all(1)
	dialog_style.corner_radius_top_left = 8
	dialog_style.corner_radius_top_right = 8
	dialog_style.corner_radius_bottom_left = 8
	dialog_style.corner_radius_bottom_right = 8
	character_detail_dialog.add_theme_stylebox_override("panel", dialog_style)
	add_child(character_detail_dialog)
	character_detail_dialog.get_ok_button().hide()

	var detail_column := VBoxContainer.new()
	detail_column.name = "CharacterDetailContent"
	detail_column.add_theme_constant_override("separation", 8)
	character_detail_dialog.add_child(detail_column)

	var profile_row := HBoxContainer.new()
	profile_row.name = "CharacterProfileRow"
	profile_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	profile_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	profile_row.add_theme_constant_override("separation", 14)
	detail_column.add_child(profile_row)

	character_detail_nameplate = CharacterNameplateScript.new()
	character_detail_nameplate.name = "CharacterDetailNameplate"
	character_detail_nameplate.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	character_detail_nameplate.call(
		"configure",
		"人物",
		Color("8d6534"),
		Vector2(120, 120),
		false
	)
	profile_row.add_child(character_detail_nameplate)

	character_detail_text = RichTextLabel.new()
	character_detail_text.name = "CharacterDetailText"
	character_detail_text.bbcode_enabled = true
	character_detail_text.fit_content = false
	character_detail_text.scroll_active = true
	character_detail_text.selection_enabled = true
	character_detail_text.custom_minimum_size = Vector2(560, 424)
	character_detail_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_detail_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	character_detail_text.add_theme_font_size_override("normal_font_size", 16)
	character_detail_text.add_theme_constant_override("line_separation", 4)
	character_detail_text.add_theme_color_override("default_color", UiThemeScript.TEXT_BODY)
	UiThemeScript.style_accessible_scrollbar(
		character_detail_text.get_v_scroll_bar(),
		"拖动查看人物资料；也可用滚轮或 ↑↓"
	)
	profile_row.add_child(character_detail_text)

	character_detail_action_footer = HBoxContainer.new()
	character_detail_action_footer.name = "CharacterProfileActionFooter"
	character_detail_action_footer.custom_minimum_size = Vector2(0, 38)
	character_detail_action_footer.add_theme_constant_override("separation", 10)
	detail_column.add_child(character_detail_action_footer)

	character_detail_place_button = Button.new()
	character_detail_place_button.name = "CharacterProfilePlaceButton"
	character_detail_place_button.text = "查看落点"
	character_detail_place_button.tooltip_text = "定位人物当前驻点并打开地点札记"
	character_detail_place_button.custom_minimum_size = Vector2(112, 34)
	character_detail_place_button.focus_mode = Control.FOCUS_ALL
	character_detail_place_button.visible = false
	character_detail_place_button.pressed.connect(_on_character_profile_place_pressed)
	_apply_toolbar_button_style(character_detail_place_button, false)
	character_detail_action_footer.add_child(character_detail_place_button)

	character_detail_chronicle_button = Button.new()
	character_detail_chronicle_button.name = "CharacterProfileChronicleButton"
	character_detail_chronicle_button.text = "写纪事…"
	character_detail_chronicle_button.tooltip_text = "以当前人物为上下文写一则玩家纪事"
	character_detail_chronicle_button.custom_minimum_size = Vector2(96, 34)
	character_detail_chronicle_button.focus_mode = Control.FOCUS_ALL
	character_detail_chronicle_button.pressed.connect(_open_character_profile_chronicle_editor)
	_apply_toolbar_button_style(character_detail_chronicle_button, false)
	character_detail_action_footer.add_child(character_detail_chronicle_button)

	character_detail_browser_footer = HBoxContainer.new()
	character_detail_browser_footer.name = "CharacterProfileBrowserFooter"
	character_detail_browser_footer.visible = false
	character_detail_browser_footer.custom_minimum_size = Vector2(0, 38)
	character_detail_browser_footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_detail_browser_footer.add_theme_constant_override("separation", 10)
	character_detail_action_footer.add_child(character_detail_browser_footer)

	character_detail_previous_button = Button.new()
	character_detail_previous_button.name = "PreviousCharacterProfileButton"
	character_detail_previous_button.text = "‹ 上一位"
	character_detail_previous_button.tooltip_text = "查看当前筛选结果中的上一位人物（←）"
	character_detail_previous_button.custom_minimum_size = Vector2(96, 34)
	character_detail_previous_button.focus_mode = Control.FOCUS_ALL
	character_detail_previous_button.pressed.connect(_browse_character_profile.bind(-1))
	_apply_toolbar_button_style(character_detail_previous_button, false)
	character_detail_browser_footer.add_child(character_detail_previous_button)

	character_detail_position_label = Label.new()
	character_detail_position_label.name = "CharacterProfilePosition"
	character_detail_position_label.text = "第 1 / 1 位"
	character_detail_position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	character_detail_position_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	character_detail_position_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_detail_position_label.add_theme_font_size_override("font_size", 14)
	character_detail_position_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	character_detail_browser_footer.add_child(character_detail_position_label)

	character_detail_next_button = Button.new()
	character_detail_next_button.name = "NextCharacterProfileButton"
	character_detail_next_button.text = "下一位 ›"
	character_detail_next_button.tooltip_text = "查看当前筛选结果中的下一位人物（→）"
	character_detail_next_button.custom_minimum_size = Vector2(96, 34)
	character_detail_next_button.focus_mode = Control.FOCUS_ALL
	character_detail_next_button.pressed.connect(_browse_character_profile.bind(1))
	_apply_toolbar_button_style(character_detail_next_button, false)
	character_detail_browser_footer.add_child(character_detail_next_button)

	character_detail_close_button = Button.new()
	character_detail_close_button.name = "CloseCharacterProfileButton"
	character_detail_close_button.text = "收起"
	character_detail_close_button.tooltip_text = "收起人物卡"
	character_detail_close_button.custom_minimum_size = Vector2(76, 34)
	character_detail_close_button.focus_mode = Control.FOCUS_ALL
	character_detail_close_button.pressed.connect(_close_character_detail_dialog)
	_apply_toolbar_button_style(character_detail_close_button, false)
	character_detail_action_footer.add_child(character_detail_close_button)


func _build_character_attribute_dialog() -> void:
	character_attribute_dialog = ConfirmationDialog.new()
	character_attribute_dialog.name = "CharacterAttributeDialog"
	character_attribute_dialog.title = "调整人物资料"
	character_attribute_dialog.min_size = Vector2i(560, 390)
	character_attribute_dialog.max_size = Vector2i(620, 430)
	character_attribute_dialog.unresizable = true
	character_attribute_dialog.ok_button_text = "应用本局调整"
	character_attribute_dialog.cancel_button_text = "取消"
	character_attribute_dialog.confirmed.connect(_confirm_character_attribute_dialog)
	character_attribute_dialog.canceled.connect(_cancel_character_attribute_dialog)
	character_attribute_dialog.close_requested.connect(_cancel_character_attribute_dialog)
	UiThemeScript.set_dialog_variant(
		character_attribute_dialog,
		UiThemeScript.DIALOG_VARIANT_RECORD
	)
	add_child(character_attribute_dialog)
	var dialog_style := UiThemeScript.make_record_panel(
		1.0,
		8,
		Vector4(12, 10, 12, 10)
	)
	dialog_style.border_width_left = 1
	dialog_style.set_corner_radius_all(8)
	character_attribute_dialog.add_theme_stylebox_override("panel", dialog_style)

	var column := VBoxContainer.new()
	column.name = "AttributeEditorContent"
	column.add_theme_constant_override("separation", 10)
	character_attribute_dialog.add_child(column)

	var boundary := Label.new()
	boundary.name = "AttributeBoundary"
	boundary.text = "四项均为 0—100；应用后会立即更新这名人物在当前沙盘中的卡牌。"
	boundary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	boundary.add_theme_font_size_override("font_size", 14)
	boundary.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(boundary)

	var grid := GridContainer.new()
	grid.name = "AttributeGrid"
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 10)
	column.add_child(grid)
	character_attribute_might_spin = _build_character_attribute_cell(grid, "武力", "个人勇武与战阵表现")
	character_attribute_intelligence_spin = _build_character_attribute_cell(grid, "智力", "判断、谋划与应变")
	character_attribute_leadership_spin = _build_character_attribute_cell(grid, "统率", "组织、带兵与掌控局面")
	character_attribute_charisma_spin = _build_character_attribute_cell(grid, "魅力", "声望、号召与人际影响")

	character_attribute_legacy_label = Label.new()
	character_attribute_legacy_label.name = "LegacyAttributeNotice"
	character_attribute_legacy_label.visible = false
	character_attribute_legacy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	character_attribute_legacy_label.add_theme_font_size_override("font_size", 13)
	character_attribute_legacy_label.add_theme_color_override("font_color", UiThemeScript.TEXT_ACCENT)
	column.add_child(character_attribute_legacy_label)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	column.add_child(footer)
	character_attribute_clear_button = Button.new()
	character_attribute_clear_button.text = "恢复项目初始值"
	character_attribute_clear_button.tooltip_text = "移除这名人物的本局覆盖，卡牌恢复项目初始四维；可使用撤销恢复"
	character_attribute_clear_button.pressed.connect(_clear_pending_character_attributes)
	_apply_toolbar_button_style(character_attribute_clear_button, true)
	footer.add_child(character_attribute_clear_button)
	var clear_hint := Label.new()
	clear_hint.text = "恢复后仍显示四维初始值。"
	clear_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clear_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clear_hint.add_theme_font_size_override("font_size", 12)
	clear_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	footer.add_child(clear_hint)


func _build_character_troop_dialog() -> void:
	character_troop_dialog = ConfirmationDialog.new()
	character_troop_dialog.name = "CharacterTroopDialog"
	character_troop_dialog.title = "调整兵力"
	character_troop_dialog.min_size = Vector2i(620, 330)
	character_troop_dialog.max_size = Vector2i(650, 350)
	character_troop_dialog.unresizable = true
	character_troop_dialog.ok_button_text = "应用"
	character_troop_dialog.cancel_button_text = "取消"
	character_troop_dialog.confirmed.connect(_confirm_character_troop_dialog)
	character_troop_dialog.canceled.connect(_cancel_character_troop_dialog)
	character_troop_dialog.close_requested.connect(_cancel_character_troop_dialog)
	UiThemeScript.set_dialog_variant(
		character_troop_dialog,
		UiThemeScript.DIALOG_VARIANT_RECORD
	)
	add_child(character_troop_dialog)
	var dialog_style := StyleBoxFlat.new()
	dialog_style.bg_color = UiThemeScript.INK_RECORD_BASE
	dialog_style.border_color = UiThemeScript.BORDER_BRASS
	dialog_style.set_border_width_all(1)
	dialog_style.set_corner_radius_all(8)
	character_troop_dialog.add_theme_stylebox_override("panel", dialog_style)

	var content_margin := MarginContainer.new()
	content_margin.name = "TroopEditorMargin"
	content_margin.add_theme_constant_override("margin_left", 10)
	content_margin.add_theme_constant_override("margin_top", 8)
	content_margin.add_theme_constant_override("margin_right", 10)
	content_margin.add_theme_constant_override("margin_bottom", 8)
	character_troop_dialog.add_child(content_margin)

	var column := VBoxContainer.new()
	column.name = "TroopEditorContent"
	column.add_theme_constant_override("separation", 12)
	content_margin.add_child(column)

	var hint := Label.new()
	hint.name = "TroopEditorHint"
	hint.text = "兵力用于沙盘展示和推演记录，可直接输入、快速增减或设为常用值。"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(hint)

	character_troop_spin = SpinBox.new()
	character_troop_spin.name = "TroopCountValue"
	character_troop_spin.min_value = CHARACTER_TROOP_MIN
	character_troop_spin.max_value = CHARACTER_TROOP_MAX
	character_troop_spin.step = 1.0
	character_troop_spin.value = CHARACTER_TROOP_DEFAULT
	character_troop_spin.custom_minimum_size = Vector2(0, 42)
	character_troop_spin.add_theme_font_size_override("font_size", 18)
	column.add_child(character_troop_spin)

	var quick_row := HBoxContainer.new()
	quick_row.name = "TroopQuickAdjust"
	quick_row.add_theme_constant_override("separation", 7)
	column.add_child(quick_row)
	for entry in [
		{"name": "Minus1000", "label": "−1000", "delta": -1000},
		{"name": "Minus100", "label": "−100", "delta": -100},
		{"name": "Plus100", "label": "+100", "delta": 100},
		{"name": "Plus1000", "label": "+1000", "delta": 1000}
	]:
		var quick_button := Button.new()
		quick_button.name = "TroopAdjust%s" % str(entry.get("name", ""))
		quick_button.text = str(entry.get("label", ""))
		quick_button.custom_minimum_size = Vector2(82, 34)
		quick_button.focus_mode = Control.FOCUS_ALL
		quick_button.pressed.connect(_adjust_pending_character_troops.bind(int(entry.get("delta", 0))))
		_apply_toolbar_button_style(quick_button, false)
		quick_row.add_child(quick_button)
	var default_button := Button.new()
	default_button.name = "TroopAdjustDefault"
	default_button.text = "默认 1000"
	default_button.custom_minimum_size = Vector2(102, 34)
	default_button.focus_mode = Control.FOCUS_ALL
	default_button.pressed.connect(_set_pending_character_troops_default)
	_apply_toolbar_button_style(default_button, false)
	quick_row.add_child(default_button)

	var large_row := HBoxContainer.new()
	large_row.name = "TroopLargeAdjust"
	large_row.add_theme_constant_override("separation", 7)
	column.add_child(large_row)
	for entry in [
		{"name": "Minus100000", "label": "−10万", "delta": -100000},
		{"name": "Minus50000", "label": "−5万", "delta": -50000},
		{"name": "Minus10000", "label": "−1万", "delta": -10000},
		{"name": "Plus10000", "label": "+1万", "delta": 10000},
		{"name": "Plus50000", "label": "+5万", "delta": 50000},
		{"name": "Plus100000", "label": "+10万", "delta": 100000}
	]:
		var large_button := Button.new()
		large_button.name = "TroopAdjust%s" % str(entry.get("name", ""))
		large_button.text = str(entry.get("label", ""))
		large_button.tooltip_text = "待应用兵力%s" % str(entry.get("label", ""))
		large_button.custom_minimum_size = Vector2(84, 34)
		large_button.focus_mode = Control.FOCUS_ALL
		large_button.pressed.connect(_adjust_pending_character_troops.bind(int(entry.get("delta", 0))))
		_apply_toolbar_button_style(large_button, false)
		large_row.add_child(large_button)

	var preset_group := HBoxContainer.new()
	preset_group.name = "TroopAbsolutePresetGroup"
	preset_group.add_theme_constant_override("separation", 7)
	column.add_child(preset_group)
	var preset_label := Label.new()
	preset_label.name = "TroopAbsolutePresetLabel"
	preset_label.text = "直接设为"
	preset_label.custom_minimum_size = Vector2(66, 34)
	preset_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preset_label.add_theme_font_size_override("font_size", 13)
	preset_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	preset_group.add_child(preset_label)
	var preset_row := HBoxContainer.new()
	preset_row.name = "TroopAbsolutePresets"
	preset_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preset_row.add_theme_constant_override("separation", 7)
	preset_group.add_child(preset_row)
	for entry in [
		{"name": "1000", "label": "1千", "value": 1000},
		{"name": "5000", "label": "5千", "value": 5000},
		{"name": "10000", "label": "1万", "value": 10000},
		{"name": "50000", "label": "5万", "value": 50000},
		{"name": "100000", "label": "10万", "value": 100000}
	]:
		var preset_button := Button.new()
		preset_button.name = "TroopSet%s" % str(entry.get("name", ""))
		preset_button.text = str(entry.get("label", ""))
		preset_button.tooltip_text = "把待应用兵力直接设为 %s" % str(entry.get("label", ""))
		preset_button.custom_minimum_size = Vector2(82, 34)
		preset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		preset_button.focus_mode = Control.FOCUS_ALL
		preset_button.pressed.connect(_set_pending_character_troops.bind(int(entry.get("value", CHARACTER_TROOP_DEFAULT))))
		_apply_toolbar_button_style(preset_button, false)
		preset_row.add_child(preset_button)


func _build_character_attribute_cell(parent: GridContainer, label_text: String, hint_text: String) -> SpinBox:
	var cell := VBoxContainer.new()
	cell.custom_minimum_size = Vector2(250, 82)
	cell.add_theme_constant_override("separation", 3)
	parent.add_child(cell)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	cell.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(54, 38)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	row.add_child(label)
	var spin := SpinBox.new()
	spin.name = "%sValue" % label_text
	spin.min_value = CHARACTER_ATTRIBUTE_MIN
	spin.max_value = CHARACTER_ATTRIBUTE_MAX
	spin.step = 1.0
	spin.allow_greater = false
	spin.allow_lesser = false
	spin.custom_minimum_size = Vector2(112, 38)
	spin.value = CHARACTER_ATTRIBUTE_EDITOR_INITIAL
	row.add_child(spin)
	var hint := Label.new()
	hint.text = hint_text
	hint.custom_minimum_size = Vector2(0, 26)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	cell.add_child(hint)
	return spin


func _build_player_stroke_dialogs() -> void:
	player_stroke_dialog = ConfirmationDialog.new()
	player_stroke_dialog.title = "绘制推演线"
	player_stroke_dialog.min_size = Vector2i(480, 245)
	player_stroke_dialog.ok_button_text = "开始落点"
	player_stroke_dialog.cancel_button_text = "取消"
	player_stroke_dialog.confirmed.connect(_confirm_player_stroke_dialog)
	player_stroke_dialog.canceled.connect(_cancel_player_stroke_dialog)
	add_child(player_stroke_dialog)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	player_stroke_dialog.add_child(column)
	player_stroke_hint_label = Label.new()
	player_stroke_hint_label.text = "这是玩家推演线；行军、时间与战果由你裁定。"
	player_stroke_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player_stroke_hint_label.custom_minimum_size = Vector2(430, 42)
	player_stroke_hint_label.add_theme_font_size_override("font_size", 14)
	player_stroke_hint_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	column.add_child(player_stroke_hint_label)
	var type_row := HBoxContainer.new()
	type_row.add_theme_constant_override("separation", 10)
	column.add_child(type_row)
	var type_label := Label.new()
	type_label.text = "线型"
	type_label.custom_minimum_size = Vector2(64, 0)
	type_label.add_theme_color_override("font_color", UiThemeScript.TEXT_FIELD)
	type_row.add_child(type_label)
	player_stroke_type_select = OptionButton.new()
	player_stroke_type_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_stroke_type_select.add_item("进军")
	player_stroke_type_select.add_item("援军")
	player_stroke_type_select.add_item("撤退")
	player_stroke_type_select.add_item("计划")
	type_row.add_child(player_stroke_type_select)
	player_stroke_label_input = LineEdit.new()
	player_stroke_label_input.max_length = MAX_PLAYER_STROKE_LABEL_LENGTH
	player_stroke_label_input.placeholder_text = "可选说明，例如：关羽北上"
	player_stroke_label_input.text_submitted.connect(_on_player_stroke_label_submitted)
	column.add_child(player_stroke_label_input)

	player_stroke_delete_confirmation_dialog = ConfirmationDialog.new()
	player_stroke_delete_confirmation_dialog.title = "删除推演线"
	player_stroke_delete_confirmation_dialog.dialog_text = "要删除选中的玩家推演线吗？删除后仍可撤销。"
	player_stroke_delete_confirmation_dialog.ok_button_text = "删除"
	player_stroke_delete_confirmation_dialog.cancel_button_text = "保留"
	player_stroke_delete_confirmation_dialog.confirmed.connect(_confirm_player_stroke_delete)
	player_stroke_delete_confirmation_dialog.canceled.connect(_cancel_player_stroke_delete)
	add_child(player_stroke_delete_confirmation_dialog)


func _build_sandbox_file_dialogs() -> void:
	var documents_dir := OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)

	export_dialog = FileDialog.new()
	export_dialog.title = "备份当前沙盘"
	export_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	export_dialog.access = FileDialog.ACCESS_FILESYSTEM
	export_dialog.filters = PackedStringArray(["*.tianxia ; 三国推演志沙盘备份"])
	export_dialog.current_dir = documents_dir
	export_dialog.file_selected.connect(_on_export_file_selected)
	export_dialog.canceled.connect(_cancel_export_dialog)
	add_child(export_dialog)

	export_overwrite_dialog = ConfirmationDialog.new()
	export_overwrite_dialog.title = "替换已有备份？"
	export_overwrite_dialog.min_size = Vector2i(460, 190)
	export_overwrite_dialog.ok_button_text = "替换"
	export_overwrite_dialog.cancel_button_text = "取消"
	export_overwrite_dialog.confirmed.connect(_confirm_export_overwrite)
	export_overwrite_dialog.canceled.connect(_cancel_export_overwrite)
	add_child(export_overwrite_dialog)

	import_dialog = FileDialog.new()
	import_dialog.title = "选择一个沙盘备份"
	import_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	import_dialog.access = FileDialog.ACCESS_FILESYSTEM
	import_dialog.filters = PackedStringArray(["*.tianxia ; 三国推演志沙盘备份", "*.json ; 旧式 JSON 存档"])
	import_dialog.current_dir = documents_dir
	import_dialog.file_selected.connect(_on_import_file_selected)
	import_dialog.canceled.connect(_cancel_import_dialog)
	add_child(import_dialog)

	import_confirmation_dialog = ConfirmationDialog.new()
	import_confirmation_dialog.title = "从这个备份继续？"
	import_confirmation_dialog.min_size = Vector2i(500, 250)
	import_confirmation_dialog.ok_button_text = "继续"
	import_confirmation_dialog.cancel_button_text = "取消"
	import_confirmation_dialog.confirmed.connect(_confirm_sandbox_import)
	import_confirmation_dialog.canceled.connect(_cancel_sandbox_import)
	add_child(import_confirmation_dialog)
	import_summary_label = Label.new()
	import_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	import_summary_label.custom_minimum_size = Vector2(460, 170)
	import_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	import_confirmation_dialog.add_child(import_summary_label)

	message_dialog = AcceptDialog.new()
	message_dialog.title = str(ProjectSettings.get_setting("application/config/name", "三国推演志"))
	message_dialog.min_size = Vector2i(450, 180)
	message_dialog.ok_button_text = "知道了"
	add_child(message_dialog)
	_build_place_search_dialog()
	_build_primary_recovery_dialog()
	_build_sandbox_identity_dialogs()
	_build_new_sandbox_dialogs()
	_build_personal_template_dialogs()
	_build_scenario_editor_dialogs()
	_build_chronicle_dialogs()
	_build_current_branch_dialogs()


func _build_place_search_dialog() -> void:
	place_search_dialog = ConfirmationDialog.new()
	place_search_dialog.name = "PlaceSearchDialog"
	place_search_dialog.title = "定位地图地点"
	place_search_dialog.min_size = Vector2i(660, 520)
	place_search_dialog.max_size = Vector2i(660, 520)
	place_search_dialog.unresizable = true
	place_search_dialog.ok_button_text = "定位"
	place_search_dialog.cancel_button_text = "取消"
	place_search_dialog.confirmed.connect(_confirm_place_search)
	add_child(place_search_dialog)

	var column := VBoxContainer.new()
	column.name = "PlaceSearchColumn"
	column.add_theme_constant_override("separation", 10)
	place_search_dialog.add_child(column)

	var hint := Label.new()
	hint.text = "输入现在地名、汉末旧称或地点类型。双击结果也可直接定位。"
	hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(hint)

	place_search_input = LineEdit.new()
	place_search_input.name = "PlaceSearchInput"
	place_search_input.placeholder_text = "例如：襄阳、南郑、虎牢、关隘"
	place_search_input.clear_button_enabled = true
	place_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	place_search_input.text_changed.connect(_on_place_search_query_changed)
	place_search_input.text_submitted.connect(_on_place_search_text_submitted)
	column.add_child(place_search_input)

	place_search_count_label = Label.new()
	place_search_count_label.name = "PlaceSearchCount"
	place_search_count_label.add_theme_font_size_override("font_size", 14)
	place_search_count_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	column.add_child(place_search_count_label)

	place_search_list = ItemList.new()
	place_search_list.name = "PlaceSearchResults"
	place_search_list.custom_minimum_size = Vector2(610, 345)
	place_search_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	place_search_list.select_mode = ItemList.SELECT_SINGLE
	place_search_list.allow_reselect = true
	place_search_list.item_selected.connect(_on_place_search_result_selected)
	place_search_list.item_activated.connect(_on_place_search_result_activated)
	UiThemeScript.style_accessible_scrollbar(
		place_search_list.get_v_scroll_bar(),
		"拖动查看地点结果；也可用滚轮或 ↑↓"
	)
	UiThemeScript.style_accessible_scrollbar(
		place_search_list.get_h_scroll_bar(),
		"横向查看地点名称"
	)
	column.add_child(place_search_list)
	place_search_dialog.get_ok_button().disabled = true


func _open_place_search_dialog() -> void:
	if place_search_dialog == null:
		return
	place_search_input.clear()
	_refresh_place_search_results()
	place_search_dialog.popup_centered(Vector2i(660, 520))
	call_deferred("_focus_place_search_input")


func _focus_place_search_input() -> void:
	await get_tree().process_frame
	if place_search_dialog == null or not place_search_dialog.visible or place_search_input == null:
		return
	place_search_input.grab_focus()
	place_search_input.select_all()


func _normalize_place_search_text(value: String) -> String:
	return value.strip_edges().to_lower().replace(" ", "").replace("　", "")


func _place_search_score(place: Dictionary, normalized_query: String) -> int:
	if normalized_query.is_empty():
		return 0
	var current_name := _normalize_place_search_text(str(place.get("name", "")))
	var historical_name := _normalize_place_search_text(str(place.get("historical_name_190", "")))
	var type_name := _normalize_place_search_text(_place_detail_type_text(str(place.get("type", "city"))))
	var place_id := _normalize_place_search_text(str(place.get("id", "")))
	if current_name == normalized_query:
		return 0
	if current_name.begins_with(normalized_query):
		return 10
	if current_name.contains(normalized_query):
		return 20
	if historical_name.begins_with(normalized_query):
		return 30
	if historical_name.contains(normalized_query):
		return 40
	if type_name.contains(normalized_query):
		return 50
	if place_id.contains(normalized_query):
		return 60
	return -1


func _place_search_historical_short_name(place: Dictionary) -> String:
	var historical_name := str(place.get("historical_name_190", "")).strip_edges()
	if historical_name.is_empty():
		return ""
	var bracket_index := historical_name.find("（")
	if bracket_index >= 0:
		historical_name = historical_name.left(bracket_index).strip_edges()
	return historical_name


func _refresh_place_search_results() -> void:
	if place_search_list == null:
		return
	place_search_list.clear()
	place_search_result_ids.clear()
	var normalized_query := _normalize_place_search_text(place_search_input.text if place_search_input != null else "")
	var matches: Array[Dictionary] = []
	for index in range(places.size()):
		if not (places[index] is Dictionary):
			continue
		var place: Dictionary = places[index]
		var score := _place_search_score(place, normalized_query)
		if score < 0:
			continue
		matches.append({"place": place, "score": score, "order": index})
	if not normalized_query.is_empty():
		matches.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
			var first_score := int(first.get("score", 999))
			var second_score := int(second.get("score", 999))
			return first_score < second_score if first_score != second_score else int(first.get("order", 0)) < int(second.get("order", 0))
		)
	for match_value in matches:
		var match_record: Dictionary = match_value
		var place: Dictionary = match_record.get("place", {})
		var place_id := str(place.get("id", ""))
		var place_name := str(place.get("name", place_id))
		var type_name := _place_detail_type_text(str(place.get("type", "city")))
		var historical_short := _place_search_historical_short_name(place)
		var row_text := "%s　·　%s" % [place_name, type_name]
		if not historical_short.is_empty() and historical_short != place_name:
			row_text += "　｜　汉末：%s" % historical_short
		place_search_list.add_item(row_text)
		var item_index := place_search_list.item_count - 1
		place_search_list.set_item_metadata(item_index, place_id)
		place_search_list.set_item_tooltip(
			item_index,
			"%s\n%s" % [str(place.get("historical_name_190", place_name)), type_name]
		)
		place_search_result_ids.append(place_id)
	var result_count := place_search_result_ids.size()
	if result_count > 0:
		place_search_list.select(0)
		place_search_list.ensure_current_is_visible()
		place_search_count_label.text = "找到 %d 个地点" % result_count
		place_search_dialog.get_ok_button().disabled = false
	else:
		place_search_count_label.text = "没有找到地点；可换用旧称或地点类型"
		place_search_dialog.get_ok_button().disabled = true


func _on_place_search_query_changed(_query: String) -> void:
	_refresh_place_search_results()


func _on_place_search_result_selected(_index: int) -> void:
	place_search_dialog.get_ok_button().disabled = place_search_list.get_selected_items().is_empty()


func _on_place_search_result_activated(index: int) -> void:
	_locate_place_search_result(index)


func _on_place_search_text_submitted(_query: String) -> void:
	var selected := place_search_list.get_selected_items()
	if not selected.is_empty():
		_locate_place_search_result(int(selected[0]))


func _confirm_place_search() -> void:
	var selected := place_search_list.get_selected_items()
	if selected.is_empty():
		return
	_locate_place_search_result(int(selected[0]))


func _locate_place_search_result(index: int) -> bool:
	if map_board == null or index < 0 or index >= place_search_result_ids.size():
		return false
	var place_id := place_search_result_ids[index]
	var place := _find_place(place_id)
	if place.is_empty() or not map_board.focus_place(place_id):
		_set_status("这个地点暂时无法定位")
		return false
	place_search_dialog.hide()
	_open_place_detail_panel(place_id)
	call_deferred("_focus_place_detail_primary_action")
	_set_status("已定位%s · 地点札记已打开" % str(place.get("name", place_id)))
	return true


func _focus_place_detail_primary_action() -> void:
	if place_detail_panel != null and place_detail_panel.visible and place_detail_locate_button != null:
		place_detail_locate_button.grab_focus()


func _build_primary_recovery_dialog() -> void:
	primary_recovery_dialog = ConfirmationDialog.new()
	primary_recovery_dialog.name = "PrimaryRecoveryDialog"
	primary_recovery_dialog.title = "可以恢复上一份沙盘"
	primary_recovery_dialog.min_size = Vector2i(540, 290)
	primary_recovery_dialog.ok_button_text = "恢复上一份"
	primary_recovery_dialog.cancel_button_text = "暂不恢复"
	primary_recovery_dialog.confirmed.connect(_confirm_primary_recovery)
	primary_recovery_dialog.canceled.connect(_cancel_primary_recovery)
	add_child(primary_recovery_dialog)
	primary_recovery_summary_label = Label.new()
	primary_recovery_summary_label.name = "PrimaryRecoverySummary"
	primary_recovery_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	primary_recovery_summary_label.custom_minimum_size = Vector2(500, 190)
	primary_recovery_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	primary_recovery_dialog.add_child(primary_recovery_summary_label)


func _build_place_detail_panel() -> void:
	place_detail_host = Control.new()
	place_detail_host.name = "PlaceDetailHost"
	place_detail_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place_detail_host.clip_contents = true
	place_detail_host.z_index = 4090
	map_board.add_child(place_detail_host)
	place_detail_panel = PanelContainer.new()
	place_detail_panel.name = "PlaceDetailPanel"
	place_detail_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	place_detail_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel_style := UiThemeScript.make_record_panel(0.99, 10)
	place_detail_panel.add_theme_stylebox_override("panel", panel_style)
	place_detail_host.add_child(place_detail_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 13)
	margin.add_theme_constant_override("margin_bottom", 14)
	place_detail_panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	column.add_child(header)
	place_detail_title_label = Label.new()
	place_detail_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	place_detail_title_label.add_theme_font_size_override("font_size", 23)
	place_detail_title_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	header.add_child(place_detail_title_label)
	place_detail_chronicle_button = _make_context_action_button(
		"写纪事…",
		"以当前地点为上下文写一则玩家纪事；不会改变地点、人物或城池归属"
	)
	place_detail_chronicle_button.name = "PlaceChronicleButton"
	place_detail_chronicle_button.custom_minimum_size = Vector2(82, 30)
	place_detail_chronicle_button.pressed.connect(_open_place_chronicle_editor)
	header.add_child(place_detail_chronicle_button)
	var close_button := Button.new()
	close_button.name = "CloseButton"
	close_button.text = "×"
	close_button.tooltip_text = "收起资料卡"
	close_button.custom_minimum_size = Vector2(32, 30)
	close_button.flat = true
	close_button.add_theme_font_size_override("font_size", 20)
	close_button.add_theme_color_override("font_color", UiThemeScript.TEXT_BUTTON)
	close_button.pressed.connect(_close_place_detail_panel)
	header.add_child(close_button)

	place_detail_historical_label = _make_place_detail_label(14, UiThemeScript.TEXT_HISTORICAL)
	column.add_child(place_detail_historical_label)
	place_detail_tags_label = _make_place_detail_label(13, Color("#52694C"))
	column.add_child(place_detail_tags_label)

	place_detail_ownership_row = HBoxContainer.new()
	place_detail_ownership_row.name = "OwnershipRow"
	place_detail_ownership_row.add_theme_constant_override("separation", 7)
	column.add_child(place_detail_ownership_row)
	var ownership_label := Label.new()
	ownership_label.text = "本局归属"
	ownership_label.custom_minimum_size = Vector2(62, 30)
	ownership_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ownership_label.add_theme_font_size_override("font_size", 13)
	ownership_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	place_detail_ownership_row.add_child(ownership_label)
	place_detail_owner_swatch = ColorRect.new()
	place_detail_owner_swatch.name = "OwnerSwatch"
	place_detail_owner_swatch.custom_minimum_size = Vector2(10, 22)
	place_detail_owner_swatch.color = Color("737B72")
	place_detail_owner_swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place_detail_ownership_row.add_child(place_detail_owner_swatch)
	place_detail_owner_select = OptionButton.new()
	place_detail_owner_select.name = "OwnerSelect"
	place_detail_owner_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	place_detail_owner_select.custom_minimum_size = Vector2(112, 30)
	place_detail_owner_select.focus_mode = Control.FOCUS_ALL
	place_detail_owner_select.tooltip_text = "只记录当前沙盘的城池归属；不产生收入、兵力、战斗或胜负"
	place_detail_owner_select.item_selected.connect(_on_place_ownership_selected)
	place_detail_ownership_row.add_child(place_detail_owner_select)
	place_detail_continuous_ownership_button = _make_context_action_button(
		"连续设置…",
		"以当前选择的势力为目标，连续点击多座城市；每座城市都可单独撤销"
	)
	place_detail_continuous_ownership_button.name = "ContinuousOwnershipButton"
	place_detail_continuous_ownership_button.custom_minimum_size = Vector2(82, 30)
	place_detail_continuous_ownership_button.pressed.connect(_start_city_ownership_tool_from_detail)
	place_detail_ownership_row.add_child(place_detail_continuous_ownership_button)

	place_detail_action_row = HFlowContainer.new()
	place_detail_action_row.name = "ContextActions"
	place_detail_action_row.add_theme_constant_override("h_separation", 6)
	place_detail_action_row.add_theme_constant_override("v_separation", 5)
	column.add_child(place_detail_action_row)
	place_detail_locate_button = _make_context_action_button("定位", "把选中的城市或势力对象带到当前视野")
	place_detail_locate_button.pressed.connect(_on_context_locate_pressed)
	place_detail_action_row.add_child(place_detail_locate_button)
	place_detail_note_button = _make_context_action_button("地点标记", "在这个地点建立玩家自己的标记")
	place_detail_note_button.pressed.connect(_on_context_place_note_pressed)
	place_detail_action_row.add_child(place_detail_note_button)
	place_detail_faction_button = _make_context_action_button("查看势力", "切换到当前归属势力的上下文")
	place_detail_faction_button.pressed.connect(_on_context_faction_pressed)
	place_detail_action_row.add_child(place_detail_faction_button)
	place_detail_edit_faction_button = _make_context_action_button("编辑势力", "打开既有势力编辑器")
	place_detail_edit_faction_button.pressed.connect(_on_context_edit_faction_pressed)
	place_detail_action_row.add_child(place_detail_edit_faction_button)

	place_detail_relation_navigation_row = HBoxContainer.new()
	place_detail_relation_navigation_row.name = "RelationNavigation"
	place_detail_relation_navigation_row.add_theme_constant_override("separation", 6)
	column.add_child(place_detail_relation_navigation_row)
	place_detail_switch_button = _make_context_action_button("换看此地", "把当前定位地点切换为新的札记中心")
	place_detail_switch_button.name = "SwitchPlaceDetailButton"
	place_detail_switch_button.custom_minimum_size = Vector2(128, 30)
	place_detail_switch_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	place_detail_switch_button.pressed.connect(_on_context_switch_place_pressed)
	place_detail_relation_navigation_row.add_child(place_detail_switch_button)
	place_detail_back_button = _make_context_action_button("返回来源", "返回上一张地点札记")
	place_detail_back_button.name = "BackPlaceDetailButton"
	place_detail_back_button.custom_minimum_size = Vector2(112, 30)
	place_detail_back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	place_detail_back_button.pressed.connect(_on_context_back_place_pressed)
	place_detail_relation_navigation_row.add_child(place_detail_back_button)
	place_detail_relation_navigation_row.hide()

	var divider := HSeparator.new()
	divider.add_theme_constant_override("separation", 7)
	column.add_child(divider)
	place_detail_scroll_hint_label = _make_place_detail_label(12, UiThemeScript.TEXT_SUMMARY)
	place_detail_scroll_hint_label.name = "ScrollHint"
	place_detail_scroll_hint_label.text = "向下滚动查看地点与年代背景"
	place_detail_scroll_hint_label.tooltip_text = "札记标题保持固定，只有下方正文滚动"
	column.add_child(place_detail_scroll_hint_label)

	place_detail_body = RichTextLabel.new()
	place_detail_body.name = "DetailBody"
	place_detail_body.custom_minimum_size = Vector2(295, 282)
	place_detail_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	place_detail_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	place_detail_body.bbcode_enabled = true
	place_detail_body.fit_content = false
	place_detail_body.scroll_active = true
	place_detail_body.selection_enabled = true
	place_detail_body.add_theme_font_size_override("normal_font_size", 14)
	place_detail_body.add_theme_color_override("default_color", UiThemeScript.TEXT_BODY)
	place_detail_body.meta_clicked.connect(_on_place_detail_meta_clicked)
	place_detail_body.meta_hover_started.connect(_on_place_detail_meta_hover_started)
	place_detail_body.meta_hover_ended.connect(_on_place_detail_meta_hover_ended)
	column.add_child(place_detail_body)
	_style_place_detail_scrollbar()
	place_detail_panel.hide()
	place_detail_host.hide()
	_position_current_place_detail_panel()


func _build_city_ownership_tool_ui() -> void:
	city_ownership_tool_panel = PanelContainer.new()
	city_ownership_tool_panel.name = "CityOwnershipToolPanel"
	city_ownership_tool_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	city_ownership_tool_panel.z_index = 3100
	city_ownership_tool_panel.set_anchor(SIDE_LEFT, 0.5)
	city_ownership_tool_panel.set_anchor(SIDE_TOP, 1.0)
	city_ownership_tool_panel.set_anchor(SIDE_RIGHT, 0.5)
	city_ownership_tool_panel.set_anchor(SIDE_BOTTOM, 1.0)
	city_ownership_tool_panel.offset_left = -310.0
	city_ownership_tool_panel.offset_top = -66.0
	city_ownership_tool_panel.offset_right = 310.0
	city_ownership_tool_panel.offset_bottom = -14.0
	city_ownership_tool_panel.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_shell_panel(
			UiThemeScript.INK_RECORD_BASE,
			UiThemeScript.BORDER_BRASS,
			1,
			8,
			8
		)
	)
	map_board.add_child(city_ownership_tool_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	city_ownership_tool_panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	var title := Label.new()
	title.text = "连续设置归属"
	title.custom_minimum_size = Vector2(104, 0)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	row.add_child(title)

	city_ownership_tool_target_select = OptionButton.new()
	city_ownership_tool_target_select.name = "OwnershipTargetSelect"
	city_ownership_tool_target_select.custom_minimum_size = Vector2(150, 34)
	city_ownership_tool_target_select.focus_mode = Control.FOCUS_ALL
	city_ownership_tool_target_select.tooltip_text = "切换后继续点击城市；切换目标本身不写入存档"
	city_ownership_tool_target_select.item_selected.connect(_on_city_ownership_tool_target_selected)
	row.add_child(city_ownership_tool_target_select)

	city_ownership_tool_hint_label = Label.new()
	city_ownership_tool_hint_label.name = "OwnershipToolHint"
	city_ownership_tool_hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	city_ownership_tool_hint_label.clip_text = true
	city_ownership_tool_hint_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	city_ownership_tool_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	city_ownership_tool_hint_label.add_theme_font_size_override("font_size", 12)
	city_ownership_tool_hint_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	row.add_child(city_ownership_tool_hint_label)

	city_ownership_tool_undo_button = _make_context_action_button("撤销上一城", "仅在最近一步是城池归属修改时可用")
	city_ownership_tool_undo_button.custom_minimum_size = Vector2(86, 34)
	city_ownership_tool_undo_button.pressed.connect(_undo_last_city_ownership_change)
	row.add_child(city_ownership_tool_undo_button)

	var finish_button := _make_context_action_button("结束", "退出连续设置；已经完成的修改会保留")
	finish_button.name = "FinishOwnershipToolButton"
	finish_button.custom_minimum_size = Vector2(54, 34)
	finish_button.pressed.connect(_finish_city_ownership_tool)
	row.add_child(finish_button)
	city_ownership_tool_panel.hide()


func _make_context_action_button(text_value: String, tooltip: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.tooltip_text = tooltip
	button.custom_minimum_size = Vector2(70, 30)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 13)
	return button


func _make_place_detail_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _style_place_detail_scrollbar() -> void:
	var scroll_bar := place_detail_body.get_v_scroll_bar()
	if scroll_bar == null:
		return
	scroll_bar.name = "DetailScrollbar"
	UiThemeScript.style_accessible_scrollbar(
		scroll_bar,
		"拖动查看地点札记；也可用滚轮或 ↑↓"
	)


func _build_sandbox_identity_dialogs() -> void:
	sandbox_info_dialog = ConfirmationDialog.new()
	sandbox_info_dialog.title = "编辑沙盘信息"
	sandbox_info_dialog.min_size = Vector2i(520, 390)
	sandbox_info_dialog.ok_button_text = "保存信息"
	sandbox_info_dialog.cancel_button_text = "取消"
	sandbox_info_dialog.confirmed.connect(_confirm_sandbox_info)
	add_child(sandbox_info_dialog)
	var info_column := VBoxContainer.new()
	info_column.add_theme_constant_override("separation", 7)
	sandbox_info_dialog.add_child(info_column)
	var info_hint := Label.new()
	info_hint.text = "填写名称、备注与来源，便于辨认和整理自己的沙盘。"
	info_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	info_column.add_child(info_hint)
	var title_label := Label.new()
	title_label.text = "沙盘名称"
	info_column.add_child(title_label)
	sandbox_title_input = LineEdit.new()
	sandbox_title_input.max_length = MAX_SANDBOX_TITLE_LENGTH
	sandbox_title_input.placeholder_text = "例如：我的蜀汉"
	info_column.add_child(sandbox_title_input)
	var note_label := Label.new()
	note_label.text = "简短说明（可选，最多 120 字）"
	info_column.add_child(note_label)
	sandbox_note_input = TextEdit.new()
	sandbox_note_input.custom_minimum_size = Vector2(0, 76)
	sandbox_note_input.placeholder_text = "例如：刘关张从涿郡起兵，剧情自由推演"
	sandbox_note_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	info_column.add_child(sandbox_note_input)
	var source_label := Label.new()
	source_label.text = "开局来源（可选）"
	info_column.add_child(source_label)
	sandbox_source_input = LineEdit.new()
	sandbox_source_input.max_length = MAX_SANDBOX_SOURCE_LENGTH
	sandbox_source_input.placeholder_text = "例如：黄巾起义（184 年）／完全自定义"
	info_column.add_child(sandbox_source_input)
	sandbox_info_summary_label = Label.new()
	sandbox_info_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	info_column.add_child(sandbox_info_summary_label)

	snapshot_create_dialog = ConfirmationDialog.new()
	snapshot_create_dialog.title = "创建命名快照"
	snapshot_create_dialog.min_size = Vector2i(500, 320)
	snapshot_create_dialog.ok_button_text = "创建快照"
	snapshot_create_dialog.cancel_button_text = "取消"
	snapshot_create_dialog.confirmed.connect(_confirm_create_snapshot)
	add_child(snapshot_create_dialog)
	var snapshot_column := VBoxContainer.new()
	snapshot_column.add_theme_constant_override("separation", 7)
	snapshot_create_dialog.add_child(snapshot_column)
	var snapshot_hint := Label.new()
	snapshot_hint.text = "快照会留住此刻的人物、标记和视角；创建后仍可继续摆放。"
	snapshot_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	snapshot_column.add_child(snapshot_hint)
	var snapshot_name_label := Label.new()
	snapshot_name_label.text = "快照名称"
	snapshot_column.add_child(snapshot_name_label)
	snapshot_name_input = LineEdit.new()
	snapshot_name_input.max_length = MAX_SNAPSHOT_NAME_LENGTH
	snapshot_name_input.placeholder_text = "例如：攻打汉中之前"
	snapshot_column.add_child(snapshot_name_input)
	var snapshot_note_label := Label.new()
	snapshot_note_label.text = "备注（可选，最多 120 字）"
	snapshot_column.add_child(snapshot_note_label)
	snapshot_note_input = TextEdit.new()
	snapshot_note_input.custom_minimum_size = Vector2(0, 72)
	snapshot_note_input.placeholder_text = "例如：兵分两路前，关羽驻荆州"
	snapshot_note_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	snapshot_column.add_child(snapshot_note_input)
	snapshot_create_summary_label = Label.new()
	snapshot_create_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	snapshot_column.add_child(snapshot_create_summary_label)

	snapshot_manager_dialog = ConfirmationDialog.new()
	snapshot_manager_dialog.title = "命名快照"
	snapshot_manager_dialog.min_size = Vector2i(680, 440)
	snapshot_manager_dialog.ok_button_text = "恢复此快照…"
	snapshot_manager_dialog.cancel_button_text = "关闭"
	snapshot_manager_dialog.confirmed.connect(_request_restore_selected_snapshot)
	snapshot_manager_dialog.canceled.connect(func(): _pending_snapshot_id = "")
	add_child(snapshot_manager_dialog)
	var manager_column := VBoxContainer.new()
	manager_column.add_theme_constant_override("separation", 8)
	snapshot_manager_dialog.add_child(manager_column)
	var manager_hint := Label.new()
	manager_hint.text = "快照按最新在前排列；恢复前会自动保护当前沙盘。"
	manager_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	manager_column.add_child(manager_hint)
	var manager_row := HBoxContainer.new()
	manager_row.add_theme_constant_override("separation", 12)
	manager_column.add_child(manager_row)
	snapshot_list = ItemList.new()
	snapshot_list.name = "SnapshotList"
	snapshot_list.custom_minimum_size = Vector2(300, 270)
	snapshot_list.item_selected.connect(_on_snapshot_selected)
	UiThemeScript.style_accessible_scrollbar(
		snapshot_list.get_v_scroll_bar(),
		"拖动查看命名快照；也可用滚轮或 ↑↓"
	)
	manager_row.add_child(snapshot_list)
	snapshot_detail_label = Label.new()
	snapshot_detail_label.custom_minimum_size = Vector2(320, 270)
	snapshot_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	snapshot_detail_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	manager_row.add_child(snapshot_detail_label)
	var snapshot_action_row := HBoxContainer.new()
	snapshot_action_row.add_theme_constant_override("separation", 8)
	manager_column.add_child(snapshot_action_row)
	snapshot_rename_button = Button.new()
	snapshot_rename_button.text = "重命名…"
	snapshot_rename_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	snapshot_rename_button.pressed.connect(_request_rename_selected_snapshot)
	snapshot_action_row.add_child(snapshot_rename_button)
	snapshot_export_button = Button.new()
	snapshot_export_button.text = "导出为文件…"
	snapshot_export_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	snapshot_export_button.pressed.connect(_request_export_selected_snapshot)
	snapshot_action_row.add_child(snapshot_export_button)
	snapshot_delete_button = Button.new()
	snapshot_delete_button.text = "删除…"
	snapshot_delete_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	snapshot_delete_button.pressed.connect(_request_delete_selected_snapshot)
	snapshot_action_row.add_child(snapshot_delete_button)

	snapshot_rename_dialog = ConfirmationDialog.new()
	snapshot_rename_dialog.title = "重命名快照"
	snapshot_rename_dialog.min_size = Vector2i(440, 180)
	snapshot_rename_dialog.ok_button_text = "保存名称"
	snapshot_rename_dialog.cancel_button_text = "取消"
	snapshot_rename_dialog.confirmed.connect(_confirm_rename_selected_snapshot)
	snapshot_rename_dialog.canceled.connect(_cancel_rename_selected_snapshot)
	add_child(snapshot_rename_dialog)
	var rename_column := VBoxContainer.new()
	rename_column.add_theme_constant_override("separation", 8)
	snapshot_rename_dialog.add_child(rename_column)
	var rename_hint := Label.new()
	rename_hint.text = "只修改快照名称，不改变当时的人物、标记、视角或来源。"
	rename_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	rename_column.add_child(rename_hint)
	snapshot_rename_input = LineEdit.new()
	snapshot_rename_input.max_length = MAX_SNAPSHOT_NAME_LENGTH
	rename_column.add_child(snapshot_rename_input)

	snapshot_restore_confirmation_dialog = ConfirmationDialog.new()
	snapshot_restore_confirmation_dialog.title = "恢复这个快照？"
	snapshot_restore_confirmation_dialog.min_size = Vector2i(480, 220)
	snapshot_restore_confirmation_dialog.ok_button_text = "恢复并继续"
	snapshot_restore_confirmation_dialog.cancel_button_text = "取消"
	snapshot_restore_confirmation_dialog.confirmed.connect(_confirm_restore_selected_snapshot)
	snapshot_restore_confirmation_dialog.canceled.connect(_cancel_snapshot_confirmation)
	add_child(snapshot_restore_confirmation_dialog)

	snapshot_delete_confirmation_dialog = ConfirmationDialog.new()
	snapshot_delete_confirmation_dialog.title = "删除这个快照？"
	snapshot_delete_confirmation_dialog.min_size = Vector2i(440, 190)
	snapshot_delete_confirmation_dialog.ok_button_text = "删除"
	snapshot_delete_confirmation_dialog.cancel_button_text = "取消"
	snapshot_delete_confirmation_dialog.confirmed.connect(_confirm_delete_selected_snapshot)
	snapshot_delete_confirmation_dialog.canceled.connect(_cancel_snapshot_confirmation)
	add_child(snapshot_delete_confirmation_dialog)


func _build_new_sandbox_dialogs() -> void:
	new_sandbox_dialog = ConfirmationDialog.new()
	new_sandbox_dialog.title = "新建沙盘"
	new_sandbox_dialog.min_size = NEW_SANDBOX_DIALOG_SIZE
	new_sandbox_dialog.ok_button_text = "下一步…"
	new_sandbox_dialog.cancel_button_text = "取消"
	new_sandbox_dialog.confirmed.connect(_request_create_selected_sandbox)
	new_sandbox_dialog.canceled.connect(_cancel_new_sandbox_dialog)
	new_sandbox_dialog.visibility_changed.connect(_on_new_sandbox_dialog_visibility_changed)
	add_child(new_sandbox_dialog)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	new_sandbox_dialog.add_child(column)
	var hint := Label.new()
	hint.text = "选择一个开局，预览人物和势力。进入后可以继续调整。"
	hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(hint)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	column.add_child(row)
	var list_column := VBoxContainer.new()
	list_column.custom_minimum_size = Vector2(260, 260)
	list_column.add_theme_constant_override("separation", 6)
	row.add_child(list_column)
	new_sandbox_list = ItemList.new()
	new_sandbox_list.name = "NewSandboxTemplateList"
	new_sandbox_list.custom_minimum_size = Vector2(260, 222)
	new_sandbox_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	new_sandbox_list.item_selected.connect(_on_new_sandbox_template_selected)
	UiThemeScript.style_accessible_scrollbar(
		new_sandbox_list.get_v_scroll_bar(),
		"拖动查看全部开局模板；也可用滚轮或 ↑↓"
	)
	list_column.add_child(new_sandbox_list)
	var personal_actions := HBoxContainer.new()
	personal_actions.add_theme_constant_override("separation", 6)
	list_column.add_child(personal_actions)
	new_sandbox_edit_button = Button.new()
	new_sandbox_edit_button.text = "编辑资料…"
	new_sandbox_edit_button.custom_minimum_size = Vector2(0, 32)
	new_sandbox_edit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_sandbox_edit_button.disabled = true
	new_sandbox_edit_button.tooltip_text = "内置模板不能编辑"
	new_sandbox_edit_button.pressed.connect(_request_edit_selected_personal_template)
	personal_actions.add_child(new_sandbox_edit_button)
	new_sandbox_delete_button = Button.new()
	new_sandbox_delete_button.text = "删除…"
	new_sandbox_delete_button.custom_minimum_size = Vector2(0, 32)
	new_sandbox_delete_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_sandbox_delete_button.disabled = true
	new_sandbox_delete_button.tooltip_text = "内置模板不能删除"
	new_sandbox_delete_button.pressed.connect(_request_delete_selected_personal_template)
	personal_actions.add_child(new_sandbox_delete_button)
	var detail_column := VBoxContainer.new()
	detail_column.custom_minimum_size = Vector2(500, 260)
	detail_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_column.add_theme_constant_override("separation", 8)
	row.add_child(detail_column)
	new_sandbox_faction_overview = ScenarioFactionOverviewScript.new()
	new_sandbox_faction_overview.faction_selected.connect(_on_new_sandbox_faction_selected)
	new_sandbox_faction_overview.faction_selection_cleared.connect(_clear_new_sandbox_map_preview)
	detail_column.add_child(new_sandbox_faction_overview)
	new_sandbox_detail_label = RichTextLabel.new()
	new_sandbox_detail_label.custom_minimum_size = Vector2(500, 90)
	new_sandbox_detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	new_sandbox_detail_label.fit_content = false
	new_sandbox_detail_label.scroll_active = true
	new_sandbox_detail_label.bbcode_enabled = false
	new_sandbox_detail_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	UiThemeScript.style_accessible_scrollbar(
		new_sandbox_detail_label.get_v_scroll_bar(),
		"拖动查看开局说明；也可用滚轮或 ↑↓"
	)
	detail_column.add_child(new_sandbox_detail_label)
	new_sandbox_character_preview = ScenarioCharacterPreviewScript.new()
	new_sandbox_character_preview.character_profile_requested.connect(
		_on_new_sandbox_character_profile_requested
	)
	column.add_child(new_sandbox_character_preview)
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	column.add_child(title_row)
	var title_label := Label.new()
	title_label.text = "新沙盘名称"
	title_label.custom_minimum_size = Vector2(96, 0)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", UiThemeScript.TEXT_FIELD)
	title_row.add_child(title_label)
	new_sandbox_title_input = LineEdit.new()
	new_sandbox_title_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_sandbox_title_input.max_length = MAX_SANDBOX_TITLE_LENGTH
	new_sandbox_title_input.placeholder_text = "之后仍可在“编辑沙盘信息”中修改"
	new_sandbox_title_input.tooltip_text = "留空时使用所选模板的默认名称；最长 24 字"
	new_sandbox_title_input.text_changed.connect(_on_new_sandbox_title_changed)
	title_row.add_child(new_sandbox_title_input)

	new_sandbox_confirmation_dialog = ConfirmationDialog.new()
	new_sandbox_confirmation_dialog.title = "开始新的沙盘？"
	new_sandbox_confirmation_dialog.min_size = Vector2i(640, 330)
	new_sandbox_confirmation_dialog.ok_button_text = "备份并新建"
	new_sandbox_confirmation_dialog.cancel_button_text = "返回"
	new_sandbox_confirmation_dialog.confirmed.connect(_confirm_create_selected_sandbox)
	new_sandbox_confirmation_dialog.canceled.connect(_return_to_new_sandbox_dialog)
	add_child(new_sandbox_confirmation_dialog)


func _build_personal_template_dialogs() -> void:
	personal_template_create_dialog = ConfirmationDialog.new()
	personal_template_create_dialog.title = "保存为我的起步模板"
	personal_template_create_dialog.min_size = Vector2i(520, 360)
	personal_template_create_dialog.ok_button_text = "保存模板"
	personal_template_create_dialog.cancel_button_text = "取消"
	personal_template_create_dialog.confirmed.connect(_confirm_create_personal_template)
	add_child(personal_template_create_dialog)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	personal_template_create_dialog.add_child(column)
	personal_template_create_hint_label = Label.new()
	personal_template_create_hint_label.text = "保存后可在“新建沙盘”中反复使用；当前沙盘保持原样。"
	personal_template_create_hint_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	personal_template_create_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	personal_template_create_hint_label.custom_minimum_size = Vector2(470, 40)
	column.add_child(personal_template_create_hint_label)
	var name_label := Label.new()
	name_label.text = "模板名称"
	column.add_child(name_label)
	personal_template_name_input = LineEdit.new()
	personal_template_name_input.max_length = MAX_PERSONAL_TEMPLATE_NAME_LENGTH
	personal_template_name_input.placeholder_text = "例如：刘关张讨董起步"
	column.add_child(personal_template_name_input)
	var description_label := Label.new()
	description_label.text = "模板说明（可选，最多 120 字）"
	column.add_child(description_label)
	personal_template_description_input = TextEdit.new()
	personal_template_description_input.custom_minimum_size = Vector2(0, 72)
	personal_template_description_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	personal_template_description_input.placeholder_text = "说明这个开局的设想与用法"
	column.add_child(personal_template_description_input)
	personal_template_create_summary_label = Label.new()
	personal_template_create_summary_label.custom_minimum_size = Vector2(470, 82)
	personal_template_create_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	personal_template_create_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	column.add_child(personal_template_create_summary_label)

	personal_template_edit_dialog = ConfirmationDialog.new()
	personal_template_edit_dialog.title = "编辑个人模板资料"
	personal_template_edit_dialog.min_size = Vector2i(520, 350)
	personal_template_edit_dialog.ok_button_text = "保存资料"
	personal_template_edit_dialog.cancel_button_text = "返回"
	personal_template_edit_dialog.confirmed.connect(_confirm_edit_personal_template)
	personal_template_edit_dialog.canceled.connect(_cancel_edit_personal_template)
	add_child(personal_template_edit_dialog)
	var edit_column := VBoxContainer.new()
	edit_column.add_theme_constant_override("separation", 8)
	personal_template_edit_dialog.add_child(edit_column)
	var edit_hint := Label.new()
	edit_hint.text = "只修改模板名称和说明。\n开局人物、位置、势力、标记与默认新沙盘名保持不变。"
	edit_hint.custom_minimum_size = Vector2(470, 38)
	edit_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	edit_column.add_child(edit_hint)
	var edit_name_label := Label.new()
	edit_name_label.text = "模板名称"
	edit_column.add_child(edit_name_label)
	personal_template_edit_name_input = LineEdit.new()
	personal_template_edit_name_input.max_length = MAX_PERSONAL_TEMPLATE_NAME_LENGTH
	personal_template_edit_name_input.placeholder_text = "用于“我的模板”列表"
	edit_column.add_child(personal_template_edit_name_input)
	var edit_description_label := Label.new()
	edit_description_label.text = "模板说明（可选，最多 120 字）"
	edit_column.add_child(edit_description_label)
	personal_template_edit_description_input = TextEdit.new()
	personal_template_edit_description_input.custom_minimum_size = Vector2(0, 82)
	personal_template_edit_description_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	personal_template_edit_description_input.placeholder_text = "修改这个开局的说明"
	edit_column.add_child(personal_template_edit_description_input)
	personal_template_edit_summary_label = Label.new()
	personal_template_edit_summary_label.custom_minimum_size = Vector2(470, 64)
	personal_template_edit_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	edit_column.add_child(personal_template_edit_summary_label)

	personal_template_delete_confirmation_dialog = ConfirmationDialog.new()
	personal_template_delete_confirmation_dialog.title = "删除这个个人模板？"
	personal_template_delete_confirmation_dialog.min_size = Vector2i(480, 220)
	personal_template_delete_confirmation_dialog.ok_button_text = "删除模板"
	personal_template_delete_confirmation_dialog.cancel_button_text = "取消"
	personal_template_delete_confirmation_dialog.confirmed.connect(_confirm_delete_selected_personal_template)
	personal_template_delete_confirmation_dialog.canceled.connect(_cancel_delete_selected_personal_template)
	add_child(personal_template_delete_confirmation_dialog)


func _build_scenario_editor_dialogs() -> void:
	scenario_editor_dialog = ConfirmationDialog.new()
	scenario_editor_dialog.title = "编辑本局玩法势力"
	scenario_editor_dialog.min_size = Vector2i(800, 620)
	scenario_editor_dialog.max_size = Vector2i(840, 720)
	scenario_editor_dialog.unresizable = true
	scenario_editor_dialog.ok_button_text = "应用势力"
	scenario_editor_dialog.cancel_button_text = "取消"
	scenario_editor_dialog.confirmed.connect(_confirm_scenario_editor)
	scenario_editor_dialog.canceled.connect(_cancel_scenario_editor)
	add_child(scenario_editor_dialog)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	scenario_editor_dialog.add_child(column)
	var hint := Label.new()
	hint.text = "这里编辑当前沙盘的玩法势力与颜色。人物史料归属保留在资料库；收回卡牌仍保留本局势力。"
	hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(hint)
	scenario_editor_summary_label = Label.new()
	scenario_editor_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	column.add_child(scenario_editor_summary_label)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	var faction_column := VBoxContainer.new()
	faction_column.custom_minimum_size = Vector2(235, 405)
	faction_column.add_theme_constant_override("separation", 6)
	body.add_child(faction_column)
	var faction_label := Label.new()
	faction_label.text = "本局势力（最多 12 个）"
	faction_label.add_theme_color_override("font_color", UiThemeScript.TEXT_FIELD)
	faction_column.add_child(faction_label)
	scenario_faction_list = ItemList.new()
	scenario_faction_list.name = "ScenarioFactionList"
	scenario_faction_list.custom_minimum_size = Vector2(235, 278)
	scenario_faction_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scenario_faction_list.item_selected.connect(_on_scenario_faction_selected)
	UiThemeScript.style_accessible_scrollbar(
		scenario_faction_list.get_v_scroll_bar(),
		"拖动查看本局势力；也可用滚轮或 ↑↓"
	)
	faction_column.add_child(scenario_faction_list)
	var faction_actions := HBoxContainer.new()
	faction_actions.add_theme_constant_override("separation", 6)
	faction_column.add_child(faction_actions)
	scenario_faction_new_button = Button.new()
	scenario_faction_new_button.text = "＋新建"
	scenario_faction_new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scenario_faction_new_button.pressed.connect(_request_create_scenario_faction)
	faction_actions.add_child(scenario_faction_new_button)
	scenario_faction_rename_button = Button.new()
	scenario_faction_rename_button.text = "重命名"
	scenario_faction_rename_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scenario_faction_rename_button.disabled = true
	scenario_faction_rename_button.pressed.connect(_request_rename_scenario_faction)
	faction_actions.add_child(scenario_faction_rename_button)
	scenario_faction_delete_button = Button.new()
	scenario_faction_delete_button.text = "删除"
	scenario_faction_delete_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scenario_faction_delete_button.disabled = true
	scenario_faction_delete_button.pressed.connect(_request_delete_scenario_faction)
	faction_actions.add_child(scenario_faction_delete_button)
	var color_row := HBoxContainer.new()
	color_row.add_theme_constant_override("separation", 8)
	faction_column.add_child(color_row)
	var color_label := Label.new()
	color_label.text = "势力颜色"
	color_label.custom_minimum_size = Vector2(72, 34)
	color_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	color_label.add_theme_color_override("font_color", UiThemeScript.TEXT_FIELD)
	color_row.add_child(color_label)
	scenario_faction_color_button = ColorPickerButton.new()
	scenario_faction_color_button.custom_minimum_size = Vector2(150, 34)
	scenario_faction_color_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scenario_faction_color_button.disabled = true
	scenario_faction_color_button.edit_alpha = false
	scenario_faction_color_button.tooltip_text = "调整本局势力的标识色；只改草稿，点击“应用势力”后才保存"
	scenario_faction_color_button.color_changed.connect(_on_scenario_faction_color_changed)
	color_row.add_child(scenario_faction_color_button)
	var color_picker := scenario_faction_color_button.get_picker()
	color_picker.edit_alpha = false
	for preset_hex in FactionPaletteScript.PRESET_HEX:
		color_picker.add_preset(Color.from_string(preset_hex, Color.WHITE))

	var character_column := VBoxContainer.new()
	character_column.custom_minimum_size = Vector2(500, 355)
	character_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_column.add_theme_constant_override("separation", 6)
	body.add_child(character_column)
	# 长名单不能只依赖一条细滑轨：标题行同时提供首／尾定位，
	# 让鼠标、键盘和触控板都有明确入口；真正的滚动条仍保留拖动与轨道翻页。
	var character_header := HBoxContainer.new()
	character_header.name = "ScenarioCharacterHeader"
	character_header.add_theme_constant_override("separation", 6)
	character_column.add_child(character_header)
	var character_label := Label.new()
	character_label.text = "人物成员（地图／背包）"
	character_label.add_theme_color_override("font_color", UiThemeScript.TEXT_FIELD)
	character_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	character_header.add_child(character_label)
	scenario_character_scroll_range_label = Label.new()
	scenario_character_scroll_range_label.name = "ScenarioCharacterScrollRange"
	scenario_character_scroll_range_label.text = "%d 人" % characters.size()
	scenario_character_scroll_range_label.add_theme_font_size_override("font_size", 12)
	scenario_character_scroll_range_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	scenario_character_scroll_range_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	scenario_character_scroll_range_label.tooltip_text = "可用滚轮、右侧滑轨或首／尾按钮浏览完整人物目录"
	character_header.add_child(scenario_character_scroll_range_label)
	scenario_character_scroll_top_button = _make_scenario_scroll_navigation_button(
		"首", "回到人物成员列表顶部（Home）", "ScenarioCharacterScrollTopButton"
	)
	scenario_character_scroll_top_button.pressed.connect(_scroll_scenario_characters_to_top)
	character_header.add_child(scenario_character_scroll_top_button)
	scenario_character_scroll_bottom_button = _make_scenario_scroll_navigation_button(
		"尾", "跳到人物成员列表末尾（End）", "ScenarioCharacterScrollBottomButton"
	)
	scenario_character_scroll_bottom_button.pressed.connect(_scroll_scenario_characters_to_bottom)
	character_header.add_child(scenario_character_scroll_bottom_button)

	scenario_character_scroll = ScrollContainer.new()
	scenario_character_scroll.name = "ScenarioCharacterRowsScroll"
	scenario_character_scroll.custom_minimum_size = Vector2(500, 320)
	scenario_character_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scenario_character_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scenario_character_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scenario_character_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	scenario_character_scroll.follow_focus = true
	scenario_character_scroll.gui_input.connect(_on_scenario_character_scroll_gui_input)
	# 这是玩法势力编辑器的长名单专用滚动条；后续全局主题刷新只处理
	# 其它内部列表，保留这里的 32px／64px 可操作契约。
	scenario_character_scroll.get_v_scroll_bar().set_meta("preserve_accessible_scrollbar", true)
	UiThemeScript.style_accessible_scrollbar(
		scenario_character_scroll.get_v_scroll_bar(),
		"拖动查看全部 80 位人物；点击轨道翻页；滚轮或 ↑↓；也可用首／尾定位",
		32.0,
		64.0
	)
	scenario_character_scroll.get_v_scroll_bar().gui_input.connect(_on_scenario_character_scroll_gui_input)
	scenario_character_scroll.get_v_scroll_bar().value_changed.connect(_on_scenario_character_scroll_value_changed)
	scenario_character_scroll.resized.connect(_on_scenario_character_scroll_layout_changed)
	character_column.add_child(scenario_character_scroll)
	scenario_character_rows = VBoxContainer.new()
	# 为 32px 滚动轨道保留右侧内容间隙，避免最后一个下拉框被覆盖。
	scenario_character_rows.custom_minimum_size = Vector2(468, 0)
	# 不把 80 行拉伸到滚动视口的最右边；保留轨道与下拉框之间的可视／可点空隙。
	scenario_character_rows.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	scenario_character_rows.add_theme_constant_override("separation", 4)
	scenario_character_rows.resized.connect(_on_scenario_character_scroll_layout_changed)
	scenario_character_scroll.add_child(scenario_character_rows)
	scenario_editor_validation_label = Label.new()
	scenario_editor_validation_label.custom_minimum_size = Vector2(0, 42)
	scenario_editor_validation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scenario_editor_validation_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	column.add_child(scenario_editor_validation_label)

	scenario_faction_name_dialog = ConfirmationDialog.new()
	scenario_faction_name_dialog.title = "新建玩法分组"
	scenario_faction_name_dialog.min_size = Vector2i(440, 190)
	scenario_faction_name_dialog.ok_button_text = "确定"
	scenario_faction_name_dialog.cancel_button_text = "取消"
	scenario_faction_name_dialog.confirmed.connect(_confirm_scenario_faction_name)
	scenario_faction_name_dialog.canceled.connect(_cancel_scenario_faction_name_dialog)
	add_child(scenario_faction_name_dialog)
	var name_column := VBoxContainer.new()
	name_column.add_theme_constant_override("separation", 8)
	scenario_faction_name_dialog.add_child(name_column)
	var name_hint := Label.new()
	name_hint.text = "名称和颜色服务本局推演；人物史料归属保留在资料库。"
	name_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	name_column.add_child(name_hint)
	scenario_faction_name_input = LineEdit.new()
	scenario_faction_name_input.max_length = 24
	scenario_faction_name_input.placeholder_text = "例如：刘备一行"
	name_column.add_child(scenario_faction_name_input)

	scenario_faction_delete_confirmation_dialog = ConfirmationDialog.new()
	scenario_faction_delete_confirmation_dialog.title = "删除这个玩法分组？"
	scenario_faction_delete_confirmation_dialog.min_size = Vector2i(500, 230)
	scenario_faction_delete_confirmation_dialog.ok_button_text = "删除并设为未分组"
	scenario_faction_delete_confirmation_dialog.cancel_button_text = "取消"
	scenario_faction_delete_confirmation_dialog.confirmed.connect(_confirm_delete_scenario_faction)
	scenario_faction_delete_confirmation_dialog.canceled.connect(_return_to_scenario_editor)
	add_child(scenario_faction_delete_confirmation_dialog)

	scenario_editor_discard_confirmation_dialog = ConfirmationDialog.new()
	scenario_editor_discard_confirmation_dialog.title = "放弃本次分组修改？"
	scenario_editor_discard_confirmation_dialog.min_size = Vector2i(480, 220)
	scenario_editor_discard_confirmation_dialog.ok_button_text = "放弃修改"
	scenario_editor_discard_confirmation_dialog.cancel_button_text = "继续编辑"
	scenario_editor_discard_confirmation_dialog.dialog_text = "尚未应用的创建、重命名和人物调整都会丢弃；当前沙盘保持原样。"
	scenario_editor_discard_confirmation_dialog.confirmed.connect(_confirm_discard_scenario_editor)
	scenario_editor_discard_confirmation_dialog.canceled.connect(_return_to_scenario_editor)
	add_child(scenario_editor_discard_confirmation_dialog)


func _build_chronicle_dialogs() -> void:
	chronicle_dialog = AcceptDialog.new()
	chronicle_dialog.title = "玩家纪事 · 当前沙盘"
	chronicle_dialog.min_size = Vector2i(780, 520)
	chronicle_dialog.max_size = Vector2i(800, 650)
	chronicle_dialog.unresizable = true
	chronicle_dialog.ok_button_text = "关闭"
	chronicle_dialog.confirmed.connect(_close_chronicle_dialog)
	chronicle_dialog.canceled.connect(_close_chronicle_dialog)
	add_child(chronicle_dialog)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	chronicle_dialog.add_child(column)
	var hint := Label.new()
	hint.text = "在这里写下战役、援军和架空剧情，作为本局纪事保存。"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(hint)
	var body := HBoxContainer.new()
	body.custom_minimum_size = Vector2(730, 350)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	column.add_child(body)
	var list_column := VBoxContainer.new()
	list_column.custom_minimum_size = Vector2(270, 350)
	list_column.add_theme_constant_override("separation", 6)
	body.add_child(list_column)
	chronicle_list = ItemList.new()
	chronicle_list.name = "ChronicleList"
	chronicle_list.custom_minimum_size = Vector2(270, 300)
	chronicle_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chronicle_list.item_selected.connect(_on_chronicle_selected)
	UiThemeScript.style_accessible_scrollbar(
		chronicle_list.get_v_scroll_bar(),
		"拖动查看玩家纪事；也可用滚轮或 ↑↓"
	)
	list_column.add_child(chronicle_list)
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 6)
	list_column.add_child(action_row)
	chronicle_add_button = Button.new()
	chronicle_add_button.text = "＋写一则"
	chronicle_add_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chronicle_add_button.pressed.connect(_open_new_chronicle_editor)
	action_row.add_child(chronicle_add_button)
	chronicle_edit_button = Button.new()
	chronicle_edit_button.text = "编辑…"
	chronicle_edit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chronicle_edit_button.disabled = true
	chronicle_edit_button.pressed.connect(_open_selected_chronicle_editor)
	action_row.add_child(chronicle_edit_button)
	chronicle_delete_button = Button.new()
	chronicle_delete_button.text = "删除…"
	chronicle_delete_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chronicle_delete_button.disabled = true
	chronicle_delete_button.pressed.connect(_request_delete_selected_chronicle)
	action_row.add_child(chronicle_delete_button)
	chronicle_detail_label = RichTextLabel.new()
	chronicle_detail_label.custom_minimum_size = Vector2(440, 350)
	chronicle_detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chronicle_detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chronicle_detail_label.bbcode_enabled = false
	chronicle_detail_label.fit_content = false
	chronicle_detail_label.scroll_active = true
	chronicle_detail_label.selection_enabled = true
	chronicle_detail_label.add_theme_color_override("default_color", UiThemeScript.TEXT_BODY)
	UiThemeScript.style_accessible_scrollbar(
		chronicle_detail_label.get_v_scroll_bar(),
		"拖动查看纪事正文；也可用滚轮或 ↑↓"
	)
	body.add_child(chronicle_detail_label)

	chronicle_editor_dialog = ConfirmationDialog.new()
	chronicle_editor_dialog.title = "写一则玩家纪事"
	chronicle_editor_dialog.min_size = Vector2i(580, 500)
	chronicle_editor_dialog.max_size = Vector2i(600, 620)
	chronicle_editor_dialog.unresizable = true
	chronicle_editor_dialog.ok_button_text = "保存纪事"
	chronicle_editor_dialog.cancel_button_text = "取消"
	chronicle_editor_dialog.confirmed.connect(_confirm_chronicle_editor)
	chronicle_editor_dialog.canceled.connect(_cancel_chronicle_editor)
	add_child(chronicle_editor_dialog)
	var editor_column := VBoxContainer.new()
	editor_column.add_theme_constant_override("separation", 7)
	chronicle_editor_dialog.add_child(editor_column)
	var editor_hint := Label.new()
	editor_hint.text = "填写类型、时间、标题与正文，保存后写入本局纪事。"
	editor_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	editor_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	editor_column.add_child(editor_hint)
	var type_label := Label.new()
	type_label.text = "纪事类型"
	editor_column.add_child(type_label)
	chronicle_type_select = OptionButton.new()
	for entry_type in CHRONICLE_ENTRY_TYPES:
		chronicle_type_select.add_item(_chronicle_type_label(str(entry_type)))
		chronicle_type_select.set_item_metadata(chronicle_type_select.item_count - 1, entry_type)
	chronicle_type_select.item_selected.connect(func(_index: int): _refresh_chronicle_editor_state())
	editor_column.add_child(chronicle_type_select)
	var time_label := Label.new()
	time_label.text = "纪事时间（可选，最多 24 字）"
	editor_column.add_child(time_label)
	chronicle_time_input = LineEdit.new()
	chronicle_time_input.max_length = MAX_CHRONICLE_TIME_LABEL_LENGTH
	chronicle_time_input.placeholder_text = "例如：中平元年三月／攻下汉中之后"
	chronicle_time_input.text_changed.connect(func(_text: String): _refresh_chronicle_editor_state())
	editor_column.add_child(chronicle_time_input)
	var title_label := Label.new()
	title_label.text = "标题（必填，最多 36 字）"
	editor_column.add_child(title_label)
	chronicle_title_input = LineEdit.new()
	chronicle_title_input.max_length = MAX_CHRONICLE_TITLE_LENGTH
	chronicle_title_input.placeholder_text = "例如：援军抵达广宗"
	chronicle_title_input.text_changed.connect(func(_text: String): _refresh_chronicle_editor_state())
	editor_column.add_child(chronicle_title_input)
	var body_label := Label.new()
	body_label.text = "正文（可选，最多 400 字）"
	editor_column.add_child(body_label)
	chronicle_body_input = TextEdit.new()
	chronicle_body_input.custom_minimum_size = Vector2(0, 175)
	chronicle_body_input.placeholder_text = "记录你想保留下来的战况、转折和脑洞。"
	chronicle_body_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	chronicle_body_input.text_changed.connect(_on_chronicle_body_changed)
	editor_column.add_child(chronicle_body_input)
	chronicle_character_count_label = Label.new()
	chronicle_character_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	chronicle_character_count_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	editor_column.add_child(chronicle_character_count_label)

	chronicle_delete_confirmation_dialog = ConfirmationDialog.new()
	chronicle_delete_confirmation_dialog.title = "删除这则玩家纪事？"
	chronicle_delete_confirmation_dialog.min_size = Vector2i(500, 230)
	chronicle_delete_confirmation_dialog.ok_button_text = "删除纪事"
	chronicle_delete_confirmation_dialog.cancel_button_text = "取消"
	chronicle_delete_confirmation_dialog.confirmed.connect(_confirm_delete_selected_chronicle)
	chronicle_delete_confirmation_dialog.canceled.connect(_return_to_chronicle_dialog)
	add_child(chronicle_delete_confirmation_dialog)

	chronicle_editor_discard_confirmation_dialog = ConfirmationDialog.new()
	chronicle_editor_discard_confirmation_dialog.title = "放弃这次纪事修改？"
	chronicle_editor_discard_confirmation_dialog.min_size = Vector2i(500, 230)
	chronicle_editor_discard_confirmation_dialog.ok_button_text = "放弃修改"
	chronicle_editor_discard_confirmation_dialog.cancel_button_text = "继续编辑"
	chronicle_editor_discard_confirmation_dialog.dialog_text = "尚未保存的类型、时间、标题和正文会丢失；已有纪事和当前沙盘保持原样。"
	chronicle_editor_discard_confirmation_dialog.confirmed.connect(_confirm_discard_chronicle_editor)
	chronicle_editor_discard_confirmation_dialog.canceled.connect(_return_to_chronicle_editor)
	add_child(chronicle_editor_discard_confirmation_dialog)


func _build_current_branch_dialogs() -> void:
	branch_sandbox_dialog = ConfirmationDialog.new()
	branch_sandbox_dialog.title = "从当前局面另开沙盘"
	branch_sandbox_dialog.min_size = Vector2i(560, 330)
	branch_sandbox_dialog.ok_button_text = "下一步…"
	branch_sandbox_dialog.cancel_button_text = "取消"
	branch_sandbox_dialog.confirmed.connect(_request_branch_current_sandbox)
	branch_sandbox_dialog.canceled.connect(_cancel_branch_current_sandbox)
	add_child(branch_sandbox_dialog)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	branch_sandbox_dialog.add_child(column)
	var hint := Label.new()
	hint.text = "保留此刻的全部摆放，用新的沙盘名称继续推演。\n确认后，当前局面会先留作可恢复的命名快照。"
	hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(hint)
	branch_sandbox_summary_label = Label.new()
	branch_sandbox_summary_label.custom_minimum_size = Vector2(500, 100)
	branch_sandbox_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	column.add_child(branch_sandbox_summary_label)
	var title_label := Label.new()
	title_label.text = "新沙盘名称"
	title_label.add_theme_color_override("font_color", UiThemeScript.TEXT_FIELD)
	column.add_child(title_label)
	branch_sandbox_title_input = LineEdit.new()
	branch_sandbox_title_input.max_length = MAX_SANDBOX_TITLE_LENGTH
	branch_sandbox_title_input.placeholder_text = "之后仍可在“编辑沙盘信息”中修改"
	branch_sandbox_title_input.tooltip_text = "最长 24 字；备注与开局来源会沿用当前沙盘"
	branch_sandbox_title_input.text_changed.connect(_on_branch_sandbox_title_changed)
	column.add_child(branch_sandbox_title_input)

	branch_sandbox_confirmation_dialog = ConfirmationDialog.new()
	branch_sandbox_confirmation_dialog.title = "确认从这里另开？"
	branch_sandbox_confirmation_dialog.min_size = Vector2i(580, 320)
	branch_sandbox_confirmation_dialog.ok_button_text = "保护当前局面并另开"
	branch_sandbox_confirmation_dialog.cancel_button_text = "返回"
	branch_sandbox_confirmation_dialog.confirmed.connect(_confirm_branch_current_sandbox)
	branch_sandbox_confirmation_dialog.canceled.connect(_return_to_branch_current_sandbox)
	add_child(branch_sandbox_confirmation_dialog)


func _open_new_sandbox_dialog(preferred_template_id := "", preferred_title := "", preferred_source := "") -> void:
	if new_sandbox_dialog == null or new_sandbox_list == null:
		return
	new_sandbox_list.clear()
	_pending_scenario_template_id = ""
	_pending_scenario_template_source = ""
	_pending_new_sandbox_title = ""
	_clear_new_sandbox_map_preview()
	new_sandbox_edit_button.disabled = true
	new_sandbox_edit_button.tooltip_text = "内置模板不能编辑"
	new_sandbox_delete_button.disabled = true
	new_sandbox_delete_button.tooltip_text = "内置模板不能删除"
	var ok_button := new_sandbox_dialog.get_ok_button()
	if (not scenario_template_load_error.is_empty() or scenario_templates.is_empty()) and personal_scenario_templates.is_empty():
		new_sandbox_detail_label.text = "起步模板暂时无法使用。\n\n%s" % (scenario_template_load_error if not scenario_template_load_error.is_empty() else "没有可用模板。")
		new_sandbox_faction_overview.set_records([], "没有可用的开局势力")
		new_sandbox_character_preview.clear("没有可用的重点人物")
		ok_button.disabled = true
		new_sandbox_dialog.popup_centered(NEW_SANDBOX_DIALOG_SIZE)
		return
	var selected_index := -1
	if not scenario_templates.is_empty():
		new_sandbox_list.add_item("内置模板")
		var header_index := new_sandbox_list.item_count - 1
		new_sandbox_list.set_item_disabled(header_index, true)
		new_sandbox_list.set_item_metadata(header_index, {"source": "header", "id": "builtin"})
	for index in range(scenario_templates.size()):
		var template: Dictionary = scenario_templates[index]
		var label := _scenario_template_display_label(template)
		new_sandbox_list.add_item(label)
		var item_index := new_sandbox_list.item_count - 1
		new_sandbox_list.set_item_metadata(item_index, {"source": "builtin", "id": str(template.get("id", ""))})
		if selected_index < 0:
			selected_index = item_index
		if str(template.get("id", "")) == preferred_template_id and preferred_source in ["", "builtin"]:
			selected_index = item_index
	if not personal_scenario_templates.is_empty() or not personal_scenario_template_load_error.is_empty():
		new_sandbox_list.add_item("我的模板（%d）" % personal_scenario_templates.size())
		var personal_header_index := new_sandbox_list.item_count - 1
		new_sandbox_list.set_item_disabled(personal_header_index, true)
		new_sandbox_list.set_item_metadata(personal_header_index, {"source": "header", "id": "personal"})
		if not personal_scenario_template_load_error.is_empty():
			new_sandbox_list.add_item("我的模板暂时无法读取")
			var error_index := new_sandbox_list.item_count - 1
			new_sandbox_list.set_item_disabled(error_index, true)
			new_sandbox_list.set_item_metadata(error_index, {"source": "error", "id": "personal"})
	for index in range(personal_scenario_templates.size() - 1, -1, -1):
		var template: Dictionary = personal_scenario_templates[index]
		new_sandbox_list.add_item(str(template.get("name", "未命名模板")))
		var item_index := new_sandbox_list.item_count - 1
		var template_id := str(template.get("id", ""))
		new_sandbox_list.set_item_metadata(item_index, {"source": "personal", "id": template_id})
		new_sandbox_list.set_item_tooltip(item_index, str(template.get("name", "未命名模板")))
		if selected_index < 0:
			selected_index = item_index
		if template_id == preferred_template_id and preferred_source in ["", "personal"]:
			selected_index = item_index
	if selected_index < 0:
		new_sandbox_detail_label.text = "没有可用模板。"
		new_sandbox_faction_overview.set_records([], "没有可用的开局势力")
		new_sandbox_character_preview.clear("没有可用的重点人物")
		ok_button.disabled = true
		new_sandbox_dialog.popup_centered(NEW_SANDBOX_DIALOG_SIZE)
		return
	new_sandbox_list.select(selected_index)
	_on_new_sandbox_template_selected(selected_index)
	if not preferred_title.is_empty() and _pending_scenario_template_id == preferred_template_id:
		var selected_template := _selected_scenario_template()
		_pending_new_sandbox_title = _sanitize_single_line(preferred_title, MAX_SANDBOX_TITLE_LENGTH, str(selected_template.get("title", "未命名沙盘")))
		new_sandbox_title_input.set_text(_pending_new_sandbox_title)
	ok_button.disabled = false
	new_sandbox_dialog.popup_centered(NEW_SANDBOX_DIALOG_SIZE)
	new_sandbox_list.call_deferred("grab_focus")


func _on_new_sandbox_template_selected(index: int) -> void:
	_clear_new_sandbox_map_preview()
	if new_sandbox_list == null or index < 0 or index >= new_sandbox_list.item_count:
		_pending_scenario_template_id = ""
		_pending_scenario_template_source = ""
		new_sandbox_faction_overview.set_records([], "请选择一个有效模板")
		new_sandbox_character_preview.clear("请选择一个有效模板")
		return
	var metadata_value: Variant = new_sandbox_list.get_item_metadata(index)
	if not (metadata_value is Dictionary):
		_pending_scenario_template_id = ""
		_pending_scenario_template_source = ""
		new_sandbox_faction_overview.set_records([], "请选择一个有效模板")
		new_sandbox_character_preview.clear("请选择一个有效模板")
		return
	var metadata: Dictionary = metadata_value
	var source := str(metadata.get("source", ""))
	var template_id := str(metadata.get("id", ""))
	var template := _find_personal_scenario_template(template_id) if source == "personal" else _find_scenario_template(template_id)
	if template.is_empty():
		_pending_scenario_template_id = ""
		_pending_scenario_template_source = ""
		new_sandbox_detail_label.text = "这个起步模板已失效，请重新打开窗口。"
		new_sandbox_faction_overview.set_records([], "这个模板没有可用势力")
		new_sandbox_character_preview.clear("这个模板没有可用的重点人物")
		new_sandbox_dialog.get_ok_button().disabled = true
		return
	_pending_scenario_template_id = template_id
	_pending_scenario_template_source = source
	_pending_new_sandbox_title = str(template.get("title", "未命名沙盘"))
	if new_sandbox_title_input != null:
		new_sandbox_title_input.set_text(_pending_new_sandbox_title)
	var placement_count := int((template.get("placements", []) as Array).size())
	var annotation_count := int((template.get("annotations", []) as Array).size())
	var faction_count := int((template.get("factions", []) as Array).size())
	var ownership_count := int((template.get("city_ownership", []) as Array).size())
	var summary := _template_placement_summary(template)
	var faction_summary := _template_faction_summary(template)
	new_sandbox_faction_overview.set_records(
		_template_faction_overview_records(template),
		"空白沙盘 · 从人物背包自由摆放"
	)
	new_sandbox_character_preview.set_records(
		_template_character_preview_records(template),
		"空白沙盘 · 不预设重点人物"
	)
	if source == "personal":
		var personal_year_value: Variant = template.get("start_year", template.get("year", null))
		var personal_year_text := "自由年代" if personal_year_value == null else "%d 年" % int(personal_year_value)
		new_sandbox_detail_label.text = "我的模板\n%s\n%s · %d 个势力 · %d 位预摆人物 · %d 座归属城池 · %d 个标记\n保存于：%s\n默认新沙盘名：%s\n来自：%s\n\n%s\n\n本局起始势力\n%s\n\n初始摆放\n%s\n\n模板范围\n这是你保存的个人开局；进入后可继续修改和推演。" % [
			str(template.get("name", "未命名模板")), personal_year_text, faction_count, placement_count, ownership_count, annotation_count,
			_format_display_time(str(template.get("created_at", ""))), str(template.get("title", "未命名沙盘")),
			str(template.get("source_title", "未命名沙盘")),
			str(template.get("description", "")), faction_summary,
			summary if not summary.is_empty() else "不预摆人物，从背包自由开始。"
		]
		var library_blocked := _personal_template_writes_blocked
		new_sandbox_edit_button.disabled = library_blocked
		new_sandbox_edit_button.tooltip_text = (
			"个人模板库处于原文件保护状态，暂时不能编辑"
			if library_blocked
		else "修改模板名称和说明；开局内容保持原样"
		)
		new_sandbox_delete_button.disabled = library_blocked
		new_sandbox_delete_button.tooltip_text = (
			"个人模板库处于原文件保护状态，暂时不能删除"
			if library_blocked
		else "删除这个个人模板；当前沙盘保持原样"
		)
	else:
		new_sandbox_detail_label.text = "%s\n起始内容：%d 个势力 · %d 位预摆人物 · %d 座归属城池\n进入后仍可自由修改人物、势力和城池归属。\n\n%s\n\n本局起始势力\n%s\n\n初始摆放\n%s\n\n资料边界\n%s" % [
			_scenario_template_display_label(template), faction_count, placement_count, ownership_count,
			str(template.get("description", "")), faction_summary,
			summary if not summary.is_empty() else "不预摆人物，从背包自由开始。",
			str(template.get("basis_note", "不预设剧情、任务或胜负条件。"))
		]
		new_sandbox_edit_button.disabled = true
		new_sandbox_edit_button.tooltip_text = "内置模板不能编辑"
		new_sandbox_delete_button.disabled = true
		new_sandbox_delete_button.tooltip_text = "内置模板不能删除"
	new_sandbox_dialog.get_ok_button().disabled = false


func _selected_scenario_template() -> Dictionary:
	if _pending_scenario_template_source == "personal":
		return _find_personal_scenario_template(_pending_scenario_template_id)
	return _find_scenario_template(_pending_scenario_template_id)


func _scenario_template_display_label(template: Dictionary) -> String:
	var era_label := _sanitize_single_line(
		str(template.get("era_label", template.get("name", "未命名模板"))),
		24,
		"未命名模板"
	)
	var year_value: Variant = template.get("start_year", template.get("year", null))
	if year_value == null:
		return era_label
	return "%d 年 · %s" % [int(year_value), era_label]


func _on_new_sandbox_title_changed(value: String) -> void:
	_pending_new_sandbox_title = value


func _template_placement_summary(template: Dictionary) -> String:
	var grouped: Dictionary = {}
	var place_order: Array[String] = []
	var free_names: Array[String] = []
	for placement_value in template.get("placements", []):
		if not (placement_value is Dictionary):
			continue
		var placement: Dictionary = placement_value
		var place_id := str(placement.get("place_id", ""))
		if place_id.is_empty():
			free_names.append(_character_name(str(placement.get("character_id", ""))))
			continue
		if not grouped.has(place_id):
			grouped[place_id] = []
			place_order.append(place_id)
		(grouped[place_id] as Array).append(_character_name(str(placement.get("character_id", ""))))
	var lines: Array[String] = []
	for place_id in place_order:
		var place := _find_place(place_id)
		var place_name := str(place.get("name", place_id))
		lines.append("%s → %s" % ["、".join(grouped[place_id]), place_name])
	if not free_names.is_empty():
		lines.append("%s → 地图自由位置" % "、".join(free_names))
	return "\n".join(lines)


func _template_faction_summary(template: Dictionary) -> String:
	var names_by_faction: Dictionary = {}
	var faction_order: Array[String] = []
	for faction_value in template.get("factions", []):
		if not (faction_value is Dictionary):
			continue
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", ""))
		if faction_id.is_empty():
			continue
		faction_order.append(faction_id)
		names_by_faction[faction_id] = {"name": str(faction.get("name", faction_id)), "characters": []}
	for assignment_value in template.get("character_assignments", []):
		if not (assignment_value is Dictionary):
			continue
		var assignment: Dictionary = assignment_value
		var faction_id := str(assignment.get("faction_id", ""))
		if names_by_faction.has(faction_id):
			(names_by_faction[faction_id]["characters"] as Array).append(_character_name(str(assignment.get("character_id", ""))))
	if faction_order.is_empty():
		return "未设置，可自由摆放。"
	var lines: Array[String] = []
	for faction_id in faction_order:
		var record: Dictionary = names_by_faction[faction_id]
		var member_names: Array = record.get("characters", [])
		lines.append("%s：%s" % [str(record.get("name", faction_id)), "、".join(member_names)])
	return "\n".join(lines)


func _template_featured_character_summary(template: Dictionary) -> String:
	var names: Array[String] = []
	for character_id_value in template.get("featured_character_ids", []):
		var character_id := str(character_id_value)
		if character_id.is_empty():
			continue
		names.append(_character_name(character_id))
	if names.is_empty():
		return "未指定，全部人物仍可从背包拿出"
	return "、".join(names)


func _character_name_list_summary(character_ids: Array, display_limit := 3) -> String:
	var names: Array[String] = []
	for character_id_value in character_ids:
		var character_id := str(character_id_value)
		if character_id.is_empty():
			continue
		var name_value := _character_name(character_id)
		if name_value not in names:
			names.append(name_value)
	if names.is_empty():
		return "无人"
	var visible_names: Array[String] = []
	for index in range(mini(names.size(), maxi(1, display_limit))):
		visible_names.append(names[index])
	if names.size() <= visible_names.size():
		return "、".join(visible_names)
	return "%s等%d人" % ["、".join(visible_names), names.size()]


func _template_featured_readiness_summary(template: Dictionary) -> String:
	var preplaced_ids: Dictionary = {}
	for placement_value in template.get("placements", []):
		if placement_value is Dictionary:
			var character_id := str((placement_value as Dictionary).get("character_id", ""))
			if not character_id.is_empty():
				preplaced_ids[character_id] = true
	var featured_ids: Array[String] = []
	var pending_ids: Array[String] = []
	for character_id_value in template.get("featured_character_ids", []):
		var character_id := str(character_id_value)
		if character_id.is_empty() or not _has_character_id(character_id) or character_id in featured_ids:
			continue
		featured_ids.append(character_id)
		if not preplaced_ids.has(character_id):
			pending_ids.append(character_id)
	if featured_ids.is_empty():
		return "未预设，可从人物背包自由摆放"
	if pending_ids.is_empty():
		return "%d 人 · 全部在图上" % featured_ids.size()
	return "%d 人 · %d 图上 · %s待摆" % [
		featured_ids.size(),
		featured_ids.size() - pending_ids.size(),
		_character_name_list_summary(pending_ids, 3),
	]


func _template_character_preview_records(template: Dictionary) -> Array[Dictionary]:
	var preplaced_ids: Dictionary = {}
	for placement_value in template.get("placements", []):
		if placement_value is Dictionary:
			var character_id := str((placement_value as Dictionary).get("character_id", ""))
			if not character_id.is_empty():
				preplaced_ids[character_id] = true
	var records: Array[Dictionary] = []
	for character_id_value in template.get("featured_character_ids", []):
		var character_id := str(character_id_value)
		if character_id.is_empty() or not _has_character_id(character_id):
			continue
		records.append({
			"id": character_id,
			"name": _character_name(character_id),
			"state": "preplaced" if preplaced_ids.has(character_id) else "pending",
		})
	return records


func _build_character_profile_opening_context(template: Dictionary, template_source: String) -> Dictionary:
	var faction_names: Dictionary = {}
	for faction_value in template.get("factions", []):
		if not (faction_value is Dictionary):
			continue
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", "")).strip_edges()
		if not faction_id.is_empty():
			faction_names[faction_id] = str(faction.get("name", faction_id))
	var faction_by_character: Dictionary = {}
	for assignment_value in template.get("character_assignments", []):
		if not (assignment_value is Dictionary):
			continue
		var assignment: Dictionary = assignment_value
		var character_id := str(assignment.get("character_id", "")).strip_edges()
		var faction_id := str(assignment.get("faction_id", "")).strip_edges()
		if not character_id.is_empty() and faction_names.has(faction_id):
			faction_by_character[character_id] = faction_id
	var placements_by_character: Dictionary = {}
	for placement_value in template.get("placements", []):
		if not (placement_value is Dictionary):
			continue
		var placement: Dictionary = placement_value
		var character_id := str(placement.get("character_id", "")).strip_edges()
		if not character_id.is_empty() and not placements_by_character.has(character_id):
			placements_by_character[character_id] = placement.duplicate(true)
	var records: Dictionary = {}
	for character_id_value in template.get("featured_character_ids", []):
		var character_id := str(character_id_value).strip_edges()
		if character_id.is_empty() or not _has_character_id(character_id):
			continue
		var position_text := "待从人物背包摆放"
		var state := "pending"
		if placements_by_character.has(character_id):
			state = "preplaced"
			var placement: Dictionary = placements_by_character[character_id]
			var place_id := str(placement.get("place_id", "")).strip_edges()
			if place_id.is_empty():
				position_text = "已预摆于地图自由位置"
			else:
				var place := _find_place(place_id)
				position_text = "已预摆于%s" % str(place.get("name", place_id))
		var faction_id := str(faction_by_character.get(character_id, ""))
		records[character_id] = {
			"state": state,
			"position_text": position_text,
			"faction_text": str(faction_names.get(faction_id, "未预设")),
		}
	var opening_label := _scenario_template_display_label(template)
	if template_source == "personal":
		opening_label = "我的模板 · %s" % opening_label
	return {
		"mode": "opening_preview",
		"template_id": str(template.get("id", "")),
		"template_source": template_source,
		"opening_label": opening_label,
		"records": records,
	}


func _on_new_sandbox_character_profile_requested(character_id: String) -> void:
	if (
		new_sandbox_dialog == null
		or not new_sandbox_dialog.visible
		or new_sandbox_character_preview == null
	):
		return
	var template := _selected_scenario_template()
	if template.is_empty():
		_set_status("请先选择一个有效的起步模板")
		return
	var opening_context := _build_character_profile_opening_context(
		template,
		_pending_scenario_template_source
	)
	var opening_records: Dictionary = opening_context.get("records", {})
	if not opening_records.has(character_id):
		_set_status("这名人物不在所选开局的重点人物中")
		return
	var browse_ids: Array[String] = []
	for record_value in _template_character_preview_records(template):
		var browse_id := str(record_value.get("id", ""))
		if opening_records.has(browse_id):
			browse_ids.append(browse_id)
	var overview_state: Dictionary = new_sandbox_faction_overview.get_display_state()
	var preview_state: Dictionary = new_sandbox_character_preview.get_display_state()
	var selected_items := new_sandbox_list.get_selected_items()
	character_detail_opening_return_state = {
		"template_id": _pending_scenario_template_id,
		"template_source": _pending_scenario_template_source,
		"title": new_sandbox_title_input.text,
		"list_index": int(selected_items[0]) if not selected_items.is_empty() else -1,
		"selected_faction_id": str(overview_state.get("selected_faction_id", "")),
		"preview_scroll": int(preview_state.get("scroll_value", 0)),
		"character_id": character_id,
	}
	character_detail_opening_context = opening_context
	character_detail_return_focus = null
	character_detail_restore_focus_on_close = false
	character_detail_restore_roster_on_close = false
	new_sandbox_dialog.hide()
	if not _open_character_profile(character_id, browse_ids):
		var return_state := character_detail_opening_return_state.duplicate(true)
		character_detail_opening_context.clear()
		character_detail_opening_return_state.clear()
		call_deferred("_restore_new_sandbox_after_character_profile", return_state)


func _restore_new_sandbox_after_character_profile(return_state: Dictionary) -> void:
	if new_sandbox_dialog == null or new_sandbox_list == null:
		return
	var template_id := str(return_state.get("template_id", ""))
	var template_source := str(return_state.get("template_source", ""))
	var requested_title := str(return_state.get("title", ""))
	if (
		_pending_scenario_template_id != template_id
		or _pending_scenario_template_source != template_source
	):
		_open_new_sandbox_dialog(template_id, requested_title, template_source)
	else:
		new_sandbox_title_input.set_text(requested_title)
		_pending_new_sandbox_title = requested_title
		new_sandbox_dialog.popup_centered(NEW_SANDBOX_DIALOG_SIZE)
		new_sandbox_dialog.size = NEW_SANDBOX_DIALOG_SIZE
	await get_tree().process_frame
	var faction_id := str(return_state.get("selected_faction_id", ""))
	if faction_id.is_empty():
		new_sandbox_faction_overview.clear_selection(false)
		_clear_new_sandbox_map_preview()
	else:
		new_sandbox_faction_overview.select_faction(faction_id, true)
	var preview_scroll := int(return_state.get("preview_scroll", 0))
	var preview_scroll_container := new_sandbox_character_preview.get_scroll_container() as ScrollContainer
	if preview_scroll_container != null:
		preview_scroll_container.scroll_horizontal = preview_scroll
	await get_tree().process_frame
	var character_id := str(return_state.get("character_id", ""))
	if not new_sandbox_character_preview.focus_character(character_id):
		new_sandbox_list.grab_focus()
	_set_status("已返回%s · 仍可继续选择或新建" % _scenario_template_display_label(_selected_scenario_template()))


func get_character_profile_opening_contract() -> Dictionary:
	return {
		"active": not character_detail_opening_context.is_empty(),
		"mode": str(character_detail_opening_context.get("mode", "current_sandbox")),
		"template_id": str(character_detail_opening_context.get("template_id", "")),
		"template_source": str(character_detail_opening_context.get("template_source", "")),
		"opening_label": str(character_detail_opening_context.get("opening_label", "")),
		"records": (character_detail_opening_context.get("records", {}) as Dictionary).duplicate(true),
		"return_state": character_detail_opening_return_state.duplicate(true),
		"new_sandbox_visible": new_sandbox_dialog != null and new_sandbox_dialog.visible,
	}


func _template_faction_count_summary(template: Dictionary) -> String:
	var counts: Dictionary = {}
	var names: Dictionary = {}
	var order: Array[String] = []
	for faction_value in template.get("factions", []):
		if faction_value is Dictionary:
			var faction: Dictionary = faction_value
			var faction_id := str(faction.get("id", ""))
			order.append(faction_id)
			counts[faction_id] = 0
			names[faction_id] = str(faction.get("name", faction_id))
	for assignment_value in template.get("character_assignments", []):
		if assignment_value is Dictionary:
			var faction_id := str((assignment_value as Dictionary).get("faction_id", ""))
			if counts.has(faction_id):
				counts[faction_id] = int(counts[faction_id]) + 1
	if order.is_empty():
		return "未设置"
	var parts: Array[String] = []
	for faction_id in order:
		parts.append("%s %d 人" % [str(names.get(faction_id, faction_id)), int(counts.get(faction_id, 0))])
	return "；".join(parts)


func _template_faction_overview_records(template: Dictionary) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var record_index_by_id: Dictionary = {}
	for faction_value in template.get("factions", []):
		if not (faction_value is Dictionary):
			continue
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", "")).strip_edges()
		if faction_id.is_empty() or record_index_by_id.has(faction_id):
			continue
		record_index_by_id[faction_id] = records.size()
		records.append({
			"id": faction_id,
			"name": str(faction.get("name", faction_id)),
			"color": str(faction.get("color", "#8B8068")),
			"character_ids": [],
			"character_count": 0,
			"city_place_ids": [],
			"city_count": 0,
			"placement_place_ids": [],
			"placement_positions": [],
		})
	var faction_by_character: Dictionary = {}
	for assignment_value in template.get("character_assignments", []):
		if not (assignment_value is Dictionary):
			continue
		var assignment: Dictionary = assignment_value
		var character_id := str(assignment.get("character_id", ""))
		var faction_id := str(assignment.get("faction_id", ""))
		if character_id.is_empty() or not record_index_by_id.has(faction_id):
			continue
		faction_by_character[character_id] = faction_id
		var record_index := int(record_index_by_id[faction_id])
		var record: Dictionary = records[record_index]
		(record["character_ids"] as Array).append(character_id)
		record["character_count"] = int(record.get("character_count", 0)) + 1
		records[record_index] = record
	for ownership_value in template.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			continue
		var ownership: Dictionary = ownership_value
		var faction_id := str(ownership.get("faction_id", ""))
		var place_id := str(ownership.get("place_id", ""))
		if place_id.is_empty() or not record_index_by_id.has(faction_id):
			continue
		var record_index := int(record_index_by_id[faction_id])
		var record: Dictionary = records[record_index]
		var city_place_ids: Array = record.get("city_place_ids", [])
		if place_id not in city_place_ids:
			city_place_ids.append(place_id)
		record["city_count"] = city_place_ids.size()
		records[record_index] = record
	for placement_value in template.get("placements", []):
		if not (placement_value is Dictionary):
			continue
		var placement: Dictionary = placement_value
		var character_id := str(placement.get("character_id", ""))
		var faction_id := str(faction_by_character.get(character_id, ""))
		if not record_index_by_id.has(faction_id):
			continue
		var record_index := int(record_index_by_id[faction_id])
		var record: Dictionary = records[record_index]
		var place_id := str(placement.get("place_id", ""))
		if not place_id.is_empty():
			var placement_place_ids: Array = record.get("placement_place_ids", [])
			if place_id not in placement_place_ids:
				placement_place_ids.append(place_id)
		elif placement.has("x") and placement.has("y"):
			(record["placement_positions"] as Array).append({
				"x": clampf(float(placement.get("x", 0.5)), 0.0, 1.0),
				"y": clampf(float(placement.get("y", 0.5)), 0.0, 1.0),
			})
		records[record_index] = record
	return records


func _on_new_sandbox_faction_selected(record: Dictionary) -> void:
	if map_board != null:
		map_board.set_scenario_preview_highlight(record)


func _clear_new_sandbox_map_preview() -> void:
	if map_board != null:
		map_board.clear_scenario_preview_highlight()


func _on_new_sandbox_dialog_visibility_changed() -> void:
	if new_sandbox_dialog != null and not new_sandbox_dialog.visible:
		_clear_new_sandbox_map_preview()


func _request_create_selected_sandbox() -> void:
	var candidate := _build_personal_template_candidate(_pending_scenario_template_id) if _pending_scenario_template_source == "personal" else _build_scenario_template_candidate(_pending_scenario_template_id)
	if not bool(candidate.get("ok", false)):
		_show_message("暂时不能新建", str(candidate.get("message", "起步模板无效，当前沙盘没有变化。")))
		return
	var template: Dictionary = candidate.get("template", {})
	_pending_new_sandbox_title = _sanitize_single_line(
		new_sandbox_title_input.text if new_sandbox_title_input != null else _pending_new_sandbox_title,
		MAX_SANDBOX_TITLE_LENGTH,
		str(template.get("title", "未命名沙盘"))
	)
	if new_sandbox_title_input != null:
		new_sandbox_title_input.set_text(_pending_new_sandbox_title)
	new_sandbox_dialog.hide()
	new_sandbox_confirmation_dialog.dialog_text = "即将开始：%s%s\n新沙盘：%s\n开局：%d 个势力 · %d 位人物 · %d 座城池 · %d 个标记\n\n当前沙盘：%s · %d 位人物 · %d 个标记\n\n将先备份当前沙盘，再开始新局。\n收藏、命名快照和个人模板会保留；本次新建可撤销。" % [
		"我的模板 · " if _pending_scenario_template_source == "personal" else "",
		_scenario_template_display_label(template),
		_pending_new_sandbox_title,
		int((template.get("factions", []) as Array).size()),
		int((candidate.get("placements", {}) as Dictionary).size()),
		int((template.get("city_ownership", []) as Array).size()),
		int((candidate.get("annotations", {}) as Dictionary).size()),
		str(sandbox_metadata.get("title", "未命名沙盘")),
		placements.size(),
		annotations.size()
	]
	new_sandbox_confirmation_dialog.popup_centered(Vector2i(640, 330))


func _confirm_create_selected_sandbox() -> void:
	var template_id := _pending_scenario_template_id
	var template_source := _pending_scenario_template_source
	var requested_title := _pending_new_sandbox_title
	var result := _apply_scenario_template(template_id, requested_title, template_source)
	_pending_scenario_template_id = ""
	_pending_scenario_template_source = ""
	_pending_new_sandbox_title = ""
	if not bool(result.get("ok", false)):
		_show_message("暂时不能新建", str(result.get("message", "当前沙盘没有变化。")))
		return
	call_deferred("_finish_new_sandbox_landing")


func _new_sandbox_landing_plan() -> Dictionary:
	var featured_ids: Array[String] = []
	for character_id_value in scenario_state.get("featured_character_ids", []):
		var character_id := str(character_id_value)
		if not character_id.is_empty() and _has_character_id(character_id) and character_id not in featured_ids:
			featured_ids.append(character_id)
	var pending_ids: Array[String] = []
	var placed_ids: Array[String] = []
	for character_id in featured_ids:
		if placements.has(character_id):
			placed_ids.append(character_id)
		else:
			pending_ids.append(character_id)
	var mode := "search"
	var character_id := ""
	if not pending_ids.is_empty():
		mode = "take"
		character_id = pending_ids[0]
	elif not placed_ids.is_empty():
		mode = "locate"
		character_id = placed_ids[0]
	return {
		"mode": mode,
		"character_id": character_id,
		"featured_ids": featured_ids,
		"pending_ids": pending_ids,
		"placed_ids": placed_ids,
	}


func _finish_new_sandbox_landing() -> void:
	if backpack == null:
		return
	var plan := _new_sandbox_landing_plan()
	var featured_ids: Array = plan.get("featured_ids", [])
	if backpack_collapsed:
		_expand_backpack()
	backpack.prepare_new_sandbox_landing(not featured_ids.is_empty())
	await get_tree().process_frame
	await get_tree().process_frame
	var focus_action := ""
	var target_character_id := str(plan.get("character_id", ""))
	if not target_character_id.is_empty():
		focus_action = backpack.focus_character_entry(target_character_id)
	if focus_action.is_empty():
		backpack.focus_search(false)
	var pending_ids: Array = plan.get("pending_ids", [])
	if not pending_ids.is_empty():
		_set_status("%s待摆 · 背包已置顶 · 可撤销" % _character_name_list_summary(pending_ids, 3))
	elif not featured_ids.is_empty():
		_set_status("重点人物已就位 · 已聚焦“定位” · 可撤销")
	else:
		_set_status("空白沙盘已建立 · 从人物背包拿卡 · 可撤销")


func _return_to_new_sandbox_dialog() -> void:
	var template_id := _pending_scenario_template_id
	var template_source := _pending_scenario_template_source
	var requested_title := _pending_new_sandbox_title
	_set_status("尚未新建，当前沙盘保持不变")
	call_deferred("_open_new_sandbox_dialog", template_id, requested_title, template_source)


func _cancel_new_sandbox_dialog() -> void:
	_clear_new_sandbox_map_preview()
	_pending_scenario_template_id = ""
	_pending_scenario_template_source = ""
	_pending_new_sandbox_title = ""
	_set_status("已取消新建，当前沙盘保持不变")


func _default_branch_sandbox_title() -> String:
	var suffix := " · 分支"
	var base := _sanitize_single_line(str(sandbox_metadata.get("title", "未命名沙盘")), MAX_SANDBOX_TITLE_LENGTH, "未命名沙盘")
	if base.ends_with(suffix):
		base = base.left(base.length() - suffix.length()).strip_edges()
	if base.is_empty():
		base = "未命名沙盘"
	return "%s%s" % [base.left(maxi(1, MAX_SANDBOX_TITLE_LENGTH - suffix.length())), suffix]


func _branch_protection_snapshot_name(source_title: String) -> String:
	var prefix := "另开前 · "
	var safe_source := _sanitize_single_line(source_title, MAX_SANDBOX_TITLE_LENGTH, "未命名沙盘")
	return "%s%s" % [prefix, safe_source.left(maxi(1, MAX_SNAPSHOT_NAME_LENGTH - prefix.length()))]


func _open_branch_current_sandbox_dialog(preferred_title := "") -> void:
	if branch_sandbox_dialog == null or branch_sandbox_title_input == null:
		return
	_pending_branch_sandbox_title = _sanitize_single_line(
		preferred_title,
		MAX_SANDBOX_TITLE_LENGTH,
		_default_branch_sandbox_title()
	)
	branch_sandbox_title_input.set_text(_pending_branch_sandbox_title)
	branch_sandbox_summary_label.text = "来源沙盘：%s\n当前内容：人物 %d 张 · 标记 %d 个 · 推演线 %d 条 · 玩法分组 %d 组 · 玩家纪事 %d 则 · 当前视角\n备注、开局来源、推演线和玩家纪事会沿用；已有快照和人物收藏保持原样。" % [
		str(sandbox_metadata.get("title", "未命名沙盘")),
		placements.size(),
		annotations.size(),
		player_strokes.size(),
		(scenario_state.get("factions", []) as Array).size(),
		chronicle_entries.size()
	]
	branch_sandbox_dialog.popup_centered(Vector2i(560, 330))
	branch_sandbox_title_input.grab_focus()
	branch_sandbox_title_input.select_all()


func _on_branch_sandbox_title_changed(value: String) -> void:
	_pending_branch_sandbox_title = value


func _request_branch_current_sandbox() -> void:
	var source_title := str(sandbox_metadata.get("title", "未命名沙盘"))
	_pending_branch_sandbox_title = _sanitize_single_line(
		branch_sandbox_title_input.text if branch_sandbox_title_input != null else _pending_branch_sandbox_title,
		MAX_SANDBOX_TITLE_LENGTH,
		_default_branch_sandbox_title()
	)
	if branch_sandbox_title_input != null:
		branch_sandbox_title_input.set_text(_pending_branch_sandbox_title)
	branch_sandbox_dialog.hide()
	branch_sandbox_confirmation_dialog.dialog_text = "来源沙盘：%s\n新沙盘：%s\n保留内容：%d 位人物 · %d 个标记 · %d 条推演线 · %d 组玩法分组 · %d 则玩家纪事 · %d 人行动标注 · 当前视角\n\n确认后会先创建命名快照“%s”。\n随后建立新的沙盘身份，地图和摆放保持原样。\n之后的修改属于新沙盘；人物收藏和已有快照都会保留。\n这次身份切换可以撤销。" % [
		source_title,
		_pending_branch_sandbox_title,
		placements.size(),
		annotations.size(),
		player_strokes.size(),
		(scenario_state.get("factions", []) as Array).size(),
		chronicle_entries.size(),
		character_actions.size(),
		_branch_protection_snapshot_name(source_title)
	]
	branch_sandbox_confirmation_dialog.popup_centered(Vector2i(580, 320))


func _confirm_branch_current_sandbox() -> void:
	var source_title := str(sandbox_metadata.get("title", "未命名沙盘"))
	var requested_title := _pending_branch_sandbox_title
	var result := _branch_current_sandbox(requested_title)
	_pending_branch_sandbox_title = ""
	if not bool(result.get("ok", false)):
		_show_message("暂时不能另开沙盘", str(result.get("message", "当前沙盘没有变化。")))
		return
	var snapshot: Dictionary = result.get("snapshot", {})
	_set_status("已从“%s”另开“%s” · 已保留快照“%s” · 可撤销" % [
		source_title,
		str(sandbox_metadata.get("title", "未命名沙盘")),
		str(snapshot.get("name", "另开前局面"))
	])


func _return_to_branch_current_sandbox() -> void:
	var requested_title := _pending_branch_sandbox_title
	_set_status("尚未另开，当前沙盘保持不变")
	call_deferred("_open_branch_current_sandbox_dialog", requested_title)


func _cancel_branch_current_sandbox() -> void:
	_pending_branch_sandbox_title = ""
	_set_status("已取消另开，当前沙盘保持不变")


func _make_button(text_value: String, danger := false, width := 92) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(width, 38)
	_apply_toolbar_button_style(button, danger)
	return button


func _apply_toolbar_button_style(button: BaseButton, danger: bool) -> void:
	UiThemeScript.apply_toolbar_button_style(button, danger)


func _load_reference_data() -> void:
	characters = _load_json_array(_runtime_character_data_path("characters.json"))
	_load_character_catalog()
	_load_character_display_attributes()
	_load_character_portraits()
	places = _load_json_array(PLACES_PATH)
	_load_map_source_registry()
	routes = _load_json_array(ROUTES_PATH)
	land_data = _load_json_dictionary(LAND_PATH)
	river_data = _load_json_dictionary(RIVERS_PATH)
	lake_data = _load_json_dictionary(LAKES_PATH)
	mountains = _load_json_array(MOUNTAINS_PATH)
	_load_geographic_context()
	_load_historical_context_layer()
	_load_character_profiles()


func _load_character_catalog() -> void:
	character_catalog_version = 0
	character_catalog_ids.clear()
	character_catalog_load_error = ""
	var decoded: Dictionary = CharacterCatalogPolicyScript.decode_manifest(
		_load_json_dictionary(_runtime_character_data_path("character_catalog.json")),
		characters
	)
	if not bool(decoded.get("ok", false)):
		character_catalog_load_error = str(decoded.get("message", "人物目录无法读取。"))
		push_error(character_catalog_load_error)
		return
	var decoded_version := int(decoded.get("catalog_version", 0))
	if decoded_version != runtime_current_character_catalog_version:
		character_catalog_load_error = "人物目录版本与运行时契约不一致。"
		push_error(character_catalog_load_error)
		return
	var identity_decoded: Dictionary = CharacterIdentityPolicyScript.decode_runtime_records(
		characters,
		decoded.get("character_ids", [])
	)
	if not bool(identity_decoded.get("ok", false)):
		character_catalog_load_error = str(identity_decoded.get("message", "人物身份数据无法读取。"))
		characters.clear()
		push_error(character_catalog_load_error)
		return
	characters.assign(identity_decoded.get("characters", []))
	character_catalog_version = decoded_version
	for character_id_value in decoded.get("character_ids", []):
		character_catalog_ids.append(str(character_id_value))


func _load_geographic_context() -> void:
	geographic_context_records.clear()
	geographic_context_load_error = ""
	var decoded: Dictionary = MapGeographicContextPolicyScript.decode_document(
		_load_json_dictionary(GEOGRAPHIC_CONTEXT_PATH),
		MAP_GEOMETRY_V4_BOUNDS
	)
	if not bool(decoded.get("ok", false)):
		geographic_context_load_error = str(decoded.get("message", "外围地理参照无法读取。"))
		push_error(geographic_context_load_error)
		return
	for record_value in decoded.get("records", []):
		if record_value is Dictionary:
			geographic_context_records.append((record_value as Dictionary).duplicate(true))


func _load_character_display_attributes() -> void:
	character_display_attributes_by_id.clear()
	character_display_attributes_load_error = ""
	var decoded := _decode_character_display_attributes(
		_load_json_dictionary(_runtime_character_data_path("character_display_attributes.json"))
	)
	if not bool(decoded.get("ok", false)):
		character_display_attributes_load_error = str(decoded.get("message", "人物初始属性无法读取。"))
		push_error(character_display_attributes_load_error)
		return
	character_display_attributes_by_id = (decoded.get("attributes_by_id", {}) as Dictionary).duplicate(true)


func _load_character_portraits() -> void:
	character_portraits_by_id.clear()
	character_portrait_registry_load_error = ""
	if CHARACTER_PRESENTATION_MODE == "nameplate":
		return
	# 人物名牌已是正式运行方案。旧头像登记只作为同版本历史资产兼容读取；
	# 后续人物目录可以在没有新增头像的情况下直接发布。
	if not FileAccess.file_exists(CHARACTER_PORTRAITS_PATH):
		return
	var document := _load_json_dictionary(CHARACTER_PORTRAITS_PATH)
	if int(document.get("catalog_version", 0)) != runtime_current_character_catalog_version:
		return
	var allowed_root_keys := {
		"schema_version": true,
		"catalog_version": true,
		"status": true,
		"fallback": true,
		"records": true
	}
	if document.size() != allowed_root_keys.size():
		character_portrait_registry_load_error = "人物头像登记表字段不完整或含未定义字段。"
		push_error(character_portrait_registry_load_error)
		return
	for key in document.keys():
		if not allowed_root_keys.has(str(key)):
			character_portrait_registry_load_error = "人物头像登记表包含未定义字段：%s。" % str(key)
			push_error(character_portrait_registry_load_error)
			return
	var registry_status := str(document.get("status", ""))
	if (
		int(document.get("schema_version", 0)) != 2
		or int(document.get("catalog_version", 0)) != runtime_current_character_catalog_version
		or registry_status not in ["partial_with_fallback", "complete"]
		or str(document.get("fallback", "")) != "surname_seal"
		or not (document.get("records", null) is Array)
	):
		character_portrait_registry_load_error = "人物头像登记表版本、试片状态或兜底策略无效。"
		push_error(character_portrait_registry_load_error)
		return
	var known_ids := {}
	for character in characters:
		if character is Dictionary:
			known_ids[str((character as Dictionary).get("id", ""))] = true
	var seen_ids := {}
	for index in range((document.get("records", []) as Array).size()):
		var record_value: Variant = (document.get("records", []) as Array)[index]
		if not (record_value is Dictionary):
			character_portrait_registry_load_error = "第 %d 条人物头像记录不是对象。" % (index + 1)
			break
		var record: Dictionary = record_value
		var allowed_record_keys := {
			"character_id": true,
			"path": true,
			"runtime_size": true,
			"display_size": true,
			"source_manifest": true
		}
		if record.size() != allowed_record_keys.size():
			character_portrait_registry_load_error = "第 %d 条人物头像记录字段不完整或含未定义字段。" % (index + 1)
			break
		for key in record.keys():
			if not allowed_record_keys.has(str(key)):
				character_portrait_registry_load_error = "人物头像记录包含未定义字段：%s。" % str(key)
				break
		if not character_portrait_registry_load_error.is_empty():
			break
		var character_id := str(record.get("character_id", "")).strip_edges()
		var path := str(record.get("path", "")).strip_edges()
		var runtime_size: Variant = record.get("runtime_size", null)
		if (
			not known_ids.has(character_id)
			or seen_ids.has(character_id)
			or not path.begins_with("res://assets/characters/portraits/v2/")
			or not ResourceLoader.exists(path, "Texture2D")
			or not (runtime_size is Array)
			or (runtime_size as Array).size() != 2
			or int((runtime_size as Array)[0]) != 128
			or int((runtime_size as Array)[1]) != 128
			or int(record.get("display_size", 0)) != 32
		):
			character_portrait_registry_load_error = "第 %d 条人物头像记录的身份、路径或尺寸契约无效。" % (index + 1)
			break
		var texture := load(path) as Texture2D
		if texture == null or texture.get_width() != 128 or texture.get_height() != 128:
			character_portrait_registry_load_error = "第 %d 条人物头像运行图无法按 128×128 读取。" % (index + 1)
			break
		seen_ids[character_id] = true
		character_portraits_by_id[character_id] = texture
	if (
		character_portrait_registry_load_error.is_empty()
		and registry_status == "complete"
		and seen_ids.size() != known_ids.size()
	):
		character_portrait_registry_load_error = "完整人物头像登记表必须覆盖人物目录中的全部人物。"
	if not character_portrait_registry_load_error.is_empty():
		character_portraits_by_id.clear()
		push_error(character_portrait_registry_load_error)


func _decode_character_display_attributes(document: Variant) -> Dictionary:
	if not (document is Dictionary):
		return {"ok": false, "message": "人物初始属性顶层必须是对象。"}
	var root_document: Dictionary = document
	var allowed_root_keys := {
		"schema_version": true,
		"scale": true,
		"dimensions": true,
		"provenance": true,
		"records": true
	}
	if root_document.size() != allowed_root_keys.size():
		return {"ok": false, "message": "人物初始属性顶层字段不完整或含未定义字段。"}
	for key in root_document.keys():
		if not allowed_root_keys.has(str(key)):
			return {"ok": false, "message": "人物初始属性包含未定义字段：%s。" % str(key)}
	if int(root_document.get("schema_version", -1)) != CHARACTER_DISPLAY_ATTRIBUTES_SCHEMA_VERSION:
		return {"ok": false, "message": "人物初始属性版本不受支持。"}
	var scale_value: Variant = root_document.get("scale", null)
	if not (scale_value is Dictionary) \
		or (scale_value as Dictionary).size() != 2 \
		or not _is_integer_number((scale_value as Dictionary).get("minimum", null)) \
		or not _is_integer_number((scale_value as Dictionary).get("maximum", null)) \
		or int((scale_value as Dictionary).get("minimum", -1)) != CHARACTER_ATTRIBUTE_MIN \
		or int((scale_value as Dictionary).get("maximum", -1)) != CHARACTER_ATTRIBUTE_MAX:
		return {"ok": false, "message": "人物初始属性量程必须与程序的 0—100 契约一致。"}
	var dimensions_value: Variant = root_document.get("dimensions", null)
	if not (dimensions_value is Array) or Array(dimensions_value) != CHARACTER_ATTRIBUTE_FIELDS:
		return {"ok": false, "message": "人物初始属性维度或顺序不是武力、智力、统率、魅力。"}
	var provenance_value: Variant = root_document.get("provenance", null)
	if not (provenance_value is Dictionary):
		return {"ok": false, "message": "人物初始属性缺少项目自编来源边界。"}
	var provenance: Dictionary = provenance_value
	if str(provenance.get("semantic_layer", "")) != "project_editorial" \
		or str(provenance.get("verification_status", "")) != "not_historical_fact" \
		or str(provenance.get("method", "")).strip_edges().is_empty():
		return {"ok": false, "message": "人物初始属性不得伪装成史实或外部商业数据。"}
	var records_value: Variant = root_document.get("records", null)
	if not (records_value is Array):
		return {"ok": false, "message": "人物初始属性缺少 records 列表。"}
	var known_ids: Dictionary = {}
	for character_value in characters:
		if character_value is Dictionary:
			known_ids[str((character_value as Dictionary).get("id", ""))] = true
	var attributes_by_id: Dictionary = {}
	for index in range((records_value as Array).size()):
		var record_value: Variant = (records_value as Array)[index]
		if not (record_value is Dictionary):
			return {"ok": false, "message": "第 %d 条人物初始属性不是对象。" % (index + 1)}
		var record: Dictionary = record_value
		var allowed_record_keys := {
			"character_id": true,
			"might": true,
			"intelligence": true,
			"leadership": true,
			"charisma": true
		}
		if record.size() != allowed_record_keys.size():
			return {"ok": false, "message": "第 %d 条人物初始属性字段不完整或含未定义字段。" % (index + 1)}
		for key in record.keys():
			if not allowed_record_keys.has(str(key)):
				return {"ok": false, "message": "人物初始属性包含未定义字段：%s。" % str(key)}
		var character_id := str(record.get("character_id", "")).strip_edges()
		if not known_ids.has(character_id) or attributes_by_id.has(character_id):
			return {"ok": false, "message": "人物初始属性引用未知或重复人物：%s。" % character_id}
		var decoded_record: Dictionary = {}
		for field in CHARACTER_ATTRIBUTE_FIELDS:
			var value: Variant = record.get(field, null)
			if not _is_integer_number(value):
				return {"ok": false, "message": "%s 的%s必须是整数。" % [_character_name(character_id), _character_attribute_label(field)]}
			var number := int(value)
			if number < CHARACTER_ATTRIBUTE_MIN or number > CHARACTER_ATTRIBUTE_MAX:
				return {"ok": false, "message": "%s 的%s必须在 %d—%d 之间。" % [_character_name(character_id), _character_attribute_label(field), CHARACTER_ATTRIBUTE_MIN, CHARACTER_ATTRIBUTE_MAX]}
			decoded_record[field] = number
		attributes_by_id[character_id] = decoded_record
	if attributes_by_id.size() != known_ids.size():
		return {"ok": false, "message": "人物初始属性必须为当前全部 %d 名人物各提供一条记录。" % known_ids.size()}
	return {"ok": true, "attributes_by_id": attributes_by_id}


func _character_attribute_label(field: String) -> String:
	match field:
		"might":
			return "武力"
		"intelligence":
			return "智力"
		"leadership":
			return "统率"
		"charisma":
			return "魅力"
		_:
			return field


func _load_map_source_registry() -> void:
	map_sources_by_id.clear()
	map_source_load_error = ""
	var decoded := _decode_map_source_registry(_load_json_dictionary(MAP_SOURCES_PATH))
	if not bool(decoded.get("ok", false)):
		map_source_load_error = str(decoded.get("message", "地图资料登记表无法读取。"))
		push_error(map_source_load_error)
		return
	map_sources_by_id = (decoded.get("sources_by_id", {}) as Dictionary).duplicate(true)


func _decode_map_source_registry(document: Variant) -> Dictionary:
	if not (document is Dictionary):
		return {"ok": false, "message": "地图资料登记表顶层必须是对象。"}
	var root_document: Dictionary = document
	if int(root_document.get("schema_version", -1)) != MAP_SOURCE_SCHEMA_VERSION:
		return {"ok": false, "message": "地图资料登记表版本不受支持。"}
	var source_values: Variant = root_document.get("sources", null)
	if not (source_values is Array):
		return {"ok": false, "message": "地图资料登记表缺少来源列表。"}
	var sources_by_id: Dictionary = {}
	for index in range((source_values as Array).size()):
		var source_value: Variant = (source_values as Array)[index]
		if not (source_value is Dictionary):
			return {"ok": false, "message": "地图资料登记表第 %d 条不是对象。" % (index + 1)}
		var source: Dictionary = source_value
		var source_id := str(source.get("id", "")).strip_edges()
		if source_id.is_empty() or sources_by_id.has(source_id):
			return {"ok": false, "message": "地图资料登记表含空白或重复来源 ID。"}
		sources_by_id[source_id] = source.duplicate(true)
	return {"ok": true, "sources_by_id": sources_by_id}


func _load_character_profiles() -> void:
	character_profiles_by_id.clear()
	character_profile_sources_by_id.clear()
	character_profile_load_error = ""
	var decoded := _decode_character_profiles(
		_load_json_dictionary(_runtime_character_data_path("character_profiles.json")),
		_load_json_dictionary(_runtime_character_data_path("character_sources.json"))
	)
	if not bool(decoded.get("ok", false)):
		character_profile_load_error = str(decoded.get("message", "人物小传无法读取。"))
		push_error(character_profile_load_error)
		return
	character_profiles_by_id = (decoded.get("profiles_by_id", {}) as Dictionary).duplicate(true)
	character_profile_sources_by_id = (decoded.get("sources_by_id", {}) as Dictionary).duplicate(true)


func _decode_character_profiles(document: Variant, source_registry_document: Variant) -> Dictionary:
	return CharacterProfilePolicyScript.decode_document(
		document,
		characters,
		source_registry_document
	)


func _load_historical_context_layer() -> void:
	historical_context_layer.clear()
	historical_context_layers.clear()
	historical_context_load_error = ""
	historical_context_sources_by_id.clear()
	var source_store := _load_json_dictionary(_runtime_character_data_path("character_sources.json"))
	var decoded := _decode_historical_context_store(
		_load_json_dictionary(HISTORICAL_CONTEXT_PATH),
		source_store
	)
	if not bool(decoded.get("ok", false)):
		historical_context_load_error = str(decoded.get("message", "历史背景参考层无法读取。"))
		push_error(historical_context_load_error)
		return
	historical_context_layers.assign(decoded.get("layers", []))
	for layer_value in historical_context_layers:
		if str(layer_value.get("id", "")) == "context_184":
			historical_context_layer = layer_value.duplicate(true)
			break
	historical_context_sources_by_id = (decoded.get("sources_by_id", {}) as Dictionary).duplicate(true)


func _decode_historical_context_store(document: Variant, source_registry_document: Variant) -> Dictionary:
	if not (document is Dictionary):
		return {"ok": false, "message": "历史背景参考层顶层必须是对象。"}
	if not (source_registry_document is Dictionary):
		return {"ok": false, "message": "历史背景参考层缺少可核验的来源登记表。"}
	if int((source_registry_document as Dictionary).get("schema_version", -1)) != 1:
		return {"ok": false, "message": "历史背景参考层来源登记表版本不受支持。"}
	var root_document: Dictionary = document
	var allowed_root_keys := {
		"schema_version": true, "map_id": true, "map_geometry_version": true,
		"runtime_policy": true, "layers": true
	}
	for root_key in root_document.keys():
		if not allowed_root_keys.has(str(root_key)):
			return {"ok": false, "message": "历史背景参考层顶层含未定义字段：%s。" % str(root_key)}
	if not _is_integer_number(root_document.get("schema_version", null)) or int(root_document.get("schema_version", -1)) != HISTORICAL_CONTEXT_SCHEMA_VERSION:
		return {"ok": false, "message": "历史背景参考层版本不受支持。"}
	if str(root_document.get("map_id", "")) != MAP_ID or not _is_integer_number(root_document.get("map_geometry_version", null)) or int(root_document.get("map_geometry_version", -1)) != MAP_GEOMETRY_VERSION:
		return {"ok": false, "message": "历史背景参考层与当前地图不兼容。"}
	if str(root_document.get("runtime_policy", "")) != "visual_reference_only_no_snap_no_route_no_save_no_events":
		return {"ok": false, "message": "历史背景参考层缺少只读运行时边界。"}
	var source_values: Variant = (source_registry_document as Dictionary).get("sources", null)
	if not (source_values is Array):
		return {"ok": false, "message": "历史背景参考层来源登记表无效。"}
	var sources_by_id := {}
	for source_value in source_values:
		if source_value is Dictionary:
			var source_id := str((source_value as Dictionary).get("id", "")).strip_edges()
			if not source_id.is_empty():
				sources_by_id[source_id] = source_value
	var place_ids := {}
	for place in places:
		if place is Dictionary:
			place_ids[str(place.get("id", ""))] = true
	var layer_values: Variant = root_document.get("layers", null)
	var expected_layer_years := {
		"context_184": 184,
		"context_190": 190,
		"context_196": 196,
		"context_200": 200,
		"context_208": 208
	}
	if not (layer_values is Array) or (layer_values as Array).size() != expected_layer_years.size():
		return {"ok": false, "message": "历史背景层必须完整覆盖当前五个内置历史开局。"}
	var allowed_layer_keys := {"id": true, "name": true, "year": true, "default_visible": true, "runtime_semantics": true, "records": true}
	var allowed_record_keys := {
		"id": true, "candidate_ref": true, "label": true, "title": true,
		"anchor_place_id": true, "anchor_semantics": true, "display_tier": true,
		"label_offset": true, "layer": true, "date": true, "summary": true,
		"spatial_note": true, "evidence": true, "confidence": true
	}
	var allowed_date_keys := {"year": true, "month_from": true, "month_to": true, "precision": true}
	var allowed_evidence_keys := {"source_registry": true, "source_ref": true, "source_locator": true, "claim_scope": true}
	var seen_layer_ids := {}
	var seen_record_ids := {}
	var referenced_sources_by_id := {}
	var decoded_layers: Array[Dictionary] = []
	for layer_index in range((layer_values as Array).size()):
		var layer_value: Variant = (layer_values as Array)[layer_index]
		if not (layer_value is Dictionary):
			return {"ok": false, "message": "第 %d 个历史背景层不是对象。" % (layer_index + 1)}
		var layer: Dictionary = layer_value
		for layer_key in layer.keys():
			if not allowed_layer_keys.has(str(layer_key)):
				return {"ok": false, "message": "历史背景层含未定义字段：%s。" % str(layer_key)}
		var layer_id := str(layer.get("id", "")).strip_edges()
		if not expected_layer_years.has(layer_id) or seen_layer_ids.has(layer_id):
			return {"ok": false, "message": "历史背景层身份无效或重复。"}
		seen_layer_ids[layer_id] = true
		var layer_year := int(expected_layer_years[layer_id])
		if str(layer.get("name", "")).strip_edges().is_empty() or not _is_integer_number(layer.get("year", null)) or int(layer.get("year", 0)) != layer_year:
			return {"ok": false, "message": "%s 的名称或年份无效。" % layer_id}
		if typeof(layer.get("default_visible", null)) != TYPE_BOOL or bool(layer.get("default_visible", true)):
			return {"ok": false, "message": "%s 必须默认关闭。" % layer_id}
		if str(layer.get("runtime_semantics", "")) != "historical_reference":
			return {"ok": false, "message": "%s 的运行语义无效。" % layer_id}
		var record_values: Variant = layer.get("records", null)
		var expected_record_count := 2 if layer_id in ["context_190", "context_208"] else (1 if layer_id in ["context_196", "context_200"] else -1)
		if not (record_values is Array) or (expected_record_count > 0 and (record_values as Array).size() != expected_record_count) or (layer_id == "context_184" and ((record_values as Array).size() < 5 or (record_values as Array).size() > 7)):
			return {"ok": false, "message": "%s 的记录数量无效。" % layer_id}
		var decoded_records: Array[Dictionary] = []
		for record_index in range((record_values as Array).size()):
			var record_value: Variant = (record_values as Array)[record_index]
			if not (record_value is Dictionary):
				return {"ok": false, "message": "%s 第 %d 条记录不是对象。" % [layer_id, record_index + 1]}
			var record: Dictionary = record_value
			for record_key in record.keys():
				if not allowed_record_keys.has(str(record_key)):
					return {"ok": false, "message": "%s 记录含未定义字段：%s。" % [layer_id, str(record_key)]}
			var record_id := str(record.get("id", "")).strip_edges()
			if not _is_safe_record_id(record_id) or not record_id.begins_with(layer_id + "_") or seen_record_ids.has(record_id):
				return {"ok": false, "message": "%s 的记录 ID 无效或重复。" % layer_id}
			seen_record_ids[record_id] = true
			var candidate_ref := str(record.get("candidate_ref", "")).strip_edges()
			if layer_id != "context_184" and (candidate_ref.is_empty() or not candidate_ref.begins_with("candidate_%s_" % layer_id)):
				return {"ok": false, "message": "%s 缺少人工提升来源。" % record_id}
			if layer_id == "context_184" and not candidate_ref.is_empty():
				return {"ok": false, "message": "%s 不应伪造候选提升记录。" % record_id}
			var label := str(record.get("label", "")).strip_edges()
			var detail_title := str(record.get("title", "")).strip_edges()
			if label.is_empty() or label.length() > 16 or detail_title.is_empty() or detail_title.length() > 20:
				return {"ok": false, "message": "%s 的标签或标题无效。" % record_id}
			var anchor_place_id := str(record.get("anchor_place_id", "")).strip_edges()
			if not place_ids.has(anchor_place_id) or str(record.get("anchor_semantics", "")).strip_edges().is_empty():
				return {"ok": false, "message": "%s 的地点锚点无效。" % record_id}
			if not _is_integer_number(record.get("display_tier", null)) or int(record.get("display_tier", 0)) not in [1, 2]:
				return {"ok": false, "message": "%s 的显示层级无效。" % record_id}
			var label_offset: Variant = record.get("label_offset", null)
			if not (label_offset is Array) or (label_offset as Array).size() != 2:
				return {"ok": false, "message": "%s 的标签偏移无效。" % record_id}
			for component in label_offset:
				if not (typeof(component) in [TYPE_INT, TYPE_FLOAT]) or not is_finite(float(component)) or absf(float(component)) > 160.0:
					return {"ok": false, "message": "%s 的标签偏移越界。" % record_id}
			var evidence_layer := str(record.get("layer", ""))
			if evidence_layer not in ["historical", "romance"] or (layer_id != "context_184" and evidence_layer != "historical"):
				return {"ok": false, "message": "%s 的史实／演义层级无效。" % record_id}
			var date_value: Variant = record.get("date", null)
			if not (date_value is Dictionary):
				return {"ok": false, "message": "%s 缺少日期边界。" % record_id}
			var date_record: Dictionary = date_value
			for date_key in date_record.keys():
				if not allowed_date_keys.has(str(date_key)):
					return {"ok": false, "message": "%s 的日期含未定义字段。" % record_id}
			if not _is_integer_number(date_record.get("year", null)) or int(date_record.get("year", 0)) != layer_year or str(date_record.get("precision", "")) not in ["month", "year", "range"]:
				return {"ok": false, "message": "%s 的日期无效。" % record_id}
			for month_key in ["month_from", "month_to"]:
				if date_record.has(month_key) and (not _is_integer_number(date_record.get(month_key, null)) or int(date_record.get(month_key, 0)) < 1 or int(date_record.get(month_key, 0)) > 12):
					return {"ok": false, "message": "%s 的月份无效。" % record_id}
			if str(record.get("summary", "")).strip_edges().is_empty() or str(record.get("spatial_note", "")).strip_edges().is_empty():
				return {"ok": false, "message": "%s 缺少事实摘要或空间边界。" % record_id}
			if str(record.get("confidence", "")) not in ["text_explicit", "regional_anchor", "narrative_explicit"]:
				return {"ok": false, "message": "%s 的置信度无效。" % record_id}
			var evidence_values: Variant = record.get("evidence", null)
			if not (evidence_values is Array) or (evidence_values as Array).is_empty():
				return {"ok": false, "message": "%s 缺少证据。" % record_id}
			var seen_evidence := {}
			for evidence_value in evidence_values:
				if not (evidence_value is Dictionary):
					return {"ok": false, "message": "%s 的证据不是对象。" % record_id}
				var evidence: Dictionary = evidence_value
				for evidence_key in evidence.keys():
					if not allowed_evidence_keys.has(str(evidence_key)):
						return {"ok": false, "message": "%s 的证据含未定义字段。" % record_id}
				var source_ref := str(evidence.get("source_ref", "")).strip_edges()
				if str(evidence.get("source_registry", "")) != "character_sources" or source_ref.is_empty() or seen_evidence.has(source_ref) or not sources_by_id.has(source_ref):
					return {"ok": false, "message": "%s 引用了未知或重复来源。" % record_id}
				seen_evidence[source_ref] = true
				var source: Dictionary = sources_by_id[source_ref]
				if str(source.get("layer", "")) != evidence_layer or str(source.get("usage_status", "")) != "reference_only" or "historical_context_reference" not in source.get("roles", []):
					return {"ok": false, "message": "%s 的来源层级或用途不匹配。" % record_id}
				if str(evidence.get("source_locator", "")).strip_edges().is_empty() or str(evidence.get("claim_scope", "")).strip_edges().is_empty():
					return {"ok": false, "message": "%s 的证据缺少原文定位。" % record_id}
				referenced_sources_by_id[source_ref] = source.duplicate(true)
			decoded_records.append(record.duplicate(true))
		var decoded_layer := layer.duplicate(true)
		decoded_layer["records"] = decoded_records
		decoded_layers.append(decoded_layer)
	if seen_layer_ids.size() != expected_layer_years.size():
		return {"ok": false, "message": "历史背景层集合不完整。"}
	return {"ok": true, "layers": decoded_layers, "sources_by_id": referenced_sources_by_id}


func _decode_historical_context_store_legacy(document: Variant, source_registry_document: Variant) -> Dictionary:
	if not (document is Dictionary):
		return {"ok": false, "message": "历史背景参考层顶层必须是对象。"}
	if not (source_registry_document is Dictionary):
		return {"ok": false, "message": "历史背景参考层缺少可核验的来源登记表。"}
	if int((source_registry_document as Dictionary).get("schema_version", -1)) != 1:
		return {"ok": false, "message": "历史背景参考层来源登记表版本不受支持。"}
	var root_document: Dictionary = document
	var allowed_root_keys := {
		"schema_version": true, "map_id": true, "map_geometry_version": true,
		"runtime_policy": true, "layers": true
	}
	for root_key in root_document.keys():
		if not allowed_root_keys.has(str(root_key)):
			return {"ok": false, "message": "历史背景参考层顶层含未定义字段：%s。" % str(root_key)}
	if not _is_integer_number(root_document.get("schema_version", null)) or int(root_document.get("schema_version", -1)) != HISTORICAL_CONTEXT_SCHEMA_VERSION:
		return {"ok": false, "message": "历史背景参考层版本不受支持。"}
	if str(root_document.get("map_id", "")) != MAP_ID or not _is_integer_number(root_document.get("map_geometry_version", null)) or int(root_document.get("map_geometry_version", -1)) != MAP_GEOMETRY_VERSION:
		return {"ok": false, "message": "历史背景参考层与当前地图不兼容。"}
	if str(root_document.get("runtime_policy", "")) != "visual_reference_only_no_snap_no_route_no_save_no_events":
		return {"ok": false, "message": "历史背景参考层缺少只读运行时边界。"}
	var source_values: Variant = (source_registry_document as Dictionary).get("sources", null)
	if not (source_values is Array):
		return {"ok": false, "message": "历史背景参考层来源登记表无效。"}
	var sources_by_id := {}
	for source_value in source_values:
		if not (source_value is Dictionary):
			continue
		var source: Dictionary = source_value
		var source_id := str(source.get("id", "")).strip_edges()
		if not source_id.is_empty():
			sources_by_id[source_id] = source
	var place_ids := {}
	for place in places:
		if place is Dictionary:
			place_ids[str(place.get("id", ""))] = true
	var layer_values: Variant = root_document.get("layers", null)
	if not (layer_values is Array) or (layer_values as Array).size() != 1:
		return {"ok": false, "message": "A20 只接受一个 184 年背景参考层。"}
	var layer_value: Variant = (layer_values as Array)[0]
	if not (layer_value is Dictionary):
		return {"ok": false, "message": "184 年背景参考层不是对象。"}
	var layer: Dictionary = layer_value
	var allowed_layer_keys := {"id": true, "name": true, "year": true, "default_visible": true, "runtime_semantics": true, "records": true}
	for layer_key in layer.keys():
		if not allowed_layer_keys.has(str(layer_key)):
			return {"ok": false, "message": "184 年背景参考层含未定义字段：%s。" % str(layer_key)}
	if str(layer.get("id", "")) != "context_184" or str(layer.get("name", "")).strip_edges().is_empty():
		return {"ok": false, "message": "184 年背景参考层身份无效。"}
	if not _is_integer_number(layer.get("year", null)) or int(layer.get("year", 0)) != 184:
		return {"ok": false, "message": "184 年背景参考层年份无效。"}
	if typeof(layer.get("default_visible", null)) != TYPE_BOOL or bool(layer.get("default_visible", true)):
		return {"ok": false, "message": "184 年背景参考层必须默认关闭。"}
	if str(layer.get("runtime_semantics", "")) != "historical_reference":
		return {"ok": false, "message": "184 年背景参考层运行语义无效。"}
	var record_values: Variant = layer.get("records", null)
	if not (record_values is Array) or (record_values as Array).size() < 5 or (record_values as Array).size() > 7:
		return {"ok": false, "message": "184 年背景参考层应包含 5 至 7 条首批线索。"}
	var allowed_record_keys := {
		"id": true, "label": true, "title": true, "anchor_place_id": true, "anchor_semantics": true,
		"display_tier": true, "label_offset": true, "layer": true, "date": true,
		"summary": true, "spatial_note": true, "evidence": true, "confidence": true
	}
	var allowed_date_keys := {"year": true, "month_from": true, "month_to": true, "precision": true}
	var allowed_evidence_keys := {"source_registry": true, "source_ref": true, "source_locator": true, "claim_scope": true}
	var seen_ids := {}
	var referenced_sources_by_id := {}
	var decoded_records: Array[Dictionary] = []
	for index in range((record_values as Array).size()):
		var record_value: Variant = (record_values as Array)[index]
		if not (record_value is Dictionary):
			return {"ok": false, "message": "184 年背景第 %d 条线索不是对象。" % (index + 1)}
		var record: Dictionary = record_value
		for record_key in record.keys():
			if not allowed_record_keys.has(str(record_key)):
				return {"ok": false, "message": "184 年背景线索含未定义字段：%s。" % str(record_key)}
		var record_id := str(record.get("id", "")).strip_edges()
		if not _is_safe_record_id(record_id) or seen_ids.has(record_id):
			return {"ok": false, "message": "184 年背景线索 ID 无效或重复。"}
		seen_ids[record_id] = true
		var label := str(record.get("label", "")).strip_edges()
		if label.is_empty() or label.length() > 16:
			return {"ok": false, "message": "184 年背景线索 %s 的短标签无效。" % record_id}
		var detail_title := str(record.get("title", "")).strip_edges()
		if detail_title.is_empty() or detail_title.length() > 20:
			return {"ok": false, "message": "184 年背景线索 %s 的资料卡标题无效。" % record_id}
		var anchor_place_id := str(record.get("anchor_place_id", "")).strip_edges()
		if not place_ids.has(anchor_place_id):
			return {"ok": false, "message": "184 年背景线索 %s 引用了未知地点。" % record_id}
		if str(record.get("anchor_semantics", "")).strip_edges().is_empty():
			return {"ok": false, "message": "184 年背景线索 %s 缺少空间语义。" % record_id}
		if not _is_integer_number(record.get("display_tier", null)) or int(record.get("display_tier", 0)) not in [1, 2]:
			return {"ok": false, "message": "184 年背景线索 %s 的显示层级无效。" % record_id}
		var label_offset: Variant = record.get("label_offset", null)
		if not (label_offset is Array) or (label_offset as Array).size() != 2:
			return {"ok": false, "message": "184 年背景线索 %s 的标签偏移无效。" % record_id}
		for component in label_offset:
			if not (typeof(component) in [TYPE_INT, TYPE_FLOAT]) or not is_finite(float(component)) or absf(float(component)) > 160.0:
				return {"ok": false, "message": "184 年背景线索 %s 的标签偏移越界。" % record_id}
		var evidence_layer := str(record.get("layer", ""))
		if evidence_layer not in ["historical", "romance"]:
			return {"ok": false, "message": "184 年背景线索 %s 的史实／演义层级无效。" % record_id}
		var date_value: Variant = record.get("date", null)
		if not (date_value is Dictionary):
			return {"ok": false, "message": "184 年背景线索 %s 缺少日期边界。" % record_id}
		var date_record: Dictionary = date_value
		for date_key in date_record.keys():
			if not allowed_date_keys.has(str(date_key)):
				return {"ok": false, "message": "184 年背景线索 %s 的日期含未定义字段。" % record_id}
		if not _is_integer_number(date_record.get("year", null)) or int(date_record.get("year", 0)) != 184 or str(date_record.get("precision", "")) not in ["month", "year", "range"]:
			return {"ok": false, "message": "184 年背景线索 %s 的日期无效。" % record_id}
		for month_key in ["month_from", "month_to"]:
			if date_record.has(month_key) and (not _is_integer_number(date_record.get(month_key, null)) or int(date_record.get(month_key, 0)) < 1 or int(date_record.get(month_key, 0)) > 12):
				return {"ok": false, "message": "184 年背景线索 %s 的月份无效。" % record_id}
		if str(record.get("summary", "")).strip_edges().is_empty() or str(record.get("spatial_note", "")).strip_edges().is_empty():
			return {"ok": false, "message": "184 年背景线索 %s 缺少事实摘要或空间边界。" % record_id}
		if str(record.get("confidence", "")) not in ["text_explicit", "regional_anchor", "narrative_explicit"]:
			return {"ok": false, "message": "184 年背景线索 %s 的置信度无效。" % record_id}
		var evidence_values: Variant = record.get("evidence", null)
		if not (evidence_values is Array) or (evidence_values as Array).is_empty():
			return {"ok": false, "message": "184 年背景线索 %s 缺少证据。" % record_id}
		var seen_evidence := {}
		for evidence_value in evidence_values:
			if not (evidence_value is Dictionary):
				return {"ok": false, "message": "184 年背景线索 %s 的证据不是对象。" % record_id}
			var evidence: Dictionary = evidence_value
			for evidence_key in evidence.keys():
				if not allowed_evidence_keys.has(str(evidence_key)):
					return {"ok": false, "message": "184 年背景线索 %s 的证据含未定义字段。" % record_id}
			var source_ref := str(evidence.get("source_ref", "")).strip_edges()
			if str(evidence.get("source_registry", "")) != "character_sources" or source_ref.is_empty() or seen_evidence.has(source_ref) or not sources_by_id.has(source_ref):
				return {"ok": false, "message": "184 年背景线索 %s 引用了未知或重复来源。" % record_id}
			seen_evidence[source_ref] = true
			var source: Dictionary = sources_by_id[source_ref]
			if str(source.get("layer", "")) != evidence_layer or str(source.get("usage_status", "")) != "reference_only" or "historical_context_reference" not in source.get("roles", []):
				return {"ok": false, "message": "184 年背景线索 %s 的来源层级或用途不匹配。" % record_id}
			if str(evidence.get("source_locator", "")).strip_edges().is_empty() or str(evidence.get("claim_scope", "")).strip_edges().is_empty():
				return {"ok": false, "message": "184 年背景线索 %s 的证据缺少原文定位。" % record_id}
			referenced_sources_by_id[source_ref] = source.duplicate(true)
		decoded_records.append(record.duplicate(true))
	var decoded_layer := layer.duplicate(true)
	decoded_layer["records"] = decoded_records
	return {"ok": true, "layer": decoded_layer, "sources_by_id": referenced_sources_by_id}


func _load_scenario_templates() -> void:
	scenario_templates.clear()
	scenario_template_load_error = ""
	if not FileAccess.file_exists(runtime_scenario_templates_path):
		scenario_template_load_error = "缺少起步模板文件。"
		push_error("%s：%s" % [scenario_template_load_error, runtime_scenario_templates_path])
		return
	var file := FileAccess.open(runtime_scenario_templates_path, FileAccess.READ)
	if file == null:
		scenario_template_load_error = "无法读取起步模板文件。"
		push_error(scenario_template_load_error)
		return
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	if parse_error != OK:
		scenario_template_load_error = "起步模板 JSON 第 %d 行有误：%s" % [parser.get_error_line(), parser.get_error_message()]
		push_error(scenario_template_load_error)
		return
	var result := _decode_scenario_template_store(parser.data)
	if not bool(result.get("ok", false)):
		scenario_template_load_error = str(result.get("message", "起步模板未通过校验。"))
		push_error(scenario_template_load_error)
		return
	for template_value in result.get("templates", []):
		if template_value is Dictionary:
			scenario_templates.append((template_value as Dictionary).duplicate(true))


func _decode_scenario_template_store(document: Variant) -> Dictionary:
	if not (document is Dictionary):
		return {"ok": false, "message": "起步模板顶层必须是对象。"}
	var root: Dictionary = document
	var allowed_root_keys := {"schema_version": true, "templates": true}
	for root_key in root.keys():
		if not allowed_root_keys.has(str(root_key)):
			return {"ok": false, "message": "起步模板顶层含未定义字段：%s。" % str(root_key)}
	var schema_value: Variant = root.get("schema_version", null)
	if not _is_integer_number(schema_value):
		return {"ok": false, "message": "起步模板版本不受支持。"}
	var schema_version := int(schema_value)
	if schema_version < SCENARIO_TEMPLATE_MIN_SCHEMA_VERSION or schema_version > SCENARIO_TEMPLATE_SCHEMA_VERSION:
		return {"ok": false, "message": "起步模板版本不受支持。"}
	var templates_value: Variant = root.get("templates", null)
	if not (templates_value is Array):
		return {"ok": false, "message": "起步模板列表无效。"}
	var source_templates: Array = templates_value
	if source_templates.size() > SCENARIO_TEMPLATE_LIMIT:
		return {"ok": false, "message": "起步模板数量超过安全上限。"}
	var decoded_templates: Array[Dictionary] = []
	var seen_ids: Dictionary = {}
	var allowed_record_keys := {
		"id": true, "name": true, "year": true, "title": true,
		"map_id": true, "map_geometry_version": true,
		"description": true, "scenario_source": true, "basis_note": true,
		"placements": true, "annotations": true
	}
	if schema_version >= 2:
		allowed_record_keys["factions"] = true
		allowed_record_keys["character_assignments"] = true
	if schema_version >= 4:
		for contract_key in [
			"scenario_id", "scenario_kind", "era_label",
			"featured_character_ids", "history_layer_ids", "city_ownership"
		]:
			allowed_record_keys[contract_key] = true
		# “拿取引导”只服务于当前内置模板的会话 UI，不写入沙盘存档。
		allowed_record_keys["take_guidance"] = true
	var allowed_placement_keys := {"character_id": true, "place_id": true}
	for index in range(source_templates.size()):
		var record_value: Variant = source_templates[index]
		if not (record_value is Dictionary):
			return {"ok": false, "message": "第 %d 个起步模板不是对象。" % (index + 1)}
		var record: Dictionary = record_value
		for record_key in record.keys():
			if not allowed_record_keys.has(str(record_key)):
				return {"ok": false, "message": "起步模板 schema v%d 不接受字段：%s。" % [schema_version, str(record_key)]}
		var template_id := str(record.get("id", "")).strip_edges()
		if not _is_safe_record_id(template_id) or seen_ids.has(template_id):
			return {"ok": false, "message": "第 %d 个起步模板 ID 无效或重复。" % (index + 1)}
		seen_ids[template_id] = true
		var raw_name := str(record.get("name", "")).strip_edges()
		var raw_title := str(record.get("title", "")).strip_edges()
		if raw_name.is_empty() or raw_title.is_empty():
			return {"ok": false, "message": "起步模板 %s 缺少名称或沙盘标题。" % template_id}
		if str(record.get("map_id", "")) != MAP_ID:
			return {"ok": false, "message": "起步模板 %s 不属于当前地图。" % template_id}
		var geometry_value: Variant = record.get("map_geometry_version", null)
		if not _is_integer_number(geometry_value) or int(geometry_value) != MAP_GEOMETRY_VERSION:
			return {"ok": false, "message": "起步模板 %s 的地图几何版本不兼容。" % template_id}
		var year_value: Variant = record.get("year", null)
		if year_value != null and (not _is_integer_number(year_value) or int(year_value) < 100 or int(year_value) > 999):
			return {"ok": false, "message": "起步模板 %s 的年份无效。" % template_id}
		var placement_values: Variant = record.get("placements", null)
		var annotation_values: Variant = record.get("annotations", null)
		if not (placement_values is Array) or not (annotation_values is Array):
			return {"ok": false, "message": "起步模板 %s 的摆放数据无效。" % template_id}
		if not (annotation_values as Array).is_empty():
			return {"ok": false, "message": "起步模板暂不接受预设标记，以免夹带固定剧情。"}
		var decoded_placements: Array[Dictionary] = []
		var seen_characters: Dictionary = {}
		for placement_index in range((placement_values as Array).size()):
			var placement_value: Variant = (placement_values as Array)[placement_index]
			if not (placement_value is Dictionary):
				return {"ok": false, "message": "起步模板 %s 的第 %d 个摆放不是对象。" % [template_id, placement_index + 1]}
			var raw_placement: Dictionary = placement_value
			for placement_key in raw_placement.keys():
				if not allowed_placement_keys.has(str(placement_key)):
					return {"ok": false, "message": "起步模板 %s 的人物摆放含未定义字段：%s。" % [template_id, str(placement_key)]}
			var character_id := str(raw_placement.get("character_id", "")).strip_edges()
			var place_id := str(raw_placement.get("place_id", "")).strip_edges()
			if not _has_character_id(character_id) or seen_characters.has(character_id):
				return {"ok": false, "message": "起步模板 %s 含未知或重复人物：%s。" % [template_id, character_id]}
			if _find_place(place_id).is_empty():
				return {"ok": false, "message": "起步模板 %s 含未知地点：%s。" % [template_id, place_id]}
			seen_characters[character_id] = true
			decoded_placements.append({"character_id": character_id, "place_id": place_id})
		var decoded_factions: Array[Dictionary] = []
		var decoded_assignments: Array[Dictionary] = []
		if schema_version >= 2:
			var faction_values: Variant = record.get("factions", null)
			var assignment_values: Variant = record.get("character_assignments", null)
			if not (faction_values is Array) or not (assignment_values is Array):
				return {"ok": false, "message": "起步模板 %s 缺少完整的玩法势力数据。" % template_id}
			if (faction_values as Array).size() > SCENARIO_FACTION_LIMIT:
				return {"ok": false, "message": "起步模板 %s 的玩法势力超过安全上限。" % template_id}
			var seen_factions: Dictionary = {}
			var seen_faction_names: Dictionary = {}
			var faction_member_counts: Dictionary = {}
			for faction_index in range((faction_values as Array).size()):
				var faction_value: Variant = (faction_values as Array)[faction_index]
				if not (faction_value is Dictionary):
					return {"ok": false, "message": "起步模板 %s 的第 %d 个玩法势力不是对象。" % [template_id, faction_index + 1]}
				var raw_faction: Dictionary = faction_value
				for faction_key in raw_faction.keys():
					var allowed_faction_keys := ["id", "name", "color"] if schema_version >= 3 else ["id", "name"]
					if str(faction_key) not in allowed_faction_keys:
						return {"ok": false, "message": "起步模板 %s 的玩法势力含未定义字段：%s。" % [template_id, str(faction_key)]}
				var faction_id := str(raw_faction.get("id", "")).strip_edges()
				var faction_name := _sanitize_single_line(str(raw_faction.get("name", "")), 24, "")
				var faction_color := FactionPaletteScript.normalize_hex(raw_faction.get("color", "")) if schema_version >= 3 else FactionPaletteScript.default_hex(faction_index)
				if not faction_id.begins_with("play_") or not _is_safe_record_id(faction_id) or seen_factions.has(faction_id):
					return {"ok": false, "message": "起步模板 %s 的玩法势力 ID 无效或重复。" % template_id}
				if faction_name.is_empty() or seen_faction_names.has(faction_name):
					return {"ok": false, "message": "起步模板 %s 的玩法势力名称为空或重复。" % template_id}
				if faction_color.is_empty() or (schema_version >= 3 and not FactionPaletteScript.is_canonical_hex(raw_faction.get("color", ""))):
					return {"ok": false, "message": "起步模板 %s 的玩法势力颜色必须是 #RRGGBB。" % template_id}
				seen_factions[faction_id] = true
				seen_faction_names[faction_name] = true
				faction_member_counts[faction_id] = 0
				decoded_factions.append({"id": faction_id, "name": faction_name, "color": faction_color})
			var seen_assignments: Dictionary = {}
			for assignment_index in range((assignment_values as Array).size()):
				var assignment_value: Variant = (assignment_values as Array)[assignment_index]
				if not (assignment_value is Dictionary):
					return {"ok": false, "message": "起步模板 %s 的第 %d 个人物分组不是对象。" % [template_id, assignment_index + 1]}
				var raw_assignment: Dictionary = assignment_value
				for assignment_key in raw_assignment.keys():
					if str(assignment_key) not in ["character_id", "faction_id"]:
						return {"ok": false, "message": "起步模板 %s 的人物分组含未定义字段：%s。" % [template_id, str(assignment_key)]}
				var character_id := str(raw_assignment.get("character_id", "")).strip_edges()
				var faction_id := str(raw_assignment.get("faction_id", "")).strip_edges()
				if not _has_character_id(character_id) or not seen_characters.has(character_id) or seen_assignments.has(character_id):
					return {"ok": false, "message": "起步模板 %s 的人物分组引用未知、未摆放或重复人物。" % template_id}
				if not seen_factions.has(faction_id):
					return {"ok": false, "message": "起步模板 %s 的人物分组引用未知玩法势力。" % template_id}
				seen_assignments[character_id] = true
				faction_member_counts[faction_id] = int(faction_member_counts[faction_id]) + 1
				decoded_assignments.append({"character_id": character_id, "faction_id": faction_id})
			if seen_assignments.size() != seen_characters.size():
				return {"ok": false, "message": "起步模板 %s 必须显式分组每一位预摆人物。" % template_id}
			for faction_id in faction_member_counts:
				if int(faction_member_counts[faction_id]) <= 0:
					return {"ok": false, "message": "起步模板 %s 含没有人物的玩法势力。" % template_id}
		var scenario_result := _decode_scenario_state(
			{
				"scenario_id": record.get("scenario_id", template_id),
				"start_year": year_value,
				"era_label": record.get("era_label", raw_name),
				"scenario_kind": record.get("scenario_kind", SCENARIO_KIND_CUSTOM if year_value == null else SCENARIO_KIND_HISTORICAL_START),
				"featured_character_ids": record.get("featured_character_ids", []),
				"history_layer_ids": record.get("history_layer_ids", []),
				"factions": decoded_factions,
				"character_assignments": decoded_assignments,
				"city_ownership": record.get("city_ownership", [])
			},
			false,
			true
		)
		if not bool(scenario_result.get("ok", false)):
			return {"ok": false, "message": "起步模板 %s 的稳定剧本契约无效：%s" % [template_id, str(scenario_result.get("message", ""))]}
		var decoded_scenario: Dictionary = scenario_result.get("scenario_state", {})
		var take_guidance_result := _decode_scenario_take_guidance(
			record.get("take_guidance", null),
			template_id
		)
		if not bool(take_guidance_result.get("ok", false)):
			return {"ok": false, "message": str(take_guidance_result.get("message", "起步模板拿取引导无效。"))}
		decoded_templates.append({
			"id": template_id,
			"scenario_id": str(decoded_scenario.get("scenario_id", "")),
			"scenario_kind": str(decoded_scenario.get("scenario_kind", "")),
			"era_label": str(decoded_scenario.get("era_label", "")),
			"featured_character_ids": (decoded_scenario.get("featured_character_ids", []) as Array).duplicate(),
			"history_layer_ids": (decoded_scenario.get("history_layer_ids", []) as Array).duplicate(),
			"name": _sanitize_single_line(raw_name, 36, "未命名模板"),
			"year": year_value,
			"title": _sanitize_single_line(raw_title, MAX_SANDBOX_TITLE_LENGTH, "未命名沙盘"),
			"map_id": MAP_ID,
			"map_geometry_version": MAP_GEOMETRY_VERSION,
			"description": _sanitize_multiline(str(record.get("description", "")), 240),
			"scenario_source": _sanitize_single_line(str(record.get("scenario_source", "")), MAX_SANDBOX_SOURCE_LENGTH, ""),
			"basis_note": _sanitize_multiline(str(record.get("basis_note", "")), 200),
			"factions": (decoded_scenario.get("factions", []) as Array).duplicate(true),
			"character_assignments": (decoded_scenario.get("character_assignments", []) as Array).duplicate(true),
			"city_ownership": (decoded_scenario.get("city_ownership", []) as Array).duplicate(true),
			"take_guidance": (take_guidance_result.get("guidance", {}) as Dictionary).duplicate(true),
			"placements": decoded_placements,
			"annotations": []
		})
	return {"ok": true, "templates": decoded_templates}


func _decode_scenario_take_guidance(value: Variant, template_id: String) -> Dictionary:
	if value == null:
		return {"ok": true, "guidance": {}}
	if not (value is Dictionary):
		return {"ok": false, "message": "起步模板 %s 的拿取引导必须是对象。" % template_id}
	var raw: Dictionary = value
	var allowed_keys := {
		"label": true,
		"hint": true,
		"take_character_ids": true,
		"conditional_character_ids": true,
	}
	for key in raw.keys():
		if not allowed_keys.has(str(key)):
			return {"ok": false, "message": "起步模板 %s 的拿取引导含未定义字段：%s。" % [template_id, str(key)]}
	var label_raw := str(raw.get("label", "本局补位"))
	var label := _sanitize_single_line(label_raw, 24, "")
	var hint_raw := str(raw.get("hint", ""))
	var hint := _sanitize_multiline(hint_raw, 160)
	if label.is_empty() or label != label_raw.strip_edges() or hint.is_empty() or hint != hint_raw.replace("\r\n", "\n").replace("\r", "\n").strip_edges():
		return {"ok": false, "message": "起步模板 %s 的拿取引导文字无效。" % template_id}
	var take_values: Variant = raw.get("take_character_ids", [])
	var conditional_values: Variant = raw.get("conditional_character_ids", [])
	if not (take_values is Array) or not (conditional_values is Array):
		return {"ok": false, "message": "起步模板 %s 的拿取引导人物必须使用数组。" % template_id}
	if (take_values as Array).size() > SCENARIO_TAKE_GUIDANCE_LIMIT:
		return {"ok": false, "message": "起步模板 %s 的一键拿取人物不得超过 %d 人。" % [template_id, SCENARIO_TAKE_GUIDANCE_LIMIT]}
	if (conditional_values as Array).size() > SCENARIO_CONDITIONAL_GUIDANCE_LIMIT:
		return {"ok": false, "message": "起步模板 %s 的条件人物不得超过 %d 人。" % [template_id, SCENARIO_CONDITIONAL_GUIDANCE_LIMIT]}
	var take_ids: Array[String] = []
	var conditional_ids: Array[String] = []
	for character_id_value in take_values:
		var character_id := str(character_id_value).strip_edges()
		if not _has_character_id(character_id) or character_id in take_ids:
			return {"ok": false, "message": "起步模板 %s 的一键拿取人物引用未知或重复人物：%s。" % [template_id, character_id]}
		take_ids.append(character_id)
	for character_id_value in conditional_values:
		var character_id := str(character_id_value).strip_edges()
		if not _has_character_id(character_id) or character_id in conditional_ids or character_id in take_ids:
			return {"ok": false, "message": "起步模板 %s 的条件人物引用未知、重复或与一键拿取重复：%s。" % [template_id, character_id]}
		conditional_ids.append(character_id)
	return {
		"ok": true,
		"guidance": {
			"label": label,
			"hint": hint,
			"take_character_ids": take_ids,
			"conditional_character_ids": conditional_ids,
		},
	}


func _find_scenario_template(template_id: String) -> Dictionary:
	for template in scenario_templates:
		if str(template.get("id", "")) == template_id:
			return template.duplicate(true)
	return {}


func _build_scenario_template_candidate(template_id: String) -> Dictionary:
	var template := _find_scenario_template(template_id)
	if template.is_empty():
		return {"ok": false, "message": "找不到这个起步模板，当前沙盘没有变化。"}
	var next_placements: Dictionary = {}
	for placement_value in template.get("placements", []):
		if not (placement_value is Dictionary):
			return {"ok": false, "message": "起步模板摆放数据已失效。"}
		var placement: Dictionary = placement_value
		var character_id := str(placement.get("character_id", ""))
		var place_id := str(placement.get("place_id", ""))
		var place := _find_place(place_id)
		if not _has_character_id(character_id) or place.is_empty() or next_placements.has(character_id):
			return {"ok": false, "message": "起步模板的人物或地点引用已失效。"}
		next_placements[character_id] = {
			"x": float(place.get("x", 0.5)),
			"y": float(place.get("y", 0.5)),
			"place_id": place_id
		}
	var scenario_result := _decode_scenario_state({
		"scenario_id": template.get("scenario_id", ""),
		"start_year": template.get("year", null),
		"era_label": template.get("era_label", ""),
		"scenario_kind": template.get("scenario_kind", ""),
		"featured_character_ids": template.get("featured_character_ids", []).duplicate(),
		"history_layer_ids": template.get("history_layer_ids", []).duplicate(),
		"factions": template.get("factions", []).duplicate(true),
		"character_assignments": template.get("character_assignments", []).duplicate(true),
		"city_ownership": template.get("city_ownership", []).duplicate(true)
	})
	if not bool(scenario_result.get("ok", false)):
		return {"ok": false, "message": "起步模板的玩法势力数据已失效。"}
	return {
		"ok": true,
		"template": template.duplicate(true),
		"placements": next_placements,
		"annotations": {},
		"scenario_state": (scenario_result.get("scenario_state", {}) as Dictionary).duplicate(true)
	}


func _build_capture_scenario_candidate(requested_scenario_id: String) -> Dictionary:
	for template in scenario_templates:
		if str(template.get("scenario_id", "")) == requested_scenario_id:
			return _build_scenario_template_candidate(str(template.get("id", "")))
	return {
		"ok": false,
		"message": "找不到确定性截图剧本：%s。" % requested_scenario_id
	}


func _load_personal_scenario_templates() -> void:
	personal_scenario_templates.clear()
	personal_scenario_template_load_error = ""
	_personal_template_writes_blocked = false
	_personal_template_write_block_reason = ""
	if not FileAccess.file_exists(personal_template_store_path):
		return
	var file := FileAccess.open(personal_template_store_path, FileAccess.READ)
	if file == null:
		personal_scenario_template_load_error = "无法读取个人模板库。"
		_personal_template_writes_blocked = true
		_personal_template_write_block_reason = personal_scenario_template_load_error
		return
	if file.get_length() > MAX_IMPORT_FILE_BYTES * 2:
		personal_scenario_template_load_error = "个人模板库超过安全上限。"
		_personal_template_writes_blocked = true
		_personal_template_write_block_reason = personal_scenario_template_load_error
		return
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	file = null
	if parse_error != OK:
		personal_scenario_template_load_error = "个人模板库 JSON 第 %d 行有误：%s" % [parser.get_error_line(), parser.get_error_message()]
		_personal_template_writes_blocked = true
		_personal_template_write_block_reason = personal_scenario_template_load_error
		return
	var document_for_decode: Variant = parser.data
	var geometry_migration_required := false
	if document_for_decode is Dictionary:
		var raw_root: Dictionary = document_for_decode
		var raw_templates_value: Variant = raw_root.get("templates", null)
		if raw_templates_value is Array and not (raw_templates_value as Array).is_empty():
			var all_geometry_v3 := true
			for template_value in (raw_templates_value as Array):
				if not (template_value is Dictionary) \
					or not _is_integer_number((template_value as Dictionary).get("map_geometry_version", null)) \
					or int((template_value as Dictionary).get("map_geometry_version", -1)) != MAP_GEOMETRY_MIGRATABLE_VERSION:
					all_geometry_v3 = false
					break
			if all_geometry_v3:
				var migration_result := MapGeometryMigrationScript.migrate_personal_template_records(
					raw_templates_value,
					MAP_GEOMETRY_MIGRATABLE_VERSION,
					MAP_GEOMETRY_VERSION,
					MAP_GEOMETRY_V3_BOUNDS,
					MAP_GEOMETRY_V4_BOUNDS
				)
				if not bool(migration_result.get("ok", false)):
					personal_scenario_template_load_error = "个人模板旧地图范围迁移失败：%s" % str(migration_result.get("message", "坐标无效。"))
					_personal_template_writes_blocked = true
					_personal_template_write_block_reason = personal_scenario_template_load_error
					return
				var migrated_root := raw_root.duplicate(true)
				migrated_root["templates"] = (migration_result.get("templates", []) as Array).duplicate(true)
				document_for_decode = migrated_root
				geometry_migration_required = true
	var result := _decode_personal_template_store(document_for_decode)
	if not bool(result.get("ok", false)):
		personal_scenario_template_load_error = str(result.get("message", "个人模板库无法安全读取。"))
		_personal_template_writes_blocked = true
		_personal_template_write_block_reason = personal_scenario_template_load_error
		return
	personal_scenario_templates = result.get("templates", []).duplicate(true)
	var template_migration_required := (
		geometry_migration_required
		or bool(result.get("schema_migration_required", false))
		or bool(result.get("catalog_migration_required", false))
	)
	if template_migration_required:
		var backup_result := _create_raw_migration_backup(
			personal_template_store_path,
			int(result.get("source_schema_version", 0)),
			int(result.get("source_character_catalog_version", 1)),
			"personal_templates"
		)
		if not bool(backup_result.get("ok", false)):
			personal_scenario_template_load_error = "个人模板已在内存迁移，但迁移前逐字节备份失败；原文件已保留且已停止写入。"
			_personal_template_writes_blocked = true
			_personal_template_write_block_reason = personal_scenario_template_load_error
			return
		var write_result := _write_personal_template_store(personal_scenario_templates)
		if not bool(write_result.get("ok", false)):
			personal_scenario_template_load_error = "个人模板已在内存迁移，但无法安全写回；原文件与迁移前备份均已保留。"
			_personal_template_writes_blocked = true
			_personal_template_write_block_reason = personal_scenario_template_load_error


func _decode_personal_template_store(document: Variant) -> Dictionary:
	if not (document is Dictionary):
		return {"ok": false, "message": "个人模板库顶层必须是对象。"}
	var root: Dictionary = document
	if str(root.get("format", "")) != PERSONAL_TEMPLATE_FORMAT:
		return {"ok": false, "message": "个人模板库格式标识无效。"}
	if not _is_integer_number(root.get("schema_version", null)):
		return {"ok": false, "message": "个人模板库版本不兼容。"}
	var schema_version := int(root.get("schema_version", -1))
	if schema_version < PERSONAL_TEMPLATE_MIN_SCHEMA_VERSION or schema_version > PERSONAL_TEMPLATE_SCHEMA_VERSION:
		return {"ok": false, "message": "个人模板库版本不兼容。"}
	var allowed_root_keys := {"format": true, "schema_version": true, "templates": true, "updated_at": true}
	if schema_version >= 3:
		allowed_root_keys["character_catalog_version"] = true
	for key in root.keys():
		if not allowed_root_keys.has(str(key)):
			return {"ok": false, "message": "个人模板库顶层含未定义字段：%s。" % str(key)}
	if root.size() != allowed_root_keys.size():
		return {"ok": false, "message": "个人模板库顶层字段不完整。"}
	var source_catalog_version := 1
	if schema_version >= 3:
		if not _is_integer_number(root.get("character_catalog_version", null)):
			return {"ok": false, "message": "个人模板库缺少有效人物目录版本。"}
		source_catalog_version = int(root.get("character_catalog_version"))
		if source_catalog_version > character_catalog_version:
			return {"ok": false, "message": "个人模板库由更新的人物目录创建，请升级游戏后再试。"}
		if _character_ids_for_catalog_version(source_catalog_version).is_empty():
			return {"ok": false, "message": "个人模板库人物目录版本无法安全读取。"}
	var allowed_character_ids := _character_ids_for_catalog_version(source_catalog_version)
	if allowed_character_ids.is_empty():
		return {"ok": false, "message": "个人模板库人物目录版本不受支持。"}
	var template_values: Variant = root.get("templates", null)
	if not (template_values is Array) or (template_values as Array).size() > PERSONAL_TEMPLATE_LIMIT:
		return {"ok": false, "message": "个人模板数量或结构无效。"}
	var allowed_record_keys := {
		"id": true, "name": true, "title": true, "description": true,
		"scenario_source": true, "source_title": true, "basis_note": true,
		"semantic_layer": true, "verification_status": true, "created_at": true,
		"map_id": true, "map_geometry_version": true, "placements": true,
		"factions": true, "character_assignments": true, "annotations": true
	}
	if schema_version >= 3:
		for contract_key in [
			"scenario_id", "scenario_kind", "era_label", "featured_character_ids",
			"history_layer_ids", "city_ownership"
		]:
			allowed_record_keys[contract_key] = true
	var seen_ids: Dictionary = {}
	var seen_names: Dictionary = {}
	var decoded_templates: Array[Dictionary] = []
	for index in range((template_values as Array).size()):
		var value: Variant = (template_values as Array)[index]
		if not (value is Dictionary):
			return {"ok": false, "message": "第 %d 个个人模板不是对象。" % (index + 1)}
		var record: Dictionary = value
		for key in record.keys():
			if not allowed_record_keys.has(str(key)):
				return {"ok": false, "message": "个人模板含未定义字段：%s。" % str(key)}
		var template_id := str(record.get("id", "")).strip_edges()
		if not template_id.begins_with("tpl_") or not _is_safe_record_id(template_id) or seen_ids.has(template_id) or not _find_scenario_template(template_id).is_empty():
			return {"ok": false, "message": "第 %d 个个人模板 ID 无效、重复或与内置模板冲突。" % (index + 1)}
		seen_ids[template_id] = true
		var raw_name := str(record.get("name", ""))
		var name := _sanitize_single_line(raw_name, MAX_PERSONAL_TEMPLATE_NAME_LENGTH, "")
		if name.is_empty() or name != raw_name.strip_edges() or seen_names.has(name):
			return {"ok": false, "message": "个人模板名称为空、重复或不符合单行长度规则。"}
		seen_names[name] = true
		var raw_title := str(record.get("title", ""))
		var title := _sanitize_single_line(raw_title, MAX_SANDBOX_TITLE_LENGTH, "")
		var raw_description := str(record.get("description", ""))
		var description := _sanitize_multiline(raw_description, MAX_PERSONAL_TEMPLATE_DESCRIPTION_LENGTH)
		var raw_source := str(record.get("scenario_source", ""))
		var scenario_source := _sanitize_single_line(raw_source, MAX_SANDBOX_SOURCE_LENGTH, "")
		var raw_source_title := str(record.get("source_title", ""))
		var source_title := _sanitize_single_line(raw_source_title, MAX_SANDBOX_TITLE_LENGTH, "")
		if title.is_empty() or title != raw_title.strip_edges() or description != raw_description.replace("\r\n", "\n").replace("\r", "\n").strip_edges() or scenario_source != raw_source.strip_edges() or source_title.is_empty() or source_title != raw_source_title.strip_edges():
			return {"ok": false, "message": "个人模板的标题、说明或来源文本无效。"}
		if str(record.get("semantic_layer", "")) != ANNOTATION_SEMANTIC_LAYER or str(record.get("verification_status", "")) != ANNOTATION_VERIFICATION_STATUS:
			return {"ok": false, "message": "个人模板必须明确标记为玩家创作／项目未核验。"}
		var basis_note := str(record.get("basis_note", ""))
		var expected_basis_note := (
			"人物落点、玩法分组、城池归属和标记均为玩家创作，项目未核验。"
			if schema_version >= 3
			else "人物落点、玩法分组和标记均为玩家创作，项目未核验。"
		)
		if basis_note != expected_basis_note:
			return {"ok": false, "message": "个人模板缺少固定的资料边界说明。"}
		var created_at := str(record.get("created_at", "")).strip_edges()
		if created_at.is_empty() or created_at.length() > 40:
			return {"ok": false, "message": "个人模板创建时间无效。"}
		if str(record.get("map_id", "")) != MAP_ID or not _is_integer_number(record.get("map_geometry_version", null)) or int(record.get("map_geometry_version", -1)) != MAP_GEOMETRY_VERSION:
			return {"ok": false, "message": "个人模板与当前地图不兼容。"}
		var placement_values: Variant = record.get("placements", null)
		if not (placement_values is Array) or (placement_values as Array).size() > characters.size():
			return {"ok": false, "message": "个人模板的人物摆放结构或数量无效。"}
		var decoded_placements: Array[Dictionary] = []
		var placed_characters: Dictionary = {}
		for placement_index in range((placement_values as Array).size()):
			var placement_value: Variant = (placement_values as Array)[placement_index]
			if not (placement_value is Dictionary):
				return {"ok": false, "message": "个人模板第 %d 个人物摆放不是对象。" % (placement_index + 1)}
			var placement: Dictionary = placement_value
			var character_id := str(placement.get("character_id", "")).strip_edges()
			if character_id not in allowed_character_ids or placed_characters.has(character_id):
				return {"ok": false, "message": "个人模板含未知或重复人物。"}
			var has_place := placement.has("place_id")
			var has_free_coordinates := placement.has("x") or placement.has("y")
			if has_place == has_free_coordinates:
				return {"ok": false, "message": "人物摆放必须在地点锚点和自由位置之间二选一。"}
			if has_place:
				if placement.size() != 2:
					return {"ok": false, "message": "地点锚定人物摆放含多余字段。"}
				var place_id := str(placement.get("place_id", "")).strip_edges()
				if _find_place(place_id).is_empty():
					return {"ok": false, "message": "个人模板引用了未知地点：%s。" % place_id}
				decoded_placements.append({"character_id": character_id, "place_id": place_id})
			else:
				if placement.size() != 3 or not placement.has("x") or not placement.has("y"):
					return {"ok": false, "message": "自由人物摆放字段不完整。"}
				for coordinate_key in ["x", "y"]:
					var coordinate: Variant = placement.get(coordinate_key, null)
					if not (typeof(coordinate) in [TYPE_INT, TYPE_FLOAT]) or not is_finite(float(coordinate)) or float(coordinate) < 0.0 or float(coordinate) > 1.0:
						return {"ok": false, "message": "自由人物摆放坐标无效。"}
				decoded_placements.append({"character_id": character_id, "x": float(placement.get("x")), "y": float(placement.get("y"))})
			placed_characters[character_id] = true
		var legacy_personal_contract := {
			"scenario_id": "personal_%s" % template_id,
			"start_year": null,
			"era_label": "个人模板",
			"scenario_kind": SCENARIO_KIND_CUSTOM,
			"featured_character_ids": placed_characters.keys(),
			"history_layer_ids": [],
			"city_ownership": []
		}
		var scenario_result := _decode_scenario_state(
			{
				"scenario_id": record.get("scenario_id", ""),
				"start_year": null,
				"era_label": record.get("era_label", ""),
				"scenario_kind": record.get("scenario_kind", ""),
				"featured_character_ids": record.get("featured_character_ids", []),
				"history_layer_ids": record.get("history_layer_ids", []),
				"factions": record.get("factions", null),
				"character_assignments": record.get("character_assignments", null),
				"city_ownership": record.get("city_ownership", [])
			} if schema_version >= 3 else {
				"factions": record.get("factions", null),
				"character_assignments": record.get("character_assignments", null)
			},
			schema_version < 2,
			schema_version >= 2,
			legacy_personal_contract if schema_version < 3 else {}
		)
		if not bool(scenario_result.get("ok", false)):
			return {"ok": false, "message": "个人模板的玩法势力无效：%s" % str(scenario_result.get("message", ""))}
		var decoded_scenario: Dictionary = scenario_result.get("scenario_state", {})
		for assignment_value in decoded_scenario.get("character_assignments", []):
			if not placed_characters.has(str((assignment_value as Dictionary).get("character_id", ""))):
				return {"ok": false, "message": "个人模板不得给背包人物设置隐藏玩法分组。"}
		var annotation_values: Variant = record.get("annotations", null)
		if not (annotation_values is Array) or (annotation_values as Array).size() > MAX_IMPORT_ANNOTATIONS:
			return {"ok": false, "message": "个人模板的标记结构或数量无效。"}
		var decoded_annotations: Array[Dictionary] = []
		var seen_annotation_ids: Dictionary = {}
		var allowed_annotation_keys := {"id": true, "kind": true, "marker_type": true, "semantic_layer": true, "verification_status": true, "x": true, "y": true, "label": true, "style": true}
		if schema_version >= 4:
			allowed_annotation_keys["faction_id"] = true
		var template_faction_ids: Dictionary = {}
		for faction_value in decoded_scenario.get("factions", []):
			if faction_value is Dictionary:
				template_faction_ids[str((faction_value as Dictionary).get("id", ""))] = true
		for annotation_index in range((annotation_values as Array).size()):
			var annotation_value: Variant = (annotation_values as Array)[annotation_index]
			if not (annotation_value is Dictionary):
				return {"ok": false, "message": "个人模板第 %d 个标记不是对象。" % (annotation_index + 1)}
			var annotation: Dictionary = annotation_value
			if annotation.size() != allowed_annotation_keys.size():
				return {"ok": false, "message": "个人模板标记字段不完整。"}
			for key in annotation.keys():
				if not allowed_annotation_keys.has(str(key)):
					return {"ok": false, "message": "个人模板标记含未定义字段：%s。" % str(key)}
			var annotation_id := str(annotation.get("id", "")).strip_edges()
			var label := str(annotation.get("label", ""))
			if seen_annotation_ids.has(annotation_id) or label != label.replace("\r", " ").replace("\n", " ").strip_edges().left(24):
				return {"ok": false, "message": "个人模板标记 ID 重复或文字无效。"}
			for coordinate_key in ["x", "y"]:
				var coordinate: Variant = annotation.get(coordinate_key, null)
				if not (typeof(coordinate) in [TYPE_INT, TYPE_FLOAT]) or not is_finite(float(coordinate)) or float(coordinate) < 0.0 or float(coordinate) > 1.0:
					return {"ok": false, "message": "个人模板标记坐标无效。"}
			var warnings: Array[String] = []
			var decoded_annotation := _decode_annotation(annotation, warnings, annotation_index)
			if decoded_annotation.is_empty() or not warnings.is_empty():
				return {"ok": false, "message": "个人模板标记未通过严格校验。"}
			var annotation_faction_id := str(decoded_annotation.get("faction_id", ""))
			if not annotation_faction_id.is_empty() and not template_faction_ids.has(annotation_faction_id):
				return {"ok": false, "message": "个人模板标记引用了不存在的玩法势力。"}
			seen_annotation_ids[annotation_id] = true
			decoded_annotations.append(decoded_annotation)
		decoded_templates.append({
			"id": template_id,
			"scenario_id": str(decoded_scenario.get("scenario_id", "")),
			"scenario_kind": str(decoded_scenario.get("scenario_kind", "")),
			"era_label": str(decoded_scenario.get("era_label", "")),
			"featured_character_ids": (decoded_scenario.get("featured_character_ids", []) as Array).duplicate(),
			"history_layer_ids": (decoded_scenario.get("history_layer_ids", []) as Array).duplicate(),
			"name": name,
			"title": title,
			"description": description,
			"scenario_source": scenario_source,
			"source_title": source_title,
			"basis_note": "人物落点、玩法分组、城池归属和标记均为玩家创作，项目未核验。",
			"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
			"verification_status": ANNOTATION_VERIFICATION_STATUS,
			"created_at": created_at,
			"map_id": MAP_ID,
			"map_geometry_version": MAP_GEOMETRY_VERSION,
			"placements": decoded_placements,
			"factions": (decoded_scenario.get("factions", []) as Array).duplicate(true),
			"character_assignments": (decoded_scenario.get("character_assignments", []) as Array).duplicate(true),
			"city_ownership": (decoded_scenario.get("city_ownership", []) as Array).duplicate(true),
			"annotations": decoded_annotations
		})
	return {
		"ok": true,
		"templates": decoded_templates,
		"schema_migration_required": schema_version < PERSONAL_TEMPLATE_SCHEMA_VERSION,
		"catalog_migration_required": source_catalog_version != character_catalog_version,
		"source_schema_version": schema_version,
		"source_character_catalog_version": source_catalog_version
	}


func _build_personal_template_store_document(template_values: Array) -> Dictionary:
	return {
		"format": PERSONAL_TEMPLATE_FORMAT,
		"schema_version": PERSONAL_TEMPLATE_SCHEMA_VERSION,
		"character_catalog_version": character_catalog_version,
		"templates": template_values.duplicate(true),
		"updated_at": Time.get_datetime_string_from_system(false, true)
	}


func _write_personal_template_store(template_values: Array) -> Dictionary:
	if _personal_template_writes_blocked:
		return {"ok": false, "error_code": "personal_template_write_blocked", "message": _personal_template_write_block_reason}
	var document := _build_personal_template_store_document(template_values)
	var validation := _decode_personal_template_store(document)
	if not bool(validation.get("ok", false)):
		return {
			"ok": false,
			"error_code": "invalid_personal_template_store",
			"message": "个人模板库候选没有通过完整校验：%s" % str(validation.get("message", "未知错误。"))
		}
	return _write_json_atomic(personal_template_store_path, document, true)


func _filtered_personal_template_scenario_state() -> Dictionary:
	var decoded_result := _decode_scenario_state(scenario_state)
	if not bool(decoded_result.get("ok", false)):
		return {}
	var decoded: Dictionary = decoded_result.get("scenario_state", {})
	var kept_assignments: Array[Dictionary] = []
	var used_factions: Dictionary = {}
	for assignment_value in decoded.get("character_assignments", []):
		var assignment: Dictionary = assignment_value
		if placements.has(str(assignment.get("character_id", ""))):
			kept_assignments.append(assignment.duplicate(true))
			used_factions[str(assignment.get("faction_id", ""))] = true
	var kept_factions: Array[Dictionary] = []
	for faction_value in decoded.get("factions", []):
		var faction: Dictionary = faction_value
		if used_factions.has(str(faction.get("id", ""))):
			kept_factions.append(faction.duplicate(true))
	var kept_ownership: Array[Dictionary] = []
	for ownership_value in decoded.get("city_ownership", []):
		var ownership: Dictionary = ownership_value
		if used_factions.has(str(ownership.get("faction_id", ""))):
			kept_ownership.append(ownership.duplicate(true))
	var featured_ids: Array[String] = []
	for character_id_value in placements.keys():
		var character_id := str(character_id_value)
		if _has_character_id(character_id):
			featured_ids.append(character_id)
	featured_ids.sort()
	return {
		"scenario_id": "custom_personal",
		"start_year": null,
		"era_label": "个人模板",
		"scenario_kind": SCENARIO_KIND_CUSTOM,
		"featured_character_ids": featured_ids,
		"history_layer_ids": [],
		"factions": kept_factions,
		"character_assignments": kept_assignments,
		"city_ownership": kept_ownership
	}


func _build_current_personal_template_record(template_name: String, template_description: String, for_share_package := false) -> Dictionary:
	var name := _sanitize_single_line(template_name, MAX_PERSONAL_TEMPLATE_NAME_LENGTH, "")
	if name.is_empty():
		return {"ok": false, "message": "请先给这个开局起一个名字。"}
	if _save_writes_blocked:
		return {"ok": false, "message": "当前沙盘处于原文件保护状态，暂时不能据此创建开局。"}
	if not for_share_package:
		for existing in personal_scenario_templates:
			if str(existing.get("name", "")) == name:
				return {"ok": false, "message": "已经有一个同名个人模板，请换一个名字。"}
		if _personal_template_writes_blocked:
			return {"ok": false, "message": "个人模板库处于原文件保护状态。%s" % ("\n" + _personal_template_write_block_reason if not _personal_template_write_block_reason.is_empty() else "")}
		if personal_scenario_templates.size() >= PERSONAL_TEMPLATE_LIMIT:
			return {"ok": false, "message": "个人模板已达到 %d 个上限，请先删除不再需要的模板。" % PERSONAL_TEMPLATE_LIMIT}
	var saved_placements: Array[Dictionary] = []
	var character_ids := placements.keys()
	character_ids.sort()
	for character_id_value in character_ids:
		var character_id := str(character_id_value)
		if not _has_character_id(character_id):
			return {"ok": false, "message": "当前摆放含未知人物，个人模板未创建。"}
		var placement: Dictionary = placements[character_id]
		var place_id := str(placement.get("place_id", ""))
		if not _find_place(place_id).is_empty():
			saved_placements.append({"character_id": character_id, "place_id": place_id})
		else:
			var x_value: Variant = placement.get("x", null)
			var y_value: Variant = placement.get("y", null)
			if not (typeof(x_value) in [TYPE_INT, TYPE_FLOAT]) or not (typeof(y_value) in [TYPE_INT, TYPE_FLOAT]) or not is_finite(float(x_value)) or not is_finite(float(y_value)):
				return {"ok": false, "message": "当前自由摆放位置无效，个人模板未创建。"}
			saved_placements.append({"character_id": character_id, "x": clampf(float(x_value), 0.0, 1.0), "y": clampf(float(y_value), 0.0, 1.0)})
	var saved_annotations: Array[Dictionary] = []
	var annotation_ids := annotations.keys()
	annotation_ids.sort()
	for annotation_id_value in annotation_ids:
		var sanitized := _sanitize_annotation(annotations.get(str(annotation_id_value), {}))
		if sanitized.is_empty():
			return {"ok": false, "message": "当前标记含无效记录，个人模板未创建。"}
		saved_annotations.append(sanitized)
	var filtered_scenario := _filtered_personal_template_scenario_state()
	if filtered_scenario.is_empty():
		return {"ok": false, "message": "当前玩法分组未通过校验，个人模板未创建。"}
	var current_title := _sanitize_single_line(str(sandbox_metadata.get("title", "未命名沙盘")), MAX_SANDBOX_TITLE_LENGTH, "未命名沙盘")
	var record := {
		"id": _new_record_id("tpl"),
		"scenario_id": "",
		"scenario_kind": str(filtered_scenario.get("scenario_kind", SCENARIO_KIND_CUSTOM)),
		"era_label": str(filtered_scenario.get("era_label", "个人模板")),
		"featured_character_ids": (filtered_scenario.get("featured_character_ids", []) as Array).duplicate(),
		"history_layer_ids": (filtered_scenario.get("history_layer_ids", []) as Array).duplicate(),
		"name": name,
		"title": current_title,
		"description": _sanitize_multiline(template_description, MAX_PERSONAL_TEMPLATE_DESCRIPTION_LENGTH),
		"scenario_source": _sanitize_single_line(str(sandbox_metadata.get("scenario_source", "")), MAX_SANDBOX_SOURCE_LENGTH, ""),
		"source_title": current_title,
		"basis_note": "人物落点、玩法分组、城池归属和标记均为玩家创作，项目未核验。",
		"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
		"verification_status": ANNOTATION_VERIFICATION_STATUS,
		"created_at": Time.get_datetime_string_from_system(false, true),
		"map_id": MAP_ID,
		"map_geometry_version": MAP_GEOMETRY_VERSION,
		"placements": saved_placements,
		"factions": (filtered_scenario.get("factions", []) as Array).duplicate(true),
		"character_assignments": (filtered_scenario.get("character_assignments", []) as Array).duplicate(true),
		"city_ownership": (filtered_scenario.get("city_ownership", []) as Array).duplicate(true),
		"annotations": saved_annotations
	}
	record["scenario_id"] = "personal_%s" % str(record.get("id", ""))
	var validation := _decode_personal_template_store(_build_personal_template_store_document([record]))
	if not bool(validation.get("ok", false)):
		return {"ok": false, "message": "个人模板没有通过完整校验：%s" % str(validation.get("message", ""))}
	return {"ok": true, "template": record}


func _create_personal_scenario_template(template_name: String, template_description: String) -> Dictionary:
	var build_result := _build_current_personal_template_record(template_name, template_description)
	if not bool(build_result.get("ok", false)):
		return build_result
	var record: Dictionary = build_result.get("template", {}).duplicate(true)
	var next_templates: Array[Dictionary] = personal_scenario_templates.duplicate(true)
	next_templates.append(record)
	var write_result := _write_personal_template_store(next_templates)
	if not bool(write_result.get("ok", false)):
		return write_result
	personal_scenario_templates = next_templates
	return {"ok": true, "template": record.duplicate(true)}


func _find_personal_scenario_template(template_id: String) -> Dictionary:
	for template in personal_scenario_templates:
		if str(template.get("id", "")) == template_id:
			return template.duplicate(true)
	return {}


func _update_personal_scenario_template_text(template_id: String, requested_name: String, requested_description: String) -> Dictionary:
	if _personal_template_writes_blocked:
		return {
			"ok": false,
			"error_code": "personal_template_write_blocked",
			"message": _personal_template_write_block_reason
		}
	var template_index := -1
	var original: Dictionary = {}
	for index in range(personal_scenario_templates.size()):
		var template: Dictionary = personal_scenario_templates[index]
		if str(template.get("id", "")) == template_id:
			template_index = index
			original = template.duplicate(true)
			break
	if template_index < 0:
		return {"ok": false, "error_code": "personal_template_not_found", "message": "找不到这个个人模板。"}
	var name := _sanitize_single_line(requested_name, MAX_PERSONAL_TEMPLATE_NAME_LENGTH, "")
	if name.is_empty():
		return {"ok": false, "error_code": "personal_template_name_empty", "message": "请先给个人模板起一个名字。"}
	for existing in personal_scenario_templates:
		if str(existing.get("id", "")) != template_id and str(existing.get("name", "")) == name:
			return {
				"ok": false,
				"error_code": "personal_template_name_duplicate",
				"message": "已经有一个同名个人模板，请换一个名字。"
			}
	var description := _sanitize_multiline(requested_description, MAX_PERSONAL_TEMPLATE_DESCRIPTION_LENGTH)
	if name == str(original.get("name", "")) and description == str(original.get("description", "")):
		return {"ok": true, "unchanged": true, "template": original}
	var updated := original.duplicate(true)
	updated["name"] = name
	updated["description"] = description
	var next_templates: Array[Dictionary] = personal_scenario_templates.duplicate(true)
	next_templates[template_index] = updated
	var write_result := _write_personal_template_store(next_templates)
	if not bool(write_result.get("ok", false)):
		return write_result
	personal_scenario_templates = next_templates
	return {"ok": true, "unchanged": false, "template": updated.duplicate(true)}


func _delete_personal_scenario_template(template_id: String) -> Dictionary:
	if _personal_template_writes_blocked:
		return {"ok": false, "message": _personal_template_write_block_reason}
	var next_templates: Array[Dictionary] = []
	var found := false
	for template in personal_scenario_templates:
		if str(template.get("id", "")) == template_id:
			found = true
			continue
		next_templates.append(template.duplicate(true))
	if not found:
		return {"ok": false, "message": "找不到这个个人模板。"}
	var write_result := _write_personal_template_store(next_templates)
	if not bool(write_result.get("ok", false)):
		return write_result
	personal_scenario_templates = next_templates
	return {"ok": true}


func _build_personal_template_candidate(template_id: String) -> Dictionary:
	var template := _find_personal_scenario_template(template_id)
	if template.is_empty():
		return {"ok": false, "message": "找不到这个个人模板，当前沙盘没有变化。"}
	return _build_personal_template_record_candidate(template)


func _build_personal_template_record_candidate(template: Dictionary) -> Dictionary:
	if template.is_empty():
		return {"ok": false, "message": "开局模板为空，当前沙盘没有变化。"}
	var next_placements: Dictionary = {}
	for placement_value in template.get("placements", []):
		if not (placement_value is Dictionary):
			return {"ok": false, "message": "开局模板的摆放记录无效。"}
		var placement: Dictionary = placement_value
		var character_id := str(placement.get("character_id", ""))
		if not _has_character_id(character_id) or next_placements.has(character_id):
			return {"ok": false, "message": "开局模板引用了未知或重复人物。"}
		if placement.has("place_id"):
			var place_id := str(placement.get("place_id", ""))
			var place := _find_place(place_id)
			if place.is_empty():
				return {"ok": false, "message": "个人模板引用的地点已经失效。"}
			next_placements[character_id] = {"x": float(place.get("x", 0.5)), "y": float(place.get("y", 0.5)), "place_id": place_id}
		else:
			next_placements[character_id] = {"x": float(placement.get("x", 0.5)), "y": float(placement.get("y", 0.5))}
	var next_annotations: Dictionary = {}
	for annotation_value in template.get("annotations", []):
		if not (annotation_value is Dictionary):
			return {"ok": false, "message": "开局模板的标记记录无效。"}
		var annotation: Dictionary = annotation_value
		var annotation_id := str(annotation.get("id", ""))
		if annotation_id.is_empty() or next_annotations.has(annotation_id):
			return {"ok": false, "message": "开局模板含空白或重复标记 ID。"}
		next_annotations[annotation_id] = annotation.duplicate(true)
	var scenario_result := _decode_scenario_state({
		"scenario_id": template.get("scenario_id", ""),
		"start_year": null,
		"era_label": template.get("era_label", "个人模板"),
		"scenario_kind": template.get("scenario_kind", SCENARIO_KIND_CUSTOM),
		"featured_character_ids": template.get("featured_character_ids", []).duplicate(),
		"history_layer_ids": template.get("history_layer_ids", []).duplicate(),
		"factions": template.get("factions", []).duplicate(true),
		"character_assignments": template.get("character_assignments", []).duplicate(true),
		"city_ownership": template.get("city_ownership", []).duplicate(true)
	})
	if not bool(scenario_result.get("ok", false)):
		return {"ok": false, "message": "个人模板的玩法势力数据已失效。"}
	return {
		"ok": true,
		"template": template.duplicate(true),
		"placements": next_placements,
		"annotations": next_annotations,
		"scenario_state": (scenario_result.get("scenario_state", {}) as Dictionary).duplicate(true)
	}


func _build_scenario_share_document(template: Dictionary) -> Dictionary:
	return ScenarioSharePackagePolicyScript.build_document(
		template,
		_new_record_id("pkg"),
		Time.get_datetime_string_from_system(false, true),
		character_catalog_version,
		MAP_ID,
		MAP_GEOMETRY_VERSION
	)


func _decode_scenario_share_document(document: Variant) -> Dictionary:
	var outer := ScenarioSharePackagePolicyScript.decode_outer_document(
		document,
		character_catalog_version,
		MAP_ID,
		MAP_GEOMETRY_VERSION
	)
	if not bool(outer.get("ok", false)):
		return outer
	var template_value: Variant = outer.get("template", null)
	if not (template_value is Dictionary):
		return {"ok": false, "error_code": "invalid_template", "message": "开局包缺少有效模板。"}
	var store_validation := _decode_personal_template_store(
		_build_personal_template_store_document([(template_value as Dictionary).duplicate(true)])
	)
	if not bool(store_validation.get("ok", false)):
		return {
			"ok": false,
			"error_code": "invalid_template",
			"message": "开局内容没有通过严格校验：%s" % str(store_validation.get("message", "结构无效。"))
		}
	var decoded_templates: Array = store_validation.get("templates", [])
	if decoded_templates.size() != 1 or not (decoded_templates[0] is Dictionary):
		return {"ok": false, "error_code": "invalid_template", "message": "开局包必须只包含一个开局。"}
	var template: Dictionary = (decoded_templates[0] as Dictionary).duplicate(true)
	var candidate := _build_personal_template_record_candidate(template)
	if not bool(candidate.get("ok", false)):
		return {
			"ok": false,
			"error_code": "invalid_template",
			"message": str(candidate.get("message", "开局内容已失效。"))
		}
	return {
		"ok": true,
		"error_code": "",
		"package_id": str(outer.get("package_id", "")),
		"exported_at": str(outer.get("exported_at", "")),
		"template": template,
		"candidate": candidate,
		"character_count": int((template.get("placements", []) as Array).size()),
		"annotation_count": int((template.get("annotations", []) as Array).size()),
		"faction_count": int((template.get("factions", []) as Array).size()),
		"ownership_count": int((template.get("city_ownership", []) as Array).size())
	}


func _write_scenario_share_package(path: String, template: Dictionary, allow_overwrite := false) -> Dictionary:
	var target_path := ScenarioSharePackagePolicyScript.normalized_path(path)
	var document := _build_scenario_share_document(template)
	var validation := _decode_scenario_share_document(document)
	if not bool(validation.get("ok", false)):
		return {
			"ok": false,
			"error_code": str(validation.get("error_code", "invalid_package")),
			"message": str(validation.get("message", "开局包没有通过写前校验。")),
			"path": target_path
		}
	var encoded := JSON.stringify(document, "\t")
	if encoded.to_utf8_buffer().size() > MAX_SCENARIO_SHARE_FILE_BYTES:
		return {"ok": false, "error_code": "file_too_large", "message": "开局包超过 1 MB 安全上限。", "path": target_path}
	var result := _write_json_atomic(target_path, document, allow_overwrite)
	result["path"] = target_path
	return result


func _read_scenario_share_package(path: String) -> Dictionary:
	if not path.to_lower().ends_with(ScenarioSharePackagePolicyScript.FILE_EXTENSION):
		return {"ok": false, "error_code": "wrong_extension", "message": "请选择 .sanguostart 开局包。"}
	var absolute_path := ProjectSettings.globalize_path(path)
	var file := FileAccess.open(absolute_path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error_code": "read_failed", "message": "无法读取这个开局包。"}
	var byte_count := file.get_length()
	if byte_count <= 0 or byte_count > MAX_SCENARIO_SHARE_FILE_BYTES:
		return {"ok": false, "error_code": "file_too_large", "message": "开局包为空或超过 1 MB 安全上限。"}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {
			"ok": false,
			"error_code": "invalid_json",
			"message": "开局包 JSON 第 %d 行有误：%s" % [parser.get_error_line(), parser.get_error_message()]
		}
	var result := _decode_scenario_share_document(parser.data)
	result["path"] = path
	return result


func _empty_scenario_state() -> Dictionary:
	return {
		"scenario_id": "custom_blank",
		"start_year": null,
		"era_label": "完全自定义",
		"scenario_kind": SCENARIO_KIND_CUSTOM,
		"featured_character_ids": [],
		"history_layer_ids": [],
		"factions": [],
		"character_assignments": [],
		"city_ownership": []
	}


func _legacy_scenario_contract(metadata: Dictionary = {}) -> Dictionary:
	var scenario_source := str(metadata.get("scenario_source", "")).strip_edges()
	if scenario_source == "《三国演义》开篇氛围原型；正史资料仅作 184 年背景参考":
		return {
			"scenario_id": "yellow_turban_184",
			"start_year": 184,
			"era_label": "黄巾起义",
			"scenario_kind": SCENARIO_KIND_HISTORICAL_START,
			"featured_character_ids": ["liu_bei", "guan_yu", "zhang_fei", "zhang_jiao"],
			"history_layer_ids": ["context_184"],
			"city_ownership": []
		}
	return {
		"scenario_id": "custom_blank",
		"start_year": null,
		"era_label": "完全自定义",
		"scenario_kind": SCENARIO_KIND_CUSTOM,
		"featured_character_ids": [],
		"history_layer_ids": [],
		"city_ownership": []
	}


func _decode_scenario_state(
	value: Variant,
	allow_missing_colors := true,
	require_canonical_colors := false,
	legacy_contract: Dictionary = {}
) -> Dictionary:
	if not (value is Dictionary):
		return {"ok": false, "message": "玩法势力状态不是对象。"}
	var raw: Dictionary = (value as Dictionary).duplicate(true)
	var contract_keys := [
		"scenario_id", "start_year", "era_label", "scenario_kind",
		"featured_character_ids", "history_layer_ids", "city_ownership"
	]
	var missing_contract := false
	for contract_key in contract_keys:
		if not raw.has(contract_key):
			missing_contract = true
			break
	if missing_contract:
		if legacy_contract.is_empty():
			return {"ok": false, "message": "玩法势力状态缺少稳定剧本身份。"}
		for contract_key in contract_keys:
			if not legacy_contract.has(contract_key):
				return {"ok": false, "message": "旧版玩法势力状态缺少迁移契约。"}
			raw[contract_key] = legacy_contract.get(contract_key)
	for key in raw.keys():
		if str(key) not in [
			"scenario_id", "start_year", "era_label", "scenario_kind",
			"featured_character_ids", "history_layer_ids",
			"factions", "character_assignments", "city_ownership"
		]:
			return {"ok": false, "message": "玩法势力状态含未定义字段：%s。" % str(key)}
	var scenario_id := str(raw.get("scenario_id", "")).strip_edges()
	var era_label_raw := str(raw.get("era_label", ""))
	var era_label := _sanitize_single_line(era_label_raw, 24, "")
	var scenario_kind := str(raw.get("scenario_kind", "")).strip_edges()
	var start_year_value: Variant = raw.get("start_year", null)
	var start_year: Variant = null
	if not _is_safe_record_id(scenario_id):
		return {"ok": false, "message": "剧本 ID 无效。"}
	if era_label.is_empty() or era_label != era_label_raw:
		return {"ok": false, "message": "时代标签为空或含无效字符。"}
	if scenario_kind not in SCENARIO_KINDS:
		return {"ok": false, "message": "剧本类型无效。"}
	if scenario_kind == SCENARIO_KIND_CUSTOM:
		if start_year_value != null:
			return {"ok": false, "message": "自定义沙盘不应声明固定起始年份。"}
	elif not _is_integer_number(start_year_value) or int(start_year_value) < 1 or int(start_year_value) > 9999:
		return {"ok": false, "message": "历史开局必须声明有效起始年份。"}
	else:
		start_year = int(start_year_value)
	var featured_values: Variant = raw.get("featured_character_ids", null)
	var history_layer_values: Variant = raw.get("history_layer_ids", null)
	if not (featured_values is Array) or not (history_layer_values is Array):
		return {"ok": false, "message": "剧本人物与历史图层必须使用数组。"}
	if (featured_values as Array).size() > characters.size():
		return {"ok": false, "message": "剧本重点人物超过安全上限。"}
	var decoded_featured: Array[String] = []
	var seen_featured := {}
	for character_id_value in featured_values:
		var featured_id := str(character_id_value).strip_edges()
		if not _has_character_id(featured_id) or seen_featured.has(featured_id):
			return {"ok": false, "message": "剧本重点人物引用未知或重复人物。"}
		seen_featured[featured_id] = true
		decoded_featured.append(featured_id)
	var decoded_history_layers: Array[String] = []
	var seen_history_layers := {}
	for layer_id_value in history_layer_values:
		var layer_id := str(layer_id_value).strip_edges()
		if not _has_historical_context_layer_id(layer_id) or seen_history_layers.has(layer_id):
			return {"ok": false, "message": "剧本引用未知或重复历史图层。"}
		seen_history_layers[layer_id] = true
		decoded_history_layers.append(layer_id)
	var faction_values: Variant = raw.get("factions", null)
	var assignment_values: Variant = raw.get("character_assignments", null)
	var ownership_values: Variant = raw.get("city_ownership", null)
	if not (faction_values is Array) or not (assignment_values is Array) or not (ownership_values is Array):
		return {"ok": false, "message": "玩法势力状态缺少完整数组。"}
	if (faction_values as Array).size() > SCENARIO_FACTION_LIMIT:
		return {"ok": false, "message": "玩法势力数量超过安全上限。"}
	var decoded_factions: Array[Dictionary] = []
	var seen_factions: Dictionary = {}
	var seen_names: Dictionary = {}
	var member_counts: Dictionary = {}
	var color_migration_required := false
	for index in range((faction_values as Array).size()):
		var faction_value: Variant = (faction_values as Array)[index]
		if not (faction_value is Dictionary):
			return {"ok": false, "message": "第 %d 个玩法势力不是对象。" % (index + 1)}
		var faction: Dictionary = faction_value
		for key in faction.keys():
			if str(key) not in ["id", "name", "color"]:
				return {"ok": false, "message": "玩法势力含未定义字段：%s。" % str(key)}
		var faction_id := str(faction.get("id", "")).strip_edges()
		var faction_name := _sanitize_single_line(str(faction.get("name", "")), 24, "")
		var raw_color := str(faction.get("color", ""))
		var faction_color := FactionPaletteScript.normalize_hex(raw_color)
		if raw_color.is_empty():
			if not allow_missing_colors:
				return {"ok": false, "message": "玩法势力缺少 #RRGGBB 标识色。"}
			faction_color = FactionPaletteScript.default_hex(index)
			color_migration_required = true
		elif faction_color.is_empty():
			return {"ok": false, "message": "玩法势力颜色必须是 #RRGGBB。"}
		elif raw_color != faction_color:
			if require_canonical_colors:
				return {"ok": false, "message": "玩法势力颜色必须使用大写 #RRGGBB。"}
			color_migration_required = true
		if not faction_id.begins_with("play_") or not _is_safe_record_id(faction_id) or seen_factions.has(faction_id):
			return {"ok": false, "message": "玩法势力 ID 无效或重复。"}
		if faction_name.is_empty() or seen_names.has(faction_name):
			return {"ok": false, "message": "玩法势力名称为空或重复。"}
		seen_factions[faction_id] = true
		seen_names[faction_name] = true
		member_counts[faction_id] = 0
		decoded_factions.append({"id": faction_id, "name": faction_name, "color": faction_color})
	var decoded_assignments: Array[Dictionary] = []
	var seen_assignments: Dictionary = {}
	if (assignment_values as Array).size() > maxi(1, characters.size()) * 2:
		return {"ok": false, "message": "人物玩法分组超过安全上限。"}
	for index in range((assignment_values as Array).size()):
		var assignment_value: Variant = (assignment_values as Array)[index]
		if not (assignment_value is Dictionary):
			return {"ok": false, "message": "第 %d 个人物玩法分组不是对象。" % (index + 1)}
		var assignment: Dictionary = assignment_value
		for key in assignment.keys():
			if str(key) not in ["character_id", "faction_id"]:
				return {"ok": false, "message": "人物玩法分组含未定义字段：%s。" % str(key)}
		var character_id := str(assignment.get("character_id", "")).strip_edges()
		var faction_id := str(assignment.get("faction_id", "")).strip_edges()
		if not _has_character_id(character_id) or seen_assignments.has(character_id):
			return {"ok": false, "message": "人物玩法分组引用未知或重复人物。"}
		if not seen_factions.has(faction_id):
			return {"ok": false, "message": "人物玩法分组引用未知玩法势力。"}
		seen_assignments[character_id] = true
		member_counts[faction_id] = int(member_counts[faction_id]) + 1
		decoded_assignments.append({"character_id": character_id, "faction_id": faction_id})
	for faction_id in member_counts:
		if int(member_counts[faction_id]) <= 0:
			return {"ok": false, "message": "玩法势力必须至少包含一位人物。"}
	if (ownership_values as Array).size() > places.size():
		return {"ok": false, "message": "城池归属数量超过地图地点上限。"}
	var decoded_city_ownership: Array[Dictionary] = []
	var seen_owned_places := {}
	for index in range((ownership_values as Array).size()):
		var ownership_value: Variant = (ownership_values as Array)[index]
		if not (ownership_value is Dictionary):
			return {"ok": false, "message": "第 %d 条城池归属不是对象。" % (index + 1)}
		var ownership: Dictionary = ownership_value
		if ownership.size() != 2:
			return {"ok": false, "message": "城池归属字段不完整或含未定义字段。"}
		for key in ownership.keys():
			if str(key) not in ["place_id", "faction_id"]:
				return {"ok": false, "message": "城池归属含未定义字段：%s。" % str(key)}
		var place_id := str(ownership.get("place_id", "")).strip_edges()
		var faction_id := str(ownership.get("faction_id", "")).strip_edges()
		var place := _find_place(place_id)
		if place.is_empty() or str(place.get("type", "")) not in ASSIGNABLE_PLACE_TYPES or seen_owned_places.has(place_id):
			return {"ok": false, "message": "城池归属引用未知、不可分配或重复地点。"}
		if not seen_factions.has(faction_id):
			return {"ok": false, "message": "城池归属引用未知玩法势力。"}
		seen_owned_places[place_id] = true
		decoded_city_ownership.append({"place_id": place_id, "faction_id": faction_id})
	return {
		"ok": true,
		"color_migration_required": color_migration_required,
		"scenario_state": {
			"scenario_id": scenario_id,
			"start_year": start_year,
			"era_label": era_label,
			"scenario_kind": scenario_kind,
			"featured_character_ids": decoded_featured,
			"history_layer_ids": decoded_history_layers,
			"factions": decoded_factions,
			"character_assignments": decoded_assignments,
			"city_ownership": decoded_city_ownership
		}
	}


func _scenario_states_match(first: Dictionary, second: Dictionary) -> bool:
	for key in ["scenario_id", "start_year", "era_label", "scenario_kind"]:
		if first.get(key, null) != second.get(key, null):
			return false
	for key in ["featured_character_ids", "history_layer_ids"]:
		var first_values: Array = first.get(key, [])
		var second_values: Array = second.get(key, [])
		var first_sorted := first_values.duplicate()
		var second_sorted := second_values.duplicate()
		first_sorted.sort()
		second_sorted.sort()
		if first_sorted != second_sorted:
			return false
	var first_factions_value: Variant = first.get("factions", null)
	var second_factions_value: Variant = second.get("factions", null)
	var first_assignments_value: Variant = first.get("character_assignments", null)
	var second_assignments_value: Variant = second.get("character_assignments", null)
	if not (first_factions_value is Array) or not (second_factions_value is Array) or not (first_assignments_value is Array) or not (second_assignments_value is Array):
		return false
	var first_factions: Dictionary = {}
	var second_factions: Dictionary = {}
	for faction_value in first_factions_value:
		if not (faction_value is Dictionary):
			return false
		first_factions[str(faction_value.get("id", ""))] = {
			"name": str(faction_value.get("name", "")),
			"color": str(faction_value.get("color", ""))
		}
	for faction_value in second_factions_value:
		if not (faction_value is Dictionary):
			return false
		second_factions[str(faction_value.get("id", ""))] = {
			"name": str(faction_value.get("name", "")),
			"color": str(faction_value.get("color", ""))
		}
	var first_assignments: Dictionary = {}
	var second_assignments: Dictionary = {}
	for assignment_value in first_assignments_value:
		if not (assignment_value is Dictionary):
			return false
		first_assignments[str(assignment_value.get("character_id", ""))] = str(assignment_value.get("faction_id", ""))
	for assignment_value in second_assignments_value:
		if not (assignment_value is Dictionary):
			return false
		second_assignments[str(assignment_value.get("character_id", ""))] = str(assignment_value.get("faction_id", ""))
	var first_ownership: Dictionary = {}
	var second_ownership: Dictionary = {}
	for ownership_value in first.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			return false
		first_ownership[str(ownership_value.get("place_id", ""))] = str(ownership_value.get("faction_id", ""))
	for ownership_value in second.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			return false
		second_ownership[str(ownership_value.get("place_id", ""))] = str(ownership_value.get("faction_id", ""))
	return (
		first_factions == second_factions
		and first_assignments == second_assignments
		and first_ownership == second_ownership
	)


func _has_historical_context_layer_id(layer_id: String) -> bool:
	if layer_id.is_empty():
		return false
	for layer_value in historical_context_layers:
		if layer_value is Dictionary and str((layer_value as Dictionary).get("id", "")) == layer_id:
			return true
	return false


func _character_states_payload_for(states: Dictionary) -> Dictionary:
	var records: Array[Dictionary] = []
	var character_ids := states.keys()
	character_ids.sort()
	for character_id_value in character_ids:
		var character_id := str(character_id_value)
		var state_value: Variant = states.get(character_id, null)
		if not (state_value is Dictionary):
			records.append({"character_id": character_id, "state_schema": null})
			continue
		var state: Dictionary = state_value
		var state_schema := str(state.get("state_schema", ""))
		if state_schema == CHARACTER_STATE_SCHEMA_FOUR_DIMENSIONS:
			records.append({
				"character_id": character_id,
				"state_schema": CHARACTER_STATE_SCHEMA_FOUR_DIMENSIONS,
				"might": state.get("might", null),
				"intelligence": state.get("intelligence", null),
				"leadership": state.get("leadership", null),
				"charisma": state.get("charisma", null)
			})
		elif state_schema == CHARACTER_STATE_SCHEMA_LEGACY_V8_COMBAT:
			records.append({
				"character_id": character_id,
				"state_schema": CHARACTER_STATE_SCHEMA_LEGACY_V8_COMBAT,
				"attack": state.get("attack", null),
				"defense": state.get("defense", null)
			})
		else:
			records.append({"character_id": character_id, "state_schema": state.get("state_schema", null)})
	return {
		"semantic_layer": CHARACTER_STATE_SEMANTIC_LAYER,
		"verification_status": CHARACTER_STATE_VERIFICATION_STATUS,
		"records": records
	}


func _decode_character_states_v8(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return {"ok": false, "message": "旧版本局攻防结构无效。"}
	var raw: Dictionary = value
	var allowed_root_keys := {"semantic_layer": true, "verification_status": true, "records": true}
	if raw.size() != allowed_root_keys.size():
		return {"ok": false, "message": "旧版本局攻防包含未定义字段或缺少必要字段。"}
	for key in raw.keys():
		if not allowed_root_keys.has(str(key)):
			return {"ok": false, "message": "旧版本局攻防包含未定义字段：%s。" % str(key)}
	if str(raw.get("semantic_layer", "")) != CHARACTER_STATE_SEMANTIC_LAYER or str(raw.get("verification_status", "")) != CHARACTER_STATE_VERIFICATION_STATUS:
		return {"ok": false, "message": "旧版本局攻防的玩家创作边界无效。"}
	var records_value: Variant = raw.get("records", null)
	if not (records_value is Array):
		return {"ok": false, "message": "旧版本局攻防记录不是数组。"}
	if (records_value as Array).size() > maxi(1, characters.size()):
		return {"ok": false, "message": "旧版本局攻防记录超过人物数量上限。"}
	var decoded: Dictionary = {}
	for index in range((records_value as Array).size()):
		var record_value: Variant = (records_value as Array)[index]
		if not (record_value is Dictionary):
			return {"ok": false, "message": "第 %d 条旧版本局攻防不是对象。" % (index + 1)}
		var record: Dictionary = record_value
		var allowed_record_keys := {"character_id": true, "attack": true, "defense": true}
		if record.size() != allowed_record_keys.size():
			return {"ok": false, "message": "第 %d 条旧版本局攻防字段不完整。" % (index + 1)}
		for key in record.keys():
			if not allowed_record_keys.has(str(key)):
				return {"ok": false, "message": "旧版本局攻防包含未定义字段：%s。" % str(key)}
		var character_id := str(record.get("character_id", "")).strip_edges()
		if not _has_character_id(character_id) or decoded.has(character_id):
			return {"ok": false, "message": "旧版本局攻防引用未知或重复人物。"}
		var attack_value: Variant = record.get("attack", null)
		var defense_value: Variant = record.get("defense", null)
		if not _is_integer_number(attack_value) or not _is_integer_number(defense_value):
			return {"ok": false, "message": "%s 的旧版攻击／防御必须是整数。" % _character_name(character_id)}
		var attack := int(attack_value)
		var defense := int(defense_value)
		if attack < CHARACTER_ATTRIBUTE_MIN or attack > CHARACTER_ATTRIBUTE_MAX or defense < CHARACTER_ATTRIBUTE_MIN or defense > CHARACTER_ATTRIBUTE_MAX:
			return {"ok": false, "message": "%s 的旧版攻击／防御必须在 %d—%d 之间。" % [_character_name(character_id), CHARACTER_ATTRIBUTE_MIN, CHARACTER_ATTRIBUTE_MAX]}
		decoded[character_id] = {
			"state_schema": CHARACTER_STATE_SCHEMA_LEGACY_V8_COMBAT,
			"attack": attack,
			"defense": defense
		}
	return {"ok": true, "character_states": decoded}


func _decode_character_states(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return {"ok": false, "message": "本局人物资料调整结构无效。"}
	var raw: Dictionary = value
	var allowed_root_keys := {"semantic_layer": true, "verification_status": true, "records": true}
	if raw.size() != allowed_root_keys.size():
		return {"ok": false, "message": "本局人物资料调整包含未定义字段或缺少必要字段。"}
	for key in raw.keys():
		if not allowed_root_keys.has(str(key)):
			return {"ok": false, "message": "本局人物资料调整包含未定义字段：%s。" % str(key)}
	if str(raw.get("semantic_layer", "")) != CHARACTER_STATE_SEMANTIC_LAYER or str(raw.get("verification_status", "")) != CHARACTER_STATE_VERIFICATION_STATUS:
		return {"ok": false, "message": "本局人物资料调整的玩家创作边界无效。"}
	var records_value: Variant = raw.get("records", null)
	if not (records_value is Array):
		return {"ok": false, "message": "本局人物资料调整记录不是数组。"}
	if (records_value as Array).size() > maxi(1, characters.size()):
		return {"ok": false, "message": "本局人物资料调整记录超过人物数量上限。"}
	var decoded: Dictionary = {}
	for index in range((records_value as Array).size()):
		var record_value: Variant = (records_value as Array)[index]
		if not (record_value is Dictionary):
			return {"ok": false, "message": "第 %d 条本局人物资料调整不是对象。" % (index + 1)}
		var record: Dictionary = record_value
		var character_id := str(record.get("character_id", "")).strip_edges()
		if not _has_character_id(character_id) or decoded.has(character_id):
			return {"ok": false, "message": "本局人物资料调整引用未知或重复人物。"}
		var state_schema := str(record.get("state_schema", "")).strip_edges()
		var allowed_record_keys: Dictionary
		var decoded_record := {"state_schema": state_schema}
		if state_schema == CHARACTER_STATE_SCHEMA_FOUR_DIMENSIONS:
			allowed_record_keys = {
				"character_id": true,
				"state_schema": true,
				"might": true,
				"intelligence": true,
				"leadership": true,
				"charisma": true
			}
			for field in CHARACTER_ATTRIBUTE_FIELDS:
				var field_value: Variant = record.get(field, null)
				if not _is_integer_number(field_value):
					return {"ok": false, "message": "%s 的%s必须是整数。" % [_character_name(character_id), _character_attribute_label(field)]}
				var number := int(field_value)
				if number < CHARACTER_ATTRIBUTE_MIN or number > CHARACTER_ATTRIBUTE_MAX:
					return {"ok": false, "message": "%s 的%s必须在 %d—%d 之间。" % [_character_name(character_id), _character_attribute_label(field), CHARACTER_ATTRIBUTE_MIN, CHARACTER_ATTRIBUTE_MAX]}
				decoded_record[field] = number
		elif state_schema == CHARACTER_STATE_SCHEMA_LEGACY_V8_COMBAT:
			allowed_record_keys = {
				"character_id": true,
				"state_schema": true,
				"attack": true,
				"defense": true
			}
			var attack_value: Variant = record.get("attack", null)
			var defense_value: Variant = record.get("defense", null)
			if not _is_integer_number(attack_value) or not _is_integer_number(defense_value):
				return {"ok": false, "message": "%s 的旧版攻击／防御必须是整数。" % _character_name(character_id)}
			var attack := int(attack_value)
			var defense := int(defense_value)
			if attack < CHARACTER_ATTRIBUTE_MIN or attack > CHARACTER_ATTRIBUTE_MAX or defense < CHARACTER_ATTRIBUTE_MIN or defense > CHARACTER_ATTRIBUTE_MAX:
				return {"ok": false, "message": "%s 的旧版攻击／防御必须在 %d—%d 之间。" % [_character_name(character_id), CHARACTER_ATTRIBUTE_MIN, CHARACTER_ATTRIBUTE_MAX]}
			decoded_record["attack"] = attack
			decoded_record["defense"] = defense
		else:
			return {"ok": false, "message": "%s 的人物资料调整类型不受支持。" % _character_name(character_id)}
		if record.size() != allowed_record_keys.size():
			return {"ok": false, "message": "第 %d 条本局人物资料调整字段不完整或含未定义字段。" % (index + 1)}
		for key in record.keys():
			if not allowed_record_keys.has(str(key)):
				return {"ok": false, "message": "本局人物资料调整包含未定义字段：%s。" % str(key)}
		decoded[character_id] = decoded_record
	return {"ok": true, "character_states": decoded}


func _character_states_match(first: Dictionary, second: Dictionary) -> bool:
	return first == second


func _character_actions_payload_for(actions: Dictionary) -> Dictionary:
	var records: Array[Dictionary] = []
	var character_ids := actions.keys()
	character_ids.sort()
	for character_id_value in character_ids:
		var character_id := str(character_id_value)
		records.append({
			"character_id": character_id,
			"action": actions.get(character_id, null)
		})
	return {
		"semantic_layer": CHARACTER_ACTION_SEMANTIC_LAYER,
		"verification_status": CHARACTER_ACTION_VERIFICATION_STATUS,
		"records": records
	}


func _decode_character_actions(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return {"ok": false, "message": "人物行动状态结构无效。"}
	var raw: Dictionary = value
	var allowed_root_keys := {"semantic_layer": true, "verification_status": true, "records": true}
	if raw.size() != allowed_root_keys.size():
		return {"ok": false, "message": "人物行动状态包含未定义字段或缺少必要字段。"}
	for key in raw.keys():
		if not allowed_root_keys.has(str(key)):
			return {"ok": false, "message": "人物行动状态包含未定义字段：%s。" % str(key)}
	if str(raw.get("semantic_layer", "")) != CHARACTER_ACTION_SEMANTIC_LAYER \
		or str(raw.get("verification_status", "")) != CHARACTER_ACTION_VERIFICATION_STATUS:
		return {"ok": false, "message": "人物行动状态的玩家创作边界无效。"}
	var records_value: Variant = raw.get("records", null)
	if not (records_value is Array):
		return {"ok": false, "message": "人物行动状态记录不是数组。"}
	if (records_value as Array).size() > maxi(1, characters.size()):
		return {"ok": false, "message": "人物行动状态超过人物数量上限。"}
	var decoded: Dictionary = {}
	for index in range((records_value as Array).size()):
		var record_value: Variant = (records_value as Array)[index]
		if not (record_value is Dictionary):
			return {"ok": false, "message": "第 %d 条人物行动状态不是对象。" % (index + 1)}
		var record: Dictionary = record_value
		var allowed_record_keys := {"character_id": true, "action": true}
		if record.size() != allowed_record_keys.size():
			return {"ok": false, "message": "第 %d 条人物行动状态字段不完整或含未定义字段。" % (index + 1)}
		for key in record.keys():
			if not allowed_record_keys.has(str(key)):
				return {"ok": false, "message": "人物行动状态包含未定义字段：%s。" % str(key)}
		var character_id := str(record.get("character_id", "")).strip_edges()
		if not _has_character_id(character_id) or decoded.has(character_id):
			return {"ok": false, "message": "人物行动状态引用未知或重复人物。"}
		var action_value: Variant = record.get("action", null)
		if typeof(action_value) != TYPE_STRING or not CharacterActionPolicyScript.is_stored_action(str(action_value)):
			return {"ok": false, "message": "%s 的行动状态无效；待命是默认状态，不写入记录。" % _character_name(character_id)}
		decoded[character_id] = str(action_value)
	return {"ok": true, "character_actions": decoded}


func _character_actions_match(first: Dictionary, second: Dictionary) -> bool:
	return first == second


func _character_troops_payload_for(troops: Dictionary) -> Dictionary:
	var records: Array[Dictionary] = []
	var character_ids := troops.keys()
	character_ids.sort()
	for character_id_value in character_ids:
		var character_id := str(character_id_value)
		var troop_count := int(troops.get(character_id, CHARACTER_TROOP_DEFAULT))
		if troop_count == CHARACTER_TROOP_DEFAULT:
			continue
		records.append({
			"character_id": character_id,
			"troop_count": troop_count
		})
	return {
		"schema_version": CHARACTER_TROOP_SCHEMA_VERSION,
		"semantic_layer": CHARACTER_TROOP_SEMANTIC_LAYER,
		"verification_status": CHARACTER_TROOP_VERIFICATION_STATUS,
		"default_troop_count": CHARACTER_TROOP_DEFAULT,
		"records": records
	}


func _decode_character_troops(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return {"ok": false, "message": "人物兵力结构无效。"}
	var raw: Dictionary = value
	var allowed_root_keys := {
		"schema_version": true,
		"semantic_layer": true,
		"verification_status": true,
		"default_troop_count": true,
		"records": true
	}
	if raw.size() != allowed_root_keys.size():
		return {"ok": false, "message": "人物兵力包含未定义字段或缺少必要字段。"}
	for key in raw.keys():
		if not allowed_root_keys.has(str(key)):
			return {"ok": false, "message": "人物兵力包含未定义字段：%s。" % str(key)}
	if (
		int(raw.get("schema_version", 0)) != CHARACTER_TROOP_SCHEMA_VERSION
		or str(raw.get("semantic_layer", "")) != CHARACTER_TROOP_SEMANTIC_LAYER
		or str(raw.get("verification_status", "")) != CHARACTER_TROOP_VERIFICATION_STATUS
		or not _is_integer_number(raw.get("default_troop_count", null))
		or int(raw.get("default_troop_count", -1)) != CHARACTER_TROOP_DEFAULT
	):
		return {"ok": false, "message": "人物兵力的数据边界或默认值无效。"}
	var records_value: Variant = raw.get("records", null)
	if not (records_value is Array):
		return {"ok": false, "message": "人物兵力记录不是数组。"}
	if (records_value as Array).size() > maxi(1, characters.size()):
		return {"ok": false, "message": "人物兵力记录超过人物数量上限。"}
	var decoded: Dictionary = {}
	for index in range((records_value as Array).size()):
		var record_value: Variant = (records_value as Array)[index]
		if not (record_value is Dictionary):
			return {"ok": false, "message": "第 %d 条人物兵力记录不是对象。" % (index + 1)}
		var record: Dictionary = record_value
		var allowed_record_keys := {"character_id": true, "troop_count": true}
		if record.size() != allowed_record_keys.size():
			return {"ok": false, "message": "第 %d 条人物兵力记录字段不完整或含未定义字段。" % (index + 1)}
		for key in record.keys():
			if not allowed_record_keys.has(str(key)):
				return {"ok": false, "message": "人物兵力记录包含未定义字段：%s。" % str(key)}
		var character_id := str(record.get("character_id", "")).strip_edges()
		var troop_value: Variant = record.get("troop_count", null)
		if not _has_character_id(character_id) or decoded.has(character_id):
			return {"ok": false, "message": "人物兵力引用未知或重复人物。"}
		if not _is_integer_number(troop_value):
			return {"ok": false, "message": "%s 的兵力必须是整数。" % _character_name(character_id)}
		var troop_count := int(troop_value)
		if troop_count < CHARACTER_TROOP_MIN or troop_count > CHARACTER_TROOP_MAX:
			return {"ok": false, "message": "%s 的兵力超出 0—999999。" % _character_name(character_id)}
		if troop_count == CHARACTER_TROOP_DEFAULT:
			return {"ok": false, "message": "%s 使用默认兵力 1000 时不应写入覆盖记录。" % _character_name(character_id)}
		decoded[character_id] = troop_count
	return {"ok": true, "character_troops": decoded}


func _character_troops_match(first: Dictionary, second: Dictionary) -> bool:
	return first == second


func _effective_character_troop_count(character_id: String) -> int:
	return int(character_troops.get(character_id, CHARACTER_TROOP_DEFAULT))


func _effective_character_action(character_id: String) -> String:
	return str(character_actions.get(character_id, CHARACTER_ACTION_STANDBY))


func _character_action_label(action: String) -> String:
	return CharacterActionPolicyScript.label(action)


func _effective_character_attributes(character_id: String) -> Dictionary:
	var baseline: Dictionary = character_display_attributes_by_id.get(character_id, {}).duplicate(true)
	var state: Dictionary = character_states.get(character_id, {})
	if str(state.get("state_schema", "")) == CHARACTER_STATE_SCHEMA_FOUR_DIMENSIONS:
		for field in CHARACTER_ATTRIBUTE_FIELDS:
			baseline[field] = int(state.get(field, baseline.get(field, CHARACTER_ATTRIBUTE_EDITOR_INITIAL)))
		baseline["source"] = "player_override"
	else:
		baseline["source"] = "project_default"
	if str(state.get("state_schema", "")) == CHARACTER_STATE_SCHEMA_LEGACY_V8_COMBAT:
		baseline["legacy_attack"] = int(state.get("attack", 0))
		baseline["legacy_defense"] = int(state.get("defense", 0))
	return baseline


func _display_character_attributes() -> Dictionary:
	var result: Dictionary = {}
	for character_value in characters:
		if not (character_value is Dictionary):
			continue
		var character_id := str((character_value as Dictionary).get("id", ""))
		if not character_id.is_empty():
			result[character_id] = _effective_character_attributes(character_id)
	return result


func _empty_chronicle() -> Dictionary:
	return {
		"semantic_layer": CHRONICLE_SEMANTIC_LAYER,
		"verification_status": CHRONICLE_VERIFICATION_STATUS,
		"entries": []
	}


func _chronicle_payload_for(entries: Array) -> Dictionary:
	return {
		"semantic_layer": CHRONICLE_SEMANTIC_LAYER,
		"verification_status": CHRONICLE_VERIFICATION_STATUS,
		"entries": entries.duplicate(true)
	}


func _chronicle_type_label(entry_type: String) -> String:
	match entry_type:
		"battle":
			return "战役"
		"reinforcement":
			return "援军"
		"plot":
			return "架空剧情"
		_:
			return "随记"


func _decode_chronicle(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return {"ok": false, "message": "玩家纪事结构无效。"}
	var raw: Dictionary = value
	var allowed_root_keys := {"semantic_layer": true, "verification_status": true, "entries": true}
	if raw.size() != allowed_root_keys.size():
		return {"ok": false, "message": "玩家纪事包含未定义字段或缺少必要字段。"}
	for key in raw.keys():
		if not allowed_root_keys.has(str(key)):
			return {"ok": false, "message": "玩家纪事包含未定义字段：%s。" % str(key)}
	if typeof(raw.get("semantic_layer", null)) != TYPE_STRING or str(raw.get("semantic_layer", "")) != CHRONICLE_SEMANTIC_LAYER:
		return {"ok": false, "message": "玩家纪事语义层无效。"}
	if typeof(raw.get("verification_status", null)) != TYPE_STRING or str(raw.get("verification_status", "")) != CHRONICLE_VERIFICATION_STATUS:
		return {"ok": false, "message": "玩家纪事核验状态无效。"}
	var entries_value: Variant = raw.get("entries", null)
	if not (entries_value is Array):
		return {"ok": false, "message": "玩家纪事条目结构无效。"}
	if entries_value.size() > CHRONICLE_ENTRY_LIMIT:
		return {"ok": false, "message": "玩家纪事超过 %d 条安全上限。" % CHRONICLE_ENTRY_LIMIT}
	var allowed_entry_keys := {
		"id": true, "entry_type": true, "title": true, "time_label": true,
		"body": true, "created_at": true, "updated_at": true
	}
	var seen_ids: Dictionary = {}
	var decoded_entries: Array[Dictionary] = []
	for index in range(entries_value.size()):
		var entry_value: Variant = entries_value[index]
		if not (entry_value is Dictionary):
			return {"ok": false, "message": "第 %d 则玩家纪事不是有效对象。" % (index + 1)}
		var entry: Dictionary = entry_value
		if entry.size() != allowed_entry_keys.size():
			return {"ok": false, "message": "第 %d 则玩家纪事包含未定义字段或缺少必要字段。" % (index + 1)}
		for key in entry.keys():
			if not allowed_entry_keys.has(str(key)):
				return {"ok": false, "message": "第 %d 则玩家纪事包含未定义字段：%s。" % [index + 1, str(key)]}
		for key in allowed_entry_keys.keys():
			if typeof(entry.get(key, null)) != TYPE_STRING:
				return {"ok": false, "message": "第 %d 则玩家纪事字段 %s 不是文字。" % [index + 1, str(key)]}
		var entry_id := str(entry.get("id", ""))
		if not entry_id.begins_with("chron_") or not _is_safe_record_id(entry_id) or seen_ids.has(entry_id):
			return {"ok": false, "message": "玩家纪事 ID 无效或重复。"}
		var entry_type := str(entry.get("entry_type", ""))
		if entry_type not in CHRONICLE_ENTRY_TYPES:
			return {"ok": false, "message": "第 %d 则玩家纪事类型无效。" % (index + 1)}
		var title := str(entry.get("title", ""))
		var time_label := str(entry.get("time_label", ""))
		var body := str(entry.get("body", ""))
		var created_at := str(entry.get("created_at", ""))
		var updated_at := str(entry.get("updated_at", ""))
		if title != _sanitize_single_line(title, MAX_CHRONICLE_TITLE_LENGTH, "") or title.is_empty():
			return {"ok": false, "message": "第 %d 则玩家纪事标题为空、过长或不是规范单行文字。" % (index + 1)}
		if time_label != _sanitize_single_line(time_label, MAX_CHRONICLE_TIME_LABEL_LENGTH, ""):
			return {"ok": false, "message": "第 %d 则玩家纪事时间标签过长或不是规范单行文字。" % (index + 1)}
		if body != _sanitize_multiline(body, MAX_CHRONICLE_BODY_LENGTH):
			return {"ok": false, "message": "第 %d 则玩家纪事正文过长或格式无效。" % (index + 1)}
		if created_at.is_empty() or created_at.length() > 40 or created_at != _sanitize_single_line(created_at, 40, ""):
			return {"ok": false, "message": "第 %d 则玩家纪事创建时间无效。" % (index + 1)}
		if updated_at.is_empty() or updated_at.length() > 40 or updated_at != _sanitize_single_line(updated_at, 40, ""):
			return {"ok": false, "message": "第 %d 则玩家纪事修改时间无效。" % (index + 1)}
		seen_ids[entry_id] = true
		decoded_entries.append({
			"id": entry_id,
			"entry_type": entry_type,
			"title": title,
			"time_label": time_label,
			"body": body,
			"created_at": created_at,
			"updated_at": updated_at
		})
	return {"ok": true, "chronicle_entries": decoded_entries}


func _chronicle_entries_match(first: Array, second: Array) -> bool:
	return first == second


func _player_strokes_payload_for(strokes_value: Array) -> Dictionary:
	var saved_strokes: Array[Dictionary] = []
	for stroke_value in strokes_value:
		if not (stroke_value is Dictionary):
			continue
		var stroke: Dictionary = stroke_value
		var saved_points: Array[Dictionary] = []
		for point_value in stroke.get("points", []):
			if point_value is Dictionary:
				saved_points.append({"x": float(point_value.get("x", 0.5)), "y": float(point_value.get("y", 0.5))})
		saved_strokes.append({
			"id": str(stroke.get("id", "")),
			"stroke_type": str(stroke.get("stroke_type", "advance")),
			"label": str(stroke.get("label", "")),
			"points": saved_points,
			"created_at": str(stroke.get("created_at", "")),
			"updated_at": str(stroke.get("updated_at", ""))
		})
	return {
		"semantic_layer": PLAYER_STROKE_SEMANTIC_LAYER,
		"verification_status": PLAYER_STROKE_VERIFICATION_STATUS,
		"strokes": saved_strokes
	}


func _decode_player_strokes(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return {"ok": false, "message": "玩家推演线结构无效。"}
	var raw: Dictionary = value
	var allowed_root_keys := {"semantic_layer": true, "verification_status": true, "strokes": true}
	if raw.size() != allowed_root_keys.size():
		return {"ok": false, "message": "玩家推演线包含未定义字段或缺少必要字段。"}
	for key in raw.keys():
		if not allowed_root_keys.has(str(key)):
			return {"ok": false, "message": "玩家推演线包含未定义字段：%s。" % str(key)}
	if typeof(raw.get("semantic_layer", null)) != TYPE_STRING or str(raw.get("semantic_layer", "")) != PLAYER_STROKE_SEMANTIC_LAYER:
		return {"ok": false, "message": "玩家推演线语义层无效。"}
	if typeof(raw.get("verification_status", null)) != TYPE_STRING or str(raw.get("verification_status", "")) != PLAYER_STROKE_VERIFICATION_STATUS:
		return {"ok": false, "message": "玩家推演线核验状态无效。"}
	var strokes_value: Variant = raw.get("strokes", null)
	if not (strokes_value is Array):
		return {"ok": false, "message": "玩家推演线列表结构无效。"}
	if strokes_value.size() > PLAYER_STROKE_LIMIT:
		return {"ok": false, "message": "玩家推演线超过 %d 条安全上限。" % PLAYER_STROKE_LIMIT}
	var allowed_stroke_keys := {"id": true, "stroke_type": true, "label": true, "points": true, "created_at": true, "updated_at": true}
	var allowed_point_keys := {"x": true, "y": true}
	var seen_ids: Dictionary = {}
	var total_points := 0
	var decoded: Array[Dictionary] = []
	for index in range(strokes_value.size()):
		var stroke_value: Variant = strokes_value[index]
		if not (stroke_value is Dictionary):
			return {"ok": false, "message": "第 %d 条玩家推演线不是有效对象。" % (index + 1)}
		var stroke: Dictionary = stroke_value
		for forbidden_field in PLAYER_STROKE_FORBIDDEN_FIELDS:
			if stroke.has(forbidden_field):
				return {"ok": false, "message": "第 %d 条玩家推演线夹带不允许的运行／史实字段：%s。" % [index + 1, forbidden_field]}
		if stroke.size() != allowed_stroke_keys.size():
			return {"ok": false, "message": "第 %d 条玩家推演线包含未定义字段或缺少必要字段。" % (index + 1)}
		for key in stroke.keys():
			if not allowed_stroke_keys.has(str(key)):
				return {"ok": false, "message": "第 %d 条玩家推演线包含未定义字段：%s。" % [index + 1, str(key)]}
		var stroke_id := str(stroke.get("id", ""))
		if typeof(stroke.get("id", null)) != TYPE_STRING or not stroke_id.begins_with("stroke_") or not _is_safe_record_id(stroke_id) or seen_ids.has(stroke_id):
			return {"ok": false, "message": "玩家推演线 ID 无效或重复。"}
		var stroke_type := str(stroke.get("stroke_type", ""))
		if typeof(stroke.get("stroke_type", null)) != TYPE_STRING or stroke_type not in PLAYER_STROKE_TYPES:
			return {"ok": false, "message": "第 %d 条玩家推演线类型无效。" % (index + 1)}
		var label := str(stroke.get("label", ""))
		if typeof(stroke.get("label", null)) != TYPE_STRING or label != _sanitize_single_line(label, MAX_PLAYER_STROKE_LABEL_LENGTH, ""):
			return {"ok": false, "message": "第 %d 条玩家推演线说明过长或不是规范单行文字。" % (index + 1)}
		var created_at := str(stroke.get("created_at", ""))
		var updated_at := str(stroke.get("updated_at", ""))
		if typeof(stroke.get("created_at", null)) != TYPE_STRING or created_at.is_empty() or created_at != _sanitize_single_line(created_at, 40, ""):
			return {"ok": false, "message": "第 %d 条玩家推演线创建时间无效。" % (index + 1)}
		if typeof(stroke.get("updated_at", null)) != TYPE_STRING or updated_at.is_empty() or updated_at != _sanitize_single_line(updated_at, 40, ""):
			return {"ok": false, "message": "第 %d 条玩家推演线修改时间无效。" % (index + 1)}
		var points_value: Variant = stroke.get("points", null)
		if not (points_value is Array) or points_value.size() < 2 or points_value.size() > PLAYER_STROKE_POINT_LIMIT:
			return {"ok": false, "message": "第 %d 条玩家推演线必须包含 2—%d 个落点。" % [index + 1, PLAYER_STROKE_POINT_LIMIT]}
		total_points += points_value.size()
		if total_points > PLAYER_STROKE_TOTAL_POINT_LIMIT:
			return {"ok": false, "message": "玩家推演线总落点超过 %d 个安全上限。" % PLAYER_STROKE_TOTAL_POINT_LIMIT}
		var decoded_points: Array[Dictionary] = []
		var normalized_length := 0.0
		var previous := Vector2.ZERO
		for point_index in range(points_value.size()):
			var point_value: Variant = points_value[point_index]
			if not (point_value is Dictionary):
				return {"ok": false, "message": "第 %d 条玩家推演线的第 %d 个落点无效。" % [index + 1, point_index + 1]}
			var point: Dictionary = point_value
			if point.size() != allowed_point_keys.size() or not point.has("x") or not point.has("y"):
				return {"ok": false, "message": "第 %d 条玩家推演线的落点字段无效。" % (index + 1)}
			for point_key in point.keys():
				if not allowed_point_keys.has(str(point_key)):
					return {"ok": false, "message": "第 %d 条玩家推演线的落点包含未定义字段。" % (index + 1)}
			if not (typeof(point.get("x", null)) in [TYPE_INT, TYPE_FLOAT]) or not (typeof(point.get("y", null)) in [TYPE_INT, TYPE_FLOAT]):
				return {"ok": false, "message": "第 %d 条玩家推演线的落点坐标不是数字。" % (index + 1)}
			var x := float(point.get("x", 0.5))
			var y := float(point.get("y", 0.5))
			if not is_finite(x) or not is_finite(y) or x < 0.0 or x > 1.0 or y < 0.0 or y > 1.0:
				return {"ok": false, "message": "第 %d 条玩家推演线的落点超出地图范围。" % (index + 1)}
			var decoded_point := Vector2(x, y)
			if point_index > 0:
				normalized_length += previous.distance_to(decoded_point)
			previous = decoded_point
			decoded_points.append({"x": x, "y": y})
		if normalized_length < 0.003:
			return {"ok": false, "message": "第 %d 条玩家推演线过短，无法形成有效方向。" % (index + 1)}
		seen_ids[stroke_id] = true
		decoded.append({
			"id": stroke_id,
			"stroke_type": stroke_type,
			"label": label,
			"points": decoded_points,
			"created_at": created_at,
			"updated_at": updated_at
		})
	return {"ok": true, "player_strokes": decoded}


func _player_strokes_match(first: Array, second: Array) -> bool:
	return first == second


func _find_chronicle_entry(entry_id: String, entries_value: Variant = null) -> Dictionary:
	var entries: Array = chronicle_entries if entries_value == null else entries_value
	for entry_value in entries:
		if entry_value is Dictionary and str((entry_value as Dictionary).get("id", "")) == entry_id:
			return (entry_value as Dictionary).duplicate(true)
	return {}


func _load_json_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_error("缺少数据文件：%s" % path)
		return []
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		return parsed
	push_error("数据文件不是数组：%s" % path)
	return []


func _load_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("缺少数据文件：%s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	push_error("数据文件不是对象：%s" % path)
	return {}


func _primary_last_good_path(path := "") -> String:
	var effective_path := save_path if path.is_empty() else path
	return ProjectSettings.globalize_path(effective_path) + PRIMARY_LAST_GOOD_SUFFIX


func _primary_recovery_candidate_paths(path := "") -> Dictionary:
	var effective_path := save_path if path.is_empty() else path
	var absolute_path := ProjectSettings.globalize_path(effective_path)
	var parent_dir := absolute_path.get_base_dir()
	var base_name := absolute_path.get_file()
	var committed: Array[String] = []
	var uncommitted: Array[String] = []
	var directory := DirAccess.open(parent_dir)
	if directory == null:
		return {
			"ok": false,
			"error_code": "recovery_directory_unreadable",
			"committed": committed,
			"uncommitted": uncommitted,
			"total": 0
		}
	directory.list_dir_begin()
	while true:
		var filename := directory.get_next()
		if filename.is_empty():
			break
		if directory.current_is_dir():
			continue
		if filename == base_name + PRIMARY_LAST_GOOD_SUFFIX:
			committed.append(parent_dir.path_join(filename))
		elif filename.begins_with(base_name + ".replace-") and filename.ends_with(".tmp"):
			committed.append(parent_dir.path_join(filename))
		elif filename.begins_with(base_name + ".write-") and filename.ends_with(".tmp"):
			uncommitted.append(parent_dir.path_join(filename))
	directory.list_dir_end()
	committed.sort()
	uncommitted.sort()
	return {
		"ok": true,
		"error_code": "",
		"committed": committed,
		"uncommitted": uncommitted,
		"total": committed.size() + uncommitted.size()
	}


func _primary_recovery_declared_version(bytes: PackedByteArray) -> int:
	if bytes.is_empty():
		return 0
	var parsed: Variant = JSON.parse_string(bytes.get_string_from_utf8())
	if not (parsed is Dictionary):
		return 0
	var value: Variant = (parsed as Dictionary).get("save_version", null)
	return int(value) if _is_integer_number(value) else 0


func _inspect_primary_recovery_candidate(path: String, kind: String) -> Dictionary:
	var result := {
		"path": path,
		"kind": kind,
		"status": "invalid",
		"sha256": "",
		"byte_count": 0,
		"source_save_version": 0,
		"title": "未命名沙盘",
		"updated_at": "",
		"character_count": 0,
		"message": ""
	}
	if not FileAccess.file_exists(path):
		result["message"] = "候选文件已经不存在。"
		return result
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		result["message"] = "候选文件无法读取。"
		return result
	var byte_count := file.get_length()
	result["byte_count"] = byte_count
	if byte_count <= 0 or byte_count > MAX_IMPORT_FILE_BYTES:
		result["message"] = "候选文件为空或超过安全上限。"
		return result
	var bytes := file.get_buffer(byte_count)
	file = null
	var declared_version := _primary_recovery_declared_version(bytes)
	result["source_save_version"] = declared_version
	result["sha256"] = _sha256_hex(bytes)
	if declared_version > runtime_save_version:
		result["status"] = "future"
		result["message"] = "候选由更新版本创建。"
		return result
	var decoded := _read_sandbox_transfer_file(path, false)
	if not bool(decoded.get("ok", false)):
		result["message"] = str(decoded.get("message", "候选没有通过完整校验。"))
		return result
	if str(decoded.get("source_format", "")) != "raw_save":
		result["message"] = "候选不是本机活动沙盘格式。"
		return result
	result["status"] = "valid"
	result["source_save_version"] = int(decoded.get("source_save_version", declared_version))
	var metadata: Dictionary = decoded.get("sandbox_metadata", {})
	result["title"] = str(metadata.get("title", "未命名沙盘"))
	result["updated_at"] = str(decoded.get("updated_at", ""))
	result["character_count"] = int((decoded.get("placements", {}) as Dictionary).size())
	result["message"] = ""
	return result


func _preferred_primary_recovery_candidate(candidates: Array[Dictionary]) -> Dictionary:
	for candidate in candidates:
		if str(candidate.get("kind", "")) == "last_good":
			return candidate.duplicate(true)
	return candidates[0].duplicate(true) if not candidates.is_empty() else {}


func _inspect_primary_save_recovery(path := "") -> Dictionary:
	var effective_path := save_path if path.is_empty() else path
	var absolute_path := ProjectSettings.globalize_path(effective_path)
	var path_set := _primary_recovery_candidate_paths(effective_path)
	var valid_candidates: Array[Dictionary] = []
	var invalid_candidates: Array[Dictionary] = []
	var future_candidates: Array[Dictionary] = []
	var uncommitted_candidates: Array[Dictionary] = []
	var state := {
		"status": "none",
		"save_path": absolute_path,
		"primary": {},
		"candidate": {},
		"valid_candidates": valid_candidates,
		"invalid_candidates": invalid_candidates,
		"future_candidates": future_candidates,
		"uncommitted_candidates": uncommitted_candidates,
		"candidate_hash_count": 0,
		"artifact_count": int(path_set.get("total", 0)),
		"message": ""
	}
	if not bool(path_set.get("ok", false)):
		state["status"] = "directory_unreadable"
		state["message"] = "无法检查当前沙盘所在文件夹。"
		return state

	var primary: Dictionary
	if FileAccess.file_exists(absolute_path):
		primary = _inspect_primary_recovery_candidate(absolute_path, "primary")
	else:
		primary = {"path": absolute_path, "kind": "primary", "status": "missing"}
	state["primary"] = primary
	if str(primary.get("status", "")) == "valid":
		state["status"] = "primary_valid"
		return state
	if str(primary.get("status", "")) == "future":
		state["status"] = "primary_future"
		state["message"] = "当前沙盘由更新版本创建，已保持原文件并停止写入。"
		return state
	if int(path_set.get("total", 0)) > PRIMARY_RECOVERY_CANDIDATE_LIMIT:
		state["status"] = "too_many"
		state["message"] = "找到过多未完成的保存记录，已停止自动写入。"
		return state

	for candidate_path_value in path_set.get("committed", []):
		var candidate_path := str(candidate_path_value)
		var kind := "last_good" if candidate_path == _primary_last_good_path(effective_path) else "replace"
		var candidate := _inspect_primary_recovery_candidate(candidate_path, kind)
		match str(candidate.get("status", "")):
			"valid":
				valid_candidates.append(candidate)
			"future":
				future_candidates.append(candidate)
			_:
				invalid_candidates.append(candidate)
	for write_path_value in path_set.get("uncommitted", []):
		uncommitted_candidates.append(_inspect_primary_recovery_candidate(str(write_path_value), "write"))
	state["valid_candidates"] = valid_candidates
	state["invalid_candidates"] = invalid_candidates
	state["future_candidates"] = future_candidates
	state["uncommitted_candidates"] = uncommitted_candidates

	var by_hash: Dictionary = {}
	for candidate in valid_candidates:
		var hash := str(candidate.get("sha256", ""))
		if hash.is_empty():
			continue
		if not by_hash.has(hash):
			by_hash[hash] = []
		(by_hash[hash] as Array).append(candidate)
	state["candidate_hash_count"] = by_hash.size()
	if not future_candidates.is_empty():
		state["status"] = "ambiguous_future"
		state["message"] = "找到当前版本无法判断的保存记录，已保持全部文件并停止写入。"
	elif by_hash.size() > 1:
		state["status"] = "ambiguous"
		state["message"] = "找到多份内容不同的可恢复沙盘，已保持全部文件并停止写入。"
	elif by_hash.size() == 1:
		var hash := str(by_hash.keys()[0])
		var same_hash_candidates: Array[Dictionary] = []
		for value in by_hash[hash]:
			same_hash_candidates.append((value as Dictionary).duplicate(true))
		state["status"] = "recoverable"
		state["candidate"] = _preferred_primary_recovery_candidate(same_hash_candidates)
		state["message"] = "找到一份保存前保留的沙盘。"
	elif int(path_set.get("total", 0)) > 0:
		state["status"] = "unavailable"
		state["message"] = "找到未完成的保存记录，但没有一份通过完整校验。"
	return state


func _primary_recovery_can_confirm() -> bool:
	return (
		str(_primary_recovery_state.get("status", "")) == "recoverable"
		and not (_primary_recovery_state.get("candidate", {}) as Dictionary).is_empty()
	)


func _apply_primary_recovery_write_guard() -> void:
	var status := str(_primary_recovery_state.get("status", "none"))
	if status in ["recoverable", "ambiguous", "ambiguous_future", "unavailable", "too_many", "directory_unreadable", "primary_future"]:
		_save_writes_blocked = true
		_save_write_block_reason = str(_primary_recovery_state.get("message", "当前沙盘需要先完成安全检查。"))


func _load_save() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var read_result := _read_sandbox_transfer_file(save_path, false)
	if not bool(read_result.get("ok", false)):
		_save_writes_blocked = true
		_save_write_block_reason = str(read_result.get("message", "现有存档无法安全读取。"))
		if not automated_test_mode:
			push_error("无法读取本机沙盘，已保护原文件不被写回：%s" % _save_write_block_reason)
		return
	_save_writes_blocked = false
	_save_write_block_reason = ""
	_primary_recovery_requires_reload = false
	var next_placements: Dictionary = read_result.get("placements", {}).duplicate(true)
	var next_annotations: Dictionary = read_result.get("annotations", {}).duplicate(true)
	var next_camera: Dictionary = read_result.get("camera", {}).duplicate(true) if bool(read_result.get("camera_valid", false)) else {}
	var next_metadata: Dictionary = read_result.get("sandbox_metadata", {}).duplicate(true)
	var next_scenario_state: Dictionary = read_result.get("scenario_state", _empty_scenario_state()).duplicate(true)
	var next_chronicle_entries: Array[Dictionary] = (read_result.get("chronicle_entries", []) as Array).duplicate(true)
	var next_player_strokes: Array[Dictionary] = (read_result.get("player_strokes", []) as Array).duplicate(true)
	var next_character_states: Dictionary = read_result.get("character_states", {}).duplicate(true)
	var next_character_actions: Dictionary = read_result.get("character_actions", {}).duplicate(true)
	var next_character_troops: Dictionary = read_result.get("character_troops", {}).duplicate(true)
	if bool(read_result.get("metadata_migration_required", false)):
		next_metadata = _new_sandbox_metadata()
	var migration_required := (
		bool(read_result.get("save_version_migration_required", false))
		or bool(read_result.get("metadata_migration_required", false))
		or bool(read_result.get("scenario_color_migration_required", false))
		or bool(read_result.get("chronicle_migration_required", false))
		or bool(read_result.get("player_stroke_migration_required", false))
		or bool(read_result.get("character_state_migration_required", false))
		or bool(read_result.get("character_action_migration_required", false))
		or bool(read_result.get("character_troop_migration_required", false))
		or bool(read_result.get("character_catalog_migration_required", false))
		or bool(read_result.get("geometry_migration_required", false))
	)
	if migration_required:
		var backup_result := _create_raw_migration_backup(
			save_path,
			int(read_result.get("source_save_version", 0)),
			int(read_result.get("source_character_catalog_version", 0))
		)
		if not bool(backup_result.get("ok", false)):
			_save_writes_blocked = true
			_save_write_block_reason = "旧版沙盘迁移前无法建立逐字节备份，原文件已保留且已停止写入。"
		else:
			var migration_result := _write_validated_sandbox_payload_atomic(
				save_path,
				_build_sandbox_payload_for(next_placements, next_annotations, next_camera, next_metadata, next_scenario_state, next_chronicle_entries, next_player_strokes, next_character_states, next_character_actions, next_character_troops),
				true
			)
			if not bool(migration_result.get("ok", false)):
				_save_writes_blocked = true
				_save_write_block_reason = "旧版沙盘迁移无法安全写入，原文件已保留；迁移前备份已经建立。"
	placements = next_placements
	annotations = next_annotations
	loaded_camera = next_camera
	sandbox_metadata = next_metadata
	scenario_state = next_scenario_state
	chronicle_entries = next_chronicle_entries
	player_strokes = next_player_strokes
	character_states = next_character_states
	character_actions = next_character_actions
	character_troops = next_character_troops
	_recalculate_next_annotation_serial()


func _read_sandbox_transfer_file(path: String, external := true) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "error_code": "read_failed", "message": "文件不存在或已经被移动。"}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error_code": "read_failed", "message": "无法读取这个文件，请检查访问权限。"}
	var byte_count := file.get_length()
	if byte_count <= 0:
		return {"ok": false, "error_code": "empty_file", "message": "文件是空的。"}
	if byte_count > MAX_IMPORT_FILE_BYTES:
		return {"ok": false, "error_code": "file_too_large", "message": "文件超过 2 MiB 安全上限。"}
	var text := file.get_as_text()
	var result := _decode_sandbox_text(text, external)
	result["path"] = path
	result["byte_count"] = byte_count
	return result


func _decode_sandbox_text(text: String, external := true) -> Dictionary:
	var parser := JSON.new()
	var error := parser.parse(text)
	if error != OK:
		return {
			"ok": false,
			"error_code": "invalid_json",
			"message": "JSON 格式错误（第 %d 行）：%s" % [parser.get_error_line(), parser.get_error_message()]
		}
	return _decode_sandbox_document(parser.data, external)


func _decode_sandbox_document(document: Variant, external := true) -> Dictionary:
	if not (document is Dictionary):
		return {"ok": false, "error_code": "invalid_root", "message": "文件顶层不是有效的沙盘对象。"}
	var root: Dictionary = document
	var payload: Dictionary
	var source_format := "raw_save"
	var warnings: Array[String] = []
	var exported_at := ""
	var source_snapshot_id := ""
	var source_snapshot_name := ""
	var source_snapshot_sandbox_id := ""
	if root.has("format"):
		if str(root.get("format", "")) != SANDBOX_PACKAGE_FORMAT:
			return {"ok": false, "error_code": "wrong_format", "message": "文件不是三国推演志沙盘备份。"}
		var allowed_backup_root_keys := {
			"format": true, "format_version": true, "exported_at": true,
			"sandbox": true, "snapshot": true
		}
		for root_key in root.keys():
			if not allowed_backup_root_keys.has(str(root_key)):
				return {"ok": false, "error_code": "invalid_payload", "message": "备份信封包含未定义字段：%s。" % str(root_key)}
		var format_version_value: Variant = root.get("format_version", 0)
		if not _is_integer_number(format_version_value):
			return {"ok": false, "error_code": "unsupported_format", "message": "备份格式版本无效。"}
		var format_version := int(format_version_value)
		if format_version != SANDBOX_PACKAGE_VERSION:
			return {"ok": false, "error_code": "unsupported_format", "message": "这个备份需要更新版本的三国推演志。"}
		if not (root.get("sandbox", {}) is Dictionary):
			return {"ok": false, "error_code": "invalid_payload", "message": "备份中缺少完整的沙盘内容。"}
		payload = root.get("sandbox", {})
		source_format = "backup_v1"
		exported_at = str(root.get("exported_at", ""))
		if root.has("snapshot"):
			var source_snapshot_value: Variant = root.get("snapshot", null)
			if not (source_snapshot_value is Dictionary):
				return {"ok": false, "error_code": "invalid_snapshot_metadata", "message": "备份中的来源快照信息无效。"}
			var source_snapshot: Dictionary = source_snapshot_value
			source_snapshot_id = str(source_snapshot.get("snapshot_id", "")).strip_edges()
			source_snapshot_name = _sanitize_single_line(str(source_snapshot.get("name", "")), MAX_SNAPSHOT_NAME_LENGTH, "")
			source_snapshot_sandbox_id = str(source_snapshot.get("source_sandbox_id", "")).strip_edges()
			if not _is_safe_record_id(source_snapshot_id) or source_snapshot_name.is_empty() or not _is_safe_record_id(source_snapshot_sandbox_id):
				return {"ok": false, "error_code": "invalid_snapshot_metadata", "message": "备份中的来源快照身份无效。"}
	else:
		payload = root
		if external:
			if not root.has("save_version") or not _is_integer_number(root.get("save_version")) or not root.has("cards") or not (root.get("cards") is Array):
				return {"ok": false, "error_code": "wrong_format", "message": "文件不是可识别的三国推演志沙盘备份或旧式存档。"}
			warnings.append("这是旧式原始存档，将自动转换后恢复。")

	var save_version_value: Variant = payload.get("save_version", 1)
	if not _is_integer_number(save_version_value):
		return {"ok": false, "error_code": "unsupported_version", "message": "沙盘版本字段无效。"}
	var source_save_version := int(save_version_value)
	if source_save_version < 1 or source_save_version > runtime_save_version:
		return {"ok": false, "error_code": "unsupported_version", "message": "这个备份由更新版本创建，请升级游戏后再试。"}
	var catalog_result: Dictionary = CharacterCatalogPolicyScript.evaluate_payload_catalog(
		payload,
		character_catalog_version,
		CHARACTER_CATALOG_SAVE_VERSION,
		runtime_save_version,
		runtime_previous_character_catalog_version,
		runtime_previous_character_catalog_max_save_version,
		runtime_historical_character_catalog_max_save_versions,
		runtime_previous_character_catalog_min_save_version
	)
	if not bool(catalog_result.get("ok", false)):
		return {
			"ok": false,
			"error_code": str(catalog_result.get("error_code", "invalid_character_catalog")),
			"message": str(catalog_result.get("message", "人物目录版本无效。"))
		}
	var source_catalog_version := int(catalog_result.get("source_catalog_version", 0))
	var allowed_character_ids := _character_ids_for_catalog_version(source_catalog_version)
	if allowed_character_ids.is_empty():
		return {"ok": false, "error_code": "unsupported_character_catalog", "message": "该沙盘的人物目录版本不受支持。"}
	if source_save_version >= CHARACTER_TROOP_SAVE_VERSION:
		var allowed_v14_keys := {
			"save_version": true, "character_catalog_version": true,
			"metadata": true, "scenario_state": true, "chronicle": true,
			"player_strokes": true, "character_states": true, "character_actions": true,
			"character_troops": true,
			"map_id": true, "map_geometry_version": true, "camera": true, "cards": true,
			"annotations": true, "updated_at": true
		}
		if payload.size() != allowed_v14_keys.size():
			return {"ok": false, "error_code": "invalid_payload", "message": "v%d 沙盘包含未定义字段或缺少必要字段。" % source_save_version}
		for key in payload.keys():
			if not allowed_v14_keys.has(str(key)):
				return {"ok": false, "error_code": "invalid_payload", "message": "v%d 沙盘包含未定义字段：%s。" % [source_save_version, str(key)]}
	elif source_save_version >= CHARACTER_CATALOG_SAVE_VERSION:
		var allowed_v13_keys := {
			"save_version": true, "character_catalog_version": true,
			"metadata": true, "scenario_state": true, "chronicle": true,
			"player_strokes": true, "character_states": true, "character_actions": true,
			"map_id": true, "map_geometry_version": true, "camera": true, "cards": true,
			"annotations": true, "updated_at": true
		}
		if payload.size() != allowed_v13_keys.size():
			return {"ok": false, "error_code": "invalid_payload", "message": "v13 沙盘包含未定义字段或缺少必要字段。"}
		for key in payload.keys():
			if not allowed_v13_keys.has(str(key)):
				return {"ok": false, "error_code": "invalid_payload", "message": "v13 沙盘包含未定义字段：%s。" % str(key)}
	elif source_save_version >= CHARACTER_ACTION_SAVE_VERSION:
		var allowed_character_action_keys := {
			"save_version": true, "metadata": true, "scenario_state": true, "chronicle": true,
			"player_strokes": true, "character_states": true, "character_actions": true,
			"map_id": true, "map_geometry_version": true, "camera": true, "cards": true,
			"annotations": true, "updated_at": true
		}
		if payload.size() != allowed_character_action_keys.size():
			return {"ok": false, "error_code": "invalid_payload", "message": "v%d 沙盘包含未定义字段或缺少必要字段。" % source_save_version}
		for key in payload.keys():
			if not allowed_character_action_keys.has(str(key)):
				return {"ok": false, "error_code": "invalid_payload", "message": "v%d 沙盘包含未定义字段：%s。" % [source_save_version, str(key)]}
	elif source_save_version >= LEGACY_CHARACTER_STATE_SAVE_VERSION:
		var allowed_character_state_keys := {
			"save_version": true, "metadata": true, "scenario_state": true, "chronicle": true,
			"player_strokes": true, "character_states": true, "map_id": true, "map_geometry_version": true,
			"camera": true, "cards": true, "annotations": true, "updated_at": true
		}
		if payload.size() != allowed_character_state_keys.size():
			return {"ok": false, "error_code": "invalid_payload", "message": "v%d 沙盘包含未定义字段或缺少必要字段。" % source_save_version}
		for key in payload.keys():
			if not allowed_character_state_keys.has(str(key)):
				return {"ok": false, "error_code": "invalid_payload", "message": "v%d 沙盘包含未定义字段：%s。" % [source_save_version, str(key)]}
	elif source_save_version >= PLAYER_STROKE_SAVE_VERSION:
		var allowed_v7_keys := {
			"save_version": true, "metadata": true, "scenario_state": true, "chronicle": true,
			"player_strokes": true, "map_id": true, "map_geometry_version": true, "camera": true,
			"cards": true, "annotations": true, "updated_at": true
		}
		if payload.size() != allowed_v7_keys.size():
			return {"ok": false, "error_code": "invalid_payload", "message": "v7 沙盘包含未定义字段或缺少必要字段。"}
		for key in payload.keys():
			if not allowed_v7_keys.has(str(key)):
				return {"ok": false, "error_code": "invalid_payload", "message": "v7 沙盘包含未定义字段：%s。" % str(key)}
	elif source_save_version >= CHRONICLE_SAVE_VERSION:
		var allowed_v6_keys := {
			"save_version": true, "metadata": true, "scenario_state": true, "chronicle": true,
			"map_id": true, "map_geometry_version": true, "camera": true, "cards": true,
			"annotations": true, "updated_at": true
		}
		if payload.size() != allowed_v6_keys.size():
			return {"ok": false, "error_code": "invalid_payload", "message": "v6 沙盘包含未定义字段或缺少必要字段。"}
		for key in payload.keys():
			if not allowed_v6_keys.has(str(key)):
				return {"ok": false, "error_code": "invalid_payload", "message": "v6 沙盘包含未定义字段：%s。" % str(key)}
	var strict_reference_result: Dictionary = CharacterCatalogReferencePolicyScript.validate_payload_references(
		payload.get("cards", []),
		payload.get("scenario_state", {"character_assignments": []}),
		payload.get("character_states", {"records": []}),
		payload.get("character_actions", {"records": []}),
		allowed_character_ids,
		payload.get("character_troops", {"records": []})
	)
	if not bool(strict_reference_result.get("ok", false)):
		return {
			"ok": false,
			"error_code": str(strict_reference_result.get("error_code", "invalid_character_reference")),
			"message": str(strict_reference_result.get("message", "沙盘引用了人物目录之外的人物。"))
		}

	var geometry_migration_required := false
	var source_geometry_value: Variant = payload.get("map_geometry_version", 0)
	var source_geometry_version := int(source_geometry_value) if _is_integer_number(source_geometry_value) else 0
	var payload_map_id := str(payload.get("map_id", MAP_ID))
	if payload_map_id != MAP_ID:
		return {"ok": false, "error_code": "wrong_map", "message": "这个备份使用了当前版本不支持的地图。"}
	if source_geometry_version == MAP_GEOMETRY_MIGRATABLE_VERSION:
		# v1—v2 尚未写入标记数组；先补齐其历史默认值，再交给严格几何迁移器。
		# v3 及以后缺失 annotations 仍按坏档拒绝，不能替当前文档静默补字段。
		if source_save_version < 3 and not payload.has("annotations"):
			payload = payload.duplicate(true)
			payload["annotations"] = []
		var target_places_by_id := {}
		for place_value in places:
			if place_value is Dictionary:
				var place_id := str((place_value as Dictionary).get("id", "")).strip_edges()
				if not place_id.is_empty():
					target_places_by_id[place_id] = (place_value as Dictionary).duplicate(true)
		var geometry_result := MapGeometryMigrationScript.migrate_sandbox_payload(
			payload,
			MAP_GEOMETRY_MIGRATABLE_VERSION,
			MAP_GEOMETRY_VERSION,
			MAP_GEOMETRY_V3_BOUNDS,
			MAP_GEOMETRY_V4_BOUNDS,
			target_places_by_id
		)
		if not bool(geometry_result.get("ok", false)):
			return {
				"ok": false,
				"error_code": "map_geometry_migration_failed",
				"message": "旧地图范围无法安全迁移：%s" % str(geometry_result.get("message", "坐标数据无效。"))
			}
		if not external and not (geometry_result.get("warnings", []) as Array).is_empty():
			return {
				"ok": false,
				"error_code": "map_geometry_unknown_place",
				"message": "旧沙盘含有已经无法确认的驻城地点；为避免静默丢失锚点，原文件保持不变。请使用备份导入流程检查后再恢复。"
			}
		payload = (geometry_result.get("payload", {}) as Dictionary).duplicate(true)
		geometry_migration_required = true
		if external:
			warnings.append("地图已扩展为周边全图；驻城人物按城池重定位，自由落点、标记和推演线已按经纬范围迁移，旧视角已归位。")
			for migration_warning_value in geometry_result.get("warnings", []):
				var migration_warning := str(migration_warning_value).strip_edges()
				if not migration_warning.is_empty():
					warnings.append(migration_warning)
	elif source_geometry_version != MAP_GEOMETRY_VERSION:
		return {
			"ok": false,
			"error_code": "unsupported_map_geometry",
			"message": "这个沙盘使用了当前版本不支持的地图几何版本。"
		}
	var decoded_metadata: Dictionary = {}
	var metadata_migration_required := source_save_version < SANDBOX_METADATA_SAVE_VERSION
	if metadata_migration_required:
		if external:
			warnings.append("旧版沙盘没有分支身份，继续后会建立新的沙盘身份。")
	else:
		var metadata_result := _decode_sandbox_metadata(payload.get("metadata", null), warnings)
		if not bool(metadata_result.get("ok", false)):
			return {
				"ok": false,
				"error_code": "invalid_metadata",
				"message": str(metadata_result.get("message", "沙盘身份信息无效。"))
			}
		decoded_metadata = metadata_result.get("metadata", {}).duplicate(true)
		if not source_snapshot_id.is_empty() and source_snapshot_sandbox_id != str(decoded_metadata.get("sandbox_id", "")):
			return {"ok": false, "error_code": "invalid_snapshot_metadata", "message": "备份中的来源快照与沙盘身份不一致。"}
	var decoded_scenario_state := _empty_scenario_state()
	var scenario_color_migration_required := source_save_version < SCENARIO_COLOR_SAVE_VERSION
	if source_save_version >= SCENARIO_STATE_SAVE_VERSION:
		var scenario_result := _decode_scenario_state(
			payload.get("scenario_state", null),
			source_save_version < SCENARIO_COLOR_SAVE_VERSION,
			source_save_version >= SCENARIO_COLOR_SAVE_VERSION,
			_legacy_scenario_contract(decoded_metadata) if source_save_version < CHARACTER_CATALOG_SAVE_VERSION else {}
		)
		if not bool(scenario_result.get("ok", false)):
			return {
				"ok": false,
				"error_code": "invalid_scenario_state",
				"message": str(scenario_result.get("message", "玩法势力状态无效。"))
			}
		decoded_scenario_state = (scenario_result.get("scenario_state", {}) as Dictionary).duplicate(true)
		scenario_color_migration_required = scenario_color_migration_required or bool(scenario_result.get("color_migration_required", false))
	elif external:
		warnings.append("旧版沙盘没有玩法势力状态，已按未分组沙盘继续。")
	var decoded_chronicle_entries: Array[Dictionary] = []
	var chronicle_migration_required := source_save_version < CHRONICLE_SAVE_VERSION
	if source_save_version >= CHRONICLE_SAVE_VERSION:
		var chronicle_result := _decode_chronicle(payload.get("chronicle", null))
		if not bool(chronicle_result.get("ok", false)):
			return {
				"ok": false,
				"error_code": "invalid_chronicle",
				"message": str(chronicle_result.get("message", "玩家纪事数据无效。"))
			}
		decoded_chronicle_entries = (chronicle_result.get("chronicle_entries", []) as Array).duplicate(true)
	elif external:
		warnings.append("旧版沙盘没有玩家纪事，已按空纪事继续。")
	var decoded_player_strokes: Array[Dictionary] = []
	var player_stroke_migration_required := source_save_version < PLAYER_STROKE_SAVE_VERSION
	if source_save_version >= PLAYER_STROKE_SAVE_VERSION:
		var stroke_result := _decode_player_strokes(payload.get("player_strokes", null))
		if not bool(stroke_result.get("ok", false)):
			return {
				"ok": false,
				"error_code": "invalid_player_strokes",
				"message": str(stroke_result.get("message", "玩家推演线数据无效。"))
			}
		decoded_player_strokes = (stroke_result.get("player_strokes", []) as Array).duplicate(true)
	elif external:
		warnings.append("旧版沙盘没有玩家推演线，已按空画线继续。")
	var decoded_character_states: Dictionary = {}
	var character_state_migration_required := source_save_version < CHARACTER_STATE_SAVE_VERSION
	if source_save_version >= CHARACTER_STATE_SAVE_VERSION:
		var character_state_result := _decode_character_states(payload.get("character_states", null))
		if not bool(character_state_result.get("ok", false)):
			return {
				"ok": false,
				"error_code": "invalid_character_states",
				"message": str(character_state_result.get("message", "本局人物属性无效。"))
			}
		decoded_character_states = (character_state_result.get("character_states", {}) as Dictionary).duplicate(true)
	elif source_save_version == LEGACY_CHARACTER_STATE_SAVE_VERSION:
		var legacy_character_state_result := _decode_character_states_v8(payload.get("character_states", null))
		if not bool(legacy_character_state_result.get("ok", false)):
			return {
				"ok": false,
				"error_code": "invalid_character_states",
				"message": str(legacy_character_state_result.get("message", "旧版本局攻防无效。"))
			}
		decoded_character_states = (legacy_character_state_result.get("character_states", {}) as Dictionary).duplicate(true)
		if external and not decoded_character_states.is_empty():
			warnings.append("旧版攻击／防御已原样保留，不会自动换算成武力／智力／统率／魅力；可在人物右键中手动应用四维。")
	elif external:
		warnings.append("旧版沙盘没有人物资料调整，已使用项目初始四维继续。")
	var decoded_character_actions: Dictionary = {}
	var character_action_migration_required := source_save_version < CHARACTER_ACTION_SAVE_VERSION
	if source_save_version >= CHARACTER_ACTION_SAVE_VERSION:
		var character_action_result := _decode_character_actions(payload.get("character_actions", null))
		if not bool(character_action_result.get("ok", false)):
			return {
				"ok": false,
				"error_code": "invalid_character_actions",
				"message": str(character_action_result.get("message", "人物行动状态无效。"))
			}
		decoded_character_actions = (character_action_result.get("character_actions", {}) as Dictionary).duplicate(true)
	elif external:
		warnings.append("旧版沙盘没有人物行动状态，已按全部待命继续。")
	var decoded_character_troops: Dictionary = {}
	var character_troop_migration_required := source_save_version < CHARACTER_TROOP_SAVE_VERSION
	if source_save_version >= CHARACTER_TROOP_SAVE_VERSION:
		var character_troop_result := _decode_character_troops(payload.get("character_troops", null))
		if not bool(character_troop_result.get("ok", false)):
			return {
				"ok": false,
				"error_code": "invalid_character_troops",
				"message": str(character_troop_result.get("message", "人物兵力无效。"))
			}
		decoded_character_troops = (character_troop_result.get("character_troops", {}) as Dictionary).duplicate(true)
	elif external:
		warnings.append("旧版沙盘没有人物兵力记录，已按每人 1000 继续。")

	var cards_value: Variant = payload.get("cards", [])
	if not (cards_value is Array):
		return {"ok": false, "error_code": "invalid_cards", "message": "人物卡数据结构无效。"}
	if cards_value.size() > maxi(1, characters.size()) * 2:
		return {"ok": false, "error_code": "too_many_cards", "message": "人物卡数量超过安全上限。"}
	var decoded_placements := {}
	for index in range(cards_value.size()):
		var card_value: Variant = cards_value[index]
		if not (card_value is Dictionary):
			warnings.append("已跳过第 %d 条无效人物记录。" % (index + 1))
			continue
		var card: Dictionary = card_value
		if source_save_version >= STRICT_CARD_FIELDS_SAVE_VERSION:
			var allowed_card_keys := {"character_id": true, "x": true, "y": true, "place_id": true}
			for card_key in card.keys():
				if not allowed_card_keys.has(str(card_key)):
					return {
						"ok": false,
						"error_code": "invalid_cards",
						"message": "v%d 人物卡包含未定义字段：%s。" % [source_save_version, str(card_key)]
					}
		var character_id := str(card.get("character_id", "")).strip_edges()
		if not _has_character_id(character_id):
			warnings.append("已跳过当前版本无法识别的人物：%s。" % (character_id if not character_id.is_empty() else "空 ID"))
			continue
		if decoded_placements.has(character_id):
			warnings.append("人物 %s 重复出现，已保留第一条记录。" % _character_name(character_id))
			continue
		var x := _decode_coordinate(card.get("x", 0.5), 0.5, warnings, "%s 的横坐标" % _character_name(character_id))
		var y := _decode_coordinate(card.get("y", 0.5), 0.5, warnings, "%s 的纵坐标" % _character_name(character_id))
		var place_id := str(card.get("place_id", "")).strip_edges()
		if source_save_version < PLACE_ID_SAVE_VERSION and place_id.is_empty():
			place_id = _infer_legacy_place_id(Vector2(x, y))
		var place := _find_place(place_id)
		var placement := {"x": x, "y": y}
		if not place.is_empty():
			placement["x"] = float(place.get("x", x))
			placement["y"] = float(place.get("y", y))
			placement["place_id"] = place_id
		elif not place_id.is_empty():
			warnings.append("%s 的未知驻城信息已降级为自由摆放。" % _character_name(character_id))
		decoded_placements[character_id] = placement

	var annotations_value: Variant = payload.get("annotations", [])
	if not (annotations_value is Array):
		return {"ok": false, "error_code": "invalid_annotations", "message": "沙盘标记数据结构无效。"}
	if annotations_value.size() > MAX_IMPORT_ANNOTATIONS:
		return {"ok": false, "error_code": "too_many_annotations", "message": "沙盘标记超过 500 个安全上限。"}
	var decoded_annotations := {}
	for index in range(annotations_value.size()):
		var annotation_value: Variant = annotations_value[index]
		if not (annotation_value is Dictionary):
			warnings.append("已跳过第 %d 条无效标记记录。" % (index + 1))
			continue
		var annotation := _decode_annotation(annotation_value, warnings, index)
		var annotation_id := str(annotation.get("id", ""))
		if annotation_id.is_empty():
			continue
		if decoded_annotations.has(annotation_id):
			warnings.append("标记 %s 重复出现，已保留第一条记录。" % annotation_id)
			continue
		decoded_annotations[annotation_id] = annotation

	var camera := {}
	var camera_valid := false
	var geometry_version_value: Variant = payload.get("map_geometry_version", 0)
	var geometry_version := int(geometry_version_value) if typeof(geometry_version_value) in [TYPE_INT, TYPE_FLOAT] else 0
	if geometry_version == MAP_GEOMETRY_VERSION:
		var camera_value: Variant = payload.get("camera", {})
		if camera_value is Dictionary and _camera_dictionary_is_numeric(camera_value):
			camera = {
				"x": clampf(float(camera_value.get("x", 0.0)), -10000.0, 10000.0),
				"y": clampf(float(camera_value.get("y", 0.0)), -10000.0, 10000.0),
				"zoom": clampf(
					float(camera_value.get("zoom", 1.0)),
					MapBoardScript.MIN_ZOOM,
					MapBoardScript.MAX_ZOOM
				)
			}
			camera_valid = true
		elif not (camera_value is Dictionary and camera_value.is_empty()):
			warnings.append("地图视角数据无效，恢复时将保留当前视角。")
	else:
		warnings.append("地图几何版本不同，人物和标记会保留，恢复时将保留当前视角。")

	return {
		"ok": true,
		"error_code": "",
		"message": "",
		"placements": decoded_placements,
		"annotations": decoded_annotations,
		"camera": camera,
		"camera_valid": camera_valid,
		"sandbox_metadata": decoded_metadata,
		"scenario_state": decoded_scenario_state,
		"chronicle_entries": decoded_chronicle_entries,
		"player_strokes": decoded_player_strokes,
		"character_states": decoded_character_states,
		"character_actions": decoded_character_actions,
		"character_troops": decoded_character_troops,
		"metadata_migration_required": metadata_migration_required,
		"scenario_color_migration_required": scenario_color_migration_required,
		"chronicle_migration_required": chronicle_migration_required,
		"player_stroke_migration_required": player_stroke_migration_required,
		"character_state_migration_required": character_state_migration_required,
		"character_action_migration_required": character_action_migration_required,
		"character_troop_migration_required": character_troop_migration_required,
		"geometry_migration_required": geometry_migration_required,
		"character_catalog_migration_required": bool(catalog_result.get("catalog_migration_required", false)),
		"save_version_migration_required": source_save_version < runtime_save_version,
		"source_save_version": source_save_version,
		"source_character_catalog_version": source_catalog_version,
		"source_format": source_format,
		"source_snapshot_id": source_snapshot_id,
		"source_snapshot_name": source_snapshot_name,
		"exported_at": exported_at if not exported_at.is_empty() else str(payload.get("updated_at", "")),
		"warnings": warnings,
		"character_count": decoded_placements.size(),
		"annotation_count": decoded_annotations.size(),
		"chronicle_count": decoded_chronicle_entries.size(),
		"character_state_count": decoded_character_states.size(),
		"character_action_count": decoded_character_actions.size(),
		"character_troop_override_count": decoded_character_troops.size(),
		"player_stroke_count": decoded_player_strokes.size()
	}


func _decode_coordinate(value: Variant, fallback: float, warnings: Array[String], label: String) -> float:
	if not (typeof(value) in [TYPE_INT, TYPE_FLOAT]):
		warnings.append("%s无效，已使用默认位置。" % label)
		return fallback
	var number := float(value)
	if not is_finite(number):
		warnings.append("%s无效，已使用默认位置。" % label)
		return fallback
	var clamped := clampf(number, 0.0, 1.0)
	if not is_equal_approx(number, clamped):
		warnings.append("%s超出地图范围，已安全修正。" % label)
	return clamped


func _decode_annotation(value: Dictionary, warnings: Array[String], index: int) -> Dictionary:
	var annotation_id := str(value.get("id", "")).strip_edges()
	if not _is_safe_record_id(annotation_id):
		warnings.append("已跳过第 %d 条 ID 无效的标记。" % (index + 1))
		return {}
	if str(value.get("kind", "marker")) != "marker":
		warnings.append("已跳过当前版本不支持的标记记录族：%s。" % str(value.get("kind", "")))
		return {}
	for forbidden_field in ANNOTATION_FORBIDDEN_FIELDS:
		if value.has(forbidden_field):
			warnings.append("已跳过夹带史实／运行字段的玩家标记 %s：%s。" % [annotation_id, forbidden_field])
			return {}
	var marker_type := str(value.get("marker_type", "note"))
	if not ANNOTATION_TYPES.has(marker_type):
		warnings.append("标记 %s 的未知类型已降级为战术便签。" % annotation_id)
		marker_type = "note"
	var semantic_layer := str(value.get("semantic_layer", ANNOTATION_SEMANTIC_LAYER))
	var verification_status := str(value.get("verification_status", ANNOTATION_VERIFICATION_STATUS))
	if semantic_layer != ANNOTATION_SEMANTIC_LAYER or verification_status != ANNOTATION_VERIFICATION_STATUS:
		warnings.append("标记 %s 的语义来源无效，已恢复为玩家创作／项目未核验。" % annotation_id)
		semantic_layer = ANNOTATION_SEMANTIC_LAYER
		verification_status = ANNOTATION_VERIFICATION_STATUS
	var label := str(value.get("label", "")).replace("\r", " ").replace("\n", " ").strip_edges().left(24)
	var faction_id := str(value.get("faction_id", "")).strip_edges()
	if not faction_id.is_empty() and not _is_safe_record_id(faction_id):
		warnings.append("标记 %s 的所属势力 ID 无效，已清除。" % annotation_id)
		faction_id = ""
	var expected_style := _annotation_style_for_type(marker_type)
	var style := str(value.get("style", expected_style))
	if style != expected_style:
		warnings.append("标记 %s 的样式与类型不匹配，已恢复为对应样式。" % annotation_id)
		style = expected_style
	return {
		"id": annotation_id,
		"kind": "marker",
		"marker_type": marker_type,
		"semantic_layer": semantic_layer,
		"verification_status": verification_status,
		"x": _decode_coordinate(value.get("x", 0.5), 0.5, warnings, "标记 %s 的横坐标" % annotation_id),
		"y": _decode_coordinate(value.get("y", 0.5), 0.5, warnings, "标记 %s 的纵坐标" % annotation_id),
		"label": label,
		"style": style,
		"faction_id": faction_id
	}


func _is_safe_record_id(value: String) -> bool:
	if value.is_empty() or value.length() > 64:
		return false
	for index in range(value.length()):
		var code := value.unicode_at(index)
		var valid := (code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or code == 95 or code == 45
		if not valid:
			return false
	return true


func _camera_dictionary_is_numeric(value: Dictionary) -> bool:
	for key in ["x", "y", "zoom"]:
		if not (typeof(value.get(key, null)) in [TYPE_INT, TYPE_FLOAT]):
			return false
		if not is_finite(float(value.get(key, 0.0))):
			return false
	return true


func _is_integer_number(value: Variant) -> bool:
	if not (typeof(value) in [TYPE_INT, TYPE_FLOAT]):
		return false
	var number := float(value)
	return is_finite(number) and is_equal_approx(number, roundf(number))


func _new_record_id(prefix: String) -> String:
	var random_bytes := Crypto.new().generate_random_bytes(16)
	if random_bytes.size() == 16:
		return "%s_%s" % [prefix, random_bytes.hex_encode()]
	return "%s_%s" % [prefix, _timestamp_slug().replace("-", "").replace("_", "")]


func _new_sandbox_metadata(title := "未命名沙盘", note := "", scenario_source := "", branch_parent_id := "", source_snapshot_id := "") -> Dictionary:
	return {
		"sandbox_id": _new_record_id("sbx"),
		"branch_parent_id": branch_parent_id,
		"source_snapshot_id": source_snapshot_id,
		"title": _sanitize_single_line(title, MAX_SANDBOX_TITLE_LENGTH, "未命名沙盘"),
		"note": _sanitize_multiline(note, MAX_SANDBOX_NOTE_LENGTH),
		"scenario_source": _sanitize_single_line(scenario_source, MAX_SANDBOX_SOURCE_LENGTH, ""),
		"created_at": Time.get_datetime_string_from_system(false, true)
	}


func _branch_metadata_from(source_metadata: Dictionary, source_snapshot_id := "") -> Dictionary:
	var parent_id := str(source_metadata.get("sandbox_id", ""))
	return _new_sandbox_metadata(
		str(source_metadata.get("title", "未命名沙盘")),
		str(source_metadata.get("note", "")),
		str(source_metadata.get("scenario_source", "")),
		parent_id if _is_safe_record_id(parent_id) else "",
		source_snapshot_id if _is_safe_record_id(source_snapshot_id) else ""
	)


func _decode_sandbox_metadata(value: Variant, warnings: Array[String]) -> Dictionary:
	if not (value is Dictionary):
		return {"ok": false, "message": "沙盘缺少完整的身份信息。"}
	var raw: Dictionary = value
	var sandbox_id := str(raw.get("sandbox_id", "")).strip_edges()
	if not _is_safe_record_id(sandbox_id):
		return {"ok": false, "message": "沙盘身份 ID 无效，无法安全继续。"}
	var branch_parent_id := str(raw.get("branch_parent_id", "")).strip_edges()
	if not branch_parent_id.is_empty() and (not _is_safe_record_id(branch_parent_id) or branch_parent_id == sandbox_id):
		return {"ok": false, "message": "沙盘的分支来源无效。"}
	var source_snapshot_id := str(raw.get("source_snapshot_id", "")).strip_edges()
	if not source_snapshot_id.is_empty() and not _is_safe_record_id(source_snapshot_id):
		return {"ok": false, "message": "沙盘的来源快照 ID 无效。"}
	var raw_title := str(raw.get("title", ""))
	var title := _sanitize_single_line(raw_title, MAX_SANDBOX_TITLE_LENGTH, "未命名沙盘")
	if title != raw_title.strip_edges():
		warnings.append("沙盘名称已按当前长度和单行规则整理。")
	var raw_note := str(raw.get("note", ""))
	var note := _sanitize_multiline(raw_note, MAX_SANDBOX_NOTE_LENGTH)
	if note != raw_note.replace("\r\n", "\n").replace("\r", "\n").strip_edges():
		warnings.append("沙盘说明已按当前长度规则整理。")
	var raw_source := str(raw.get("scenario_source", ""))
	var scenario_source := _sanitize_single_line(raw_source, MAX_SANDBOX_SOURCE_LENGTH, "")
	if scenario_source != raw_source.strip_edges():
		warnings.append("开局来源已按当前长度和单行规则整理。")
	var created_at := str(raw.get("created_at", "")).strip_edges().left(40)
	if created_at.is_empty():
		created_at = Time.get_datetime_string_from_system(false, true)
		warnings.append("沙盘创建时间缺失，已补为当前时间。")
	return {
		"ok": true,
		"metadata": {
			"sandbox_id": sandbox_id,
			"branch_parent_id": branch_parent_id,
			"source_snapshot_id": source_snapshot_id,
			"title": title,
			"note": note,
			"scenario_source": scenario_source,
			"created_at": created_at
		}
	}


func _sanitize_single_line(value: String, max_length: int, fallback: String) -> String:
	var result := value.replace("\r", " ").replace("\n", " ").strip_edges().left(max_length)
	return fallback if result.is_empty() else result


func _sanitize_multiline(value: String, max_length: int) -> String:
	return value.replace("\r\n", "\n").replace("\r", "\n").strip_edges().left(max_length)


func _safe_filename_component(value: String) -> String:
	var result := _sanitize_single_line(value, 48, "未命名沙盘")
	for invalid_character in ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"]:
		result = result.replace(invalid_character, "_")
	while result.ends_with(".") or result.ends_with(" "):
		result = result.left(result.length() - 1)
	return "未命名沙盘" if result.is_empty() else result


func _sandbox_metadata_match(first: Dictionary, second: Dictionary) -> bool:
	for key in ["sandbox_id", "branch_parent_id", "source_snapshot_id", "title", "note", "scenario_source", "created_at"]:
		if str(first.get(key, "")) != str(second.get(key, "")):
			return false
	return true


func _load_preferences() -> void:
	favorite_character_ids.clear()
	_preferences_writes_blocked = false
	_preferences_write_block_reason = ""
	if FileAccess.file_exists(preferences_path):
		var current_result := _read_preferences_document(preferences_path, PREFERENCES_VERSION)
		if not bool(current_result.get("ok", false)):
			_preferences_writes_blocked = true
			_preferences_write_block_reason = str(current_result.get("message", "人物背包偏好无法安全读取。"))
			if not automated_test_mode:
				push_error(_preferences_write_block_reason)
			return
		for character_id_value in current_result.get("favorite_character_ids", []):
			favorite_character_ids[str(character_id_value)] = true
		if bool(current_result.get("catalog_migration_required", false)):
			var backup_result := _create_raw_migration_backup(
				preferences_path,
				PREFERENCES_VERSION,
				int(current_result.get("source_character_catalog_version", 0)),
				"preferences"
			)
			if not bool(backup_result.get("ok", false)):
				_preferences_writes_blocked = true
				_preferences_write_block_reason = "人物背包偏好已在内存读取，但迁移前备份失败；原文件保持不变。"
				return
			if not _save_preferences():
				_preferences_writes_blocked = true
				_preferences_write_block_reason = "人物背包偏好已在内存迁移，但新版文件无法安全写入；迁移前备份已保留。"
		return
	if not FileAccess.file_exists(legacy_preferences_path):
		return
	var legacy_result := _read_preferences_document(legacy_preferences_path, 1)
	if not bool(legacy_result.get("ok", false)):
		_preferences_writes_blocked = true
		_preferences_write_block_reason = str(legacy_result.get("message", "旧版人物背包偏好无法安全读取。"))
		if not automated_test_mode:
			push_error(_preferences_write_block_reason)
		return
	for character_id_value in legacy_result.get("favorite_character_ids", []):
		favorite_character_ids[str(character_id_value)] = true
	if not _save_preferences():
		_preferences_writes_blocked = true
		_preferences_write_block_reason = "旧版人物背包偏好已在内存中读取，但 v2 文件无法安全写入；原 v1 文件保持不变。"


func _save_preferences() -> bool:
	if _preferences_writes_blocked:
		return false
	var ids: Array[String] = []
	for character_id in favorite_character_ids:
		var normalized_id := str(character_id).strip_edges()
		if not _has_character_id(normalized_id):
			push_error("人物背包偏好含未知人物，已拒绝静默写入：%s" % normalized_id)
			return false
		ids.append(normalized_id)
	ids.sort()
	var data := {
		"schema_version": PREFERENCES_VERSION,
		"character_catalog_version": character_catalog_version,
		"favorite_character_ids": ids,
		"updated_at": Time.get_datetime_string_from_system(false, true)
	}
	var validation := _decode_preferences_document(data, PREFERENCES_VERSION)
	if not bool(validation.get("ok", false)):
		push_error("人物背包偏好未通过写前校验：%s" % str(validation.get("message", "结构无效。")))
		return false
	var write_result := _write_json_atomic(preferences_path, data, true)
	if not bool(write_result.get("ok", false)):
		push_error("无法原子写入人物背包偏好：%s" % str(write_result.get("message", preferences_path)))
		return false
	return true


func _read_preferences_document(path: String, expected_schema_version: int) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "message": "无法读取人物背包偏好文件。"}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {"ok": false, "message": "人物背包偏好 JSON 无效。"}
	return _decode_preferences_document(parser.data, expected_schema_version)


func _decode_preferences_document(document: Variant, expected_schema_version: int) -> Dictionary:
	if not (document is Dictionary):
		return {"ok": false, "message": "人物背包偏好顶层必须是对象。"}
	var root: Dictionary = document
	var allowed_keys: Array[String] = ["schema_version", "favorite_character_ids", "updated_at"]
	if expected_schema_version == PREFERENCES_VERSION:
		allowed_keys.append("character_catalog_version")
	if root.size() != allowed_keys.size():
		return {"ok": false, "message": "人物背包偏好字段不完整或含未定义字段。"}
	for key in root.keys():
		if str(key) not in allowed_keys:
			return {"ok": false, "message": "人物背包偏好含未定义字段：%s。" % str(key)}
	if not _is_integer_number(root.get("schema_version", null)) or int(root.get("schema_version")) != expected_schema_version:
		return {"ok": false, "message": "人物背包偏好版本不受支持。"}
	var allowed_ids: Array[String]
	var source_catalog_version := 1
	if expected_schema_version == 1:
		allowed_ids = _character_ids_for_catalog_version(1)
	else:
		if not _is_integer_number(root.get("character_catalog_version", null)):
			return {"ok": false, "message": "人物背包偏好缺少有效人物目录版本。"}
		source_catalog_version = int(root.get("character_catalog_version"))
		if source_catalog_version > character_catalog_version:
			return {"ok": false, "message": "人物背包偏好由更新的人物目录创建，请升级游戏后再试。"}
		if _character_ids_for_catalog_version(source_catalog_version).is_empty():
			return {"ok": false, "message": "人物背包偏好目录版本无法安全读取。"}
		allowed_ids = _character_ids_for_catalog_version(source_catalog_version)
	var favorite_values: Variant = root.get("favorite_character_ids", null)
	if not (favorite_values is Array) or (favorite_values as Array).size() > allowed_ids.size():
		return {"ok": false, "message": "人物背包收藏列表无效或超过安全上限。"}
	var decoded_ids: Array[String] = []
	var seen_ids := {}
	for character_id_value in favorite_values:
		if not (character_id_value is String):
			return {"ok": false, "message": "人物背包收藏 ID 必须是字符串。"}
		var character_id := str(character_id_value).strip_edges()
		if character_id not in allowed_ids or seen_ids.has(character_id):
			return {"ok": false, "message": "人物背包收藏引用未知或重复人物：%s。" % character_id}
		seen_ids[character_id] = true
		decoded_ids.append(character_id)
	if not (root.get("updated_at", null) is String):
		return {"ok": false, "message": "人物背包偏好更新时间无效。"}
	return {
		"ok": true,
		"favorite_character_ids": decoded_ids,
		"source_character_catalog_version": source_catalog_version,
		"catalog_migration_required": source_catalog_version != character_catalog_version,
	}


func _snapshot_store_artifact_paths(path := "") -> Dictionary:
	var effective_path := snapshot_store_path if path.is_empty() else path
	var absolute_path := ProjectSettings.globalize_path(effective_path)
	var parent_dir := absolute_path.get_base_dir()
	var base_name := absolute_path.get_file()
	var committed: Array[String] = []
	var uncommitted: Array[String] = []
	if not DirAccess.dir_exists_absolute(parent_dir):
		return {"ok": true, "committed": committed, "uncommitted": uncommitted, "total": 0}
	var directory := DirAccess.open(parent_dir)
	if directory == null:
		return {"ok": false, "committed": committed, "uncommitted": uncommitted, "total": 0}
	directory.list_dir_begin()
	while true:
		var filename := directory.get_next()
		if filename.is_empty():
			break
		if directory.current_is_dir():
			continue
		if filename.begins_with(base_name + ".replace-") and filename.ends_with(".tmp"):
			committed.append(parent_dir.path_join(filename))
		elif filename.begins_with(base_name + ".write-") and filename.ends_with(".tmp"):
			uncommitted.append(parent_dir.path_join(filename))
	directory.list_dir_end()
	committed.sort()
	uncommitted.sort()
	return {
		"ok": true,
		"committed": committed,
		"uncommitted": uncommitted,
		"total": committed.size() + uncommitted.size()
	}


func _inspect_snapshot_store_candidate(path: String, kind: String) -> Dictionary:
	var result := {
		"path": path,
		"kind": kind,
		"status": "invalid",
		"sha256": "",
		"byte_count": 0,
		"snapshots": [],
		"message": ""
	}
	if not FileAccess.file_exists(path):
		result["status"] = "missing"
		result["message"] = "候选文件已经不存在。"
		return result
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		result["message"] = "候选文件无法读取。"
		return result
	var byte_count := file.get_length()
	result["byte_count"] = byte_count
	if byte_count <= 0 or byte_count > MAX_IMPORT_FILE_BYTES * 4:
		result["message"] = "候选文件为空或超过安全上限。"
		return result
	var bytes := file.get_buffer(byte_count)
	file = null
	result["sha256"] = _sha256_hex(bytes)
	var parsed: Variant = JSON.parse_string(bytes.get_string_from_utf8())
	if parsed is Dictionary:
		var declared_version: Variant = (parsed as Dictionary).get("snapshot_store_version", 0)
		if _is_integer_number(declared_version) and int(declared_version) > SNAPSHOT_STORE_VERSION:
			result["status"] = "future"
			result["message"] = "候选由更新版本创建。"
			return result
	var decode_result := _decode_snapshot_store(parsed)
	if not bool(decode_result.get("ok", false)):
		result["message"] = str(decode_result.get("message", "候选没有通过完整校验。"))
		return result
	result["status"] = "valid"
	result["snapshots"] = (decode_result.get("snapshots", []) as Array).duplicate(true)
	return result


func _inspect_snapshot_store_recovery(path := "") -> Dictionary:
	var effective_path := snapshot_store_path if path.is_empty() else path
	var absolute_path := ProjectSettings.globalize_path(effective_path)
	var artifacts := _snapshot_store_artifact_paths(effective_path)
	var state := {
		"status": "none",
		"store_path": absolute_path,
		"primary": {},
		"candidate": {},
		"artifact_count": int(artifacts.get("total", 0)),
		"message": ""
	}
	if not bool(artifacts.get("ok", false)):
		state["status"] = "directory_unreadable"
		state["message"] = "无法检查命名快照库所在文件夹。"
		return state
	if FileAccess.file_exists(absolute_path):
		var primary := _inspect_snapshot_store_candidate(absolute_path, "primary")
		state["primary"] = primary
		if str(primary.get("status", "")) == "valid":
			state["status"] = "primary_valid"
			return state
		state["status"] = "primary_future" if str(primary.get("status", "")) == "future" else "primary_invalid"
		state["message"] = "命名快照库由更新版本创建，已保持原文件并停止写入。" if str(primary.get("status", "")) == "future" else str(primary.get("message", "命名快照库无法安全读取。"))
		return state
	if int(artifacts.get("total", 0)) > PRIMARY_RECOVERY_CANDIDATE_LIMIT:
		state["status"] = "too_many"
		state["message"] = "找到过多未完成的命名快照写入记录，已停止写入。"
		return state

	var valid_candidates: Array[Dictionary] = []
	var future_candidates: Array[Dictionary] = []
	var invalid_candidates: Array[Dictionary] = []
	for candidate_path_value in artifacts.get("committed", []):
		var candidate := _inspect_snapshot_store_candidate(str(candidate_path_value), "replace")
		match str(candidate.get("status", "")):
			"valid":
				valid_candidates.append(candidate)
			"future":
				future_candidates.append(candidate)
			_:
				invalid_candidates.append(candidate)
	state["valid_candidates"] = valid_candidates
	state["future_candidates"] = future_candidates
	state["invalid_candidates"] = invalid_candidates
	state["uncommitted_paths"] = (artifacts.get("uncommitted", []) as Array).duplicate()
	if not future_candidates.is_empty():
		state["status"] = "ambiguous_future"
		state["message"] = "找到当前版本无法判断的命名快照恢复记录，已保持全部文件并停止写入。"
		return state
	var by_hash: Dictionary = {}
	for candidate in valid_candidates:
		var hash := str(candidate.get("sha256", ""))
		if hash.is_empty():
			continue
		if not by_hash.has(hash):
			by_hash[hash] = []
		(by_hash[hash] as Array).append(candidate)
	if by_hash.size() > 1:
		state["status"] = "ambiguous"
		state["message"] = "找到多份内容不同的可恢复命名快照库，已保持全部文件并停止写入。"
	elif by_hash.size() == 1:
		var hash := str(by_hash.keys()[0])
		state["status"] = "recoverable"
		state["candidate"] = ((by_hash[hash] as Array)[0] as Dictionary).duplicate(true)
		state["message"] = "找到一份写入中断前已提交的命名快照库。"
	elif int(artifacts.get("total", 0)) > 0:
		state["status"] = "unavailable"
		state["message"] = "找到未完成的命名快照写入记录，但未提交文件不会被载入；已停止写入以保护现场。"
	return state


func _restore_missing_snapshot_store_candidate(candidate: Dictionary, path := "") -> Dictionary:
	var effective_path := snapshot_store_path if path.is_empty() else path
	var absolute_path := ProjectSettings.globalize_path(effective_path)
	if FileAccess.file_exists(absolute_path):
		return {"ok": false, "message": "命名快照主文件已经出现，已停止自动恢复。"}
	var candidate_path := str(candidate.get("path", ""))
	var expected_hash := str(candidate.get("sha256", ""))
	var fresh := _inspect_snapshot_store_candidate(candidate_path, "replace")
	if str(fresh.get("status", "")) != "valid" or expected_hash.is_empty() or str(fresh.get("sha256", "")) != expected_hash:
		return {"ok": false, "message": "命名快照恢复候选已变化，已保持全部文件并停止写入。"}
	if DirAccess.rename_absolute(candidate_path, absolute_path) != OK:
		return {"ok": false, "message": "无法把已提交的命名快照库恢复到主路径，已保持原文件并停止写入。"}
	var restored := _inspect_snapshot_store_candidate(absolute_path, "primary")
	if str(restored.get("status", "")) == "valid" and str(restored.get("sha256", "")) == expected_hash:
		return {"ok": true, "snapshots": (restored.get("snapshots", []) as Array).duplicate(true)}
	if not FileAccess.file_exists(candidate_path) and FileAccess.file_exists(absolute_path):
		DirAccess.rename_absolute(absolute_path, candidate_path)
	return {"ok": false, "message": "恢复后的命名快照库未通过完整校验，已停止写入。"}


func _load_named_snapshots() -> void:
	named_snapshots.clear()
	_snapshot_writes_blocked = false
	_snapshot_write_block_reason = ""
	var recovery := _inspect_snapshot_store_recovery()
	match str(recovery.get("status", "none")):
		"none":
			return
		"primary_valid":
			var primary: Dictionary = recovery.get("primary", {})
			named_snapshots = (primary.get("snapshots", []) as Array).duplicate(true)
		"recoverable":
			var restore_result := _restore_missing_snapshot_store_candidate(recovery.get("candidate", {}))
			if bool(restore_result.get("ok", false)):
				named_snapshots = (restore_result.get("snapshots", []) as Array).duplicate(true)
			else:
				_snapshot_writes_blocked = true
				_snapshot_write_block_reason = str(restore_result.get("message", "命名快照库恢复失败，已停止写入。"))
		_:
			_snapshot_writes_blocked = true
			_snapshot_write_block_reason = str(recovery.get("message", "命名快照库无法安全读取。"))


func _decode_snapshot_store(document: Variant) -> Dictionary:
	if not (document is Dictionary):
		return {"ok": false, "message": "命名快照库格式无效。"}
	var root_value: Dictionary = document
	if not _is_integer_number(root_value.get("snapshot_store_version", 0)) or int(root_value.get("snapshot_store_version", 0)) != SNAPSHOT_STORE_VERSION:
		return {"ok": false, "message": "命名快照库版本不兼容。"}
	var snapshot_values: Variant = root_value.get("snapshots", [])
	if not (snapshot_values is Array) or snapshot_values.size() > SNAPSHOT_LIMIT:
		return {"ok": false, "message": "命名快照数量或结构无效。"}
	var decoded: Array[Dictionary] = []
	var seen_ids := {}
	for index in range(snapshot_values.size()):
		var value: Variant = snapshot_values[index]
		if not (value is Dictionary):
			return {"ok": false, "message": "第 %d 个命名快照结构无效。" % (index + 1)}
		var record: Dictionary = value
		var snapshot_id := str(record.get("snapshot_id", "")).strip_edges()
		if not _is_safe_record_id(snapshot_id) or seen_ids.has(snapshot_id):
			return {"ok": false, "message": "命名快照 ID 无效或重复。"}
		var name := _sanitize_single_line(str(record.get("name", "")), MAX_SNAPSHOT_NAME_LENGTH, "")
		if name.is_empty():
			return {"ok": false, "message": "命名快照缺少名称。"}
		var sandbox_value: Variant = record.get("sandbox", null)
		if not (sandbox_value is Dictionary):
			return {"ok": false, "message": "命名快照缺少沙盘内容。"}
		var sandbox_result := _decode_sandbox_document(sandbox_value, false)
		if not bool(sandbox_result.get("ok", false)) or bool(sandbox_result.get("metadata_migration_required", true)):
			return {"ok": false, "message": "命名快照包含不兼容的沙盘状态。"}
		seen_ids[snapshot_id] = true
		decoded.append({
			"snapshot_id": snapshot_id,
			"name": name,
			"note": _sanitize_multiline(str(record.get("note", "")), MAX_SNAPSHOT_NOTE_LENGTH),
			"created_at": str(record.get("created_at", "")).strip_edges().left(40),
			"sandbox": sandbox_value.duplicate(true)
		})
	return {"ok": true, "snapshots": decoded}


func _build_snapshot_store_document(snapshot_values: Array) -> Dictionary:
	return {
		"snapshot_store_version": SNAPSHOT_STORE_VERSION,
		"snapshots": snapshot_values.duplicate(true),
		"updated_at": Time.get_datetime_string_from_system(false, true)
	}


func _write_snapshot_store(snapshot_values: Array) -> Dictionary:
	if _snapshot_writes_blocked:
		return {"ok": false, "error_code": "snapshot_write_blocked", "message": _snapshot_write_block_reason}
	return _write_json_atomic(snapshot_store_path, _build_snapshot_store_document(snapshot_values), true)


func _create_named_snapshot(snapshot_name: String, snapshot_note: String) -> Dictionary:
	var name := _sanitize_single_line(snapshot_name, MAX_SNAPSHOT_NAME_LENGTH, "")
	if name.is_empty():
		return {"ok": false, "message": "请先给这个快照起一个名字。"}
	if named_snapshots.size() >= SNAPSHOT_LIMIT:
		return {"ok": false, "message": "命名快照已达到 %d 个上限，请先删除不再需要的快照。" % SNAPSHOT_LIMIT}
	if not _save():
		return {"ok": false, "message": "当前沙盘尚未安全保存，暂时不能创建快照。"}
	return _create_named_snapshot_from_payload(name, snapshot_note, _build_sandbox_payload())


func _create_named_snapshot_from_payload(snapshot_name: String, snapshot_note: String, sandbox_payload: Dictionary) -> Dictionary:
	var name := _sanitize_single_line(snapshot_name, MAX_SNAPSHOT_NAME_LENGTH, "")
	if name.is_empty():
		return {"ok": false, "message": "请先给这个快照起一个名字。"}
	if named_snapshots.size() >= SNAPSHOT_LIMIT:
		return {"ok": false, "message": "命名快照已达到 %d 个上限，请先删除不再需要的快照。" % SNAPSHOT_LIMIT}
	var write_validation := _validate_sandbox_payload_for_write(sandbox_payload, true)
	if not bool(write_validation.get("ok", false)):
		return {"ok": false, "message": "当前局面没有通过完整校验，命名快照未创建。"}
	var record := {
		"snapshot_id": _new_record_id("snapshot"),
		"name": name,
		"note": _sanitize_multiline(snapshot_note, MAX_SNAPSHOT_NOTE_LENGTH),
		"created_at": Time.get_datetime_string_from_system(false, true),
		"sandbox": sandbox_payload.duplicate(true)
	}
	var next_snapshots: Array[Dictionary] = named_snapshots.duplicate(true)
	next_snapshots.append(record)
	var result := _write_snapshot_store(next_snapshots)
	if not bool(result.get("ok", false)):
		return result
	named_snapshots = next_snapshots
	return {"ok": true, "snapshot": record.duplicate(true)}


func _quick_situation_bookmark_name(now: Dictionary = {}) -> String:
	var source_now: Dictionary = now if not now.is_empty() else Time.get_datetime_dict_from_system()
	return "%d月%d日 %02d:%02d:%02d 的局面" % [
		int(source_now.get("month", 0)),
		int(source_now.get("day", 0)),
		int(source_now.get("hour", 0)),
		int(source_now.get("minute", 0)),
		int(source_now.get("second", 0)),
	]


func _simulation_state_from_decoded_sandbox(decoded: Dictionary) -> Dictionary:
	return {
		"placements": (decoded.get("placements", {}) as Dictionary).duplicate(true),
		"annotations": (decoded.get("annotations", {}) as Dictionary).duplicate(true),
		"scenario_state": (decoded.get("scenario_state", {}) as Dictionary).duplicate(true),
		"player_strokes": (decoded.get("player_strokes", []) as Array).duplicate(true),
		"character_actions": (decoded.get("character_actions", {}) as Dictionary).duplicate(true),
		"character_troops": (decoded.get("character_troops", {}) as Dictionary).duplicate(true),
	}


func _latest_same_sandbox_snapshot_state() -> Dictionary:
	var current_sandbox_id := str(sandbox_metadata.get("sandbox_id", "")).strip_edges()
	if current_sandbox_id.is_empty():
		return {"found": false}
	for index in range(named_snapshots.size() - 1, -1, -1):
		var record: Dictionary = named_snapshots[index]
		var sandbox_value: Variant = record.get("sandbox", {})
		if not sandbox_value is Dictionary:
			continue
		var decoded := _decode_sandbox_document(sandbox_value, false)
		if not bool(decoded.get("ok", false)):
			continue
		var decoded_metadata: Dictionary = decoded.get("sandbox_metadata", {})
		if str(decoded_metadata.get("sandbox_id", "")).strip_edges() != current_sandbox_id:
			continue
		return {
			"found": true,
			"snapshot_id": str(record.get("snapshot_id", "")),
			"state": _simulation_state_from_decoded_sandbox(decoded),
		}
	return {"found": false}


func _quick_record_change_token(diff: Dictionary, prefix: String, label: String) -> String:
	var added := (diff.get("%s_added" % prefix, []) as Array).size()
	var removed := (diff.get("%s_removed" % prefix, []) as Array).size()
	var changed := (diff.get("%s_changed" % prefix, []) as Array).size()
	if added + removed + changed == 0:
		return ""
	var parts: Array[String] = []
	if added > 0:
		parts.append("+%d" % added)
	if removed > 0:
		parts.append("-%d" % removed)
	if changed > 0:
		parts.append("改%d" % changed)
	return "%s%s" % [label, "/".join(parts)]


func _quick_situation_change_note(diff: Dictionary) -> String:
	var tokens: Array[String] = []
	var count_contract := [
		["placements_added", "摆出"],
		["placements_removed", "收回"],
		["placements_moved", "移动"],
		["troops_changed", "兵力"],
		["actions_changed", "行动"],
		["assignments_changed", "编组"],
		["city_ownership_changed", "城池"],
	]
	for contract_value in count_contract:
		var contract: Array = contract_value
		var count := (diff.get(str(contract[0]), []) as Array).size()
		if count > 0:
			tokens.append("%s%d" % [str(contract[1]), count])
	var faction_token := _quick_record_change_token(diff, "factions", "势力")
	if not faction_token.is_empty():
		tokens.append(faction_token)
	var annotation_token := _quick_record_change_token(diff, "annotations", "标记")
	if not annotation_token.is_empty():
		tokens.append(annotation_token)
	var stroke_token := _quick_record_change_token(diff, "strokes", "推演线")
	if not stroke_token.is_empty():
		tokens.append(stroke_token)
	if tokens.is_empty():
		return "较上次留存：未检测到结构变化。"
	return "较上次留存：%s。" % "、".join(tokens)


func _quick_situation_first_note(current_state: Dictionary) -> String:
	var current_scenario: Dictionary = current_state.get("scenario_state", {})
	return "首次留存：人物%d、势力%d、归属城池%d、标记%d、推演线%d。" % [
		(current_state.get("placements", {}) as Dictionary).size(),
		(current_scenario.get("factions", []) as Array).size(),
		(current_scenario.get("city_ownership", []) as Array).size(),
		(current_state.get("annotations", {}) as Dictionary).size(),
		(current_state.get("player_strokes", []) as Array).size(),
	]


func _build_quick_situation_bookmark_contract(now: Dictionary = {}) -> Dictionary:
	var current_decoded := _decode_sandbox_document(_build_sandbox_payload(), false)
	if not bool(current_decoded.get("ok", false)):
		return {
			"ok": false,
			"message": "当前局面没有通过完整校验，暂时不能留住此刻。",
		}
	var current_state := _simulation_state_from_decoded_sandbox(current_decoded)
	var baseline := _latest_same_sandbox_snapshot_state()
	var note := _quick_situation_first_note(current_state)
	if bool(baseline.get("found", false)):
		var previous_state: Dictionary = baseline.get("state", {})
		note = _quick_situation_change_note(SimulationSessionDiffScript.compare(previous_state, current_state))
	return {
		"ok": true,
		"name": _quick_situation_bookmark_name(now),
		"note": _sanitize_single_line(note, MAX_SNAPSHOT_NOTE_LENGTH, ""),
		"has_baseline": bool(baseline.get("found", false)),
		"baseline_snapshot_id": str(baseline.get("snapshot_id", "")),
	}


func _create_quick_situation_bookmark(now: Dictionary = {}) -> Dictionary:
	var contract := _build_quick_situation_bookmark_contract(now)
	if not bool(contract.get("ok", false)):
		return contract
	var result := _create_named_snapshot(str(contract.get("name", "")), str(contract.get("note", "")))
	if bool(result.get("ok", false)):
		result["contract"] = contract.duplicate(true)
	return result


func _on_quick_situation_bookmark_pressed() -> void:
	var result := _create_quick_situation_bookmark()
	if not bool(result.get("ok", false)):
		_show_message("此刻尚未留住", str(result.get("message", "当前局面没有安全写入。")))
		return
	var record: Dictionary = result.get("snapshot", {})
	_refresh_sandbox_identity_view()
	_set_status("已留住“%s” · 可在命名快照中重命名或导出" % str(record.get("name", "此刻")))


func _rename_named_snapshot(snapshot_id: String, snapshot_name: String) -> Dictionary:
	var name := _sanitize_single_line(snapshot_name, MAX_SNAPSHOT_NAME_LENGTH, "")
	if name.is_empty():
		return {"ok": false, "message": "请先给这个快照起一个名字。"}
	var next_snapshots: Array[Dictionary] = named_snapshots.duplicate(true)
	var found_index := -1
	for index in range(next_snapshots.size()):
		if str(next_snapshots[index].get("snapshot_id", "")) == snapshot_id:
			found_index = index
			break
	if found_index < 0:
		return {"ok": false, "message": "找不到这个命名快照。"}
	var current: Dictionary = next_snapshots[found_index]
	if str(current.get("name", "")) == name:
		return {"ok": true, "unchanged": true, "snapshot": current.duplicate(true)}
	var renamed := current.duplicate(true)
	renamed["name"] = name
	next_snapshots[found_index] = renamed
	var result := _write_snapshot_store(next_snapshots)
	if not bool(result.get("ok", false)):
		return result
	named_snapshots = next_snapshots
	return {"ok": true, "unchanged": false, "snapshot": renamed.duplicate(true)}


func _delete_named_snapshot(snapshot_id: String) -> Dictionary:
	var next_snapshots: Array[Dictionary] = []
	var found := false
	for record in named_snapshots:
		if str(record.get("snapshot_id", "")) == snapshot_id:
			found = true
			continue
		next_snapshots.append(record.duplicate(true))
	if not found:
		return {"ok": false, "message": "找不到这个命名快照。"}
	var result := _write_snapshot_store(next_snapshots)
	if not bool(result.get("ok", false)):
		return result
	named_snapshots = next_snapshots
	return {"ok": true}


func _find_named_snapshot(snapshot_id: String) -> Dictionary:
	for record in named_snapshots:
		if str(record.get("snapshot_id", "")) == snapshot_id:
			return record
	return {}


func _has_character_id(character_id: String) -> bool:
	if character_id.is_empty() or not character_catalog_load_error.is_empty():
		return false
	return character_catalog_ids.has(character_id)


func _character_ids_for_catalog_version(catalog_version: int) -> Array[String]:
	var allowed: Array[String] = []
	if catalog_version == 1:
		for index in range(mini(LEGACY_CHARACTER_CATALOG_COUNT, character_catalog_ids.size())):
			allowed.append(character_catalog_ids[index])
	elif catalog_version == runtime_previous_character_catalog_version:
		for index in range(mini(runtime_previous_character_catalog_count, character_catalog_ids.size())):
			allowed.append(character_catalog_ids[index])
	elif runtime_historical_character_catalog_counts.has(catalog_version):
		var historical_count := int(runtime_historical_character_catalog_counts[catalog_version])
		for index in range(mini(historical_count, character_catalog_ids.size())):
			allowed.append(character_catalog_ids[index])
	elif catalog_version == runtime_current_character_catalog_version:
		allowed = character_catalog_ids.duplicate()
	return allowed


func _sanitize_annotation(value: Dictionary) -> Dictionary:
	var annotation_id := str(value.get("id", "")).strip_edges()
	if annotation_id.is_empty() or str(value.get("kind", "marker")) != "marker":
		return {}
	var marker_type := str(value.get("marker_type", "note"))
	if not ANNOTATION_TYPES.has(marker_type):
		marker_type = "note"
	var label := str(value.get("label", "")).replace("\r", " ").replace("\n", " ").strip_edges().left(24)
	var faction_id := str(value.get("faction_id", "")).strip_edges()
	if not faction_id.is_empty() and not _is_safe_record_id(faction_id):
		faction_id = ""
	return {
		"id": annotation_id,
		"kind": "marker",
		"marker_type": marker_type,
		"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
		"verification_status": ANNOTATION_VERIFICATION_STATUS,
		"x": clampf(float(value.get("x", 0.5)), 0.0, 1.0),
		"y": clampf(float(value.get("y", 0.5)), 0.0, 1.0),
		"label": label,
		"style": _annotation_style_for_type(marker_type),
		"faction_id": faction_id
	}


func _annotation_style_for_type(marker_type: String) -> String:
	return str(ANNOTATION_STYLES.get(marker_type, "amber"))


func _annotation_type_label(marker_type: String) -> String:
	match marker_type:
		"player_place":
			return "玩家自定地点"
		"player_event":
			return "玩家事件"
		_:
			return "战术便签"


func _annotation_type_index(marker_type: String) -> int:
	var index := ANNOTATION_TYPES.find(marker_type)
	return index if index >= 0 else 0


func _update_next_annotation_serial(annotation_id: String) -> void:
	if not annotation_id.begins_with("marker_"):
		return
	var suffix := annotation_id.trim_prefix("marker_")
	if suffix.is_valid_int():
		_next_annotation_serial = maxi(_next_annotation_serial, suffix.to_int() + 1)


func _recalculate_next_annotation_serial() -> void:
	_next_annotation_serial = 1
	for annotation_id in annotations:
		_update_next_annotation_serial(str(annotation_id))


func _new_annotation_id() -> String:
	var annotation_id := "marker_%d" % _next_annotation_serial
	while annotations.has(annotation_id):
		_next_annotation_serial += 1
		annotation_id = "marker_%d" % _next_annotation_serial
	_next_annotation_serial += 1
	return annotation_id


func _save() -> bool:
	var result := _write_runtime_state(placements, annotations, map_board.get_camera_state() if map_board != null else loaded_camera)
	if not bool(result.get("ok", false)):
		if not automated_test_mode:
			push_error("无法写入存档：%s" % str(result.get("message", "未知错误")))
		return false
	return true


func _write_runtime_state(state_placements: Dictionary, state_annotations: Dictionary, camera: Dictionary, state_metadata: Dictionary = {}, state_scenario: Dictionary = {}, state_chronicle: Variant = null, state_player_strokes: Variant = null, state_character_states: Variant = null, state_character_actions: Variant = null, state_character_troops: Variant = null) -> Dictionary:
	if _save_writes_blocked:
		return {
			"ok": false,
			"error_code": "save_write_blocked",
			"message": "检测到无法安全读取的原存档，为避免覆盖已停止自动写入。%s" % ("\n" + _save_write_block_reason if not _save_write_block_reason.is_empty() else "")
		}
	var effective_metadata := sandbox_metadata if state_metadata.is_empty() else state_metadata
	var effective_scenario := scenario_state if state_scenario.is_empty() else state_scenario
	var effective_chronicle: Array = chronicle_entries if state_chronicle == null else state_chronicle
	var effective_player_strokes: Array = player_strokes if state_player_strokes == null else state_player_strokes
	var effective_character_states: Dictionary = character_states if state_character_states == null else state_character_states
	var effective_character_actions: Dictionary = character_actions if state_character_actions == null else state_character_actions
	var effective_character_troops: Dictionary = character_troops if state_character_troops == null else state_character_troops
	return _write_validated_sandbox_payload_atomic(
		save_path,
		_build_sandbox_payload_for(state_placements, state_annotations, camera, effective_metadata, effective_scenario, effective_chronicle, effective_player_strokes, effective_character_states, effective_character_actions, effective_character_troops),
		true
	)


func _build_sandbox_payload() -> Dictionary:
	var camera := map_board.get_camera_state() if map_board != null else loaded_camera
	return _build_sandbox_payload_for(placements, annotations, camera, sandbox_metadata, scenario_state, chronicle_entries, player_strokes, character_states, character_actions, character_troops)


func _build_sandbox_payload_for(state_placements: Dictionary, state_annotations: Dictionary, camera: Dictionary, state_metadata: Dictionary = {}, state_scenario: Dictionary = {}, state_chronicle: Variant = null, state_player_strokes: Variant = null, state_character_states: Variant = null, state_character_actions: Variant = null, state_character_troops: Variant = null) -> Dictionary:
	var cards: Array = []
	var character_ids := state_placements.keys()
	character_ids.sort()
	for character_id_value in character_ids:
		var character_id := str(character_id_value)
		var placement_value: Variant = state_placements.get(character_id, {})
		var placement: Dictionary = placement_value if placement_value is Dictionary else {}
		var card_data := {
			"character_id": character_id,
			"x": float(placement.get("x", 0.5)),
			"y": float(placement.get("y", 0.5))
		}
		var place_id := str(placement.get("place_id", ""))
		if not _find_place(place_id).is_empty():
			card_data["place_id"] = place_id
		cards.append(card_data)
	var saved_annotations: Array = []
	var annotation_ids := state_annotations.keys()
	annotation_ids.sort()
	for annotation_id_value in annotation_ids:
		var annotation_id := str(annotation_id_value)
		var annotation := _sanitize_annotation(state_annotations.get(annotation_id, {}))
		if not annotation.is_empty():
			saved_annotations.append(annotation)
	var raw_scenario: Dictionary = (scenario_state if state_scenario.is_empty() else state_scenario).duplicate(true)
	var scenario_validation := _decode_scenario_state(raw_scenario, true, false)
	var saved_scenario := (scenario_validation.get("scenario_state", raw_scenario) as Dictionary).duplicate(true) if bool(scenario_validation.get("ok", false)) else raw_scenario
	var data := {
		"save_version": runtime_save_version,
		"character_catalog_version": character_catalog_version,
		"metadata": (sandbox_metadata if state_metadata.is_empty() else state_metadata).duplicate(true),
		"scenario_state": saved_scenario,
		"chronicle": _chronicle_payload_for(chronicle_entries if state_chronicle == null else state_chronicle),
		"player_strokes": _player_strokes_payload_for(player_strokes if state_player_strokes == null else state_player_strokes),
		"character_states": _character_states_payload_for(character_states if state_character_states == null else state_character_states),
		"character_actions": _character_actions_payload_for(character_actions if state_character_actions == null else state_character_actions),
		"character_troops": _character_troops_payload_for(character_troops if state_character_troops == null else state_character_troops),
		"map_id": MAP_ID,
		"map_geometry_version": MAP_GEOMETRY_VERSION,
		"camera": camera.duplicate(true),
		"cards": cards,
		"annotations": saved_annotations,
		"updated_at": Time.get_datetime_string_from_system(false, true)
	}
	return data


func _build_sandbox_document() -> Dictionary:
	return _build_sandbox_document_for_payload(_build_sandbox_payload())


func _build_sandbox_document_for_payload(payload: Dictionary, source_snapshot: Dictionary = {}) -> Dictionary:
	var document := {
		"format": SANDBOX_PACKAGE_FORMAT,
		"format_version": SANDBOX_PACKAGE_VERSION,
		"exported_at": Time.get_datetime_string_from_system(false, true),
		"sandbox": payload.duplicate(true)
	}
	if not source_snapshot.is_empty():
		document["snapshot"] = source_snapshot.duplicate(true)
	return document


func _write_sandbox_transfer_file(path: String, allow_overwrite := false) -> Dictionary:
	if _save_writes_blocked:
		return {"ok": false, "error_code": "save_write_blocked", "message": "当前沙盘处于原文件保护状态，暂时不能创建备份。", "path": path}
	return _write_sandbox_payload_transfer_file(path, _build_sandbox_payload(), allow_overwrite)


func _write_named_snapshot_transfer_file(path: String, snapshot_id: String, allow_overwrite := false) -> Dictionary:
	var record := _find_named_snapshot(snapshot_id)
	if record.is_empty():
		return {"ok": false, "error_code": "snapshot_not_found", "message": "找不到这个命名快照。", "path": path}
	var payload_value: Variant = record.get("sandbox", null)
	if not (payload_value is Dictionary):
		return {"ok": false, "error_code": "invalid_snapshot", "message": "这个快照的沙盘内容无效。", "path": path}
	var decode_result := _decode_sandbox_document(payload_value, false)
	if not bool(decode_result.get("ok", false)) or bool(decode_result.get("metadata_migration_required", true)):
		return {"ok": false, "error_code": "invalid_snapshot", "message": "这个快照无法安全导出。", "path": path}
	var payload_metadata: Dictionary = payload_value.get("metadata", {})
	var source_snapshot := {
		"snapshot_id": str(record.get("snapshot_id", "")),
		"name": str(record.get("name", "")),
		"note": str(record.get("note", "")),
		"created_at": str(record.get("created_at", "")),
		"source_sandbox_id": str(payload_metadata.get("sandbox_id", ""))
	}
	return _write_sandbox_payload_transfer_file(path, payload_value, allow_overwrite, source_snapshot, false)


func _write_sandbox_payload_transfer_file(path: String, payload: Dictionary, allow_overwrite := false, source_snapshot: Dictionary = {}, require_current_version := true) -> Dictionary:
	var target_path := path
	if not target_path.to_lower().ends_with(".tianxia"):
		target_path += ".tianxia"
	var validation := _validate_sandbox_payload_for_write(payload, require_current_version)
	if not bool(validation.get("ok", false)):
		validation["path"] = target_path
		return validation
	var result := _write_json_atomic(target_path, _build_sandbox_document_for_payload(payload, source_snapshot), allow_overwrite)
	result["path"] = target_path
	return result


func _validate_sandbox_payload_for_write(payload: Dictionary, require_current_version := true) -> Dictionary:
	var validation := _decode_sandbox_document(payload, false)
	if not bool(validation.get("ok", false)):
		return {
			"ok": false,
			"error_code": "invalid_runtime_payload",
			"message": "沙盘内容没有通过完整写前校验，原文件没有变化。\n%s" % str(validation.get("message", "沙盘结构无效。"))
		}
	if bool(validation.get("metadata_migration_required", true)):
		return {
			"ok": false,
			"error_code": "invalid_runtime_payload",
			"message": "沙盘缺少可继续编辑的稳定身份，原文件没有变化。"
		}
	if require_current_version:
		if (
			int(validation.get("source_save_version", 0)) != runtime_save_version
			or bool(validation.get("scenario_color_migration_required", true))
			or bool(validation.get("chronicle_migration_required", true))
			or bool(validation.get("player_stroke_migration_required", true))
			or bool(validation.get("character_state_migration_required", true))
			or bool(validation.get("character_action_migration_required", true))
			or bool(validation.get("character_troop_migration_required", true))
			or bool(validation.get("character_catalog_migration_required", true))
			or bool(validation.get("geometry_migration_required", true))
			or bool(validation.get("save_version_migration_required", true))
		):
			return {
				"ok": false,
				"error_code": "invalid_runtime_payload",
				"message": "准备写入的沙盘不是完整 v%d 状态，原文件没有变化。" % runtime_save_version
			}
		var warnings: Array = validation.get("warnings", [])
		if not warnings.is_empty():
			return {
				"ok": false,
				"error_code": "invalid_runtime_payload",
				"message": "准备写入的沙盘需要兼容修正，已拒绝静默写入。\n%s" % str(warnings[0])
			}
	return {"ok": true, "error_code": "", "message": "", "validation": validation}


func _write_validated_sandbox_payload_atomic(path: String, payload: Dictionary, allow_overwrite: bool) -> Dictionary:
	var validation := _validate_sandbox_payload_for_write(payload, true)
	if not bool(validation.get("ok", false)):
		validation["path"] = path
		return validation
	if ProjectSettings.globalize_path(path) == ProjectSettings.globalize_path(save_path):
		return _write_primary_sandbox_payload_atomic(path, payload, allow_overwrite)
	return _write_json_atomic(path, payload, allow_overwrite)


func _write_exact_bytes_atomic(
	path: String,
	bytes: PackedByteArray,
	allow_overwrite: bool,
	require_sandbox := false,
	expected_target: Dictionary = {}
) -> Dictionary:
	var absolute_path := ProjectSettings.globalize_path(path)
	var has_target_expectation := expected_target.has("exists")
	var expected_target_exists := bool(expected_target.get("exists", false))
	var expected_target_sha256 := str(expected_target.get("sha256", ""))
	if has_target_expectation and expected_target_exists and expected_target_sha256.is_empty():
		return {"ok": false, "error_code": "invalid_expectation", "message": "无法确认恢复前主档的校验值。"}
	if bytes.is_empty() or bytes.size() > MAX_IMPORT_FILE_BYTES:
		return {"ok": false, "error_code": "invalid_bytes", "message": "准备保留的文件为空或超过安全上限。"}
	if FileAccess.file_exists(absolute_path) and not allow_overwrite:
		return {"ok": false, "error_code": "target_exists", "message": "目标文件已经存在。"}
	var parent_dir := absolute_path.get_base_dir()
	if parent_dir.is_empty() or DirAccess.make_dir_recursive_absolute(parent_dir) != OK:
		return {"ok": false, "error_code": "write_failed", "message": "无法创建目标文件夹。"}
	var source_hash := _sha256_hex(bytes)
	if source_hash.is_empty():
		return {"ok": false, "error_code": "hash_failed", "message": "无法计算文件校验值。"}
	var temp_path := "%s.write-%d.tmp" % [absolute_path, Time.get_ticks_usec()]
	var temp_file := FileAccess.open(temp_path, FileAccess.WRITE)
	if temp_file == null:
		return {"ok": false, "error_code": "write_failed", "message": "无法在目标文件夹中写入文件。"}
	temp_file.store_buffer(bytes)
	temp_file.flush()
	var write_error := temp_file.get_error()
	temp_file = null
	if write_error != OK:
		DirAccess.remove_absolute(temp_path)
		return {"ok": false, "error_code": "write_failed", "message": "保留文件写入失败，原文件没有变化。"}
	var verify_file := FileAccess.open(temp_path, FileAccess.READ)
	if verify_file == null:
		DirAccess.remove_absolute(temp_path)
		return {"ok": false, "error_code": "verify_failed", "message": "无法复核刚写入的保留文件。"}
	var verify_bytes := verify_file.get_buffer(verify_file.get_length())
	verify_file = null
	if verify_bytes.size() != bytes.size() or _sha256_hex(verify_bytes) != source_hash:
		DirAccess.remove_absolute(temp_path)
		return {"ok": false, "error_code": "verify_failed", "message": "保留文件逐字节复核失败。"}
	if require_sandbox:
		var decoded := _read_sandbox_transfer_file(temp_path, false)
		if not bool(decoded.get("ok", false)) or str(decoded.get("source_format", "")) != "raw_save":
			DirAccess.remove_absolute(temp_path)
			return {"ok": false, "error_code": "verify_failed", "message": "保留文件没有通过完整沙盘校验。"}

	var replacement_path := ""
	if FileAccess.file_exists(absolute_path):
		replacement_path = "%s.replace-%d.tmp" % [absolute_path, Time.get_ticks_usec()]
		if DirAccess.rename_absolute(absolute_path, replacement_path) != OK:
			DirAccess.remove_absolute(temp_path)
			return {"ok": false, "error_code": "write_failed", "message": "现有保留文件正在使用，没有进行替换。"}
	if has_target_expectation:
		var target_matches := replacement_path.is_empty() == not expected_target_exists
		if target_matches and expected_target_exists:
			var replacement_identity := _read_file_identity(replacement_path)
			target_matches = (
				bool(replacement_identity.get("ok", false))
				and str(replacement_identity.get("sha256", "")) == expected_target_sha256
			)
		if not target_matches:
			DirAccess.remove_absolute(temp_path)
			var restore_error := OK
			if not replacement_path.is_empty():
				if FileAccess.file_exists(absolute_path):
					restore_error = ERR_ALREADY_EXISTS
				else:
					restore_error = DirAccess.rename_absolute(replacement_path, absolute_path)
			if restore_error != OK:
				return {
					"ok": false,
					"error_code": "recovery_required",
					"message": "当前主档在恢复提交前发生变化；较新的文件仍保留在临时恢复位置。",
					"recovery_path": replacement_path
				}
			return {
				"ok": false,
				"error_code": "target_changed",
				"message": "当前主档在恢复提交前发生变化，本次没有覆盖。"
			}
	var promote_error := DirAccess.rename_absolute(temp_path, absolute_path)
	if promote_error != OK:
		var restore_error := OK
		if not replacement_path.is_empty():
			restore_error = DirAccess.rename_absolute(replacement_path, absolute_path)
		DirAccess.remove_absolute(temp_path)
		if restore_error != OK:
			return {
				"ok": false,
				"error_code": "recovery_required",
				"message": "保留文件替换失败，上一份仍在临时恢复位置。",
				"recovery_path": replacement_path
			}
		return {"ok": false, "error_code": "write_failed", "message": "保留文件替换失败，上一份仍然保留。"}
	if (
		automated_test_mode
		and absolute_path == ProjectSettings.globalize_path(save_path)
		and _automated_atomic_write_failure_stage == "exact_after_promote_replace"
	):
		var injected_file := FileAccess.open(absolute_path, FileAccess.WRITE)
		if injected_file != null:
			injected_file.store_buffer(_automated_exact_write_post_promote_bytes)
			injected_file.flush()
			injected_file = null
	var promoted_identity := _read_file_identity(absolute_path)
	if (
		not bool(promoted_identity.get("ok", false))
		or not bool(promoted_identity.get("exists", false))
		or int(promoted_identity.get("byte_count", -1)) != bytes.size()
		or str(promoted_identity.get("sha256", "")) != source_hash
	):
		if not replacement_path.is_empty():
			return {
				"ok": false,
				"error_code": "recovery_required",
				"message": "新文件提升后发生变化；当前主路径和上一份文件均已保留，未自动选边。",
				"recovery_path": replacement_path,
				"observed_path": absolute_path
			}
		return {
			"ok": false,
			"error_code": "verify_failed",
			"message": "新文件提升后没有通过逐字节复核；当前主路径保持不变。",
			"observed_path": absolute_path
		}
	if not replacement_path.is_empty():
		DirAccess.remove_absolute(replacement_path)
	return {
		"ok": true,
		"error_code": "",
		"message": "",
		"path": absolute_path,
		"byte_count": bytes.size(),
		"sha256": source_hash
	}


func _refresh_primary_last_good(path: String) -> Dictionary:
	var absolute_path := ProjectSettings.globalize_path(path)
	var decoded := _read_sandbox_transfer_file(absolute_path, false)
	if not bool(decoded.get("ok", false)) or str(decoded.get("source_format", "")) != "raw_save":
		return {
			"ok": false,
			"error_code": "last_good_source_invalid",
			"message": "当前沙盘未通过完整校验，未改写上一份可靠沙盘。"
		}
	if automated_test_mode and _automated_last_good_failure_stage == "before_write":
		return {
			"ok": false,
			"error_code": "last_good_write_failed",
			"message": "自动化故障注入：上一份可靠沙盘写入前停止。"
		}
	var source_file := FileAccess.open(absolute_path, FileAccess.READ)
	if source_file == null:
		return {"ok": false, "error_code": "last_good_read_failed", "message": "无法读取当前沙盘以建立保护副本。"}
	var source_bytes := source_file.get_buffer(source_file.get_length())
	source_file = null
	var result := _write_exact_bytes_atomic(_primary_last_good_path(path), source_bytes, true, true)
	if not bool(result.get("ok", false)):
		result["message"] = "上一份可靠沙盘没有安全写入，当前沙盘未被替换。\n%s" % str(result.get("message", ""))
	return result


func _write_primary_sandbox_payload_atomic(path: String, payload: Dictionary, allow_overwrite: bool) -> Dictionary:
	var absolute_path := ProjectSettings.globalize_path(path)
	var primary_exists := FileAccess.file_exists(absolute_path)
	if primary_exists and not allow_overwrite:
		return {"ok": false, "error_code": "target_exists", "message": "目标文件已经存在。"}
	if primary_exists:
		var current := _read_sandbox_transfer_file(absolute_path, false)
		if not bool(current.get("ok", false)) or str(current.get("source_format", "")) != "raw_save":
			return {
				"ok": false,
				"error_code": "primary_invalid",
				"message": "当前沙盘没有通过完整校验；为保护原文件，本次没有覆盖。"
			}
		var last_good_result := _refresh_primary_last_good(path)
		if not bool(last_good_result.get("ok", false)):
			return last_good_result
	var write_result := _write_json_atomic(path, payload, allow_overwrite)
	if not bool(write_result.get("ok", false)):
		return write_result
	if not primary_exists:
		var initial_last_good := _refresh_primary_last_good(path)
		if not bool(initial_last_good.get("ok", false)):
			write_result["warning_code"] = "last_good_unavailable"
			write_result["warning_message"] = "当前沙盘已保存，但暂时未能建立第一份保护副本。"
	return write_result


func _write_json_atomic(path: String, data: Dictionary, allow_overwrite: bool) -> Dictionary:
	var absolute_path := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(absolute_path) and not allow_overwrite:
		return {"ok": false, "error_code": "target_exists", "message": "目标文件已经存在。"}
	var parent_dir := absolute_path.get_base_dir()
	if parent_dir.is_empty():
		return {"ok": false, "error_code": "invalid_path", "message": "保存位置无效。"}
	var directory_error := DirAccess.make_dir_recursive_absolute(parent_dir)
	if directory_error != OK:
		return {"ok": false, "error_code": "write_failed", "message": "无法创建目标文件夹。"}
	var temp_path := "%s.write-%d.tmp" % [absolute_path, Time.get_ticks_usec()]
	var temp_file := FileAccess.open(temp_path, FileAccess.WRITE)
	if temp_file == null:
		return {"ok": false, "error_code": "write_failed", "message": "无法在目标文件夹中写入文件。"}
	temp_file.store_string(JSON.stringify(data, "\t"))
	temp_file.flush()
	var write_error := temp_file.get_error()
	temp_file = null
	if write_error != OK:
		DirAccess.remove_absolute(temp_path)
		return {"ok": false, "error_code": "write_failed", "message": "写入过程中发生错误，原文件没有变化。"}
	var verify_file := FileAccess.open(temp_path, FileAccess.READ)
	if verify_file == null:
		DirAccess.remove_absolute(temp_path)
		return {"ok": false, "error_code": "write_failed", "message": "无法校验刚写入的文件。"}
	var verify_parser := JSON.new()
	if verify_parser.parse(verify_file.get_as_text()) != OK or not (verify_parser.data is Dictionary):
		verify_file = null
		DirAccess.remove_absolute(temp_path)
		return {"ok": false, "error_code": "write_failed", "message": "写入校验失败，原文件没有变化。"}
	verify_file = null
	if automated_test_mode and _automated_atomic_write_failure_stage == "before_replace":
		DirAccess.remove_absolute(temp_path)
		return {
			"ok": false,
			"error_code": "write_failed",
			"message": "自动化故障注入：替换前停止，原文件没有变化。"
		}

	var replacement_path := ""
	if FileAccess.file_exists(absolute_path):
		replacement_path = "%s.replace-%d.tmp" % [absolute_path, Time.get_ticks_usec()]
		var move_old_error := DirAccess.rename_absolute(absolute_path, replacement_path)
		if move_old_error != OK:
			DirAccess.remove_absolute(temp_path)
			return {"ok": false, "error_code": "write_failed", "message": "现有文件正在使用，未进行覆盖。"}
	if (
		automated_test_mode
		and absolute_path == ProjectSettings.globalize_path(save_path)
		and _automated_atomic_write_failure_stage == "interrupt_after_old_moved"
		and not replacement_path.is_empty()
	):
		return {
			"ok": false,
			"error_code": "simulated_interruption",
			"message": "自动化故障注入：旧沙盘移至保护位置后中断。",
			"recovery_path": replacement_path,
			"uncommitted_path": temp_path
		}
	var inject_promote_failure := (
		automated_test_mode
		and _automated_atomic_write_failure_stage in ["promote", "promote_and_restore"]
	)
	var promote_error := ERR_CANT_CREATE if inject_promote_failure else DirAccess.rename_absolute(temp_path, absolute_path)
	if promote_error != OK:
		var restore_error := OK
		if not replacement_path.is_empty():
			if automated_test_mode and _automated_atomic_write_failure_stage == "promote_and_restore":
				restore_error = ERR_CANT_CREATE
			else:
				restore_error = DirAccess.rename_absolute(replacement_path, absolute_path)
		DirAccess.remove_absolute(temp_path)
		if restore_error != OK:
			return {
				"ok": false,
				"error_code": "recovery_required",
				"message": "替换文件失败，原文件保留在临时恢复位置，请勿关闭程序并联系维护者。",
				"recovery_path": replacement_path
			}
		return {"ok": false, "error_code": "write_failed", "message": "替换文件失败，原文件已保留。"}
	if (
		automated_test_mode
		and absolute_path == ProjectSettings.globalize_path(save_path)
		and _automated_atomic_write_failure_stage == "interrupt_after_new_promoted_before_cleanup"
		and not replacement_path.is_empty()
	):
		return {
			"ok": false,
			"error_code": "simulated_interruption",
			"message": "自动化故障注入：新沙盘已经提升，旧沙盘清理前中断。",
			"recovery_path": replacement_path
		}
	if not replacement_path.is_empty():
		DirAccess.remove_absolute(replacement_path)
	return {"ok": true, "error_code": "", "message": "", "path": path}


func _timestamp_slug() -> String:
	var now := Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d_%02d%02d%02d_%06d" % [
		int(now.get("year", 0)), int(now.get("month", 0)), int(now.get("day", 0)),
		int(now.get("hour", 0)), int(now.get("minute", 0)), int(now.get("second", 0)),
		Time.get_ticks_usec() % 1000000
	]


func _sha256_hex(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	if context.update(bytes) != OK:
		return ""
	return context.finish().hex_encode()


func _read_file_identity(path: String) -> Dictionary:
	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		return {"ok": true, "exists": false, "sha256": "", "byte_count": 0}
	var file := FileAccess.open(absolute_path, FileAccess.READ)
	if file == null:
		return {"ok": false, "exists": true, "sha256": "", "byte_count": 0}
	var byte_count := file.get_length()
	var file_bytes := file.get_buffer(byte_count)
	file = null
	var file_hash := _sha256_hex(file_bytes)
	return {
		"ok": not file_hash.is_empty(),
		"exists": true,
		"sha256": file_hash,
		"byte_count": byte_count
	}


func _validate_primary_recovery_commit_preconditions(
	candidate_path: String,
	expected_candidate_sha256: String,
	expected_primary_exists: bool,
	expected_primary_sha256: String
) -> Dictionary:
	var candidate_identity := _read_file_identity(candidate_path)
	if (
		not bool(candidate_identity.get("ok", false))
		or not bool(candidate_identity.get("exists", false))
		or expected_candidate_sha256.is_empty()
		or str(candidate_identity.get("sha256", "")) != expected_candidate_sha256
	):
		return {
			"ok": false,
			"error_code": "candidate_changed",
			"message": "上一份沙盘在原始文件备份期间发生变化。"
		}
	var primary_identity := _read_file_identity(save_path)
	if not bool(primary_identity.get("ok", false)):
		return {
			"ok": false,
			"error_code": "primary_unreadable",
			"message": "当前主档在恢复提交前无法重新读取。"
		}
	if bool(primary_identity.get("exists", false)) != expected_primary_exists:
		return {
			"ok": false,
			"error_code": "primary_changed",
			"message": "当前主档在原始文件备份期间发生变化。"
		}
	if expected_primary_exists and (
		expected_primary_sha256.is_empty()
		or str(primary_identity.get("sha256", "")) != expected_primary_sha256
	):
		return {
			"ok": false,
			"error_code": "primary_changed",
			"message": "当前主档在原始文件备份期间发生变化。"
		}
	return {"ok": true, "error_code": "", "message": ""}


func _create_raw_migration_backup(
	path: String,
	source_save_version: int,
	source_catalog_version: int,
	file_prefix := "sandbox"
) -> Dictionary:
	var absolute_source := ProjectSettings.globalize_path(path)
	var source_file := FileAccess.open(absolute_source, FileAccess.READ)
	if source_file == null:
		return {"ok": false, "error_code": "migration_backup_read_failed", "message": "无法读取迁移前原文件。"}
	var source_bytes := source_file.get_buffer(source_file.get_length())
	source_file = null
	var source_hash := _sha256_hex(source_bytes)
	if source_hash.is_empty():
		return {"ok": false, "error_code": "migration_backup_hash_failed", "message": "无法计算迁移前原文件校验值。"}
	var absolute_backup_root := ProjectSettings.globalize_path(backup_dir)
	if FileAccess.file_exists(absolute_backup_root):
		return {"ok": false, "error_code": "migration_backup_dir_failed", "message": "备份位置被同名文件占用，无法创建迁移备份目录。"}
	var raw_backup_dir := backup_dir.path_join("migration_raw")
	var absolute_backup_dir := ProjectSettings.globalize_path(raw_backup_dir)
	if DirAccess.make_dir_recursive_absolute(absolute_backup_dir) != OK:
		return {"ok": false, "error_code": "migration_backup_dir_failed", "message": "无法创建迁移备份目录。"}
	var filename := "%s_pre_v%d_catalog_v%d_%s.json.raw" % [
		file_prefix,
		source_save_version,
		source_catalog_version,
		_timestamp_slug()
	]
	var backup_path := raw_backup_dir.path_join(filename)
	var absolute_backup_path := ProjectSettings.globalize_path(backup_path)
	if FileAccess.file_exists(absolute_backup_path):
		return {"ok": false, "error_code": "migration_backup_exists", "message": "迁移备份目标已存在。"}
	var backup_file := FileAccess.open(absolute_backup_path, FileAccess.WRITE)
	if backup_file == null:
		return {"ok": false, "error_code": "migration_backup_write_failed", "message": "无法写入迁移备份。"}
	backup_file.store_buffer(source_bytes)
	backup_file.flush()
	var write_error := backup_file.get_error()
	backup_file = null
	if write_error != OK:
		DirAccess.remove_absolute(absolute_backup_path)
		return {"ok": false, "error_code": "migration_backup_write_failed", "message": "迁移备份写入失败。"}
	var verify_file := FileAccess.open(absolute_backup_path, FileAccess.READ)
	if verify_file == null:
		DirAccess.remove_absolute(absolute_backup_path)
		return {"ok": false, "error_code": "migration_backup_verify_failed", "message": "无法复核迁移备份。"}
	var verify_bytes := verify_file.get_buffer(verify_file.get_length())
	verify_file = null
	if verify_bytes.size() != source_bytes.size() or _sha256_hex(verify_bytes) != source_hash:
		DirAccess.remove_absolute(absolute_backup_path)
		return {"ok": false, "error_code": "migration_backup_verify_failed", "message": "迁移备份逐字节复核失败。"}
	return {
		"ok": true,
		"path": backup_path,
		"byte_count": source_bytes.size(),
		"sha256": source_hash
	}


func _create_internal_backup(reason: String) -> Dictionary:
	var filename := "三国推演志_%s_%s.tianxia" % [reason, _timestamp_slug()]
	var path := backup_dir.path_join(filename)
	var result := _write_sandbox_payload_transfer_file(path, _build_sandbox_payload(), false, {}, true)
	result["path"] = path
	return result


func _refresh_views() -> void:
	if map_board != null:
		map_board.set_scenario_context(_current_scenario_context_contract())
		map_board.set_scenario_state(scenario_state)
		map_board.set_character_states(_display_character_attributes())
		map_board.set_character_actions(character_actions)
		map_board.set_character_troops(character_troops)
		map_board.set_character_portraits(character_portraits_by_id)
		map_board.set_placements(placements)
		map_board.set_annotations(annotations)
		map_board.set_player_strokes(player_strokes)
	if backpack != null:
		backpack.set_scenario_focus(
			str(scenario_state.get("scenario_id", "custom_blank")),
			str(scenario_state.get("era_label", "完全自定义")),
			scenario_state.get("featured_character_ids", []),
			str(scenario_state.get("scenario_kind", SCENARIO_KIND_CUSTOM)) == SCENARIO_KIND_HISTORICAL_START,
			false
		)
		backpack.set_scenario_take_guidance(
			_scenario_take_guidance_for_state(),
			false
		)
		backpack.set_placed(placements)
	_sync_city_ownership_tool_after_scenario_change()


func _scenario_take_guidance_for_state() -> Dictionary:
	var scenario_id := str(scenario_state.get("scenario_id", "")).strip_edges()
	if scenario_id.is_empty():
		return {}
	for template in scenario_templates:
		if str(template.get("scenario_id", "")).strip_edges() != scenario_id:
			continue
		var guidance_value: Variant = template.get("take_guidance", {})
		return guidance_value.duplicate(true) if guidance_value is Dictionary else {}
	return {}


func _current_scenario_context_contract() -> Dictionary:
	var year_value: Variant = scenario_state.get("start_year", null)
	var matched_year := int(year_value) if _is_integer_number(year_value) else 0
	var era_label := str(scenario_state.get("era_label", "完全自定义")).strip_edges()
	var scenario_id := str(scenario_state.get("scenario_id", "custom_blank")).strip_edges()
	var label := era_label
	if matched_year > 0:
		label = "%s · %d" % [era_label, matched_year]
	return {
		"year": matched_year,
		"label": label,
		"scenario_name": era_label,
		"scenario_id": scenario_id,
		"source": str(sandbox_metadata.get("scenario_source", "")).strip_edges()
	}


func _collapse_backpack() -> void:
	if backpack_host == null or backpack == null or backpack_restore_button == null or backpack_collapsed:
		return
	backpack_collapsed = true
	backpack.visible = false
	backpack_restore_button.visible = true
	backpack_host.custom_minimum_size = Vector2(64, 0)
	backpack_restore_button.grab_focus()
	_set_status("人物背包已收起；点击左侧窄栏可重新展开")


func _expand_backpack() -> void:
	if backpack_host == null or backpack == null or backpack_restore_button == null or not backpack_collapsed:
		return
	backpack_collapsed = false
	backpack_restore_button.visible = false
	backpack.visible = true
	backpack_host.custom_minimum_size = Vector2(292, 0)
	if backpack.get_search_edit() != null:
		backpack.get_search_edit().grab_focus()
	_set_status("人物背包已展开")


func get_backpack_layout_contract() -> Dictionary:
	return {
		"collapsed": backpack_collapsed,
		"host_width": backpack_host.size.x if backpack_host != null else 0.0,
		"backpack_visible": backpack != null and backpack.visible,
		"restore_visible": backpack_restore_button != null and backpack_restore_button.visible
	}


func _refresh_sandbox_identity_view() -> void:
	var title := str(sandbox_metadata.get("title", "未命名沙盘"))
	if map_board != null:
		map_board.set_scenario_context(_current_scenario_context_contract())
	if sandbox_subtitle_label != null:
		sandbox_subtitle_label.text = (
			"%s · 自由推演 · 80 人隔离 v16" % title
			if isolated_catalog_v4_runtime
			else "%s · 自由推演" % title
		)
		var tooltip_lines: Array[String] = ["沙盘：%s" % title]
		if isolated_catalog_v4_runtime:
			tooltip_lines.append("目录 v4／80 人 · 独立测试存档")
		var source := str(sandbox_metadata.get("scenario_source", ""))
		var note := str(sandbox_metadata.get("note", ""))
		if not source.is_empty():
			tooltip_lines.append("开局来源：%s" % source)
		if not note.is_empty():
			tooltip_lines.append(note)
		if not (scenario_state.get("factions", []) as Array).is_empty():
			tooltip_lines.append("当前玩法分组（玩家设定）：\n%s" % _template_faction_summary(scenario_state))
		if not chronicle_entries.is_empty():
			tooltip_lines.append("玩家纪事：%d 则" % chronicle_entries.size())
		if not player_strokes.is_empty():
			tooltip_lines.append("玩家推演线：%d 条" % player_strokes.size())
		sandbox_subtitle_label.tooltip_text = "\n".join(tooltip_lines)
	if sandbox_file_menu != null:
		var popup := sandbox_file_menu.get_popup()
		var item_index := popup.get_item_index(4)
		if item_index >= 0:
			popup.set_item_text(item_index, "查看命名快照（%d）…" % named_snapshots.size())


func _open_sandbox_info_dialog() -> void:
	sandbox_title_input.text = str(sandbox_metadata.get("title", "未命名沙盘"))
	sandbox_note_input.text = str(sandbox_metadata.get("note", ""))
	sandbox_source_input.text = str(sandbox_metadata.get("scenario_source", ""))
	sandbox_info_summary_label.text = "当前内容：人物 %d 张 · 标记 %d 个 · 推演线 %d 条 · 玩法分组 %d 组 · 玩家纪事 %d 则 · 行动标注 %d 人" % [placements.size(), annotations.size(), player_strokes.size(), (scenario_state.get("factions", []) as Array).size(), chronicle_entries.size(), character_actions.size()]
	sandbox_info_dialog.popup_centered(Vector2i(540, 420))
	sandbox_title_input.grab_focus()
	sandbox_title_input.select_all()


func _confirm_sandbox_info() -> void:
	var next_metadata := sandbox_metadata.duplicate(true)
	next_metadata["title"] = _sanitize_single_line(sandbox_title_input.text, MAX_SANDBOX_TITLE_LENGTH, "未命名沙盘")
	next_metadata["note"] = _sanitize_multiline(sandbox_note_input.text, MAX_SANDBOX_NOTE_LENGTH)
	next_metadata["scenario_source"] = _sanitize_single_line(sandbox_source_input.text, MAX_SANDBOX_SOURCE_LENGTH, "")
	if _sandbox_metadata_match(sandbox_metadata, next_metadata):
		_set_status("沙盘信息没有变化")
		return
	_commit_sandbox_metadata(next_metadata, "编辑沙盘信息", "沙盘信息已更新 · 可撤销")


func _default_personal_template_name() -> String:
	var suffix := " · 起步"
	var base := _sanitize_single_line(str(sandbox_metadata.get("title", "我的沙盘")), MAX_PERSONAL_TEMPLATE_NAME_LENGTH, "我的沙盘")
	if base.ends_with(suffix):
		return base
	return "%s%s" % [base.left(maxi(1, MAX_PERSONAL_TEMPLATE_NAME_LENGTH - suffix.length())), suffix]


func _personal_template_position_counts() -> Dictionary:
	var anchored := 0
	var free := 0
	for placement_value in placements.values():
		var placement: Dictionary = placement_value
		if not _find_place(str(placement.get("place_id", ""))).is_empty():
			anchored += 1
		else:
			free += 1
	return {"anchored": anchored, "free": free}


func _open_personal_template_create_dialog() -> void:
	if personal_template_create_dialog == null:
		return
	_personal_template_create_mode = "store"
	personal_template_create_dialog.title = "保存为我的起步模板"
	personal_template_create_dialog.ok_button_text = "保存模板"
	personal_template_create_dialog.cancel_button_text = "取消"
	personal_template_create_hint_label.text = "保存后可在“新建沙盘”中反复使用；当前沙盘保持原样。"
	personal_template_name_input.text = _default_personal_template_name()
	personal_template_description_input.text = _sanitize_multiline(str(sandbox_metadata.get("note", "")), MAX_PERSONAL_TEMPLATE_DESCRIPTION_LENGTH)
	var counts := _personal_template_position_counts()
	personal_template_create_summary_label.text = (
		"将保存：人物 %d 张 · 标记 %d 个 · 起始势力 %d 组\n"
		+ "其中：%d 人驻于地点 · %d 人保留自由位置\n"
		+ "模板保存地图人物及其势力、驻点／自由位置和玩家标记。新建时人物从待命开始并回到全图视角；沙盘身份、当前视角、命名快照、撤销记录、人物收藏、推演线、纪事和当前行动留在原沙盘。"
	) % [
		placements.size(), annotations.size(), (_filtered_personal_template_scenario_state().get("factions", []) as Array).size(),
		int(counts.get("anchored", 0)), int(counts.get("free", 0))
	]
	personal_template_create_dialog.get_ok_button().disabled = _personal_template_writes_blocked or _save_writes_blocked or personal_scenario_templates.size() >= PERSONAL_TEMPLATE_LIMIT
	personal_template_create_dialog.popup_centered(Vector2i(540, 390))
	personal_template_name_input.grab_focus()
	personal_template_name_input.select_all()


func _open_scenario_share_export_dialog() -> void:
	if personal_template_create_dialog == null:
		return
	_personal_template_create_mode = "share"
	personal_template_create_dialog.title = "导出当前开局包"
	personal_template_create_dialog.ok_button_text = "选择导出位置"
	personal_template_create_dialog.cancel_button_text = "取消"
	personal_template_create_hint_label.text = "把当前摆好的开局交给别人；对方预览并确认后，会从它建立一个独立新沙盘。"
	personal_template_name_input.text = _default_personal_template_name()
	personal_template_description_input.text = _sanitize_multiline(str(sandbox_metadata.get("note", "")), MAX_PERSONAL_TEMPLATE_DESCRIPTION_LENGTH)
	var counts := _personal_template_position_counts()
	var filtered_state := _filtered_personal_template_scenario_state()
	personal_template_create_summary_label.text = (
		"将导出：人物 %d 张 · 标记 %d 个 · 势力 %d 组 · 归属城池 %d 座\n"
		+ "其中：%d 人驻于地点 · %d 人保留自由位置\n"
		+ "开局包保存以上开局内容。当前视角、沙盘身份、快照、推演线、纪事、兵力、四维、行动、撤销记录、收藏、脚本和 AI 指令留在原沙盘。"
	) % [
		placements.size(), annotations.size(), (filtered_state.get("factions", []) as Array).size(),
		(filtered_state.get("city_ownership", []) as Array).size(), int(counts.get("anchored", 0)), int(counts.get("free", 0))
	]
	personal_template_create_dialog.get_ok_button().disabled = _save_writes_blocked
	personal_template_create_dialog.popup_centered(Vector2i(540, 390))
	personal_template_name_input.grab_focus()
	personal_template_name_input.select_all()


func _confirm_create_personal_template() -> void:
	if _personal_template_create_mode == "share":
		var build_result := _build_current_personal_template_record(
			personal_template_name_input.text,
			personal_template_description_input.text,
			true
		)
		if not bool(build_result.get("ok", false)):
			_show_message("开局包没有生成", "%s\n\n当前沙盘和已有文件都没有变化。" % str(build_result.get("message", "开局内容无效。")))
			return
		_pending_scenario_share_template = (build_result.get("template", {}) as Dictionary).duplicate(true)
		_pending_file_export_mode = "scenario_share"
		_pending_export_path = ""
		_pending_export_snapshot_id = ""
		export_dialog.title = "导出开局分享包"
		export_dialog.filters = PackedStringArray(["*.sanguostart ; 三国推演志开局包"])
		export_dialog.current_file = "%s.sanguostart" % _safe_filename_component(str(_pending_scenario_share_template.get("name", "未命名开局")))
		export_dialog.call_deferred("popup_centered", Vector2i(900, 640))
		return
	var result := _create_personal_scenario_template(personal_template_name_input.text, personal_template_description_input.text)
	if not bool(result.get("ok", false)):
		_show_message("个人模板没有保存", "%s\n\n当前沙盘和已有模板都没有变化。" % str(result.get("message", "无法安全写入个人模板库。")))
		return
	var template: Dictionary = result.get("template", {})
	_set_status("已保存个人模板“%s”，可在“新建沙盘”中使用" % str(template.get("name", "未命名模板")))


func _request_edit_selected_personal_template() -> void:
	if _pending_scenario_template_source != "personal":
		return
	var template_id := _pending_scenario_template_id
	new_sandbox_dialog.hide()
	call_deferred("_open_personal_template_edit_dialog", template_id)


func _open_personal_template_edit_dialog(template_id: String) -> void:
	if personal_template_edit_dialog == null:
		return
	var template := _find_personal_scenario_template(template_id)
	if template.is_empty():
		_pending_edit_personal_template_id = ""
		_show_message("无法编辑模板", "这个个人模板已经不存在；当前沙盘和模板库都没有变化。")
		return
	_pending_edit_personal_template_id = template_id
	personal_template_edit_name_input.text = str(template.get("name", "未命名模板"))
	personal_template_edit_description_input.text = str(template.get("description", ""))
	personal_template_edit_summary_label.text = (
		"默认新沙盘名：%s\n"
		+ "内容保持：%d 位人物 · %d 个标记 · %d 组势力 · 全图视角\n"
		+ "本次只更新模板名称和说明。当前沙盘及模板中的人物、位置、分组、\n"
		+ "标记和四维属性保持原样。"
	) % [
		str(template.get("title", "未命名沙盘")),
		(template.get("placements", []) as Array).size(),
		(template.get("annotations", []) as Array).size(),
		(template.get("factions", []) as Array).size()
	]
	personal_template_edit_dialog.get_ok_button().disabled = _personal_template_writes_blocked
	personal_template_edit_dialog.popup_centered(Vector2i(540, 390))
	personal_template_edit_name_input.grab_focus()
	personal_template_edit_name_input.select_all()


func _confirm_edit_personal_template() -> void:
	var template_id := _pending_edit_personal_template_id
	var result := _update_personal_scenario_template_text(
		template_id,
		personal_template_edit_name_input.text,
		personal_template_edit_description_input.text
	)
	if not bool(result.get("ok", false)):
		_pending_edit_personal_template_id = ""
		_show_message("模板资料没有保存", "%s\n\n原模板和当前沙盘都没有变化。" % str(result.get("message", "无法安全写入个人模板库。")))
		return
	_pending_edit_personal_template_id = ""
	var template: Dictionary = result.get("template", {})
	if bool(result.get("unchanged", false)):
		_set_status("模板资料没有变化")
	else:
		_set_status("已更新个人模板“%s”的资料 · 开局内容没有变化" % str(template.get("name", "未命名模板")))
	call_deferred("_open_new_sandbox_dialog", template_id, "", "personal")


func _cancel_edit_personal_template() -> void:
	var template_id := _pending_edit_personal_template_id
	_pending_edit_personal_template_id = ""
	_set_status("已取消编辑个人模板资料")
	call_deferred("_open_new_sandbox_dialog", template_id, "", "personal")


func _request_delete_selected_personal_template() -> void:
	if _pending_scenario_template_source != "personal":
		return
	var template := _find_personal_scenario_template(_pending_scenario_template_id)
	if template.is_empty():
		_show_message("无法删除模板", "这个个人模板已经不存在；当前沙盘没有变化。")
		return
	_pending_delete_personal_template_id = str(template.get("id", ""))
	new_sandbox_dialog.hide()
	personal_template_delete_confirmation_dialog.dialog_text = "删除“%s”？\n\n删除后将无法再用它开始新沙盘。当前沙盘、已经从它建立的沙盘和命名快照保持原样。" % str(template.get("name", "未命名模板"))
	personal_template_delete_confirmation_dialog.popup_centered(Vector2i(480, 220))


func _confirm_delete_selected_personal_template() -> void:
	var template_id := _pending_delete_personal_template_id
	var template_name := str(_find_personal_scenario_template(template_id).get("name", "未命名模板"))
	_pending_delete_personal_template_id = ""
	var result := _delete_personal_scenario_template(template_id)
	if not bool(result.get("ok", false)):
		_show_message("个人模板没有删除", "%s\n\n当前沙盘和已有模板都没有变化。" % str(result.get("message", "无法安全写入个人模板库。")))
		return
	_set_status("已删除个人模板“%s” · 当前沙盘没有变化" % template_name)
	call_deferred("_open_new_sandbox_dialog")


func _cancel_delete_selected_personal_template() -> void:
	var template_id := _pending_delete_personal_template_id
	_pending_delete_personal_template_id = ""
	_set_status("已取消删除个人模板")
	call_deferred("_open_new_sandbox_dialog", template_id, "", "personal")


func _scenario_assignment_map(state: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for assignment_value in state.get("character_assignments", []):
		if assignment_value is Dictionary:
			var assignment: Dictionary = assignment_value
			result[str(assignment.get("character_id", ""))] = str(assignment.get("faction_id", ""))
	return result


func _scenario_faction_name_for_character(character_id: String) -> String:
	var assignment_map := _scenario_assignment_map(scenario_state)
	var faction_id := str(assignment_map.get(character_id, ""))
	if faction_id.is_empty():
		return "未加入玩家分组"
	for faction_value in scenario_state.get("factions", []):
		if faction_value is Dictionary and str((faction_value as Dictionary).get("id", "")) == faction_id:
			return str((faction_value as Dictionary).get("name", "未命名分组"))
	return "未加入玩家分组"


func _scenario_faction_member_counts(state: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for faction_value in state.get("factions", []):
		if faction_value is Dictionary:
			result[str((faction_value as Dictionary).get("id", ""))] = {"total": 0, "placed": 0, "cities": 0}
	for assignment_value in state.get("character_assignments", []):
		if not (assignment_value is Dictionary):
			continue
		var assignment: Dictionary = assignment_value
		var faction_id := str(assignment.get("faction_id", ""))
		if not result.has(faction_id):
			continue
		var count_record: Dictionary = result[faction_id]
		count_record["total"] = int(count_record.get("total", 0)) + 1
		if placements.has(str(assignment.get("character_id", ""))):
			count_record["placed"] = int(count_record.get("placed", 0)) + 1
		result[faction_id] = count_record
	for ownership_value in state.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			continue
		var faction_id := str((ownership_value as Dictionary).get("faction_id", ""))
		if not result.has(faction_id):
			continue
		var count_record: Dictionary = result[faction_id]
		count_record["cities"] = int(count_record.get("cities", 0)) + 1
		result[faction_id] = count_record
	return result


func _scenario_character_location_text(character_id: String) -> String:
	if not placements.has(character_id):
		return "背包中"
	var placement: Dictionary = placements.get(character_id, {})
	var place := _find_place(str(placement.get("place_id", "")))
	return str(place.get("name", "地图自由位置")) if not place.is_empty() else "地图自由位置"


func _open_scenario_editor() -> void:
	var validation := _decode_scenario_state(scenario_state)
	if not bool(validation.get("ok", false)):
		_show_message("暂时不能编辑玩法分组", "当前分组状态没有通过完整校验；沙盘没有变化。\n\n%s" % str(validation.get("message", "")))
		return
	_pending_scenario_editor_state = (validation.get("scenario_state", {}) as Dictionary).duplicate(true)
	_pending_scenario_faction_id = ""
	_scenario_editor_transient_error = ""
	_refresh_scenario_editor()
	scenario_editor_dialog.popup_centered(Vector2i(820, 650))


func _return_to_scenario_editor() -> void:
	if _pending_scenario_editor_state.is_empty():
		return
	if scenario_faction_name_dialog != null:
		scenario_faction_name_dialog.hide()
	if scenario_faction_delete_confirmation_dialog != null:
		scenario_faction_delete_confirmation_dialog.hide()
	if scenario_editor_discard_confirmation_dialog != null:
		scenario_editor_discard_confirmation_dialog.hide()
	_refresh_scenario_editor(_pending_scenario_faction_id)
	scenario_editor_dialog.popup_centered(Vector2i(820, 650))


func _cancel_scenario_faction_name_dialog() -> void:
	if _pending_scenario_faction_name_mode == "direct_rename":
		_pending_scenario_editor_state.clear()
		_pending_scenario_faction_id = ""
		_pending_scenario_faction_name_mode = ""
		_set_status("已取消重命名玩法分组")
		return
	_return_to_scenario_editor()


func _return_to_direct_scenario_faction_rename() -> void:
	if _pending_scenario_faction_name_mode != "direct_rename":
		return
	scenario_faction_name_dialog.popup_centered(Vector2i(460, 200))
	scenario_faction_name_input.grab_focus()
	scenario_faction_name_input.select_all()


func _refresh_scenario_editor(preferred_faction_id := "") -> void:
	if scenario_editor_dialog == null or _pending_scenario_editor_state.is_empty():
		return
	var assignment_map := _scenario_assignment_map(_pending_scenario_editor_state)
	var member_counts := _scenario_faction_member_counts(_pending_scenario_editor_state)
	var assigned_count := assignment_map.size()
	scenario_editor_summary_label.text = "地图 %d 人 · 背包 %d 人 · %d 个势力 · %d 人已分组 · %d 城有归属" % [
		placements.size(), maxi(0, characters.size() - placements.size()),
		(_pending_scenario_editor_state.get("factions", []) as Array).size(), assigned_count,
		(_pending_scenario_editor_state.get("city_ownership", []) as Array).size()
	]
	scenario_faction_list.clear()
	var selected_index := -1
	for faction_value in _pending_scenario_editor_state.get("factions", []):
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", ""))
		var faction_color := str(faction.get("color", FactionPaletteScript.default_hex(scenario_faction_list.item_count)))
		var count_record: Dictionary = member_counts.get(faction_id, {"total": 0, "placed": 0})
		var total_count := int(count_record.get("total", 0))
		var placed_count := int(count_record.get("placed", 0))
		var city_count := int(count_record.get("cities", 0))
		var label := "%s · %d 人 · %d 城" % [str(faction.get("name", faction_id)), total_count, city_count]
		scenario_faction_list.add_item(label, _faction_swatch_texture(faction_color))
		var item_index := scenario_faction_list.item_count - 1
		scenario_faction_list.set_item_metadata(item_index, faction_id)
		scenario_faction_list.set_item_tooltip(item_index, "%s · %s\n地图上 %d 人，含背包共 %d 人；本局记录 %d 座城池" % [str(faction.get("name", faction_id)), faction_color, placed_count, total_count, city_count])
		if faction_id == preferred_faction_id:
			selected_index = item_index
	if selected_index >= 0:
		scenario_faction_list.select(selected_index)
		_pending_scenario_faction_id = str(scenario_faction_list.get_item_metadata(selected_index))
	elif scenario_faction_list.item_count > 0 and not _pending_scenario_faction_id.is_empty():
		for item_index in range(scenario_faction_list.item_count):
			if str(scenario_faction_list.get_item_metadata(item_index)) == _pending_scenario_faction_id:
				scenario_faction_list.select(item_index)
				selected_index = item_index
				break
	if selected_index < 0 and (scenario_faction_list.item_count == 0 or _find_pending_scenario_faction(_pending_scenario_faction_id).is_empty()):
		_pending_scenario_faction_id = ""
	if selected_index < 0 and scenario_faction_list.item_count > 0 and _pending_scenario_faction_id.is_empty():
		selected_index = 0
		scenario_faction_list.select(selected_index)
		_pending_scenario_faction_id = str(scenario_faction_list.get_item_metadata(selected_index))
	scenario_faction_new_button.disabled = (_pending_scenario_editor_state.get("factions", []) as Array).size() >= SCENARIO_FACTION_LIMIT
	scenario_faction_rename_button.disabled = _pending_scenario_faction_id.is_empty()
	scenario_faction_delete_button.disabled = _pending_scenario_faction_id.is_empty()
	_sync_scenario_faction_color_button()
	_rebuild_scenario_character_rows(assignment_map)
	_refresh_scenario_editor_validation()


func _refresh_scenario_editor_validation() -> void:
	var pending_validation := _decode_scenario_state(_pending_scenario_editor_state)
	var changed := not _scenario_states_match(_pending_scenario_editor_state, scenario_state)
	if not _scenario_editor_transient_error.is_empty():
		scenario_editor_validation_label.text = _scenario_editor_transient_error
		scenario_editor_validation_label.add_theme_color_override("font_color", UiThemeScript.TEXT_WARNING)
		scenario_editor_dialog.get_ok_button().disabled = not bool(pending_validation.get("ok", false)) or not changed
	elif bool(pending_validation.get("ok", false)):
		scenario_editor_validation_label.text = "势力颜色会同步到地图人物卡、驻城窗口和城点；个人模板带走地图人物及其势力。" if changed else "尚未修改。这里编辑当前沙盘势力；史料归属保留在人物资料库。"
		scenario_editor_validation_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
		scenario_editor_dialog.get_ok_button().disabled = not changed
	else:
		scenario_editor_validation_label.text = "%s 请先补齐成员或删除空分组。" % str(pending_validation.get("message", "分组尚未完整。"))
		scenario_editor_validation_label.add_theme_color_override("font_color", UiThemeScript.TEXT_WARNING)
		scenario_editor_dialog.get_ok_button().disabled = true


func _sync_scenario_faction_color_button() -> void:
	if scenario_faction_color_button == null:
		return
	var faction := _find_pending_scenario_faction(_pending_scenario_faction_id)
	_scenario_color_picker_syncing = true
	scenario_faction_color_button.disabled = faction.is_empty()
	if not faction.is_empty():
		var color_hex := FactionPaletteScript.normalize_hex(faction.get("color", ""))
		scenario_faction_color_button.color = FactionPaletteScript.to_color(color_hex, Color.WHITE)
		scenario_faction_color_button.text = color_hex
		scenario_faction_color_button.tooltip_text = "%s · %s\n点击“应用势力”后保存到当前沙盘" % [str(faction.get("name", "")), color_hex]
	else:
		scenario_faction_color_button.color = Color("737B72")
		scenario_faction_color_button.text = "先选择势力"
		scenario_faction_color_button.tooltip_text = "先选择一个玩法势力"
	_scenario_color_picker_syncing = false


func _faction_swatch_texture(color_hex: String) -> Texture2D:
	var image := Image.create(18, 18, false, Image.FORMAT_RGBA8)
	image.fill(Color("101812"))
	image.fill_rect(Rect2i(2, 2, 14, 14), FactionPaletteScript.to_color(color_hex))
	return ImageTexture.create_from_image(image)


func _capture_scenario_assignment_focus_context(character_id: String, select: OptionButton) -> Dictionary:
	if select == null or scenario_character_scroll == null:
		return {}
	var viewport := select.get_viewport()
	if viewport == null or viewport.gui_get_focus_owner() != select:
		return {}
	var character_index := -1
	for index in range(characters.size()):
		if str((characters[index] as Dictionary).get("id", "")) == character_id:
			character_index = index
			break
	return {
		"character_id": character_id,
		"character_index": character_index,
		"scroll_vertical": scenario_character_scroll.scroll_vertical,
	}


func _scenario_focus_control_is_available(control: Control) -> bool:
	return (
		control != null
		and is_instance_valid(control)
		and control.is_visible_in_tree()
		and control.focus_mode != Control.FOCUS_NONE
		and not (control is BaseButton and (control as BaseButton).disabled)
	)


func _scenario_assignment_select_at_character_index(index: int) -> Control:
	if index < 0 or index >= characters.size():
		return null
	var character_id := str((characters[index] as Dictionary).get("id", ""))
	return _scenario_assignment_selects.get(character_id) as Control


func _restore_scenario_assignment_focus_after_refresh(context: Dictionary) -> void:
	if (
		context.is_empty()
		or not is_inside_tree()
		or scenario_editor_dialog == null
		or not scenario_editor_dialog.visible
		or scenario_character_scroll == null
	):
		return
	var viewport := scenario_character_scroll.get_viewport()
	if viewport == null:
		return
	var current_owner := viewport.gui_get_focus_owner()
	if current_owner is Control and _scenario_focus_control_is_available(current_owner as Control):
		return
	scenario_character_scroll.scroll_vertical = roundi(clampf(
		float(context.get("scroll_vertical", scenario_character_scroll.scroll_vertical)),
		0.0,
		_scenario_character_scroll_limit()
	))
	var character_id := str(context.get("character_id", ""))
	var target := _scenario_assignment_selects.get(character_id) as Control
	var character_index := int(context.get("character_index", -1))
	if not _scenario_focus_control_is_available(target):
		target = _scenario_assignment_select_at_character_index(character_index)
	if not _scenario_focus_control_is_available(target):
		target = _scenario_assignment_select_at_character_index(character_index - 1)
	if _scenario_focus_control_is_available(target):
		target.grab_focus()
		scenario_character_scroll.ensure_control_visible(target)
		_update_scenario_character_scroll_navigation()
		return
	var scroll_bar := scenario_character_scroll.get_v_scroll_bar() as Control
	for fallback in [scroll_bar, scenario_faction_list]:
		var control := fallback as Control
		if _scenario_focus_control_is_available(control):
			control.grab_focus()
			return


func _rebuild_scenario_character_rows(assignment_map: Dictionary) -> void:
	for child in scenario_character_rows.get_children():
		scenario_character_rows.remove_child(child)
		child.queue_free()
	_scenario_assignment_selects.clear()
	var factions: Array = _pending_scenario_editor_state.get("factions", [])
	for character_value in characters:
		var character: Dictionary = character_value
		var character_id := str(character.get("id", ""))
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(468, 34)
		row.add_theme_constant_override("separation", 8)
		scenario_character_rows.add_child(row)
		var label := Label.new()
		label.text = "%s · %s" % [str(character.get("name", character_id)), _scenario_character_location_text(character_id)]
		label.custom_minimum_size = Vector2(235, 30)
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		label.tooltip_text = "%s\n%s" % [str(character.get("name", character_id)), _scenario_character_location_text(character_id)]
		row.add_child(label)
		var select := OptionButton.new()
		select.custom_minimum_size = Vector2(220, 30)
		select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		select.add_item("未分组")
		select.set_item_metadata(0, "")
		var selected_index := 0
		for faction_value in factions:
			var faction: Dictionary = faction_value
			var faction_id := str(faction.get("id", ""))
			select.add_item(str(faction.get("name", faction_id)))
			var option_index := select.item_count - 1
			select.set_item_metadata(option_index, faction_id)
			if str(assignment_map.get(character_id, "")) == faction_id:
				selected_index = option_index
		select.select(selected_index)
		select.item_selected.connect(_on_scenario_character_assignment_selected.bind(character_id))
		row.add_child(select)
		_scenario_assignment_selects[character_id] = select


func _find_pending_scenario_faction(faction_id: String) -> Dictionary:
	for faction_value in _pending_scenario_editor_state.get("factions", []):
		if faction_value is Dictionary and str((faction_value as Dictionary).get("id", "")) == faction_id:
			return (faction_value as Dictionary).duplicate(true)
	return {}


func _duplicate_dictionary_records(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is not Array:
		return result
	for value in values:
		if value is Dictionary:
			result.append((value as Dictionary).duplicate(true))
	return result


func _on_scenario_faction_selected(index: int) -> void:
	if index < 0 or index >= scenario_faction_list.item_count:
		_pending_scenario_faction_id = ""
	else:
		_pending_scenario_faction_id = str(scenario_faction_list.get_item_metadata(index))
	scenario_faction_rename_button.disabled = _pending_scenario_faction_id.is_empty()
	scenario_faction_delete_button.disabled = _pending_scenario_faction_id.is_empty()
	_sync_scenario_faction_color_button()


func _on_scenario_faction_color_changed(value: Color) -> void:
	if _scenario_color_picker_syncing or _pending_scenario_faction_id.is_empty():
		return
	value.a = 1.0
	var color_hex := FactionPaletteScript.to_hex(value)
	var factions := _duplicate_dictionary_records(_pending_scenario_editor_state.get("factions", []))
	var changed := false
	for index in range(factions.size()):
		if str(factions[index].get("id", "")) == _pending_scenario_faction_id:
			if str(factions[index].get("color", "")) != color_hex:
				factions[index]["color"] = color_hex
				changed = true
			break
	if not changed:
		return
	_pending_scenario_editor_state["factions"] = factions
	_scenario_editor_transient_error = ""
	for item_index in range(scenario_faction_list.item_count):
		if str(scenario_faction_list.get_item_metadata(item_index)) == _pending_scenario_faction_id:
			scenario_faction_list.set_item_icon(item_index, _faction_swatch_texture(color_hex))
			var faction := _find_pending_scenario_faction(_pending_scenario_faction_id)
			scenario_faction_list.set_item_tooltip(item_index, "%s · %s\n颜色仅表示当前沙盘势力" % [str(faction.get("name", "")), color_hex])
			break
	scenario_faction_color_button.tooltip_text = "%s\n点击“应用势力”后保存到当前沙盘" % color_hex
	scenario_faction_color_button.text = color_hex
	_refresh_scenario_editor_validation()


func _request_create_scenario_faction() -> void:
	if (_pending_scenario_editor_state.get("factions", []) as Array).size() >= SCENARIO_FACTION_LIMIT:
		_set_status("玩法分组已达到 %d 个上限" % SCENARIO_FACTION_LIMIT)
		return
	_pending_scenario_faction_name_mode = "create"
	_scenario_editor_transient_error = ""
	_pending_scenario_faction_id = ""
	scenario_faction_name_dialog.title = "新建玩法分组"
	scenario_faction_name_input.text = ""
	scenario_editor_dialog.hide()
	scenario_faction_name_dialog.popup_centered(Vector2i(460, 200))
	scenario_faction_name_input.grab_focus()


func _request_rename_scenario_faction() -> void:
	var faction := _find_pending_scenario_faction(_pending_scenario_faction_id)
	if faction.is_empty():
		return
	_pending_scenario_faction_name_mode = "rename"
	_scenario_editor_transient_error = ""
	scenario_faction_name_dialog.title = "重命名玩法分组"
	scenario_faction_name_input.text = str(faction.get("name", ""))
	scenario_editor_dialog.hide()
	scenario_faction_name_dialog.popup_centered(Vector2i(460, 200))
	scenario_faction_name_input.grab_focus()
	scenario_faction_name_input.select_all()


func _on_city_faction_rename_requested(faction_id: String, faction_name: String) -> void:
	var validation := _decode_scenario_state(scenario_state)
	if not bool(validation.get("ok", false)):
		_set_status("暂时不能重命名：当前玩法分组未通过校验")
		return
	_pending_scenario_editor_state = (validation.get("scenario_state", {}) as Dictionary).duplicate(true)
	_pending_scenario_faction_id = faction_id
	var faction := _find_pending_scenario_faction(faction_id)
	if faction.is_empty():
		_pending_scenario_editor_state.clear()
		_pending_scenario_faction_id = ""
		_set_status("暂时不能重命名：找不到这个玩法分组")
		return
	_pending_scenario_faction_name_mode = "direct_rename"
	_scenario_editor_transient_error = ""
	scenario_faction_name_dialog.title = "重命名玩法分组"
	scenario_faction_name_input.text = str(faction.get("name", faction_name))
	scenario_faction_name_dialog.popup_centered(Vector2i(460, 200))
	scenario_faction_name_input.grab_focus()
	scenario_faction_name_input.select_all()


func _confirm_scenario_faction_name() -> void:
	scenario_faction_name_dialog.hide()
	var direct_rename := _pending_scenario_faction_name_mode == "direct_rename"
	var name := _sanitize_single_line(scenario_faction_name_input.text, 24, "")
	if name.is_empty():
		if direct_rename:
			_set_status("请填写一个不超过 24 字的单行名称")
			call_deferred("_return_to_direct_scenario_faction_rename")
		else:
			_scenario_editor_transient_error = "请填写一个不超过 24 字的单行名称；本次草稿没有变化。"
			call_deferred("_return_to_scenario_editor")
		return
	for faction_value in _pending_scenario_editor_state.get("factions", []):
		var faction: Dictionary = faction_value
		if str(faction.get("name", "")) == name and str(faction.get("id", "")) != _pending_scenario_faction_id:
			if direct_rename:
				_set_status("已经有一个同名玩法分组，请换一个名字")
				call_deferred("_return_to_direct_scenario_faction_rename")
			else:
				_scenario_editor_transient_error = "已经有一个同名玩法分组，请换一个名字。"
				call_deferred("_return_to_scenario_editor")
			return
	var factions := _duplicate_dictionary_records(_pending_scenario_editor_state.get("factions", []))
	if _pending_scenario_faction_name_mode == "create":
		if factions.size() >= SCENARIO_FACTION_LIMIT:
			call_deferred("_return_to_scenario_editor")
			return
		_pending_scenario_faction_id = _new_record_id("play")
		factions.append({
			"id": _pending_scenario_faction_id,
			"name": name,
			"color": FactionPaletteScript.first_unused_hex(factions)
		})
	else:
		for index in range(factions.size()):
			if str(factions[index].get("id", "")) == _pending_scenario_faction_id:
				factions[index]["name"] = name
				break
	_pending_scenario_editor_state["factions"] = factions
	if direct_rename:
		var next_state := _pending_scenario_editor_state.duplicate(true)
		var renamed_faction_id := _pending_scenario_faction_id
		_pending_scenario_faction_name_mode = ""
		if _commit_scenario_state(next_state, "重命名玩法分组", "已将玩法分组改名为“%s” · 可撤销" % name):
			_pending_scenario_editor_state.clear()
			_pending_scenario_faction_id = ""
			_scenario_editor_transient_error = ""
		else:
			_pending_scenario_faction_id = renamed_faction_id
			_pending_scenario_faction_name_mode = "direct_rename"
			_set_status("玩法分组未改名：无法安全保存当前沙盘")
			call_deferred("_return_to_direct_scenario_faction_rename")
		return
	_pending_scenario_faction_name_mode = ""
	_scenario_editor_transient_error = ""
	call_deferred("_return_to_scenario_editor")


func _request_delete_scenario_faction() -> void:
	var faction := _find_pending_scenario_faction(_pending_scenario_faction_id)
	if faction.is_empty():
		return
	var affected_count := 0
	var affected_city_count := 0
	for assignment_value in _pending_scenario_editor_state.get("character_assignments", []):
		if assignment_value is Dictionary and str((assignment_value as Dictionary).get("faction_id", "")) == _pending_scenario_faction_id:
			affected_count += 1
	for ownership_value in _pending_scenario_editor_state.get("city_ownership", []):
		if ownership_value is Dictionary and str((ownership_value as Dictionary).get("faction_id", "")) == _pending_scenario_faction_id:
			affected_city_count += 1
	scenario_editor_dialog.hide()
	scenario_faction_delete_confirmation_dialog.dialog_text = "删除“%s”？\n\n组内 %d 位人物将改为“未分组”，%d 座城池将改为“无归属”。人物位置、卡牌和史料归属保持原样。" % [str(faction.get("name", "未命名分组")), affected_count, affected_city_count]
	scenario_faction_delete_confirmation_dialog.popup_centered(Vector2i(500, 230))


func _confirm_delete_scenario_faction() -> void:
	scenario_faction_delete_confirmation_dialog.hide()
	var faction_id := _pending_scenario_faction_id
	var factions: Array[Dictionary] = []
	for faction_value in _pending_scenario_editor_state.get("factions", []):
		if str((faction_value as Dictionary).get("id", "")) != faction_id:
			factions.append((faction_value as Dictionary).duplicate(true))
	var assignments: Array[Dictionary] = []
	for assignment_value in _pending_scenario_editor_state.get("character_assignments", []):
		if str((assignment_value as Dictionary).get("faction_id", "")) != faction_id:
			assignments.append((assignment_value as Dictionary).duplicate(true))
	var city_ownership: Array[Dictionary] = []
	for ownership_value in _pending_scenario_editor_state.get("city_ownership", []):
		if str((ownership_value as Dictionary).get("faction_id", "")) != faction_id:
			city_ownership.append((ownership_value as Dictionary).duplicate(true))
	_pending_scenario_editor_state["factions"] = factions
	_pending_scenario_editor_state["character_assignments"] = assignments
	_pending_scenario_editor_state["city_ownership"] = city_ownership
	_pending_scenario_faction_id = ""
	_scenario_editor_transient_error = ""
	call_deferred("_return_to_scenario_editor")


func _on_scenario_character_assignment_selected(index: int, character_id: String) -> void:
	var select: OptionButton = _scenario_assignment_selects.get(character_id)
	if select == null or index < 0 or index >= select.item_count:
		return
	var focus_context := _capture_scenario_assignment_focus_context(character_id, select)
	var next_faction_id := str(select.get_item_metadata(index))
	var assignments: Array[Dictionary] = []
	for assignment_value in _pending_scenario_editor_state.get("character_assignments", []):
		if str((assignment_value as Dictionary).get("character_id", "")) != character_id:
			assignments.append((assignment_value as Dictionary).duplicate(true))
	if not next_faction_id.is_empty():
		assignments.append({"character_id": character_id, "faction_id": next_faction_id})
	assignments.sort_custom(func(first: Dictionary, second: Dictionary): return str(first.get("character_id", "")) < str(second.get("character_id", "")))
	_pending_scenario_editor_state["character_assignments"] = assignments
	_scenario_editor_transient_error = ""
	_refresh_scenario_editor(_pending_scenario_faction_id)
	if not focus_context.is_empty():
		call_deferred("_restore_scenario_assignment_focus_after_refresh", focus_context)


func _confirm_scenario_editor() -> void:
	var validation := _decode_scenario_state(_pending_scenario_editor_state)
	if not bool(validation.get("ok", false)):
		_scenario_editor_transient_error = "%s 当前沙盘没有变化。" % str(validation.get("message", "请先补齐分组成员。"))
		call_deferred("_return_to_scenario_editor")
		return
	var next_state: Dictionary = validation.get("scenario_state", {}).duplicate(true)
	if _scenario_states_match(scenario_state, next_state):
		_pending_scenario_editor_state.clear()
		_set_status("玩法分组没有变化")
		return
	var assigned_count := (next_state.get("character_assignments", []) as Array).size()
	var status_text := "已更新玩法分组：%d 组 · %d 人已分组 · %d 人未分组 · 可撤销" % [
		(next_state.get("factions", []) as Array).size(), assigned_count, maxi(0, characters.size() - assigned_count)
	]
	if not _commit_scenario_state(next_state, "编辑玩法分组", status_text):
		_scenario_editor_transient_error = "无法安全保存沙盘；当前分组、人物和历史都没有变化。"
		call_deferred("_return_to_scenario_editor")
		return
	_pending_scenario_editor_state.clear()
	_pending_scenario_faction_id = ""
	_scenario_editor_transient_error = ""


func _cancel_scenario_editor() -> void:
	if _pending_scenario_editor_state.is_empty():
		return
	if _scenario_states_match(_pending_scenario_editor_state, scenario_state):
		_pending_scenario_editor_state.clear()
		_pending_scenario_faction_id = ""
		_scenario_editor_transient_error = ""
		_set_status("已取消编辑玩法分组")
		return
	scenario_editor_dialog.hide()
	scenario_editor_discard_confirmation_dialog.popup_centered(Vector2i(480, 220))


func _confirm_discard_scenario_editor() -> void:
	_pending_scenario_editor_state.clear()
	_pending_scenario_faction_id = ""
	_scenario_editor_transient_error = ""
	_set_status("已放弃未应用的玩法分组修改；当前沙盘没有变化")


func _open_chronicle_dialog(preferred_entry_id := "") -> void:
	_chronicle_editor_return_context.clear()
	_pending_chronicle_id = preferred_entry_id
	_refresh_chronicle_dialog(preferred_entry_id)
	chronicle_dialog.popup_centered(Vector2i(780, 540))
	call_deferred("_focus_chronicle_dialog_default")


func _focus_chronicle_dialog_default() -> void:
	if chronicle_dialog == null or not chronicle_dialog.visible:
		return
	if chronicle_list.item_count > 0:
		chronicle_list.grab_focus()
	elif not chronicle_add_button.disabled:
		chronicle_add_button.grab_focus()
	else:
		chronicle_dialog.get_ok_button().grab_focus()


func _close_chronicle_dialog() -> void:
	_pending_chronicle_id = ""
	_pending_chronicle_edit_id = ""
	_chronicle_editor_original.clear()
	_chronicle_editor_return_context.clear()


func _refresh_chronicle_dialog(preferred_entry_id := "") -> void:
	if chronicle_dialog == null:
		return
	chronicle_list.clear()
	var selected_index := -1
	for reverse_index in range(chronicle_entries.size() - 1, -1, -1):
		var entry: Dictionary = chronicle_entries[reverse_index]
		var entry_id := str(entry.get("id", ""))
		var list_text := "〔%s〕%s" % [_chronicle_type_label(str(entry.get("entry_type", "note"))), str(entry.get("title", "未命名纪事"))]
		chronicle_list.add_item(list_text)
		var item_index := chronicle_list.item_count - 1
		chronicle_list.set_item_metadata(item_index, entry_id)
		chronicle_list.set_item_tooltip(item_index, "%s\n%s" % [str(entry.get("title", "未命名纪事")), _format_display_time(str(entry.get("created_at", "")))])
		if entry_id == preferred_entry_id:
			selected_index = item_index
	chronicle_add_button.disabled = chronicle_entries.size() >= CHRONICLE_ENTRY_LIMIT
	if chronicle_entries.is_empty():
		_pending_chronicle_id = ""
		chronicle_detail_label.text = "还没有玩家纪事。\n\n按 Enter 或点击“写一则”，记录战役、援军或你的架空剧情。"
		chronicle_edit_button.disabled = true
		chronicle_delete_button.disabled = true
		return
	if selected_index < 0:
		selected_index = 0
	chronicle_list.select(selected_index)
	_on_chronicle_selected(selected_index)


func _on_chronicle_selected(index: int) -> void:
	if index < 0 or index >= chronicle_list.item_count:
		_pending_chronicle_id = ""
		chronicle_detail_label.text = "请选择一则纪事查看完整内容。"
		chronicle_edit_button.disabled = true
		chronicle_delete_button.disabled = true
		return
	_pending_chronicle_id = str(chronicle_list.get_item_metadata(index))
	var entry := _find_chronicle_entry(_pending_chronicle_id)
	if entry.is_empty():
		_on_chronicle_selected(-1)
		return
	var time_text := str(entry.get("time_label", ""))
	if time_text.is_empty():
		time_text = "未填写"
	var body_text := str(entry.get("body", ""))
	if body_text.is_empty():
		body_text = "（未写正文）"
	chronicle_detail_label.text = (
		"%s\n\n"
		+ "类型：%s\n"
		+ "纪事时间：%s\n"
		+ "创建：%s\n"
		+ "修改：%s\n"
		+ "记录类型：玩家纪事\n\n"
		+ "%s"
	) % [
		str(entry.get("title", "未命名纪事")), _chronicle_type_label(str(entry.get("entry_type", "note"))), time_text,
		_format_display_time(str(entry.get("created_at", ""))), _format_display_time(str(entry.get("updated_at", ""))), body_text
	]
	chronicle_edit_button.disabled = false
	chronicle_delete_button.disabled = false


func _open_new_chronicle_editor(return_context: Dictionary = {}) -> void:
	if chronicle_entries.size() >= CHRONICLE_ENTRY_LIMIT:
		_set_status("玩家纪事已达到 %d 则上限" % CHRONICLE_ENTRY_LIMIT)
		return
	_chronicle_editor_return_context = return_context.duplicate(true)
	_pending_chronicle_edit_id = ""
	_chronicle_editor_original.clear()
	chronicle_type_select.select(0)
	chronicle_time_input.text = ""
	chronicle_title_input.text = ""
	chronicle_body_input.text = str(_chronicle_editor_return_context.get("prefill_body", ""))
	if not _chronicle_editor_return_context.is_empty():
		_chronicle_editor_original = _chronicle_editor_draft()
	chronicle_editor_dialog.title = "写一则玩家纪事"
	chronicle_editor_dialog.ok_button_text = "保存纪事"
	chronicle_dialog.hide()
	_refresh_chronicle_editor_state()
	chronicle_editor_dialog.popup_centered(Vector2i(580, 520))
	chronicle_title_input.grab_focus()


func _open_selected_chronicle_editor() -> void:
	var entry := _find_chronicle_entry(_pending_chronicle_id)
	if entry.is_empty():
		return
	_chronicle_editor_return_context.clear()
	_pending_chronicle_edit_id = str(entry.get("id", ""))
	_chronicle_editor_original = entry.duplicate(true)
	var type_index := CHRONICLE_ENTRY_TYPES.find(str(entry.get("entry_type", "note")))
	chronicle_type_select.select(maxi(0, type_index))
	chronicle_time_input.text = str(entry.get("time_label", ""))
	chronicle_title_input.text = str(entry.get("title", ""))
	chronicle_body_input.text = str(entry.get("body", ""))
	chronicle_editor_dialog.title = "编辑玩家纪事"
	chronicle_editor_dialog.ok_button_text = "保存修改"
	chronicle_dialog.hide()
	_refresh_chronicle_editor_state()
	chronicle_editor_dialog.popup_centered(Vector2i(580, 520))
	chronicle_title_input.grab_focus()
	chronicle_title_input.select_all()


func _chronicle_editor_draft() -> Dictionary:
	var selected_index := chronicle_type_select.selected
	var entry_type := "note"
	if selected_index >= 0 and selected_index < chronicle_type_select.item_count:
		entry_type = str(chronicle_type_select.get_item_metadata(selected_index))
	return {
		"entry_type": entry_type,
		"title": _sanitize_single_line(chronicle_title_input.text, MAX_CHRONICLE_TITLE_LENGTH, ""),
		"time_label": _sanitize_single_line(chronicle_time_input.text, MAX_CHRONICLE_TIME_LABEL_LENGTH, ""),
		"body": _sanitize_multiline(chronicle_body_input.text, MAX_CHRONICLE_BODY_LENGTH)
	}


func _chronicle_editor_has_changes() -> bool:
	var draft := _chronicle_editor_draft()
	if _chronicle_editor_original.is_empty():
		return str(draft.get("entry_type", "note")) != "note" or not str(draft.get("title", "")).is_empty() or not str(draft.get("time_label", "")).is_empty() or not str(draft.get("body", "")).is_empty()
	for key in ["entry_type", "title", "time_label", "body"]:
		if str(draft.get(key, "")) != str(_chronicle_editor_original.get(key, "")):
			return true
	return false


func _on_chronicle_body_changed() -> void:
	if chronicle_body_input.text.length() > MAX_CHRONICLE_BODY_LENGTH:
		var caret_line := chronicle_body_input.get_caret_line()
		var caret_column := chronicle_body_input.get_caret_column()
		chronicle_body_input.text = chronicle_body_input.text.left(MAX_CHRONICLE_BODY_LENGTH)
		chronicle_body_input.set_caret_line(mini(caret_line, chronicle_body_input.get_line_count() - 1))
		chronicle_body_input.set_caret_column(caret_column)
	_refresh_chronicle_editor_state()


func _refresh_chronicle_editor_state() -> void:
	if chronicle_editor_dialog == null:
		return
	var title := _sanitize_single_line(chronicle_title_input.text, MAX_CHRONICLE_TITLE_LENGTH, "")
	chronicle_character_count_label.text = "%d / %d 字" % [chronicle_body_input.text.length(), MAX_CHRONICLE_BODY_LENGTH]
	chronicle_editor_dialog.get_ok_button().disabled = title.is_empty() or not _chronicle_editor_has_changes()


func _confirm_chronicle_editor() -> void:
	chronicle_editor_dialog.hide()
	var draft := _chronicle_editor_draft()
	if str(draft.get("title", "")).is_empty():
		_set_status("玩家纪事需要填写标题")
		call_deferred("_return_to_chronicle_editor")
		return
	var now := Time.get_datetime_string_from_system(false, true)
	var next_entries: Array[Dictionary] = chronicle_entries.duplicate(true)
	var selected_id := _pending_chronicle_edit_id
	var action_label := "新增玩家纪事"
	var status_text := "已写入玩家纪事 · 可撤销"
	if selected_id.is_empty():
		selected_id = _new_record_id("chron")
		next_entries.append({
			"id": selected_id,
			"entry_type": str(draft.get("entry_type", "note")),
			"title": str(draft.get("title", "")),
			"time_label": str(draft.get("time_label", "")),
			"body": str(draft.get("body", "")),
			"created_at": now,
			"updated_at": now
		})
	else:
		action_label = "编辑玩家纪事"
		status_text = "已更新玩家纪事 · 可撤销"
		var replaced := false
		for index in range(next_entries.size()):
			if str(next_entries[index].get("id", "")) == selected_id:
				next_entries[index] = {
					"id": selected_id,
					"entry_type": str(draft.get("entry_type", "note")),
					"title": str(draft.get("title", "")),
					"time_label": str(draft.get("time_label", "")),
					"body": str(draft.get("body", "")),
					"created_at": str(_chronicle_editor_original.get("created_at", now)),
					"updated_at": now
				}
				replaced = true
				break
		if not replaced:
			_set_status("找不到要编辑的玩家纪事；当前沙盘没有变化")
			call_deferred("_open_chronicle_dialog")
			return
	if not _commit_chronicle_entries(next_entries, action_label, status_text):
		call_deferred("_return_to_chronicle_editor")
		return
	_pending_chronicle_id = selected_id
	_pending_chronicle_edit_id = ""
	_chronicle_editor_original.clear()
	_finish_chronicle_editor_navigation(selected_id)


func _cancel_chronicle_editor() -> void:
	if not _chronicle_editor_has_changes():
		_pending_chronicle_edit_id = ""
		_chronicle_editor_original.clear()
		_finish_chronicle_editor_navigation(_pending_chronicle_id)
		return
	chronicle_editor_dialog.hide()
	chronicle_editor_discard_confirmation_dialog.popup_centered(Vector2i(500, 230))


func _return_to_chronicle_editor() -> void:
	chronicle_editor_discard_confirmation_dialog.hide()
	chronicle_delete_confirmation_dialog.hide()
	_refresh_chronicle_editor_state()
	chronicle_editor_dialog.call_deferred("popup_centered", Vector2i(580, 520))


func _confirm_discard_chronicle_editor() -> void:
	chronicle_editor_discard_confirmation_dialog.hide()
	_pending_chronicle_edit_id = ""
	_chronicle_editor_original.clear()
	_set_status("已放弃未保存的纪事修改；当前沙盘没有变化")
	_finish_chronicle_editor_navigation(_pending_chronicle_id)


func _finish_chronicle_editor_navigation(preferred_entry_id := "") -> void:
	var return_context := _chronicle_editor_return_context.duplicate(true)
	_chronicle_editor_return_context.clear()
	var return_kind := str(return_context.get("kind", ""))
	if return_kind == "place_detail":
		_pending_chronicle_id = ""
		call_deferred(
			"_return_to_place_detail_after_chronicle",
			str(return_context.get("place_id", ""))
		)
		return
	if return_kind == "character_profile":
		_pending_chronicle_id = ""
		call_deferred(
			"_return_from_character_profile_chronicle",
			str(return_context.get("character_id", ""))
		)
		return
	call_deferred("_open_chronicle_dialog", preferred_entry_id)


func _return_to_place_detail_after_chronicle(place_id: String) -> void:
	if place_id.is_empty() or _find_place(place_id).is_empty():
		return
	if (
		place_detail_panel == null
		or not place_detail_panel.visible
		or current_place_detail_id != place_id
	):
		_open_place_detail_panel(place_id)
	_refresh_place_detail_chronicle_action()
	call_deferred("_focus_place_detail_chronicle_action", place_id)


func _focus_place_detail_chronicle_action(place_id: String) -> void:
	if (
		place_detail_panel != null
		and place_detail_panel.visible
		and current_place_detail_id == place_id
		and place_detail_chronicle_button != null
		and place_detail_chronicle_button.visible
		and not place_detail_chronicle_button.disabled
	):
		place_detail_chronicle_button.grab_focus()


func _return_from_character_profile_chronicle(_character_id: String) -> void:
	_on_character_detail_dialog_closed()


func _request_delete_selected_chronicle() -> void:
	var entry := _find_chronicle_entry(_pending_chronicle_id)
	if entry.is_empty():
		return
	chronicle_dialog.hide()
	chronicle_delete_confirmation_dialog.dialog_text = "删除“%s”？\n\n删除后可撤销。人物、地图、玩法分组、命名快照和历史资料保持原样。" % str(entry.get("title", "未命名纪事"))
	chronicle_delete_confirmation_dialog.popup_centered(Vector2i(500, 230))


func _confirm_delete_selected_chronicle() -> void:
	chronicle_delete_confirmation_dialog.hide()
	var entry := _find_chronicle_entry(_pending_chronicle_id)
	if entry.is_empty():
		call_deferred("_open_chronicle_dialog")
		return
	var next_entries: Array[Dictionary] = []
	for entry_value in chronicle_entries:
		if str(entry_value.get("id", "")) != _pending_chronicle_id:
			next_entries.append(entry_value.duplicate(true))
	if not _commit_chronicle_entries(next_entries, "删除玩家纪事", "已删除玩家纪事 · 可撤销"):
		call_deferred("_open_chronicle_dialog", _pending_chronicle_id)
		return
	_pending_chronicle_id = ""
	call_deferred("_open_chronicle_dialog")


func _return_to_chronicle_dialog() -> void:
	chronicle_delete_confirmation_dialog.hide()
	call_deferred("_open_chronicle_dialog", _pending_chronicle_id)


func _open_snapshot_create_dialog() -> void:
	var now := Time.get_datetime_dict_from_system()
	snapshot_name_input.text = "%d月%d日 %02d:%02d 的局面" % [int(now.get("month", 0)), int(now.get("day", 0)), int(now.get("hour", 0)), int(now.get("minute", 0))]
	snapshot_note_input.text = ""
	snapshot_create_summary_label.text = "将保存：人物 %d 张 · 标记 %d 个 · 推演线 %d 条 · 玩法分组 %d 组 · 玩家纪事 %d 则 · 本局属性 %d 人 · 行动标注 %d 人 · 当前视角" % [placements.size(), annotations.size(), player_strokes.size(), (scenario_state.get("factions", []) as Array).size(), chronicle_entries.size(), character_states.size(), character_actions.size()]
	snapshot_create_dialog.popup_centered(Vector2i(520, 350))
	snapshot_name_input.grab_focus()
	snapshot_name_input.select_all()


func _confirm_create_snapshot() -> void:
	var result := _create_named_snapshot(snapshot_name_input.text, snapshot_note_input.text)
	if not bool(result.get("ok", false)):
		_show_message("快照没有创建成功", str(result.get("message", "当前沙盘没有变化。")))
		return
	var record: Dictionary = result.get("snapshot", {})
	_refresh_sandbox_identity_view()
	_set_status("已创建快照“%s”，可以继续摆放" % str(record.get("name", "未命名")))


func _snapshot_manager_scroll_value() -> float:
	if snapshot_list == null or not is_instance_valid(snapshot_list):
		return -1.0
	var scroll_bar := snapshot_list.get_v_scroll_bar()
	return float(scroll_bar.value) if scroll_bar != null else -1.0


func _snapshot_manager_focus_control_is_available(control: Control) -> bool:
	return (
		control != null
		and is_instance_valid(control)
		and control.is_visible_in_tree()
		and control.focus_mode != Control.FOCUS_NONE
		and not (control is BaseButton and (control as BaseButton).disabled)
	)


func _restore_snapshot_manager_focus_after_open(target: Control, preferred_scroll: float, ensure_selected_visible: bool) -> void:
	for _attempt in range(2):
		await get_tree().process_frame
		if (
			not is_inside_tree()
			or snapshot_manager_dialog == null
			or not snapshot_manager_dialog.visible
			or not _snapshot_manager_focus_control_is_available(target)
		):
			return
		var viewport := target.get_viewport()
		if viewport == null:
			return
		var current_owner := viewport.gui_get_focus_owner()
		if (
			current_owner is Control
			and current_owner != target
			and current_owner != snapshot_manager_dialog.get_ok_button()
			and _snapshot_manager_focus_control_is_available(current_owner as Control)
		):
			return
		if target == snapshot_list:
			var scroll_bar := snapshot_list.get_v_scroll_bar()
			if preferred_scroll >= 0.0 and scroll_bar != null:
				var scroll_limit := maxf(0.0, float(scroll_bar.max_value) - float(scroll_bar.page))
				scroll_bar.value = clampf(preferred_scroll, 0.0, scroll_limit)
			elif ensure_selected_visible:
				snapshot_list.ensure_current_is_visible()
		if current_owner == null:
			snapshot_manager_dialog.grab_focus()
		target.grab_focus()


func _snapshot_list_neighbor_after_removal(snapshot_id: String) -> String:
	if snapshot_list == null or snapshot_id.is_empty():
		return ""
	for index in range(snapshot_list.item_count):
		if str(snapshot_list.get_item_metadata(index)) != snapshot_id:
			continue
		if index + 1 < snapshot_list.item_count:
			return str(snapshot_list.get_item_metadata(index + 1))
		if index > 0:
			return str(snapshot_list.get_item_metadata(index - 1))
		return ""
	return ""


func _open_snapshot_manager(preferred_snapshot_id := "", preferred_scroll := -1.0) -> void:
	snapshot_list.clear()
	_pending_snapshot_id = ""
	var preferred_item_index := -1
	for index in range(named_snapshots.size() - 1, -1, -1):
		var record: Dictionary = named_snapshots[index]
		var display_time := _format_display_time(str(record.get("created_at", "")))
		snapshot_list.add_item(str(record.get("name", "未命名")))
		var item_index := snapshot_list.item_count - 1
		var record_id := str(record.get("snapshot_id", ""))
		snapshot_list.set_item_metadata(item_index, record_id)
		snapshot_list.set_item_tooltip(item_index, "创建于 %s" % display_time)
		if record_id == preferred_snapshot_id:
			preferred_item_index = item_index
	var has_snapshots := not named_snapshots.is_empty()
	snapshot_manager_dialog.get_ok_button().disabled = not has_snapshots
	snapshot_rename_button.disabled = not has_snapshots
	snapshot_export_button.disabled = not has_snapshots
	snapshot_delete_button.disabled = not has_snapshots
	snapshot_detail_label.text = "还没有命名快照。\n\n创建快照后，可以在这里回到当时的人物、标记、推演线、玩法分组、玩家纪事、本局属性、行动状态和视角。" if not has_snapshots else "请选择一个快照查看详情。"
	snapshot_manager_dialog.popup_centered(Vector2i(700, 470))
	snapshot_manager_dialog.grab_focus()
	var focus_target: Control = snapshot_list if has_snapshots else snapshot_manager_dialog.get_cancel_button()
	if has_snapshots:
		var selected_index := preferred_item_index if preferred_item_index >= 0 else 0
		snapshot_list.select(selected_index)
		_on_snapshot_selected(selected_index)
	focus_target.grab_focus()
	call_deferred(
		"_restore_snapshot_manager_focus_after_open",
		focus_target,
		preferred_scroll,
		preferred_scroll < 0.0
	)


func _on_snapshot_selected(index: int) -> void:
	if index < 0 or index >= snapshot_list.item_count:
		snapshot_manager_dialog.get_ok_button().disabled = true
		snapshot_rename_button.disabled = true
		snapshot_export_button.disabled = true
		snapshot_delete_button.disabled = true
		return
	_pending_snapshot_id = str(snapshot_list.get_item_metadata(index))
	var record := _find_named_snapshot(_pending_snapshot_id)
	if record.is_empty():
		snapshot_manager_dialog.get_ok_button().disabled = true
		snapshot_rename_button.disabled = true
		snapshot_export_button.disabled = true
		snapshot_delete_button.disabled = true
		return
	var payload: Dictionary = record.get("sandbox", {})
	var source_metadata: Dictionary = payload.get("metadata", {})
	var source_chronicle: Dictionary = payload.get("chronicle", _empty_chronicle())
	var source_player_strokes: Dictionary = payload.get("player_strokes", {"strokes": []})
	var source_character_states: Dictionary = payload.get("character_states", {"records": []})
	var source_character_actions: Dictionary = payload.get("character_actions", {"records": []})
	var note := str(record.get("note", ""))
	if note.is_empty():
		note = "（没有备注）"
	snapshot_detail_label.text = (
		"%s\n\n"
		+ "创建时间：%s\n"
		+ "来自沙盘：%s\n"
		+ "内容：人物 %d 张 · 标记 %d 个 · 推演线 %d 条 · 玩家纪事 %d 则 · 本局属性 %d 人 · 行动标注 %d 人\n\n"
		+ "%s"
	) % [
		str(record.get("name", "未命名")), _format_display_time(str(record.get("created_at", ""))),
		str(source_metadata.get("title", "未命名沙盘")), payload.get("cards", []).size(), payload.get("annotations", []).size(), (source_player_strokes.get("strokes", []) as Array).size(), (source_chronicle.get("entries", []) as Array).size(), (source_character_states.get("records", []) as Array).size(), (source_character_actions.get("records", []) as Array).size(), note
	]
	snapshot_manager_dialog.get_ok_button().disabled = false
	snapshot_rename_button.disabled = false
	snapshot_export_button.disabled = false
	snapshot_delete_button.disabled = false


func _request_rename_selected_snapshot() -> void:
	var record := _find_named_snapshot(_pending_snapshot_id)
	if record.is_empty():
		_show_message("无法重命名快照", "这个快照已经不存在，其他内容没有变化。")
		return
	_pending_rename_snapshot_id = str(record.get("snapshot_id", ""))
	snapshot_rename_input.text = str(record.get("name", ""))
	snapshot_manager_dialog.hide()
	snapshot_rename_dialog.popup_centered(Vector2i(460, 190))
	snapshot_rename_input.grab_focus()
	snapshot_rename_input.select_all()


func _confirm_rename_selected_snapshot() -> void:
	var snapshot_id := _pending_rename_snapshot_id
	var snapshot_scroll := _snapshot_manager_scroll_value()
	_pending_rename_snapshot_id = ""
	var result := _rename_named_snapshot(snapshot_id, snapshot_rename_input.text)
	if not bool(result.get("ok", false)):
		_show_message("快照没有重命名", "%s\n\n当前沙盘和快照内容没有变化。" % str(result.get("message", "无法安全保存名称。")))
		return
	var record: Dictionary = result.get("snapshot", {})
	if bool(result.get("unchanged", false)):
		_set_status("快照名称没有变化")
	else:
		_set_status("快照已重命名为“%s”" % str(record.get("name", "未命名")))
	call_deferred("_open_snapshot_manager", snapshot_id, snapshot_scroll)


func _cancel_rename_selected_snapshot() -> void:
	var snapshot_id := _pending_rename_snapshot_id
	var snapshot_scroll := _snapshot_manager_scroll_value()
	_pending_rename_snapshot_id = ""
	_set_status("已取消重命名，快照没有变化")
	call_deferred("_open_snapshot_manager", snapshot_id, snapshot_scroll)


func _request_export_selected_snapshot() -> void:
	var record := _find_named_snapshot(_pending_snapshot_id)
	if record.is_empty():
		_show_message("无法导出快照", "这个快照已经不存在，当前沙盘没有变化。")
		return
	var payload_value: Variant = record.get("sandbox", null)
	if not (payload_value is Dictionary):
		_show_message("无法导出快照", "这个快照的沙盘内容无效，当前沙盘没有变化。")
		return
	var validation := _decode_sandbox_document(payload_value, false)
	if not bool(validation.get("ok", false)) or bool(validation.get("metadata_migration_required", true)):
		_show_message("无法导出快照", "这个快照没有通过完整校验，当前沙盘没有变化。")
		return
	_pending_file_export_mode = "snapshot"
	_pending_scenario_share_template.clear()
	_pending_export_path = ""
	_pending_export_snapshot_id = str(record.get("snapshot_id", ""))
	snapshot_manager_dialog.hide()
	export_dialog.title = "导出这个快照"
	export_dialog.filters = PackedStringArray(["*.tianxia ; 三国推演志沙盘备份"])
	var time_component := str(record.get("created_at", "")).replace("T", "_").replace(":", "").left(15)
	if time_component.is_empty():
		time_component = _timestamp_slug().left(16)
	export_dialog.current_file = "%s_%s.tianxia" % [_safe_filename_component(str(record.get("name", "未命名快照"))), time_component]
	export_dialog.popup_centered(Vector2i(900, 640))


func _request_restore_selected_snapshot() -> void:
	var record := _find_named_snapshot(_pending_snapshot_id)
	if record.is_empty():
		return
	snapshot_restore_confirmation_dialog.dialog_text = (
		"恢复“%s”？\n\n系统先自动备份当前沙盘，再将人物、标记、推演线、玩法分组、玩家纪事、本局属性和视角恢复到快照状态。恢复结果进入可撤销的新分支，人物收藏保持原样。"
	) % str(record.get("name", "未命名"))
	snapshot_manager_dialog.hide()
	snapshot_restore_confirmation_dialog.popup_centered(Vector2i(500, 240))


func _confirm_restore_selected_snapshot() -> void:
	var record := _find_named_snapshot(_pending_snapshot_id)
	if record.is_empty():
		_show_message("无法恢复快照", "这个快照已经不存在，当前沙盘没有变化。")
		return
	var result := _apply_named_snapshot(record)
	if not bool(result.get("ok", false)):
		_show_message("暂时不能恢复快照", str(result.get("message", "当前沙盘没有变化。")))
		return
	if bool(result.get("unchanged", false)):
		_set_status("当前沙盘已经与这个快照相同")
		return
	_set_status("已恢复快照“%s” · 已建立分支 · 可撤销" % str(record.get("name", "未命名")))


func _request_delete_selected_snapshot() -> void:
	var record := _find_named_snapshot(_pending_snapshot_id)
	if record.is_empty():
		return
	snapshot_delete_confirmation_dialog.dialog_text = "删除“%s”？\n\n删除后无法从游戏内恢复。当前沙盘保持原样。" % str(record.get("name", "未命名"))
	snapshot_manager_dialog.hide()
	snapshot_delete_confirmation_dialog.popup_centered(Vector2i(460, 210))


func _cancel_snapshot_confirmation() -> void:
	var snapshot_id := _pending_snapshot_id
	var snapshot_scroll := _snapshot_manager_scroll_value()
	_set_status("已取消，快照和当前沙盘都没有变化")
	call_deferred("_open_snapshot_manager", snapshot_id, snapshot_scroll)


func _confirm_delete_selected_snapshot() -> void:
	var record := _find_named_snapshot(_pending_snapshot_id)
	if record.is_empty():
		return
	var deleted_snapshot_id := _pending_snapshot_id
	var preferred_snapshot_id := _snapshot_list_neighbor_after_removal(deleted_snapshot_id)
	var snapshot_scroll := _snapshot_manager_scroll_value()
	var name := str(record.get("name", "未命名"))
	var result := _delete_named_snapshot(deleted_snapshot_id)
	if not bool(result.get("ok", false)):
		_show_message("快照没有删除", str(result.get("message", "快照仍然保留。")))
		return
	_pending_snapshot_id = ""
	_refresh_sandbox_identity_view()
	_set_status("已删除快照“%s”" % name)
	call_deferred("_open_snapshot_manager", preferred_snapshot_id, snapshot_scroll)


func _format_display_time(value: String) -> String:
	if value.length() >= 16:
		return value.substr(0, 16).replace("T", " ")
	return value if not value.is_empty() else "未记录时间"


func _on_favorite_toggled(character_id: String, favorite: bool) -> void:
	if not _has_character_id(character_id):
		return
	if favorite:
		favorite_character_ids[character_id] = true
	else:
		favorite_character_ids.erase(character_id)
	if _save_preferences():
		_set_status("已收藏 %s" % _character_name(character_id) if favorite else "已取消收藏 %s" % _character_name(character_id))
	else:
		_set_status("收藏偏好保存失败")


func _on_backpack_hand_candidate_changed(character_id: String, selected: bool, selected_count: int) -> void:
	if character_id.is_empty():
		_set_status("手边已清空；地图上的人物没有变化")
		return
	if selected:
		_set_status("已拿到手边：%s · %d/%d" % [
			_character_name(character_id),
			selected_count,
			BackpackPanelScript.HAND_CANDIDATE_LIMIT
		])
	else:
		_set_status("已移出手边：%s · %d/%d" % [
			_character_name(character_id),
			selected_count,
			BackpackPanelScript.HAND_CANDIDATE_LIMIT
		])


func _on_backpack_hand_candidate_limit_reached(limit: int) -> void:
	_set_status("手边最多放 %d 人；请先移出一位或清空手边" % limit)


func _on_backpack_scenario_take_completed(added_count: int, pending_count: int, capacity_limited: bool) -> void:
	if added_count > 0:
		var message := "已把 %d 位本局补位人物放到手边 · 现在把手边卡拖到地图" % [
			added_count,
		]
		if capacity_limited and pending_count > 0:
			message += " · 手边已满，剩余人物可稍后补入"
		_set_status(message)
	elif capacity_limited:
		_set_status("手边已满 %d/%d；先拖一张到地图或移出一位" % [BackpackPanelScript.HAND_CANDIDATE_LIMIT, BackpackPanelScript.HAND_CANDIDATE_LIMIT])
	else:
		_set_status("本局补位人物已经在手边或地图上")


func _on_draw_tool_button_pressed() -> void:
	if map_board == null:
		return
	if city_ownership_tool_active:
		_finish_city_ownership_tool()
		return
	if map_board.is_player_stroke_point_edit_active():
		map_board.cancel_player_stroke_point_edit()
		_set_status("已取消调整推演线路线")
		return
	if map_board.is_annotation_tool_active():
		map_board.set_annotation_tool_active(false)
		_set_status("已取消放置标记")
		return
	if map_board.is_player_stroke_tool_active():
		map_board.cancel_player_stroke_draft()
		_set_status("已取消绘制推演线")
		return
	if draw_tool_popup == null or annotation_button == null:
		return
	draw_tool_popup.position = Vector2i(roundi(annotation_button.global_position.x), roundi(annotation_button.global_position.y + annotation_button.size.y + 4.0))
	draw_tool_popup.popup()


func _on_draw_tool_popup_pressed(item_id: int) -> void:
	match item_id:
		1:
			map_board.set_annotation_tool_active(true)
			_set_status("请在地图上点一下，再选择便签／玩家地点／玩家事件 · 按 Esc 取消")
		2:
			_open_player_stroke_dialog()


func _refresh_draw_tool_button() -> void:
	if annotation_button == null:
		return
	if city_ownership_tool_active:
		annotation_button.text = "结束归属"
		annotation_button.tooltip_text = "结束连续设置城池归属；已经完成的修改会保留"
	elif map_board != null and map_board.is_player_stroke_point_edit_active():
		annotation_button.text = "取消调线"
		annotation_button.tooltip_text = "取消当前折点调整；存档保持原样"
	elif map_board != null and map_board.is_player_stroke_tool_active():
		annotation_button.text = "取消画线"
		annotation_button.tooltip_text = "取消当前推演线；存档保持原样"
	elif map_board != null and map_board.is_annotation_tool_active():
		annotation_button.text = "取消标记"
		annotation_button.tooltip_text = "取消当前点标记"
	else:
		annotation_button.text = "＋绘制"
		annotation_button.tooltip_text = "放置玩家标记，或画出进军、援军、撤退和计划线"


func _on_annotation_button_toggled(active: bool) -> void:
	if map_board == null:
		return
	if active and city_ownership_tool_active:
		_finish_city_ownership_tool("", false)
	map_board.set_annotation_tool_active(active)
	if active:
		_set_status("请在地图上点一下，再选择便签／玩家地点／玩家事件 · 按 Esc 取消")
	else:
		_set_status("已取消放置标记")


func _on_annotation_tool_changed(active: bool) -> void:
	_refresh_draw_tool_button()


func _open_player_stroke_dialog(stroke_id := "") -> void:
	if player_stroke_dialog == null:
		return
	if city_ownership_tool_active:
		_finish_city_ownership_tool("", false)
	_pending_player_stroke_id = stroke_id
	_pending_player_stroke_type = "advance"
	_pending_player_stroke_label = ""
	var editing := not stroke_id.is_empty() and not _find_player_stroke(stroke_id).is_empty()
	if editing:
		var stroke := _find_player_stroke(stroke_id)
		_pending_player_stroke_type = str(stroke.get("stroke_type", "advance"))
		_pending_player_stroke_label = str(stroke.get("label", ""))
	player_stroke_dialog.title = "修改推演线" if editing else "绘制推演线"
	player_stroke_dialog.get_ok_button().text = "保存修改" if editing else "开始落点"
	player_stroke_type_select.select(_player_stroke_type_index(_pending_player_stroke_type))
	player_stroke_label_input.text = _pending_player_stroke_label
	player_stroke_dialog.popup_centered(Vector2i(480, 245))
	player_stroke_label_input.call_deferred("grab_focus")


func _confirm_player_stroke_dialog() -> void:
	_pending_player_stroke_type = str(PLAYER_STROKE_TYPES[clampi(player_stroke_type_select.selected, 0, PLAYER_STROKE_TYPES.size() - 1)])
	_pending_player_stroke_label = _sanitize_single_line(player_stroke_label_input.text, MAX_PLAYER_STROKE_LABEL_LENGTH, "")
	if not _pending_player_stroke_id.is_empty():
		var next := player_strokes.duplicate(true)
		var found := false
		for index in range(next.size()):
			if str(next[index].get("id", "")) != _pending_player_stroke_id:
				continue
			var edited: Dictionary = next[index].duplicate(true)
			edited["stroke_type"] = _pending_player_stroke_type
			edited["label"] = _pending_player_stroke_label
			edited["updated_at"] = Time.get_datetime_string_from_system(false, true)
			next[index] = edited
			found = true
			break
		if found:
			if not _commit_player_strokes(next, "修改推演线", "已修改推演线，可撤销"):
				_set_status("推演线类型和说明都没有变化")
		_pending_player_stroke_id = ""
		return
	if player_strokes.size() >= PLAYER_STROKE_LIMIT:
		_show_message("暂时不能继续画", "当前沙盘已达到 %d 条玩家推演线上限。请先删除不再需要的线。" % PLAYER_STROKE_LIMIT)
		return
	map_board.set_player_stroke_tool_active(true, _pending_player_stroke_type)
	_set_status("正在绘制%s：单击落点，双击或 Enter 完成，Backspace 撤一点，Esc 取消" % _player_stroke_type_label(_pending_player_stroke_type))


func _cancel_player_stroke_dialog() -> void:
	_pending_player_stroke_id = ""
	_pending_player_stroke_type = "advance"
	_pending_player_stroke_label = ""


func _on_player_stroke_label_submitted(_value: String) -> void:
	if player_stroke_dialog != null and player_stroke_dialog.visible:
		player_stroke_dialog.hide()
		_confirm_player_stroke_dialog()


func _on_player_stroke_tool_changed(active: bool) -> void:
	_refresh_draw_tool_button()
	if active and map_board != null and map_board.is_player_stroke_point_edit_active():
		_set_status("正在调整路线：拖动金色折点，Enter 保存，Esc 取消")


func _on_player_stroke_draft_completed(points: Array) -> void:
	if points.size() < 2 or points.size() > PLAYER_STROKE_POINT_LIMIT:
		_set_status("推演线未保存：至少需要两个有效落点")
		return
	if player_strokes.size() >= PLAYER_STROKE_LIMIT:
		_set_status("推演线未保存：已达到 %d 条上限" % PLAYER_STROKE_LIMIT)
		return
	var saved_points: Array[Dictionary] = []
	for point_value in points:
		if not (point_value is Vector2):
			return
		var point: Vector2 = point_value
		saved_points.append({"x": clampf(point.x, 0.0, 1.0), "y": clampf(point.y, 0.0, 1.0)})
	var now := Time.get_datetime_string_from_system(false, true)
	var stroke := {
		"id": _new_record_id("stroke"),
		"stroke_type": _pending_player_stroke_type if PLAYER_STROKE_TYPES.has(_pending_player_stroke_type) else "advance",
		"label": _sanitize_single_line(_pending_player_stroke_label, MAX_PLAYER_STROKE_LABEL_LENGTH, ""),
		"points": saved_points,
		"created_at": now,
		"updated_at": now
	}
	var next := player_strokes.duplicate(true)
	next.append(stroke)
	var type_label := _player_stroke_type_label(str(stroke.get("stroke_type", "advance")))
	if _commit_player_strokes(next, "绘制%s" % type_label, "已画好%s，可撤销" % type_label):
		if map_board != null:
			map_board.set_player_strokes_visible(true)
	_pending_player_stroke_type = "advance"
	_pending_player_stroke_label = ""


func _on_player_stroke_edit_requested(stroke_id: String) -> void:
	if not _find_player_stroke(stroke_id).is_empty():
		_open_player_stroke_dialog(stroke_id)


func _on_player_stroke_geometry_edit_completed(stroke_id: String, points: Array) -> void:
	var current := _find_player_stroke(stroke_id)
	if current.is_empty():
		_set_status("路线调整未保存：目标推演线已不存在")
		return
	var current_points: Variant = current.get("points", [])
	if not (current_points is Array) or points.size() != current_points.size():
		_set_status("路线调整未保存：折点数量与原线不一致")
		return
	var saved_points: Array[Dictionary] = []
	for point_value in points:
		if not (point_value is Vector2):
			_set_status("路线调整未保存：折点结构无效")
			return
		var point: Vector2 = point_value
		if not is_finite(point.x) or not is_finite(point.y) or point.x < 0.0 or point.x > 1.0 or point.y < 0.0 or point.y > 1.0:
			_set_status("路线调整未保存：折点超出地图范围")
			return
		saved_points.append({"x": point.x, "y": point.y})
	var next := player_strokes.duplicate(true)
	for index in range(next.size()):
		if str(next[index].get("id", "")) != stroke_id:
			continue
		var edited: Dictionary = next[index].duplicate(true)
		edited["points"] = saved_points
		edited["updated_at"] = Time.get_datetime_string_from_system(false, true)
		next[index] = edited
		_commit_player_strokes(next, "调整推演线路线", "已调整推演线路线，可撤销")
		return


func _on_player_stroke_delete_requested(stroke_id: String) -> void:
	if _find_player_stroke(stroke_id).is_empty():
		return
	_pending_player_stroke_id = stroke_id
	player_stroke_delete_confirmation_dialog.popup_centered(Vector2i(430, 180))


func _confirm_player_stroke_delete() -> void:
	var next: Array[Dictionary] = []
	for stroke in player_strokes:
		if str(stroke.get("id", "")) != _pending_player_stroke_id:
			next.append(stroke.duplicate(true))
	if next.size() != player_strokes.size():
		_commit_player_strokes(next, "删除推演线", "已删除推演线，可撤销")
	_pending_player_stroke_id = ""


func _cancel_player_stroke_delete() -> void:
	_pending_player_stroke_id = ""


func _on_player_stroke_focused(_stroke_id: String, label: String, index: int, total: int) -> void:
	_set_status("已定位推演线 %d/%d：%s" % [index, total, label])


func _on_player_stroke_focus_unavailable() -> void:
	_set_status("当前没有可定位的玩家推演线")


func _find_player_stroke(stroke_id: String) -> Dictionary:
	for stroke in player_strokes:
		if str(stroke.get("id", "")) == stroke_id:
			return stroke
	return {}


func _player_stroke_type_index(stroke_type: String) -> int:
	var index := PLAYER_STROKE_TYPES.find(stroke_type)
	return index if index >= 0 else 0


func _player_stroke_type_label(stroke_type: String) -> String:
	match stroke_type:
		"reinforcement":
			return "援军线"
		"retreat":
			return "撤退线"
		"plan":
			return "计划线"
		_:
			return "进军线"


func _on_annotation_create_requested(normalized_position: Vector2) -> void:
	_pending_annotation_id = ""
	_pending_annotation_position = normalized_position
	_pending_annotation_type = "note"
	_pending_annotation_faction_id = ""
	_open_annotation_dialog("添加沙盘标记", "放好", "援军", "note", "")


func _on_annotation_edit_requested(annotation_id: String) -> void:
	if not annotations.has(annotation_id):
		return
	_pending_annotation_id = annotation_id
	var annotation: Dictionary = annotations[annotation_id]
	_pending_annotation_position = Vector2(float(annotation.get("x", 0.5)), float(annotation.get("y", 0.5)))
	_pending_annotation_type = str(annotation.get("marker_type", "note"))
	_pending_annotation_faction_id = str(annotation.get("faction_id", ""))
	_open_annotation_dialog(
		"修改沙盘标记",
		"保存修改",
		str(annotation.get("label", "")),
		_pending_annotation_type,
		_pending_annotation_faction_id
	)


func _open_annotation_dialog(
	title_text: String,
	ok_text: String,
	initial_text: String,
	marker_type: String = "note",
	faction_id: String = ""
) -> void:
	if annotation_dialog == null or annotation_input == null or annotation_type_select == null or annotation_faction_select == null:
		return
	annotation_dialog.title = title_text
	annotation_dialog.get_ok_button().text = ok_text
	_pending_annotation_type = marker_type if ANNOTATION_TYPES.has(marker_type) else "note"
	annotation_type_select.select(_annotation_type_index(_pending_annotation_type))
	_on_annotation_type_selected(annotation_type_select.selected)
	_rebuild_annotation_faction_select(faction_id)
	annotation_input.text = initial_text
	annotation_dialog.popup_centered(Vector2i(480, 286))
	annotation_input.call_deferred("grab_focus")
	annotation_input.call_deferred("select_all")


func _rebuild_annotation_faction_select(selected_faction_id: String) -> void:
	if annotation_faction_select == null:
		return
	annotation_faction_select.clear()
	annotation_faction_select.add_item("未指定势力")
	annotation_faction_select.set_item_metadata(0, "")
	var selected_index := 0
	for faction_value in scenario_state.get("factions", []):
		if not (faction_value is Dictionary):
			continue
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", "")).strip_edges()
		var faction_name := str(faction.get("name", "")).strip_edges()
		if faction_id.is_empty() or faction_name.is_empty():
			continue
		annotation_faction_select.add_item(faction_name)
		var item_index := annotation_faction_select.item_count - 1
		annotation_faction_select.set_item_metadata(item_index, faction_id)
		if faction_id == selected_faction_id:
			selected_index = item_index
	annotation_faction_select.select(selected_index)
	_on_annotation_faction_selected(selected_index)


func _on_annotation_faction_selected(index: int) -> void:
	if annotation_faction_select == null or index < 0 or index >= annotation_faction_select.item_count:
		_pending_annotation_faction_id = ""
		return
	_pending_annotation_faction_id = str(annotation_faction_select.get_item_metadata(index)).strip_edges()


func _on_annotation_type_selected(index: int) -> void:
	_pending_annotation_type = str(ANNOTATION_TYPES[clampi(index, 0, ANNOTATION_TYPES.size() - 1)])
	if annotation_input == null:
		return
	match _pending_annotation_type:
		"player_place":
			annotation_input.placeholder_text = "例如：卧龙岗别院"
			annotation_input.tooltip_text = "玩家自定地点作为沙盘标记保存；人物保持自由摆放"
		"player_event":
			annotation_input.placeholder_text = "例如：援军抵达"
			annotation_input.tooltip_text = "玩家事件记录本局推演；结果由你安排"
		_:
			annotation_input.placeholder_text = "例如：援军从这里来"
			annotation_input.tooltip_text = "一行战术便签"


func _on_annotation_text_submitted(_value: String) -> void:
	if annotation_dialog != null and annotation_dialog.visible:
		annotation_dialog.hide()
		_confirm_annotation_dialog()


func _confirm_annotation_dialog() -> void:
	var label := str(annotation_input.text if annotation_input != null else "").replace("\r", " ").replace("\n", " ").strip_edges().left(24)
	var marker_type := _pending_annotation_type if ANNOTATION_TYPES.has(_pending_annotation_type) else "note"
	var faction_id := _pending_annotation_faction_id
	if not faction_id.is_empty() and _scenario_faction_record(faction_id).is_empty():
		faction_id = ""
	# 新增或改成某一类型时自动恢复该类型可见，避免“添加成功却看不见”的错觉；这是会话状态，不写入存档。
	if map_board != null:
		map_board.set_annotation_type_visible(marker_type, true)
	var next := annotations.duplicate(true)
	if _pending_annotation_id.is_empty():
		var annotation_id := _new_annotation_id()
		next[annotation_id] = {
			"id": annotation_id,
			"kind": "marker",
			"marker_type": marker_type,
			"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
			"verification_status": ANNOTATION_VERIFICATION_STATUS,
			"x": _pending_annotation_position.x,
			"y": _pending_annotation_position.y,
			"label": label,
			"style": _annotation_style_for_type(marker_type),
			"faction_id": faction_id
		}
		_commit_annotations(next, "添加%s" % _annotation_type_label(marker_type), "已添加%s，可撤销" % _annotation_type_label(marker_type))
	else:
		if not next.has(_pending_annotation_id):
			_cancel_annotation_dialog()
			return
		var edited: Dictionary = next[_pending_annotation_id]
		edited["label"] = label
		edited["kind"] = "marker"
		edited["marker_type"] = marker_type
		edited["semantic_layer"] = ANNOTATION_SEMANTIC_LAYER
		edited["verification_status"] = ANNOTATION_VERIFICATION_STATUS
		edited["style"] = _annotation_style_for_type(marker_type)
		edited["faction_id"] = faction_id
		next[_pending_annotation_id] = edited
		if not _commit_annotations(next, "修改沙盘标记", "已修改%s，可撤销" % _annotation_type_label(marker_type)):
			_set_status("标记类型和文字都没有变化")
	_pending_annotation_id = ""
	_pending_annotation_type = "note"
	_pending_annotation_faction_id = ""


func _cancel_annotation_dialog() -> void:
	_pending_annotation_id = ""
	_pending_annotation_type = "note"
	_pending_annotation_faction_id = ""
	_set_status("已取消标记编辑")


func _on_annotation_delete_requested(annotation_id: String) -> void:
	if not annotations.has(annotation_id):
		return
	var next := annotations.duplicate(true)
	next.erase(annotation_id)
	_commit_annotations(next, "删除标记", "已删除标记，可撤销")


func _on_annotation_drag_released(annotation_id: String, normalized_position: Vector2, valid_map_drop: bool) -> void:
	if not annotations.has(annotation_id):
		return
	if not valid_map_drop:
		map_board.set_annotations(annotations)
		_set_status("标记仍保留在原位置")
		return
	var next := annotations.duplicate(true)
	var moved: Dictionary = next[annotation_id]
	moved["x"] = normalized_position.x
	moved["y"] = normalized_position.y
	next[annotation_id] = moved
	if not _commit_annotations(next, "移动标记", "已移动标记，可撤销"):
		map_board.set_annotations(annotations)


func _is_generated_tooltip_window(window: Window) -> bool:
	if not (window is PopupPanel) or not str(window.name).begins_with("@PopupPanel@"):
		return false
	var tooltip_owner := window.get_parent() as Control
	return tooltip_owner != null and not tooltip_owner.tooltip_text.is_empty()


func _has_visible_desktop_shortcut_window(node: Node = self) -> bool:
	for child in node.get_children(true):
		if child is Window and (child as Window).visible:
			# Godot 会把普通 Control 的 tooltip 生成为内部 PopupPanel；
			# 它只是悬停说明，不应像菜单或业务对话框一样阻断桌面快捷键。
			if not _is_generated_tooltip_window(child as Window):
				return true
		if _has_visible_desktop_shortcut_window(child):
			return true
	return false


func _desktop_shortcut_focus_is_text_input() -> bool:
	var focused := get_viewport().gui_get_focus_owner()
	var current: Node = focused
	while current != null:
		if current is LineEdit or current is TextEdit or current is SpinBox:
			return true
		if current == self:
			break
		current = current.get_parent()
	return false


func _cancel_top_map_context_on_escape() -> bool:
	# 路线编辑、绘制、连续归属、地点札记与放置标记都是地图上的
	# 高层上下文。它们共用同一取消入口，并先于人物临时多选退出。
	if map_board != null and map_board.is_player_stroke_point_edit_active():
		map_board.cancel_player_stroke_point_edit()
		_set_status("已取消调整路线；预览没有保存")
		return true
	if map_board != null and map_board.is_player_stroke_tool_active():
		map_board.cancel_player_stroke_draft()
		_pending_player_stroke_type = "advance"
		_pending_player_stroke_label = ""
		_set_status("已取消绘制推演线；草稿没有保存")
		return true
	if city_ownership_tool_active:
		_finish_city_ownership_tool()
		return true
	if place_detail_panel != null and place_detail_panel.visible:
		_close_place_detail_panel()
		return true
	if map_board != null and map_board.is_annotation_tool_active():
		map_board.set_annotation_tool_active(false)
		_set_status("已取消放置标记")
		return true
	return false


func _desktop_shortcut_block_reason(command: String) -> String:
	if _has_visible_desktop_shortcut_window():
		return "window"
	if _simulation_session_tool_is_busy():
		return "map_tool"
	if get_viewport().gui_is_dragging() or (map_board != null and map_board.is_pointer_interaction_active()):
		return "pointer_interaction"
	if command != "focus_search" and _desktop_shortcut_focus_is_text_input():
		return "text_input"
	return ""


func _desktop_shortcut_command(event: InputEventKey) -> String:
	if not event.pressed or event.echo or event.alt_pressed or event.meta_pressed:
		return ""
	if event.ctrl_pressed:
		if event.keycode == KEY_F and not event.shift_pressed:
			return "focus_search"
		if event.keycode == KEY_G and not event.shift_pressed:
			return "place_search"
		if event.keycode == KEY_J and not event.shift_pressed:
			return "chronicle"
		if event.keycode == KEY_S:
			return "quick_bookmark" if event.shift_pressed else "save"
		if event.keycode == KEY_Z:
			return "redo" if event.shift_pressed else "undo"
		if event.keycode == KEY_Y and not event.shift_pressed:
			return "redo"
		return ""
	if not event.shift_pressed and event.keycode == KEY_HOME:
		return "home"
	return ""


func _handle_desktop_shortcut(event: InputEventKey) -> bool:
	var command := _desktop_shortcut_command(event)
	if command.is_empty():
		return false
	var block_reason := _desktop_shortcut_block_reason(command)
	if not block_reason.is_empty():
		if block_reason in ["map_tool", "pointer_interaction"]:
			_set_status("请先完成或取消当前地图操作，再使用快捷键")
		return block_reason in ["map_tool", "pointer_interaction"]
	match command:
		"focus_search":
			if backpack_collapsed:
				_expand_backpack()
			if backpack != null and backpack.focus_search(true):
				_set_status("已定位人物搜索；输入姓名、字号或别名")
				return true
		"place_search":
			_open_place_search_dialog()
			return true
		"chronicle":
			_open_chronicle_dialog()
			return true
		"save":
			_on_save_pressed()
			return true
		"quick_bookmark":
			_on_quick_situation_bookmark_pressed()
			return true
		"undo":
			if _undo_stack.is_empty():
				_set_status("暂无可撤销操作")
			else:
				_on_undo_pressed()
			return true
		"redo":
			if _redo_stack.is_empty():
				_set_status("暂无可重做操作")
			else:
				_on_redo_pressed()
			return true
		"home":
			_on_home_pressed()
			return true
	return false


func _input(event: InputEvent) -> void:
	if not (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_ESCAPE
	):
		return
	# Godot 的 GUI 导航层会在没有显式焦点时吃掉 Esc 的按下事件，
	# 因此临时多人选择不能只依赖 MapBoard._unhandled_key_input。
	# 弹窗、文本输入和正在进行的指针手势仍优先处理自己的 Esc。
	if (
		_has_visible_desktop_shortcut_window()
		or _desktop_shortcut_focus_is_text_input()
		or get_viewport().gui_is_dragging()
		or (map_board != null and map_board.is_pointer_interaction_active())
	):
		return
	# 地图上下文面板／工具位于临时人物多选之上；同一 Esc 只退出
	# 最上层交互，避免札记或工具仍活动时先丢失人物编组。
	if _cancel_top_map_context_on_escape():
		get_viewport().set_input_as_handled()
		return
	if map_board != null and map_board.cancel_character_multiselection():
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void:
	if (
		test_mode
		and event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_F8
	):
		_toggle_pass_symbol_review_variant()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and _handle_desktop_shortcut(event as InputEventKey):
		get_viewport().set_input_as_handled()
		return
	if map_board != null and map_board.is_player_stroke_point_edit_active():
		if event.is_action_pressed("ui_accept"):
			var edit_state := map_board.get_player_stroke_point_edit_state()
			map_board.finish_player_stroke_point_edit()
			if not bool(edit_state.get("changed", false)):
				_set_status("折点没有变化；未写入存档")
			get_viewport().set_input_as_handled()
			return
	if map_board != null and map_board.is_player_stroke_tool_active():
		if event.is_action_pressed("ui_accept"):
			map_board.finish_player_stroke_draft()
			get_viewport().set_input_as_handled()
			return
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_BACKSPACE:
			map_board.undo_player_stroke_draft_point()
			get_viewport().set_input_as_handled()
			return
	if not event.is_action_pressed("ui_cancel"):
		return
	if _cancel_top_map_context_on_escape():
		get_viewport().set_input_as_handled()
	elif annotation_dialog != null and annotation_dialog.visible:
		annotation_dialog.hide()
		_cancel_annotation_dialog()
		get_viewport().set_input_as_handled()


func _toggle_pass_symbol_review_variant() -> void:
	if map_board == null:
		return
	var next_variant := (
		MapBoardScript.PASS_SYMBOL_VARIANT_PAPER_INK_V1
		if map_board.get_pass_symbol_variant() == MapBoardScript.PASS_SYMBOL_VARIANT_V3
		else MapBoardScript.PASS_SYMBOL_VARIANT_V3
	)
	if map_board.set_pass_symbol_variant(next_variant):
		pass_symbol_variant = next_variant
		_set_pass_symbol_review_status()


func _set_pass_symbol_review_status() -> void:
	var is_candidate := (
		map_board != null
		and map_board.get_pass_symbol_variant() == MapBoardScript.PASS_SYMBOL_VARIANT_PAPER_INK_V1
	)
	_set_status(
		"测试模式 · 关隘 B/纸墨候选 · F8 切换 · 不覆盖正式存档"
		if is_candidate
		else "测试模式 · 关隘 A/V3 · F8 切换 · 不覆盖正式存档"
	)


func _on_character_dropped(character_id: String, normalized_position: Vector2) -> void:
	if character_id.is_empty():
		return
	var was_placed := placements.has(character_id)
	var drop_context := map_board.take_last_drop_context(character_id) if map_board != null else {}
	var next := placements.duplicate(true)
	var next_placement := {"x": normalized_position.x, "y": normalized_position.y}
	if bool(drop_context.get("snapped", false)):
		next_placement["place_id"] = str(drop_context.get("place_id", ""))
	next[character_id] = next_placement
	var character_name := _character_name(character_id)
	var status_text := "已移动 %s" % character_name if was_placed else "已将 %s 放到地图" % character_name
	if bool(drop_context.get("snapped", false)):
		status_text = "已将 %s 移至%s" % [character_name, str(drop_context.get("place_name", "城池"))] if was_placed else "已将 %s 驻于%s" % [character_name, str(drop_context.get("place_name", "城池"))]
	elif bool(drop_context.get("snap_bypassed", false)):
		status_text = "已自由移动 %s · Alt 已跳过城池吸附" % character_name if was_placed else "已自由摆放 %s · Alt 已跳过城池吸附" % character_name
	_commit_placements(
		next,
		"移动%s" % character_name if was_placed else "摆出%s" % character_name,
		status_text
	)


func _on_map_character_drag_released(character_id: String, global_position: Vector2, normalized_position: Vector2, valid_map_drop: bool) -> void:
	if backpack != null and backpack.get_global_rect().has_point(global_position):
		_on_character_returned(character_id)
	elif valid_map_drop:
		_on_character_dropped(character_id, normalized_position)
	else:
		map_board.set_placements(placements)
		_set_status("人物仍保留在原位置")
	if test_mode:
		_append_drag_performance_status()


func _on_map_character_group_drag_released(character_ids: Array, global_position: Vector2, normalized_positions: Dictionary, valid_map_drop: bool) -> void:
	if character_ids.size() <= 1:
		return
	if backpack != null and backpack.get_global_rect().has_point(global_position):
		_on_character_group_returned(character_ids)
	elif not valid_map_drop or normalized_positions.size() != character_ids.size():
		map_board.set_placements(placements)
		_set_status("整组人物仍保留在原位置")
	else:
		var next := placements.duplicate(true)
		var moved_ids: Array[String] = []
		for character_id_value in character_ids:
			var character_id := str(character_id_value)
			if not placements.has(character_id) or not normalized_positions.has(character_id):
				continue
			var normalized: Vector2 = normalized_positions[character_id]
			next[character_id] = {
				"x": clampf(normalized.x, 0.0, 1.0),
				"y": clampf(normalized.y, 0.0, 1.0)
			}
			moved_ids.append(character_id)
		if moved_ids.size() == character_ids.size():
			var lead_name := _character_name(moved_ids[0])
			_commit_placements(
				next,
				"整组移动%s等%d人" % [lead_name, moved_ids.size()],
				"已整组移动 %s 等 %d 人 · 保持相对位置 · 可撤销" % [lead_name, moved_ids.size()]
			)
		else:
			map_board.set_placements(placements)
			_set_status("整组移动未应用：人物数据不完整")
	if test_mode:
		_append_drag_performance_status()


func _on_map_character_selected(character_id: String) -> void:
	if character_id.is_empty():
		return
	var stack_state := map_board.get_character_stack_state(character_id) if map_board != null else {}
	if not str(stack_state.get("place_id", "")).is_empty():
		_set_status("已选中 %s · %s · %s（%d 人）· %s" % [
			_character_name(character_id),
			str(stack_state.get("place_name", "城池")),
			str(stack_state.get("faction_name", "未编组")),
			int(stack_state.get("group_count", 1)),
			_character_action_label(_effective_character_action(character_id))
		])
	else:
		_set_status("已选中 %s · %s，可拖动调整位置" % [_character_name(character_id), _character_action_label(_effective_character_action(character_id))])


func _on_map_character_selection_changed(character_ids: Array) -> void:
	var previous_count := _last_map_selection_count
	_last_map_selection_count = character_ids.size()
	if character_ids.size() > 1:
		_set_status("已选 %d 人 · 拖动整组移动 · 右键批量行动或收回 · Esc 取消" % character_ids.size())
	elif character_ids.is_empty() and previous_count > 1:
		_set_status("已取消人物多选")


func _on_city_faction_window_toggled(place_name: String, faction_name: String, member_count: int, collapsed: bool) -> void:
	_set_status("%s · %s已%s（%d 人）" % [place_name, faction_name, "收起，仅显示势力" if collapsed else "展开", member_count])


func _on_character_action_requested(character_id: String, action: String) -> void:
	if not placements.has(character_id) or not CharacterActionPolicyScript.is_valid_action(action):
		return
	var next_actions := character_actions.duplicate(true)
	if action == CHARACTER_ACTION_STANDBY:
		next_actions.erase(character_id)
	else:
		next_actions[character_id] = action
	var character_name := _character_name(character_id)
	var action_label := _character_action_label(action)
	_commit_character_actions(
		next_actions,
		"设置%s行动为%s" % [character_name, action_label],
		"已将%s设为%s · 仅作沙盘标注 · 可撤销" % [character_name, action_label]
	)


func _normalized_placed_character_ids(character_ids: Array) -> Array[String]:
	var result: Array[String] = []
	for character_id_value in character_ids:
		var character_id := str(character_id_value)
		if placements.has(character_id) and character_id not in result:
			result.append(character_id)
	return result


func _on_character_group_action_requested(character_ids: Array, action: String) -> void:
	if not CharacterActionPolicyScript.is_valid_action(action):
		return
	var placed_ids := _normalized_placed_character_ids(character_ids)
	if placed_ids.size() <= 1 or placed_ids.size() != character_ids.size():
		_set_status("整组行动未应用：人物选择已经变化")
		return
	var next_actions := character_actions.duplicate(true)
	for character_id in placed_ids:
		if action == CHARACTER_ACTION_STANDBY:
			next_actions.erase(character_id)
		else:
			next_actions[character_id] = action
	var lead_name := _character_name(placed_ids[0])
	var action_label := _character_action_label(action)
	if not _commit_character_actions(
		next_actions,
		"整组设置%s等%d人为%s" % [lead_name, placed_ids.size(), action_label],
		"已将 %s 等 %d 人整组设为%s · 仅作沙盘标注 · 可撤销" % [
			lead_name,
			placed_ids.size(),
			action_label,
		]
	):
		if _character_actions_match(character_actions, next_actions):
			_set_status("所选 %d 人已经全部为%s" % [placed_ids.size(), action_label])


func _on_character_group_returned(character_ids: Array) -> void:
	var placed_ids := _normalized_placed_character_ids(character_ids)
	if placed_ids.size() <= 1 or placed_ids.size() != character_ids.size():
		if map_board != null:
			map_board.set_placements(placements)
		_set_status("整组收回未应用：人物选择已经变化")
		return
	var next := placements.duplicate(true)
	for character_id in placed_ids:
		next.erase(character_id)
	var lead_name := _character_name(placed_ids[0])
	if not _commit_placements(
		next,
		"整组收回%s等%d人" % [lead_name, placed_ids.size()],
		"已将 %s 等 %d 人整组收回背包 · 人物资料与本局标注保留 · 可撤销" % [
			lead_name,
			placed_ids.size(),
		]
	):
		if map_board != null:
			map_board.set_placements(placements)


func _on_character_troops_requested(character_id: String) -> void:
	if character_troop_dialog == null or not placements.has(character_id):
		return
	if _find_character_record(character_id).is_empty():
		_set_status("兵力暂时无法调整：找不到人物资料")
		return
	character_troop_pending_id = character_id
	character_troop_spin.value = _effective_character_troop_count(character_id)
	character_troop_dialog.title = "%s · 调整兵力" % _character_name(character_id)
	character_troop_dialog.popup_centered(Vector2i(620, 330))
	character_troop_dialog.size = Vector2i(620, 330)
	character_troop_spin.get_line_edit().call_deferred("grab_focus")
	character_troop_spin.get_line_edit().call_deferred("select_all")
	_set_status("正在调整%s的兵力" % _character_name(character_id))


func _on_character_troop_adjust_requested(character_id: String, delta: int, reset_to_default: bool) -> void:
	if not placements.has(character_id) or _find_character_record(character_id).is_empty():
		return
	var current_troops := _effective_character_troop_count(character_id)
	var troop_count := (
		CHARACTER_TROOP_DEFAULT
		if reset_to_default
		else clampi(current_troops + delta, CHARACTER_TROOP_MIN, CHARACTER_TROOP_MAX)
	)
	var next_troops := character_troops.duplicate(true)
	if troop_count == CHARACTER_TROOP_DEFAULT:
		next_troops.erase(character_id)
	else:
		next_troops[character_id] = troop_count
	var character_name := _character_name(character_id)
	_commit_character_troops(
		next_troops,
		"快速调整%s兵力" % character_name,
		"已将%s兵力设为 %s · 可撤销" % [character_name, _format_troop_count_exact(troop_count)]
	)


func _adjust_pending_character_troops(delta: int) -> void:
	if character_troop_spin == null or character_troop_pending_id.is_empty():
		return
	character_troop_spin.value = clampi(
		roundi(character_troop_spin.value) + delta,
		CHARACTER_TROOP_MIN,
		CHARACTER_TROOP_MAX
	)


func _set_pending_character_troops_default() -> void:
	_set_pending_character_troops(CHARACTER_TROOP_DEFAULT)


func _set_pending_character_troops(value: int) -> void:
	if character_troop_spin == null or character_troop_pending_id.is_empty():
		return
	character_troop_spin.value = clampi(value, CHARACTER_TROOP_MIN, CHARACTER_TROOP_MAX)


func _confirm_character_troop_dialog() -> void:
	var character_id := character_troop_pending_id
	character_troop_pending_id = ""
	if character_id.is_empty() or not _has_character_id(character_id):
		return
	var troop_count := clampi(
		roundi(character_troop_spin.value),
		CHARACTER_TROOP_MIN,
		CHARACTER_TROOP_MAX
	)
	var next_troops := character_troops.duplicate(true)
	if troop_count == CHARACTER_TROOP_DEFAULT:
		next_troops.erase(character_id)
	else:
		next_troops[character_id] = troop_count
	var character_name := _character_name(character_id)
	_commit_character_troops(
		next_troops,
		"调整%s兵力" % character_name,
		"已将%s兵力设为 %s · 可撤销" % [character_name, _format_troop_count_exact(troop_count)]
	)


func _cancel_character_troop_dialog() -> void:
	if character_troop_pending_id.is_empty():
		return
	var character_name := _character_name(character_troop_pending_id)
	character_troop_pending_id = ""
	_set_status("已取消调整%s的兵力" % character_name)


func _on_character_faction_assignment_requested(character_id: String, target_faction_id: String) -> void:
	if not placements.has(character_id) or _find_character_record(character_id).is_empty():
		return
	var validation := _decode_scenario_state(scenario_state)
	if not bool(validation.get("ok", false)):
		_set_status("所属势力未更新：当前沙盘分组需要先修复")
		return
	var next_state: Dictionary = validation.get("scenario_state", {}).duplicate(true)
	var assignment_map := _scenario_assignment_map(next_state)
	var current_faction_id := str(assignment_map.get(character_id, ""))
	if current_faction_id == target_faction_id:
		var unchanged_name := (
			str(_scenario_faction_record_in_state(next_state, current_faction_id).get("name", "未命名势力"))
			if not current_faction_id.is_empty()
			else "未编组"
		)
		_set_status("%s已属于%s" % [_character_name(character_id), unchanged_name])
		return
	if not target_faction_id.is_empty():
		var target_faction := _scenario_faction_record_in_state(next_state, target_faction_id)
		if target_faction.is_empty():
			_set_status("所属势力未更新：目标势力不存在")
			return
	if not current_faction_id.is_empty():
		var member_counts := _scenario_faction_member_counts(next_state)
		var current_count_record: Dictionary = member_counts.get(current_faction_id, {})
		if int(current_count_record.get("total", 0)) <= 1:
			_set_status("所属势力未更新：该势力仅剩%s；请先从“沙盘”菜单调整成员" % _character_name(character_id))
			return
	var assignments: Array[Dictionary] = []
	for assignment_value in next_state.get("character_assignments", []):
		if not (assignment_value is Dictionary):
			continue
		var assignment: Dictionary = assignment_value
		if str(assignment.get("character_id", "")) != character_id:
			assignments.append(assignment.duplicate(true))
	if not target_faction_id.is_empty():
		assignments.append({"character_id": character_id, "faction_id": target_faction_id})
	assignments.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		return str(first.get("character_id", "")) < str(second.get("character_id", ""))
	)
	next_state["character_assignments"] = assignments
	var old_name := "未编组"
	if not current_faction_id.is_empty():
		old_name = str(_scenario_faction_record_in_state(next_state, current_faction_id).get("name", "未命名势力"))
	var target_name := "未编组"
	if not target_faction_id.is_empty():
		target_name = str(_scenario_faction_record_in_state(next_state, target_faction_id).get("name", "未命名势力"))
	var character_name := _character_name(character_id)
	_commit_scenario_state(
		next_state,
		"调整%s所属势力：%s → %s" % [character_name, old_name, target_name],
		"已将%s从%s调整至%s · 可撤销" % [character_name, old_name, target_name]
	)


func _on_character_attributes_requested(character_id: String) -> void:
	if character_attribute_dialog == null or not placements.has(character_id):
		return
	var character := _find_character_record(character_id)
	if character.is_empty():
		_set_status("本局属性暂时无法调整：找不到人物资料")
		return
	var state: Dictionary = character_states.get(character_id, {})
	var effective := _effective_character_attributes(character_id)
	character_attribute_pending_id = character_id
	character_attribute_might_spin.value = int(effective.get("might", CHARACTER_ATTRIBUTE_EDITOR_INITIAL))
	character_attribute_intelligence_spin.value = int(effective.get("intelligence", CHARACTER_ATTRIBUTE_EDITOR_INITIAL))
	character_attribute_leadership_spin.value = int(effective.get("leadership", CHARACTER_ATTRIBUTE_EDITOR_INITIAL))
	character_attribute_charisma_spin.value = int(effective.get("charisma", CHARACTER_ATTRIBUTE_EDITOR_INITIAL))
	character_attribute_clear_button.disabled = state.is_empty()
	var has_legacy := str(state.get("state_schema", "")) == CHARACTER_STATE_SCHEMA_LEGACY_V8_COMBAT
	character_attribute_legacy_label.visible = has_legacy
	character_attribute_legacy_label.text = "保留的旧版记录：攻击 %d／防御 %d。未自动换算；应用本局调整后才会由四维覆盖。" % [
		int(state.get("attack", 0)),
		int(state.get("defense", 0))
	] if has_legacy else ""
	character_attribute_dialog.title = "%s · 武力／智力／统率／魅力" % str(character.get("name", character_id))
	character_attribute_dialog.popup_centered(Vector2i(560, 390))
	character_attribute_dialog.size = Vector2i(560, 390)
	_set_status("正在调整%s的人物资料" % str(character.get("name", character_id)))


func _confirm_character_attribute_dialog() -> void:
	var character_id := character_attribute_pending_id
	character_attribute_pending_id = ""
	if character_id.is_empty() or not _has_character_id(character_id):
		return
	var next_states := character_states.duplicate(true)
	next_states[character_id] = {
		"state_schema": CHARACTER_STATE_SCHEMA_FOUR_DIMENSIONS,
		"might": roundi(character_attribute_might_spin.value),
		"intelligence": roundi(character_attribute_intelligence_spin.value),
		"leadership": roundi(character_attribute_leadership_spin.value),
		"charisma": roundi(character_attribute_charisma_spin.value)
	}
	var character_name := _character_name(character_id)
	_commit_character_states(
		next_states,
		"调整%s本局人物资料" % character_name,
		"已调整%s · 武 %d · 智 %d · 统 %d · 魅 %d · 可撤销" % [
			character_name,
			int(next_states[character_id].get("might", 0)),
			int(next_states[character_id].get("intelligence", 0)),
			int(next_states[character_id].get("leadership", 0)),
			int(next_states[character_id].get("charisma", 0))
		]
	)


func _clear_pending_character_attributes() -> void:
	var character_id := character_attribute_pending_id
	if character_id.is_empty() or not character_states.has(character_id):
		return
	var next_states := character_states.duplicate(true)
	next_states.erase(character_id)
	var character_name := _character_name(character_id)
	if _commit_character_states(next_states, "恢复%s项目初始值" % character_name, "已恢复%s的项目初始四维 · 可撤销" % character_name):
		character_attribute_pending_id = ""
		character_attribute_dialog.hide()


func _cancel_character_attribute_dialog() -> void:
	if character_attribute_pending_id.is_empty():
		return
	var character_name := _character_name(character_attribute_pending_id)
	character_attribute_pending_id = ""
	_set_status("已取消调整%s的人物资料" % character_name)


func _character_state_summary(character_id: String) -> String:
	var state: Dictionary = character_states.get(character_id, {})
	var effective := _effective_character_attributes(character_id)
	var summary := "兵力：%s\n人物四维：武力 %d　智力 %d　统率 %d　魅力 %d" % [
		_format_troop_count_exact(_effective_character_troop_count(character_id)),
		int(effective.get("might", 0)),
		int(effective.get("intelligence", 0)),
		int(effective.get("leadership", 0)),
		int(effective.get("charisma", 0))
	]
	if str(state.get("state_schema", "")) == CHARACTER_STATE_SCHEMA_LEGACY_V8_COMBAT:
		summary += "\n旧版兼容数值：攻击 %d　防御 %d（与当前行动无关，未换算）" % [
			int(state.get("attack", 0)),
			int(state.get("defense", 0))
		]
	return summary


func _format_troop_count_exact(value: int) -> String:
	var digits := str(maxi(0, value))
	var grouped := ""
	for index in range(digits.length()):
		if index > 0 and (digits.length() - index) % 3 == 0:
			grouped += ","
		grouped += digits[index]
	return grouped


func _open_current_roster_dialog() -> void:
	if current_roster_dialog == null or current_roster_tree == null:
		return
	_refresh_current_roster_dialog()
	current_roster_dialog.popup_centered(Vector2i(900, 560))
	current_roster_dialog.size = Vector2i(900, 560)
	call_deferred("_focus_current_roster_dialog")
	_set_status("正在查看本局已摆人物")


func _refresh_current_roster_dialog() -> void:
	if current_roster_tree == null:
		return
	var preferred_character_id := current_roster_selected_id
	current_roster_tree.clear()
	current_roster_character_ids.clear()
	current_roster_rows.clear()
	current_roster_groups.clear()
	current_roster_selected_id = ""
	current_roster_tree.set_column_title(
		1,
		"势力" if current_roster_view_mode == CURRENT_ROSTER_VIEW_PLACE else "地点"
	)
	if current_roster_faction_view_button != null:
		current_roster_faction_view_button.button_pressed = (
			current_roster_view_mode == CURRENT_ROSTER_VIEW_FACTION
		)
	if current_roster_place_view_button != null:
		current_roster_place_view_button.button_pressed = (
			current_roster_view_mode == CURRENT_ROSTER_VIEW_PLACE
		)
	var root_item := current_roster_tree.create_item()
	var assignment_map := _scenario_assignment_map(scenario_state)
	var faction_order: Array[String] = []
	var characters_by_faction: Dictionary = {}
	var faction_by_id: Dictionary = {}
	for faction_value in scenario_state.get("factions", []):
		if not (faction_value is Dictionary):
			continue
		var faction_record: Dictionary = faction_value
		var faction_record_id := str(faction_record.get("id", ""))
		if faction_record_id.is_empty() or characters_by_faction.has(faction_record_id):
			continue
		faction_order.append(faction_record_id)
		characters_by_faction[faction_record_id] = []
		faction_by_id[faction_record_id] = faction_record.duplicate(true)
	faction_order.append("")
	characters_by_faction[""] = []
	var row_by_character_id: Dictionary = {}
	var characters_by_place: Dictionary = {}
	var anchored_count := 0
	var free_count := 0
	for character_id in character_catalog_ids:
		if not placements.has(character_id):
			continue
		var assigned_faction_id := str(assignment_map.get(character_id, ""))
		if not characters_by_faction.has(assigned_faction_id):
			assigned_faction_id = ""
		(characters_by_faction[assigned_faction_id] as Array).append(character_id)
		var assigned_faction: Dictionary = faction_by_id.get(assigned_faction_id, {})
		var assigned_faction_name := (
			str(assigned_faction.get("name", "未编组"))
			if not assigned_faction.is_empty()
			else "未编组"
		)
		var placement: Dictionary = placements.get(character_id, {})
		var raw_place_id := str(placement.get("place_id", ""))
		var placed_at := _find_place(raw_place_id)
		var registered_place_id := ""
		var location_text := "自由落点"
		if not placed_at.is_empty():
			registered_place_id = raw_place_id
			location_text = str(placed_at.get("name", raw_place_id))
			anchored_count += 1
		else:
			free_count += 1
		if not characters_by_place.has(registered_place_id):
			characters_by_place[registered_place_id] = []
		(characters_by_place[registered_place_id] as Array).append(character_id)
		var action := str(character_actions.get(character_id, CHARACTER_ACTION_STANDBY))
		row_by_character_id[character_id] = {
			"character_id": character_id,
			"name": _character_name(character_id),
			"faction_id": assigned_faction_id,
			"faction_name": assigned_faction_name,
			"place_id": registered_place_id,
			"location": location_text,
			"action": action,
			"action_label": _character_action_label(action),
			"troops": _effective_character_troop_count(character_id),
		}

	var active_faction_count := 0
	for ordered_faction_id in faction_order:
		if not (characters_by_faction.get(ordered_faction_id, []) as Array).is_empty():
			active_faction_count += 1
	var display_groups: Array[Dictionary] = []
	if current_roster_view_mode == CURRENT_ROSTER_VIEW_PLACE:
		var place_header_color := UiThemeScript.INK_LIST_SELECTED
		place_header_color.a = 0.58
		for place_value in places:
			if not (place_value is Dictionary):
				continue
			var place_record: Dictionary = place_value
			var display_place_id := str(place_record.get("id", ""))
			var place_member_ids: Array = characters_by_place.get(display_place_id, [])
			if place_member_ids.is_empty():
				continue
			display_groups.append({
				"id": display_place_id,
				"name": str(place_record.get("name", display_place_id)),
				"member_ids": place_member_ids.duplicate(),
				"header_color": place_header_color,
			})
		var free_member_ids: Array = characters_by_place.get("", [])
		if not free_member_ids.is_empty():
			var free_header_color := UiThemeScript.INK_BOARD
			free_header_color.a = 0.72
			display_groups.append({
				"id": "",
				"name": "自由落点",
				"member_ids": free_member_ids.duplicate(),
				"header_color": free_header_color,
			})
	else:
		for display_faction_id in faction_order:
			var faction_member_ids: Array = characters_by_faction.get(display_faction_id, [])
			if faction_member_ids.is_empty():
				continue
			var display_faction: Dictionary = faction_by_id.get(display_faction_id, {})
			var display_faction_name := (
				str(display_faction.get("name", "未编组"))
				if not display_faction.is_empty()
				else "未编组"
			)
			var faction_header_color := FactionPaletteScript.to_color(
				str(display_faction.get("color", "#888575")),
				Color("888575")
			)
			faction_header_color.a = 0.16
			display_groups.append({
				"id": display_faction_id,
				"name": display_faction_name,
				"member_ids": faction_member_ids.duplicate(),
				"header_color": faction_header_color,
			})

	var first_character_item: TreeItem = null
	var preferred_character_item: TreeItem = null
	for display_group in display_groups:
		var display_member_ids: Array = display_group.get("member_ids", [])
		var display_group_id := str(display_group.get("id", ""))
		var display_group_name := str(display_group.get("name", ""))
		var header_color = display_group.get("header_color", UiThemeScript.INK_LIST_SELECTED)
		var group_verb := "摆在地图上"
		if current_roster_view_mode == CURRENT_ROSTER_VIEW_PLACE and not display_group_id.is_empty():
			group_verb = "驻扎"
		var group_item := current_roster_tree.create_item(root_item)
		group_item.set_text(0, "%s · %d" % [display_group_name, display_member_ids.size()])
		group_item.set_tooltip_text(0, "%s当前有 %d 位人物%s" % [display_group_name, display_member_ids.size(), group_verb])
		for column_index in range(current_roster_tree.columns):
			group_item.set_selectable(column_index, false)
			group_item.set_custom_bg_color(column_index, header_color)
			group_item.set_custom_color(column_index, UiThemeScript.TEXT_FIELD)
		group_item.collapsed = false
		current_roster_groups.append({
			"id": display_group_id,
			"name": display_group_name,
			"count": display_member_ids.size(),
			"character_ids": display_member_ids.duplicate(),
		})
		for character_id_value in display_member_ids:
			var character_id := str(character_id_value)
			var row: Dictionary = row_by_character_id.get(character_id, {})
			var secondary_text := (
				str(row.get("faction_name", "未编组"))
				if current_roster_view_mode == CURRENT_ROSTER_VIEW_PLACE
				else str(row.get("location", "自由落点"))
			)
			var action_text := str(row.get("action_label", "待命"))
			var troop_text := _format_troop_count_exact(int(row.get("troops", 1000)))
			var character_item := current_roster_tree.create_item(group_item)
			character_item.set_text(0, str(row.get("name", _character_name(character_id))))
			character_item.set_text(1, secondary_text)
			character_item.set_text(2, action_text)
			character_item.set_text(3, troop_text)
			character_item.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
			character_item.set_text_alignment(3, HORIZONTAL_ALIGNMENT_RIGHT)
			character_item.set_metadata(0, character_id)
			character_item.set_tooltip_text(0, "选择后可定位或查看人物卡")
			character_item.set_tooltip_text(
				1,
				"%s：%s"
				% ["当前势力" if current_roster_view_mode == CURRENT_ROSTER_VIEW_PLACE else "当前落点", secondary_text]
			)
			character_item.set_tooltip_text(2, "当前行动：%s" % action_text)
			character_item.set_tooltip_text(3, "当前兵力：%s" % troop_text)
			current_roster_character_ids.append(character_id)
			var visible_row := row.duplicate(true)
			visible_row["group_mode"] = current_roster_view_mode
			visible_row["group_id"] = display_group_id
			visible_row["group_name"] = display_group_name
			current_roster_rows.append(visible_row)
			if first_character_item == null:
				first_character_item = character_item
			if character_id == preferred_character_id:
				preferred_character_item = character_item

	var placed_count := current_roster_character_ids.size()
	current_roster_summary_label.text = (
		"已摆 %d / %d · 势力 %d · 地点驻扎 %d · 自由落点 %d"
		% [placed_count, character_catalog_ids.size(), active_faction_count, anchored_count, free_count]
	)
	var has_characters := placed_count > 0
	current_roster_tree.visible = has_characters
	current_roster_empty_label.visible = not has_characters
	current_roster_locate_button.disabled = true
	current_roster_profile_button.disabled = true
	var item_to_select := preferred_character_item if preferred_character_item != null else first_character_item
	if item_to_select != null:
		item_to_select.select(0)
		current_roster_tree.scroll_to_item(item_to_select, true)
		_sync_current_roster_selection()


func _on_current_roster_view_mode_pressed(view_mode: String) -> void:
	if view_mode != CURRENT_ROSTER_VIEW_FACTION and view_mode != CURRENT_ROSTER_VIEW_PLACE:
		return
	var changed := current_roster_view_mode != view_mode
	current_roster_view_mode = view_mode
	_refresh_current_roster_dialog()
	if changed:
		_set_status("本局人物一览已按%s整理" % ("地点" if view_mode == CURRENT_ROSTER_VIEW_PLACE else "势力"))


func _sync_current_roster_selection() -> void:
	current_roster_selected_id = ""
	if current_roster_tree != null:
		var selected_item := current_roster_tree.get_selected()
		if selected_item != null:
			var candidate_id := str(selected_item.get_metadata(0))
			if current_roster_character_ids.has(candidate_id) and placements.has(candidate_id):
				current_roster_selected_id = candidate_id
	var has_selection := not current_roster_selected_id.is_empty()
	if current_roster_locate_button != null:
		current_roster_locate_button.disabled = not has_selection
	if current_roster_profile_button != null:
		current_roster_profile_button.disabled = not has_selection


func _on_current_roster_item_selected() -> void:
	_sync_current_roster_selection()


func _on_current_roster_item_activated() -> void:
	_sync_current_roster_selection()
	_on_current_roster_locate_pressed()


func _on_current_roster_locate_pressed() -> void:
	var character_id := current_roster_selected_id
	if character_id.is_empty():
		return
	if not placements.has(character_id):
		_refresh_current_roster_dialog()
		_set_status("这名人物已经收回背包；本局人物一览已刷新")
		return
	if map_board == null or not map_board.focus_character(character_id):
		_set_status("暂时无法定位%s；请先完成或取消当前路线调整" % _character_name(character_id))
		return
	current_roster_dialog.hide()
	_set_status("已定位%s；可直接拖动，右键查看人物卡" % _character_name(character_id))


func _on_current_roster_profile_pressed() -> void:
	var character_id := current_roster_selected_id
	if character_id.is_empty():
		return
	if not placements.has(character_id):
		_refresh_current_roster_dialog()
		_set_status("这名人物已经收回背包；本局人物一览已刷新")
		return
	character_detail_restore_focus_on_close = true
	character_detail_return_focus = current_roster_tree
	character_detail_restore_roster_on_close = current_roster_dialog != null and current_roster_dialog.visible
	if character_detail_restore_roster_on_close:
		current_roster_dialog.hide()
	character_detail_opening_context.clear()
	character_detail_opening_return_state.clear()
	_open_character_profile(character_id, current_roster_character_ids)


func _focus_current_roster_dialog() -> void:
	if current_roster_dialog == null or not current_roster_dialog.visible:
		return
	if current_roster_tree != null and current_roster_tree.visible:
		current_roster_tree.grab_focus()


func _close_current_roster_dialog() -> void:
	if current_roster_dialog != null:
		current_roster_dialog.hide()


func get_current_roster_view_state() -> Dictionary:
	return {
		"visible": current_roster_dialog != null and current_roster_dialog.visible,
		"view_mode": current_roster_view_mode,
		"secondary_column": current_roster_tree.get_column_title(1) if current_roster_tree != null else "",
		"summary": current_roster_summary_label.text if current_roster_summary_label != null else "",
		"empty_visible": current_roster_empty_label != null and current_roster_empty_label.visible,
		"tree_visible": current_roster_tree != null and current_roster_tree.visible,
		"character_ids": current_roster_character_ids.duplicate(),
		"rows": current_roster_rows.duplicate(true),
		"groups": current_roster_groups.duplicate(true),
		"selected_character_id": current_roster_selected_id,
		"locate_enabled": current_roster_locate_button != null and not current_roster_locate_button.disabled,
		"profile_enabled": current_roster_profile_button != null and not current_roster_profile_button.disabled,
	}


func _on_character_details_requested(character_id: String) -> void:
	character_detail_opening_context.clear()
	character_detail_opening_return_state.clear()
	character_detail_return_focus = null
	character_detail_restore_focus_on_close = false
	character_detail_restore_roster_on_close = false
	_open_character_profile(character_id, [])


func _on_backpack_character_details_requested(character_id: String, browse_ids: Array[String]) -> void:
	character_detail_opening_context.clear()
	character_detail_opening_return_state.clear()
	character_detail_restore_focus_on_close = true
	character_detail_restore_roster_on_close = false
	character_detail_return_focus = backpack.get_placed_details_button(character_id)
	if character_detail_return_focus == null:
		character_detail_return_focus = backpack.get_search_edit()
	_open_character_profile(character_id, browse_ids)


func _open_character_profile(character_id: String, requested_browse_ids: Array[String]) -> bool:
	if character_detail_dialog == null or character_detail_text == null:
		return false
	character_detail_browse_ids = _normalize_character_profile_browse_ids(requested_browse_ids)
	character_detail_browse_index = character_detail_browse_ids.find(character_id)
	if character_detail_browse_index < 0:
		character_detail_browse_ids.clear()
		character_detail_browse_index = -1
	if not _render_character_profile(character_id):
		character_detail_browse_ids.clear()
		character_detail_browse_index = -1
		_refresh_character_profile_browser_controls()
		return false
	_refresh_character_profile_browser_controls()
	character_detail_dialog.popup_centered(Vector2i(760, 610))
	character_detail_dialog.size = Vector2i(760, 610)
	call_deferred("_focus_character_profile_dialog")
	return true


func _render_character_profile(character_id: String) -> bool:
	var character := _find_character_record(character_id)
	if character.is_empty():
		_set_status("人物卡暂时无法打开：找不到人物资料")
		return false
	var character_name := str(character.get("name", character_id))
	_refresh_character_detail_nameplate(character_name)
	var alias_values := PackedStringArray()
	for alias_value in character.get("aliases", []):
		var alias_text := str(alias_value).strip_edges()
		if not alias_text.is_empty():
			alias_values.append(alias_text)
	var title_color := UiThemeScript.TEXT_PANEL_TITLE.to_html(false)
	var secondary_color := UiThemeScript.TEXT_SUMMARY.to_html(false)
	var accent_color := UiThemeScript.TEXT_ACCENT.to_html(false)
	var character_header := "[font_size=29][color=#%s]%s[/color][/font_size]" % [
		title_color,
		_bbcode_escape(character_name)
	]
	if not alias_values.is_empty():
		var aliases_text := "字／别名：%s" % "、".join(alias_values)
		character_header += "\n[color=#%s][font_size=16]%s[/font_size][/color]" % [
			secondary_color,
			_bbcode_escape(aliases_text)
		]
	var profile: Dictionary = character_profiles_by_id.get(character_id, {})
	var headline := str(profile.get("headline", "人物资料整理中"))
	var biography := str(profile.get("biography", "这名人物的小传仍在整理，后续会逐步补充。"))
	var context_section := ""
	if not character_detail_opening_context.is_empty():
		var opening_records: Dictionary = character_detail_opening_context.get("records", {})
		var opening_record: Dictionary = opening_records.get(character_id, {})
		if opening_record.is_empty():
			_set_status("人物卡暂时无法打开：所选开局没有这名重点人物")
			return false
		context_section = "[b][color=#%s]所选开局[/color][/b]\n%s\n开局位置：%s\n开局势力：%s" % [
			title_color,
			_bbcode_escape(str(character_detail_opening_context.get("opening_label", "未命名开局"))),
			_bbcode_escape(str(opening_record.get("position_text", "待从人物背包摆放"))),
			_bbcode_escape(str(opening_record.get("faction_text", "未预设"))),
		]
	else:
		var faction_text := _scenario_faction_name_for_character(character_id)
		if faction_text == "未加入玩家分组":
			faction_text = "未编组"
		context_section = "[b][color=#%s]当前沙盘[/color][/b]\n所在：%s\n玩法势力：%s　　当前行动：%s\n\n%s" % [
			title_color,
			_bbcode_escape(_scenario_character_location_text(character_id)),
			_bbcode_escape(faction_text),
			_bbcode_escape(_character_action_label(_effective_character_action(character_id))),
			_bbcode_escape(_character_state_summary(character_id))
		]
	var affiliation_text := _character_affiliation_text(character)
	var body_sections: Array[String] = [
		character_header,
		"[color=#%s][font_size=18]%s[/font_size][/color]" % [
			accent_color,
			_bbcode_escape(headline)
		],
		"[b][color=#%s]人物小传[/color][/b]\n[font_size=16]%s[/font_size]" % [
			title_color,
			_bbcode_escape(biography)
		],
		context_section
	]
	if not affiliation_text.is_empty() and affiliation_text != "尚未录入可显示的史料关系":
		body_sections.append(
			"[b][color=#%s]史书中的明确记录[/color][/b]\n%s"
			% [title_color, _bbcode_escape(affiliation_text)]
		)
	character_detail_character_id = character_id
	character_detail_dialog.title = "%s · 人物卡" % character_name
	character_detail_text.text = "\n\n".join(body_sections)
	if character_detail_opening_context.is_empty():
		_refresh_character_profile_place_button(character_id)
	else:
		character_detail_place_button.visible = false
		character_detail_place_button.disabled = true
		character_detail_place_button.set_meta("place_id", "")
	_refresh_character_profile_chronicle_button(character_id)
	character_detail_text.scroll_to_line(0)
	var scroll_bar := character_detail_text.get_v_scroll_bar()
	if scroll_bar != null:
		scroll_bar.value = 0.0
	if character_detail_browse_ids.size() > 1 and character_detail_browse_index >= 0:
		_set_status(
			"正在查看%s人物卡 · 第 %d / %d 位 · 只读"
			% [character_name, character_detail_browse_index + 1, character_detail_browse_ids.size()]
		)
	else:
		_set_status("正在查看%s人物卡 · 只读，沙盘保持不变" % character_name)
	return true


func _character_profile_place_id(character_id: String) -> String:
	if not placements.has(character_id):
		return ""
	var placement: Dictionary = placements.get(character_id, {})
	var place_id := str(placement.get("place_id", ""))
	if place_id.is_empty() or _find_place(place_id).is_empty():
		return ""
	return place_id


func _refresh_character_profile_place_button(character_id: String) -> void:
	if character_detail_place_button == null:
		return
	if not character_detail_opening_context.is_empty():
		character_detail_place_button.visible = false
		character_detail_place_button.disabled = true
		character_detail_place_button.set_meta("place_id", "")
		return
	var place_id := _character_profile_place_id(character_id)
	var place := _find_place(place_id)
	var has_registered_place := not place.is_empty()
	character_detail_place_button.visible = has_registered_place
	character_detail_place_button.disabled = not has_registered_place
	character_detail_place_button.set_meta("place_id", place_id if has_registered_place else "")
	if not has_registered_place:
		character_detail_place_button.text = "查看落点"
		character_detail_place_button.tooltip_text = "自由落点没有对应的地点札记"
		return
	var place_name := str(place.get("name", place_id))
	character_detail_place_button.text = "查看%s" % place_name
	character_detail_place_button.tooltip_text = "收起人物卡，定位%s并打开地点札记" % place_name


func _refresh_character_profile_chronicle_button(character_id: String) -> void:
	if character_detail_chronicle_button == null:
		return
	if not character_detail_opening_context.is_empty():
		character_detail_chronicle_button.visible = false
		character_detail_chronicle_button.disabled = true
		return
	var character := _find_character_record(character_id)
	var at_limit := chronicle_entries.size() >= CHRONICLE_ENTRY_LIMIT
	character_detail_chronicle_button.visible = not character.is_empty()
	character_detail_chronicle_button.disabled = character.is_empty() or at_limit
	if at_limit:
		character_detail_chronicle_button.tooltip_text = "玩家纪事已达到 %d 则上限；可在纪事管理器中编辑或删除" % CHRONICLE_ENTRY_LIMIT
	elif not character.is_empty():
		character_detail_chronicle_button.tooltip_text = (
			"以“%s · %s”为上下文写一则玩家纪事；不会移动人物或镜头"
			% [
				str(character.get("name", character_id)),
				_scenario_character_location_text(character_id),
			]
		)


func _open_character_profile_chronicle_editor() -> void:
	if (
		character_detail_dialog == null
		or not character_detail_dialog.visible
		or not character_detail_opening_context.is_empty()
	):
		return
	var character_id := character_detail_character_id
	var character := _find_character_record(character_id)
	if character.is_empty():
		_set_status("当前人物已经不可用；沙盘没有变化")
		return
	if chronicle_entries.size() >= CHRONICLE_ENTRY_LIMIT:
		_refresh_character_profile_chronicle_button(character_id)
		_set_status("玩家纪事已达到 %d 则上限" % CHRONICLE_ENTRY_LIMIT)
		return
	var character_name := str(character.get("name", character_id))
	var location_text := _scenario_character_location_text(character_id)
	character_detail_dialog.hide()
	_pending_chronicle_id = ""
	_open_new_chronicle_editor({
		"kind": "character_profile",
		"character_id": character_id,
		"prefill_body": "人物：%s\n所在：%s\n\n" % [character_name, location_text],
	})


func _on_character_profile_place_pressed() -> void:
	if not character_detail_opening_context.is_empty():
		return
	var character_id := character_detail_character_id
	if character_id.is_empty():
		return
	var place_id := _character_profile_place_id(character_id)
	var place := _find_place(place_id)
	if place.is_empty():
		_refresh_character_profile_place_button(character_id)
		_set_status("%s当前不在已登记地点" % _character_name(character_id))
		return
	if map_board == null or not map_board.focus_place(place_id):
		_set_status("这个地点暂时无法定位")
		return
	var character_name := _character_name(character_id)
	var place_name := str(place.get("name", place_id))
	character_detail_restore_focus_on_close = false
	character_detail_restore_roster_on_close = false
	character_detail_return_focus = null
	if character_detail_dialog != null:
		character_detail_dialog.hide()
	_on_character_detail_dialog_closed()
	if current_roster_dialog != null and current_roster_dialog.visible:
		current_roster_dialog.hide()
	_open_place_detail_panel(place_id)
	call_deferred("_focus_place_detail_primary_action")
	_set_status("已从%s人物卡回到%s地点札记" % [character_name, place_name])


func get_character_profile_place_navigation_contract() -> Dictionary:
	return {
		"character_id": character_detail_character_id,
		"place_id": str(character_detail_place_button.get_meta("place_id", "")) if character_detail_place_button != null else "",
		"visible": character_detail_place_button != null and character_detail_place_button.visible,
		"enabled": character_detail_place_button != null and not character_detail_place_button.disabled,
		"text": character_detail_place_button.text if character_detail_place_button != null else "",
	}


func _refresh_character_detail_nameplate(character_name: String) -> void:
	if character_detail_nameplate == null:
		return
	character_detail_nameplate.call("set_display_name", character_name)
	character_detail_nameplate.tooltip_text = "%s · 人物名牌" % character_name


func get_character_profile_visual_contract() -> Dictionary:
	var nameplate_contract: Dictionary = (
		character_detail_nameplate.call("get_nameplate_contract") as Dictionary
		if character_detail_nameplate != null
		else {}
	)
	return {
		"dialog_min_size": character_detail_dialog.min_size if character_detail_dialog != null else Vector2i.ZERO,
		"dialog_size": character_detail_dialog.size if character_detail_dialog != null else Vector2i.ZERO,
		"presentation_mode": CHARACTER_PRESENTATION_MODE,
		"nameplate_size": nameplate_contract.get("target_size", Vector2.ZERO),
		"nameplate_full_name": str(nameplate_contract.get("full_name", "")),
		"nameplate_display": str(nameplate_contract.get("display_text", "")),
		"nameplate_uses_raster_asset": bool(nameplate_contract.get("uses_raster_asset", true)),
		"portrait_panel_size": Vector2.ZERO,
		"portrait_visible": false,
		"portrait_available": false,
		"fallback_visible": false,
		"fallback_text": "",
		"content_read_only": true
	}


func _normalize_character_profile_browse_ids(values: Array[String]) -> Array[String]:
	var normalized: Array[String] = []
	var seen: Dictionary = {}
	for character_id_value in values:
		var character_id := str(character_id_value).strip_edges()
		if character_id.is_empty() or seen.has(character_id) or _find_character_record(character_id).is_empty():
			continue
		seen[character_id] = true
		normalized.append(character_id)
	return normalized


func _refresh_character_profile_browser_controls() -> void:
	if (
		character_detail_browser_footer == null
		or character_detail_previous_button == null
		or character_detail_position_label == null
		or character_detail_next_button == null
	):
		return
	var browser_visible := character_detail_browse_ids.size() > 1 and character_detail_browse_index >= 0
	character_detail_browser_footer.visible = browser_visible
	if not browser_visible:
		character_detail_previous_button.disabled = true
		character_detail_next_button.disabled = true
		character_detail_position_label.text = "单张人物卡"
		return
	character_detail_previous_button.disabled = character_detail_browse_index <= 0
	character_detail_next_button.disabled = character_detail_browse_index >= character_detail_browse_ids.size() - 1
	character_detail_position_label.text = "第 %d / %d 位" % [
		character_detail_browse_index + 1,
		character_detail_browse_ids.size()
	]


func _browse_character_profile(offset: int) -> bool:
	if (
		character_detail_dialog == null
		or not character_detail_dialog.visible
		or character_detail_browse_ids.size() <= 1
		or character_detail_browse_index < 0
	):
		return false
	var next_index := character_detail_browse_index + offset
	if next_index < 0 or next_index >= character_detail_browse_ids.size():
		return false
	var previous_index := character_detail_browse_index
	character_detail_browse_index = next_index
	if not _render_character_profile(character_detail_browse_ids[next_index]):
		character_detail_browse_index = previous_index
		return false
	_refresh_character_profile_browser_controls()
	return true


func _on_character_detail_dialog_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	var browse_offset := 0
	if key_event.keycode == KEY_LEFT:
		browse_offset = -1
	elif key_event.keycode == KEY_RIGHT:
		browse_offset = 1
	if browse_offset == 0:
		return
	if _browse_character_profile(browse_offset):
		character_detail_dialog.set_input_as_handled()


func _focus_character_profile_dialog() -> void:
	if character_detail_dialog == null or not character_detail_dialog.visible:
		return
	if character_detail_browser_footer != null and character_detail_browser_footer.visible:
		if character_detail_next_button != null and not character_detail_next_button.disabled:
			character_detail_next_button.grab_focus()
			return
		if character_detail_previous_button != null and not character_detail_previous_button.disabled:
			character_detail_previous_button.grab_focus()
			return
	if character_detail_close_button != null:
		character_detail_close_button.grab_focus()


func _close_character_detail_dialog() -> void:
	if character_detail_dialog == null or not character_detail_dialog.visible:
		return
	character_detail_dialog.hide()
	_on_character_detail_dialog_closed()


func get_character_profile_browser_contract() -> Dictionary:
	return {
		"visible": character_detail_dialog != null and character_detail_dialog.visible,
		"footer_visible": character_detail_browser_footer != null and character_detail_browser_footer.visible,
		"browse_ids": character_detail_browse_ids.duplicate(),
		"index": character_detail_browse_index,
		"current_character_id": character_detail_character_id,
		"previous_enabled": character_detail_previous_button != null and not character_detail_previous_button.disabled,
		"next_enabled": character_detail_next_button != null and not character_detail_next_button.disabled,
		"position_text": character_detail_position_label.text if character_detail_position_label != null else ""
	}


func _on_character_detail_dialog_closed() -> void:
	var should_restore_opening := not character_detail_opening_context.is_empty()
	var opening_return_state := character_detail_opening_return_state.duplicate(true)
	if character_detail_character_id.is_empty():
		character_detail_opening_context.clear()
		character_detail_opening_return_state.clear()
		if should_restore_opening:
			call_deferred("_restore_new_sandbox_after_character_profile", opening_return_state)
		return
	if character_detail_dialog != null and character_detail_dialog.visible:
		character_detail_dialog.hide()
	var character_name := _character_name(character_detail_character_id)
	character_detail_character_id = ""
	character_detail_browse_ids.clear()
	character_detail_browse_index = -1
	_refresh_character_profile_browser_controls()
	_set_status(
		"已收起%s人物卡 · 返回所选开局" % character_name
		if should_restore_opening
		else "已收起%s人物卡 · 沙盘保持不变" % character_name
	)
	var return_focus := character_detail_return_focus
	var should_restore_focus := character_detail_restore_focus_on_close
	var should_restore_roster := character_detail_restore_roster_on_close
	character_detail_return_focus = null
	character_detail_restore_focus_on_close = false
	character_detail_restore_roster_on_close = false
	character_detail_opening_context.clear()
	character_detail_opening_return_state.clear()
	if should_restore_opening:
		call_deferred("_restore_new_sandbox_after_character_profile", opening_return_state)
		return
	if should_restore_roster and current_roster_dialog != null:
		current_roster_dialog.popup_centered(Vector2i(900, 560))
		current_roster_dialog.size = Vector2i(900, 560)
	if should_restore_focus:
		var focus_target: Control = null
		if return_focus != null and is_instance_valid(return_focus):
			focus_target = return_focus
		elif backpack != null and backpack.get_search_edit() != null:
			focus_target = backpack.get_search_edit()
		if focus_target != null:
			call_deferred("_restore_character_detail_return_focus", focus_target)


func _restore_character_detail_return_focus(control: Control) -> void:
	if (
		control != null
		and is_instance_valid(control)
		and control.is_inside_tree()
		and control.is_visible_in_tree()
		and control.focus_mode != Control.FOCUS_NONE
	):
		control.grab_focus()
	elif backpack != null and backpack.get_search_edit() != null:
		backpack.get_search_edit().grab_focus()


func _on_backpack_placed_character_focus_requested(character_id: String) -> void:
	if map_board != null and map_board.focus_character(character_id):
		_set_status("已定位 %s；可在地图上继续拖动" % _character_name(character_id))
	else:
		_set_status("暂时无法定位该人物；请先完成或取消当前路线调整")


func _append_drag_performance_status() -> void:
	var stats := map_board.get_last_drag_stats()
	if int(stats.get("frames", 0)) < 3:
		return
	if not bool(stats.get("sample_sufficient", false)):
		status_label.text += " · 性能样本不足，请持续拖动约2秒"
		return
	status_label.text += " · %.0f FPS · 帧 %.1f/%.1f ms · 慢帧 %.0f%% · 定位 %.2f ms" % [
		float(stats.get("average_fps", 0.0)),
		float(stats.get("p50_frame_ms", 0.0)),
		float(stats.get("p95_frame_ms", 0.0)),
		float(stats.get("slow_33ms_percent", 0.0)),
		float(stats.get("update_p95_ms", 0.0))
	]
	status_label.tooltip_text = "P99 %.1f ms · 峰值 %.1f ms · 严重慢帧 %.1f%%" % [
		float(stats.get("p99_frame_ms", 0.0)),
		float(stats.get("max_frame_ms", 0.0)),
		float(stats.get("severe_50ms_percent", 0.0))
	]


func _on_character_returned(character_id: String) -> void:
	if not placements.has(character_id):
		return
	var next := placements.duplicate(true)
	next.erase(character_id)
	var character_name := _character_name(character_id)
	_commit_placements(next, "收回%s" % character_name, "%s 已收回背包" % character_name)


func _on_home_pressed() -> void:
	map_board.focus_home("han_theater")
	_set_status("已归位到汉地战区")


func _on_save_pressed() -> void:
	if _save():
		_set_status("沙盘已保存")
	else:
		_set_status("保存失败，请查看运行日志")


func _sync_primary_recovery_menu_item() -> void:
	if sandbox_file_menu == null:
		return
	var popup := sandbox_file_menu.get_popup()
	var item_index := popup.get_item_index(13)
	if item_index >= 0:
		popup.set_item_disabled(item_index, not _primary_recovery_can_confirm())


func _primary_recovery_summary_text(candidate: Dictionary) -> String:
	var saved_time := _format_display_time(str(candidate.get("updated_at", "")))
	if saved_time.is_empty():
		saved_time = "时间未记录"
	return (
		"当前沙盘没有完整保存，但我们找到了一份保存前保留的沙盘。\n\n"
		+ "“%s” · %s · 人物 %d 张\n\n"
		+ "我们尚未替换或删除任何文件。选择恢复后，当前打不开的文件也会另外保留。"
	) % [
		str(candidate.get("title", "未命名沙盘")),
		saved_time,
		int(candidate.get("character_count", 0))
	]


func _open_primary_recovery_dialog() -> void:
	var previous_candidate: Dictionary = _primary_recovery_state.get("candidate", {}).duplicate(true)
	_primary_recovery_state = _inspect_primary_save_recovery()
	_apply_primary_recovery_write_guard()
	_sync_primary_recovery_menu_item()
	if not _primary_recovery_can_confirm():
		if str(_primary_recovery_state.get("status", "")) == "primary_valid":
			_show_message("当前沙盘已经可以继续", "当前沙盘已通过完整校验，不需要恢复上一份。")
		else:
			_show_message(
				"当前沙盘暂时打不开",
				"%s\n\n所有现有文件都保持不变。你也可以从“沙盘 → 从备份继续”选择自己保存过的备份。" % str(_primary_recovery_state.get("message", "没有找到可以直接恢复的上一份沙盘。"))
			)
		return
	var candidate: Dictionary = _primary_recovery_state.get("candidate", {})
	if not previous_candidate.is_empty() and str(previous_candidate.get("sha256", "")) != str(candidate.get("sha256", "")):
		_set_status("可恢复内容已经变化，请重新确认")
	primary_recovery_summary_label.text = _primary_recovery_summary_text(candidate)
	primary_recovery_dialog.popup_centered(Vector2i(560, 310))
	call_deferred("_focus_primary_recovery_cancel")


func _focus_primary_recovery_cancel() -> void:
	if primary_recovery_dialog != null and primary_recovery_dialog.visible:
		primary_recovery_dialog.get_cancel_button().grab_focus()


func _cancel_primary_recovery() -> void:
	_set_status("暂未恢复 · 现有文件均已保留")
	call_deferred("_focus_primary_recovery_return")


func _focus_primary_recovery_return() -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	await get_tree().process_frame
	if not is_inside_tree() or is_queued_for_deletion():
		return
	if (
		is_instance_valid(sandbox_file_menu)
		and sandbox_file_menu.is_inside_tree()
		and sandbox_file_menu.is_visible_in_tree()
		and sandbox_file_menu.focus_mode != Control.FOCUS_NONE
	):
		sandbox_file_menu.grab_focus()


func _show_primary_recovery_unavailable_notice() -> void:
	if not _save_writes_blocked or _primary_recovery_can_confirm():
		return
	_show_message(
		"当前沙盘暂时打不开",
		"%s\n\n原文件和保存过程中留下的文件都没有被修改。你可以从“沙盘 → 从备份继续”选择自己保存过的备份。" % str(_primary_recovery_state.get("message", "没有找到可以直接恢复的上一份沙盘。"))
	)


func _primary_recovery_stale_confirmation_message(fresh: Dictionary) -> String:
	var status := str(fresh.get("status", ""))
	if status == "recoverable" and not (fresh.get("candidate", {}) as Dictionary).is_empty():
		return "可恢复内容已经变化。所有文件都保持不变，请重新打开恢复选项检查。"
	if status == "primary_valid":
		if _primary_recovery_requires_reload:
			return _primary_recovery_reload_message()
		return "当前沙盘已经可以继续使用。所有文件都保持不变，不需要再恢复上一份沙盘。"
	var reason := str(fresh.get("message", "")).strip_edges()
	if reason.is_empty():
		reason = "原来的恢复候选已经不存在或无法继续读取。"
	return "%s\n\n所有现有文件都保持不变。当前没有可以直接恢复的上一份沙盘；你可以从“沙盘 → 从备份继续”选择自己保存过的备份。" % reason


func _focus_primary_recovery_return_after_message() -> void:
	if message_dialog != null and message_dialog.visible:
		return
	call_deferred("_focus_primary_recovery_return")


func _arm_primary_recovery_message_focus_return() -> void:
	if message_dialog == null:
		return
	var focus_return := Callable(self, "_focus_primary_recovery_return_after_message")
	if not message_dialog.visibility_changed.is_connected(focus_return):
		message_dialog.visibility_changed.connect(focus_return, CONNECT_ONE_SHOT)


func _primary_recovery_failure_follow_up(fresh: Dictionary) -> String:
	var status := str(fresh.get("status", ""))
	if status == "recoverable" and not (fresh.get("candidate", {}) as Dictionary).is_empty():
		return "恢复候选仍然保留。请重新打开恢复选项检查后重试；也可以从“沙盘 → 从备份继续”选择自己保存过的备份。"
	if status == "primary_valid":
		if _primary_recovery_requires_reload:
			return _primary_recovery_reload_message()
		return "当前沙盘现在已经通过完整校验，不需要再恢复上一份沙盘。"
	var reason := str(fresh.get("message", "")).strip_edges()
	if reason.is_empty():
		reason = "当前没有找到可以直接恢复的上一份沙盘。"
	return "%s\n\n你可以从“沙盘 → 从备份继续”选择自己保存过的备份。" % reason


func _primary_recovery_storage_failure_follow_up(fresh: Dictionary) -> String:
	var status := str(fresh.get("status", ""))
	if status == "recoverable" and not (fresh.get("candidate", {}) as Dictionary).is_empty():
		return "恢复候选仍然保留。请检查本机存储位置是否可写，再重新打开恢复选项重试；在原始文件成功另行保留前，不会覆盖当前主档。"
	var reason := str(fresh.get("message", "")).strip_edges()
	if reason.is_empty():
		reason = "当前没有找到可以直接恢复的上一份沙盘。"
	return "%s\n\n请检查本机存储位置是否可写后重新检查；当前主档仍保持不变。" % reason


func _primary_recovery_reload_message() -> String:
	return (
		"当前主路径现在是一份完整、但与本次确认不同的沙盘。程序没有把它当作恢复候选，也没有删除任何一边；"
		+ "本会话仍停止保存。关闭提示后请选择“沙盘 → 返回标题”，程序会不写盘地重新检查当前主档。"
	)


func _sync_primary_recovery_reload_gate() -> void:
	_primary_recovery_requires_reload = (
		_save_writes_blocked
		and str(_primary_recovery_state.get("status", "")) == "primary_valid"
	)
	if _primary_recovery_requires_reload:
		_save_write_block_reason = "当前主档在恢复期间被另一份完整文件替换；请返回标题重新检查。"


func _show_primary_recovery_failure_after_rescan(detail: String, storage_failure := false) -> void:
	_primary_recovery_state = _inspect_primary_save_recovery()
	_apply_primary_recovery_write_guard()
	_sync_primary_recovery_reload_gate()
	_sync_primary_recovery_menu_item()
	var detail_text := detail.strip_edges()
	var follow_up := (
		_primary_recovery_storage_failure_follow_up(_primary_recovery_state)
		if storage_failure
		else _primary_recovery_failure_follow_up(_primary_recovery_state)
	)
	_show_message("暂时无法恢复", "%s\n\n%s" % [detail_text, follow_up])
	_arm_primary_recovery_message_focus_return()


func _confirm_primary_recovery() -> void:
	var expected: Dictionary = _primary_recovery_state.get("candidate", {}).duplicate(true)
	var fresh := _inspect_primary_save_recovery()
	if (
		str(fresh.get("status", "")) != "recoverable"
		or str((fresh.get("candidate", {}) as Dictionary).get("path", "")) != str(expected.get("path", ""))
		or str((fresh.get("candidate", {}) as Dictionary).get("sha256", "")) != str(expected.get("sha256", ""))
	):
		_primary_recovery_state = fresh
		_apply_primary_recovery_write_guard()
		_sync_primary_recovery_reload_gate()
		_sync_primary_recovery_menu_item()
		_show_message("暂时无法恢复", _primary_recovery_stale_confirmation_message(fresh))
		_arm_primary_recovery_message_focus_return()
		return
	var candidate: Dictionary = fresh.get("candidate", {})
	var candidate_path := str(candidate.get("path", ""))
	var candidate_file := FileAccess.open(candidate_path, FileAccess.READ)
	if candidate_file == null:
		_show_primary_recovery_failure_after_rescan("上一份沙盘现在无法读取。所有文件都保持不变。")
		return
	var candidate_bytes := candidate_file.get_buffer(candidate_file.get_length())
	candidate_file = null
	if _sha256_hex(candidate_bytes) != str(candidate.get("sha256", "")):
		_show_primary_recovery_failure_after_rescan("上一份沙盘在确认期间发生变化。所有文件都保持不变。")
		return

	var absolute_primary := ProjectSettings.globalize_path(save_path)
	var raw_backup_path := ""
	var primary: Dictionary = fresh.get("primary", {})
	var expected_primary_exists := str(primary.get("status", "missing")) != "missing"
	var expected_primary_sha256 := str(primary.get("sha256", ""))
	if FileAccess.file_exists(absolute_primary):
		var backup_result := _create_raw_migration_backup(
			save_path,
			int(primary.get("source_save_version", 0)),
			0,
			"recovery_primary"
		)
		if not bool(backup_result.get("ok", false)):
			_show_primary_recovery_failure_after_rescan(
				"当前打不开的文件无法先另行保留，因此本次没有替换任何内容。\n\n%s" % str(backup_result.get("message", "")),
				true
			)
			return
		raw_backup_path = str(backup_result.get("path", ""))
		var backup_sha256 := str(backup_result.get("sha256", ""))
		if not expected_primary_exists or (
			not expected_primary_sha256.is_empty()
			and backup_sha256 != expected_primary_sha256
		):
			_show_primary_recovery_failure_after_rescan(
				"当前主档在确认与原始字节备份之间发生变化，本次没有覆盖；刚建立的原始备份继续保留。"
			)
			return
		expected_primary_sha256 = backup_sha256

	var precommit := _validate_primary_recovery_commit_preconditions(
		candidate_path,
		str(candidate.get("sha256", "")),
		expected_primary_exists,
		expected_primary_sha256
	)
	if not bool(precommit.get("ok", false)):
		_show_primary_recovery_failure_after_rescan(
			"%s 所有现有文件和已建立的原始备份都保持不变。" % str(precommit.get("message", "恢复提交前的文件已经变化。"))
		)
		return

	var expected_target := {"exists": expected_primary_exists}
	if expected_primary_exists:
		expected_target["sha256"] = expected_primary_sha256
	var restore_result := _write_exact_bytes_atomic(save_path, candidate_bytes, true, true, expected_target)
	if not bool(restore_result.get("ok", false)):
		_show_primary_recovery_failure_after_rescan("所有恢复候选都保持不变，本次没有完成替换。\n\n%s" % str(restore_result.get("message", "")))
		return
	var verify := _read_sandbox_transfer_file(save_path, false)
	if not bool(verify.get("ok", false)) or str(verify.get("source_format", "")) != "raw_save":
		_save_writes_blocked = true
		_save_write_block_reason = "恢复后的当前沙盘没有通过完整复核。"
		_show_primary_recovery_failure_after_rescan("恢复后的沙盘没有通过完整复核，现有保护副本仍然保留。")
		return

	_save_writes_blocked = false
	_save_write_block_reason = ""
	_primary_recovery_requires_reload = false
	_load_save()
	_primary_recovery_state = _inspect_primary_save_recovery()
	_sync_primary_recovery_menu_item()
	_refresh_views()
	_refresh_sandbox_identity_view()
	_update_history_buttons()
	if not loaded_camera.is_empty() and map_board != null:
		map_board.set_camera_state(loaded_camera)
	if _save_writes_blocked:
		_show_message("上一份沙盘已保留", "沙盘已经恢复，但旧版更新尚未完整写入；当前仍保持停止保存状态。")
		return
	_set_status("已恢复上一份沙盘 · 保护副本仍然保留")
	var backup_note := "\n当前打不开的文件也已另外保留。" if not raw_backup_path.is_empty() else ""
	_show_message(
		"已恢复上一份沙盘",
		"已继续使用 %s 保存的沙盘。原来的恢复候选没有删除。%s" % [
			_format_display_time(str(candidate.get("updated_at", ""))),
			backup_note
		]
	)


func _open_simulation_session_start_dialog() -> void:
	if simulation_session_start_dialog == null or map_board == null:
		return
	if not active_simulation_session.is_empty():
		_set_status("已有一段推演正在进行，请先结束复盘或取消助手")
		return
	pending_simulation_session_participants = _normalized_placed_character_ids(map_board.get_selected_character_ids())
	simulation_session_name_input.text = ""
	simulation_session_time_input.text = ""
	simulation_session_type_select.select(0)
	simulation_session_initial_action_select.select(0)
	var participant_names: Array[String] = []
	for character_id in pending_simulation_session_participants:
		participant_names.append(_character_name(character_id))
	if participant_names.is_empty():
		simulation_session_participants_label.text = "未选择人物：按全局局面推演。若要固定参与人物，请取消后在地图上单选或 Shift 多选。"
		simulation_session_initial_action_select.disabled = true
	else:
		simulation_session_participants_label.text = "%d 人：%s" % [participant_names.size(), "、".join(participant_names)]
		simulation_session_initial_action_select.disabled = false
	_on_simulation_session_type_selected(simulation_session_type_select.selected)
	simulation_session_start_dialog.popup_centered(Vector2i(640, 500))
	simulation_session_name_input.call_deferred("grab_focus")


func _on_simulation_session_type_selected(_index: int) -> void:
	if simulation_session_type_select == null or simulation_session_siege_setup_panel == null:
		return
	var siege_mode := _selected_option_value(simulation_session_type_select, "advance") == "siege"
	simulation_session_siege_setup_panel.visible = siege_mode
	simulation_session_initial_action_label.visible = not siege_mode
	simulation_session_initial_action_select.visible = not siege_mode
	if siege_mode:
		simulation_session_participants_label.text = "当前地图选择作为攻方初始名单；请在下方逐人确认攻守，结束时由你裁定胜负。"
		_populate_simulation_siege_target_select()
		_rebuild_simulation_siege_roster(true)
		simulation_session_start_dialog.min_size = Vector2i(780, 700)
		if simulation_session_start_dialog.visible:
			simulation_session_start_dialog.popup_centered(Vector2i(780, 700))
	else:
		var participant_names: Array[String] = []
		for character_id in pending_simulation_session_participants:
			participant_names.append(_character_name(character_id))
		if participant_names.is_empty():
			simulation_session_participants_label.text = "未选择人物：按全局局面推演。若要固定参与人物，请取消后在地图上单选或 Shift 多选。"
			simulation_session_initial_action_select.disabled = true
		else:
			simulation_session_participants_label.text = "%d 人：%s" % [participant_names.size(), "、".join(participant_names)]
			simulation_session_initial_action_select.disabled = false
		simulation_session_start_dialog.min_size = Vector2i(640, 500)
		if simulation_session_start_dialog.visible:
			simulation_session_start_dialog.popup_centered(Vector2i(640, 500))


func _valid_simulation_siege_city_ids() -> Array[String]:
	var result: Array[String] = []
	for place_value in places:
		if not (place_value is Dictionary):
			continue
		var place: Dictionary = place_value
		if str(place.get("type", "city")) not in ["city", "capital"]:
			continue
		var place_id := str(place.get("id", "")).strip_edges()
		if not place_id.is_empty():
			result.append(place_id)
	return result


func _populate_simulation_siege_target_select() -> void:
	if simulation_session_siege_target_select == null:
		return
	var previous_target := _selected_option_value(simulation_session_siege_target_select, "")
	var valid_city_ids := _valid_simulation_siege_city_ids()
	var preferred_target := previous_target
	if preferred_target not in valid_city_ids:
		preferred_target = current_place_detail_id if current_place_detail_id in valid_city_ids else ""
	if preferred_target.is_empty():
		for character_id_value in placements:
			var character_id := str(character_id_value)
			if character_id in pending_simulation_session_participants:
				continue
			var placement_value: Variant = placements.get(character_id, {})
			var placement: Dictionary = placement_value if placement_value is Dictionary else {}
			var place_id := str(placement.get("place_id", ""))
			if place_id in valid_city_ids:
				preferred_target = place_id
				break
	if preferred_target.is_empty() and not valid_city_ids.is_empty():
		preferred_target = valid_city_ids[0]
	simulation_session_siege_target_select.clear()
	var selected_index := 0
	for place_id in valid_city_ids:
		var place := _find_place(place_id)
		simulation_session_siege_target_select.add_item(str(place.get("name", place_id)))
		var option_index := simulation_session_siege_target_select.item_count - 1
		simulation_session_siege_target_select.set_item_metadata(option_index, place_id)
		if place_id == preferred_target:
			selected_index = option_index
	if simulation_session_siege_target_select.item_count > 0:
		simulation_session_siege_target_select.select(selected_index)


func _on_simulation_session_siege_target_selected(_index: int) -> void:
	_rebuild_simulation_siege_roster(true)


func _clear_control_children(container: Control) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _rebuild_simulation_siege_roster(reset_defenders := false) -> void:
	if simulation_session_siege_roster == null:
		return
	var target_place_id := _selected_option_value(simulation_session_siege_target_select, "")
	var preserved_attackers: Array[String] = []
	if reset_defenders:
		for character_id_value in simulation_session_siege_role_selects:
			var existing_character_id := str(character_id_value)
			var existing_select := simulation_session_siege_role_selects.get(existing_character_id) as OptionButton
			if existing_select != null and _selected_option_value(existing_select, "") == PlayerAdjudicatedSiegePolicyScript.SIDE_ATTACKER:
				preserved_attackers.append(existing_character_id)
		if preserved_attackers.is_empty():
			preserved_attackers = pending_simulation_session_participants.duplicate()
	_clear_control_children(simulation_session_siege_roster)
	simulation_session_siege_role_selects.clear()
	var placed_ids: Array[String] = _normalized_placed_character_ids(placements.keys())
	placed_ids.sort_custom(func(first: String, second: String) -> bool: return _character_name(first) < _character_name(second))
	var assignment_map := _scenario_assignment_map(scenario_state)
	for character_id in placed_ids:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		simulation_session_siege_roster.add_child(row)
		var placement: Dictionary = placements.get(character_id, {})
		var place_name := _simulation_place_name(str(placement.get("place_id", "")))
		var faction_name := _simulation_faction_name(scenario_state, str(assignment_map.get(character_id, "")))
		var label := Label.new()
		label.text = "%s · %s · %s" % [_character_name(character_id), place_name, faction_name]
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
		row.add_child(label)
		var role_select := OptionButton.new()
		role_select.custom_minimum_size = Vector2(142, 34)
		for option in [
			{"label": "不参战", "value": ""},
			{"label": "进攻方", "value": PlayerAdjudicatedSiegePolicyScript.SIDE_ATTACKER},
			{"label": "防守方", "value": PlayerAdjudicatedSiegePolicyScript.SIDE_DEFENDER},
		]:
			role_select.add_item(str(option["label"]))
			role_select.set_item_metadata(role_select.item_count - 1, str(option["value"]))
		var role := ""
		if character_id in preserved_attackers:
			role = PlayerAdjudicatedSiegePolicyScript.SIDE_ATTACKER
		elif str(placement.get("place_id", "")) == target_place_id:
			role = PlayerAdjudicatedSiegePolicyScript.SIDE_DEFENDER
		_select_option_by_value(role_select, role)
		role_select.item_selected.connect(_on_simulation_siege_role_selected.bind(character_id))
		row.add_child(role_select)
		simulation_session_siege_role_selects[character_id] = role_select
	_refresh_simulation_siege_roster_summary()


func _on_simulation_siege_role_selected(_index: int, _character_id: String) -> void:
	_refresh_simulation_siege_roster_summary()


func _refresh_simulation_siege_roster_summary() -> void:
	var attackers: Array[String] = []
	var defenders: Array[String] = []
	for character_id_value in simulation_session_siege_role_selects:
		var character_id := str(character_id_value)
		var role_select := simulation_session_siege_role_selects.get(character_id) as OptionButton
		var role := _selected_option_value(role_select, "")
		if role == PlayerAdjudicatedSiegePolicyScript.SIDE_ATTACKER:
			attackers.append(character_id)
		elif role == PlayerAdjudicatedSiegePolicyScript.SIDE_DEFENDER:
			defenders.append(character_id)
	var target_name := _simulation_place_name(_selected_option_value(simulation_session_siege_target_select, ""))
	simulation_session_participants_label.text = "%s · 攻方 %d 人 · 守方 %d 人" % [target_name, attackers.size(), defenders.size()]


func _select_option_by_value(option: OptionButton, value: String) -> bool:
	if option == null:
		return false
	for index in range(option.item_count):
		if str(option.get_item_metadata(index)) == value:
			option.select(index)
			return true
	return false


func _simulation_siege_start_contract() -> Dictionary:
	var attackers: Array = []
	var defenders: Array = []
	for character_id_value in simulation_session_siege_role_selects:
		var character_id := str(character_id_value)
		var role_select := simulation_session_siege_role_selects.get(character_id) as OptionButton
		var role := _selected_option_value(role_select, "")
		if role == PlayerAdjudicatedSiegePolicyScript.SIDE_ATTACKER:
			attackers.append(character_id)
		elif role == PlayerAdjudicatedSiegePolicyScript.SIDE_DEFENDER:
			defenders.append(character_id)
	return PlayerAdjudicatedSiegePolicyScript.validate_start(
		_selected_option_value(simulation_session_siege_target_select, ""),
		attackers,
		defenders,
		placements.keys(),
		_valid_simulation_siege_city_ids()
	)


func _confirm_start_simulation_session() -> void:
	var session_name := _sanitize_single_line(simulation_session_name_input.text, MAX_SIMULATION_SESSION_NAME_LENGTH, "")
	if session_name.is_empty():
		_set_status("请先填写本次推演名称")
		call_deferred("_return_to_simulation_session_start_dialog")
		return
	if not active_simulation_session.is_empty():
		_set_status("已有一段推演正在进行")
		return
	var session_type := _selected_option_value(simulation_session_type_select, "advance")
	var time_label := _sanitize_single_line(simulation_session_time_input.text, MAX_SIMULATION_SESSION_TIME_LENGTH, "")
	var participants := _normalized_placed_character_ids(pending_simulation_session_participants)
	var siege_contract: Dictionary = {}
	if session_type == "siege":
		siege_contract = _simulation_siege_start_contract()
		if not bool(siege_contract.get("ok", false)):
			_set_status(str(siege_contract.get("message", "攻守名单还不完整。")))
			call_deferred("_return_to_simulation_session_start_dialog")
			return
		participants = (siege_contract.get("participant_ids", []) as Array).duplicate()
	var baseline := _capture_simulation_session_state()
	var snapshot_name := _simulation_session_snapshot_name("攻城前" if session_type == "siege" else "推演前", session_name)
	var participant_text := "全局局面" if participants.is_empty() else "、".join(participants.map(func(character_id: String) -> String: return _character_name(character_id)))
	var snapshot_note := "“%s”开始前自动留存；参与：%s。" % [session_name, participant_text]
	if session_type == "siege":
		snapshot_note = "“%s”攻城开始前自动留存；目标：%s；攻方：%s；守方：%s。" % [
			session_name,
			_simulation_place_name(str(siege_contract.get("target_place_id", ""))),
			_simulation_character_names(siege_contract.get("attacker_ids", [])),
			_simulation_character_names(siege_contract.get("defender_ids", [])),
		]
	var snapshot_result := _create_named_snapshot(snapshot_name, snapshot_note)
	if not bool(snapshot_result.get("ok", false)):
		_show_message("暂时不能开始推演", "%s\n\n当前地图没有变化。" % str(snapshot_result.get("message", "起点快照没有建立。")))
		return
	var start_snapshot: Dictionary = snapshot_result.get("snapshot", {}).duplicate(true)
	active_simulation_session = {
		"id": _new_record_id("session"),
		"name": session_name,
		"session_type": session_type,
		"time_label": time_label,
		"participant_ids": participants.duplicate(),
		"baseline": baseline,
		"start_snapshot_id": str(start_snapshot.get("snapshot_id", "")),
		"result_chronicle_id": "",
		"end_snapshot_id": "",
		"started_at": Time.get_datetime_string_from_system(false, true),
	}
	if session_type == "siege":
		active_simulation_session["target_place_id"] = str(siege_contract.get("target_place_id", ""))
		active_simulation_session["attacker_ids"] = (siege_contract.get("attacker_ids", []) as Array).duplicate()
		active_simulation_session["defender_ids"] = (siege_contract.get("defender_ids", []) as Array).duplicate()
		active_simulation_session["resolution_committed"] = false
	_refresh_simulation_session_bar()
	_refresh_sandbox_identity_view()
	var requested_action := _selected_option_value(simulation_session_initial_action_select, "keep")
	var action_applied := false
	if session_type != "siege" and not participants.is_empty() and requested_action != "keep" and CharacterActionPolicyScript.is_valid_action(requested_action):
		var next_actions := character_actions.duplicate(true)
		for character_id in participants:
			if requested_action == CHARACTER_ACTION_STANDBY:
				next_actions.erase(character_id)
			else:
				next_actions[character_id] = requested_action
		action_applied = _commit_character_actions(
			next_actions,
			"推演开始：统一行动",
			"本次推演已开始，起点快照已建立 · 统一行动已应用 · 可撤销"
		)
	if not action_applied:
		_set_status("本次推演已开始 · 起点快照“%s”已建立" % snapshot_name)
	pending_simulation_session_participants.clear()
	simulation_session_siege_role_selects.clear()


func _return_to_simulation_session_start_dialog() -> void:
	if simulation_session_start_dialog != null:
		var popup_size := Vector2i(780, 700) if _selected_option_value(simulation_session_type_select, "advance") == "siege" else Vector2i(640, 500)
		simulation_session_start_dialog.popup_centered(popup_size)
		simulation_session_name_input.grab_focus()


func _selected_option_value(option: OptionButton, fallback: String) -> String:
	if option == null or option.selected < 0 or option.selected >= option.item_count:
		return fallback
	return str(option.get_item_metadata(option.selected))


func _capture_simulation_session_state() -> Dictionary:
	return {
		"placements": placements.duplicate(true),
		"annotations": annotations.duplicate(true),
		"scenario_state": scenario_state.duplicate(true),
		"player_strokes": player_strokes.duplicate(true),
		"character_actions": character_actions.duplicate(true),
		"character_troops": character_troops.duplicate(true),
	}


func _simulation_session_snapshot_name(prefix: String, session_name: String) -> String:
	return _sanitize_single_line("%s·%s" % [prefix, session_name], MAX_SNAPSHOT_NAME_LENGTH, prefix)


func _simulation_session_type_label(session_type: String) -> String:
	match session_type:
		"siege":
			return "攻城（玩家裁定）"
		"reinforcement":
			return "援军／会合"
		"retreat":
			return "撤退／转移"
		"plan":
			return "谋划／其他"
		_:
			return "进军／交战"


func _refresh_simulation_session_bar() -> void:
	if simulation_session_bar == null:
		return
	var active := not active_simulation_session.is_empty()
	simulation_session_bar.visible = active
	var session_name := str(active_simulation_session.get("name", "未命名推演")) if active else ""
	if map_board != null:
		map_board.set_simulation_session_active(active, session_name)
	if not active:
		return
	var participant_ids: Array = active_simulation_session.get("participant_ids", [])
	var participants := "全局局面"
	if not participant_ids.is_empty():
		var names: Array[String] = []
		for character_id_value in participant_ids:
			names.append(_character_name(str(character_id_value)))
		participants = "、".join(names)
	simulation_session_title_label.text = "正在推演 · %s" % session_name
	var time_label := str(active_simulation_session.get("time_label", ""))
	if str(active_simulation_session.get("session_type", "advance")) == "siege":
		var attacker_count := (active_simulation_session.get("attacker_ids", []) as Array).size()
		var defender_count := (active_simulation_session.get("defender_ids", []) as Array).size()
		simulation_session_meta_label.text = "攻城 · %s · 攻 %d／守 %d%s" % [
			_simulation_place_name(str(active_simulation_session.get("target_place_id", ""))),
			attacker_count,
			defender_count,
			" · %s" % time_label if not time_label.is_empty() else "",
		]
	else:
		simulation_session_meta_label.text = "%s · %s%s" % [
			_simulation_session_type_label(str(active_simulation_session.get("session_type", "advance"))),
			participants,
			" · %s" % time_label if not time_label.is_empty() else "",
		]


func _simulation_session_tool_is_busy() -> bool:
	return (
		city_ownership_tool_active
		or (map_board != null and (
			map_board.is_annotation_tool_active()
			or map_board.is_player_stroke_tool_active()
			or map_board.is_player_stroke_point_edit_active()
		))
	)


func _open_active_session_route() -> void:
	if active_simulation_session.is_empty():
		return
	if _simulation_session_tool_is_busy():
		_set_status("请先完成或取消当前地图绘制／编辑")
		return
	_open_player_stroke_dialog()
	_pending_player_stroke_type = str(active_simulation_session.get("session_type", "advance"))
	if _pending_player_stroke_type == "siege":
		_pending_player_stroke_type = "advance"
	_pending_player_stroke_label = _sanitize_single_line(str(active_simulation_session.get("name", "")), MAX_PLAYER_STROKE_LABEL_LENGTH, "")
	player_stroke_type_select.select(_player_stroke_type_index(_pending_player_stroke_type))
	player_stroke_label_input.text = _pending_player_stroke_label


func _open_simulation_session_end_dialog() -> void:
	if active_simulation_session.is_empty() or simulation_session_end_dialog == null:
		return
	if _simulation_session_tool_is_busy():
		_set_status("请先完成或取消当前地图绘制／编辑，再结束推演")
		return
	var diff := _current_simulation_session_diff()
	simulation_session_end_summary.text = _simulation_diff_display_text(diff)
	simulation_session_end_title_input.text = "%s · 复盘" % str(active_simulation_session.get("name", "未命名推演"))
	simulation_session_end_note_input.text = ""
	simulation_session_end_snapshot_check.button_pressed = str(active_simulation_session.get("end_snapshot_id", "")).is_empty()
	var siege_mode := str(active_simulation_session.get("session_type", "advance")) == "siege"
	simulation_session_siege_resolution_panel.visible = siege_mode
	simulation_session_end_summary.custom_minimum_size = Vector2(0, 132 if siege_mode else 210)
	simulation_session_end_dialog.ok_button_text = "确认裁定并写入" if siege_mode else "写入复盘"
	simulation_session_end_snapshot_check.text = "同时保存“攻城后”命名快照" if siege_mode else "同时保存“推演后”命名快照"
	if siege_mode:
		_populate_simulation_siege_resolution_controls()
		simulation_session_end_dialog.min_size = Vector2i(800, 720)
		simulation_session_end_dialog.popup_centered(Vector2i(800, 720))
	else:
		simulation_session_end_dialog.min_size = Vector2i(700, 590)
		simulation_session_end_dialog.popup_centered(Vector2i(700, 590))
	simulation_session_end_title_input.call_deferred("grab_focus")


func _populate_simulation_siege_resolution_controls() -> void:
	if simulation_session_siege_outcome_select == null:
		return
	simulation_session_siege_outcome_select.select(0)
	simulation_session_siege_handling_select.select(0)
	simulation_session_siege_owner_select.clear()
	simulation_session_siege_owner_select.add_item("保持当前归属")
	simulation_session_siege_owner_select.set_item_metadata(0, "keep")
	simulation_session_siege_owner_select.add_item("设为无归属")
	simulation_session_siege_owner_select.set_item_metadata(1, "clear")
	for faction_value in scenario_state.get("factions", []):
		if not (faction_value is Dictionary):
			continue
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", ""))
		if faction_id.is_empty():
			continue
		simulation_session_siege_owner_select.add_item("改为：%s" % str(faction.get("name", faction_id)))
		simulation_session_siege_owner_select.set_item_metadata(simulation_session_siege_owner_select.item_count - 1, "owner:%s" % faction_id)
	_on_simulation_session_siege_resolution_changed(0)


func _on_simulation_session_siege_resolution_changed(_index: int) -> void:
	if simulation_session_siege_outcome_select == null or active_simulation_session.is_empty():
		return
	var outcome := _selected_option_value(simulation_session_siege_outcome_select, PlayerAdjudicatedSiegePolicyScript.OUTCOME_ATTACKER_WIN)
	var candidates := PlayerAdjudicatedSiegePolicyScript.defeated_candidates(
		outcome,
		active_simulation_session.get("attacker_ids", []),
		active_simulation_session.get("defender_ids", []),
		placements
	)
	var has_defeated_side := not candidates.is_empty()
	for option_index in [1, 2]:
		simulation_session_siege_handling_select.set_item_disabled(option_index, not has_defeated_side)
	if not has_defeated_side and _selected_option_value(simulation_session_siege_handling_select, "keep") in ["return_all", "return_selected"]:
		simulation_session_siege_handling_select.select(0)
	var handling := _selected_option_value(simulation_session_siege_handling_select, "keep")
	simulation_session_siege_return_panel.visible = handling == PlayerAdjudicatedSiegePolicyScript.HANDLING_RETURN_SELECTED and has_defeated_side
	_rebuild_simulation_siege_return_checks(candidates)


func _rebuild_simulation_siege_return_checks(candidate_ids: Array) -> void:
	if simulation_session_siege_return_list == null:
		return
	var previous_checked: Dictionary = {}
	for character_id_value in simulation_session_siege_return_checks:
		var character_id := str(character_id_value)
		var previous_check := simulation_session_siege_return_checks.get(character_id) as CheckBox
		if previous_check != null and previous_check.button_pressed:
			previous_checked[character_id] = true
	_clear_control_children(simulation_session_siege_return_list)
	simulation_session_siege_return_checks.clear()
	for character_id_value in candidate_ids:
		var character_id := str(character_id_value)
		var check := CheckBox.new()
		check.text = "%s · 兵 %s" % [_character_name(character_id), _format_troop_count_exact(_effective_character_troop_count(character_id))]
		check.button_pressed = bool(previous_checked.get(character_id, false))
		check.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
		simulation_session_siege_return_list.add_child(check)
		simulation_session_siege_return_checks[character_id] = check


func _selected_simulation_siege_return_ids() -> Array[String]:
	var result: Array[String] = []
	for character_id_value in simulation_session_siege_return_checks:
		var character_id := str(character_id_value)
		var check := simulation_session_siege_return_checks.get(character_id) as CheckBox
		if check != null and check.button_pressed:
			result.append(character_id)
	return result


func _current_simulation_session_diff() -> Dictionary:
	if active_simulation_session.is_empty():
		return SimulationSessionDiffScript.compare({}, {})
	var baseline_value: Variant = active_simulation_session.get("baseline", {})
	var baseline: Dictionary = baseline_value if baseline_value is Dictionary else {}
	return SimulationSessionDiffScript.compare(baseline, _capture_simulation_session_state())


func _simulation_diff_display_text(diff: Dictionary) -> String:
	var lines := _simulation_diff_lines(diff)
	if lines.is_empty():
		return "尚未检测到人物、兵力、行动、分组、城池、标记或路线的结构变化。你仍可写下这次推演得到的判断。"
	return "\n".join(lines)


func _simulation_diff_lines(diff: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	for value in diff.get("placements_added", []):
		var record: Dictionary = value
		lines.append("摆出：%s → %s" % [_character_name(str(record.get("character_id", ""))), _simulation_place_name(str(record.get("place_id", "")))])
	for value in diff.get("placements_removed", []):
		var record: Dictionary = value
		lines.append("收回：%s（原在%s）" % [_character_name(str(record.get("character_id", ""))), _simulation_place_name(str(record.get("place_id", "")))])
	for value in diff.get("placements_moved", []):
		var record: Dictionary = value
		lines.append("移动：%s · %s → %s" % [
			_character_name(str(record.get("character_id", ""))),
			_simulation_place_name(str(record.get("from_place_id", ""))),
			_simulation_place_name(str(record.get("to_place_id", ""))),
		])
	for value in diff.get("actions_changed", []):
		var record: Dictionary = value
		lines.append("行动：%s · %s → %s" % [
			_character_name(str(record.get("character_id", ""))),
			_character_action_label(str(record.get("from", CHARACTER_ACTION_STANDBY))),
			_character_action_label(str(record.get("to", CHARACTER_ACTION_STANDBY))),
		])
	for value in diff.get("troops_changed", []):
		var record: Dictionary = value
		lines.append("兵力：%s · %s → %s" % [
			_character_name(str(record.get("character_id", ""))),
			_format_troop_count_exact(int(record.get("from", CHARACTER_TROOP_DEFAULT))),
			_format_troop_count_exact(int(record.get("to", CHARACTER_TROOP_DEFAULT))),
		])
	_append_simulation_count_line(lines, diff, "factions", "势力")
	for value in diff.get("assignments_changed", []):
		var record: Dictionary = value
		lines.append("分组：%s · %s → %s" % [
			_character_name(str(record.get("character_id", ""))),
			_simulation_faction_name(_simulation_baseline_scenario(), str(record.get("from", ""))),
			_simulation_faction_name(scenario_state, str(record.get("to", ""))),
		])
	for value in diff.get("city_ownership_changed", []):
		var record: Dictionary = value
		lines.append("城池：%s · %s → %s" % [
			_simulation_place_name(str(record.get("place_id", ""))),
			_simulation_faction_name(_simulation_baseline_scenario(), str(record.get("from", ""))),
			_simulation_faction_name(scenario_state, str(record.get("to", ""))),
		])
	_append_simulation_count_line(lines, diff, "annotations", "标记")
	_append_simulation_count_line(lines, diff, "strokes", "推演线")
	return lines


func _append_simulation_count_line(lines: Array[String], diff: Dictionary, prefix: String, label: String) -> void:
	var added := (diff.get("%s_added" % prefix, []) as Array).size()
	var removed := (diff.get("%s_removed" % prefix, []) as Array).size()
	var changed := (diff.get("%s_changed" % prefix, []) as Array).size()
	if added + removed + changed > 0:
		lines.append("%s：新增 %d · 删除 %d · 修改 %d" % [label, added, removed, changed])


func _simulation_baseline_scenario() -> Dictionary:
	var baseline_value: Variant = active_simulation_session.get("baseline", {})
	if not baseline_value is Dictionary:
		return {}
	var scenario_value: Variant = (baseline_value as Dictionary).get("scenario_state", {})
	return (scenario_value as Dictionary) if scenario_value is Dictionary else {}


func _simulation_place_name(place_id: String) -> String:
	if place_id.is_empty():
		return "自由位置"
	var place := _find_place(place_id)
	return str(place.get("name", place_id)) if not place.is_empty() else place_id


func _simulation_faction_name(state: Dictionary, faction_id: String) -> String:
	if faction_id.is_empty():
		return "未分组"
	for faction_value in state.get("factions", []):
		if faction_value is Dictionary and str((faction_value as Dictionary).get("id", "")) == faction_id:
			return str((faction_value as Dictionary).get("name", "未命名势力"))
	return faction_id


func _confirm_end_simulation_session() -> void:
	if active_simulation_session.is_empty():
		return
	if str(active_simulation_session.get("session_type", "advance")) == "siege":
		_confirm_end_player_adjudicated_siege()
		return
	var title_text := _sanitize_single_line(simulation_session_end_title_input.text, MAX_CHRONICLE_TITLE_LENGTH, "")
	if title_text.is_empty():
		_set_status("请先填写复盘纪事标题")
		call_deferred("_open_simulation_session_end_dialog")
		return
	var wants_snapshot := simulation_session_end_snapshot_check.button_pressed
	if wants_snapshot and named_snapshots.size() >= SNAPSHOT_LIMIT and str(active_simulation_session.get("end_snapshot_id", "")).is_empty():
		_show_message("终点快照暂时无法建立", "命名快照已达到 %d 个上限。请先删除旧快照，或取消勾选终点快照后完成复盘。" % SNAPSHOT_LIMIT)
		return
	if wants_snapshot and _snapshot_writes_blocked:
		_show_message("终点快照暂时无法建立", _snapshot_write_block_reason)
		return
	var chronicle_id := str(active_simulation_session.get("result_chronicle_id", ""))
	if not chronicle_id.is_empty() and _find_chronicle_entry(chronicle_id).is_empty():
		# 终点快照失败后玩家仍可撤销刚写入的纪事；再次提交时应重新建立，
		# 不能因会话内缓存了旧 ID 就生成一份没有对应纪事的终点快照。
		chronicle_id = ""
		active_simulation_session["result_chronicle_id"] = ""
	if chronicle_id.is_empty():
		if chronicle_entries.size() >= CHRONICLE_ENTRY_LIMIT:
			_show_message("暂时不能写入复盘", "玩家纪事已达到 %d 则上限，请先删除不再需要的纪事。" % CHRONICLE_ENTRY_LIMIT)
			return
		var diff := _current_simulation_session_diff()
		var auto_body := _simulation_diff_plain_text(diff)
		var player_note := _sanitize_multiline(simulation_session_end_note_input.text, MAX_SIMULATION_SESSION_NOTE_LENGTH)
		var body := auto_body
		if not player_note.is_empty():
			body += "\n\n我的复盘：%s" % player_note
		body = _sanitize_multiline(body, MAX_CHRONICLE_BODY_LENGTH)
		chronicle_id = _new_record_id("chron")
		var now := Time.get_datetime_string_from_system(false, true)
		var next_entries: Array[Dictionary] = chronicle_entries.duplicate(true)
		next_entries.append({
			"id": chronicle_id,
			"entry_type": _simulation_session_chronicle_type(str(active_simulation_session.get("session_type", "advance"))),
			"title": title_text,
			"time_label": str(active_simulation_session.get("time_label", "")),
			"body": body,
			"created_at": now,
			"updated_at": now,
		})
		if not _commit_chronicle_entries(next_entries, "结束推演并写入复盘", "本次推演复盘已写入玩家纪事 · 可撤销"):
			_show_message("复盘没有写入", "当前沙盘无法安全保存；本次推演仍保持进行中，可以稍后重试。")
			return
		active_simulation_session["result_chronicle_id"] = chronicle_id

	if wants_snapshot and str(active_simulation_session.get("end_snapshot_id", "")).is_empty():
		var session_name := str(active_simulation_session.get("name", "未命名推演"))
		var snapshot_result := _create_named_snapshot(
			_simulation_session_snapshot_name("推演后", session_name),
			"“%s”结束后的局面；对应玩家纪事“%s”。" % [session_name, title_text]
		)
		if not bool(snapshot_result.get("ok", false)):
			_show_message(
				"复盘已写入，终点快照未建立",
				"玩家纪事已经安全保存且不会重复写入。请检查快照仓库后再次点击“结束并复盘”，或取消勾选终点快照完成本次流程。\n\n%s" % str(snapshot_result.get("message", ""))
			)
			return
		var snapshot: Dictionary = snapshot_result.get("snapshot", {})
		active_simulation_session["end_snapshot_id"] = str(snapshot.get("snapshot_id", ""))
		_refresh_sandbox_identity_view()
	_finish_simulation_session("本次推演已复盘 · 纪事与起终点快照均已保留" if wants_snapshot else "本次推演已复盘 · 纪事与起点快照已保留")


func _confirm_end_player_adjudicated_siege() -> void:
	var title_text := _sanitize_single_line(simulation_session_end_title_input.text, MAX_CHRONICLE_TITLE_LENGTH, "")
	if title_text.is_empty():
		_set_status("请先填写攻城复盘标题")
		call_deferred("_open_simulation_session_end_dialog")
		return
	var wants_snapshot := simulation_session_end_snapshot_check.button_pressed
	if wants_snapshot and named_snapshots.size() >= SNAPSHOT_LIMIT and str(active_simulation_session.get("end_snapshot_id", "")).is_empty():
		_show_message("终点快照暂时无法建立", "命名快照已达到 %d 个上限。请先删除旧快照，或取消勾选终点快照后完成裁定。" % SNAPSHOT_LIMIT)
		return
	if wants_snapshot and _snapshot_writes_blocked:
		_show_message("终点快照暂时无法建立", _snapshot_write_block_reason)
		return

	var chronicle_id := str(active_simulation_session.get("result_chronicle_id", ""))
	if not chronicle_id.is_empty() and _find_chronicle_entry(chronicle_id).is_empty():
		chronicle_id = ""
		active_simulation_session["result_chronicle_id"] = ""
		active_simulation_session["resolution_committed"] = false
	if chronicle_id.is_empty():
		if chronicle_entries.size() >= CHRONICLE_ENTRY_LIMIT:
			_show_message("暂时不能写入攻城复盘", "玩家纪事已达到 %d 则上限，请先删除不再需要的纪事。" % CHRONICLE_ENTRY_LIMIT)
			return
		var outcome := _selected_option_value(simulation_session_siege_outcome_select, PlayerAdjudicatedSiegePolicyScript.OUTCOME_ATTACKER_WIN)
		var handling := _selected_option_value(simulation_session_siege_handling_select, PlayerAdjudicatedSiegePolicyScript.HANDLING_KEEP)
		if handling == PlayerAdjudicatedSiegePolicyScript.HANDLING_DEFER:
			_set_status("本次裁定尚未写入 · 可先在地图上手动安排，再点“结束并复盘”")
			return
		var return_result := PlayerAdjudicatedSiegePolicyScript.resolve_return_ids(
			outcome,
			handling,
			_selected_simulation_siege_return_ids(),
			active_simulation_session.get("attacker_ids", []),
			active_simulation_session.get("defender_ids", []),
			placements
		)
		if not bool(return_result.get("ok", false)):
			_set_status(str(return_result.get("message", "战败方处理还不完整。")))
			call_deferred("_open_simulation_session_end_dialog")
			return
		var return_ids: Array = (return_result.get("return_ids", []) as Array).duplicate()
		var next_placements := PlayerAdjudicatedSiegePolicyScript.placements_without(placements, return_ids)
		var target_place_id := str(active_simulation_session.get("target_place_id", ""))
		var owner_choice := _selected_option_value(simulation_session_siege_owner_select, "keep")
		var next_scenario := scenario_state.duplicate(true)
		if owner_choice == "clear":
			next_scenario = _city_ownership_state_with(target_place_id, "")
		elif owner_choice.begins_with("owner:"):
			var owner_id := owner_choice.trim_prefix("owner:")
			if _scenario_faction_record(owner_id).is_empty():
				_set_status("所选城池归属势力已经不存在；本次没有写入")
				call_deferred("_open_simulation_session_end_dialog")
				return
			next_scenario = _city_ownership_state_with(target_place_id, owner_id)
		var player_note := _sanitize_multiline(simulation_session_end_note_input.text, MAX_SIMULATION_SESSION_NOTE_LENGTH)
		var next_entries: Array[Dictionary] = chronicle_entries.duplicate(true)
		chronicle_id = _new_record_id("chron")
		var now := Time.get_datetime_string_from_system(false, true)
		var body := _build_player_adjudicated_siege_body(outcome, handling, return_ids, next_placements, next_scenario, player_note)
		next_entries.append({
			"id": chronicle_id,
			"entry_type": "battle",
			"title": title_text,
			"time_label": str(active_simulation_session.get("time_label", "")),
			"body": body,
			"created_at": now,
			"updated_at": now,
		})
		var camera := map_board.get_camera_state() if map_board != null else loaded_camera
		var write_result := _write_runtime_state(
			next_placements,
			annotations,
			camera,
			sandbox_metadata,
			next_scenario,
			next_entries,
			player_strokes,
			character_states,
			character_actions,
			character_troops
		)
		if not bool(write_result.get("ok", false)):
			_show_message("攻城裁定没有写入", "人物、城池和纪事均保持确认前状态；本次推演仍在进行，可以稍后重试。")
			return
		_push_history_snapshot("裁定攻城并写入复盘", false, false, true, true)
		_redo_stack.clear()
		placements = next_placements.duplicate(true)
		scenario_state = next_scenario.duplicate(true)
		chronicle_entries = next_entries.duplicate(true)
		active_simulation_session["result_chronicle_id"] = chronicle_id
		active_simulation_session["resolution_committed"] = true
		active_simulation_session["outcome"] = outcome
		active_simulation_session["handling"] = handling
		active_simulation_session["returned_ids"] = return_ids.duplicate()
		_refresh_views()
		_refresh_sandbox_identity_view()
		_update_history_buttons()
		_set_status("攻城结果已按玩家裁定写入 · 人物、城池与纪事可一次撤销")

	if wants_snapshot and str(active_simulation_session.get("end_snapshot_id", "")).is_empty():
		var session_name := str(active_simulation_session.get("name", "未命名攻城"))
		var snapshot_result := _create_named_snapshot(
			_simulation_session_snapshot_name("攻城后", session_name),
			"“%s”由玩家裁定后的局面；对应玩家纪事“%s”。" % [session_name, title_text]
		)
		if not bool(snapshot_result.get("ok", false)):
			_show_message(
				"攻城裁定已写入，终点快照未建立",
				"人物退场、城池处理和纪事已经安全保存且不会重复写入。请检查快照仓库后重试，或取消勾选终点快照完成本次流程。\n\n%s" % str(snapshot_result.get("message", ""))
			)
			return
		var snapshot: Dictionary = snapshot_result.get("snapshot", {})
		active_simulation_session["end_snapshot_id"] = str(snapshot.get("snapshot_id", ""))
		_refresh_sandbox_identity_view()
	_finish_simulation_session("本次攻城已由玩家裁定 · 纪事与起终点快照均已保留" if wants_snapshot else "本次攻城已由玩家裁定 · 纪事与起点快照已保留")


func _build_player_adjudicated_siege_body(outcome: String, handling: String, return_ids: Array, next_placements: Dictionary, next_scenario: Dictionary, player_note: String) -> String:
	var target_place_id := str(active_simulation_session.get("target_place_id", ""))
	var attacker_names := _simulation_character_names(active_simulation_session.get("attacker_ids", []))
	var defender_names := _simulation_character_names(active_simulation_session.get("defender_ids", []))
	var returned_names := _simulation_character_names(return_ids)
	var old_owner := _simulation_faction_name(scenario_state, _scenario_city_owner_id(target_place_id))
	var new_owner_id := ""
	for ownership_value in next_scenario.get("city_ownership", []):
		if ownership_value is Dictionary and str((ownership_value as Dictionary).get("place_id", "")) == target_place_id:
			new_owner_id = str((ownership_value as Dictionary).get("faction_id", ""))
			break
	var new_owner := _simulation_faction_name(next_scenario, new_owner_id)
	var proposed_state := _capture_simulation_session_state()
	proposed_state["placements"] = next_placements.duplicate(true)
	proposed_state["scenario_state"] = next_scenario.duplicate(true)
	var baseline_value: Variant = active_simulation_session.get("baseline", {})
	var baseline: Dictionary = baseline_value if baseline_value is Dictionary else {}
	var diff := SimulationSessionDiffScript.compare(baseline, proposed_state)
	var lines: Array[String] = [
		"玩家裁定：%s · %s。" % [_simulation_place_name(target_place_id), PlayerAdjudicatedSiegePolicyScript.outcome_label(outcome)],
		"攻方：%s；守方：%s。" % [attacker_names, defender_names],
		"局面处理：%s；实际收回：%s。" % [PlayerAdjudicatedSiegePolicyScript.handling_label(handling), returned_names if not returned_names.is_empty() else "无"],
		"城池归属：%s。" % ("保持%s" % old_owner if old_owner == new_owner else "%s → %s" % [old_owner, new_owner]),
		_simulation_diff_plain_text(diff),
	]
	if not player_note.is_empty():
		lines.append("我的复盘：%s" % player_note)
	return _sanitize_multiline("\n".join(lines), MAX_CHRONICLE_BODY_LENGTH)


func _simulation_character_names(character_ids: Array) -> String:
	var names: Array[String] = []
	for character_id_value in character_ids:
		var character_id := str(character_id_value)
		if not character_id.is_empty() and character_id not in names:
			names.append(_character_name(character_id))
	return "、".join(names)


func _simulation_diff_plain_text(diff: Dictionary) -> String:
	var lines := _simulation_diff_lines(diff)
	if lines.is_empty():
		return "局面变化：未检测到结构变化。"
	return "局面变化：\n%s" % "\n".join(lines)


func _simulation_session_chronicle_type(session_type: String) -> String:
	match session_type:
		"reinforcement":
			return "reinforcement"
		"advance", "siege":
			return "battle"
		"plan":
			return "plot"
		_:
			return "note"


func _open_simulation_session_cancel_dialog() -> void:
	if not active_simulation_session.is_empty() and simulation_session_cancel_dialog != null:
		simulation_session_cancel_dialog.popup_centered(Vector2i(520, 240))


func _confirm_cancel_simulation_session() -> void:
	if active_simulation_session.is_empty():
		return
	_finish_simulation_session("本次流程助手已关闭 · 地图改动和起点快照均保留")


func _finish_simulation_session(status_text: String) -> void:
	active_simulation_session.clear()
	pending_simulation_session_participants.clear()
	_refresh_simulation_session_bar()
	_set_status(status_text)


func _on_sandbox_file_menu_pressed(item_id: int) -> void:
	# Display-only action must not cancel a draft or end an active simulation.
	if item_id == MAP_TOOLS_VISIBLE_MENU_ID and map_board != null:
		var show_tools := not map_board.is_map_tools_visible()
		map_board.set_map_tools_visible(show_tools)
		var popup := sandbox_file_menu.get_popup()
		popup.set_item_checked(popup.get_item_index(MAP_TOOLS_VISIBLE_MENU_ID), show_tools)
		sandbox_file_menu.grab_focus()
		_set_status("地图工具已显示" if show_tools else "地图工具已隐藏 · 在沙盘菜单中勾选即可恢复；当前推演和绘制保留")
		return
	if not _guard_active_map_draft_before_interruption("使用沙盘菜单"):
		return
	if not active_simulation_session.is_empty() and item_id in [4, 6, 7, 8, 12, 13, 15, 16]:
		_set_status("请先结束本次推演或取消助手，再切换／恢复沙盘或返回标题")
		return
	if item_id == QUICK_SITUATION_BOOKMARK_MENU_ID and _simulation_session_tool_is_busy():
		_set_status("请先完成或取消当前绘制／连续设置，再留住此刻")
		return
	if city_ownership_tool_active:
		_finish_city_ownership_tool("", false)
	if map_board != null and map_board.is_annotation_tool_active():
		map_board.set_annotation_tool_active(false)
	if map_board != null and map_board.is_player_stroke_tool_active():
		map_board.cancel_player_stroke_draft()
	if map_board != null and map_board.is_player_stroke_point_edit_active():
		map_board.cancel_player_stroke_point_edit()
	match item_id:
		7:
			_open_new_sandbox_dialog()
		8:
			_open_branch_current_sandbox_dialog()
		PLACE_SEARCH_MENU_ID:
			_open_place_search_dialog()
		CURRENT_ROSTER_MENU_ID:
			_open_current_roster_dialog()
		1:
			_open_sandbox_info_dialog()
		10:
			_open_scenario_editor()
		11:
			_open_chronicle_dialog()
		14:
			_open_simulation_session_start_dialog()
		2:
			_on_save_pressed()
		QUICK_SITUATION_BOOKMARK_MENU_ID:
			_on_quick_situation_bookmark_pressed()
		9:
			_open_personal_template_create_dialog()
		15:
			_open_scenario_share_export_dialog()
		16:
			if import_dialog != null:
				_pending_file_import_mode = "scenario_share"
				import_dialog.title = "选择一个开局包"
				import_dialog.filters = PackedStringArray(["*.sanguostart ; 三国推演志开局包"])
				import_dialog.popup_centered(Vector2i(900, 640))
		3:
			_open_snapshot_create_dialog()
		4:
			_open_snapshot_manager()
		5:
			if export_dialog != null:
				_pending_file_export_mode = "sandbox"
				_pending_scenario_share_template.clear()
				_pending_export_path = ""
				_pending_export_snapshot_id = ""
				export_dialog.title = "备份当前沙盘"
				export_dialog.filters = PackedStringArray(["*.tianxia ; 三国推演志沙盘备份"])
				export_dialog.current_file = "%s_%s.tianxia" % [_safe_filename_component(str(sandbox_metadata.get("title", "未命名沙盘"))), _timestamp_slug().left(16)]
				export_dialog.popup_centered(Vector2i(900, 640))
		6:
			if import_dialog != null:
				_pending_file_import_mode = "sandbox"
				import_dialog.title = "选择一个沙盘备份"
				import_dialog.filters = PackedStringArray(["*.tianxia ; 三国推演志沙盘备份", "*.json ; 旧式 JSON 存档"])
				import_dialog.popup_centered(Vector2i(900, 640))
		13:
			_open_primary_recovery_dialog()
		12:
			_return_to_title_screen()


func _sync_map_visual_profile_menu() -> void:
	if map_visual_profile_menu == null:
		return
	var active_profile := terrain_visual_profile
	if map_board != null:
		active_profile = map_board.get_terrain_visual_profile()
	for item_id in [MAP_VISUAL_DAYLIGHT_MENU_ID, MAP_VISUAL_ANTIQUE_MENU_ID, MAP_VISUAL_JADE_MENU_ID]:
		var item_index := map_visual_profile_menu.get_item_index(item_id)
		if item_index < 0:
			continue
		var profile := (
			MapBoardScript.TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1
			if item_id == MAP_VISUAL_DAYLIGHT_MENU_ID
			else MapBoardScript.TERRAIN_VISUAL_PROFILE_ANTIQUE_TOPOGRAPHIC_V1
		)
		if item_id == MAP_VISUAL_JADE_MENU_ID:
			profile = MapBoardScript.TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1
		map_visual_profile_menu.set_item_checked(item_index, active_profile == profile)


func _on_map_visual_profile_menu_pressed(item_id: int) -> void:
	if map_board == null or item_id not in [MAP_VISUAL_DAYLIGHT_MENU_ID, MAP_VISUAL_ANTIQUE_MENU_ID, MAP_VISUAL_JADE_MENU_ID]:
		return
	var next_profile := (
		MapBoardScript.TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1
		if item_id == MAP_VISUAL_DAYLIGHT_MENU_ID
		else MapBoardScript.TERRAIN_VISUAL_PROFILE_ANTIQUE_TOPOGRAPHIC_V1
	)
	var profile_label := "明亮白昼" if item_id == MAP_VISUAL_DAYLIGHT_MENU_ID else "古地图地形"
	if item_id == MAP_VISUAL_JADE_MENU_ID:
		next_profile = MapBoardScript.TERRAIN_VISUAL_PROFILE_JADE_PIXEL_V1
		profile_label = "青绿微像素"
	if map_board.get_terrain_visual_profile() == next_profile:
		_sync_map_visual_profile_menu()
		_set_status("当前已经是%s" % profile_label)
		return
	if not map_board.set_terrain_visual_profile(next_profile):
		_set_status("地图外观没有变化")
		return
	terrain_visual_profile = next_profile
	_sync_map_visual_profile_menu()
	_set_status("已切换为%s · 只影响当前会话显示" % profile_label)


func _return_to_title_screen() -> bool:
	if not _guard_unsaved_editor_drafts_before_leaving():
		return false
	if _primary_recovery_requires_reload:
		var reload_result := get_tree().change_scene_to_file(TITLE_SCENE_PATH)
		if reload_result != OK:
			_show_message("无法打开标题页", "当前主档和全部恢复文件均未修改，但标题场景加载失败：%s" % error_string(reload_result))
			return false
		return true
	if not _save():
		_show_leave_failure_message("暂时无法返回标题", "当前沙盘没有安全写入；为避免丢失改动，已留在地图中。请检查存档文件或磁盘空间后重试。")
		return false
	var result := get_tree().change_scene_to_file(TITLE_SCENE_PATH)
	if result != OK:
		_show_message("无法打开标题页", "当前沙盘已经保存，但标题场景加载失败：%s" % error_string(result))
		return false
	return true


func _on_export_file_selected(path: String) -> void:
	if _pending_file_export_mode == "scenario_share":
		_on_scenario_share_export_file_selected(path)
		return
	var exporting_snapshot := not _pending_export_snapshot_id.is_empty()
	var return_snapshot_id := _pending_export_snapshot_id
	var return_snapshot_scroll := _snapshot_manager_scroll_value()
	var export_name := str(_find_named_snapshot(_pending_export_snapshot_id).get("name", "未命名快照")) if exporting_snapshot else str(sandbox_metadata.get("title", "未命名沙盘"))
	var result := _write_named_snapshot_transfer_file(path, _pending_export_snapshot_id, false) if exporting_snapshot else _write_sandbox_transfer_file(path, false)
	if str(result.get("error_code", "")) == "target_exists":
		_pending_export_path = str(result.get("path", path))
		export_overwrite_dialog.title = "替换已有备份？"
		export_overwrite_dialog.dialog_text = "“%s”已经存在。\n\n替换后，原文件内容将无法恢复。当前沙盘和游戏内快照保持原样。" % _pending_export_path.get_file()
		export_overwrite_dialog.popup_centered(Vector2i(470, 210))
		return
	if bool(result.get("ok", false)):
		_set_status("快照“%s”已导出，游戏内快照仍然保留" % export_name if exporting_snapshot else "备份已保存，当前沙盘保持原样")
	else:
		_show_message(
			"快照没有导出" if exporting_snapshot else "备份没有保存成功",
			("游戏内快照和当前沙盘都没有变化。" if exporting_snapshot else "当前沙盘仍安全保存在游戏中。")
			+ "请换一个文件夹或检查剩余空间后再试。\n\n%s" % str(result.get("message", ""))
		)
	_pending_export_path = ""
	_pending_export_snapshot_id = ""
	_pending_file_export_mode = ""
	if bool(result.get("ok", false)) and exporting_snapshot:
		call_deferred("_open_snapshot_manager", return_snapshot_id, return_snapshot_scroll)


func _on_scenario_share_export_file_selected(path: String) -> void:
	if _pending_scenario_share_template.is_empty():
		_pending_file_export_mode = ""
		_show_message("开局包没有导出", "待导出的开局已经失效；当前沙盘和已有文件都没有变化。")
		return
	var result := _write_scenario_share_package(path, _pending_scenario_share_template, false)
	if str(result.get("error_code", "")) == "target_exists":
		_pending_export_path = str(result.get("path", path))
		export_overwrite_dialog.title = "替换已有开局包？"
		export_overwrite_dialog.dialog_text = "“%s”已经存在。\n\n替换后，原文件内容将无法恢复；当前沙盘保持原样。" % _pending_export_path.get_file()
		export_overwrite_dialog.popup_centered(Vector2i(470, 210))
		return
	var package_name := str(_pending_scenario_share_template.get("name", "未命名开局"))
	if bool(result.get("ok", false)):
		_set_status("开局包“%s”已导出 · 当前沙盘保持不变" % package_name)
	else:
		_show_message("开局包没有导出", "当前沙盘和已有文件都没有变化。\n\n%s" % str(result.get("message", "无法写入文件。")))
	_pending_export_path = ""
	_pending_file_export_mode = ""
	_pending_scenario_share_template.clear()


func _confirm_export_overwrite() -> void:
	if _pending_export_path.is_empty():
		return
	if _pending_file_export_mode == "scenario_share":
		var package_name := str(_pending_scenario_share_template.get("name", "未命名开局"))
		var share_result := _write_scenario_share_package(_pending_export_path, _pending_scenario_share_template, true)
		_pending_export_path = ""
		_pending_file_export_mode = ""
		_pending_scenario_share_template.clear()
		if bool(share_result.get("ok", false)):
			_set_status("开局包“%s”已导出并替换原文件" % package_name)
		else:
			_show_message("开局包没有导出", "原文件和当前沙盘均未主动删除。\n\n%s" % str(share_result.get("message", "无法替换文件。")))
		return
	var target_path := _pending_export_path
	var snapshot_id := _pending_export_snapshot_id
	var exporting_snapshot := not snapshot_id.is_empty()
	var export_name := str(_find_named_snapshot(snapshot_id).get("name", "未命名快照")) if exporting_snapshot else str(sandbox_metadata.get("title", "未命名沙盘"))
	_pending_export_path = ""
	var result := _write_named_snapshot_transfer_file(target_path, snapshot_id, true) if exporting_snapshot else _write_sandbox_transfer_file(target_path, true)
	_pending_export_snapshot_id = ""
	_pending_file_export_mode = ""
	if bool(result.get("ok", false)):
		_set_status("快照“%s”已导出并替换原文件" % export_name if exporting_snapshot else "已有备份已安全替换，当前沙盘保持原样")
		if exporting_snapshot:
			call_deferred("_open_snapshot_manager", snapshot_id, _snapshot_manager_scroll_value())
	else:
		_show_message("快照没有导出" if exporting_snapshot else "备份没有保存成功", "原文件、游戏内快照和当前沙盘均未主动删除。\n\n%s" % str(result.get("message", "")))


func _cancel_export_overwrite() -> void:
	if _pending_file_export_mode == "scenario_share":
		_pending_export_path = ""
		_pending_file_export_mode = ""
		_pending_scenario_share_template.clear()
		_set_status("已取消替换，原开局包和当前沙盘保持不变")
		return
	var exporting_snapshot := not _pending_export_snapshot_id.is_empty()
	var snapshot_id := _pending_export_snapshot_id
	_pending_export_path = ""
	_pending_export_snapshot_id = ""
	_pending_file_export_mode = ""
	_set_status("已取消替换，原文件和游戏内快照保持不变" if exporting_snapshot else "已取消替换，原备份保持不变")
	if exporting_snapshot:
		call_deferred("_open_snapshot_manager", snapshot_id, _snapshot_manager_scroll_value())


func _cancel_export_dialog() -> void:
	if _pending_file_export_mode == "scenario_share":
		_pending_export_path = ""
		_pending_file_export_mode = ""
		_pending_scenario_share_template.clear()
		_set_status("已取消导出开局包")
		return
	var exporting_snapshot := not _pending_export_snapshot_id.is_empty()
	var snapshot_id := _pending_export_snapshot_id
	_pending_export_path = ""
	_pending_export_snapshot_id = ""
	_pending_file_export_mode = ""
	_set_status("已取消导出，游戏内快照仍然保留" if exporting_snapshot else "已取消备份")
	if exporting_snapshot:
		call_deferred("_open_snapshot_manager", snapshot_id, _snapshot_manager_scroll_value())


func _cancel_import_dialog() -> void:
	var canceled_share := _pending_file_import_mode == "scenario_share"
	_pending_file_import_mode = ""
	_pending_import_result.clear()
	_pending_import_path = ""
	_set_status("已取消选择开局包" if canceled_share else "已取消恢复")


func _on_import_file_selected(path: String) -> void:
	if _pending_file_import_mode == "scenario_share":
		_on_scenario_share_import_file_selected(path)
		return
	import_confirmation_dialog.title = "从这个备份继续？"
	import_confirmation_dialog.ok_button_text = "继续"
	import_confirmation_dialog.cancel_button_text = "取消"
	var result := _read_sandbox_transfer_file(path, true)
	if not bool(result.get("ok", false)):
		_pending_import_result.clear()
		_pending_import_path = ""
		_pending_file_import_mode = ""
		_show_message("无法打开这个备份", "%s\n\n当前沙盘没有变化。" % str(result.get("message", "文件内容无效。")))
		return
	_pending_import_result = result.duplicate(true)
	_pending_import_path = path
	var warnings: Array = result.get("warnings", [])
	var warning_text := "可以恢复"
	if not warnings.is_empty():
		warning_text = "有 %d 项兼容提示，无法识别的内容会被跳过。" % warnings.size()
		var preview_count := mini(3, warnings.size())
		for index in range(preview_count):
			warning_text += "\n• %s" % str(warnings[index])
		if warnings.size() > preview_count:
			warning_text += "\n• 另有 %d 项提示" % (warnings.size() - preview_count)
	var saved_time := str(result.get("exported_at", ""))
	if saved_time.is_empty():
		saved_time = "未记录"
	var view_summary := "恢复后会替换当前人物、标记、推演线、玩家纪事、本局属性、行动状态和视角；人物收藏保持原样。"
	if not bool(result.get("camera_valid", false)):
		view_summary = "恢复后会替换当前人物、标记、推演线、玩家纪事、本局属性和行动状态；旧地图视角不再适用，将回到天下全图。人物收藏保持原样。" if bool(result.get("geometry_migration_required", false)) else "恢复后会替换当前人物、标记、推演线、玩家纪事、本局属性和行动状态，并保留当前视角；人物收藏保持原样。"
	var source_metadata: Dictionary = result.get("sandbox_metadata", {})
	var source_scenario_state: Dictionary = result.get("scenario_state", _empty_scenario_state())
	var source_faction_count := int((source_scenario_state.get("factions", []) as Array).size())
	var source_title := str(source_metadata.get("title", "旧版未命名沙盘"))
	var source_snapshot_name := str(result.get("source_snapshot_name", ""))
	var snapshot_summary := ""
	if not source_snapshot_name.is_empty():
		snapshot_summary = "来源快照：%s\n" % source_snapshot_name
	import_summary_label.text = (
		"文件：%s\n"
		+ "沙盘：%s\n"
		+ "%s"
		+ "内容：人物 %d 张 · 标记 %d 个 · 推演线 %d 条 · 玩法分组 %d 组 · 玩家纪事 %d 则 · 本局属性 %d 人 · 行动标注 %d 人\n"
		+ "保存时间：%s\n"
		+ "地图：汉末天下\n\n"
		+ "%s\n\n"
		+ "%s\n"
		+ "继续前会自动备份当前沙盘，并建立一个新的分支；之后也可以撤销。"
	) % [
		path.get_file(), source_title, snapshot_summary, int(result.get("character_count", 0)), int(result.get("annotation_count", 0)), int(result.get("player_stroke_count", 0)), source_faction_count, int(result.get("chronicle_count", 0)), int(result.get("character_state_count", 0)), int(result.get("character_action_count", 0)),
		saved_time, warning_text, view_summary
	]
	import_confirmation_dialog.popup_centered(Vector2i(520, 310))


func _on_scenario_share_import_file_selected(path: String) -> void:
	var result := _read_scenario_share_package(path)
	if not bool(result.get("ok", false)):
		_pending_import_result.clear()
		_pending_import_path = ""
		_pending_file_import_mode = ""
		_show_message("无法打开这个开局包", "%s\n\n当前沙盘和个人模板库都没有变化。" % str(result.get("message", "文件内容无效。")))
		return
	_show_scenario_share_import_preview(path, result)


func _show_scenario_share_import_preview(path: String, result: Dictionary) -> void:
	_pending_import_result = result.duplicate(true)
	_pending_import_path = path
	var template: Dictionary = result.get("template", {})
	var description := str(template.get("description", "")).strip_edges()
	if description.is_empty():
		description = "没有附加说明。"
	import_confirmation_dialog.title = "从这个开局开始？"
	import_confirmation_dialog.ok_button_text = "保护当前沙盘并新建"
	import_confirmation_dialog.cancel_button_text = "取消"
	import_summary_label.text = (
		"文件：%s\n"
		+ "开局：%s\n"
		+ "内容：人物 %d 张 · 势力 %d 组 · 归属城池 %d 座 · 标记 %d 个\n"
		+ "导出时间：%s\n\n"
		+ "%s\n\n"
		+ "确认后先自动备份当前沙盘，再建立一个独立新沙盘。开局包带入人物、势力、归属城池和标记；其余本局状态留在原沙盘。"
	) % [
		path.get_file(), str(template.get("name", "未命名开局")), int(result.get("character_count", 0)),
		int(result.get("faction_count", 0)), int(result.get("ownership_count", 0)), int(result.get("annotation_count", 0)),
		_format_display_time(str(result.get("exported_at", ""))), description
	]
	import_confirmation_dialog.popup_centered(Vector2i(560, 360))


func _cancel_sandbox_import() -> void:
	var canceled_share := _pending_file_import_mode == "scenario_share"
	_pending_import_result.clear()
	_pending_import_path = ""
	_pending_file_import_mode = ""
	_set_status("已取消导入开局包，当前沙盘没有变化" if canceled_share else "已取消恢复，当前沙盘没有变化")


func _confirm_sandbox_import() -> void:
	if _pending_file_import_mode == "scenario_share":
		_confirm_scenario_share_import()
		return
	if not bool(_pending_import_result.get("ok", false)):
		_cancel_sandbox_import()
		return
	var source_name := _pending_import_path.get_file().get_basename()
	var warning_count := int(_pending_import_result.get("warnings", []).size())
	var result := _apply_import_result(_pending_import_result)
	_pending_import_result.clear()
	_pending_import_path = ""
	_pending_file_import_mode = ""
	if not bool(result.get("ok", false)):
		_show_message(str(result.get("title", "暂时不能恢复")), str(result.get("message", "当前沙盘没有变化。")))
		return
	if bool(result.get("unchanged", false)):
		_set_status("备份内容与当前沙盘相同，未作修改")
		return
	var status := "已从“%s”继续 · 已建立分支 · 可撤销" % source_name
	if warning_count > 0:
		status += " · 跳过/修正 %d 项" % warning_count
	_set_status(status)


func _confirm_scenario_share_import() -> void:
	if not bool(_pending_import_result.get("ok", false)):
		_cancel_sandbox_import()
		return
	var template: Dictionary = _pending_import_result.get("template", {}).duplicate(true)
	var candidate: Dictionary = _pending_import_result.get("candidate", {}).duplicate(true)
	var source_name := _pending_import_path.get_file().get_basename()
	var requested_title := str(template.get("title", template.get("name", "导入开局")))
	_pending_import_result.clear()
	_pending_import_path = ""
	_pending_file_import_mode = ""
	var result := _apply_scenario_candidate(candidate, requested_title, "从开局包新建沙盘")
	if not bool(result.get("ok", false)):
		_show_message("暂时不能从这个开局开始", "%s\n\n当前沙盘没有变化。" % str(result.get("message", "无法安全建立新沙盘。")))
		return
	_set_status("已从“%s”建立独立新沙盘 · 原沙盘已自动备份 · 可撤销" % source_name)


func _apply_import_result(candidate: Dictionary) -> Dictionary:
	if not bool(candidate.get("ok", false)):
		return {"ok": false, "title": "暂时不能恢复", "message": "备份尚未通过完整校验，当前沙盘没有变化。"}
	if _save_writes_blocked:
		return {"ok": false, "title": "暂时不能继续", "message": "当前沙盘处于原文件保护状态。请先保留原文件并使用兼容版本打开，当前内容没有变化。"}
	var next_placements: Dictionary = candidate.get("placements", {}).duplicate(true)
	var next_annotations: Dictionary = candidate.get("annotations", {}).duplicate(true)
	var next_scenario_state: Dictionary = candidate.get("scenario_state", _empty_scenario_state()).duplicate(true)
	var next_chronicle_entries: Array[Dictionary] = (candidate.get("chronicle_entries", []) as Array).duplicate(true)
	var next_player_strokes: Array[Dictionary] = (candidate.get("player_strokes", []) as Array).duplicate(true)
	var next_character_states: Dictionary = candidate.get("character_states", {}).duplicate(true)
	var next_character_actions: Dictionary = candidate.get("character_actions", {}).duplicate(true)
	var next_character_troops: Dictionary = candidate.get("character_troops", {}).duplicate(true)
	var current_camera := map_board.get_camera_state() if map_board != null else {}
	var next_camera: Dictionary
	if bool(candidate.get("camera_valid", false)):
		next_camera = candidate.get("camera", {}).duplicate(true)
	elif bool(candidate.get("geometry_migration_required", false)) and map_board != null:
		next_camera = map_board.get_home_camera_state()
	else:
		next_camera = current_camera.duplicate(true)
	var source_metadata: Dictionary = candidate.get("sandbox_metadata", {}).duplicate(true)
	var source_has_identity := not bool(candidate.get("metadata_migration_required", true)) and not source_metadata.is_empty()
	var source_snapshot_id := str(candidate.get("source_snapshot_id", ""))
	if (
		_placements_match(placements, next_placements)
		and _annotations_match(annotations, next_annotations)
		and _scenario_states_match(scenario_state, next_scenario_state)
		and _chronicle_entries_match(chronicle_entries, next_chronicle_entries)
		and _player_strokes_match(player_strokes, next_player_strokes)
		and _character_states_match(character_states, next_character_states)
		and _character_actions_match(character_actions, next_character_actions)
		and _character_troops_match(character_troops, next_character_troops)
		and _camera_states_match(current_camera, next_camera)
		and source_has_identity
		and source_snapshot_id.is_empty()
		and str(source_metadata.get("sandbox_id", "")) == str(sandbox_metadata.get("sandbox_id", ""))
	):
		return {"ok": true, "unchanged": true}
	var next_metadata := _branch_metadata_from(source_metadata, source_snapshot_id) if source_has_identity else _new_sandbox_metadata()

	var backup_result := _create_internal_backup("恢复前")
	if not bool(backup_result.get("ok", false)):
		return {
			"ok": false,
			"title": "暂时不能恢复",
			"message": "无法为当前沙盘创建安全备份。为了避免丢失内容，本次恢复已取消。\n\n%s" % str(backup_result.get("message", ""))
		}
	var candidate_payload := _build_sandbox_payload_for(next_placements, next_annotations, next_camera, next_metadata, next_scenario_state, next_chronicle_entries, next_player_strokes, next_character_states, next_character_actions, next_character_troops)
	var write_result := _write_validated_sandbox_payload_atomic(save_path, candidate_payload, true)
	if not bool(write_result.get("ok", false)):
		return {
			"ok": false,
			"title": "暂时不能恢复",
			"message": "新沙盘无法安全写入，本次恢复已取消；原沙盘和自动备份均已保留。\n\n%s" % str(write_result.get("message", "")),
			"backup_path": str(backup_result.get("path", ""))
		}
	_save_writes_blocked = false
	_save_write_block_reason = ""

	_push_history_snapshot("从备份继续", true, true)
	_redo_stack.clear()
	placements = next_placements
	annotations = next_annotations
	sandbox_metadata = next_metadata
	scenario_state = next_scenario_state
	chronicle_entries = next_chronicle_entries
	player_strokes = next_player_strokes
	character_states = next_character_states
	character_actions = next_character_actions
	character_troops = next_character_troops
	loaded_camera = next_camera.duplicate(true)
	_clear_hand_candidates_for_new_sandbox()
	_recalculate_next_annotation_serial()
	_refresh_views()
	_refresh_sandbox_identity_view()
	if map_board != null:
		map_board.set_camera_state(next_camera)
	_update_history_buttons()
	return {"ok": true, "backup_path": str(backup_result.get("path", "")), "metadata": next_metadata.duplicate(true)}


func _branch_current_sandbox(requested_title := "") -> Dictionary:
	if _save_writes_blocked:
		return {"ok": false, "message": "当前沙盘处于原文件保护状态。请先保留原文件并使用兼容版本打开；本次没有变化。"}
	if _snapshot_writes_blocked:
		return {"ok": false, "message": "命名快照库处于保护状态，无法先保留当前局面；本次没有变化。"}
	if named_snapshots.size() >= SNAPSHOT_LIMIT:
		return {"ok": false, "message": "命名快照已达到 %d 个上限。请先删除不再需要的快照，再从当前局面另开。" % SNAPSHOT_LIMIT}
	var current_metadata := sandbox_metadata.duplicate(true)
	var parent_id := str(current_metadata.get("sandbox_id", "")).strip_edges()
	if not _is_safe_record_id(parent_id):
		return {"ok": false, "message": "当前沙盘缺少有效身份，不能安全建立来源关系；本次没有变化。"}
	var current_placements := placements.duplicate(true)
	var current_annotations := annotations.duplicate(true)
	var current_scenario_state := scenario_state.duplicate(true)
	var current_chronicle_entries := chronicle_entries.duplicate(true)
	var current_player_strokes := player_strokes.duplicate(true)
	var current_character_states := character_states.duplicate(true)
	var current_character_actions := character_actions.duplicate(true)
	var current_character_troops := character_troops.duplicate(true)
	var current_camera := map_board.get_camera_state() if map_board != null else loaded_camera.duplicate(true)
	var next_metadata := _branch_metadata_from(current_metadata, "")
	next_metadata["title"] = _sanitize_single_line(requested_title, MAX_SANDBOX_TITLE_LENGTH, _default_branch_sandbox_title())
	var current_payload := _build_sandbox_payload_for(
		current_placements,
		current_annotations,
		current_camera,
		current_metadata,
		current_scenario_state,
		current_chronicle_entries,
		current_player_strokes,
		current_character_states,
		current_character_actions,
		current_character_troops
	)

	# 先留下独立备份和玩家可见快照，再切换活动身份。后续任一步失败都不改当前局面。
	var backup_result := _create_internal_backup("另开分支前")
	if not bool(backup_result.get("ok", false)):
		return {
			"ok": false,
			"message": "无法为当前沙盘创建安全备份。为了避免丢失内容，本次另开已取消。\n\n%s" % str(backup_result.get("message", ""))
		}
	var source_title := str(current_metadata.get("title", "未命名沙盘"))
	var snapshot_name := _branch_protection_snapshot_name(source_title)
	var snapshot_note := "从“%s”另开为“%s”前自动保留的局面；可从命名快照恢复。" % [source_title, str(next_metadata.get("title", "未命名沙盘"))]
	var snapshot_result := _create_named_snapshot_from_payload(snapshot_name, snapshot_note, current_payload)
	if not bool(snapshot_result.get("ok", false)):
		return {
			"ok": false,
			"message": "当前局面无法保存为命名快照，本次另开已取消；当前沙盘和安全备份均已保留。\n\n%s" % str(snapshot_result.get("message", "")),
			"backup_path": str(backup_result.get("path", ""))
		}
	var snapshot: Dictionary = snapshot_result.get("snapshot", {}).duplicate(true)
	_refresh_sandbox_identity_view()

	var write_result := _write_validated_sandbox_payload_atomic(
		save_path,
		_build_sandbox_payload_for(current_placements, current_annotations, current_camera, next_metadata, current_scenario_state, current_chronicle_entries, current_player_strokes, current_character_states, current_character_actions, current_character_troops),
		true
	)
	if not bool(write_result.get("ok", false)):
		return {
			"ok": false,
			"message": "新沙盘无法安全写入，本次另开已取消；当前沙盘未切换，命名快照“%s”和安全备份仍保留。\n\n%s" % [snapshot_name, str(write_result.get("message", ""))],
			"backup_path": str(backup_result.get("path", "")),
			"snapshot": snapshot,
			"snapshot_preserved": true
		}
	_save_writes_blocked = false
	_save_write_block_reason = ""
	_push_history_snapshot("从当前局面另开沙盘", true, true)
	_redo_stack.clear()
	sandbox_metadata = next_metadata
	loaded_camera = current_camera.duplicate(true)
	_refresh_sandbox_identity_view()
	_update_history_buttons()
	return {
		"ok": true,
		"backup_path": str(backup_result.get("path", "")),
		"metadata": next_metadata.duplicate(true),
		"snapshot": snapshot
	}


func _apply_scenario_template(template_id: String, requested_title := "", template_source := "builtin") -> Dictionary:
	var candidate := _build_personal_template_candidate(template_id) if template_source == "personal" else _build_scenario_template_candidate(template_id)
	return _apply_scenario_candidate(candidate, requested_title, "新建沙盘")


func _scenario_opening_camera_state(template: Dictionary, next_placements: Dictionary) -> Dictionary:
	if map_board == null:
		return loaded_camera.duplicate(true)
	var scenario_id := str(template.get("scenario_id", ""))
	if scenario_id not in HISTORICAL_SCENARIO_OPENING_IDS:
		return map_board.get_home_camera_state()
	var place_ids: Array = []
	var seen_place_ids := {}
	for placement_value in next_placements.values():
		if not (placement_value is Dictionary):
			continue
		var place_id := str((placement_value as Dictionary).get("place_id", ""))
		if place_id.is_empty() or seen_place_ids.has(place_id):
			continue
		seen_place_ids[place_id] = true
		place_ids.append(place_id)
	return map_board.get_place_group_camera_state(
		place_ids,
		HISTORICAL_SCENARIO_OPENING_ZOOM,
		HISTORICAL_SCENARIO_OPENING_SCREEN_ANCHOR
	)


func _apply_scenario_candidate(candidate: Dictionary, requested_title := "", history_label := "新建沙盘") -> Dictionary:
	if not bool(candidate.get("ok", false)):
		return {"ok": false, "message": str(candidate.get("message", "起步模板未通过校验，当前沙盘没有变化。"))}
	if _save_writes_blocked:
		return {"ok": false, "message": "当前沙盘处于原文件保护状态。请先保留原文件并使用兼容版本打开；本次没有变化。"}
	var template: Dictionary = candidate.get("template", {}).duplicate(true)
	var next_placements: Dictionary = candidate.get("placements", {}).duplicate(true)
	var next_annotations: Dictionary = candidate.get("annotations", {}).duplicate(true)
	var next_scenario_state: Dictionary = candidate.get("scenario_state", _empty_scenario_state()).duplicate(true)
	var next_camera := _scenario_opening_camera_state(template, next_placements)

	# 先保护现状，再生成新身份并落盘；任何失败都不会提前改动地图或历史。
	var backup_result := _create_internal_backup("新建前")
	if not bool(backup_result.get("ok", false)):
		return {
			"ok": false,
			"message": "无法为当前沙盘创建安全备份。为了避免丢失内容，本次新建已取消。\n\n%s" % str(backup_result.get("message", ""))
		}
	var next_metadata := _new_sandbox_metadata(
		_sanitize_single_line(requested_title, MAX_SANDBOX_TITLE_LENGTH, str(template.get("title", "未命名沙盘"))),
		str(template.get("description", "")),
		str(template.get("scenario_source", "")),
		"",
		""
	)
	var write_result := _write_validated_sandbox_payload_atomic(
		save_path,
		_build_sandbox_payload_for(next_placements, next_annotations, next_camera, next_metadata, next_scenario_state, [], [], {}, {}, {}),
		true
	)
	if not bool(write_result.get("ok", false)):
		return {
			"ok": false,
			"message": "新沙盘无法安全写入，本次新建已取消；原沙盘和自动备份均已保留。\n\n%s" % str(write_result.get("message", "")),
			"backup_path": str(backup_result.get("path", ""))
		}
	_save_writes_blocked = false
	_save_write_block_reason = ""
	_push_history_snapshot(history_label, true, true)
	_redo_stack.clear()
	placements = next_placements
	annotations = next_annotations
	sandbox_metadata = next_metadata
	scenario_state = next_scenario_state
	chronicle_entries.clear()
	player_strokes.clear()
	character_states.clear()
	character_actions.clear()
	character_troops.clear()
	loaded_camera = next_camera.duplicate(true)
	_clear_hand_candidates_for_new_sandbox()
	_recalculate_next_annotation_serial()
	_refresh_views()
	_refresh_sandbox_identity_view()
	if map_board != null:
		map_board.set_camera_state(next_camera)
	_update_history_buttons()
	return {
		"ok": true,
		"backup_path": str(backup_result.get("path", "")),
		"metadata": next_metadata.duplicate(true),
		"template": template.duplicate(true)
	}


func _camera_states_match(first: Dictionary, second: Dictionary) -> bool:
	if first.is_empty() != second.is_empty():
		return false
	if first.is_empty():
		return true
	for key in ["x", "y", "zoom"]:
		if not is_equal_approx(float(first.get(key, 0.0)), float(second.get(key, 0.0))):
			return false
	return true


func _apply_named_snapshot(record: Dictionary) -> Dictionary:
	if _save_writes_blocked:
		return {"ok": false, "message": "当前沙盘处于原文件保护状态，暂时不能恢复快照。"}
	var snapshot_id := str(record.get("snapshot_id", ""))
	var payload_value: Variant = record.get("sandbox", null)
	if not _is_safe_record_id(snapshot_id) or not (payload_value is Dictionary):
		return {"ok": false, "message": "命名快照结构无效。"}
	var candidate := _decode_sandbox_document(payload_value, false)
	if not bool(candidate.get("ok", false)) or bool(candidate.get("metadata_migration_required", true)):
		return {"ok": false, "message": "命名快照无法通过完整校验。"}
	var next_placements: Dictionary = candidate.get("placements", {}).duplicate(true)
	var next_annotations: Dictionary = candidate.get("annotations", {}).duplicate(true)
	var next_scenario_state: Dictionary = candidate.get("scenario_state", _empty_scenario_state()).duplicate(true)
	var next_chronicle_entries: Array[Dictionary] = (candidate.get("chronicle_entries", []) as Array).duplicate(true)
	var next_player_strokes: Array[Dictionary] = (candidate.get("player_strokes", []) as Array).duplicate(true)
	var next_character_states: Dictionary = candidate.get("character_states", {}).duplicate(true)
	var next_character_actions: Dictionary = candidate.get("character_actions", {}).duplicate(true)
	var next_character_troops: Dictionary = candidate.get("character_troops", {}).duplicate(true)
	var current_camera := map_board.get_camera_state() if map_board != null else {}
	var next_camera: Dictionary
	if bool(candidate.get("camera_valid", false)):
		next_camera = candidate.get("camera", {}).duplicate(true)
	elif bool(candidate.get("geometry_migration_required", false)) and map_board != null:
		next_camera = map_board.get_home_camera_state()
	else:
		next_camera = current_camera.duplicate(true)
	var source_metadata: Dictionary = candidate.get("sandbox_metadata", {}).duplicate(true)
	if (
		_placements_match(placements, next_placements)
		and _annotations_match(annotations, next_annotations)
		and _scenario_states_match(scenario_state, next_scenario_state)
		and _chronicle_entries_match(chronicle_entries, next_chronicle_entries)
		and _player_strokes_match(player_strokes, next_player_strokes)
		and _character_states_match(character_states, next_character_states)
		and _character_actions_match(character_actions, next_character_actions)
		and _character_troops_match(character_troops, next_character_troops)
		and _camera_states_match(current_camera, next_camera)
		and str(source_metadata.get("sandbox_id", "")) == str(sandbox_metadata.get("sandbox_id", ""))
	):
		return {"ok": true, "unchanged": true}
	var next_metadata := _branch_metadata_from(source_metadata, snapshot_id)
	var backup_result := _create_internal_backup("快照恢复前")
	if not bool(backup_result.get("ok", false)):
		return {"ok": false, "message": "无法为当前沙盘创建安全备份，本次恢复已取消。\n\n%s" % str(backup_result.get("message", ""))}
	var write_result := _write_validated_sandbox_payload_atomic(
		save_path,
		_build_sandbox_payload_for(next_placements, next_annotations, next_camera, next_metadata, next_scenario_state, next_chronicle_entries, next_player_strokes, next_character_states, next_character_actions, next_character_troops),
		true
	)
	if not bool(write_result.get("ok", false)):
		return {"ok": false, "message": "新分支无法安全写入，本次恢复已取消；原沙盘和安全备份均已保留。\n\n%s" % str(write_result.get("message", "")), "backup_path": str(backup_result.get("path", ""))}
	_push_history_snapshot("恢复命名快照", true, true)
	_redo_stack.clear()
	placements = next_placements
	annotations = next_annotations
	sandbox_metadata = next_metadata
	scenario_state = next_scenario_state
	chronicle_entries = next_chronicle_entries
	player_strokes = next_player_strokes
	character_states = next_character_states
	character_actions = next_character_actions
	character_troops = next_character_troops
	loaded_camera = next_camera.duplicate(true)
	_clear_hand_candidates_for_new_sandbox()
	_recalculate_next_annotation_serial()
	_refresh_views()
	_refresh_sandbox_identity_view()
	if map_board != null:
		map_board.set_camera_state(next_camera)
	_update_history_buttons()
	return {"ok": true, "backup_path": str(backup_result.get("path", "")), "metadata": next_metadata.duplicate(true)}


func _clear_hand_candidates_for_new_sandbox() -> void:
	# “手边”模拟现实桌面上临时拿出的卡，不属于任何沙盘存档。
	# 只有成功换入另一份局面后才清空；失败、撤销/重做与普通保存均不触碰它。
	if backpack != null:
		backpack.clear_hand_candidates()


func _commit_sandbox_metadata(next_metadata: Dictionary, action_label: String, status_text: String) -> bool:
	if _sandbox_metadata_match(sandbox_metadata, next_metadata):
		return false
	var camera := map_board.get_camera_state() if map_board != null else loaded_camera
	var write_result := _write_runtime_state(placements, annotations, camera, next_metadata)
	if not bool(write_result.get("ok", false)):
		_set_status("沙盘信息未更新：无法安全保存")
		return false
	_push_history_snapshot(action_label, true)
	_redo_stack.clear()
	sandbox_metadata = next_metadata.duplicate(true)
	_refresh_sandbox_identity_view()
	_set_status(status_text)
	_update_history_buttons()
	return true


func _push_history_snapshot(action_label: String, include_metadata := false, include_camera := false, include_scenario := false, include_chronicle := false) -> void:
	var snapshot := {
		"label": action_label,
		"placements": placements.duplicate(true),
		"annotations": annotations.duplicate(true),
		"player_strokes": player_strokes.duplicate(true),
		"character_states": character_states.duplicate(true),
		"character_actions": character_actions.duplicate(true),
		"character_troops": character_troops.duplicate(true)
	}
	if include_metadata:
		snapshot["metadata"] = sandbox_metadata.duplicate(true)
	if include_metadata or include_scenario:
		snapshot["scenario_state"] = scenario_state.duplicate(true)
	if include_metadata or include_chronicle:
		snapshot["chronicle_entries"] = chronicle_entries.duplicate(true)
	if include_camera and map_board != null:
		snapshot["camera"] = map_board.get_camera_state()
	_undo_stack.append(snapshot)
	if _undo_stack.size() > HISTORY_LIMIT:
		_undo_stack.pop_front()


func _show_message(title_text: String, body_text: String) -> void:
	if message_dialog == null:
		push_error("%s：%s" % [title_text, body_text])
		return
	message_dialog.title = title_text
	message_dialog.dialog_text = body_text
	message_dialog.popup_centered(Vector2i(470, 210))
	call_deferred("_focus_message_dialog_ok")


func _focus_message_dialog_ok() -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	await get_tree().process_frame
	if not is_inside_tree() or is_queued_for_deletion():
		return
	if is_instance_valid(message_dialog) and message_dialog.is_inside_tree() and message_dialog.visible:
		message_dialog.get_ok_button().grab_focus()


func _on_clear_pressed() -> void:
	if placements.is_empty():
		_set_status("地图上已经没有人物；标记与推演线仍保留")
		return
	_commit_placements({}, "收回全部人物", "人物已全部收回背包，标记与推演线已保留 · 可撤销")


func _commit_placements(next_value: Dictionary, action_label: String, status_text: String) -> bool:
	return _commit_sandbox_state(next_value, annotations, action_label, status_text)


func _commit_annotations(next_value: Dictionary, action_label: String, status_text: String) -> bool:
	return _commit_sandbox_state(placements, next_value, action_label, status_text)


func _commit_scenario_state(next_value: Dictionary, action_label: String, status_text: String) -> bool:
	var validation := _decode_scenario_state(next_value)
	if not bool(validation.get("ok", false)):
		_set_status("玩法分组未更新：%s" % str(validation.get("message", "分组数据无效")))
		return false
	var decoded: Dictionary = validation.get("scenario_state", {}).duplicate(true)
	if _scenario_states_match(scenario_state, decoded):
		return false
	var camera := map_board.get_camera_state() if map_board != null else loaded_camera
	var write_result := _write_runtime_state(placements, annotations, camera, sandbox_metadata, decoded)
	if not bool(write_result.get("ok", false)):
		_set_status("玩法分组未更新：无法安全保存沙盘")
		if not automated_test_mode:
			push_error(str(write_result.get("message", "无法写入沙盘。")))
		return false
	_push_history_snapshot(action_label, false, false, true)
	_redo_stack.clear()
	scenario_state = decoded
	if map_board != null:
		map_board.set_scenario_state(scenario_state)
	_sync_city_ownership_tool_after_scenario_change()
	_refresh_sandbox_identity_view()
	_set_status(status_text)
	_update_history_buttons()
	return true


func _commit_character_states(next_value: Dictionary, action_label: String, status_text: String) -> bool:
	var validation := _decode_character_states(_character_states_payload_for(next_value))
	if not bool(validation.get("ok", false)):
		_set_status("本局属性未更新：%s" % str(validation.get("message", "属性数据无效")))
		return false
	var decoded: Dictionary = validation.get("character_states", {}).duplicate(true)
	if _character_states_match(character_states, decoded):
		_set_status("本局属性没有变化")
		return false
	var camera := map_board.get_camera_state() if map_board != null else loaded_camera
	var write_result := _write_runtime_state(
		placements,
		annotations,
		camera,
		sandbox_metadata,
		scenario_state,
		chronicle_entries,
		player_strokes,
		decoded
	)
	if not bool(write_result.get("ok", false)):
		_set_status("本局属性未更新：无法安全保存沙盘")
		if not automated_test_mode:
			push_error(str(write_result.get("message", "无法写入沙盘。")))
		return false
	_push_history_snapshot(action_label)
	_redo_stack.clear()
	character_states = decoded
	_refresh_views()
	_refresh_sandbox_identity_view()
	_set_status(status_text)
	_update_history_buttons()
	return true


func _commit_character_actions(next_value: Dictionary, action_label: String, status_text: String) -> bool:
	var validation := _decode_character_actions(_character_actions_payload_for(next_value))
	if not bool(validation.get("ok", false)):
		_set_status("人物行动未更新：%s" % str(validation.get("message", "行动状态无效")))
		return false
	var decoded: Dictionary = validation.get("character_actions", {}).duplicate(true)
	if _character_actions_match(character_actions, decoded):
		_set_status("人物行动没有变化")
		return false
	var camera := map_board.get_camera_state() if map_board != null else loaded_camera
	var write_result := _write_runtime_state(
		placements,
		annotations,
		camera,
		sandbox_metadata,
		scenario_state,
		chronicle_entries,
		player_strokes,
		character_states,
		decoded
	)
	if not bool(write_result.get("ok", false)):
		_set_status("人物行动未更新：无法安全保存沙盘")
		if not automated_test_mode:
			push_error(str(write_result.get("message", "无法写入沙盘。")))
		return false
	_push_history_snapshot(action_label)
	_redo_stack.clear()
	character_actions = decoded
	_refresh_views()
	_refresh_sandbox_identity_view()
	_set_status(status_text)
	_update_history_buttons()
	return true


func _commit_character_troops(next_value: Dictionary, action_label: String, status_text: String) -> bool:
	var validation := _decode_character_troops(_character_troops_payload_for(next_value))
	if not bool(validation.get("ok", false)):
		_set_status("人物兵力未更新：%s" % str(validation.get("message", "兵力数据无效")))
		return false
	var decoded: Dictionary = validation.get("character_troops", {}).duplicate(true)
	if _character_troops_match(character_troops, decoded):
		_set_status("人物兵力没有变化")
		return false
	var camera := map_board.get_camera_state() if map_board != null else loaded_camera
	var write_result := _write_runtime_state(
		placements,
		annotations,
		camera,
		sandbox_metadata,
		scenario_state,
		chronicle_entries,
		player_strokes,
		character_states,
		character_actions,
		decoded
	)
	if not bool(write_result.get("ok", false)):
		_set_status("人物兵力未更新：无法安全保存沙盘")
		if not automated_test_mode:
			push_error(str(write_result.get("message", "无法写入沙盘。")))
		return false
	_push_history_snapshot(action_label)
	_redo_stack.clear()
	character_troops = decoded
	_refresh_views()
	_refresh_sandbox_identity_view()
	_set_status(status_text)
	_update_history_buttons()
	return true


func _commit_chronicle_entries(next_value: Array, action_label: String, status_text: String) -> bool:
	var validation := _decode_chronicle(_chronicle_payload_for(next_value))
	if not bool(validation.get("ok", false)):
		_set_status("玩家纪事未更新：%s" % str(validation.get("message", "纪事数据无效")))
		return false
	var decoded: Array[Dictionary] = (validation.get("chronicle_entries", []) as Array).duplicate(true)
	if _chronicle_entries_match(chronicle_entries, decoded):
		return false
	var camera := map_board.get_camera_state() if map_board != null else loaded_camera
	var write_result := _write_runtime_state(placements, annotations, camera, sandbox_metadata, scenario_state, decoded)
	if not bool(write_result.get("ok", false)):
		_set_status("玩家纪事未更新：无法安全保存沙盘")
		if not automated_test_mode:
			push_error(str(write_result.get("message", "无法写入沙盘。")))
		return false
	_push_history_snapshot(action_label, false, false, false, true)
	_redo_stack.clear()
	chronicle_entries = decoded
	_refresh_sandbox_identity_view()
	if chronicle_dialog != null and chronicle_dialog.visible:
		_refresh_chronicle_dialog(_pending_chronicle_id)
	_set_status(status_text)
	_update_history_buttons()
	return true


func _commit_player_strokes(next_value: Array, action_label: String, status_text: String) -> bool:
	# 内部编辑候选也必须先按原始结构严格校验，不能借序列化过程跳过坏记录或补默认坐标。
	var validation := _decode_player_strokes({
		"semantic_layer": PLAYER_STROKE_SEMANTIC_LAYER,
		"verification_status": PLAYER_STROKE_VERIFICATION_STATUS,
		"strokes": next_value.duplicate(true)
	})
	if not bool(validation.get("ok", false)):
		_set_status("玩家推演线未更新：%s" % str(validation.get("message", "画线数据无效")))
		return false
	var decoded: Array[Dictionary] = (validation.get("player_strokes", []) as Array).duplicate(true)
	if _player_strokes_match(player_strokes, decoded):
		return false
	var camera := map_board.get_camera_state() if map_board != null else loaded_camera
	var write_result := _write_runtime_state(placements, annotations, camera, sandbox_metadata, scenario_state, chronicle_entries, decoded)
	if not bool(write_result.get("ok", false)):
		_set_status("玩家推演线未更新：无法安全保存沙盘")
		if not automated_test_mode:
			push_error(str(write_result.get("message", "无法写入沙盘。")))
		return false
	_push_history_snapshot(action_label)
	_redo_stack.clear()
	player_strokes = decoded
	_refresh_views()
	_refresh_sandbox_identity_view()
	_set_status(status_text)
	_update_history_buttons()
	return true


func _commit_sandbox_state(next_placements: Dictionary, next_annotations: Dictionary, action_label: String, status_text: String) -> bool:
	if _placements_match(placements, next_placements) and _annotations_match(annotations, next_annotations):
		return false
	var camera := map_board.get_camera_state() if map_board != null else loaded_camera
	var write_result := _write_runtime_state(next_placements, next_annotations, camera)
	if not bool(write_result.get("ok", false)):
		_set_status("操作未应用：无法安全保存沙盘")
		if not automated_test_mode:
			push_error(str(write_result.get("message", "无法写入沙盘。")))
		return false
	_push_history_snapshot(action_label)
	_redo_stack.clear()
	placements = next_placements.duplicate(true)
	annotations = next_annotations.duplicate(true)
	_refresh_views()
	_set_status(status_text)
	_update_history_buttons()
	return true


func _on_undo_pressed() -> void:
	if _undo_stack.is_empty():
		return
	var snapshot: Dictionary = _undo_stack.back()
	var action_label := str(snapshot.get("label", "上一步"))
	var target_camera := map_board.get_camera_state() if map_board != null else loaded_camera
	if snapshot.has("camera"):
		target_camera = snapshot.get("camera", {}).duplicate(true)
	var target_metadata: Dictionary = snapshot.get("metadata", sandbox_metadata).duplicate(true)
	var target_scenario_state: Dictionary = snapshot.get("scenario_state", scenario_state).duplicate(true)
	var target_chronicle_entries: Array[Dictionary] = (snapshot.get("chronicle_entries", chronicle_entries) as Array).duplicate(true)
	var target_player_strokes: Array[Dictionary] = (snapshot.get("player_strokes", player_strokes) as Array).duplicate(true)
	var target_character_states: Dictionary = snapshot.get("character_states", character_states).duplicate(true)
	var target_character_actions: Dictionary = snapshot.get("character_actions", character_actions).duplicate(true)
	var target_character_troops: Dictionary = snapshot.get("character_troops", character_troops).duplicate(true)
	var write_result := _write_runtime_state(snapshot.get("placements", {}), snapshot.get("annotations", {}), target_camera, target_metadata, target_scenario_state, target_chronicle_entries, target_player_strokes, target_character_states, target_character_actions, target_character_troops)
	if not bool(write_result.get("ok", false)):
		_set_status("撤销未执行：无法安全保存沙盘")
		return
	_undo_stack.pop_back()
	var redo_snapshot := {
		"label": action_label,
		"placements": placements.duplicate(true),
		"annotations": annotations.duplicate(true),
		"player_strokes": player_strokes.duplicate(true),
		"character_states": character_states.duplicate(true),
		"character_actions": character_actions.duplicate(true),
		"character_troops": character_troops.duplicate(true)
	}
	if snapshot.has("camera") and map_board != null:
		redo_snapshot["camera"] = map_board.get_camera_state()
	if snapshot.has("metadata"):
		redo_snapshot["metadata"] = sandbox_metadata.duplicate(true)
	if snapshot.has("scenario_state"):
		redo_snapshot["scenario_state"] = scenario_state.duplicate(true)
	if snapshot.has("chronicle_entries"):
		redo_snapshot["chronicle_entries"] = chronicle_entries.duplicate(true)
	_redo_stack.append(redo_snapshot)
	_apply_history_snapshot(snapshot)
	_set_status("已撤销：%s" % action_label)


func _on_redo_pressed() -> void:
	if _redo_stack.is_empty():
		return
	var snapshot: Dictionary = _redo_stack.back()
	var action_label := str(snapshot.get("label", "下一步"))
	var target_camera := map_board.get_camera_state() if map_board != null else loaded_camera
	if snapshot.has("camera"):
		target_camera = snapshot.get("camera", {}).duplicate(true)
	var target_metadata: Dictionary = snapshot.get("metadata", sandbox_metadata).duplicate(true)
	var target_scenario_state: Dictionary = snapshot.get("scenario_state", scenario_state).duplicate(true)
	var target_chronicle_entries: Array[Dictionary] = (snapshot.get("chronicle_entries", chronicle_entries) as Array).duplicate(true)
	var target_player_strokes: Array[Dictionary] = (snapshot.get("player_strokes", player_strokes) as Array).duplicate(true)
	var target_character_states: Dictionary = snapshot.get("character_states", character_states).duplicate(true)
	var target_character_actions: Dictionary = snapshot.get("character_actions", character_actions).duplicate(true)
	var target_character_troops: Dictionary = snapshot.get("character_troops", character_troops).duplicate(true)
	var write_result := _write_runtime_state(snapshot.get("placements", {}), snapshot.get("annotations", {}), target_camera, target_metadata, target_scenario_state, target_chronicle_entries, target_player_strokes, target_character_states, target_character_actions, target_character_troops)
	if not bool(write_result.get("ok", false)):
		_set_status("重做未执行：无法安全保存沙盘")
		return
	_redo_stack.pop_back()
	var undo_snapshot := {
		"label": action_label,
		"placements": placements.duplicate(true),
		"annotations": annotations.duplicate(true),
		"player_strokes": player_strokes.duplicate(true),
		"character_states": character_states.duplicate(true),
		"character_actions": character_actions.duplicate(true),
		"character_troops": character_troops.duplicate(true)
	}
	if snapshot.has("camera") and map_board != null:
		undo_snapshot["camera"] = map_board.get_camera_state()
	if snapshot.has("metadata"):
		undo_snapshot["metadata"] = sandbox_metadata.duplicate(true)
	if snapshot.has("scenario_state"):
		undo_snapshot["scenario_state"] = scenario_state.duplicate(true)
	if snapshot.has("chronicle_entries"):
		undo_snapshot["chronicle_entries"] = chronicle_entries.duplicate(true)
	_undo_stack.append(undo_snapshot)
	_apply_history_snapshot(snapshot)
	_set_status("已重做：%s" % action_label)


func _apply_history_snapshot(snapshot_value: Dictionary) -> void:
	placements = snapshot_value.get("placements", {}).duplicate(true)
	annotations = snapshot_value.get("annotations", {}).duplicate(true)
	if snapshot_value.has("metadata"):
		sandbox_metadata = snapshot_value.get("metadata", {}).duplicate(true)
	if snapshot_value.has("scenario_state"):
		scenario_state = snapshot_value.get("scenario_state", _empty_scenario_state()).duplicate(true)
	if snapshot_value.has("chronicle_entries"):
		chronicle_entries = (snapshot_value.get("chronicle_entries", []) as Array).duplicate(true)
	if snapshot_value.has("player_strokes"):
		player_strokes = (snapshot_value.get("player_strokes", []) as Array).duplicate(true)
	if snapshot_value.has("character_states"):
		character_states = snapshot_value.get("character_states", {}).duplicate(true)
	if snapshot_value.has("character_actions"):
		character_actions = snapshot_value.get("character_actions", {}).duplicate(true)
	if snapshot_value.has("character_troops"):
		character_troops = snapshot_value.get("character_troops", {}).duplicate(true)
	_recalculate_next_annotation_serial()
	_refresh_views()
	_refresh_sandbox_identity_view()
	if chronicle_dialog != null and chronicle_dialog.visible:
		_refresh_chronicle_dialog(_pending_chronicle_id)
	if snapshot_value.has("camera") and map_board != null:
		map_board.set_camera_state(snapshot_value.get("camera", {}))
	_update_history_buttons()


func _update_history_buttons() -> void:
	if undo_button != null:
		undo_button.disabled = _undo_stack.is_empty()
		undo_button.tooltip_text = "暂无可撤销操作 · Ctrl+Z" if _undo_stack.is_empty() else "撤销：%s · Ctrl+Z" % str(_undo_stack.back().get("label", "上一步"))
	if redo_button != null:
		redo_button.disabled = _redo_stack.is_empty()
		redo_button.tooltip_text = "暂无可重做操作 · Ctrl+Y / Ctrl+Shift+Z" if _redo_stack.is_empty() else "重做：%s · Ctrl+Y / Ctrl+Shift+Z" % str(_redo_stack.back().get("label", "下一步"))
	_refresh_city_ownership_tool_ui()


func _placements_match(first: Dictionary, second: Dictionary) -> bool:
	if first.size() != second.size():
		return false
	for character_id in first:
		if not second.has(character_id):
			return false
		var first_position: Dictionary = first[character_id]
		var second_position: Dictionary = second[character_id]
		if not is_equal_approx(float(first_position.get("x", 0.5)), float(second_position.get("x", 0.5))):
			return false
		if not is_equal_approx(float(first_position.get("y", 0.5)), float(second_position.get("y", 0.5))):
			return false
		if str(first_position.get("place_id", "")) != str(second_position.get("place_id", "")):
			return false
	return true


func _annotations_match(first: Dictionary, second: Dictionary) -> bool:
	if first.size() != second.size():
		return false
	for annotation_id in first:
		if not second.has(annotation_id):
			return false
		var first_value: Dictionary = first[annotation_id]
		var second_value: Dictionary = second[annotation_id]
		if str(first_value.get("kind", "marker")) != str(second_value.get("kind", "marker")):
			return false
		if str(first_value.get("marker_type", "note")) != str(second_value.get("marker_type", "note")):
			return false
		if str(first_value.get("semantic_layer", ANNOTATION_SEMANTIC_LAYER)) != str(second_value.get("semantic_layer", ANNOTATION_SEMANTIC_LAYER)):
			return false
		if str(first_value.get("verification_status", ANNOTATION_VERIFICATION_STATUS)) != str(second_value.get("verification_status", ANNOTATION_VERIFICATION_STATUS)):
			return false
		if str(first_value.get("label", "")) != str(second_value.get("label", "")):
			return false
		if str(first_value.get("style", "amber")) != str(second_value.get("style", "amber")):
			return false
		if str(first_value.get("faction_id", "")) != str(second_value.get("faction_id", "")):
			return false
		if not is_equal_approx(float(first_value.get("x", 0.5)), float(second_value.get("x", 0.5))):
			return false
		if not is_equal_approx(float(first_value.get("y", 0.5)), float(second_value.get("y", 0.5))):
			return false
	return true


func _find_place(place_id: String) -> Dictionary:
	if place_id.is_empty():
		return {}
	for place in places:
		if str(place.get("id", "")) == place_id:
			return place
	return {}


func _find_character_record(character_id: String) -> Dictionary:
	if character_id.is_empty():
		return {}
	for character_value in characters:
		if character_value is Dictionary and str((character_value as Dictionary).get("id", "")) == character_id:
			return (character_value as Dictionary)
	return {}


func _character_profile_source_text(profile: Dictionary) -> String:
	var source_titles := PackedStringArray()
	for source_ref_value in profile.get("source_refs", []):
		var source_ref := str(source_ref_value).strip_edges()
		if not character_profile_sources_by_id.has(source_ref):
			continue
		var source: Dictionary = character_profile_sources_by_id[source_ref]
		var citation_title := str(source.get("citation_title", "")).strip_edges()
		if not citation_title.is_empty() and citation_title not in source_titles:
			source_titles.append(citation_title)
	if source_titles.is_empty():
		return ""
	return "据%s整理" % "、".join(source_titles)


func _character_affiliation_text(character: Dictionary) -> String:
	var affiliation_lines := PackedStringArray()
	for affiliation_value in character.get("affiliations", []):
		if not (affiliation_value is Dictionary):
			continue
		var affiliation: Dictionary = affiliation_value
		var period: Dictionary = affiliation.get("period", {})
		var start_year := int(period.get("start_year", 0))
		var end_year := int(period.get("end_year", start_year))
		var year_text := "年代待核"
		if start_year > 0 and end_year > start_year:
			year_text = "%d—%d 年" % [start_year, end_year]
		elif start_year > 0:
			year_text = "%d 年" % start_year
		var position_title := str(affiliation.get("position_title", "")).strip_edges()
		if position_title.is_empty():
			position_title = "已录入关系"
		var layer_suffix := "" if str(affiliation.get("layer", "")) == "historical" else "（演义）"
		affiliation_lines.append("%s：%s%s" % [year_text, position_title, layer_suffix])
	if affiliation_lines.is_empty():
		return "尚未录入可显示的史料关系"
	return "\n".join(affiliation_lines)


func _resolve_place_detail(place_id: String) -> Dictionary:
	var place := _find_place(place_id)
	if place.is_empty():
		return {"ok": false, "message": "找不到这个地点。"}
	var warnings: Array[String] = []
	if not map_source_load_error.is_empty():
		warnings.append(map_source_load_error)
	var primary_source: Dictionary = {}
	var source_ref := str(place.get("source_ref", "")).strip_edges()
	if source_ref.is_empty():
		warnings.append("这个地点尚未登记主定位来源。")
	elif map_sources_by_id.has(source_ref):
		primary_source = (map_sources_by_id[source_ref] as Dictionary).duplicate(true)
	else:
		warnings.append("主定位来源登记缺失：%s。" % source_ref)
	var crosscheck_source: Dictionary = {}
	var crosscheck_ref := str(place.get("crosscheck_ref", "")).strip_edges()
	if not crosscheck_ref.is_empty():
		if map_sources_by_id.has(crosscheck_ref):
			crosscheck_source = (map_sources_by_id[crosscheck_ref] as Dictionary).duplicate(true)
		else:
			warnings.append("交叉核对来源登记缺失：%s。" % crosscheck_ref)
	var resolved_period_contexts: Array[Dictionary] = []
	var seen_period_context_refs := {}
	for context_ref_value in place.get("period_context_refs", []):
		var context_ref := str(context_ref_value).strip_edges()
		if context_ref.is_empty() or seen_period_context_refs.has(context_ref):
			continue
		seen_period_context_refs[context_ref] = true
		var resolved_context := _resolve_historical_context_detail(context_ref)
		if not bool(resolved_context.get("ok", false)):
			warnings.append("年代依据登记缺失：%s。" % context_ref)
			continue
		resolved_period_contexts.append({
			"record": (resolved_context.get("record", {}) as Dictionary).duplicate(true),
			"resolved_evidence": (resolved_context.get("resolved_evidence", []) as Array).duplicate(true)
		})
		for context_warning_value in resolved_context.get("warnings", []):
			var context_warning := str(context_warning_value).strip_edges()
			if not context_warning.is_empty() and context_warning not in warnings:
				warnings.append(context_warning)
	return {
		"ok": true,
		"place": place.duplicate(true),
		"primary_source": primary_source,
		"crosscheck_source": crosscheck_source,
		"resolved_period_contexts": resolved_period_contexts,
		"warnings": warnings
	}


func _on_place_details_requested(place_id: String) -> void:
	if city_ownership_tool_active:
		_on_city_ownership_place_requested(place_id)
		return
	if place_detail_panel != null and place_detail_panel.visible and current_place_detail_id == place_id:
		_close_place_detail_panel()
		return
	_open_place_detail_panel(place_id)


func _connected_place_ids(place_id: String) -> Array[String]:
	var result: Array[String] = []
	var seen := {}
	for route_value in routes:
		if not (route_value is Dictionary):
			continue
		var route: Dictionary = route_value
		var connected_id := ""
		if str(route.get("from", "")) == place_id:
			connected_id = str(route.get("to", ""))
		elif str(route.get("to", "")) == place_id:
			connected_id = str(route.get("from", ""))
		if connected_id.is_empty() or connected_id == place_id or seen.has(connected_id):
			continue
		if _find_place(connected_id).is_empty():
			continue
		seen[connected_id] = true
		result.append(connected_id)
	return result


func _place_connections_bbcode(place_id: String) -> String:
	var connected_ids := _connected_place_ids(place_id)
	var heading := "[color=#%s][font_size=15][b]沙盘相连[/b][/font_size][/color]" % UiThemeScript.RICH_HEADING_HEX
	if connected_ids.is_empty():
		return "%s\n[color=#%s][font_size=14]当前没有相连地点。[/font_size][/color]" % [heading, UiThemeScript.RICH_BODY_HEX]
	var links: Array[String] = []
	for connected_id in connected_ids:
		var place := _find_place(connected_id)
		links.append("[url=place:%s][color=#7B5A1D][u]%s[/u][/color][/url]" % [
			connected_id,
			_bbcode_escape(str(place.get("name", connected_id)))
		])
	return "%s\n[font_size=14]%s[/font_size]\n[color=#6F6A58][font_size=12]点击地名直接定位，也可用上方“逐个定位”顺看。[/font_size][/color]" % [
		heading,
		"　".join(links)
	]


func _on_place_detail_meta_clicked(meta: Variant) -> void:
	var meta_text := str(meta)
	if meta_text.begins_with("character:"):
		_focus_stationed_character_from_place_detail(meta_text.trim_prefix("character:"))
		return
	if not meta_text.begins_with("place:") or current_place_detail_id.is_empty():
		return
	var target_place_id := meta_text.trim_prefix("place:")
	var connected_index := current_place_connection_ids.find(target_place_id)
	if connected_index < 0:
		return
	_place_connection_cycle_index = connected_index + 1
	_focus_place_from_detail(target_place_id, _place_connection_cycle_index, current_place_connection_ids.size() + 1)


func _on_place_detail_meta_hover_started(meta: Variant) -> void:
	if map_board == null or not place_detail_panel.visible or current_place_detail_id.is_empty():
		return
	var meta_text := str(meta)
	if not meta_text.begins_with("place:"):
		return
	var target_place_id := meta_text.trim_prefix("place:")
	if current_place_connection_ids.has(target_place_id):
		map_board.set_place_relation_hover_target(target_place_id)


func _on_place_detail_meta_hover_ended(meta: Variant) -> void:
	if map_board == null:
		return
	var meta_text := str(meta)
	if not meta_text.begins_with("place:"):
		return
	map_board.clear_place_relation_hover_target(meta_text.trim_prefix("place:"))


func _find_historical_context_record(context_id: String) -> Dictionary:
	for layer_value in historical_context_layers:
		for record_value in layer_value.get("records", []):
			if record_value is Dictionary and str(record_value.get("id", "")) == context_id:
				return (record_value as Dictionary).duplicate(true)
	return {}


func _historical_context_layer_id_for_record(context_id: String) -> String:
	for layer_value in historical_context_layers:
		for record_value in layer_value.get("records", []):
			if record_value is Dictionary and str(record_value.get("id", "")) == context_id:
				return str(layer_value.get("id", ""))
	return ""


func _resolve_historical_context_detail(context_id: String) -> Dictionary:
	var record := _find_historical_context_record(context_id)
	if record.is_empty():
		return {"ok": false, "message": "找不到这条历史背景线索。"}
	var warnings: Array[String] = []
	if not historical_context_load_error.is_empty():
		warnings.append(historical_context_load_error)
	var resolved_evidence: Array[Dictionary] = []
	for evidence_value in record.get("evidence", []):
		if not (evidence_value is Dictionary):
			continue
		var evidence: Dictionary = evidence_value
		var source_ref := str(evidence.get("source_ref", "")).strip_edges()
		var source: Dictionary = {}
		if historical_context_sources_by_id.has(source_ref):
			source = (historical_context_sources_by_id[source_ref] as Dictionary).duplicate(true)
		else:
			warnings.append("固定版本来源登记缺失：%s。" % source_ref)
		resolved_evidence.append({"evidence": evidence.duplicate(true), "source": source})
	return {"ok": true, "record": record, "resolved_evidence": resolved_evidence, "warnings": warnings}


func _on_historical_context_details_requested(context_id: String) -> void:
	if place_detail_panel != null and place_detail_panel.visible and current_historical_context_detail_id == context_id:
		_close_place_detail_panel()
		return
	_open_historical_context_detail_panel(context_id)


func _open_historical_context_detail_panel(context_id: String) -> void:
	var layer_id := _historical_context_layer_id_for_record(context_id)
	if place_detail_panel == null or map_board == null or layer_id.is_empty() or not map_board.is_historical_context_layer_visible(layer_id):
		return
	map_board.clear_faction_inspection_highlight()
	map_board.clear_place_relation_highlight()
	map_board._hide_place_hover()
	var resolved := _resolve_historical_context_detail(context_id)
	if not bool(resolved.get("ok", false)):
		_set_status(str(resolved.get("message", "历史背景资料卡暂时无法打开。")))
		return
	var record: Dictionary = resolved.get("record", {})
	_place_detail_return_ids.clear()
	current_place_detail_id = ""
	current_place_connection_ids.clear()
	_place_connection_cycle_index = -1
	current_faction_detail_id = ""
	current_historical_context_detail_id = context_id
	current_detail_anchor_place_id = str(record.get("anchor_place_id", ""))
	_configure_context_inspector_mode("historical")
	place_detail_title_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	var is_romance := str(record.get("layer", "")) == "romance"
	var anchor_place := _find_place(current_detail_anchor_place_id)
	var anchor_name := str(anchor_place.get("name", current_detail_anchor_place_id))
	place_detail_title_label.text = str(record.get("title", record.get("label", "历史背景")))
	place_detail_historical_label.text = "%s　·　%s" % [
		_historical_context_date_text(record),
		"演义叙事" if is_romance else "正史记载"
	]
	place_detail_tags_label.text = "关联地点：%s" % anchor_name
	place_detail_scroll_hint_label.text = "向下滚动查看背景内容"
	place_detail_scroll_hint_label.tooltip_text = "资料卡标题保持固定，只有下方正文滚动"
	var body_sections: Array[String] = []
	body_sections.append("[color=#%s][font_size=15]%s[/font_size][/color]" % [
		UiThemeScript.RICH_BODY_HEX,
		_bbcode_escape(str(record.get("summary", "这条背景线索尚待补充摘要。")))
	])
	place_detail_body.text = "\n\n".join(body_sections)
	place_detail_body.scroll_to_line(0)
	place_detail_host.show()
	place_detail_panel.show()
	map_board.set_faction_influence_legend_context_suppressed(true)
	_position_current_place_detail_panel()
	call_deferred("_position_current_place_detail_panel")
	_set_status("正在查看%s" % place_detail_title_label.text)


func _open_place_detail_panel(place_id: String, preserve_relation_history: bool = false) -> void:
	if place_detail_panel == null:
		return
	var resolved := _resolve_place_detail(place_id)
	if not bool(resolved.get("ok", false)):
		_set_status(str(resolved.get("message", "地点札记暂时无法打开。")))
		return
	var place: Dictionary = resolved.get("place", {})
	var connected_place_ids := _connected_place_ids(place_id)
	if not preserve_relation_history:
		_place_detail_return_ids.clear()
	if map_board != null:
		map_board.clear_faction_inspection_highlight()
		map_board.clear_place_relation_highlight()
		map_board._hide_place_hover()
	current_place_detail_id = place_id
	current_place_connection_ids = connected_place_ids
	_place_connection_cycle_index = -1
	current_faction_detail_id = ""
	current_historical_context_detail_id = ""
	current_detail_anchor_place_id = place_id
	_configure_context_inspector_mode("city")
	place_detail_title_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	place_detail_title_label.text = str(place.get("name", "地点札记"))
	_refresh_place_detail_chronicle_action()
	place_detail_historical_label.text = str(place.get("historical_name_190", place_detail_title_label.text))
	var owner_id := _scenario_city_owner_id(place_id)
	var owner := _scenario_faction_record(owner_id)
	var owner_name := str(owner.get("name", "无归属")) if not owner.is_empty() else "无归属"
	place_detail_tags_label.text = "%s　·　可驻扎人物　·　%s　·　%s" % [
		_place_detail_type_text(str(place.get("type", "city"))),
		_current_scenario_context_contract().get("label", "完全自定义"),
		owner_name
	]
	_configure_place_ownership_editor(place)
	place_detail_scroll_hint_label.text = "向下滚动查看人物、相连地点与背景"
	place_detail_scroll_hint_label.tooltip_text = "城池归属记录本局局势；战果由玩家裁定"
	var period_note := str(place.get("period_note", "")).strip_edges()
	if period_note.is_empty():
		period_note = "约 190 年称谓：%s。" % str(place.get("historical_name_190", place_detail_title_label.text))
	var body_sections: Array[String] = []
	body_sections.append("[color=#%s][font_size=15]%s[/font_size][/color]" % [
		UiThemeScript.RICH_BODY_HEX,
		_bbcode_escape(_place_detail_player_summary(place))
	])
	body_sections.append(_place_detail_bbcode_section("驻扎人物", _place_stationed_characters_text(place_id), "#%s" % UiThemeScript.RICH_BODY_HEX, true))
	body_sections.append(_place_connections_bbcode(place_id))
	body_sections.append(_place_detail_bbcode_section("历史与推演", period_note, "#%s" % UiThemeScript.RICH_BODY_HEX))
	var resolved_period_contexts: Array = resolved.get("resolved_period_contexts", [])
	if not resolved_period_contexts.is_empty():
		body_sections.append(_place_detail_bbcode_section("相关年代", _place_period_context_text(resolved_period_contexts), "#%s" % UiThemeScript.RICH_BODY_HEX))
	place_detail_body.text = "\n\n".join(body_sections)
	place_detail_body.scroll_to_line(0)
	if map_board != null:
		map_board.set_place_relation_context(place_id, current_place_connection_ids)
	place_detail_host.show()
	place_detail_panel.show()
	map_board.set_faction_influence_legend_context_suppressed(true)
	_position_current_place_detail_panel()
	call_deferred("_position_current_place_detail_panel")
	_set_status("正在查看%s地点札记" % place_detail_title_label.text)


func _configure_context_inspector_mode(mode: String) -> void:
	var city_mode := mode == "city"
	var faction_mode := mode == "faction"
	place_detail_chronicle_button.visible = city_mode
	place_detail_ownership_row.visible = city_mode
	place_detail_action_row.visible = city_mode or faction_mode
	place_detail_locate_button.visible = city_mode or faction_mode
	place_detail_note_button.visible = city_mode
	place_detail_faction_button.visible = city_mode or faction_mode
	place_detail_edit_faction_button.visible = city_mode or faction_mode
	if city_mode:
		_refresh_place_detail_relation_navigation()
	else:
		place_detail_relation_navigation_row.hide()
	if city_mode:
		place_detail_locate_button.text = "定位" if current_place_connection_ids.is_empty() else "逐个定位"
		place_detail_locate_button.tooltip_text = (
			"把这座城市带到当前视野"
			if current_place_connection_ids.is_empty()
			else "依次定位当前地点与相连地点"
		)
		place_detail_faction_button.text = "查看势力"
		place_detail_faction_button.tooltip_text = "切换到当前归属势力的上下文"
	elif faction_mode:
		place_detail_locate_button.text = "下座城"
		place_detail_locate_button.tooltip_text = "依次定位这个势力当前记录的城池"
		place_detail_faction_button.text = "下个人"
		place_detail_faction_button.tooltip_text = "依次定位这个势力当前放在地图上的人物"


func _refresh_place_detail_chronicle_action() -> void:
	if place_detail_chronicle_button == null:
		return
	var place := _find_place(current_place_detail_id)
	var at_limit := chronicle_entries.size() >= CHRONICLE_ENTRY_LIMIT
	place_detail_chronicle_button.disabled = place.is_empty() or at_limit
	if at_limit:
		place_detail_chronicle_button.tooltip_text = "玩家纪事已达到 %d 则上限；可在纪事管理器中编辑或删除" % CHRONICLE_ENTRY_LIMIT
	elif not place.is_empty():
		place_detail_chronicle_button.tooltip_text = (
			"以“%s”为上下文写一则玩家纪事；不会改变地点、人物或城池归属"
			% str(place.get("name", current_place_detail_id))
		)


func _open_place_chronicle_editor() -> void:
	if place_detail_panel == null or not place_detail_panel.visible:
		return
	var place := _find_place(current_place_detail_id)
	if place.is_empty():
		_set_status("当前地点已经不可用；沙盘没有变化")
		return
	_pending_chronicle_id = ""
	_open_new_chronicle_editor({
		"kind": "place_detail",
		"place_id": current_place_detail_id,
		"prefill_body": "地点：%s\n\n" % str(place.get("name", current_place_detail_id)),
	})


func _configure_place_ownership_editor(place: Dictionary) -> void:
	var place_type := str(place.get("type", "city"))
	var editable := place_type in ["city", "capital"]
	place_detail_ownership_row.visible = editable
	if not editable:
		return
	var current_owner_id := _scenario_city_owner_id(str(place.get("id", "")))
	_place_owner_select_syncing = true
	place_detail_owner_select.clear()
	place_detail_owner_select.add_item("无归属")
	place_detail_owner_select.set_item_metadata(0, "")
	var selected_index := 0
	for faction_value in scenario_state.get("factions", []):
		if not (faction_value is Dictionary):
			continue
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", ""))
		place_detail_owner_select.add_item(str(faction.get("name", faction_id)))
		var option_index := place_detail_owner_select.item_count - 1
		place_detail_owner_select.set_item_metadata(option_index, faction_id)
		if faction_id == current_owner_id:
			selected_index = option_index
	place_detail_owner_select.select(selected_index)
	_place_owner_select_syncing = false
	var owner := _scenario_faction_record(current_owner_id)
	place_detail_owner_swatch.color = FactionPaletteScript.to_color(str(owner.get("color", "#737B72")), Color("737B72"))
	place_detail_faction_button.disabled = owner.is_empty()
	place_detail_faction_button.tooltip_text = "这座城市尚无归属；可先在上方选择势力" if owner.is_empty() else "查看“%s”的本局上下文" % str(owner.get("name", "势力"))
	place_detail_continuous_ownership_button.disabled = (scenario_state.get("factions", []) as Array).is_empty()
	place_detail_continuous_ownership_button.tooltip_text = (
		"请先在“沙盘 → 编辑玩法分组”中建立势力"
		if place_detail_continuous_ownership_button.disabled
		else "以当前选择为目标，连续点击多座城市；每座城市都可单独撤销"
	)


func _scenario_city_owner_id(place_id: String) -> String:
	for ownership_value in scenario_state.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			continue
		var ownership: Dictionary = ownership_value
		if str(ownership.get("place_id", "")) == place_id:
			return str(ownership.get("faction_id", ""))
	return ""


func _scenario_faction_record(faction_id: String) -> Dictionary:
	return _scenario_faction_record_in_state(scenario_state, faction_id)


func _scenario_faction_record_in_state(state: Dictionary, faction_id: String) -> Dictionary:
	if faction_id.is_empty():
		return {}
	for faction_value in state.get("factions", []):
		if faction_value is Dictionary and str((faction_value as Dictionary).get("id", "")) == faction_id:
			return (faction_value as Dictionary).duplicate(true)
	return {}


func _place_stationed_characters_text(place_id: String) -> String:
	var assignment_map := _scenario_assignment_map(scenario_state)
	var grouped: Dictionary = {}
	var group_order: Array[String] = []
	for faction_value in scenario_state.get("factions", []):
		if not (faction_value is Dictionary):
			continue
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", ""))
		group_order.append(faction_id)
		grouped[faction_id] = []
	group_order.append("")
	grouped[""] = []
	for character_id_value in placements:
		var character_id := str(character_id_value)
		var placement: Dictionary = placements.get(character_id, {})
		if str(placement.get("place_id", "")) != place_id:
			continue
		var faction_id := str(assignment_map.get(character_id, ""))
		if not grouped.has(faction_id):
			faction_id = ""
		(grouped[faction_id] as Array).append("[url=character:%s][color=#7B5A1D][u]%s[/u][/color][/url]〔%s · 兵%s〕" % [
			character_id,
			_bbcode_escape(_character_name(character_id)),
			_bbcode_escape(_character_action_label(str(character_actions.get(character_id, "standby")))),
			_format_troop_count_exact(_effective_character_troop_count(character_id))
		])
	var sections: Array[String] = []
	for faction_id in group_order:
		var members: Array = grouped.get(faction_id, [])
		if members.is_empty():
			continue
		var faction := _scenario_faction_record(faction_id)
		var faction_name := str(faction.get("name", "未编组")) if not faction.is_empty() else "未编组"
		sections.append("%s：%s" % [_bbcode_escape(faction_name), "、".join(members)])
	if sections.is_empty():
		return "当前没有人物驻扎。拖入人物后，可在上方调整城池归属。"
	return "%s\n[color=#6F6A58][font_size=12]点击人名定位；地图人物卡右键可查看人物卡。[/font_size][/color]" % "\n".join(sections)


func _focus_stationed_character_from_place_detail(character_id: String) -> void:
	if current_place_detail_id.is_empty() or map_board == null:
		return
	var placement_value: Variant = placements.get(character_id, null)
	if not (placement_value is Dictionary) or str((placement_value as Dictionary).get("place_id", "")) != current_place_detail_id:
		var place_name := str(_find_place(current_place_detail_id).get("name", "当前地点"))
		_open_place_detail_panel(current_place_detail_id, true)
		_set_status("%s已不在%s；驻扎人物列表已刷新" % [_character_name(character_id), place_name])
		return
	if not map_board.focus_character(character_id):
		_set_status("暂时无法定位%s；请先完成或取消当前路线调整" % _character_name(character_id))
		return
	_position_current_place_detail_panel()
	call_deferred("_position_current_place_detail_panel")
	_set_status("已定位%s；可直接拖动，右键查看人物卡" % _character_name(character_id))


func _on_place_ownership_selected(index: int) -> void:
	if _place_owner_select_syncing or current_place_detail_id.is_empty():
		return
	if index < 0 or index >= place_detail_owner_select.item_count:
		return
	var next_faction_id := str(place_detail_owner_select.get_item_metadata(index))
	if _commit_city_ownership(current_place_detail_id, next_faction_id):
		_open_place_detail_panel(current_place_detail_id, true)
	else:
		_configure_place_ownership_editor(_find_place(current_place_detail_id))


func _commit_city_ownership(place_id: String, faction_id: String, continuous := false) -> bool:
	var place := _find_place(place_id)
	if place.is_empty() or str(place.get("type", "city")) not in ["city", "capital"]:
		_set_status("这里只能设置城市或都城的本局归属")
		return false
	if not faction_id.is_empty() and _scenario_faction_record(faction_id).is_empty():
		_set_status("目标势力已经不存在；沙盘保持原样")
		return false
	var current_faction_id := _scenario_city_owner_id(place_id)
	var place_name := str(place.get("name", place_id))
	if faction_id == current_faction_id:
		var current_faction := _scenario_faction_record(faction_id)
		var current_name := str(current_faction.get("name", "无归属")) if not current_faction.is_empty() else "无归属"
		_set_status("%s已经是“%s” · 没有新增撤销步骤" % [place_name, current_name])
		return false
	var next_state := _city_ownership_state_with(place_id, faction_id)
	var next_faction := _scenario_faction_record(faction_id)
	var status := "已清除%s的本局归属 · 可撤销" % place_name
	if not next_faction.is_empty():
		status = "已将%s设为“%s” · 可撤销" % [place_name, str(next_faction.get("name", "势力"))]
	if continuous:
		status += " · 可继续点选"
	return _commit_scenario_state(next_state, "修改城池归属", status)


func _city_ownership_state_with(place_id: String, faction_id: String) -> Dictionary:
	var next_state := scenario_state.duplicate(true)
	var next_ownership: Array[Dictionary] = []
	for ownership_value in next_state.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			continue
		if str((ownership_value as Dictionary).get("place_id", "")) != place_id:
			next_ownership.append((ownership_value as Dictionary).duplicate(true))
	if not faction_id.is_empty():
		next_ownership.append({"place_id": place_id, "faction_id": faction_id})
	next_ownership.sort_custom(
		func(first: Dictionary, second: Dictionary):
			return str(first.get("place_id", "")) < str(second.get("place_id", ""))
	)
	next_state["city_ownership"] = next_ownership
	return next_state


func _start_city_ownership_tool_from_detail() -> void:
	if place_detail_owner_select == null or current_place_detail_id.is_empty():
		return
	if (scenario_state.get("factions", []) as Array).is_empty():
		_set_status("请先建立至少一个本局玩法势力")
		return
	var selected_index := place_detail_owner_select.selected
	if selected_index < 0 or selected_index >= place_detail_owner_select.item_count:
		return
	city_ownership_tool_target_faction_id = str(place_detail_owner_select.get_item_metadata(selected_index))
	city_ownership_tool_hover_place_id = ""
	_city_ownership_tool_restore_influence_visible = map_board.is_faction_influence_visible()
	_close_place_detail_panel()
	map_board.set_faction_influence_visible(true)
	map_board.set_faction_influence_legend_context_suppressed(false)
	city_ownership_tool_active = true
	_populate_city_ownership_tool_target_select(city_ownership_tool_target_faction_id)
	map_board.set_city_ownership_tool_active(true)
	city_ownership_tool_panel.show()
	_refresh_city_ownership_tool_ui()
	_refresh_draw_tool_button()
	_set_status("%s · 连续点击城市设置归属，Esc 结束" % _city_ownership_tool_target_text())


func _finish_city_ownership_tool(status_text := "已结束连续设置；已完成的城池归属保持不变", update_status := true) -> void:
	if not city_ownership_tool_active:
		return
	city_ownership_tool_active = false
	city_ownership_tool_hover_place_id = ""
	if map_board != null:
		map_board.set_city_ownership_tool_active(false)
		map_board.set_faction_influence_visible(_city_ownership_tool_restore_influence_visible)
	if city_ownership_tool_panel != null:
		city_ownership_tool_panel.hide()
	_refresh_draw_tool_button()
	if update_status:
		_set_status(status_text)


func _populate_city_ownership_tool_target_select(preferred_faction_id: String) -> void:
	if city_ownership_tool_target_select == null:
		return
	_city_ownership_tool_select_syncing = true
	city_ownership_tool_target_select.clear()
	city_ownership_tool_target_select.add_item("无归属（清除）")
	city_ownership_tool_target_select.set_item_metadata(0, "")
	city_ownership_tool_target_select.set_item_icon(0, _faction_swatch_texture("#737B72"))
	var selected_index := 0
	var target_is_valid := preferred_faction_id.is_empty()
	var faction_index := 0
	for faction_value in scenario_state.get("factions", []):
		if not (faction_value is Dictionary):
			continue
		var faction: Dictionary = faction_value
		var faction_id := str(faction.get("id", ""))
		if faction_id.is_empty():
			continue
		faction_index += 1
		city_ownership_tool_target_select.add_item("%d %s" % [faction_index, str(faction.get("name", faction_id))])
		var option_index := city_ownership_tool_target_select.item_count - 1
		city_ownership_tool_target_select.set_item_metadata(option_index, faction_id)
		city_ownership_tool_target_select.set_item_icon(option_index, _faction_swatch_texture(str(faction.get("color", "#737B72"))))
		if faction_id == preferred_faction_id:
			selected_index = option_index
			target_is_valid = true
	if not target_is_valid:
		city_ownership_tool_target_faction_id = ""
	city_ownership_tool_target_select.select(selected_index)
	_city_ownership_tool_select_syncing = false


func _on_city_ownership_tool_target_selected(index: int) -> void:
	if _city_ownership_tool_select_syncing or not city_ownership_tool_active:
		return
	if index < 0 or index >= city_ownership_tool_target_select.item_count:
		return
	var next_faction_id := str(city_ownership_tool_target_select.get_item_metadata(index))
	if not next_faction_id.is_empty() and _scenario_faction_record(next_faction_id).is_empty():
		_populate_city_ownership_tool_target_select(city_ownership_tool_target_faction_id)
		_set_status("目标势力已经不存在")
		return
	city_ownership_tool_target_faction_id = next_faction_id
	_refresh_city_ownership_tool_ui()
	_set_status("%s · 继续点击城市；切换目标时沙盘保持原样" % _city_ownership_tool_target_text())


func _on_city_ownership_place_requested(place_id: String) -> void:
	if not city_ownership_tool_active:
		return
	if _commit_city_ownership(place_id, city_ownership_tool_target_faction_id, true):
		_refresh_city_ownership_tool_ui()


func _on_city_ownership_hover_changed(place_id: String) -> void:
	if not city_ownership_tool_active:
		return
	city_ownership_tool_hover_place_id = place_id
	_refresh_city_ownership_tool_ui()


func _city_ownership_tool_target_text() -> String:
	var faction := _scenario_faction_record(city_ownership_tool_target_faction_id)
	if faction.is_empty():
		return "目标：无归属（清除）"
	return "目标：%s" % str(faction.get("name", "本局势力"))


func _refresh_city_ownership_tool_ui() -> void:
	if city_ownership_tool_panel == null:
		return
	city_ownership_tool_panel.visible = city_ownership_tool_active
	if not city_ownership_tool_active:
		return
	var hint := "单击城市设置归属 · Esc 结束"
	if not city_ownership_tool_hover_place_id.is_empty():
		var place_name := str(_find_place(city_ownership_tool_hover_place_id).get("name", city_ownership_tool_hover_place_id))
		var faction := _scenario_faction_record(city_ownership_tool_target_faction_id)
		hint = (
			"单击清除%s归属" % place_name
			if faction.is_empty()
			else "单击将%s设为%s" % [place_name, str(faction.get("name", "本局势力"))]
		)
	city_ownership_tool_hint_label.text = hint
	city_ownership_tool_hint_label.tooltip_text = hint
	city_ownership_tool_undo_button.disabled = (
		_undo_stack.is_empty()
		or str((_undo_stack.back() as Dictionary).get("label", "")) != "修改城池归属"
	)


func _undo_last_city_ownership_change() -> void:
	if not city_ownership_tool_active or _undo_stack.is_empty():
		return
	if str((_undo_stack.back() as Dictionary).get("label", "")) != "修改城池归属":
		_refresh_city_ownership_tool_ui()
		return
	var previous_size := _undo_stack.size()
	_on_undo_pressed()
	_refresh_city_ownership_tool_ui()
	if _undo_stack.size() < previous_size:
		_set_status("已撤销上一座城市归属 · 连续设置仍开启")


func _sync_city_ownership_tool_after_scenario_change() -> void:
	if not city_ownership_tool_active:
		return
	if (scenario_state.get("factions", []) as Array).is_empty():
		_finish_city_ownership_tool("玩法势力已清空，连续设置已结束")
		return
	if (
		not city_ownership_tool_target_faction_id.is_empty()
		and _scenario_faction_record(city_ownership_tool_target_faction_id).is_empty()
	):
		_finish_city_ownership_tool("目标势力已删除，连续设置已结束")
		return
	_populate_city_ownership_tool_target_select(city_ownership_tool_target_faction_id)
	_refresh_city_ownership_tool_ui()


func _open_faction_context_panel(faction_id: String) -> void:
	var faction := _scenario_faction_record(faction_id)
	if faction.is_empty() or place_detail_panel == null:
		_set_status("找不到这个本局势力")
		return
	_place_detail_return_ids.clear()
	current_place_detail_id = ""
	current_place_connection_ids.clear()
	_place_connection_cycle_index = -1
	current_historical_context_detail_id = ""
	current_faction_detail_id = faction_id
	map_board.clear_place_relation_highlight()
	map_board.set_faction_inspection_highlight(faction_id)
	_faction_city_cycle_index = -1
	_faction_character_cycle_index = -1
	var owned_places := _owned_place_ids_for_faction(faction_id)
	current_detail_anchor_place_id = str(owned_places[0]) if not owned_places.is_empty() else ""
	_configure_context_inspector_mode("faction")
	place_detail_title_label.text = str(faction.get("name", "本局势力"))
	place_detail_title_label.add_theme_color_override(
		"font_color",
		FactionPaletteScript.render_on_light(
			str(faction.get("color", "#737B72")),
			UiThemeScript.INK_DIALOG,
			4.5
		)
	)
	place_detail_historical_label.text = "本局玩法势力　·　%s" % str(_current_scenario_context_contract().get("label", "完全自定义"))
	var member_ids := _character_ids_for_faction(faction_id, false)
	place_detail_tags_label.text = "%d 人　·　%d 城　·　颜色 %s" % [member_ids.size(), owned_places.size(), str(faction.get("color", ""))]
	place_detail_scroll_hint_label.text = "本局人物、城池与行动摘要"
	place_detail_scroll_hint_label.tooltip_text = "这里只汇总玩家记录，不计算强弱、资源或胜率"
	var action_counts := CharacterActionPolicyScript.empty_counts()
	for character_id in member_ids:
		var action := CharacterActionPolicyScript.normalize(str(character_actions.get(character_id, CHARACTER_ACTION_STANDBY)))
		action_counts[action] = int(action_counts.get(action, 0)) + 1
	var city_names: Array[String] = []
	for place_id in owned_places:
		city_names.append(str(_find_place(place_id).get("name", place_id)))
	var member_names: Array[String] = []
	for character_id in member_ids:
		var location := _scenario_character_location_text(character_id)
		member_names.append("%s（%s）" % [_character_name(character_id), location])
	var body_sections: Array[String] = []
	body_sections.append(_place_detail_bbcode_section(
		"当前行动",
		"待命 %d　进攻 %d　防御 %d\n这些只是玩家标注，不触发自动行动。" % [
			int(action_counts.get(CHARACTER_ACTION_STANDBY, 0)),
			int(action_counts.get(CHARACTER_ACTION_ATTACK, 0)),
			int(action_counts.get(CHARACTER_ACTION_DEFEND, 0))
		],
		"#%s" % UiThemeScript.RICH_BODY_HEX
	))
	body_sections.append(_place_detail_bbcode_section(
		"本局城池",
		"、".join(city_names) if not city_names.is_empty() else "尚未记录城池归属。",
		"#%s" % UiThemeScript.RICH_BODY_HEX
	))
	body_sections.append(_place_detail_bbcode_section(
		"本局人物",
		"\n".join(member_names) if not member_names.is_empty() else "尚未给人物分组。",
		"#%s" % UiThemeScript.RICH_BODY_HEX
	))
	place_detail_body.text = "\n\n".join(body_sections)
	place_detail_body.scroll_to_line(0)
	place_detail_host.show()
	place_detail_panel.show()
	map_board.set_faction_influence_legend_context_suppressed(true)
	_position_current_place_detail_panel()
	call_deferred("_position_current_place_detail_panel")
	place_detail_locate_button.disabled = owned_places.is_empty()
	place_detail_faction_button.disabled = _character_ids_for_faction(faction_id, true).is_empty()
	_set_status("正在查看“%s”的本局势力上下文" % place_detail_title_label.text)


func _on_faction_legend_requested(faction_id: String) -> void:
	_open_faction_context_panel(faction_id)


func _character_ids_for_faction(faction_id: String, placed_only: bool) -> Array[String]:
	var result: Array[String] = []
	for assignment_value in scenario_state.get("character_assignments", []):
		if not (assignment_value is Dictionary):
			continue
		var assignment: Dictionary = assignment_value
		if str(assignment.get("faction_id", "")) != faction_id:
			continue
		var character_id := str(assignment.get("character_id", ""))
		if placed_only and not placements.has(character_id):
			continue
		result.append(character_id)
	return result


func _owned_place_ids_for_faction(faction_id: String) -> Array[String]:
	var result: Array[String] = []
	for ownership_value in scenario_state.get("city_ownership", []):
		if not (ownership_value is Dictionary):
			continue
		var ownership: Dictionary = ownership_value
		if str(ownership.get("faction_id", "")) == faction_id:
			result.append(str(ownership.get("place_id", "")))
	return result


func _on_context_locate_pressed() -> void:
	if map_board == null:
		return
	if not current_place_detail_id.is_empty():
		var place_cycle: Array[String] = [current_place_detail_id]
		place_cycle.append_array(current_place_connection_ids)
		_place_connection_cycle_index = (_place_connection_cycle_index + 1) % place_cycle.size()
		_focus_place_from_detail(place_cycle[_place_connection_cycle_index], _place_connection_cycle_index, place_cycle.size())
		return
	if current_faction_detail_id.is_empty():
		return
	var place_ids := _owned_place_ids_for_faction(current_faction_detail_id)
	if place_ids.is_empty():
		_set_status("这个势力尚未记录城池归属")
		return
	_faction_city_cycle_index = (_faction_city_cycle_index + 1) % place_ids.size()
	var place_id := place_ids[_faction_city_cycle_index]
	current_detail_anchor_place_id = place_id
	map_board.focus_place(place_id)
	_position_current_place_detail_panel()
	_set_status("已定位%s（%d/%d）" % [str(_find_place(place_id).get("name", place_id)), _faction_city_cycle_index + 1, place_ids.size()])


func _focus_place_from_detail(place_id: String, cycle_index: int, cycle_size: int) -> bool:
	if map_board == null or not map_board.focus_place(place_id):
		_set_status("这个地点暂时无法定位")
		return false
	current_detail_anchor_place_id = place_id
	if place_id == current_place_detail_id:
		map_board.clear_place_relation_target()
	else:
		map_board.set_place_relation_highlight(current_place_detail_id, place_id)
	_refresh_place_detail_relation_navigation()
	_position_current_place_detail_panel()
	var place_name := str(_find_place(place_id).get("name", place_id))
	var source_name := str(_find_place(current_place_detail_id).get("name", current_place_detail_id))
	var status_text := "已定位%s" % place_name
	if place_id != current_place_detail_id:
		status_text = "从%s查看%s" % [source_name, place_name]
	if cycle_size > 1:
		status_text += "（%d/%d）" % [cycle_index + 1, cycle_size]
	_set_status(status_text)
	return true


func _refresh_place_detail_relation_navigation() -> void:
	if place_detail_relation_navigation_row == null:
		return
	var city_mode := (
		not current_place_detail_id.is_empty()
		and current_historical_context_detail_id.is_empty()
		and current_faction_detail_id.is_empty()
	)
	var switch_target_id := current_detail_anchor_place_id
	var has_switch_target := (
		city_mode
		and switch_target_id != current_place_detail_id
		and current_place_connection_ids.has(switch_target_id)
	)
	var back_target_id := _place_detail_return_ids[-1] if not _place_detail_return_ids.is_empty() else ""
	# 当前目标就是返回来源时，只显示“返回”，避免两个按钮指向同一地点。
	if has_switch_target and switch_target_id == back_target_id:
		has_switch_target = false
	place_detail_switch_button.visible = has_switch_target
	if has_switch_target:
		var switch_name := str(_find_place(switch_target_id).get("name", switch_target_id))
		place_detail_switch_button.text = "换看%s" % switch_name
		place_detail_switch_button.tooltip_text = "打开%s自己的地点札记" % switch_name
	place_detail_back_button.visible = city_mode and not back_target_id.is_empty()
	if place_detail_back_button.visible:
		var back_name := str(_find_place(back_target_id).get("name", back_target_id))
		place_detail_back_button.text = "返回%s" % back_name
		place_detail_back_button.tooltip_text = "回到上一张%s地点札记" % back_name
	place_detail_relation_navigation_row.visible = place_detail_switch_button.visible or place_detail_back_button.visible


func _on_context_switch_place_pressed() -> void:
	if current_place_detail_id.is_empty():
		return
	var target_place_id := current_detail_anchor_place_id
	if target_place_id == current_place_detail_id or not current_place_connection_ids.has(target_place_id):
		return
	if not _place_detail_return_ids.is_empty() and _place_detail_return_ids[-1] == target_place_id:
		_on_context_back_place_pressed()
		return
	var source_place_id := current_place_detail_id
	_place_detail_return_ids.append(source_place_id)
	if map_board != null:
		map_board.focus_place(target_place_id)
	_open_place_detail_panel(target_place_id, true)
	_set_status("已从%s换看%s札记" % [
		str(_find_place(source_place_id).get("name", source_place_id)),
		str(_find_place(target_place_id).get("name", target_place_id))
	])


func _on_context_back_place_pressed() -> void:
	if _place_detail_return_ids.is_empty():
		return
	var source_place_id := current_place_detail_id
	var target_place_id: String = _place_detail_return_ids.pop_back()
	if _find_place(target_place_id).is_empty():
		_refresh_place_detail_relation_navigation()
		return
	if map_board != null:
		map_board.focus_place(target_place_id)
	_open_place_detail_panel(target_place_id, true)
	_set_status("已从%s返回%s札记" % [
		str(_find_place(source_place_id).get("name", source_place_id)),
		str(_find_place(target_place_id).get("name", target_place_id))
	])


func _on_context_place_note_pressed() -> void:
	if current_place_detail_id.is_empty():
		return
	var place := _find_place(current_place_detail_id)
	if place.is_empty():
		return
	_on_annotation_create_requested(Vector2(float(place.get("x", 0.5)), float(place.get("y", 0.5))))


func _on_context_faction_pressed() -> void:
	if not current_place_detail_id.is_empty():
		var faction_id := _scenario_city_owner_id(current_place_detail_id)
		if not faction_id.is_empty():
			_open_faction_context_panel(faction_id)
		return
	if current_faction_detail_id.is_empty() or map_board == null:
		return
	var character_ids := _character_ids_for_faction(current_faction_detail_id, true)
	if character_ids.is_empty():
		_set_status("这个势力当前没有人物摆在地图上")
		return
	_faction_character_cycle_index = (_faction_character_cycle_index + 1) % character_ids.size()
	var character_id := character_ids[_faction_character_cycle_index]
	map_board.focus_character(character_id)
	_set_status("已定位%s（%d/%d）" % [_character_name(character_id), _faction_character_cycle_index + 1, character_ids.size()])


func _on_context_edit_faction_pressed() -> void:
	var preferred_faction_id := current_faction_detail_id
	if preferred_faction_id.is_empty() and not current_place_detail_id.is_empty():
		preferred_faction_id = _scenario_city_owner_id(current_place_detail_id)
	_close_place_detail_panel()
	_open_scenario_editor()
	if not preferred_faction_id.is_empty() and not _pending_scenario_editor_state.is_empty():
		_pending_scenario_faction_id = preferred_faction_id
		_refresh_scenario_editor(preferred_faction_id)


func _close_place_detail_panel() -> void:
	if place_detail_panel == null:
		return
	var was_historical_context := not current_historical_context_detail_id.is_empty()
	place_detail_panel.hide()
	if place_detail_host != null:
		place_detail_host.hide()
	if map_board != null:
		map_board.set_faction_influence_legend_context_suppressed(false)
		map_board.clear_faction_inspection_highlight()
		map_board.clear_place_relation_highlight()
	_place_detail_return_ids.clear()
	current_place_detail_id = ""
	current_place_connection_ids.clear()
	_place_connection_cycle_index = -1
	current_faction_detail_id = ""
	current_historical_context_detail_id = ""
	current_detail_anchor_place_id = ""
	_set_status("已收起历史背景资料卡，沙盘保持不变" if was_historical_context else "已收起地点札记，沙盘保持不变")


func _position_current_place_detail_panel() -> void:
	if place_detail_panel == null or place_detail_host == null or map_board == null:
		return
	var margin := 16.0
	var panel_size := Vector2(minf(340.0, maxf(300.0, map_board.size.x - margin * 2.0)), minf(450.0, maxf(360.0, map_board.size.y - margin * 2.0)))
	var target := Vector2(map_board.size.x - panel_size.x - margin, margin)
	var anchor_place_id := current_detail_anchor_place_id if not current_detail_anchor_place_id.is_empty() else current_place_detail_id
	if not anchor_place_id.is_empty():
		var place_screen := map_board.get_place_screen_position(anchor_place_id)
		if place_screen.x >= 0.0 and place_screen.y >= 0.0:
			target.x = margin if place_screen.x > map_board.size.x * 0.5 else map_board.size.x - panel_size.x - margin
			target.y = margin if place_screen.y > map_board.size.y * 0.5 else map_board.size.y - panel_size.y - margin
	place_detail_host.position = target
	place_detail_host.size = panel_size


func _bbcode_escape(value: String) -> String:
	return value.replace("[", "[lb]")


func _historical_context_date_text(record: Dictionary) -> String:
	var date: Dictionary = record.get("date", {})
	var year := int(date.get("year", 184))
	if str(record.get("layer", "")) == "romance":
		return "演义时间：%d年" % year
	var prefix := _historical_context_reign_year_text(year)
	var precision := str(date.get("precision", "year"))
	var month_from := int(date.get("month_from", 0))
	var month_to := int(date.get("month_to", month_from))
	if precision == "month" and month_from > 0:
		return "%s·%s" % [prefix, _chinese_month_text(month_from)]
	if precision == "range" and month_from > 0 and month_to > 0:
		return "%s·%s至%s" % [prefix, _chinese_month_text(month_from), _chinese_month_text(month_to)]
	return prefix


func _historical_context_reign_year_text(year: int) -> String:
	match year:
		184:
			return "中平元年（184）"
		190:
			return "初平元年（190）"
		196:
			return "建安元年（196）"
		_:
			return "%d年" % year


func _chinese_month_text(month: int) -> String:
	var names := ["", "正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
	return names[month] if month >= 1 and month < names.size() else "%d月" % month


func _historical_context_text_basis(record: Dictionary) -> String:
	match str(record.get("confidence", "")):
		"narrative_explicit":
			return "演义原文明确"
		"regional_anchor":
			return "史事原文有据"
		_:
			return "原文明确"


func _historical_context_anchor_text(anchor_semantics: String) -> String:
	match anchor_semantics:
		"administrative_center_reference":
			return "行政中心参考"
		"disputed_site_reference":
			return "地望争议代理"
		"administrative_region_reference":
			return "区域阅读锚点"
		"modern_place_proxy":
			return "现代地点代理"
		"historical_site_reference":
			return "历史地点参考"
		_:
			return "全国尺度锚点"


func _historical_context_source_text(section_title: String, source: Dictionary, evidence: Dictionary) -> String:
	var lines: Array[String] = [section_title, str(source.get("citation_title", source.get("work_title", "未命名资料")))]
	var authors: Array[String] = []
	var author := str(source.get("author", "")).strip_edges()
	var annotator := str(source.get("annotator", "")).strip_edges()
	if not author.is_empty():
		authors.append("作者：%s" % author)
	if not annotator.is_empty():
		authors.append("注者：%s" % annotator)
	if not authors.is_empty():
		lines.append(" · ".join(authors))
	lines.append("原文定位：%s" % str(evidence.get("source_locator", "未登记")))
	lines.append("本条依据：%s" % str(evidence.get("claim_scope", "未登记")))
	var permalink := str(source.get("permalink", "")).strip_edges()
	if not permalink.is_empty():
		lines.append("固定版本：%s" % permalink)
	lines.append("使用边界：仅供引用，不复制古籍全文。页面许可：%s" % str(source.get("license", "未登记")))
	return "\n".join(lines)


func _place_period_context_text(resolved_contexts: Array) -> String:
	var context_sections: Array[String] = []
	for context_value in resolved_contexts:
		if not (context_value is Dictionary):
			continue
		var resolved_context: Dictionary = context_value
		var record: Dictionary = resolved_context.get("record", {})
		if record.is_empty():
			continue
		var lines: Array[String] = ["%s · %s" % [
			_historical_context_date_text(record),
			str(record.get("title", record.get("label", "历史背景")))
		]]
		lines.append(str(record.get("summary", "当前条目只提供年代背景。")))
		context_sections.append("\n\n".join(lines))
	return "\n\n".join(context_sections)


func _place_detail_bbcode_section(title: String, content: String, color: String, content_is_bbcode := false) -> String:
	var rendered_content := content if content_is_bbcode else _bbcode_escape(content)
	return "[color=#%s][font_size=15][b]%s[/b][/font_size][/color]\n[color=%s][font_size=14]%s[/font_size][/color]" % [
		UiThemeScript.RICH_HEADING_HEX, _bbcode_escape(title), color, rendered_content
	]


func _place_detail_type_text(place_type: String) -> String:
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


func _place_detail_player_summary(place: Dictionary) -> String:
	var explicit_summary := str(place.get("hover_note", "")).strip_edges()
	if str(place.get("type", "")) == "battlefield":
		var first_line := explicit_summary if not explicit_summary.is_empty() else "这里是历史战场区域。"
		return "%s\n可以在这里摆放人物，推演集结、对峙或进军。" % first_line
	if not explicit_summary.is_empty():
		return explicit_summary
	return "%s是汉末沙盘中的重要地点，可以用于人物驻扎与自由推演。" % str(place.get("historical_name_190", place.get("name", "该地点")))


func _place_detail_source_text(section_title: String, source: Dictionary, locator: String, crosscheck: bool) -> String:
	var lines: Array[String] = [section_title, "《%s》" % str(source.get("title", "未命名资料"))]
	var meta: Array[String] = []
	var version := str(source.get("version", "")).strip_edges()
	var retrieved_at := str(source.get("retrieved_at", "")).strip_edges()
	if not version.is_empty():
		meta.append("版本 %s" % version)
	if not retrieved_at.is_empty():
		meta.append("查阅 %s" % retrieved_at)
	if not meta.is_empty():
		lines.append(" · ".join(meta))
	lines.append("使用边界：%s · 许可：%s" % [_map_source_usage_text(str(source.get("usage_status", "uncertain"))), str(source.get("license", "未登记"))])
	if not locator.is_empty() and not crosscheck:
		lines.append("来源定位：%s" % locator)
	var notes := str(source.get("notes", "")).strip_edges()
	if not notes.is_empty():
		lines.append(notes)
	return "\n".join(lines)


func _map_source_usage_text(usage_status: String) -> String:
	match usage_status:
		"approved_for_distribution":
			return "可随项目分发"
		"reference_only":
			return "仅供引用，不复制原文"
		"license_blocked":
			return "仅限研究原型，许可不满足发行门禁"
		_:
			return "使用边界待核实"


func _infer_legacy_place_id(normalized_position: Vector2) -> String:
	for place in places:
		# v1/v2 自由落点没有地点身份；范围型锚点后加进地图时，不能倒推成历史驻点。
		if str(place.get("type", "")) == "battlefield" or str(place.get("geometry_kind", "")) == "area_anchor":
			continue
		var place_position := Vector2(float(place.get("x", 0.5)), float(place.get("y", 0.5)))
		if normalized_position.distance_squared_to(place_position) <= LEGACY_PLACE_MIGRATION_EPSILON * LEGACY_PLACE_MIGRATION_EPSILON:
			return str(place.get("id", ""))
	return ""


func _capture_v3_point(point: Vector2) -> Vector2:
	var result := MapGeometryMigrationScript.reproject_normalized(
		point,
		MAP_GEOMETRY_V3_BOUNDS,
		MAP_GEOMETRY_V4_BOUNDS
	)
	return result.get("point", point) if bool(result.get("ok", false)) else point


func _capture_v3_xy(point: Vector2) -> Dictionary:
	var migrated := _capture_v3_point(point)
	return {"x": migrated.x, "y": migrated.y}


func _capture_place_placement(place_id: String, legacy_fallback: Vector2) -> Dictionary:
	var place := _find_place(place_id)
	if not place.is_empty():
		return {
			"x": float(place.get("x", 0.5)),
			"y": float(place.get("y", 0.5)),
			"place_id": place_id
		}
	var fallback := _capture_v3_xy(legacy_fallback)
	fallback["place_id"] = place_id
	return fallback


func _capture_custom_scenario_state(
	factions: Array,
	assignments: Array,
	city_ownership: Array = []
) -> Dictionary:
	var state := _empty_scenario_state()
	state["scenario_id"] = "capture_custom"
	state["era_label"] = "确定性截图"
	state["factions"] = factions.duplicate(true)
	state["character_assignments"] = assignments.duplicate(true)
	state["city_ownership"] = city_ownership.duplicate(true)
	return state


func _configure_scenario_share_capture_content() -> void:
	var zhuo := _capture_place_placement("zhuo", Vector2(0.44, 0.28))
	var guangzong := _capture_place_placement("guangzong", Vector2(0.69, 0.22))
	placements = {
		"liu_bei": zhuo.duplicate(true),
		"guan_yu": zhuo.duplicate(true),
		"zhang_fei": zhuo.duplicate(true),
		"zhang_jiao": guangzong.duplicate(true),
	}
	annotations = {
		"marker_share_capture": {
			"id": "marker_share_capture",
			"marker_type": "player_event",
			"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
			"verification_status": ANNOTATION_VERIFICATION_STATUS,
			"x": float(zhuo.get("x", 0.44)) + 0.03,
			"y": float(zhuo.get("y", 0.28)) + 0.04,
			"label": "桃园起步",
			"faction_id": "play_liu_share",
		}
	}
	scenario_state = _capture_custom_scenario_state(
		[
			{"id": "play_liu_share", "name": "刘备一行", "color": "#0077BB"},
			{"id": "play_yellow_share", "name": "黄巾军", "color": "#EE7733"},
		],
		[
			{"character_id": "liu_bei", "faction_id": "play_liu_share"},
			{"character_id": "guan_yu", "faction_id": "play_liu_share"},
			{"character_id": "zhang_fei", "faction_id": "play_liu_share"},
			{"character_id": "zhang_jiao", "faction_id": "play_yellow_share"},
		],
		[
			{"place_id": "zhuo", "faction_id": "play_liu_share"},
			{"place_id": "guangzong", "faction_id": "play_yellow_share"},
		]
	)
	sandbox_metadata["title"] = "涿郡桃园起步"
	sandbox_metadata["note"] = "刘关张从涿郡出发，张角据守广宗；交给另一位玩家继续自由推演。"
	_refresh_views()
	_refresh_sandbox_identity_view()


func _configure_simulation_session_capture(with_changes: bool) -> void:
	var luoyang := _capture_place_placement("luoyang", Vector2(0.57, 0.32))
	var guangzong := _capture_place_placement("guangzong", Vector2(0.69, 0.24))
	placements = {
		"liu_bei": luoyang.duplicate(true),
		"guan_yu": luoyang.duplicate(true),
		"zhang_fei": _capture_v3_xy(Vector2(0.52, 0.42)),
		"zhang_jiao": guangzong.duplicate(true),
	}
	annotations = {}
	player_strokes = []
	character_actions = {"liu_bei": CHARACTER_ACTION_ATTACK}
	character_troops = {"liu_bei": 3000, "zhang_jiao": 8000}
	scenario_state = _capture_custom_scenario_state(
		[
			{"id": "play_liu_capture", "name": "刘备一行", "color": "#0077BB"},
			{"id": "play_yellow_capture", "name": "黄巾军", "color": "#EE7733"},
		],
		[
			{"character_id": "liu_bei", "faction_id": "play_liu_capture"},
			{"character_id": "guan_yu", "faction_id": "play_liu_capture"},
			{"character_id": "zhang_fei", "faction_id": "play_liu_capture"},
			{"character_id": "zhang_jiao", "faction_id": "play_yellow_capture"},
		]
	)
	var baseline := _capture_simulation_session_state()
	if with_changes:
		placements["liu_bei"] = guangzong.duplicate(true)
		character_actions["guan_yu"] = CHARACTER_ACTION_DEFEND
		character_troops["guan_yu"] = 5000
		annotations["marker_session_capture"] = {
			"id": "marker_session_capture",
			"marker_type": "player_event",
			"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
			"verification_status": ANNOTATION_VERIFICATION_STATUS,
			"x": float(guangzong.get("x", 0.69)) - 0.03,
			"y": float(guangzong.get("y", 0.24)) + 0.04,
			"label": "援军抵达",
			"faction_id": "play_liu_capture",
		}
	if not with_changes:
		active_simulation_session.clear()
		_refresh_views()
		_refresh_simulation_session_bar()
		return
	active_simulation_session = {
		"id": "session_capture",
		"name": "广宗援军推演",
		"session_type": "reinforcement",
		"time_label": "中平元年春",
		"participant_ids": ["liu_bei", "guan_yu", "zhang_fei"],
		"baseline": baseline,
		"start_snapshot_id": "snapshot_capture",
		"result_chronicle_id": "",
		"end_snapshot_id": "",
		"started_at": "2026-08-01T12:00:00",
	}
	_refresh_views()
	_refresh_simulation_session_bar()


func _configure_player_siege_capture(with_changes: bool) -> void:
	_configure_simulation_session_capture(false)
	var guangzong := _capture_place_placement("guangzong", Vector2(0.69, 0.24))
	placements["zhang_bao"] = guangzong.duplicate(true)
	character_actions["zhang_jiao"] = CHARACTER_ACTION_DEFEND
	character_actions["zhang_bao"] = CHARACTER_ACTION_DEFEND
	character_troops["zhang_bao"] = 5000
	scenario_state = _capture_custom_scenario_state(
		[
			{"id": "play_liu_capture", "name": "刘备一行", "color": "#0077BB"},
			{"id": "play_yellow_capture", "name": "黄巾军", "color": "#EE7733"},
		],
		[
			{"character_id": "liu_bei", "faction_id": "play_liu_capture"},
			{"character_id": "guan_yu", "faction_id": "play_liu_capture"},
			{"character_id": "zhang_fei", "faction_id": "play_liu_capture"},
			{"character_id": "zhang_jiao", "faction_id": "play_yellow_capture"},
			{"character_id": "zhang_bao", "faction_id": "play_yellow_capture"},
		]
	)
	scenario_state["city_ownership"] = [{"place_id": "guangzong", "faction_id": "play_yellow_capture"}]
	var baseline := _capture_simulation_session_state()
	if not with_changes:
		active_simulation_session.clear()
		_refresh_views()
		_refresh_simulation_session_bar()
		return
	placements["liu_bei"] = guangzong.duplicate(true)
	annotations["marker_siege_capture"] = {
		"id": "marker_siege_capture",
		"marker_type": "player_event",
		"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
		"verification_status": ANNOTATION_VERIFICATION_STATUS,
		"x": float(guangzong.get("x", 0.69)) - 0.03,
		"y": float(guangzong.get("y", 0.24)) + 0.04,
		"label": "攻城交锋",
		"faction_id": "play_liu_capture",
	}
	active_simulation_session = {
		"id": "session_siege_capture",
		"name": "刘备试攻广宗",
		"session_type": "siege",
		"time_label": "中平元年夏",
		"participant_ids": ["liu_bei", "guan_yu", "zhang_jiao", "zhang_bao"],
		"attacker_ids": ["liu_bei", "guan_yu"],
		"defender_ids": ["zhang_jiao", "zhang_bao"],
		"target_place_id": "guangzong",
		"baseline": baseline,
		"start_snapshot_id": "snapshot_capture",
		"result_chronicle_id": "",
		"end_snapshot_id": "",
		"resolution_committed": false,
		"started_at": "2026-08-02T12:00:00",
	}
	_refresh_views()
	_refresh_simulation_session_bar()


func _on_zoom_changed(value: float) -> void:
	if zoom_label != null:
		zoom_label.text = "%d%%" % roundi(value * 100.0)
	if detail_label != null and map_board != null:
		var level := str(map_board.get_map_detail_state().get("level", "far"))
		match level:
			"near":
				detail_label.text = "城池"
				detail_label.add_theme_color_override("font_color", Color("d4bd77"))
			"middle":
				detail_label.text = "战区"
				detail_label.add_theme_color_override("font_color", Color("a9b98c"))
			_:
				detail_label.text = "天下"
	detail_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	if place_detail_panel != null and place_detail_panel.visible:
		_position_current_place_detail_panel()


func _on_strategic_corridors_visibility_changed(visible: bool) -> void:
	_set_status("已显示战略通道 · 仅为沙盘连通示意" if visible else "已隐藏战略通道 · 地图与沙盘状态不变")


func _on_historical_context_layer_visibility_changed(layer_id: String, visible: bool) -> void:
	if not visible and not current_historical_context_detail_id.is_empty() and _historical_context_layer_id_for_record(current_historical_context_detail_id) == layer_id:
		_close_place_detail_panel()
	var year_text := "历史"
	for layer_value in historical_context_layers:
		if str(layer_value.get("id", "")) == layer_id:
			year_text = "%d 年" % int(layer_value.get("year", 0))
			break
	_set_status("已显示 %s背景 · 可在地图查看" % year_text if visible else "已隐藏 %s背景 · 地图与沙盘保持原样" % year_text)


func _on_annotation_type_visibility_changed(marker_type: String, visible: bool) -> void:
	var type_name := _annotation_type_label(marker_type)
	_set_status("已显示%s · 仅当前会话" % type_name if visible else "已隐藏%s · 标记数据不变" % type_name)


func _on_annotation_focused(_annotation_id: String, label: String, index: int, total: int) -> void:
	var display_label := label if not label.is_empty() else "未命名标记"
	_set_status("已定位：%s · %d/%d" % [display_label, index, total])


func _on_annotation_focus_unavailable() -> void:
	_set_status("当前没有可定位的标记 · 可在“我的标记”中恢复显示")


func _character_name(character_id: String) -> String:
	for character in characters:
		if str(character.get("id", "")) == character_id:
			return str(character.get("name", character_id))
	return character_id


func _set_status(value: String) -> void:
	if status_label != null:
		status_label.text = value
		status_label.tooltip_text = value


func _drag_benchmark_path_point(frame_index: int, frame_count: int, luoyang_screen: Vector2, hulao_screen: Vector2) -> Vector2:
	var progress := clampf(float(frame_index) / maxf(1.0, float(frame_count - 1)), 0.0, 1.0)
	var point := luoyang_screen
	if progress < 0.12:
		point = (luoyang_screen + Vector2(-60.0, 0.0)).lerp(luoyang_screen, progress / 0.12)
	elif progress < 0.24:
		point = luoyang_screen.lerp(hulao_screen, (progress - 0.12) / 0.12)
	elif progress < 0.36:
		point = hulao_screen.lerp(hulao_screen + Vector2(60.0, 24.0), (progress - 0.24) / 0.12)
	else:
		var orbit_progress := (progress - 0.36) / 0.64
		var angle := orbit_progress * TAU * 2.0
		var center := map_board.size * Vector2(0.53, 0.50)
		var radius := Vector2(minf(map_board.size.x * 0.38, 430.0), minf(map_board.size.y * 0.34, 260.0))
		point = center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y)
	point.x = clampf(point.x, 52.0, maxf(52.0, map_board.size.x - 52.0))
	point.y = clampf(point.y, 42.0, maxf(42.0, map_board.size.y - 42.0))
	return point


func _drag_benchmark_timestamp() -> String:
	var now := Time.get_datetime_dict_from_system()
	return "%04d%02d%02d-%02d%02d%02d" % [
		int(now.get("year", 0)), int(now.get("month", 0)), int(now.get("day", 0)),
		int(now.get("hour", 0)), int(now.get("minute", 0)), int(now.get("second", 0))
	]


func _drag_benchmark_environment() -> Dictionary:
	var version: Dictionary = Engine.get_version_info()
	var viewport_size := get_viewport().get_visible_rect().size
	return {
		"godot_version": str(version.get("string", "unknown")),
		"os": OS.get_name(),
		"display_driver": DisplayServer.get_name(),
		"rendering_method": RenderingServer.get_current_rendering_method(),
		"rendering_driver": RenderingServer.get_current_rendering_driver_name(),
		"video_adapter_name": RenderingServer.get_video_adapter_name(),
		"video_adapter_vendor": RenderingServer.get_video_adapter_vendor(),
		"video_adapter_api_version": RenderingServer.get_video_adapter_api_version(),
		"screen_refresh_hz": DisplayServer.screen_get_refresh_rate(),
		"window_vsync_mode_actual": int(DisplayServer.window_get_vsync_mode()),
		"viewport_size": [roundi(viewport_size.x), roundi(viewport_size.y)],
		"window_size": [get_window().size.x, get_window().size.y]
	}


func _drag_benchmark_vector(value: Vector2) -> Array[float]:
	return [value.x, value.y]


func _drag_benchmark_rect(value: Rect2) -> Array[float]:
	return [value.position.x, value.position.y, value.size.x, value.size.y]


func _save_drag_benchmark_screenshot(output_path: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	return image.save_png(output_path) == OK


func _run_drag_benchmark() -> void:
	for _warmup in range(DRAG_BENCHMARK_SCENE_WARMUP_FRAMES):
		await get_tree().process_frame
	map_board.zoom = drag_benchmark_zoom
	var luoyang := _find_place("luoyang")
	var hulao := _find_place("hulao_pass")
	if luoyang.is_empty() or hulao.is_empty():
		push_error("拖拽基准缺少洛阳或虎牢关地点数据")
		get_tree().quit(2)
		return
	var midpoint_normalized := Vector2(
		(float(luoyang.get("x", 0.5)) + float(hulao.get("x", 0.5))) * 0.5,
		(float(luoyang.get("y", 0.5)) + float(hulao.get("y", 0.5))) * 0.5
	)
	var midpoint_world := map_board.map_normalized_to_world(midpoint_normalized)
	map_board.pan = map_board.size * 0.5 - midpoint_world * drag_benchmark_zoom
	map_board._apply_camera()
	_on_zoom_changed(drag_benchmark_zoom)
	for _cache_warmup in range(DRAG_BENCHMARK_CACHE_WARMUP_FRAMES):
		await get_tree().process_frame

	var cache_before: Dictionary = map_board.get_static_cache_state()
	var luoyang_screen := map_board.get_place_screen_position("luoyang")
	var hulao_screen := map_board.get_place_screen_position("hulao_pass")
	if not map_board.begin_drag_benchmark("liu_bei", luoyang_screen + Vector2(-60.0, 0.0)):
		push_error("无法启动刘备拖拽基准")
		get_tree().quit(2)
		return

	var candidate_transitions: Array[Dictionary] = []
	var last_candidate := ""
	var max_prompt_overlap_area := 0.0
	var total_profile_frames := drag_benchmark_frames + MapBoardScript.DRAG_WARMUP_FRAMES
	for frame_index in range(total_profile_frames):
		map_board.set_drag_benchmark_pointer(_drag_benchmark_path_point(frame_index, total_profile_frames, luoyang_screen, hulao_screen))
		await get_tree().process_frame
		var drag_state: Dictionary = map_board.get_drag_benchmark_state()
		var candidate_id := str(drag_state.get("candidate_id", ""))
		if candidate_id != last_candidate:
			candidate_transitions.append({"frame": frame_index, "from": last_candidate, "to": candidate_id})
			last_candidate = candidate_id
		var guide_contract: Dictionary = drag_state.get("guide", {})
		max_prompt_overlap_area = maxf(max_prompt_overlap_area, float(guide_contract.get("overlap_area", 0.0)))

	# 在候选提示显示时留一帧取证；额外帧不会进入已达到上限的性能样本。
	map_board.set_drag_benchmark_pointer(luoyang_screen + Vector2(0.0, 22.0))
	await get_tree().process_frame
	var evidence_state: Dictionary = map_board.get_drag_benchmark_state()
	var evidence_guide: Dictionary = evidence_state.get("guide", {})
	max_prompt_overlap_area = maxf(max_prompt_overlap_area, float(evidence_guide.get("overlap_area", 0.0)))

	var timestamp := _drag_benchmark_timestamp()
	var output_dir := ProjectSettings.globalize_path("res://artifacts/performance")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var base_name := "drag_windows_opengl_%dx%d_z%d_%s_run%d" % [
		drag_benchmark_window_size.x, drag_benchmark_window_size.y, roundi(drag_benchmark_zoom * 100.0), timestamp, drag_benchmark_run
	]
	var screenshot_path := output_dir.path_join("%s.png" % base_name)
	var screenshot_saved := await _save_drag_benchmark_screenshot(screenshot_path)
	var stats: Dictionary = map_board.finish_drag_benchmark()
	var cache_after: Dictionary = map_board.get_static_cache_state()
	var influence_before: Dictionary = cache_before.get("influence", {})
	var influence_after: Dictionary = cache_after.get("influence", {})
	var report := {
		"schema_version": 2,
		"benchmark_id": "character_drag_windows_opengl_influence_v2",
		"status": "measured",
		"terrain_visual_profile": map_board.get_terrain_visual_profile(),
		"protocol": {
			"scene_warmup_frames": DRAG_BENCHMARK_SCENE_WARMUP_FRAMES,
			"cache_warmup_frames": DRAG_BENCHMARK_CACHE_WARMUP_FRAMES,
			"drag_warmup_frames": MapBoardScript.DRAG_WARMUP_FRAMES,
			"measured_frames": drag_benchmark_frames,
			"character_id": "liu_bei",
			"zoom": drag_benchmark_zoom,
			"path_id": DRAG_BENCHMARK_PATH_ID,
			"scenario_id": str(scenario_state.get("scenario_id", "")),
			"influence_layer_required": true,
			"requested_window_size": [drag_benchmark_window_size.x, drag_benchmark_window_size.y],
			"run_index": drag_benchmark_run
		},
		"environment": _drag_benchmark_environment(),
		"metrics": stats,
		"snap": {
			"enter_radius_screen": MapBoardScript.SNAP_ENTER_RADIUS_SCREEN,
			"exit_radius_screen": MapBoardScript.SNAP_EXIT_RADIUS_SCREEN,
			"switch_advantage_screen": MapBoardScript.SNAP_SWITCH_ADVANTAGE_SCREEN,
			"candidate_transitions": candidate_transitions,
			"evidence_candidate_id": str(evidence_state.get("candidate_id", "")),
			"prompt_overlap_area_max": max_prompt_overlap_area,
			"evidence_guide": {
				"visible": bool(evidence_guide.get("visible", false)),
				"place_name": str(evidence_guide.get("place_name", "")),
				"target_position": _drag_benchmark_vector(evidence_guide.get("target_position", Vector2.ZERO)),
				"label_rect": _drag_benchmark_rect(evidence_guide.get("label_rect", Rect2())),
				"avoid_rect": _drag_benchmark_rect(evidence_guide.get("avoid_rect", Rect2())),
				"overlap_area": float(evidence_guide.get("overlap_area", 0.0))
			}
		},
		"cache_guard": {
			"static_builds_before": int(cache_before.get("static_builds", 0)),
			"static_builds_after": int(cache_after.get("static_builds", 0)),
			"annotation_builds_before": int(cache_before.get("annotation_builds", 0)),
			"annotation_builds_after": int(cache_after.get("annotation_builds", 0)),
			"influence_builds_before": int(influence_before.get("build_count", 0)),
			"influence_builds_after": int(influence_after.get("build_count", 0)),
			"influence_rebuild_ms": float(influence_after.get("last_rebuild_ms", 0.0)),
			"influence_visible": bool(influence_after.get("visible", false))
		},
		"artifacts": {
			"screenshot_path": screenshot_path,
			"screenshot_saved": screenshot_saved
		},
		"save_isolation": {
			"save_path": save_path,
			"preferences_path": preferences_path,
			"snapshot_store_path": snapshot_store_path,
			"personal_template_store_path": personal_template_store_path,
			"writes_performed": false
		}
	}
	var json_path := output_dir.path_join("%s.json" % base_name)
	var output := FileAccess.open(json_path, FileAccess.WRITE)
	if output == null:
		push_error("无法写入拖拽基准结果：%s" % json_path)
		get_tree().quit(2)
		return
	output.store_string(JSON.stringify(report, "\t"))
	output.close()
	print("DRAG_BENCHMARK_RESULT_JSON:%s" % json_path)
	print("DRAG_BENCHMARK_RESULT samples=%d avg_fps=%.1f p95=%.2fms slow=%.2f%% update_p95=%.3fms overlap=%.1f" % [
		int(stats.get("frames", 0)), float(stats.get("average_fps", 0.0)), float(stats.get("p95_frame_ms", 0.0)),
		float(stats.get("slow_33ms_percent", 0.0)), float(stats.get("update_p95_ms", 0.0)), max_prompt_overlap_area
	])
	get_tree().quit(0)


func _capture_after_frames() -> void:
	for _i in range(5):
		await get_tree().process_frame
	if not capture_faction_influence_override.is_empty() and map_board != null:
		map_board.set_faction_influence_visible(capture_faction_influence_override == "on")
	if not capture_scenario_id.is_empty() and map_board != null and map_board._faction_influence_layer != null:
		print("CAPTURE_INFLUENCE_STATE:%s" % JSON.stringify(map_board._faction_influence_layer.get_cache_state()))
	if capture_zoom > 0.0:
		map_board.zoom = capture_zoom
		var focus_normalized := _capture_v3_point(Vector2(0.64, 0.36))
		var capture_target_place_id := capture_focus_place_id if not capture_focus_place_id.is_empty() else capture_hover_place_id
		var place_focus_applied := (
			not capture_target_place_id.is_empty()
			and map_board.focus_place(capture_target_place_id)
		)
		if not place_focus_applied:
			var focus_world := map_board.map_normalized_to_world(focus_normalized)
			var focus_camera: Dictionary = map_board.get_focus_camera_state(focus_world)
			map_board.pan = Vector2(
				float(focus_camera.get("x", map_board.pan.x)),
				float(focus_camera.get("y", map_board.pan.y))
			)
			map_board._apply_camera()
		_on_zoom_changed(capture_zoom)
		await get_tree().process_frame
		await get_tree().process_frame
	else:
		var capture_template := {"scenario_id": str(scenario_state.get("scenario_id", ""))}
		map_board.set_camera_state(_scenario_opening_camera_state(capture_template, placements))
		await get_tree().process_frame
		await get_tree().process_frame
	if not capture_hover_place_id.is_empty():
		var hover_place := _find_place(capture_hover_place_id)
		if not hover_place.is_empty():
			var hover_normalized := Vector2(float(hover_place.get("x", 0.5)), float(hover_place.get("y", 0.5)))
			var hover_screen := map_board.pan + map_board.map_normalized_to_world(hover_normalized) * map_board.zoom
			map_board._update_place_hover(hover_screen)
			await get_tree().process_frame
	if not capture_dialog.is_empty():
		sandbox_metadata["title"] = "我的蜀汉"
		sandbox_metadata["note"] = "刘关张从涿郡起兵，按自己的想法推演天下。"
		sandbox_metadata["scenario_source"] = "黄巾起义（184 年）"
		_refresh_sandbox_identity_view()
		match capture_dialog:
			"place-search":
				_open_place_search_dialog()
				place_search_input.text = "南郑"
				_refresh_place_search_results()
			"backpack-placed-search":
				backpack.set_search_query("刘备")
			"backpack-bottom":
				var capture_scroll := backpack.get_scroll_container()
				if capture_scroll != null:
					await get_tree().process_frame
					capture_scroll.scroll_vertical = ceili(capture_scroll.get_v_scroll_bar().max_value)
			"backpack-alias-search":
				backpack.set_search_query("周郎")
			"backpack-collapsed":
				_collapse_backpack()
			"backpack-hand-3", "backpack-hand-8", "backpack-hand-8-folded", "backpack-hand-mixed":
				placements.clear()
				annotations.clear()
				_refresh_views()
				var hand_capture_ids: Array[String] = [
					"liu_bei", "guan_yu", "zhang_fei", "zhao_yun",
					"cao_cao", "sun_jian", "zhang_jiao", "lv_bu"
				]
				var hand_capture_count := 3 if capture_dialog == "backpack-hand-3" else 8
				for hand_capture_index in range(hand_capture_count):
					backpack.add_hand_candidate(hand_capture_ids[hand_capture_index])
				if capture_dialog == "backpack-hand-mixed":
					placements["liu_bei"] = _capture_v3_xy(Vector2(0.48, 0.43))
					placements["guan_yu"] = _capture_v3_xy(Vector2(0.52, 0.46))
					placements["zhang_fei"] = _capture_v3_xy(Vector2(0.50, 0.50))
					_refresh_views()
				if capture_dialog == "backpack-hand-8-folded":
					backpack.set_hand_tray_expanded(false)
				var hand_pending_count := hand_capture_count - 3 if capture_dialog == "backpack-hand-mixed" else hand_capture_count
				_set_status("手边验收 · 待摆 %d · 已摆 %d · 共 %d 人" % [
					hand_pending_count,
					hand_capture_count - hand_pending_count,
					hand_capture_count
				])
			"personal-template-edit":
				var zhuo_capture_place := _find_place("zhuo")
				placements = {
					"liu_bei": {
						"x": float(zhuo_capture_place.get("x", 0.5)),
						"y": float(zhuo_capture_place.get("y", 0.5)),
						"place_id": "zhuo"
					},
					"guan_yu": _capture_v3_xy(Vector2(0.42, 0.36)),
					"zhang_fei": _capture_v3_xy(Vector2(0.44, 0.39))
				}
				annotations = {}
				scenario_state = _capture_custom_scenario_state(
					[{"id": "play_liu_capture", "name": "刘备一行", "color": "#0077BB"}],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_capture"},
						{"character_id": "guan_yu", "faction_id": "play_liu_capture"},
						{"character_id": "zhang_fei", "faction_id": "play_liu_capture"}
					]
				)
				_refresh_views()
				var capture_template_result := _build_current_personal_template_record("涿郡起步", "刘关张从涿郡开始，由玩家继续推演。")
				if bool(capture_template_result.get("ok", false)):
					var capture_template: Dictionary = capture_template_result.get("template", {}).duplicate(true)
					personal_scenario_templates = [capture_template]
					_open_personal_template_edit_dialog(str(capture_template.get("id", "")))
			"city-faction-windows", "city-faction-windows-collapsed", "city-faction-details-hidden", "city-faction-attributes", "city-faction-zoom-cycle":
				var luoyang_capture_placement := _capture_place_placement("luoyang", Vector2(0.570361, 0.315373))
				for capture_character_id in ["liu_bei", "guan_yu", "zhang_fei", "zhang_jiao", "zhao_yun"]:
					placements[capture_character_id] = luoyang_capture_placement.duplicate(true)
				scenario_state = _capture_custom_scenario_state(
					[
						{"id": "play_liu_bei_demo", "name": "刘备一行", "color": "#0077BB"},
						{"id": "play_yellow_turban_demo", "name": "黄巾军", "color": "#EE7733"}
					],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_bei_demo"},
						{"character_id": "guan_yu", "faction_id": "play_liu_bei_demo"},
						{"character_id": "zhang_fei", "faction_id": "play_liu_bei_demo"},
						{"character_id": "zhang_jiao", "faction_id": "play_yellow_turban_demo"}
					]
				)
				if capture_dialog in ["city-faction-attributes", "city-faction-zoom-cycle"]:
					character_states = {
						"liu_bei": {"state_schema": CHARACTER_STATE_SCHEMA_FOUR_DIMENSIONS, "might": 86, "intelligence": 84, "leadership": 88, "charisma": 98},
						"guan_yu": {"state_schema": CHARACTER_STATE_SCHEMA_FOUR_DIMENSIONS, "might": 99, "intelligence": 78, "leadership": 94, "charisma": 90},
						"zhang_jiao": {"state_schema": CHARACTER_STATE_SCHEMA_FOUR_DIMENSIONS, "might": 58, "intelligence": 91, "leadership": 86, "charisma": 97}
					}
				_refresh_views()
				if capture_dialog == "city-faction-windows-collapsed":
					for capture_window_state in map_board.get_city_faction_window_state("luoyang"):
						if str(capture_window_state.get("faction_id", "")) == "play_liu_bei_demo":
							map_board.set_city_faction_group_collapsed(str(capture_window_state.get("group_key", "")), true)
							break
				elif capture_dialog == "city-faction-details-hidden":
					map_board.set_city_faction_details_visible(false)
				elif capture_dialog == "city-faction-zoom-cycle":
					map_board.zoom = 0.52
					map_board._apply_camera()
					await get_tree().process_frame
					map_board.zoom = maxf(0.75, capture_zoom)
					map_board._apply_camera()
					_on_zoom_changed(map_board.zoom)
			"dense-mixed-12", "dense-mixed-12-summary", "dense-mixed-12-focus", "dense-mixed-12-overlap":
				var luoyang_dense_placement := _capture_place_placement("luoyang", Vector2(0.570361, 0.315373))
				for dense_city_character_id in ["liu_bei", "guan_yu", "zhang_fei", "zhang_jiao", "zhao_yun", "cao_cao"]:
					placements[dense_city_character_id] = luoyang_dense_placement.duplicate(true)
				var dense_free_positions := {
					"jian_yong": Vector2(0.505, 0.270),
					"sun_qian": Vector2(0.535, 0.255),
					"xiahou_dun": Vector2(0.615, 0.255),
					"sun_jian": Vector2(0.505, 0.385),
					"sun_ce": Vector2(0.545, 0.405),
					"huang_gai": Vector2(0.620, 0.395)
				}
				if capture_dialog == "dense-mixed-12-overlap":
					dense_free_positions["jian_yong"] = Vector2(0.515, 0.285)
					dense_free_positions["sun_qian"] = Vector2(0.515, 0.285)
					dense_free_positions["xiahou_dun"] = Vector2(0.515, 0.285)
				for dense_free_character_id_value in dense_free_positions:
					var dense_free_character_id := str(dense_free_character_id_value)
					placements[dense_free_character_id] = _capture_v3_xy(dense_free_positions[dense_free_character_id])
				scenario_state = _capture_custom_scenario_state(
					[
						{"id": "play_liu_dense", "name": "刘备一行", "color": "#3F8F68"},
						{"id": "play_yellow_dense", "name": "黄巾军", "color": "#D09A2C"},
						{"id": "play_cao_dense", "name": "曹操军", "color": "#B8564F"},
						{"id": "play_sun_dense", "name": "孙氏一行", "color": "#4B83A6"}
					],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_dense"},
						{"character_id": "guan_yu", "faction_id": "play_liu_dense"},
						{"character_id": "zhang_fei", "faction_id": "play_liu_dense"},
						{"character_id": "jian_yong", "faction_id": "play_liu_dense"},
						{"character_id": "sun_qian", "faction_id": "play_liu_dense"},
						{"character_id": "zhang_jiao", "faction_id": "play_yellow_dense"},
						{"character_id": "cao_cao", "faction_id": "play_cao_dense"},
						{"character_id": "xiahou_dun", "faction_id": "play_cao_dense"},
						{"character_id": "sun_jian", "faction_id": "play_sun_dense"},
						{"character_id": "sun_ce", "faction_id": "play_sun_dense"},
						{"character_id": "huang_gai", "faction_id": "play_sun_dense"}
					]
				)
				annotations = {
					"dense_reinforcement": {
						"id": "dense_reinforcement", "kind": "marker", "marker_type": "note",
						"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
						"verification_status": ANNOTATION_VERIFICATION_STATUS,
						"x": 0.475, "y": 0.315, "label": "援军", "style": "jade", "faction_id": "play_liu_dense"
					},
					"dense_retreat": {
						"id": "dense_retreat", "kind": "marker", "marker_type": "note",
						"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
						"verification_status": ANNOTATION_VERIFICATION_STATUS,
						"x": 0.650, "y": 0.335, "label": "撤退点", "style": "amber", "faction_id": ""
					}
				}
				if capture_dialog == "dense-mixed-12-focus":
					var dense_focus_placement: Dictionary = placements.get("jian_yong", {})
					annotations["dense_reinforcement"]["x"] = float(dense_focus_placement.get("x", 0.505))
					annotations["dense_reinforcement"]["y"] = float(dense_focus_placement.get("y", 0.270))
				_refresh_views()
				if capture_dialog in ["dense-mixed-12-summary", "dense-mixed-12-focus", "dense-mixed-12-overlap"]:
					map_board.set_city_faction_details_visible(false)
				if capture_dialog == "dense-mixed-12-focus":
					map_board._on_map_card_selected("jian_yong")
					var dense_focus_card: CharacterCard = map_board.get_character_card("jian_yong")
					if dense_focus_card != null:
						dense_focus_card.set_hovered(true)
					_set_status("人物聚焦验收 · 简雍置顶／局部遮挡降权／位置不变")
				elif capture_dialog == "dense-mixed-12-overlap":
					map_board.open_character_context_menu("jian_yong", map_board.size * Vector2(0.47, 0.28))
					await get_tree().process_frame
					if map_board._character_overlap_menu != null and map_board._character_context_menu != null:
						map_board._character_overlap_menu.position = (
							map_board._character_context_menu.position
							+ Vector2i(map_board._character_context_menu.size.x - 4, 34)
						)
						map_board._character_overlap_menu.popup()
					_set_status("完全重叠人物 · 右键直接切换／卡牌位置不变")
				else:
					_set_status("12 人混合落位验收 · 6 人驻洛阳／6 人自由摆放／2 个玩家标记")
			"character-troop-menu", "character-troop-menu-edge":
				placements = {
					"liu_bei": _capture_v3_xy(Vector2(0.55, 0.50)),
					"guan_yu": _capture_v3_xy(Vector2(0.62, 0.50))
				}
				scenario_state = _capture_custom_scenario_state(
					[{"id": "play_liu_troop_demo", "name": "刘备一行", "color": "#3F8F68"}],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_troop_demo"},
						{"character_id": "guan_yu", "faction_id": "play_liu_troop_demo"}
					]
				)
				character_troops = {"liu_bei": CHARACTER_TROOP_MAX, "guan_yu": 3200}
				character_actions = {"guan_yu": CHARACTER_ACTION_DEFEND}
				_refresh_views()
				var troop_popup_position := map_board.size * Vector2(0.52, 0.34)
				if capture_dialog == "character-troop-menu-edge":
					troop_popup_position = map_board.size - Vector2(18, 18)
				map_board.open_character_context_menu("liu_bei", troop_popup_position)
				await get_tree().process_frame
				if map_board._character_troop_menu != null and map_board._character_context_menu != null:
					map_board._character_troop_menu.position = (
						map_board._character_context_menu.position
						+ Vector2i(map_board._character_context_menu.size.x - 4, 42)
					)
					map_board._character_troop_menu.popup()
				_set_status("刘备 · 兵力 999,999 · 右键就地快调")
			"character-actions", "character-action-menu", "character-action-details", "character-faction-menu":
				var action_capture_placement := _capture_place_placement("luoyang", Vector2(0.570361, 0.315373))
				for capture_character_id in ["liu_bei", "guan_yu", "zhang_fei", "zhang_jiao"]:
					placements[capture_character_id] = action_capture_placement.duplicate(true)
				scenario_state = _capture_custom_scenario_state(
					[
						{"id": "play_liu_action_demo", "name": "刘备一行", "color": "#0077BB"},
						{"id": "play_yellow_action_demo", "name": "黄巾军", "color": "#EE7733"}
					],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_action_demo"},
						{"character_id": "guan_yu", "faction_id": "play_liu_action_demo"},
						{"character_id": "zhang_fei", "faction_id": "play_liu_action_demo"},
						{"character_id": "zhang_jiao", "faction_id": "play_yellow_action_demo"}
					]
				)
				character_actions = {"liu_bei": CHARACTER_ACTION_ATTACK, "guan_yu": CHARACTER_ACTION_DEFEND}
				_refresh_views()
				if capture_dialog == "character-action-menu":
					map_board.open_character_context_menu("liu_bei", map_board.size * Vector2(0.52, 0.44))
				elif capture_dialog == "character-faction-menu":
					map_board.open_character_context_menu("liu_bei", map_board.size * Vector2(0.42, 0.40))
					await get_tree().process_frame
					if map_board._character_faction_menu != null and map_board._character_context_menu != null:
						var faction_menu_position := map_board._character_context_menu.position + Vector2i(
							map_board._character_context_menu.size.x - 4,
							94
						)
						map_board._character_faction_menu.position = faction_menu_position
						map_board._character_faction_menu.popup()
				elif capture_dialog == "character-action-details":
					_on_character_details_requested("liu_bei")
			"character-force-markers", "character-troops-dialog", "character-force-details":
				var force_capture_positions := {
					"liu_bei": Vector2(0.48, 0.42),
					"guan_yu": Vector2(0.58, 0.42),
					"zhang_fei": Vector2(0.48, 0.51),
					"cao_cao": Vector2(0.58, 0.51),
					"sun_jian": Vector2(0.48, 0.60),
					"zhang_jiao": Vector2(0.58, 0.60),
					"zhou_yu": Vector2(0.68, 0.51)
				}
				placements.clear()
				annotations.clear()
				player_strokes.clear()
				for force_character_id in force_capture_positions:
					placements[force_character_id] = _capture_v3_xy(force_capture_positions[force_character_id])
				scenario_state = _capture_custom_scenario_state(
					[
						{"id": "play_liu_force_demo", "name": "刘备军", "color": "#3F8F68"},
						{"id": "play_cao_force_demo", "name": "曹操军", "color": "#B8564F"},
						{"id": "play_sun_force_demo", "name": "孙氏军", "color": "#4B83A6"},
						{"id": "play_yellow_force_demo", "name": "黄巾军", "color": "#C99A28"}
					],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_force_demo"},
						{"character_id": "guan_yu", "faction_id": "play_liu_force_demo"},
						{"character_id": "zhang_fei", "faction_id": "play_liu_force_demo"},
						{"character_id": "cao_cao", "faction_id": "play_cao_force_demo"},
						{"character_id": "sun_jian", "faction_id": "play_sun_force_demo"},
						{"character_id": "zhou_yu", "faction_id": "play_sun_force_demo"},
						{"character_id": "zhang_jiao", "faction_id": "play_yellow_force_demo"}
					]
				)
				character_troops = {
					"guan_yu": 3200,
					"zhang_fei": 850,
					"cao_cao": 12600,
					"sun_jian": 5400,
					"zhang_jiao": 18000,
					"zhou_yu": 2750
				}
				character_actions = {
					"guan_yu": CHARACTER_ACTION_ATTACK,
					"cao_cao": CHARACTER_ACTION_DEFEND
				}
				_refresh_views()
				map_board._clear_map_selection()
				_set_status("人物地图标记验收：名牌、姓名、兵力与行动")
				if capture_dialog == "character-troops-dialog":
					_on_character_troops_requested("liu_bei")
				elif capture_dialog == "character-force-details":
					_on_character_details_requested("liu_bei")
			"character-portraits-batch05":
				var batch_05_capture_positions := {
					"zhu_jun": Vector2(0.46, 0.42),
					"hua_xiong": Vector2(0.56, 0.42),
					"gongsun_zan": Vector2(0.66, 0.42),
					"tao_qian": Vector2(0.46, 0.54),
					"wang_yun": Vector2(0.56, 0.54),
					"jia_xu": Vector2(0.66, 0.54)
				}
				placements.clear()
				annotations.clear()
				player_strokes.clear()
				for batch_05_character_id in batch_05_capture_positions:
					placements[batch_05_character_id] = _capture_v3_xy(
						batch_05_capture_positions[batch_05_character_id]
					)
				scenario_state = _capture_custom_scenario_state(
					[
						{"id": "play_han_batch05", "name": "汉军", "color": "#3F8F68"},
						{"id": "play_dong_batch05", "name": "董卓军", "color": "#B8564F"},
						{"id": "play_local_batch05", "name": "地方诸侯", "color": "#4B83A6"}
					],
					[
						{"character_id": "zhu_jun", "faction_id": "play_han_batch05"},
						{"character_id": "wang_yun", "faction_id": "play_han_batch05"},
						{"character_id": "hua_xiong", "faction_id": "play_dong_batch05"},
						{"character_id": "jia_xu", "faction_id": "play_dong_batch05"},
						{"character_id": "gongsun_zan", "faction_id": "play_local_batch05"},
						{"character_id": "tao_qian", "faction_id": "play_local_batch05"}
					]
				)
				character_troops = {
					"zhu_jun": 12000,
					"hua_xiong": 5400,
					"gongsun_zan": 8600,
					"tao_qian": 2300,
					"wang_yun": 1000,
					"jia_xu": 1800
				}
				character_actions = {
					"zhu_jun": CHARACTER_ACTION_DEFEND,
					"hua_xiong": CHARACTER_ACTION_ATTACK
				}
				_refresh_views()
				map_board._clear_map_selection()
				_set_status("批次 05 历史素材核对 · 当前运行界面使用人物名牌")
			"character-portraits-batch06":
				var batch_06_capture_positions := {
					"ma_teng": Vector2(0.44, 0.40),
					"han_sui": Vector2(0.56, 0.40),
					"liu_yan": Vector2(0.68, 0.40),
					"zhang_lu": Vector2(0.44, 0.49),
					"he_jin": Vector2(0.56, 0.49),
					"kong_rong": Vector2(0.68, 0.49)
				}
				placements.clear()
				annotations.clear()
				player_strokes.clear()
				for batch_06_character_id in batch_06_capture_positions:
					placements[batch_06_character_id] = _capture_v3_xy(
						batch_06_capture_positions[batch_06_character_id]
					)
				scenario_state = _capture_custom_scenario_state(
					[
						{"id": "play_west_batch06", "name": "西凉军", "color": "#A97439"},
						{"id": "play_yizhou_batch06", "name": "益州军", "color": "#3F8F68"},
						{"id": "play_han_batch06", "name": "汉军", "color": "#B8564F"},
						{"id": "play_beihai_batch06", "name": "北海军", "color": "#4B83A6"}
					],
					[
						{"character_id": "ma_teng", "faction_id": "play_west_batch06"},
						{"character_id": "han_sui", "faction_id": "play_west_batch06"},
						{"character_id": "liu_yan", "faction_id": "play_yizhou_batch06"},
						{"character_id": "zhang_lu", "faction_id": "play_yizhou_batch06"},
						{"character_id": "he_jin", "faction_id": "play_han_batch06"},
						{"character_id": "kong_rong", "faction_id": "play_beihai_batch06"}
					]
				)
				character_troops = {
					"ma_teng": 16000,
					"han_sui": 12500,
					"liu_yan": 50000,
					"zhang_lu": 10000,
					"he_jin": 100000,
					"kong_rong": 6800
				}
				character_actions = {
					"ma_teng": CHARACTER_ACTION_ATTACK,
					"han_sui": CHARACTER_ACTION_STANDBY,
					"liu_yan": CHARACTER_ACTION_DEFEND,
					"zhang_lu": CHARACTER_ACTION_STANDBY,
					"he_jin": CHARACTER_ACTION_DEFEND,
					"kong_rong": CHARACTER_ACTION_STANDBY
				}
				_refresh_views()
				map_board._clear_map_selection()
				_set_status("批次 06 历史素材核对 · 当前运行界面使用人物名牌")
			"m2-d30-overview":
				var overview_capture_zoom := maxf(map_board.zoom, MapBoardScript.MIN_ZOOM)
				var overview_is_compact := overview_capture_zoom < MapBoardScript.CITY_FACTION_COMPACT_ZOOM
				var overview_dx := 0.006 if overview_is_compact else 0.075 / overview_capture_zoom
				var overview_dy := 0.006 if overview_is_compact else 0.052 / overview_capture_zoom
				# 视觉验收中的两枚援军签保持约 180px 左移，并在各档落在人物组上方。
				# 只调整 --capture 固定装置，不改变玩家沙盘、剧本或正式坐标。
				var overview_marker_dx := 0.14 if overview_is_compact else 0.12 / overview_capture_zoom
				var overview_marker_top_dy := 0.07 if overview_is_compact else 0.07 / overview_capture_zoom
				var overview_marker_gap_dy := 0.05 if overview_is_compact else 0.04 / overview_capture_zoom
				placements = {
					"liu_bei": _capture_v3_xy(Vector2(0.50 - overview_dx, 0.50 - overview_dy)),
					"guan_yu": _capture_v3_xy(Vector2(0.50 + overview_dx, 0.50 - overview_dy)),
					"zhang_fei": _capture_v3_xy(Vector2(0.50 - overview_dx, 0.50 + overview_dy)),
					"cao_cao": _capture_v3_xy(Vector2(0.50 + overview_dx, 0.50 + overview_dy))
				}
				scenario_state = _capture_custom_scenario_state(
					[
						{"id": "play_liu_m2d30_capture", "name": "刘备军", "color": "#3F8F68"},
						{"id": "play_cao_m2d30_capture", "name": "曹操军", "color": "#B8564F"}
					],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_m2d30_capture"},
						{"character_id": "guan_yu", "faction_id": "play_liu_m2d30_capture"},
						{"character_id": "zhang_fei", "faction_id": "play_liu_m2d30_capture"},
						{"character_id": "cao_cao", "faction_id": "play_cao_m2d30_capture"}
					],
					[
						{"place_id": "hanzhong", "faction_id": "play_liu_m2d30_capture"},
						{"place_id": "xiangyang", "faction_id": "play_liu_m2d30_capture"},
						{"place_id": "luoyang", "faction_id": "play_cao_m2d30_capture"},
						{"place_id": "xuchang", "faction_id": "play_cao_m2d30_capture"}
					]
				)
				annotations = {
					"marker_m2d30_liu": {
						"id": "marker_m2d30_liu",
						"kind": "marker",
						"marker_type": "note",
						"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
						"verification_status": ANNOTATION_VERIFICATION_STATUS,
						"x": 0.50 - overview_marker_dx,
						"y": 0.50 - overview_marker_top_dy,
						"label": "援军",
						"style": "jade",
						"faction_id": "play_liu_m2d30_capture"
					},
					"marker_m2d30_unassigned": {
						"id": "marker_m2d30_unassigned",
						"kind": "marker",
						"marker_type": "note",
						"semantic_layer": ANNOTATION_SEMANTIC_LAYER,
						"verification_status": ANNOTATION_VERIFICATION_STATUS,
						"x": 0.50 - overview_marker_dx,
						"y": 0.50 - overview_marker_top_dy + overview_marker_gap_dy,
						"label": "援军",
						"style": "amber",
						"faction_id": ""
					}
				}
				character_troops = {
					"guan_yu": 3200,
					"zhang_fei": 850,
					"cao_cao": 12600
				}
				_refresh_views()
				map_board._clear_map_selection()
				_set_status(
					"%d%% · 远景军势与势力归属验收"
					% roundi(map_board.zoom * 100.0)
				)
			"character-group-selection", "character-group-context", "character-group-context-edge":
				placements = {
					"liu_bei": _capture_v3_xy(Vector2(0.45, 0.47)),
					"guan_yu": _capture_v3_xy(Vector2(0.52, 0.43)),
					"zhang_fei": _capture_v3_xy(Vector2(0.49, 0.54))
				}
				scenario_state = _capture_custom_scenario_state(
					[{"id": "play_liu_group_demo", "name": "刘备一行", "color": "#0077BB"}],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_group_demo"},
						{"character_id": "guan_yu", "faction_id": "play_liu_group_demo"},
						{"character_id": "zhang_fei", "faction_id": "play_liu_group_demo"}
					]
				)
				character_actions = {
					"liu_bei": CHARACTER_ACTION_STANDBY,
					"guan_yu": CHARACTER_ACTION_ATTACK,
					"zhang_fei": CHARACTER_ACTION_DEFEND
				}
				_refresh_views()
				map_board._on_map_card_selected("liu_bei")
				map_board._on_map_card_selected("guan_yu", true)
				map_board._on_map_card_selected("zhang_fei", true)
				if capture_dialog in ["character-group-context", "character-group-context-edge"]:
					var group_context_position := map_board.size * Vector2(0.58, 0.40)
					if capture_dialog == "character-group-context-edge":
						group_context_position = map_board.size - Vector2(18.0, 24.0)
					map_board.open_character_context_menu("guan_yu", group_context_position)
					await get_tree().process_frame
					if map_board._character_action_menu != null and map_board._character_context_menu != null:
						map_board._character_action_menu.position = (
							map_board._character_context_menu.position
							+ Vector2i(map_board._character_context_menu.size.x - 4, 42)
						)
						map_board._character_action_menu.popup()
			"deep-zoom-placement", "ultra-zoom-placement":
				var luoyang_deep_zoom := _find_place("luoyang")
				var deep_zoom_center := Vector2(
					float(luoyang_deep_zoom.get("x", 0.5)),
					float(luoyang_deep_zoom.get("y", 0.5))
				)
				var deep_zoom_character_ids: Array[String] = []
				var deep_zoom_offsets: Array[Vector2] = []
				if capture_dialog == "ultra-zoom-placement":
					deep_zoom_character_ids = [
						"liu_bei", "guan_yu", "zhang_fei", "jian_yong",
						"sun_qian", "zhao_yun", "cao_cao", "xiahou_dun",
						"xiahou_yuan", "sun_jian", "sun_ce", "huang_gai"
					]
					deep_zoom_offsets = [
						Vector2(-0.060, -0.042), Vector2(-0.020, -0.042), Vector2(0.020, -0.042), Vector2(0.060, -0.042),
						Vector2(-0.060, 0.0), Vector2(-0.020, 0.0), Vector2(0.020, 0.0), Vector2(0.060, 0.0),
						Vector2(-0.060, 0.042), Vector2(-0.020, 0.042), Vector2(0.020, 0.042), Vector2(0.060, 0.042)
					]
				else:
					deep_zoom_character_ids = [
						"liu_bei", "guan_yu", "zhang_fei",
						"jian_yong", "sun_qian", "zhao_yun",
						"cao_cao", "xiahou_dun", "xiahou_yuan"
					]
					deep_zoom_offsets = [
						Vector2(-0.045, -0.042), Vector2(0.0, -0.042), Vector2(0.045, -0.042),
						Vector2(-0.045, 0.0), Vector2(0.0, 0.0), Vector2(0.045, 0.0),
						Vector2(-0.045, 0.042), Vector2(0.0, 0.042), Vector2(0.045, 0.042)
					]
				placements.clear()
				var deep_zoom_assignments: Array = []
				for deep_zoom_index in range(deep_zoom_character_ids.size()):
					var deep_zoom_position: Vector2 = deep_zoom_center + deep_zoom_offsets[deep_zoom_index]
					var deep_zoom_character_id := deep_zoom_character_ids[deep_zoom_index]
					placements[deep_zoom_character_id] = {
						"x": deep_zoom_position.x,
						"y": deep_zoom_position.y
					}
					var deep_zoom_faction_id := "play_liu_deep_zoom"
					if deep_zoom_index >= 9:
						deep_zoom_faction_id = "play_sun_deep_zoom"
					elif deep_zoom_index >= 6:
						deep_zoom_faction_id = "play_cao_deep_zoom"
					deep_zoom_assignments.append({
						"character_id": deep_zoom_character_id,
						"faction_id": deep_zoom_faction_id
					})
				var deep_zoom_factions: Array = [
					{"id": "play_liu_deep_zoom", "name": "刘备一行", "color": "#4E9B73"},
					{"id": "play_cao_deep_zoom", "name": "曹操军", "color": "#B8564F"}
				]
				if capture_dialog == "ultra-zoom-placement":
					deep_zoom_factions.append(
						{"id": "play_sun_deep_zoom", "name": "孙氏一行", "color": "#4B83A6"}
					)
				scenario_state = _capture_custom_scenario_state(
					deep_zoom_factions,
					deep_zoom_assignments
				)
				_refresh_views()
				_set_status(
					"%d%% 超近景 · 人物卡保持原尺寸，摆放间距继续扩大"
					% roundi(map_board.zoom * 100.0)
				)
			"character-snap-bypass":
				var luoyang_bypass_place := _find_place("luoyang")
				var luoyang_bypass_normalized := Vector2(
					float(luoyang_bypass_place.get("x", 0.5)),
					float(luoyang_bypass_place.get("y", 0.5))
				)
				var luoyang_bypass_screen := (
					map_board.pan
					+ map_board.map_normalized_to_world(luoyang_bypass_normalized) * map_board.zoom
					+ Vector2(-18.0, 8.0)
				)
				var bypass_capture_result: Dictionary = map_board._resolve_drop_at_screen(luoyang_bypass_screen, true)
				var bypass_capture_normalized: Vector2 = bypass_capture_result.get("normalized", luoyang_bypass_normalized)
				placements = {
					"liu_bei": {
						"x": bypass_capture_normalized.x,
						"y": bypass_capture_normalized.y
					}
				}
				scenario_state = _capture_custom_scenario_state(
					[{"id": "play_liu_bypass_demo", "name": "刘备一行", "color": "#0077BB"}],
					[{"character_id": "liu_bei", "faction_id": "play_liu_bypass_demo"}]
				)
				_refresh_views()
				_set_status("已自由摆放 刘备 · Alt 已跳过城池吸附")
			"annotation":
				_on_annotation_create_requested(_capture_v3_point(Vector2(0.52, 0.50)))
				annotation_type_select.select(1)
				_on_annotation_type_selected(1)
				annotation_input.text = "卧龙岗别院"
			"annotation-manager":
				map_board.show_annotation_manager_menu()
			"place-details":
				var detail_place_id := capture_hover_place_id if not capture_hover_place_id.is_empty() else "guandu_battlefield"
				_open_place_detail_panel(detail_place_id)
			"place-chronicle-source":
				_open_place_detail_panel("luoyang")
			"place-chronicle-editor":
				_open_place_detail_panel("luoyang")
				_open_place_chronicle_editor()
			"place-relation":
				_open_place_detail_panel("luoyang")
				_on_place_detail_meta_clicked("place:hulao_pass")
			"place-relation-context":
				_open_place_detail_panel("luoyang")
			"place-relation-chain":
				_open_place_detail_panel("luoyang")
				_on_place_detail_meta_clicked("place:hulao_pass")
				_on_context_switch_place_pressed()
				_on_place_detail_meta_clicked("place:chenliu")
			"place-character-links":
				var luoyang_character_link_placement := _capture_place_placement("luoyang", Vector2(0.57, 0.32))
				placements = {
					"liu_bei": luoyang_character_link_placement.duplicate(true),
					"guan_yu": luoyang_character_link_placement.duplicate(true),
					"zhang_jiao": luoyang_character_link_placement.duplicate(true),
				}
				character_actions = {
					"liu_bei": CHARACTER_ACTION_ATTACK,
					"guan_yu": CHARACTER_ACTION_DEFEND,
					"zhang_jiao": CHARACTER_ACTION_STANDBY,
				}
				character_troops = {
					"liu_bei": 1000,
					"guan_yu": 5000,
					"zhang_jiao": 10000,
				}
				scenario_state = _capture_custom_scenario_state(
					[
						{"id": "play_liu_character_links", "name": "刘备一行", "color": "#4E9B73"},
						{"id": "play_yellow_character_links", "name": "黄巾军", "color": "#D4A62A"},
					],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_character_links"},
						{"character_id": "guan_yu", "faction_id": "play_liu_character_links"},
						{"character_id": "zhang_jiao", "faction_id": "play_yellow_character_links"},
					],
					[{"place_id": "luoyang", "faction_id": "play_liu_character_links"}]
				)
				_refresh_views()
				_open_place_detail_panel("luoyang")
				_on_place_detail_meta_clicked("character:guan_yu")
			"current-roster", "current-roster-place":
				var luoyang_roster_placement := _capture_place_placement("luoyang", Vector2(0.57, 0.32))
				var chenliu_roster_placement := _capture_place_placement("chenliu", Vector2(0.63, 0.38))
				placements = {
					"liu_bei": luoyang_roster_placement.duplicate(true),
					"guan_yu": luoyang_roster_placement.duplicate(true),
					"zhang_fei": _capture_v3_xy(Vector2(0.52, 0.43)),
					"cao_cao": chenliu_roster_placement.duplicate(true),
					"xiahou_dun": chenliu_roster_placement.duplicate(true),
					"sun_jian": _capture_place_placement("changsha", Vector2(0.69, 0.70)),
					"zhang_jiao": _capture_place_placement("guangzong", Vector2(0.69, 0.24)),
				}
				character_actions = {
					"liu_bei": CHARACTER_ACTION_STANDBY,
					"guan_yu": CHARACTER_ACTION_ATTACK,
					"zhang_fei": CHARACTER_ACTION_DEFEND,
					"cao_cao": CHARACTER_ACTION_ATTACK,
					"xiahou_dun": CHARACTER_ACTION_DEFEND,
					"sun_jian": CHARACTER_ACTION_STANDBY,
					"zhang_jiao": CHARACTER_ACTION_STANDBY,
				}
				character_troops = {
					"liu_bei": 1000,
					"guan_yu": 5000,
					"zhang_fei": 3000,
					"cao_cao": 10000,
					"xiahou_dun": 5000,
					"sun_jian": 10000,
					"zhang_jiao": 50000,
				}
				scenario_state = _capture_custom_scenario_state(
					[
						{"id": "play_liu_roster", "name": "刘备一行", "color": "#4E9B73"},
						{"id": "play_cao_roster", "name": "曹操军", "color": "#B8564F"},
						{"id": "play_sun_roster", "name": "孙氏一行", "color": "#4B83A6"},
					],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_roster"},
						{"character_id": "guan_yu", "faction_id": "play_liu_roster"},
						{"character_id": "zhang_fei", "faction_id": "play_liu_roster"},
						{"character_id": "cao_cao", "faction_id": "play_cao_roster"},
						{"character_id": "xiahou_dun", "faction_id": "play_cao_roster"},
						{"character_id": "sun_jian", "faction_id": "play_sun_roster"},
					]
				)
				_refresh_views()
				current_roster_selected_id = "guan_yu"
				current_roster_view_mode = (
					CURRENT_ROSTER_VIEW_PLACE
					if capture_dialog == "current-roster-place"
					else CURRENT_ROSTER_VIEW_FACTION
				)
				_open_current_roster_dialog()
			"character-profile-place", "character-profile-place-result":
				var profile_place_placement := _capture_place_placement("luoyang", Vector2(0.57, 0.32))
				placements = {
					"liu_bei": profile_place_placement.duplicate(true),
					"guan_yu": profile_place_placement.duplicate(true),
					"zhang_fei": _capture_v3_xy(Vector2(0.52, 0.43)),
				}
				character_actions = {
					"liu_bei": CHARACTER_ACTION_STANDBY,
					"guan_yu": CHARACTER_ACTION_ATTACK,
					"zhang_fei": CHARACTER_ACTION_DEFEND,
				}
				character_troops = {
					"liu_bei": 1000,
					"guan_yu": 5000,
					"zhang_fei": 3000,
				}
				scenario_state = _capture_custom_scenario_state(
					[{"id": "play_liu_profile_place", "name": "刘备一行", "color": "#4E9B73"}],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_profile_place"},
						{"character_id": "guan_yu", "faction_id": "play_liu_profile_place"},
						{"character_id": "zhang_fei", "faction_id": "play_liu_profile_place"},
					]
				)
				_refresh_views()
				_open_character_profile("guan_yu", ["liu_bei", "guan_yu", "zhang_fei"])
				if capture_dialog == "character-profile-place-result":
					_on_character_profile_place_pressed()
			"character-chronicle-source", "character-chronicle-editor":
				var character_chronicle_placement := _capture_place_placement("luoyang", Vector2(0.57, 0.32))
				placements = {
					"liu_bei": character_chronicle_placement.duplicate(true),
					"guan_yu": character_chronicle_placement.duplicate(true),
					"zhang_fei": _capture_v3_xy(Vector2(0.52, 0.43)),
				}
				character_actions = {
					"liu_bei": CHARACTER_ACTION_STANDBY,
					"guan_yu": CHARACTER_ACTION_ATTACK,
					"zhang_fei": CHARACTER_ACTION_DEFEND,
				}
				scenario_state = _capture_custom_scenario_state(
					[{"id": "play_liu_character_chronicle", "name": "刘备一行", "color": "#4E9B73"}],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_character_chronicle"},
						{"character_id": "guan_yu", "faction_id": "play_liu_character_chronicle"},
						{"character_id": "zhang_fei", "faction_id": "play_liu_character_chronicle"},
					]
				)
				_refresh_views()
				var character_chronicle_browse_ids: Array[String] = ["liu_bei", "guan_yu", "zhang_fei"]
				_open_character_profile("liu_bei", character_chronicle_browse_ids)
				if capture_dialog == "character-chronicle-editor":
					_open_character_profile_chronicle_editor()
			"city-context":
				var city_context_place_id := capture_hover_place_id
				if city_context_place_id.is_empty():
					for ownership_value in scenario_state.get("city_ownership", []):
						if ownership_value is Dictionary:
							city_context_place_id = str((ownership_value as Dictionary).get("place_id", ""))
							if not city_context_place_id.is_empty():
								break
				if city_context_place_id.is_empty():
					city_context_place_id = "luoyang"
				_open_place_detail_panel(city_context_place_id)
			"city-ownership-tool":
				scenario_state = _capture_custom_scenario_state(
					[
						{"id": "play_liu_ownership_demo", "name": "刘备军", "color": "#0077BB"},
						{"id": "play_cao_ownership_demo", "name": "曹操军", "color": "#EE7733"}
					],
					[
						{"character_id": "liu_bei", "faction_id": "play_liu_ownership_demo"},
						{"character_id": "cao_cao", "faction_id": "play_cao_ownership_demo"}
					],
					[
						{"place_id": "luoyang", "faction_id": "play_liu_ownership_demo"},
						{"place_id": "chenliu", "faction_id": "play_cao_ownership_demo"},
						{"place_id": "xuchang", "faction_id": "play_cao_ownership_demo"}
					]
				)
				_refresh_views()
				_open_place_detail_panel("luoyang")
				_start_city_ownership_tool_from_detail()
				map_board._set_city_ownership_hover_place("chenliu")
			"faction-context":
				var capture_factions: Array = scenario_state.get("factions", [])
				if not capture_factions.is_empty() and capture_factions[0] is Dictionary:
					_open_faction_context_panel(str((capture_factions[0] as Dictionary).get("id", "")))
			"character-profile-browser":
				placements.erase("zhang_jiao")
				_refresh_views()
				backpack.set_search_query("张")
				await get_tree().process_frame
				_on_backpack_character_details_requested(
					"zhang_jiao",
					backpack.get_visible_profile_character_ids()
				)
			"character-details":
				scenario_state = _capture_custom_scenario_state(
					[{"id": "play_liu_bei_demo", "name": "刘备一行", "color": "#0077BB"}],
					[{"character_id": "liu_bei", "faction_id": "play_liu_bei_demo"}]
				)
				_on_character_details_requested("liu_bei")
			"character-attributes":
				placements["liu_bei"] = _capture_place_placement("luoyang", Vector2(0.570361, 0.315373))
				scenario_state = _capture_custom_scenario_state(
					[{"id": "play_liu_bei_demo", "name": "刘备一行", "color": "#0077BB"}],
					[{"character_id": "liu_bei", "faction_id": "play_liu_bei_demo"}]
				)
				character_states = {
					"liu_bei": {
						"state_schema": CHARACTER_STATE_SCHEMA_FOUR_DIMENSIONS,
						"might": 86,
						"intelligence": 84,
						"leadership": 88,
						"charisma": 98
					}
				}
				_refresh_views()
				_on_character_attributes_requested("liu_bei")
			"backpack-character-details":
				placements.erase("liu_bei")
				scenario_state = _capture_custom_scenario_state(
					[{"id": "play_liu_bei_demo", "name": "刘备一行", "color": "#0077BB"}],
					[{"character_id": "liu_bei", "faction_id": "play_liu_bei_demo"}]
				)
				_refresh_views()
				_on_character_details_requested("liu_bei")
			"backpack-new-character-details":
				placements.erase("jia_xu")
				_refresh_views()
				_on_character_details_requested("jia_xu")
			"backpack-character-profile":
				if capture_character_id.is_empty():
					capture_character_id = "jia_xu"
				if not _has_character_id(capture_character_id):
					push_error("截图人物不存在：%s" % capture_character_id)
					get_tree().quit(2)
					return
				placements.erase(capture_character_id)
				_refresh_views()
				_on_character_details_requested(capture_character_id)
			"historical-context":
				var context_detail_id := "context_184_yingchuan_campaign"
				if capture_historical_context_layer_id == "context_190":
					context_detail_id = "context_190_luoyang_burning"
				elif capture_historical_context_layer_id == "context_196":
					context_detail_id = "context_196_xu_court_move"
				_open_historical_context_detail_panel(context_detail_id)
			"player-stroke-setup":
				_open_player_stroke_dialog()
			"player-stroke-selected":
				if not player_strokes.is_empty():
					map_board._select_player_stroke(str(player_strokes[0].get("id", "")))
			"player-stroke-route-editing":
				if not player_strokes.is_empty():
					var capture_stroke_id := str(player_strokes[0].get("id", ""))
					map_board._select_player_stroke(capture_stroke_id)
					if map_board.begin_player_stroke_point_edit(capture_stroke_id) and map_board._player_stroke_point_preview_points.size() >= 3:
						map_board._player_stroke_point_preview_points[1] += Vector2(-0.015, 0.025)
						map_board._update_player_stroke_point_edit_preview()
						map_board._refresh_player_stroke_guide()
			"player-stroke-drawing":
				_pending_player_stroke_type = "advance"
				_pending_player_stroke_label = "刘备军北进"
				map_board.set_player_stroke_tool_active(true, "advance")
				map_board._player_stroke_draft_points = [
					_capture_v3_point(Vector2(0.45, 0.58)),
					_capture_v3_point(Vector2(0.51, 0.50)),
					_capture_v3_point(Vector2(0.58, 0.43))
				]
				map_board._update_player_stroke_draft(_capture_v3_point(Vector2(0.63, 0.38)))
				map_board._refresh_player_stroke_guide()
			"new-sandbox", "new-sandbox-faction", "new-sandbox-confirm":
				var capture_template_id := "yellow_turban_liu_bei_184"
				for template in scenario_templates:
					if str(template.get("scenario_id", "")) == capture_scenario_id:
						capture_template_id = str(template.get("id", capture_template_id))
						break
				_open_new_sandbox_dialog(capture_template_id)
				if capture_dialog == "new-sandbox-faction":
					var first_faction_button = new_sandbox_faction_overview.get_first_button()
					if first_faction_button != null:
						first_faction_button.button_pressed = true
				elif capture_dialog == "new-sandbox-confirm":
					_request_create_selected_sandbox()
			"personal-template-save":
				_open_personal_template_create_dialog()
			"scenario-share-export":
				_configure_scenario_share_capture_content()
				_open_scenario_share_export_dialog()
			"scenario-share-import-preview":
				_configure_scenario_share_capture_content()
				var share_capture_build := _build_current_personal_template_record(
					"涿郡桃园起步",
					"刘关张从涿郡出发，张角据守广宗；交给另一位玩家继续自由推演。",
					true
				)
				if bool(share_capture_build.get("ok", false)):
					var share_capture_document := _build_scenario_share_document(
						(share_capture_build.get("template", {}) as Dictionary).duplicate(true)
					)
					share_capture_document["exported_at"] = "2026-08-01T20:00:00"
					var share_capture_result := _decode_scenario_share_document(share_capture_document)
					if bool(share_capture_result.get("ok", false)):
						_pending_file_import_mode = "scenario_share"
						_show_scenario_share_import_preview("涿郡桃园起步.sanguostart", share_capture_result)
			"scenario-editor", "scenario-editor-empty-40", "scenario-editor-empty-40-bottom":
				if capture_dialog.begins_with("scenario-editor-empty-40"):
					scenario_state = _capture_custom_scenario_state([], [])
				else:
					scenario_state = _capture_custom_scenario_state(
						[
							{"id": "play_liu_bei_demo", "name": "刘备一行", "color": "#0077BB"},
							{"id": "play_yellow_turban_demo", "name": "黄巾军", "color": "#EE7733"}
						],
						[
							{"character_id": "liu_bei", "faction_id": "play_liu_bei_demo"},
							{"character_id": "guan_yu", "faction_id": "play_liu_bei_demo"},
							{"character_id": "zhang_fei", "faction_id": "play_liu_bei_demo"},
							{"character_id": "zhao_yun", "faction_id": "play_liu_bei_demo"},
							{"character_id": "zhang_jiao", "faction_id": "play_yellow_turban_demo"}
						]
					)
				_open_scenario_editor()
				if capture_dialog == "scenario-editor-empty-40-bottom":
					await get_tree().process_frame
					_scroll_scenario_characters_to_bottom()
			"chronicle", "chronicle-editor":
				chronicle_entries = [
					{
						"id": "chron_demo_battle",
						"entry_type": "battle",
						"title": "广宗初战失利",
						"time_label": "中平元年三月",
						"body": "刘备一行兵少，第一次进攻未能突破黄巾军防线。关羽建议先稳住阵脚，等待援军。",
						"created_at": "2026-07-23T06:00:00",
						"updated_at": "2026-07-23T06:00:00"
					},
					{
						"id": "chron_demo_reinforcement",
						"entry_type": "reinforcement",
						"title": "援军抵达",
						"time_label": "广宗再战之前",
						"body": "赵云率一支援军赶到。这是本次沙盘推演中的玩家故事。",
						"created_at": "2026-07-23T06:05:00",
						"updated_at": "2026-07-23T06:05:00"
					}
				]
				_open_chronicle_dialog()
				if capture_dialog == "chronicle-editor":
					_open_selected_chronicle_editor()
			"simulation-session-start":
				_configure_simulation_session_capture(false)
				map_board._on_map_card_selected("liu_bei")
				map_board._on_map_card_selected("guan_yu", true)
				_open_simulation_session_start_dialog()
				simulation_session_name_input.text = "广宗援军推演"
				simulation_session_type_select.select(1)
				simulation_session_time_input.text = "中平元年春"
				simulation_session_initial_action_select.select(2)
			"simulation-session-active", "simulation-session-end":
				_configure_simulation_session_capture(true)
				if capture_dialog == "simulation-session-end":
					_open_simulation_session_end_dialog()
			"player-siege-start":
				_configure_player_siege_capture(false)
				map_board._on_map_card_selected("liu_bei")
				map_board._on_map_card_selected("guan_yu", true)
				_open_simulation_session_start_dialog()
				_select_option_by_value(simulation_session_type_select, "siege")
				_on_simulation_session_type_selected(simulation_session_type_select.selected)
				_select_option_by_value(simulation_session_siege_target_select, "guangzong")
				_on_simulation_session_siege_target_selected(simulation_session_siege_target_select.selected)
				simulation_session_name_input.text = "刘备试攻广宗"
				simulation_session_time_input.text = "中平元年夏"
			"player-siege-end":
				_configure_player_siege_capture(true)
				_open_simulation_session_end_dialog()
				_select_option_by_value(simulation_session_siege_outcome_select, "attacker_win")
				_select_option_by_value(simulation_session_siege_handling_select, "return_all")
				_on_simulation_session_siege_resolution_changed(0)
				_select_option_by_value(simulation_session_siege_owner_select, "owner:play_liu_capture")
				simulation_session_end_title_input.text = "广宗攻城 · 玩家裁定"
				simulation_session_end_note_input.text = "张角军败退，刘备军暂领广宗。"
			"new-sandbox-personal":
				var demo_result := _build_current_personal_template_record("洛阳集结 · 起步", "刘关张与张角已在地图上；保留援军集结标记，继续自由推演。")
				if bool(demo_result.get("ok", false)):
					var demo_template: Dictionary = demo_result.get("template", {}).duplicate(true)
					personal_scenario_templates.append(demo_template)
					_open_new_sandbox_dialog(str(demo_template.get("id", "")), "", "personal")
			"current-branch", "current-branch-confirm":
				_open_branch_current_sandbox_dialog()
				if capture_dialog == "current-branch-confirm":
					_request_branch_current_sandbox()
			"sandbox-info":
				_open_sandbox_info_dialog()
			"quick-bookmark-menu":
				sandbox_file_menu.show_popup()
				_set_status("“留住此刻”将直接保存当前局面")
			"quick-bookmark-manager":
				var quick_capture_payload := _build_sandbox_payload()
				var earlier_capture_id := "snapshot_quick_capture_earlier"
				var latest_capture_id := "snapshot_quick_capture_latest"
				named_snapshots = [
					{
						"snapshot_id": earlier_capture_id,
						"name": "8月6日 15:18:02 的局面",
						"note": "首次留存：人物4、势力2、归属城池2、标记1、推演线1。",
						"created_at": "2026-08-06 15:18:02",
						"sandbox": quick_capture_payload.duplicate(true),
					},
					{
						"snapshot_id": latest_capture_id,
						"name": "8月6日 15:20:07 的局面",
						"note": "较上次留存：摆出2、收回1、移动3、兵力2、行动1、编组2、城池1、势力改1、标记+1、推演线+1/改1。",
						"created_at": "2026-08-06 15:20:07",
						"sandbox": quick_capture_payload.duplicate(true),
					},
				]
				_refresh_sandbox_identity_view()
				_open_snapshot_manager(latest_capture_id)
			"desktop-shortcut-search-focus":
				backpack.set_search_query("关")
				_collapse_backpack()
				await get_tree().process_frame
				var focus_capture_event := InputEventKey.new()
				focus_capture_event.keycode = KEY_F
				focus_capture_event.pressed = true
				focus_capture_event.ctrl_pressed = true
				_handle_desktop_shortcut(focus_capture_event)
			"desktop-shortcut-menu":
				sandbox_file_menu.show_popup()
				_set_status("桌面快捷操作：搜索、保存、撤销、重做与地图归位")
			"snapshot-create":
				_open_snapshot_create_dialog()
			"snapshot-manager", "snapshot-rename":
				named_snapshots.clear()
				named_snapshots.append({
					"snapshot_id": _new_record_id("snapshot"),
					"name": "攻打汉中之前",
					"note": "兵分两路前，关羽暂驻荆州。",
					"created_at": Time.get_datetime_string_from_system(false, true),
					"sandbox": _build_sandbox_payload()
				})
				_open_snapshot_manager()
				if capture_dialog == "snapshot-rename":
					_request_rename_selected_snapshot()
		for _i in range(3):
			await get_tree().process_frame
	var output_path := "res://artifacts/godot_prototype_%d.png" % roundi(capture_zoom * 100.0) if capture_zoom > 0.0 else "res://artifacts/godot_prototype.png"
	if capture_window_size != Vector2i.ZERO:
		output_path = "%s_%dx%d.png" % [output_path.trim_suffix(".png"), capture_window_size.x, capture_window_size.y]
	if not capture_hover_place_id.is_empty():
		output_path = "%s_hover_%s.png" % [output_path.trim_suffix(".png"), capture_hover_place_id]
	if not capture_focus_place_id.is_empty():
		output_path = "%s_focus_%s.png" % [output_path.trim_suffix(".png"), capture_focus_place_id]
	if not capture_scenario_id.is_empty():
		output_path = "%s_scenario-%s.png" % [output_path.trim_suffix(".png"), capture_scenario_id]
	if not capture_faction_influence_override.is_empty():
		output_path = "%s_influence-%s.png" % [output_path.trim_suffix(".png"), capture_faction_influence_override]
	if pass_symbol_variant == MapBoardScript.PASS_SYMBOL_VARIANT_PAPER_INK_V1:
		output_path = "%s_pass-B.png" % output_path.trim_suffix(".png")
	if terrain_relief_variant == MapBoardScript.TERRAIN_RELIEF_VARIANT_LR_V1:
		output_path = "%s_terrain-A.png" % output_path.trim_suffix(".png")
	if (
		terrain_visual_profile_request == MapBoardScript.TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1
		and terrain_visual_profile == MapBoardScript.TERRAIN_VISUAL_PROFILE_CLASSIC_DAYLIGHT_V1
	):
		output_path = "%s_topographic-A.png" % output_path.trim_suffix(".png")
	elif terrain_visual_profile == MapBoardScript.TERRAIN_VISUAL_PROFILE_ANTIQUE_TOPOGRAPHIC_V1:
		output_path = "%s_topographic-B.png" % output_path.trim_suffix(".png")
	if not capture_dialog.is_empty():
		output_path = "%s_dialog_%s.png" % [output_path.trim_suffix(".png"), capture_dialog]
	if not capture_character_id.is_empty():
		output_path = "%s_character-%s.png" % [output_path.trim_suffix(".png"), capture_character_id]
	if capture_historical_context:
		output_path = "%s_%s.png" % [output_path.trim_suffix(".png"), capture_historical_context_layer_id.replace("_", "")]
	if capture_player_annotations:
		output_path = "%s_player-annotations.png" % output_path.trim_suffix(".png")
	if capture_player_strokes:
		output_path = "%s_player-strokes.png" % output_path.trim_suffix(".png")
	if not capture_near_hachures_override.is_empty():
		output_path = "%s_hachures-%s.png" % [output_path.trim_suffix(".png"), capture_near_hachures_override]
	await RenderingServer.frame_post_draw
	var capture_viewport := get_viewport()
	var image := capture_viewport.get_texture().get_image()
	if capture_window_size != Vector2i.ZERO and image.get_size() != capture_window_size:
		push_error("截图尺寸不符：请求 %s，实际 %s" % [capture_window_size, image.get_size()])
		get_tree().quit(2)
		return
	print("CAPTURE_GEOMETRY:requested=%s viewport=%s image=%s" % [capture_window_size, capture_viewport.get_visible_rect().size, image.get_size()])
	var error := image.save_png(output_path)
	if error == OK:
		print("CAPTURE_SAVED:", ProjectSettings.globalize_path(output_path))
		get_tree().quit(0)
	else:
		push_error("截图保存失败：%s" % error)
		get_tree().quit(1)


func _has_active_chronicle_editor_draft() -> bool:
	if chronicle_editor_dialog == null or not _chronicle_editor_has_changes():
		return false
	return (
		chronicle_editor_dialog.visible
		or (
			chronicle_editor_discard_confirmation_dialog != null
			and chronicle_editor_discard_confirmation_dialog.visible
		)
	)


func _has_active_scenario_editor_draft() -> bool:
	if (
		_pending_scenario_editor_state.is_empty()
		or _scenario_states_match(_pending_scenario_editor_state, scenario_state)
	):
		return false
	for dialog in [
		scenario_editor_dialog,
		scenario_faction_name_dialog,
		scenario_faction_delete_confirmation_dialog,
		scenario_editor_discard_confirmation_dialog,
	]:
		if dialog != null and dialog.visible:
			return true
	return false


func _guard_active_map_draft_before_interruption(next_action: String) -> bool:
	if annotation_dialog != null and annotation_dialog.visible:
		_set_status("请先完成或取消当前沙盘标记，再%s" % next_action)
		return false
	if player_stroke_dialog != null and player_stroke_dialog.visible:
		_set_status("请先完成或取消当前推演线设置，再%s" % next_action)
		return false
	if map_board == null:
		return true
	if map_board.is_player_stroke_tool_active():
		_set_status("请先完成或取消当前推演线，再%s" % next_action)
		return false
	if (
		map_board.is_player_stroke_point_edit_active()
		and bool(map_board.get_player_stroke_point_edit_state().get("changed", false))
	):
		_set_status("请先保存或取消当前路线调整，再%s" % next_action)
		return false
	return true


func _guard_unsaved_editor_drafts_before_leaving() -> bool:
	if not _guard_active_map_draft_before_interruption("离开当前沙盘"):
		return false
	if not active_simulation_session.is_empty():
		_set_status("请先结束并复盘，或明确取消助手，再离开当前沙盘")
		if (
			simulation_session_cancel_dialog != null
			and not simulation_session_cancel_dialog.visible
		):
			_open_simulation_session_cancel_dialog()
		return false
	if _has_active_chronicle_editor_draft():
		_set_status("请先保存纪事，或明确放弃这次修改，再离开当前沙盘")
		if (
			chronicle_editor_discard_confirmation_dialog == null
			or not chronicle_editor_discard_confirmation_dialog.visible
		):
			_cancel_chronicle_editor()
		return false
	if _has_active_scenario_editor_draft():
		_set_status("请先应用玩法分组，或明确放弃本次修改，再离开当前沙盘")
		if (
			scenario_editor_discard_confirmation_dialog != null
			and scenario_editor_discard_confirmation_dialog.visible
		):
			return false
		if scenario_editor_dialog != null and scenario_editor_dialog.visible:
			_cancel_scenario_editor()
		else:
			_show_message(
				"玩法分组尚未应用",
				"请先完成或取消当前步骤，再应用玩法分组，或明确放弃本次修改。当前沙盘仍保持打开。"
			)
		return false
	return true


func _show_leave_failure_message(title_text: String, body_text: String) -> void:
	var editor: Window = null
	if is_instance_valid(chronicle_editor_dialog) and chronicle_editor_dialog.visible:
		editor = chronicle_editor_dialog
	elif is_instance_valid(scenario_editor_dialog) and scenario_editor_dialog.visible:
		editor = scenario_editor_dialog
	if editor != null:
		# 只为错误提示让位，不取消编辑、不重置草稿与返回上下文。
		editor.hide()
	_show_message(title_text, body_text)
	if editor != null and is_instance_valid(message_dialog):
		message_dialog.visibility_changed.connect(
			_restore_editor_after_leave_failure.bind(editor), CONNECT_ONE_SHOT
		)


func _restore_editor_after_leave_failure(editor: Window) -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	await get_tree().process_frame
	if not is_inside_tree() or is_queued_for_deletion() or not is_instance_valid(editor):
		return
	if not editor.is_inside_tree() or (is_instance_valid(message_dialog) and message_dialog.visible):
		return
	if editor == chronicle_editor_dialog:
		_return_to_chronicle_editor()
	elif editor == scenario_editor_dialog:
		_return_to_scenario_editor()


func _request_safe_quit(perform_tree_quit := true) -> bool:
	if not _guard_unsaved_editor_drafts_before_leaving():
		return false
	if _primary_recovery_requires_reload:
		if perform_tree_quit:
			get_tree().quit()
		return true
	if not _save():
		_show_leave_failure_message(
			"暂时无法离开游戏",
			"当前沙盘没有安全写入；为避免丢失改动，游戏仍保持打开。请检查存档文件或磁盘空间后重试。"
		)
		return false
	if perform_tree_quit:
		get_tree().quit()
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and not capture_mode and not drag_benchmark_mode:
		_request_safe_quit()
