extends Control

const UiThemeScript = preload("res://src/ui_theme.gd")
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const CHARACTER_ARCHIVE_SCENE_PATH := "res://scenes/character_archive.tscn"
const COVER_PATH := "res://assets/title/cover_open_source_v1.svg"
const CREDITS_PATH := "res://data/credits.json"
const LOAD_ICON_PATH := "res://assets/ui/icons/lucide_1_26_0/folder-open.svg"
const SETTINGS_ICON_PATH := "res://assets/ui/icons/lucide_1_26_0/settings.svg"
const LOAD_ICON := preload(LOAD_ICON_PATH)
const SETTINGS_ICON := preload(SETTINGS_ICON_PATH)
const SYSTEM_ICON_SIZE := 16
const SETTINGS_VERSION := 1
const SETTINGS_FILE_LIMIT := 16 * 1024
const SETTINGS_PREVIOUS_SUFFIX := ".previous"
const SETTINGS_TEMP_SUFFIX := ".tmp"
const SETTINGS_REPLACE_SUFFIX := ".replace.tmp"
const FORMAL_SETTINGS_PATH := "user://title_settings.json"
const MANUAL_TEST_SETTINGS_PATH := "user://title_settings_test.json"
const AUTOMATED_TEST_SETTINGS_PATH := "user://title_settings_automated_test.json"
const OPEN_SNAPSHOTS_META := "sandtable_open_snapshots_after_scene_change"
const OPEN_NEW_SANDBOX_META := "sandtable_open_new_sandbox_after_scene_change"
const CURRENT_SAVE_PREVIEW_LIMIT := 2 * 1024 * 1024
const SNAPSHOT_STORE_PREVIEW_LIMIT := 8 * 1024 * 1024
const PRIMARY_RECOVERY_CANDIDATE_LIMIT := 12
const PRIMARY_LAST_GOOD_SUFFIX := ".last-good"
const CURRENT_SAVE_VERSION_MAX := 18
const CHARACTER_CATALOG_SAVE_VERSION := 13
const CURRENT_CHARACTER_CATALOG_VERSION := 6
const PREVIOUS_CHARACTER_CATALOG_VERSION := 5
const PREVIOUS_CHARACTER_CATALOG_MIN_SAVE_VERSION := 17
const PREVIOUS_CHARACTER_CATALOG_MAX_SAVE_VERSION := 17
const HISTORICAL_V3_SAVE_VERSION := 15
const SECOND_PREVIOUS_CHARACTER_CATALOG_VERSION := 2
const SECOND_PREVIOUS_CHARACTER_CATALOG_MIN_SAVE_VERSION := 13
const SECOND_PREVIOUS_CHARACTER_CATALOG_MAX_SAVE_VERSION := 14
const SNAPSHOT_STORE_VERSION := 1
const SNAPSHOT_LIMIT := 50

var title_label: Label
var save_summary_label: Label
var save_context_label: Label
var build_label: Label
var start_button: Button
var new_sandbox_button: Button
var load_button: Button
var character_archive_button: Button
var settings_button: Button
var about_button: Button
var exit_button: Button
var settings_dialog: ConfirmationDialog
var about_dialog: AcceptDialog
var about_text: RichTextLabel
var fullscreen_toggle: CheckButton
var vsync_toggle: CheckButton
var settings_status_label: Label
var exit_confirmation: ConfirmationDialog
var save_browser_dialog: ConfirmationDialog
var save_browser_current_label: Label
var save_browser_list: ItemList
var save_browser_detail_label: Label
var save_browser_status_label: Label
var _settings: Dictionary = {}
var _save_browser_snapshots: Array[Dictionary] = []
var _transitioning := false
var _title_outer: MarginContainer
var _title_menu_panel: PanelContainer
var _title_menu_margin: MarginContainer
var _title_era_label: Label
var _title_subtitle_label: Label
var _title_quote_label: Label
var _last_title_focus: Control
var _settings_load_notice := ""
var _settings_load_notice_failed := false
var _automated_settings_write_failure_stage := ""


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_window().gui_embed_subwindows = true
	# 主沙盘会接管系统关闭请求；回到没有关闭处理器的标题页后恢复默认策略。
	get_tree().auto_accept_quit = true
	if "--test-mode" in OS.get_cmdline_user_args():
		get_window().title = "三国推演志 · 测试模式 · 界面校验"
	if _should_bypass_title():
		visible = false
		call_deferred("_enter_game", false)
		return
	theme = _build_theme()
	_settings = _load_settings()
	_apply_settings(_settings)
	_build_interface()
	_build_settings_dialog()
	_build_about_dialog()
	_build_exit_confirmation()
	_build_save_browser_dialog()
	_refresh_save_summary()
	call_deferred("_style_title_scrollbars")
	call_deferred("_focus_default_title_action")
	if "--basic-release-check" in OS.get_cmdline_user_args() and "--automated-test-mode" in OS.get_cmdline_user_args() and not get_tree().has_meta("basic_release_check_started"):
		get_tree().set_meta("basic_release_check_started", true)
		var probe := load("res://tests/basic_release_probe.gd").new() as Node
		get_tree().root.call_deferred("add_child", probe)
		queue_free()


func _should_bypass_title() -> bool:
	var user_args := OS.get_cmdline_user_args()
	if "--capture" in user_args or "--drag-benchmark" in user_args:
		return true
	if "--test-mode" not in user_args:
		return false
	for argument in user_args:
		if str(argument).begins_with("--ui-review-dialog="):
			return true
	return false


func _build_theme() -> Theme:
	return UiThemeScript.build_base_theme(17)


func _build_interface() -> void:
	var background := TextureRect.new()
	background.name = "CoverBackground"
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.texture = load(COVER_PATH) as Texture2D
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var dimmer := ColorRect.new()
	dimmer.name = "CoverDimmer"
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(1.0, 0.97, 0.88, 0.04)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dimmer)

	var veil_gradient := Gradient.new()
	veil_gradient.offsets = PackedFloat32Array([0.0, 0.34, 0.72, 1.0])
	veil_gradient.colors = PackedColorArray([
		Color(0.98, 0.95, 0.86, 0.82),
		Color(0.98, 0.95, 0.86, 0.65),
		Color(0.98, 0.95, 0.86, 0.15),
		Color(0.98, 0.95, 0.86, 0.0)
	])
	var veil_texture := GradientTexture2D.new()
	veil_texture.gradient = veil_gradient
	veil_texture.width = 1024
	veil_texture.height = 4
	veil_texture.fill_from = Vector2(0.0, 0.5)
	veil_texture.fill_to = Vector2(1.0, 0.5)
	var left_veil := TextureRect.new()
	left_veil.name = "LeftVeil"
	left_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	left_veil.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	left_veil.stretch_mode = TextureRect.STRETCH_SCALE
	left_veil.texture = veil_texture
	left_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left_veil)

	_title_outer = MarginContainer.new()
	_title_outer.name = "TitleLayout"
	_title_outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_title_outer)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 48)
	_title_outer.add_child(row)

	_title_menu_panel = PanelContainer.new()
	_title_menu_panel.name = "TitleMenuPanel"
	_title_menu_panel.custom_minimum_size = Vector2(440, 0)
	_title_menu_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_title_menu_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_title_menu_panel.add_theme_stylebox_override("panel", _panel_style())
	row.add_child(_title_menu_panel)

	_title_menu_margin = MarginContainer.new()
	_title_menu_panel.add_child(_title_menu_margin)

	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 0)
	_title_menu_margin.add_child(menu)

	_title_era_label = Label.new()
	_title_era_label.name = "TitleEyebrow"
	_title_era_label.text = "个人三国历史沙盘"
	_title_era_label.add_theme_font_size_override("font_size", 13)
	_title_era_label.add_theme_color_override("font_color", UiThemeScript.TEXT_ACCENT)
	menu.add_child(_title_era_label)

	menu.add_child(_vertical_space(6))

	title_label = Label.new()
	title_label.name = "GameTitle"
	title_label.text = str(ProjectSettings.get_setting("application/config/name", "未定名"))
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 50)
	title_label.add_theme_color_override("font_color", Color("#342616"))
	title_label.add_theme_color_override("font_shadow_color", Color(1.0, 0.96, 0.82, 0.88))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	menu.add_child(title_label)

	menu.add_child(_vertical_space(5))

	_title_subtitle_label = Label.new()
	_title_subtitle_label.name = "TitleSubtitle"
	_title_subtitle_label.text = "从背包取出人物，在地图上摆下自己的三国。"
	_title_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title_subtitle_label.add_theme_font_size_override("font_size", 16)
	_title_subtitle_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	menu.add_child(_title_subtitle_label)

	menu.add_child(_vertical_space(18))

	var title_rule := ColorRect.new()
	title_rule.name = "TitleRule"
	title_rule.custom_minimum_size = Vector2(0, 1)
	title_rule.color = Color(0.57, 0.43, 0.18, 0.66)
	title_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(title_rule)

	menu.add_child(_vertical_space(20))

	start_button = _make_menu_button("开始游戏", "进入一个空白沙盘；首次有效操作后自动保存")
	start_button.name = "StartGameButton"
	start_button.custom_minimum_size.y = 54
	start_button.add_theme_font_size_override("font_size", 20)
	_apply_primary_button_style(start_button)
	start_button.pressed.connect(_on_start_pressed)
	menu.add_child(start_button)

	menu.add_child(_vertical_space(12))

	var summary_panel := PanelContainer.new()
	summary_panel.name = "CurrentSandboxSummaryPanel"
	summary_panel.add_theme_stylebox_override("panel", _summary_panel_style())
	menu.add_child(summary_panel)

	var summary_margin := MarginContainer.new()
	summary_margin.add_theme_constant_override("margin_left", 14)
	summary_margin.add_theme_constant_override("margin_right", 14)
	summary_margin.add_theme_constant_override("margin_top", 9)
	summary_margin.add_theme_constant_override("margin_bottom", 10)
	summary_panel.add_child(summary_margin)

	var summary_column := VBoxContainer.new()
	summary_column.add_theme_constant_override("separation", 4)
	summary_margin.add_child(summary_column)

	var summary_heading_row := HBoxContainer.new()
	summary_heading_row.add_theme_constant_override("separation", 8)
	summary_column.add_child(summary_heading_row)

	var summary_heading := Label.new()
	summary_heading.text = "当前沙盘"
	summary_heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_heading.add_theme_font_size_override("font_size", 12)
	summary_heading.add_theme_color_override("font_color", UiThemeScript.TEXT_ACCENT)
	summary_heading_row.add_child(summary_heading)

	save_context_label = Label.new()
	save_context_label.name = "SaveStorageContext"
	save_context_label.text = _storage_context_text()
	save_context_label.add_theme_font_size_override("font_size", 12)
	save_context_label.add_theme_color_override(
		"font_color",
		UiThemeScript.TEXT_WARNING if _is_test_storage_context() else UiThemeScript.TEXT_HINT
	)
	summary_heading_row.add_child(save_context_label)

	save_summary_label = Label.new()
	save_summary_label.name = "SaveSummary"
	save_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_summary_label.add_theme_font_size_override("font_size", 14)
	save_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	summary_column.add_child(save_summary_label)

	menu.add_child(_vertical_space(12))

	new_sandbox_button = _make_menu_button(
		"选择开局",
		"从完全自定义或五个历史开局建立新沙盘"
	)
	new_sandbox_button.name = "NewSandboxButton"
	new_sandbox_button.pressed.connect(_on_new_sandbox_pressed)
	menu.add_child(new_sandbox_button)

	menu.add_child(_vertical_space(10))

	load_button = _make_menu_button("命名快照", "查看本机命名快照；恢复仍需在主沙盘再次确认", LOAD_ICON)
	load_button.name = "LoadGameButton"
	load_button.pressed.connect(_on_load_pressed)
	menu.add_child(load_button)

	menu.add_child(_vertical_space(10))

	character_archive_button = _make_menu_button(
		"人物志",
		"按姓名、分类或内置开局翻阅人物、四维与小传"
	)
	character_archive_button.name = "CharacterArchiveButton"
	character_archive_button.pressed.connect(_on_character_archive_pressed)
	menu.add_child(character_archive_button)

	menu.add_child(_vertical_space(10))

	var utility_row := HBoxContainer.new()
	utility_row.name = "TitleUtilityActions"
	utility_row.add_theme_constant_override("separation", 8)
	menu.add_child(utility_row)

	settings_button = _make_utility_button("设置", "调整窗口模式和垂直同步", SETTINGS_ICON)
	settings_button.name = "SettingsButton"
	settings_button.pressed.connect(_open_settings)
	utility_row.add_child(settings_button)

	about_button = _make_utility_button("说明", "查看游戏说明、资料来源、素材许可与鸣谢")
	about_button.name = "AboutButton"
	about_button.pressed.connect(_open_about_dialog)
	utility_row.add_child(about_button)

	exit_button = _make_utility_button("离开", "关闭游戏")
	exit_button.name = "ExitGameButton"
	exit_button.pressed.connect(_open_exit_confirmation)
	utility_row.add_child(exit_button)

	_wire_title_focus_navigation()

	menu.add_child(_vertical_space(16))
	build_label = Label.new()
	build_label.text = "离线单机 · 自由推演 · 自动保存"
	build_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	build_label.add_theme_font_size_override("font_size", 12)
	build_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	menu.add_child(build_label)

	var right_column := VBoxContainer.new()
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(right_column)

	var right_spacer := Control.new()
	right_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_column.add_child(right_spacer)

	_title_quote_label = Label.new()
	_title_quote_label.name = "TitleQuote"
	_title_quote_label.text = "铺开地图，摆下人物。\n余下的历史，由你决定。"
	_title_quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_title_quote_label.add_theme_font_size_override("font_size", 16)
	_title_quote_label.add_theme_color_override("font_color", Color(0.20, 0.16, 0.09, 0.90))
	_title_quote_label.add_theme_color_override("font_shadow_color", Color(1.0, 0.96, 0.84, 0.92))
	_title_quote_label.add_theme_constant_override("shadow_offset_x", 1)
	_title_quote_label.add_theme_constant_override("shadow_offset_y", 2)
	right_column.add_child(_title_quote_label)

	resized.connect(_apply_title_responsive_layout)
	call_deferred("_apply_title_responsive_layout")


func _apply_title_responsive_layout() -> void:
	var compact_height := size.y < 740.0
	var compact_width := size.x < 1280.0
	if _title_outer != null:
		var horizontal_margin := 28 if compact_width else 52
		var vertical_margin := 20 if compact_height else 36
		_title_outer.add_theme_constant_override("margin_left", horizontal_margin)
		_title_outer.add_theme_constant_override("margin_right", horizontal_margin)
		_title_outer.add_theme_constant_override("margin_top", vertical_margin)
		_title_outer.add_theme_constant_override("margin_bottom", vertical_margin)
	if _title_menu_panel != null:
		_title_menu_panel.custom_minimum_size.x = 404 if compact_width else 440
	if _title_menu_margin != null:
		var side_margin := 24 if compact_width else 30
		var top_bottom_margin := 20 if compact_height else 28
		_title_menu_margin.add_theme_constant_override("margin_left", side_margin)
		_title_menu_margin.add_theme_constant_override("margin_right", side_margin)
		_title_menu_margin.add_theme_constant_override("margin_top", top_bottom_margin)
		_title_menu_margin.add_theme_constant_override("margin_bottom", top_bottom_margin)
	if title_label != null:
		title_label.add_theme_font_size_override("font_size", 42 if compact_height else 50)
	if _title_subtitle_label != null:
		_title_subtitle_label.add_theme_font_size_override("font_size", 14 if compact_height else 16)
	if _title_era_label != null:
		_title_era_label.visible = not compact_height
	if build_label != null:
		build_label.visible = not compact_height
	if _title_quote_label != null:
		_title_quote_label.visible = not compact_height and not compact_width


func _panel_style() -> StyleBoxFlat:
	var style := UiThemeScript.make_title_panel()
	style.border_color = Color(0.57, 0.46, 0.25, 0.86)
	style.border_width_left = 2
	style.shadow_size = 18
	return style


func _summary_panel_style() -> StyleBoxFlat:
	var style := UiThemeScript.make_record_panel(0.78, 0, Vector4(0, 0, 0, 0))
	style.border_color = UiThemeScript.BORDER_SHELL
	style.border_width_left = 3
	return style


func _button_style(background: Color, border: Color) -> StyleBoxFlat:
	return UiThemeScript.make_rect_button(background, border)


func _vertical_space(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


func _make_menu_button(text_value: String, tooltip_value: String, icon_texture: Texture2D = null) -> Button:
	var button := Button.new()
	button.text = text_value
	button.tooltip_text = tooltip_value
	button.custom_minimum_size = Vector2(0, 46)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 18)
	if icon_texture != null:
		button.icon = icon_texture
		button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		button.expand_icon = false
		button.add_theme_constant_override("icon_max_width", SYSTEM_ICON_SIZE)
		button.add_theme_constant_override("h_separation", 8)
		button.add_theme_color_override("icon_normal_color", UiThemeScript.TEXT_BUTTON)
		button.add_theme_color_override("icon_hover_color", UiThemeScript.TEXT_BUTTON_HOVER)
		button.add_theme_color_override("icon_pressed_color", UiThemeScript.TEXT_BUTTON_HOVER)
		button.add_theme_color_override("icon_focus_color", UiThemeScript.TEXT_BUTTON_HOVER)
	button.add_theme_color_override("icon_disabled_color", UiThemeScript.TEXT_DISABLED)
	button.add_theme_stylebox_override("normal", _button_style(Color("#F4EEDC"), Color("#9CA48F")))
	button.add_theme_stylebox_override("hover", _button_style(Color("#FFF5D9"), UiThemeScript.GOLD_FOCUS))
	button.add_theme_stylebox_override("pressed", _button_style(Color("#E8D9AF"), UiThemeScript.GOLD_FOCUS))
	button.add_theme_stylebox_override("focus", _button_style(Color("#FFF5D9"), UiThemeScript.GOLD_FOCUS))
	return button


func _make_utility_button(text_value: String, tooltip_value: String, icon_texture: Texture2D = null) -> Button:
	var button := _make_menu_button(text_value, tooltip_value, icon_texture)
	button.custom_minimum_size = Vector2(0, 44)
	button.size_flags_stretch_ratio = 1.0
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_stylebox_override("normal", _button_style(Color("#E7E6D8"), Color("#9DA593")))
	return button


func _apply_primary_button_style(button: Button) -> void:
	button.add_theme_color_override("font_color", Color("#302514"))
	button.add_theme_color_override("font_hover_color", Color("#20170A"))
	button.add_theme_color_override("font_pressed_color", Color("#20170A"))
	button.add_theme_color_override("font_focus_color", Color("#20170A"))
	button.add_theme_stylebox_override("normal", _button_style(Color("#E6CC8F"), Color("#A57A27")))
	button.add_theme_stylebox_override("hover", _button_style(Color("#F3DA9B"), Color("#8E641C")))
	button.add_theme_stylebox_override("pressed", _button_style(Color("#D5B66E"), Color("#8E641C")))
	button.add_theme_stylebox_override("focus", _button_style(Color("#F3DA9B"), UiThemeScript.GOLD_FOCUS))


func _wire_title_focus_navigation() -> void:
	var buttons: Array[Button] = [
		start_button,
		new_sandbox_button,
		load_button,
		character_archive_button,
		settings_button,
		about_button,
		exit_button,
	]
	for index in range(buttons.size()):
		var button := buttons[index]
		button.focus_mode = Control.FOCUS_ALL
		button.focus_previous = buttons[(index - 1 + buttons.size()) % buttons.size()].get_path()
		button.focus_next = buttons[(index + 1) % buttons.size()].get_path()
	start_button.focus_neighbor_bottom = new_sandbox_button.get_path()
	new_sandbox_button.focus_neighbor_top = start_button.get_path()
	new_sandbox_button.focus_neighbor_bottom = load_button.get_path()
	load_button.focus_neighbor_top = new_sandbox_button.get_path()
	load_button.focus_neighbor_bottom = character_archive_button.get_path()
	character_archive_button.focus_neighbor_top = load_button.get_path()
	character_archive_button.focus_neighbor_bottom = settings_button.get_path()
	settings_button.focus_neighbor_top = character_archive_button.get_path()
	settings_button.focus_neighbor_right = about_button.get_path()
	about_button.focus_neighbor_top = character_archive_button.get_path()
	about_button.focus_neighbor_left = settings_button.get_path()
	about_button.focus_neighbor_right = exit_button.get_path()
	exit_button.focus_neighbor_top = character_archive_button.get_path()
	exit_button.focus_neighbor_left = about_button.get_path()


func _focus_default_title_action() -> void:
	if not _transitioning and is_instance_valid(start_button) and start_button.is_visible_in_tree():
		start_button.grab_focus()


func _build_settings_dialog() -> void:
	settings_dialog = ConfirmationDialog.new()
	settings_dialog.name = "SettingsDialog"
	settings_dialog.title = "设置"
	settings_dialog.min_size = Vector2i(470, 310)
	settings_dialog.max_size = Vector2i(470, 310)
	settings_dialog.unresizable = true
	settings_dialog.dialog_hide_on_ok = false
	settings_dialog.ok_button_text = "应用"
	settings_dialog.cancel_button_text = "取消"
	settings_dialog.confirmed.connect(_apply_settings_from_dialog)
	add_child(settings_dialog)
	_apply_title_dialog_style(settings_dialog)
	_bind_title_dialog_focus(settings_dialog)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 12)
	settings_dialog.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)

	var heading := Label.new()
	heading.text = "显示"
	heading.add_theme_font_size_override("font_size", 21)
	heading.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	column.add_child(heading)

	fullscreen_toggle = CheckButton.new()
	fullscreen_toggle.text = "全屏显示"
	fullscreen_toggle.tooltip_text = "可随时回到此处切换为窗口模式"
	column.add_child(fullscreen_toggle)

	vsync_toggle = CheckButton.new()
	vsync_toggle.text = "开启垂直同步"
	vsync_toggle.tooltip_text = "减少画面撕裂；性能基准模式会绕过标题页"
	column.add_child(vsync_toggle)

	settings_status_label = Label.new()
	settings_status_label.text = "点击“应用”后写入本机设置；沙盘存档保持独立。"
	settings_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings_status_label.add_theme_font_size_override("font_size", 13)
	settings_status_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(settings_status_label)


func _build_about_dialog() -> void:
	about_dialog = AcceptDialog.new()
	about_dialog.name = "AboutDialog"
	about_dialog.title = "说明"
	about_dialog.ok_button_text = "返回"
	about_dialog.min_size = Vector2i(760, 540)
	about_dialog.max_size = Vector2i(920, 680)
	about_dialog.unresizable = true
	add_child(about_dialog)
	_apply_title_dialog_style(about_dialog)
	_bind_title_dialog_focus(about_dialog)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	about_dialog.add_child(margin)

	about_text = RichTextLabel.new()
	about_text.name = "AboutText"
	about_text.custom_minimum_size = Vector2(716, 468)
	about_text.bbcode_enabled = true
	about_text.fit_content = false
	about_text.scroll_active = true
	about_text.selection_enabled = true
	about_text.add_theme_font_size_override("normal_font_size", 15)
	about_text.add_theme_color_override("default_color", UiThemeScript.TEXT_BODY)
	about_text.add_theme_constant_override("line_separation", 4)
	about_text.add_theme_stylebox_override("normal", _about_text_style())
	about_text.text = _about_document_bbcode(_load_about_document())
	UiThemeScript.style_accessible_scrollbar(
		about_text.get_v_scroll_bar(),
		"拖动查看说明、来源与鸣谢；也可用滚轮或 ↑↓"
	)
	margin.add_child(about_text)
func _about_dialog_style() -> StyleBoxFlat:
	var style := _panel_style()
	style.bg_color = Color(0.98, 0.96, 0.89, 0.995)
	style.border_color = UiThemeScript.BORDER_BRASS
	style.shadow_size = 20
	return style


func _apply_title_dialog_style(dialog: AcceptDialog) -> void:
	_refresh_title_dialog_style(dialog)
	var refresh_callback := _refresh_title_dialog_style.bind(dialog)
	if not dialog.about_to_popup.is_connected(refresh_callback):
		dialog.about_to_popup.connect(refresh_callback)


func _refresh_title_dialog_style(dialog: AcceptDialog) -> void:
	if not is_instance_valid(dialog):
		return
	dialog.theme = theme
	UiThemeScript.apply_dialog_surface(dialog, _about_dialog_style())
	_apply_title_dialog_button_style(dialog.get_ok_button(), true)
	if dialog is ConfirmationDialog:
		_apply_title_dialog_button_style((dialog as ConfirmationDialog).get_cancel_button(), false)
	call_deferred("_style_title_scrollbars")


func _style_title_scrollbars() -> void:
	if not is_inside_tree():
		return
	UiThemeScript.style_accessible_scrollbars_in(self)


func _apply_title_dialog_button_style(button: Button, primary: bool) -> void:
	button.custom_minimum_size = Vector2(88, 38)
	button.add_theme_font_size_override("font_size", 16)
	var normal_color := Color("#E6CC8F") if primary else Color("#E7E6D8")
	var normal_border := UiThemeScript.GOLD_FOCUS if primary else UiThemeScript.BORDER_SHELL
	button.add_theme_stylebox_override("normal", _button_style(normal_color, normal_border))
	button.add_theme_stylebox_override("hover", _button_style(Color("#F5DFA6"), UiThemeScript.GOLD_FOCUS))
	button.add_theme_stylebox_override("pressed", _button_style(Color("#D9BC78"), UiThemeScript.GOLD_FOCUS))
	button.add_theme_stylebox_override("focus", _button_style(Color("#F5DFA6"), UiThemeScript.GOLD_FOCUS))
	var disabled_style := _button_style(Color("#DAD9CB"), Color("#B8B9AB"))
	button.add_theme_stylebox_override("disabled", disabled_style)
	button.add_theme_color_override("font_disabled_color", UiThemeScript.TEXT_DISABLED)


func _about_text_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.985, 0.93, 0.99)
	style.border_color = UiThemeScript.BORDER_SHELL
	style.set_border_width_all(1)
	style.set_corner_radius_all(7)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style


func _load_about_document() -> Dictionary:
	if not FileAccess.file_exists(CREDITS_PATH):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CREDITS_PATH))
	if not (parsed is Dictionary):
		return {}
	var document: Dictionary = parsed
	if int(document.get("schema_version", 0)) != 1 or not (document.get("sections", []) is Array):
		return {}
	return document


func _about_document_bbcode(document: Dictionary) -> String:
	if document.is_empty():
		return "[font_size=24][color=#%s]说明[/color][/font_size]\n\n说明资料暂时无法读取；游戏和存档没有受到影响。" % UiThemeScript.RICH_HEADING_HEX
	var blocks := PackedStringArray()
	for section_value in document.get("sections", []):
		if not (section_value is Dictionary):
			continue
		var section: Dictionary = section_value
		var heading := str(section.get("title", "")).strip_edges()
		if heading.is_empty():
			continue
		var paragraphs := PackedStringArray()
		for paragraph_value in section.get("paragraphs", []):
			var paragraph := str(paragraph_value).strip_edges()
			if not paragraph.is_empty():
				paragraphs.append(paragraph.replace("[", "[lb]"))
		blocks.append("[font_size=22][color=#%s][b]%s[/b][/color][/font_size]\n%s" % [
			UiThemeScript.RICH_HEADING_HEX,
			heading.replace("[", "[lb]"),
			"\n\n".join(paragraphs)
		])
	return "\n\n[font_size=8] [/font_size]\n\n".join(blocks)


func _build_exit_confirmation() -> void:
	exit_confirmation = ConfirmationDialog.new()
	exit_confirmation.name = "ExitConfirmation"
	exit_confirmation.title = "离开游戏"
	exit_confirmation.dialog_text = "确定要离开吗？地图内的有效操作会自动保存。"
	exit_confirmation.ok_button_text = "离开"
	exit_confirmation.cancel_button_text = "继续游戏"
	exit_confirmation.confirmed.connect(_quit_game)
	add_child(exit_confirmation)
	_apply_title_dialog_style(exit_confirmation)
	_bind_title_dialog_focus(exit_confirmation)


func _build_save_browser_dialog() -> void:
	save_browser_dialog = ConfirmationDialog.new()
	save_browser_dialog.name = "SaveBrowserDialog"
	save_browser_dialog.title = "命名快照"
	save_browser_dialog.min_size = Vector2i(760, 500)
	save_browser_dialog.max_size = Vector2i(900, 640)
	save_browser_dialog.unresizable = true
	save_browser_dialog.ok_button_text = "进入快照管理"
	save_browser_dialog.cancel_button_text = "返回封面"
	save_browser_dialog.confirmed.connect(_enter_snapshot_manager)
	add_child(save_browser_dialog)
	_apply_title_dialog_style(save_browser_dialog)
	_bind_title_dialog_focus(save_browser_dialog)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	save_browser_dialog.add_child(outer)

	var read_only_note := Label.new()
	read_only_note.text = "这里用于查看当前沙盘与命名快照；恢复仍需进入主沙盘再次确认。"
	read_only_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	read_only_note.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	outer.add_child(read_only_note)

	save_browser_current_label = Label.new()
	save_browser_current_label.name = "CurrentSavePreview"
	save_browser_current_label.custom_minimum_size = Vector2(0, 76)
	save_browser_current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_browser_current_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	outer.add_child(save_browser_current_label)

	var divider := HSeparator.new()
	outer.add_child(divider)

	var snapshot_heading := Label.new()
	snapshot_heading.text = "命名快照"
	snapshot_heading.add_theme_font_size_override("font_size", 20)
	snapshot_heading.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	outer.add_child(snapshot_heading)

	var browser_row := HBoxContainer.new()
	browser_row.add_theme_constant_override("separation", 14)
	outer.add_child(browser_row)

	save_browser_list = ItemList.new()
	save_browser_list.name = "SaveBrowserList"
	save_browser_list.custom_minimum_size = Vector2(300, 240)
	save_browser_list.item_selected.connect(_on_save_browser_snapshot_selected)
	UiThemeScript.style_accessible_scrollbar(
		save_browser_list.get_v_scroll_bar(),
		"拖动查看命名快照；也可用滚轮或 ↑↓"
	)
	browser_row.add_child(save_browser_list)

	save_browser_detail_label = Label.new()
	save_browser_detail_label.name = "SaveBrowserDetail"
	save_browser_detail_label.custom_minimum_size = Vector2(390, 240)
	save_browser_detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_browser_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_browser_detail_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	browser_row.add_child(save_browser_detail_label)

	save_browser_status_label = Label.new()
	save_browser_status_label.name = "SaveBrowserStatus"
	save_browser_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_browser_status_label.add_theme_font_size_override("font_size", 13)
	save_browser_status_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	outer.add_child(save_browser_status_label)


func _on_start_pressed() -> void:
	_enter_game(false)


func _on_new_sandbox_pressed() -> void:
	_enter_game(false, true)


func _on_load_pressed() -> void:
	_open_save_browser()


func _on_character_archive_pressed() -> void:
	_enter_character_archive()


func _enter_character_archive() -> void:
	if _transitioning:
		return
	_transitioning = true
	var result := get_tree().change_scene_to_file(CHARACTER_ARCHIVE_SCENE_PATH)
	if result != OK:
		_transitioning = false
		push_error("无法打开人物志：%s" % error_string(result))


func _set_settings_status(message: String, failed: bool) -> void:
	if settings_status_label == null:
		return
	settings_status_label.text = message
	settings_status_label.add_theme_color_override(
		"font_color",
		UiThemeScript.TEXT_DANGER if failed else UiThemeScript.TEXT_HINT
	)


func _open_settings(status_message: String = "", status_failed := false) -> void:
	_remember_title_focus(settings_button)
	fullscreen_toggle.button_pressed = bool(_settings.get("fullscreen", false))
	vsync_toggle.button_pressed = bool(_settings.get("vsync", true))
	var effective_message := status_message
	var effective_failed := status_failed
	if effective_message.is_empty() and not _settings_load_notice.is_empty():
		effective_message = _settings_load_notice
		effective_failed = _settings_load_notice_failed
		_settings_load_notice = ""
		_settings_load_notice_failed = false
	_set_settings_status(
		effective_message if not effective_message.is_empty() else "点击“应用”后写入本机设置；沙盘存档保持独立。",
		effective_failed
	)
	settings_dialog.popup_centered(Vector2i(470, 310))
	call_deferred("_focus_title_control_after_popup", fullscreen_toggle)


func _open_about_dialog() -> void:
	if about_dialog == null:
		return
	_remember_title_focus(about_button)
	about_dialog.size = Vector2i(800, 590)
	about_dialog.popup_centered(Vector2i(800, 590))
	about_dialog.size = Vector2i(800, 590)
	if about_text != null:
		about_text.scroll_to_line(0)
	call_deferred("_focus_title_control_after_popup", about_dialog.get_ok_button())


func _apply_settings_from_dialog() -> void:
	var candidate := {
		"schema_version": SETTINGS_VERSION,
		"fullscreen": fullscreen_toggle.button_pressed,
		"vsync": vsync_toggle.button_pressed
	}
	var write_result := _write_settings_atomic(candidate)
	if not bool(write_result.get("ok", false)):
		var message := str(write_result.get("message", "无法安全保存设置。"))
		if not _is_automated_test_context():
			push_warning("标题设置没有保存：%s" % message)
		fullscreen_toggle.button_pressed = bool(_settings.get("fullscreen", false))
		vsync_toggle.button_pressed = bool(_settings.get("vsync", true))
		_set_settings_status("设置没有保存，已恢复此前设置。\n%s" % message, true)
		call_deferred("_focus_title_control_after_popup", fullscreen_toggle)
		return
	_settings = candidate
	_apply_settings(_settings)
	settings_dialog.hide()


func _open_exit_confirmation() -> void:
	_remember_title_focus(exit_button)
	exit_confirmation.popup_centered(Vector2i(430, 190))
	call_deferred("_focus_title_control_after_popup", exit_confirmation.get_cancel_button())


func _quit_game() -> void:
	get_tree().quit()


func _open_save_browser() -> void:
	_remember_title_focus(load_button)
	_refresh_save_browser()
	save_browser_dialog.size = Vector2i(780, 520)
	save_browser_dialog.popup_centered(Vector2i(780, 520))
	save_browser_dialog.size = Vector2i(780, 520)
	var target: Control = save_browser_list if not _save_browser_snapshots.is_empty() else save_browser_dialog.get_cancel_button()
	call_deferred("_focus_title_control_after_popup", target)


func _remember_title_focus(fallback: Control) -> void:
	_last_title_focus = fallback if is_instance_valid(fallback) else get_viewport().gui_get_focus_owner()


func _bind_title_dialog_focus(dialog: Window) -> void:
	dialog.visibility_changed.connect(_on_title_dialog_visibility_changed.bind(dialog))


func _on_title_dialog_visibility_changed(dialog: Window) -> void:
	if dialog.visible or _transitioning:
		return
	call_deferred("_restore_title_focus")


func _focus_title_control(control: Control) -> void:
	if is_instance_valid(control) and control.is_visible_in_tree() and control.focus_mode != Control.FOCUS_NONE:
		control.grab_focus()


func _focus_title_control_after_popup(control: Control) -> void:
	await get_tree().process_frame
	_focus_title_control(control)


func _restore_title_focus() -> void:
	if is_instance_valid(_last_title_focus) and _last_title_focus.is_visible_in_tree():
		_last_title_focus.grab_focus()
	else:
		_focus_default_title_action()


func _enter_snapshot_manager() -> void:
	_enter_game(true)


func _enter_game(open_snapshots: bool, open_new_sandbox := false) -> void:
	if _transitioning:
		return
	_transitioning = true
	var scene_tree := get_tree()
	scene_tree.set_meta(OPEN_SNAPSHOTS_META, open_snapshots)
	scene_tree.set_meta(OPEN_NEW_SANDBOX_META, open_new_sandbox)
	var result := scene_tree.change_scene_to_file(MAIN_SCENE_PATH)
	if result != OK:
		_transitioning = false
		scene_tree.remove_meta(OPEN_SNAPSHOTS_META)
		scene_tree.remove_meta(OPEN_NEW_SANDBOX_META)
		push_error("无法打开主沙盘场景：%s" % error_string(result))


func _has_test_script_argument(arguments: PackedStringArray) -> bool:
	for argument in arguments:
		var normalized := str(argument).replace("\\", "/").to_lower()
		if normalized.find("tests/test_") != -1 and normalized.ends_with(".gd"):
			return true
	return false


func _is_test_script_invocation() -> bool:
	return _has_test_script_argument(OS.get_cmdline_args())


func _is_automated_test_context() -> bool:
	return "--automated-test-mode" in OS.get_cmdline_user_args() or _is_test_script_invocation()


func _settings_path_for_context(user_args: PackedStringArray, automated_context: bool) -> String:
	if automated_context:
		return AUTOMATED_TEST_SETTINGS_PATH
	if "--test-mode" in user_args:
		return MANUAL_TEST_SETTINGS_PATH
	return FORMAL_SETTINGS_PATH


func _settings_path() -> String:
	return _settings_path_for_context(OS.get_cmdline_user_args(), _is_automated_test_context())


func _settings_previous_path(path: String = "") -> String:
	var effective_path := _settings_path() if path.is_empty() else path
	return effective_path + SETTINGS_PREVIOUS_SUFFIX


func _settings_temp_path(path: String = "") -> String:
	var effective_path := _settings_path() if path.is_empty() else path
	return effective_path + SETTINGS_TEMP_SUFFIX


func _settings_replace_path(path: String = "") -> String:
	var effective_path := _settings_path() if path.is_empty() else path
	return effective_path + SETTINGS_REPLACE_SUFFIX


func _default_settings() -> Dictionary:
	return {
		"schema_version": SETTINGS_VERSION,
		"fullscreen": DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN],
		"vsync": DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	}


func _decode_settings_document(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return {"ok": false, "message": "设置文件不是有效的 JSON 对象。"}
	if value.size() != 3 or not value.has("schema_version") or not value.has("fullscreen") or not value.has("vsync"):
		return {"ok": false, "message": "设置文件字段不完整或包含当前版本不识别的字段。"}
	var schema_value: Variant = value.get("schema_version", null)
	if (
		typeof(schema_value) not in [TYPE_INT, TYPE_FLOAT]
		or float(schema_value) != float(SETTINGS_VERSION)
	):
		return {"ok": false, "message": "设置文件版本不兼容。"}
	if not (value.get("fullscreen", null) is bool) or not (value.get("vsync", null) is bool):
		return {"ok": false, "message": "设置文件缺少有效的显示选项。"}
	return {
		"ok": true,
		"settings": {
			"schema_version": SETTINGS_VERSION,
			"fullscreen": bool(value.get("fullscreen", false)),
			"vsync": bool(value.get("vsync", true))
		}
	}


func _read_settings_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "status": "missing", "message": "设置文件不存在。"}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "status": "unreadable", "message": "设置文件无法打开。"}
	if file.get_length() > SETTINGS_FILE_LIMIT:
		file.close()
		return {"ok": false, "status": "invalid", "message": "设置文件超过安全大小。"}
	var text := file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return {"ok": false, "status": "invalid", "message": "设置文件不是有效的 JSON。"}
	var decoded := _decode_settings_document(parser.data)
	if not bool(decoded.get("ok", false)):
		decoded["status"] = "invalid"
		return decoded
	decoded["status"] = "ok"
	return decoded


func _remove_settings_file(path: String) -> bool:
	var absolute_path := ProjectSettings.globalize_path(path)
	return not FileAccess.file_exists(absolute_path) or DirAccess.remove_absolute(absolute_path) == OK


func _write_settings_bytes_verified(path: String, bytes: PackedByteArray) -> Dictionary:
	var absolute_path := ProjectSettings.globalize_path(path)
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "无法写入设置保护文件。"}
	file.store_buffer(bytes)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return {"ok": false, "message": "设置保护文件写入失败。"}
	if FileAccess.get_file_as_bytes(absolute_path) != bytes:
		return {"ok": false, "message": "设置保护文件回读不一致。"}
	var decoded := _read_settings_file(absolute_path)
	if not bool(decoded.get("ok", false)):
		return {
			"ok": false,
			"message": "设置保护文件没有通过格式校验（%s）：%s" % [path, str(decoded.get("message", "未知原因"))]
		}
	return {"ok": true}


func _finalize_settings_residue(path: String) -> void:
	var replace_path := _settings_replace_path(path)
	var previous_path := _settings_previous_path(path)
	var previous := _read_settings_file(previous_path)
	if not bool(previous.get("ok", false)):
		var replacement := _read_settings_file(replace_path)
		var protected_bytes := (
			FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(replace_path))
			if bool(replacement.get("ok", false))
			else FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(path))
		)
		var initial_previous_result := _write_settings_bytes_verified(previous_path, protected_bytes)
		if not bool(initial_previous_result.get("ok", false)):
			_settings_load_notice = "当前设置有效，但暂时无法建立上一份可靠设置。"
			_settings_load_notice_failed = true
	_remove_settings_file(_settings_temp_path(path))
	if bool(_read_settings_file(previous_path).get("ok", false)):
		_remove_settings_file(replace_path)


func _load_settings() -> Dictionary:
	_settings_load_notice = ""
	_settings_load_notice_failed = false
	var defaults := _default_settings()
	var path := _settings_path()
	var primary := _read_settings_file(path)
	if bool(primary.get("ok", false)):
		_finalize_settings_residue(path)
		return primary.get("settings", defaults).duplicate(true)
	var previous_path := _settings_previous_path(path)
	var replace_path := _settings_replace_path(path)
	var previous := _read_settings_file(previous_path)
	var replacement := _read_settings_file(replace_path)
	var previous_ok := bool(previous.get("ok", false))
	var replacement_ok := bool(replacement.get("ok", false))
	if (
		previous_ok
		and replacement_ok
		and previous.get("settings", {}) != replacement.get("settings", {})
	):
		_settings_load_notice = "找到两份互相冲突的已提交设置，已采用当前显示状态并保留原文件。"
		_settings_load_notice_failed = true
		_remove_settings_file(_settings_temp_path(path))
		return defaults
	var recovery_path := previous_path if previous_ok else replace_path if replacement_ok else ""
	if not recovery_path.is_empty():
		var recovery := previous if previous_ok else replacement
		var recovered_settings: Dictionary = recovery.get("settings", defaults).duplicate(true)
		if not previous_ok:
			var protect_result := _write_settings_bytes_verified(
				previous_path,
				FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(recovery_path))
			)
			if not bool(protect_result.get("ok", false)):
				_settings_load_notice = "已采用上一份有效设置；保护副本与主设置文件暂未恢复。"
				_settings_load_notice_failed = true
				_remove_settings_file(_settings_temp_path(path))
				return recovered_settings
		var restore_result := _write_settings_atomic(recovered_settings)
		_settings_load_notice = (
			"已从上一份有效设置恢复本机显示选项。"
			if bool(restore_result.get("ok", false))
			else "已采用上一份有效设置；主设置文件暂未恢复。"
		)
		_settings_load_notice_failed = not bool(restore_result.get("ok", false))
		return recovered_settings
	var had_uncommitted_temp := FileAccess.file_exists(ProjectSettings.globalize_path(_settings_temp_path(path)))
	_remove_settings_file(_settings_temp_path(path))
	if had_uncommitted_temp:
		_settings_load_notice = "发现未提交的设置临时文件，已忽略并采用当前显示状态。"
	elif str(primary.get("status", "missing")) != "missing" or str(previous.get("status", "missing")) != "missing":
		_settings_load_notice = "本机设置与上一份可靠设置均无法读取，已采用当前显示状态；原文件未覆盖。"
	_settings_load_notice_failed = not _settings_load_notice.is_empty()
	return defaults


func _write_settings_atomic(value: Dictionary) -> Dictionary:
	var decoded := _decode_settings_document(value)
	if not bool(decoded.get("ok", false)):
		return {"ok": false, "error_code": "invalid_settings", "message": str(decoded.get("message", "设置内容无效。"))}
	var settings: Dictionary = decoded.get("settings", {}).duplicate(true)
	var path := _settings_path()
	var absolute_path := ProjectSettings.globalize_path(path)
	var parent_dir := absolute_path.get_base_dir()
	if parent_dir.is_empty() or DirAccess.make_dir_recursive_absolute(parent_dir) != OK:
		return {"ok": false, "error_code": "write_failed", "message": "无法创建设置文件夹。"}
	var temp_path := _settings_temp_path(path)
	var replace_path := _settings_replace_path(path)
	var previous_path := _settings_previous_path(path)
	if not _remove_settings_file(temp_path):
		return {"ok": false, "error_code": "write_failed", "message": "无法清理未完成的设置临时文件。"}
	var serialized := JSON.stringify(settings, "\t").to_utf8_buffer()
	var temp_result := _write_settings_bytes_verified(temp_path, serialized)
	if not bool(temp_result.get("ok", false)):
		_remove_settings_file(temp_path)
		return {"ok": false, "error_code": "write_failed", "message": str(temp_result.get("message", "无法写入设置临时文件。"))}
	if _is_automated_test_context() and _automated_settings_write_failure_stage == "before_replace":
		_remove_settings_file(temp_path)
		return {"ok": false, "error_code": "write_failed", "message": "替换前故障，原设置保持不变。"}
	var primary_exists := FileAccess.file_exists(absolute_path)
	var primary := _read_settings_file(path)
	if primary_exists and bool(primary.get("ok", false)):
		var previous_result := _write_settings_bytes_verified(previous_path, FileAccess.get_file_as_bytes(absolute_path))
		if not bool(previous_result.get("ok", false)):
			_remove_settings_file(temp_path)
			return {"ok": false, "error_code": "write_failed", "message": "上一份有效设置没有安全保留，当前设置未替换。"}
	if primary_exists:
		if not _remove_settings_file(replace_path):
			_remove_settings_file(temp_path)
			return {"ok": false, "error_code": "write_failed", "message": "无法清理旧的设置恢复文件。"}
		if DirAccess.rename_absolute(absolute_path, ProjectSettings.globalize_path(replace_path)) != OK:
			_remove_settings_file(temp_path)
			return {"ok": false, "error_code": "write_failed", "message": "现有设置正在使用，未进行替换。"}
	if (
		primary_exists
		and _is_automated_test_context()
		and _automated_settings_write_failure_stage == "interrupt_after_old_moved"
	):
		return {
			"ok": false,
			"error_code": "simulated_interruption",
			"message": "旧设置移至恢复位置后发生中断。",
			"recovery_path": replace_path,
			"uncommitted_path": temp_path
		}
	var inject_promote_failure := (
		_is_automated_test_context()
		and _automated_settings_write_failure_stage in ["promote", "promote_and_restore"]
	)
	var promote_error := ERR_CANT_CREATE if inject_promote_failure else DirAccess.rename_absolute(ProjectSettings.globalize_path(temp_path), absolute_path)
	if promote_error != OK:
		var restore_error := OK
		if primary_exists:
			restore_error = (
				ERR_CANT_CREATE
				if _is_automated_test_context() and _automated_settings_write_failure_stage == "promote_and_restore"
				else DirAccess.rename_absolute(ProjectSettings.globalize_path(replace_path), absolute_path)
			)
		_remove_settings_file(temp_path)
		if restore_error != OK:
			return {
				"ok": false,
				"error_code": "recovery_required",
				"message": "新设置提升失败，旧设置保留在恢复文件中。",
				"recovery_path": replace_path
			}
		return {"ok": false, "error_code": "write_failed", "message": "新设置提升失败，原设置已恢复。"}
	var written := _read_settings_file(path)
	if not bool(written.get("ok", false)) or written.get("settings", {}) != settings:
		_remove_settings_file(path)
		var verify_restore_error := OK
		if primary_exists:
			verify_restore_error = DirAccess.rename_absolute(ProjectSettings.globalize_path(replace_path), absolute_path)
		if verify_restore_error != OK:
			return {
				"ok": false,
				"error_code": "recovery_required",
				"message": "新设置校验失败，旧设置保留在恢复文件中。",
				"recovery_path": replace_path
			}
		return {"ok": false, "error_code": "write_failed", "message": "新设置校验失败，原设置已恢复。"}
	_remove_settings_file(replace_path)
	var previous := _read_settings_file(previous_path)
	if not bool(previous.get("ok", false)):
		var initial_previous_result := _write_settings_bytes_verified(previous_path, serialized)
		if not bool(initial_previous_result.get("ok", false)):
			_settings_load_notice = "设置已保存，但暂时无法建立上一份可靠设置。"
			return {
				"ok": true,
				"error_code": "",
				"message": "设置已保存，但暂时无法建立上一份可靠设置。",
				"warning_code": "previous_unavailable",
				"path": path
			}
	_settings_load_notice = ""
	return {"ok": true, "error_code": "", "message": "", "path": path}


func _save_settings(value: Dictionary) -> bool:
	return bool(_write_settings_atomic(value).get("ok", false))


func _apply_settings(value: Dictionary) -> void:
	var fullscreen := bool(value.get("fullscreen", false))
	var target_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != target_mode:
		DisplayServer.window_set_mode(target_mode)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if bool(value.get("vsync", true)) else DisplayServer.VSYNC_DISABLED)


func _active_save_paths() -> Dictionary:
	var user_args := OS.get_cmdline_user_args()
	var suffix := ""
	if _is_automated_test_context():
		suffix = "_automated_test"
	elif "--test-mode" in user_args:
		suffix = "_test"
	return {
		"save": "user://sandbox_save%s.json" % suffix,
		"snapshots": "user://sandbox_snapshots%s.json" % suffix
	}


func _is_test_storage_context() -> bool:
	return _is_automated_test_context() or "--test-mode" in OS.get_cmdline_user_args()


func _storage_context_text() -> String:
	var user_args := OS.get_cmdline_user_args()
	if _is_automated_test_context():
		return "自动测试 · 隔离存档"
	if "--test-mode" in user_args:
		return "测试模式 · 隔离存档"
	return "本机存档"


func _read_preview_document(path: String, byte_limit: int) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"status": "missing", "path": path}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"status": "unreadable", "path": path, "message": "文件无法打开。"}
	if file.get_length() > byte_limit:
		return {"status": "unsupported", "path": path, "message": "文件超过封面预览的安全上限。"}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {"status": "unreadable", "path": path, "message": "文件不是有效的 JSON 对象。"}
	var parsed: Variant = parser.data
	if not (parsed is Dictionary):
		return {"status": "unreadable", "path": path, "message": "文件不是有效的 JSON 对象。"}
	return {"status": "ok", "path": path, "document": parsed}


func _is_preview_integer(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	if typeof(value) == TYPE_FLOAT:
		return is_equal_approx(float(value), floorf(float(value)))
	return false


func _preview_catalog_validation(sandbox: Dictionary, save_version: int) -> Dictionary:
	if save_version < CHARACTER_CATALOG_SAVE_VERSION:
		if sandbox.has("character_catalog_version"):
			return {"ok": false, "message": "旧版沙盘含有不应提前出现的人物目录字段。"}
		return {"ok": true, "catalog_version": 1}
	var catalog_version_value: Variant = sandbox.get("character_catalog_version", null)
	if not _is_preview_integer(catalog_version_value) or int(catalog_version_value) < 1:
		return {"ok": false, "message": "沙盘缺少可识别的人物目录版本。"}
	var catalog_version := int(catalog_version_value)
	if catalog_version > CURRENT_CHARACTER_CATALOG_VERSION:
		return {"ok": false, "message": "沙盘人物目录较新，请升级游戏后再试。"}
	if catalog_version == CURRENT_CHARACTER_CATALOG_VERSION:
		if save_version < CURRENT_SAVE_VERSION_MAX:
			return {"ok": false, "message": "沙盘版本与人物目录版本不属于同一发布组合。"}
		return {"ok": true, "catalog_version": catalog_version}
	if (
		catalog_version == PREVIOUS_CHARACTER_CATALOG_VERSION
		and save_version >= PREVIOUS_CHARACTER_CATALOG_MIN_SAVE_VERSION
		and save_version <= PREVIOUS_CHARACTER_CATALOG_MAX_SAVE_VERSION
	):
		return {
			"ok": true,
			"catalog_version": catalog_version,
			"catalog_migration_required": true,
		}
	if (
		(catalog_version == SECOND_PREVIOUS_CHARACTER_CATALOG_VERSION
		and save_version >= SECOND_PREVIOUS_CHARACTER_CATALOG_MIN_SAVE_VERSION
		and save_version <= SECOND_PREVIOUS_CHARACTER_CATALOG_MAX_SAVE_VERSION)
		or (catalog_version == 3 and save_version == HISTORICAL_V3_SAVE_VERSION)
		or (catalog_version == 4 and save_version == 16)
	):
		return {
			"ok": true,
			"catalog_version": catalog_version,
			"catalog_migration_required": true,
		}
	else:
		return {"ok": false, "message": "沙盘人物目录版本无法在标题页安全预览。"}


func _preview_single_line(value: Variant, fallback: String, maximum_length := 40) -> String:
	var text := str(value).replace("\r", " ").replace("\n", " ").strip_edges()
	if text.is_empty():
		return fallback
	return text.left(maximum_length)


func _preview_time(value: Variant) -> String:
	var text := _preview_single_line(value, "时间未记录", 40).replace("T", " ")
	return text.left(16) if text.length() >= 16 else text


func _preview_array_size(value: Variant) -> int:
	return value.size() if value is Array else 0


func _sandbox_preview_counts(sandbox: Dictionary) -> Dictionary:
	var scenario: Dictionary = sandbox.get("scenario_state", {}) if sandbox.get("scenario_state", {}) is Dictionary else {}
	var chronicle: Dictionary = sandbox.get("chronicle", {}) if sandbox.get("chronicle", {}) is Dictionary else {}
	var strokes: Dictionary = sandbox.get("player_strokes", {}) if sandbox.get("player_strokes", {}) is Dictionary else {}
	var character_states: Dictionary = sandbox.get("character_states", {}) if sandbox.get("character_states", {}) is Dictionary else {}
	var character_actions: Dictionary = sandbox.get("character_actions", {}) if sandbox.get("character_actions", {}) is Dictionary else {}
	return {
		"character_count": _preview_array_size(sandbox.get("cards", [])),
		"annotation_count": _preview_array_size(sandbox.get("annotations", [])),
		"faction_count": _preview_array_size(scenario.get("factions", [])),
		"chronicle_count": _preview_array_size(chronicle.get("entries", [])),
		"stroke_count": _preview_array_size(strokes.get("strokes", [])),
		"character_state_count": _preview_array_size(character_states.get("records", [])),
		"character_action_count": _preview_array_size(character_actions.get("records", []))
	}


func _current_save_preview(path: String) -> Dictionary:
	var read_result := _read_preview_document(path, CURRENT_SAVE_PREVIEW_LIMIT)
	if str(read_result.get("status", "")) != "ok":
		return read_result
	var document: Dictionary = read_result.get("document", {})
	var version_value: Variant = document.get("save_version", null)
	if not _is_preview_integer(version_value):
		return {"status": "unsupported", "path": path, "message": "存档缺少可识别的版本号。"}
	var save_version := int(version_value)
	if save_version < 1:
		return {"status": "unsupported", "path": path, "message": "存档版本无效。", "reason": "invalid_version"}
	if save_version > CURRENT_SAVE_VERSION_MAX:
		return {
			"status": "unsupported",
			"path": path,
			"message": "该存档由更新版本创建，请升级游戏后再试。",
			"reason": "future_version"
		}
	var catalog_validation := _preview_catalog_validation(document, save_version)
	if not bool(catalog_validation.get("ok", false)):
		return {
			"status": "unsupported",
			"path": path,
			"message": str(catalog_validation.get("message", "人物目录版本不兼容。")),
			"reason": "catalog_version"
		}
	if not (document.get("cards", null) is Array) or not (document.get("annotations", null) is Array):
		return {
			"status": "unsupported",
			"path": path,
			"message": "存档缺少可预览的人物或标记数据。",
			"reason": "invalid_structure"
		}
	var metadata: Dictionary = document.get("metadata", {}) if document.get("metadata", {}) is Dictionary else {}
	var counts := _sandbox_preview_counts(document)
	return {
		"status": "ok",
		"path": path,
		"title": _preview_single_line(metadata.get("title", ""), "未命名沙盘", 30),
		"scenario_source": _preview_single_line(metadata.get("scenario_source", ""), "", 60),
		"created_at": _preview_single_line(metadata.get("created_at", ""), "", 40),
		"updated_at": _preview_single_line(document.get("updated_at", ""), "", 40),
		"save_version": save_version,
		"character_count": int(counts.character_count),
		"annotation_count": int(counts.annotation_count),
		"faction_count": int(counts.faction_count),
		"chronicle_count": int(counts.chronicle_count),
		"stroke_count": int(counts.stroke_count),
		"character_state_count": int(counts.character_state_count),
		"character_action_count": int(counts.character_action_count)
	}


func _snapshot_store_preview(path: String) -> Dictionary:
	var read_result := _read_preview_document(path, SNAPSHOT_STORE_PREVIEW_LIMIT)
	if str(read_result.get("status", "")) != "ok":
		return read_result
	var document: Dictionary = read_result.get("document", {})
	var version_value: Variant = document.get("snapshot_store_version", null)
	if not _is_preview_integer(version_value) or int(version_value) != SNAPSHOT_STORE_VERSION:
		return {"status": "unsupported", "path": path, "message": "命名快照库版本不兼容。"}
	var values: Variant = document.get("snapshots", null)
	if not (values is Array) or values.size() > SNAPSHOT_LIMIT:
		return {"status": "unsupported", "path": path, "message": "命名快照数量或结构无效。"}
	var snapshots: Array[Dictionary] = []
	for index in range(values.size() - 1, -1, -1):
		var value: Variant = values[index]
		if not (value is Dictionary):
			return {"status": "unsupported", "path": path, "message": "命名快照库包含无效记录。"}
		var record: Dictionary = value
		var sandbox_value: Variant = record.get("sandbox", null)
		if not (sandbox_value is Dictionary):
			return {"status": "unsupported", "path": path, "message": "命名快照缺少沙盘内容。"}
		var snapshot_id := _preview_single_line(record.get("snapshot_id", ""), "", 80)
		var name := _preview_single_line(record.get("name", ""), "", 30)
		if snapshot_id.is_empty() or name.is_empty():
			return {"status": "unsupported", "path": path, "message": "命名快照缺少身份或名称。"}
		var sandbox: Dictionary = sandbox_value
		var sandbox_version_value: Variant = sandbox.get("save_version", null)
		if not _is_preview_integer(sandbox_version_value):
			return {"status": "unsupported", "path": path, "message": "命名快照缺少可识别的沙盘版本。"}
		var sandbox_version := int(sandbox_version_value)
		if sandbox_version < 1 or sandbox_version > CURRENT_SAVE_VERSION_MAX:
			return {"status": "unsupported", "path": path, "message": "命名快照包含当前版本无法预览的沙盘。"}
		var catalog_validation := _preview_catalog_validation(sandbox, sandbox_version)
		if not bool(catalog_validation.get("ok", false)):
			return {"status": "unsupported", "path": path, "message": str(catalog_validation.get("message", "命名快照人物目录版本不兼容。"))}
		var metadata: Dictionary = sandbox.get("metadata", {}) if sandbox.get("metadata", {}) is Dictionary else {}
		var counts := _sandbox_preview_counts(sandbox)
		snapshots.append({
			"snapshot_id": snapshot_id,
			"name": name,
			"note": _preview_single_line(record.get("note", ""), "", 120),
			"created_at": _preview_single_line(record.get("created_at", ""), "", 40),
			"source_title": _preview_single_line(metadata.get("title", ""), "未命名沙盘", 30),
			"character_count": int(counts.character_count),
			"annotation_count": int(counts.annotation_count),
			"faction_count": int(counts.faction_count),
			"chronicle_count": int(counts.chronicle_count),
			"stroke_count": int(counts.stroke_count),
			"character_state_count": int(counts.character_state_count),
			"character_action_count": int(counts.character_action_count)
		})
	return {"status": "ok", "path": path, "count": snapshots.size(), "items": snapshots}


func _title_recovery_preview(path: String) -> Dictionary:
	var absolute_path := ProjectSettings.globalize_path(path)
	var parent_dir := absolute_path.get_base_dir()
	var base_name := absolute_path.get_file()
	var directory := DirAccess.open(parent_dir)
	if directory == null:
		return {"status": "unavailable", "message": "无法检查沙盘所在文件夹。", "count": 0}
	var committed_paths: Array[String] = []
	var uncommitted_count := 0
	directory.list_dir_begin()
	while true:
		var filename := directory.get_next()
		if filename.is_empty():
			break
		if directory.current_is_dir():
			continue
		if (
			filename == base_name + PRIMARY_LAST_GOOD_SUFFIX
			or (filename.begins_with(base_name + ".replace-") and filename.ends_with(".tmp"))
		):
			committed_paths.append(parent_dir.path_join(filename))
		elif filename.begins_with(base_name + ".write-") and filename.ends_with(".tmp"):
			uncommitted_count += 1
	directory.list_dir_end()
	committed_paths.sort()
	var total := committed_paths.size() + uncommitted_count
	if total == 0:
		return {"status": "none", "count": 0, "uncommitted_count": 0}
	if total > PRIMARY_RECOVERY_CANDIDATE_LIMIT:
		return {"status": "ambiguous", "message": "找到多份未完成的保存记录。", "count": total, "uncommitted_count": uncommitted_count}

	var valid_by_hash: Dictionary = {}
	var future_count := 0
	var invalid_count := 0
	for candidate_path in committed_paths:
		var preview := _current_save_preview(candidate_path)
		if str(preview.get("status", "")) == "ok":
			var hash := FileAccess.get_sha256(candidate_path)
			if hash.is_empty():
				invalid_count += 1
				continue
			if not valid_by_hash.has(hash):
				valid_by_hash[hash] = []
			(valid_by_hash[hash] as Array).append(preview)
		elif str(preview.get("reason", "")) == "future_version":
			future_count += 1
		else:
			invalid_count += 1
	if future_count > 0 or valid_by_hash.size() > 1:
		var ambiguity_message := (
			"找到由更新版本创建的保存记录，当前版本不能安全恢复。"
			if future_count > 0
			else "找到多份内容不同的可恢复沙盘，不能自动选择。"
		)
		return {
			"status": "ambiguous",
			"message": ambiguity_message,
			"count": total,
			"uncommitted_count": uncommitted_count,
			"future_count": future_count,
			"invalid_count": invalid_count
		}
	if valid_by_hash.size() == 1:
		var candidates: Array = valid_by_hash.values()[0]
		return {
			"status": "available",
			"candidate": (candidates[0] as Dictionary).duplicate(true),
			"count": total,
			"uncommitted_count": uncommitted_count,
			"invalid_count": invalid_count
		}
	var unavailable_message := (
		"只找到未提交的写入记录，不能作为恢复依据。"
		if committed_paths.is_empty() and uncommitted_count > 0
		else "没有一份已提交的保存记录通过完整预览。"
	)
	return {
		"status": "unavailable",
		"message": unavailable_message,
		"count": total,
		"uncommitted_count": uncommitted_count,
		"invalid_count": invalid_count
	}


func get_save_catalog_preview(paths: Dictionary = {}) -> Dictionary:
	var effective_paths := _active_save_paths() if paths.is_empty() else paths
	var save_path := str(effective_paths.get("save", ""))
	return {
		"current": _current_save_preview(save_path),
		"recovery": _title_recovery_preview(save_path),
		"snapshots": _snapshot_store_preview(str(effective_paths.get("snapshots", "")))
	}


func _current_save_preview_text(current: Dictionary) -> String:
	match str(current.get("status", "")):
		"ok":
			return (
				"当前沙盘：%s\n"
				+ "人物 %d 张 · 标记 %d 个 · 推演线 %d 条 · 玩法分组 %d 组 · 玩家纪事 %d 则\n"
				+ "本局属性 %d 人 · 行动标注 %d 人\n"
				+ "上次保存：%s"
			) % [
				str(current.get("title", "未命名沙盘")),
				int(current.get("character_count", 0)),
				int(current.get("annotation_count", 0)),
				int(current.get("stroke_count", 0)),
				int(current.get("faction_count", 0)),
				int(current.get("chronicle_count", 0)),
				int(current.get("character_state_count", 0)),
				int(current.get("character_action_count", 0)),
				_preview_time(current.get("updated_at", ""))
			]
		"missing":
			return "当前沙盘：尚未创建\n点击“开始游戏”会进入一个空白沙盘。"
		_:
			return "当前沙盘：需要检查\n%s" % str(current.get("message", "请进入主沙盘查看完整检查结果。"))


func _snapshot_preview_detail(record: Dictionary) -> String:
	var note := str(record.get("note", ""))
	if note.is_empty():
		note = "（没有备注）"
	return (
		"%s\n\n"
		+ "创建时间：%s\n"
		+ "来自沙盘：%s\n"
		+ "人物 %d 张 · 标记 %d 个 · 推演线 %d 条\n"
		+ "玩法分组 %d 组 · 玩家纪事 %d 则 · 本局属性 %d 人 · 行动标注 %d 人\n\n"
		+ "%s"
	) % [
		str(record.get("name", "未命名快照")),
		_preview_time(record.get("created_at", "")),
		str(record.get("source_title", "未命名沙盘")),
		int(record.get("character_count", 0)),
		int(record.get("annotation_count", 0)),
		int(record.get("stroke_count", 0)),
		int(record.get("faction_count", 0)),
		int(record.get("chronicle_count", 0)),
		int(record.get("character_state_count", 0)),
		int(record.get("character_action_count", 0)),
		note
	]


func _refresh_save_browser(paths: Dictionary = {}) -> void:
	var catalog := get_save_catalog_preview(paths)
	var current: Dictionary = catalog.get("current", {})
	var snapshots: Dictionary = catalog.get("snapshots", {})
	save_browser_current_label.text = _current_save_preview_text(current)
	save_browser_list.clear()
	_save_browser_snapshots.clear()

	if str(snapshots.get("status", "")) == "ok":
		_save_browser_snapshots = snapshots.get("items", []).duplicate(true)
		for record in _save_browser_snapshots:
			save_browser_list.add_item(str(record.get("name", "未命名快照")))
			var item_index := save_browser_list.item_count - 1
			save_browser_list.set_item_tooltip(item_index, "创建于 %s · 来自 %s" % [
				_preview_time(record.get("created_at", "")),
				str(record.get("source_title", "未命名沙盘"))
			])

	var has_snapshots := not _save_browser_snapshots.is_empty()
	var snapshot_status := str(snapshots.get("status", ""))
	save_browser_dialog.get_ok_button().disabled = not has_snapshots
	if has_snapshots:
		save_browser_detail_label.text = "请选择一个快照查看详情。\n\n恢复操作将在主沙盘中再次确认。"
	elif snapshot_status in ["unreadable", "unsupported"]:
		save_browser_detail_label.text = "命名快照库需要检查。\n\n原文件保持原样，请进入主沙盘查看检查结果。"
	else:
		save_browser_detail_label.text = "还没有命名快照。\n\n先进入当前沙盘，再从沙盘菜单创建一个命名快照。"
	match snapshot_status:
		"ok":
			save_browser_status_label.text = "共 %d 个命名快照；首页提供只读预览。" % int(snapshots.get("count", 0))
		"missing":
			save_browser_status_label.text = "尚未建立命名快照库；当前沙盘仍可由首页主按钮进入。"
		_:
			save_browser_status_label.text = "命名快照库无法安全预览：%s\n原文件保持原样，请进入主沙盘查看完整检查结果。" % str(snapshots.get("message", "未知原因"))

	if has_snapshots:
		save_browser_list.select(0)
		_on_save_browser_snapshot_selected(0)


func _on_save_browser_snapshot_selected(index: int) -> void:
	if index < 0 or index >= _save_browser_snapshots.size():
		save_browser_detail_label.text = "请选择一个快照查看详情。"
		return
	save_browser_detail_label.text = _snapshot_preview_detail(_save_browser_snapshots[index])


func _snapshot_summary_text(snapshots: Dictionary) -> String:
	match str(snapshots.get("status", "")):
		"ok":
			var count := int(snapshots.get("count", 0))
			return "%d 个命名快照" % count if count > 0 else "尚无命名快照"
		"missing":
			return "尚无命名快照"
		_:
			return "命名快照库需要检查"


func _title_save_entry_state(current: Dictionary, snapshots: Dictionary, recovery: Dictionary = {}) -> Dictionary:
	var snapshot_text := _snapshot_summary_text(snapshots)
	match str(current.get("status", "")):
		"ok":
			var save_version := int(current.get("save_version", 0))
			var is_legacy := save_version < CURRENT_SAVE_VERSION_MAX
			return {
				"kind": "legacy" if is_legacy else "continuable",
				"start_text": "继续当前沙盘",
				"start_tooltip": (
					"继续旧版沙盘；进入后会先备份原文件，再升级为当前版本"
					if is_legacy
					else "继续当前自动存档；进入后会完成校验并恢复地图状态"
				),
				"summary_text": "%s · 人物 %d 张\n%s · %s%s" % [
					str(current.get("title", "未命名沙盘")),
					int(current.get("character_count", 0)),
					_preview_time(current.get("updated_at", "")),
					snapshot_text,
					"\n进入后将先备份并升级旧版沙盘" if is_legacy else ""
				]
			}
		"missing":
			if str(recovery.get("status", "")) == "available":
				var candidate: Dictionary = recovery.get("candidate", {})
				return {
					"kind": "recovery_available",
					"start_text": "查看恢复选项",
					"start_tooltip": "进入主沙盘查看上一份沙盘，并在写入前确认恢复",
					"summary_text": "当前沙盘没有完整保存\n找到“%s” · 人物 %d 张\n%s" % [
						str(candidate.get("title", "未命名沙盘")),
						int(candidate.get("character_count", 0)),
						snapshot_text
					]
				}
			if str(recovery.get("status", "")) in ["ambiguous", "unavailable"]:
				return {
					"kind": "needs_check",
					"start_text": "检查当前沙盘",
					"start_tooltip": "进入主沙盘查看恢复办法；当前文件保持原样",
					"summary_text": "当前沙盘需要检查\n%s\n%s" % [
						str(recovery.get("message", "保存过程中留下的文件均未改动。")),
						snapshot_text
					]
				}
			return {
				"kind": "new",
				"start_text": "开始游戏",
				"start_tooltip": "进入一个空白沙盘；首次有效操作后自动保存",
				"summary_text": "尚未创建当前沙盘\n%s" % snapshot_text
			}
		_:
			if str(current.get("reason", "")) == "future_version":
				return {
					"kind": "needs_check",
					"start_text": "检查当前沙盘",
					"start_tooltip": "当前沙盘由更新版本创建；请升级游戏，当前文件不会被降级覆盖",
					"summary_text": "当前沙盘需要更新版本\n%s\n%s\n%s" % [
						str(current.get("message", "请升级游戏后再试。")),
						"当前文件和恢复记录均保持原样" if str(recovery.get("status", "")) != "none" else "当前文件保持原样",
						snapshot_text
					]
				}
			if str(recovery.get("status", "")) == "available":
				var candidate: Dictionary = recovery.get("candidate", {})
				return {
					"kind": "recovery_available",
					"start_text": "查看恢复选项",
					"start_tooltip": "进入主沙盘确认恢复；当前打不开的文件会另行保留",
					"summary_text": "当前沙盘暂时打不开\n找到“%s” · 人物 %d 张\n%s" % [
						str(candidate.get("title", "未命名沙盘")),
						int(candidate.get("character_count", 0)),
						snapshot_text
					]
				}
			return {
				"kind": "needs_check",
				"start_text": "检查当前沙盘",
				"start_tooltip": "进入主沙盘查看完整检查结果；原文件保持写保护",
				"summary_text": "当前沙盘需要检查\n%s\n%s" % [
					str(current.get("message", "请进入主沙盘查看完整检查结果。")),
					snapshot_text
				]
			}


func _refresh_save_summary(paths: Dictionary = {}) -> void:
	if save_summary_label == null:
		return
	var catalog := get_save_catalog_preview(paths)
	var current: Dictionary = catalog.get("current", {})
	var recovery: Dictionary = catalog.get("recovery", {})
	var snapshots: Dictionary = catalog.get("snapshots", {})
	var entry_state := _title_save_entry_state(current, snapshots, recovery)
	save_summary_label.text = str(entry_state.get("summary_text", "当前沙盘状态待检查。"))
	if start_button != null:
		start_button.text = str(entry_state.get("start_text", "开始游戏"))
		start_button.tooltip_text = str(entry_state.get("start_tooltip", "进入当前沙盘"))


func get_title_screen_contract() -> Dictionary:
	return {
		"project_name": str(ProjectSettings.get_setting("application/config/name", "")),
		"cover_path": COVER_PATH,
		"main_scene_path": MAIN_SCENE_PATH,
		"character_archive_scene_path": CHARACTER_ARCHIVE_SCENE_PATH,
		"menu_actions": ["start", "new_sandbox", "load", "character_archive", "settings", "about", "exit"],
		"settings": ["fullscreen", "vsync"],
		"about_path": CREDITS_PATH,
		"about_sections": ["game", "sources", "assets_licenses", "acknowledgements"],
		"system_icons": {
			"load": LOAD_ICON_PATH,
			"settings": SETTINGS_ICON_PATH,
			"display_size_px": SYSTEM_ICON_SIZE,
			"alignment": "right",
			"text_preserved": true
		},
		"load_flow": "readonly_catalog_then_snapshot_manager",
		"load_action": "named_snapshot_catalog",
		"new_sandbox_entry": "existing_dialog_after_scene_change",
		"new_sandbox_meta": OPEN_NEW_SANDBOX_META,
		"start_states": ["new", "continuable", "legacy", "recovery_available", "needs_check"],
		"test_storage_isolated": true,
		"preview_is_read_only": true,
		"title_is_runtime_text": true,
		"cover_contains_title": false
	}
