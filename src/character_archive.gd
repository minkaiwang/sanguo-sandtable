class_name CharacterArchive
extends Control

## 首页进入的正式人物志。
##
## 只读当前目录 v5／87 人，提供搜索、分类与人物小传浏览。
## 本场景不访问 user://，也不提供人物编辑、拖放或保存。

const DataScript = preload("res://src/character_archive_data.gd")
const UiThemeScript = preload("res://src/ui_theme.gd")
const CharacterNameplateScript = preload("res://src/character_nameplate.gd")

const TITLE_SCENE_PATH := "res://scenes/title_screen.tscn"
const LIST_MIN_WIDTH := 410
const LIST_MAX_WIDTH := 570
const LIST_WIDTH_RATIO := 0.35
const DETAIL_NAMEPLATE_SIZE := 128
## 人物志是 80 人长名单，内部 Tree 的系统滑轨需要比普通次级列表更宽。
## 轨道本身保留整条命中区，首／尾按钮作为不依赖精确瞄准的备用入口。
const ARCHIVE_VERTICAL_SCROLLBAR_WIDTH := 40.0
const ARCHIVE_VERTICAL_SCROLLBAR_MIN_GRAB := 84.0
const ARCHIVE_HORIZONTAL_SCROLLBAR_WIDTH := 30.0
const ARCHIVE_HORIZONTAL_SCROLLBAR_MIN_GRAB := 64.0
const GROUP_ACCENTS := {
	"刘备军": Color("2f6f9f"),
	"黄巾军": Color("a87816"),
	"汉廷": Color("8d6534"),
	"群雄": Color("76538e"),
	"曹氏": Color("345c8a"),
	"孙氏": Color("a94839"),
}

var return_button: Button
var search_edit: LineEdit
var group_filter: OptionButton
var scenario_filter: OptionButton
var reset_button: Button
var count_label: Label
var character_tree: Tree
var detail_scroll: ScrollContainer
var detail_nameplate: PanelContainer
var detail_name: Label
var detail_group: Label
var detail_aliases: Label
var detail_scenarios: Label
var detail_headline: Label
var detail_biography: RichTextLabel
var empty_state: Label
var archive_list_position_label: Label
var archive_list_top_button: Button
var archive_list_bottom_button: Button
var archive_vertical_scrollbar: VScrollBar

var _data := DataScript.new()
var _records: Array[Dictionary] = []
var _records_by_id := {}
var _visible_records: Array[Dictionary] = []
var _group_counts := {}
var _scenarios: Array[Dictionary] = []
var _scenario_counts := {}
var _scenario_role_counts := {}
var _attribute_values := {}
var _selected_character_id := ""
var _split: HSplitContainer
var _transitioning := false


func _ready() -> void:
	name = "CharacterArchive"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiThemeScript.build_base_theme(16)
	get_window().title = "三国推演志 · 人物志"
	_build_interface()
	_load_archive()
	resized.connect(_apply_responsive_layout)
	# Tree 的滚动条是运行时生成的内部控件，等布局完成后再放大命中区。
	call_deferred("_style_archive_internal_scrollbars")
	call_deferred("_finish_initial_layout")


func _build_interface() -> void:
	var background := ColorRect.new()
	background.name = "ArchiveBackground"
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("#DEDCC7")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var outer := MarginContainer.new()
	outer.name = "ArchiveSafeMargin"
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 18)
	outer.add_theme_constant_override("margin_right", 18)
	outer.add_theme_constant_override("margin_top", 16)
	outer.add_theme_constant_override("margin_bottom", 16)
	add_child(outer)

	var shell := VBoxContainer.new()
	shell.name = "ArchiveShell"
	shell.add_theme_constant_override("separation", 12)
	outer.add_child(shell)
	shell.add_child(_build_header())
	shell.add_child(_build_filter_bar())

	_split = HSplitContainer.new()
	_split.name = "ArchiveBodySplit"
	_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_split.add_theme_constant_override("separation", 14)
	shell.add_child(_split)
	_split.add_child(_build_list_panel())
	_split.add_child(_build_detail_panel())


func _build_header() -> Control:
	var panel := PanelContainer.new()
	panel.name = "ArchiveHeader"
	panel.custom_minimum_size = Vector2(0, 66)
	panel.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_shell_panel(
			Color("#F7EFD8"),
			UiThemeScript.BORDER_BRASS,
			3,
			4,
			4
		)
	)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 0)
	row.add_child(title_box)
	var title := Label.new()
	title.name = "ArchiveTitle"
	title.text = "三国人物志"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	title_box.add_child(title)
	var subtitle := Label.new()
	subtitle.name = "ArchiveSubtitle"
	subtitle.text = "按人物、分类或内置开局翻阅四维与小传"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	title_box.add_child(subtitle)

	return_button = Button.new()
	return_button.name = "ReturnToTitleButton"
	return_button.text = "返回首页"
	return_button.tooltip_text = "返回游戏首页（Esc）"
	return_button.custom_minimum_size = Vector2(112, 40)
	return_button.focus_mode = Control.FOCUS_ALL
	return_button.pressed.connect(_return_to_title)
	UiThemeScript.apply_toolbar_button_style(return_button, false)
	row.add_child(return_button)
	return panel


func _build_filter_bar() -> Control:
	var panel := PanelContainer.new()
	panel.name = "ArchiveFilterBar"
	panel.custom_minimum_size = Vector2(0, 52)
	panel.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_shell_panel(
			Color("#F2ECD9"),
			UiThemeScript.BORDER_SHELL,
			1,
			3
		)
	)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)

	search_edit = LineEdit.new()
	search_edit.name = "ArchiveSearchEdit"
	search_edit.placeholder_text = "搜索人物姓名、字或别称……"
	search_edit.clear_button_enabled = true
	search_edit.custom_minimum_size = Vector2(250, 36)
	search_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_edit.text_changed.connect(func(_value: String): _refresh_list())
	search_edit.gui_input.connect(_on_search_gui_input)
	row.add_child(search_edit)

	group_filter = OptionButton.new()
	group_filter.name = "ArchiveGroupFilter"
	group_filter.custom_minimum_size = Vector2(150, 36)
	group_filter.item_selected.connect(func(_index: int): _refresh_list())
	row.add_child(group_filter)

	scenario_filter = OptionButton.new()
	scenario_filter.name = "ArchiveScenarioFilter"
	scenario_filter.custom_minimum_size = Vector2(190, 36)
	scenario_filter.tooltip_text = "按内置开局中的预摆人物和重点人物筛选"
	scenario_filter.item_selected.connect(func(_index: int): _refresh_list())
	row.add_child(scenario_filter)

	reset_button = Button.new()
	reset_button.name = "ArchiveResetFiltersButton"
	reset_button.text = "重置"
	reset_button.custom_minimum_size = Vector2(72, 36)
	reset_button.pressed.connect(_reset_filters)
	row.add_child(reset_button)

	count_label = Label.new()
	count_label.name = "ArchiveResultCount"
	count_label.custom_minimum_size = Vector2(228, 0)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count_label.clip_text = true
	count_label.add_theme_font_size_override("font_size", 14)
	count_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	row.add_child(count_label)
	return panel


func _build_list_panel() -> Control:
	var panel := PanelContainer.new()
	panel.name = "ArchiveListPanel"
	panel.custom_minimum_size = Vector2(LIST_MIN_WIDTH, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_shell_panel(
			UiThemeScript.INK_SHELL,
			UiThemeScript.BORDER_SHELL,
			1,
			4,
			4
		)
	)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.name = "ArchiveListColumn"
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	# 80 人长名单不要求玩家把鼠标精确落在一条细滑轨上：
	# 标题行提供明确的首／尾定位，同时保留轨道拖动、轨道翻页和滚轮。
	var list_toolbar := HBoxContainer.new()
	list_toolbar.name = "ArchiveListToolbar"
	list_toolbar.add_theme_constant_override("separation", 6)
	column.add_child(list_toolbar)
	var list_title := Label.new()
	list_title.text = "人物目录"
	list_title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	list_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	list_toolbar.add_child(list_title)
	archive_list_position_label = Label.new()
	archive_list_position_label.name = "ArchiveListPosition"
	archive_list_position_label.text = "人物 · 顶部"
	archive_list_position_label.add_theme_font_size_override("font_size", 13)
	archive_list_position_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	archive_list_position_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	archive_list_position_label.tooltip_text = "可拖动右侧滑轨，也可用首／尾按钮浏览完整人物目录"
	list_toolbar.add_child(archive_list_position_label)
	archive_list_top_button = _make_archive_scroll_button(
		"首", "回到人物志列表顶部（Home）", "ArchiveListScrollTopButton"
	)
	archive_list_top_button.pressed.connect(_scroll_archive_to_top)
	list_toolbar.add_child(archive_list_top_button)
	archive_list_bottom_button = _make_archive_scroll_button(
		"尾", "跳到人物志列表末尾（End）", "ArchiveListScrollBottomButton"
	)
	archive_list_bottom_button.pressed.connect(_scroll_archive_to_bottom)
	list_toolbar.add_child(archive_list_bottom_button)

	character_tree = Tree.new()
	character_tree.name = "ArchiveCharacterTree"
	character_tree.columns = 2
	character_tree.column_titles_visible = true
	character_tree.hide_root = true
	character_tree.select_mode = Tree.SELECT_ROW
	character_tree.allow_rmb_select = false
	character_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	character_tree.set_column_title(0, "人物")
	character_tree.set_column_title(1, "分类")
	character_tree.set_column_expand(0, true)
	character_tree.set_column_expand(1, false)
	character_tree.set_column_custom_minimum_width(0, 260)
	character_tree.set_column_custom_minimum_width(1, 84)
	_apply_tree_style()
	character_tree.item_selected.connect(_on_tree_item_selected)
	character_tree.gui_input.connect(_on_character_tree_gui_input)
	column.add_child(character_tree)
	return panel


func _make_archive_scroll_button(text_value: String, tooltip_text: String, node_name: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text_value
	button.custom_minimum_size = Vector2(36, 32)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.tooltip_text = tooltip_text
	UiThemeScript.apply_toolbar_button_style(button, false)
	return button


func _apply_tree_style() -> void:
	character_tree.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	character_tree.add_theme_color_override("font_hovered_color", UiThemeScript.TEXT_BUTTON_HOVER)
	character_tree.add_theme_color_override("font_selected_color", UiThemeScript.TEXT_BUTTON_HOVER)
	character_tree.add_theme_color_override("font_hovered_selected_color", UiThemeScript.TEXT_BUTTON_HOVER)
	character_tree.add_theme_color_override("guide_color", Color("#C9C2AC"))
	character_tree.add_theme_constant_override("v_separation", 6)
	character_tree.add_theme_constant_override("h_separation", 8)

	character_tree.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_shell_panel(Color("#FBF5E5"), Color("#C0B69E"), 1, 2)
	)
	var selected := UiThemeScript.make_shell_panel(
		Color("#E9D8AE"),
		UiThemeScript.GOLD_FOCUS,
		3,
		2
	)
	selected.content_margin_left = 4
	selected.content_margin_right = 4
	character_tree.add_theme_stylebox_override("selected", selected)
	character_tree.add_theme_stylebox_override("selected_focus", selected)
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color(0, 0, 0, 0)
	focus.border_color = UiThemeScript.GOLD_FOCUS
	focus.set_border_width_all(2)
	focus.set_corner_radius_all(2)
	character_tree.add_theme_stylebox_override("focus", focus)
	var title_normal := UiThemeScript.make_shell_panel(
		Color("#E9E2CC"),
		Color("#B6AD97"),
		1,
		1
	)
	title_normal.content_margin_top = 4
	title_normal.content_margin_bottom = 4
	var title_hover := title_normal.duplicate() as StyleBoxFlat
	title_hover.bg_color = Color("#F4E9CD")
	title_hover.border_color = UiThemeScript.GOLD_FOCUS
	character_tree.add_theme_stylebox_override("title_button_normal", title_normal)
	character_tree.add_theme_stylebox_override("title_button_hover", title_hover)
	character_tree.add_theme_stylebox_override("title_button_pressed", title_hover)
	character_tree.add_theme_color_override("title_button_color", UiThemeScript.TEXT_PANEL_TITLE)


func _build_detail_panel() -> Control:
	var panel := PanelContainer.new()
	panel.name = "ArchiveDetailPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_shell_panel(
			Color("#FAF4E2"),
			UiThemeScript.BORDER_BRASS_SOFT,
			2,
			4,
			5
		)
	)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	detail_scroll = ScrollContainer.new()
	detail_scroll.name = "ArchiveDetailScroll"
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_scroll.follow_focus = true
	margin.add_child(detail_scroll)
	_style_archive_scrollbar(detail_scroll.get_v_scroll_bar(), "拖动查看人物小传；也可用滚轮或 ↑↓")

	var column := VBoxContainer.new()
	column.name = "ArchiveDetailColumn"
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 13)
	detail_scroll.add_child(column)

	empty_state = Label.new()
	empty_state.name = "ArchiveEmptyState"
	empty_state.text = "没有符合条件的人物。请调整搜索词或分类。"
	empty_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_state.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty_state.custom_minimum_size = Vector2(0, 160)
	empty_state.add_theme_font_size_override("font_size", 18)
	empty_state.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(empty_state)

	var identity_row := HBoxContainer.new()
	identity_row.name = "ArchiveIdentityRow"
	identity_row.add_theme_constant_override("separation", 20)
	column.add_child(identity_row)

	var avatar_frame := PanelContainer.new()
	avatar_frame.custom_minimum_size = Vector2(140, 140)
	avatar_frame.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_record_panel(1.0, 2, Vector4(6, 6, 6, 6))
	)
	identity_row.add_child(avatar_frame)
	detail_nameplate = CharacterNameplateScript.new()
	detail_nameplate.name = "ArchiveDetailNameplate"
	detail_nameplate.call(
		"configure",
		"人物",
		Color("8d6534"),
		Vector2(DETAIL_NAMEPLATE_SIZE, DETAIL_NAMEPLATE_SIZE),
		false
	)
	avatar_frame.add_child(detail_nameplate)

	var identity_column := VBoxContainer.new()
	identity_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity_column.add_theme_constant_override("separation", 5)
	identity_row.add_child(identity_column)
	detail_name = Label.new()
	detail_name.name = "ArchiveDetailName"
	detail_name.add_theme_font_size_override("font_size", 32)
	detail_name.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	identity_column.add_child(detail_name)
	detail_group = Label.new()
	detail_group.name = "ArchiveDetailGroup"
	detail_group.add_theme_font_size_override("font_size", 16)
	detail_group.add_theme_color_override("font_color", UiThemeScript.TEXT_ACCENT)
	identity_column.add_child(detail_group)
	detail_aliases = Label.new()
	detail_aliases.name = "ArchiveDetailAliases"
	detail_aliases.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_aliases.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	identity_column.add_child(detail_aliases)
	detail_scenarios = Label.new()
	detail_scenarios.name = "ArchiveDetailScenarios"
	detail_scenarios.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_scenarios.add_theme_font_size_override("font_size", 14)
	detail_scenarios.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	identity_column.add_child(detail_scenarios)

	column.add_child(_section_title("人物四维"))
	var attributes_grid := GridContainer.new()
	attributes_grid.name = "ArchiveAttributesGrid"
	attributes_grid.columns = 4
	attributes_grid.add_theme_constant_override("h_separation", 10)
	column.add_child(attributes_grid)
	for attribute in [
		{"id": "might", "label": "武力"},
		{"id": "intelligence", "label": "智力"},
		{"id": "leadership", "label": "统率"},
		{"id": "charisma", "label": "魅力"},
	]:
		attributes_grid.add_child(_build_attribute_card(
			str(attribute.get("id", "")),
			str(attribute.get("label", ""))
		))

	column.add_child(_section_title("人物介绍"))
	detail_headline = Label.new()
	detail_headline.name = "ArchiveDetailHeadline"
	detail_headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_headline.add_theme_font_size_override("font_size", 21)
	detail_headline.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	column.add_child(detail_headline)
	detail_biography = RichTextLabel.new()
	detail_biography.name = "ArchiveDetailBiography"
	detail_biography.bbcode_enabled = false
	detail_biography.fit_content = true
	detail_biography.scroll_active = false
	detail_biography.custom_minimum_size = Vector2(0, 150)
	detail_biography.add_theme_font_size_override("normal_font_size", 17)
	detail_biography.add_theme_color_override("default_color", UiThemeScript.TEXT_BODY)
	column.add_child(detail_biography)
	return panel


func _build_attribute_card(attribute_id: String, label_text: String) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(118, 64)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_record_panel(0.92, 0, Vector4(10, 6, 10, 6))
	)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	row.add_child(label)
	var value := Label.new()
	value.name = "ArchiveAttribute%s" % attribute_id.capitalize()
	value.text = "—"
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value.add_theme_font_size_override("font_size", 25)
	value.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	row.add_child(value)
	_attribute_values[attribute_id] = value
	return panel


func _section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", UiThemeScript.TEXT_ACCENT)
	return label


func _style_archive_scrollbar(scroll_bar: ScrollBar, tooltip_text: String) -> void:
	if scroll_bar == null:
		return
	var is_vertical := scroll_bar is VScrollBar
	var width := ARCHIVE_VERTICAL_SCROLLBAR_WIDTH if is_vertical else ARCHIVE_HORIZONTAL_SCROLLBAR_WIDTH
	var min_grab := ARCHIVE_VERTICAL_SCROLLBAR_MIN_GRAB if is_vertical else ARCHIVE_HORIZONTAL_SCROLLBAR_MIN_GRAB
	UiThemeScript.style_accessible_scrollbar(
		scroll_bar,
		tooltip_text,
		width,
		min_grab
	)
	var belongs_to_character_tree := (
		is_vertical
		and character_tree != null
		and is_instance_valid(character_tree)
		and character_tree.is_ancestor_of(scroll_bar)
	)
	if belongs_to_character_tree:
		archive_vertical_scrollbar = scroll_bar as VScrollBar
		if not bool(scroll_bar.get_meta("archive_scroll_bound", false)):
			scroll_bar.value_changed.connect(_on_archive_scroll_value_changed)
			scroll_bar.gui_input.connect(_on_archive_scroll_gui_input)
			scroll_bar.set_meta("archive_scroll_bound", true)
	_update_archive_scroll_navigation()


func _style_archive_internal_scrollbars() -> void:
	# Godot 4 的 Tree 不公开 get_v_scroll_bar()/get_h_scroll_bar()；内部
	# V/HScrollBar 只有进入场景并完成布局后，才能通过 find_children 获取。
	if character_tree == null or not is_instance_valid(character_tree):
		return
	for node in character_tree.find_children("*", "VScrollBar", true, false):
		var bar := node as ScrollBar
		if bar != null:
			_style_archive_scrollbar(bar, "拖动查看全部 80 位人物；也可用滚轮或 ↑↓")
	for node in character_tree.find_children("*", "HScrollBar", true, false):
		var bar := node as ScrollBar
		if bar != null:
			_style_archive_scrollbar(bar, "横向查看人物姓名与别称")
	# 筛选或重建人物行后，Tree 可能重新测量内部条；下一帧再补一次。
	call_deferred("_style_archive_internal_scrollbars_late")
	_update_archive_scroll_navigation()


func _style_archive_internal_scrollbars_late() -> void:
	if character_tree == null or not is_instance_valid(character_tree):
		return
	for node in character_tree.find_children("*", "ScrollBar", true, false):
		var bar := node as ScrollBar
		if bar == null:
			continue
		var tooltip := "横向查看人物姓名与别称" if bar is HScrollBar else "拖动查看全部 80 位人物；也可用滚轮或 ↑↓"
		_style_archive_scrollbar(bar, tooltip)
	_update_archive_scroll_navigation()


func _on_archive_scroll_value_changed(_value: float) -> void:
	_update_archive_scroll_navigation()


func _on_archive_scroll_gui_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	match key_event.keycode:
		KEY_HOME:
			_scroll_archive_to_top()
			get_viewport().set_input_as_handled()
		KEY_END:
			_scroll_archive_to_bottom()
			get_viewport().set_input_as_handled()
		KEY_PAGEUP:
			_scroll_archive_page(-1)
			get_viewport().set_input_as_handled()
		KEY_PAGEDOWN:
			_scroll_archive_page(1)
			get_viewport().set_input_as_handled()


func _archive_scroll_limit() -> float:
	var bar := archive_vertical_scrollbar
	if bar == null or not is_instance_valid(bar):
		return 0.0
	return maxf(0.0, float(bar.max_value) - float(bar.page))


func _update_archive_scroll_navigation() -> void:
	if archive_list_position_label == null or not is_instance_valid(archive_list_position_label):
		return
	var limit := _archive_scroll_limit()
	var current := float(archive_vertical_scrollbar.value) if archive_vertical_scrollbar != null and is_instance_valid(archive_vertical_scrollbar) else 0.0
	var at_top := current <= 0.5
	var at_bottom := current >= limit - 0.5
	var visible_count := _visible_records.size()
	var count_text := "%d 人" % visible_count
	if visible_count != _records.size():
		count_text = "%d／%d 人" % [visible_count, _records.size()]
	archive_list_position_label.text = "%s · %s" % [count_text, "顶部" if at_top else ("末尾" if at_bottom else "浏览中")]
	if archive_list_top_button != null and is_instance_valid(archive_list_top_button):
		archive_list_top_button.disabled = not (limit > 0.5) or at_top
	if archive_list_bottom_button != null and is_instance_valid(archive_list_bottom_button):
		archive_list_bottom_button.disabled = not (limit > 0.5) or at_bottom


func _set_archive_scroll(value: float) -> void:
	if archive_vertical_scrollbar == null or not is_instance_valid(archive_vertical_scrollbar):
		return
	archive_vertical_scrollbar.value = clampf(value, 0.0, _archive_scroll_limit())
	_update_archive_scroll_navigation()


func _scroll_archive_to_top() -> void:
	_set_archive_scroll(0.0)


func _scroll_archive_to_bottom() -> void:
	_set_archive_scroll(_archive_scroll_limit())


func _scroll_archive_page(direction: int) -> void:
	if direction == 0 or archive_vertical_scrollbar == null or not is_instance_valid(archive_vertical_scrollbar):
		return
	var page := maxf(float(archive_vertical_scrollbar.page), 120.0)
	_set_archive_scroll(float(archive_vertical_scrollbar.value) + page * float(signi(direction)))


func _load_archive() -> void:
	var result := _data.load_archive()
	if not bool(result.get("ok", false)):
		_records.clear()
		count_label.text = "载入失败"
		empty_state.text = str(result.get("message", "人物志无法载入。"))
		_refresh_detail({})
		push_error(empty_state.text)
		return
	_records.assign(result.get("records", []))
	_group_counts = result.get("group_counts", {}).duplicate(true)
	_scenarios.assign(result.get("scenarios", []))
	_scenario_counts = result.get("scenario_counts", {}).duplicate(true)
	_scenario_role_counts = result.get("scenario_role_counts", {}).duplicate(true)
	_records_by_id.clear()
	for record in _records:
		_records_by_id[str(record.get("id", ""))] = record
	_rebuild_filters()
	_rebuild_scenario_filters()
	_refresh_list()


func _rebuild_filters() -> void:
	group_filter.clear()
	for group in DataScript.GROUP_ORDER:
		var label := "全部人物" if group.is_empty() else "%s · %d" % [
			group,
			int(_group_counts.get(group, 0)),
		]
		group_filter.add_item(label)
		group_filter.set_item_metadata(group_filter.item_count - 1, group)
	group_filter.select(0)


func _rebuild_scenario_filters() -> void:
	scenario_filter.clear()
	scenario_filter.add_item("全部开局")
	scenario_filter.set_item_metadata(0, "")
	for scenario in _scenarios:
		var scenario_id := str(scenario.get("id", ""))
		scenario_filter.add_item("%s · %d" % [
			str(scenario.get("name", "")),
			int(_scenario_counts.get(scenario_id, 0)),
		])
		scenario_filter.set_item_metadata(scenario_filter.item_count - 1, scenario_id)
	scenario_filter.select(0)


func _refresh_list() -> void:
	if character_tree == null:
		return
	var preserved_selection := _selected_character_id
	_visible_records.clear()
	var query := search_edit.text if search_edit != null else ""
	var group := get_group_filter()
	var scenario_id := get_scenario_filter()
	for record in _records:
		if DataScript.record_matches(record, query, group, scenario_id):
			_visible_records.append(record)

	character_tree.clear()
	var root_item := character_tree.create_item()
	var selected_item: TreeItem
	var first_item: TreeItem
	for record in _visible_records:
		var item := character_tree.create_item(root_item)
		if first_item == null:
			first_item = item
		var character_id := str(record.get("id", ""))
		var aliases: Array = record.get("aliases", [])
		var person_text := str(record.get("name", ""))
		if not aliases.is_empty():
			person_text += "  ·  " + "／".join(aliases)
		item.set_text(0, person_text)
		item.set_text(1, str(record.get("group", "")))
		item.set_metadata(0, character_id)
		item.set_tooltip_text(0, person_text)
		if character_id == preserved_selection:
			selected_item = item

	if selected_item == null:
		selected_item = first_item
	if selected_item != null:
		selected_item.select(0)
		_selected_character_id = str(selected_item.get_metadata(0))
		_refresh_detail(_records_by_id.get(_selected_character_id, {}))
	else:
		_selected_character_id = ""
		_refresh_detail({})
	_refresh_count_summary(scenario_id)
	# Tree.clear() 会让内部 VScrollBar 重新测量；先即时同步计数，
	# 下一帧再重新绑定／套用 40px 命中区，避免筛选后标题和滑轨短暂落后。
	_update_archive_scroll_navigation()
	call_deferred("_style_archive_internal_scrollbars")


func _refresh_count_summary(scenario_id: String) -> void:
	if count_label == null:
		return
	if scenario_id.is_empty():
		count_label.text = "显示 %d／%d" % [_visible_records.size(), _records.size()]
		count_label.tooltip_text = "当前筛选结果／正式人物总数"
		return
	var roles: Dictionary = _scenario_role_counts.get(scenario_id, {})
	var members := int(roles.get("members", _scenario_counts.get(scenario_id, 0)))
	var placed := int(roles.get("placed", 0))
	var featured := int(roles.get("featured", 0))
	var overlap := int(roles.get("placed_and_featured", 0))
	count_label.text = "%d／%d · 预摆%d · 重点%d" % [
		_visible_records.size(),
		members,
		placed,
		featured,
	]
	count_label.tooltip_text = "当前结果 %d 人；本开局共 %d 人，预摆 %d 人、重点 %d 人，其中 %d 人同时属于预摆与重点。" % [
		_visible_records.size(),
		members,
		placed,
		featured,
		overlap,
	]


func _on_tree_item_selected() -> void:
	var item := character_tree.get_selected()
	if item == null:
		return
	_selected_character_id = str(item.get_metadata(0))
	_refresh_detail(_records_by_id.get(_selected_character_id, {}))
	character_tree.scroll_to_item(item, false)


func _on_character_tree_gui_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	match key_event.keycode:
		KEY_HOME:
			_scroll_archive_to_top()
			get_viewport().set_input_as_handled()
		KEY_END:
			_scroll_archive_to_bottom()
			get_viewport().set_input_as_handled()
		KEY_PAGEUP:
			_scroll_archive_page(-1)
			get_viewport().set_input_as_handled()
		KEY_PAGEDOWN:
			_scroll_archive_page(1)
			get_viewport().set_input_as_handled()


func _refresh_detail(record: Dictionary) -> void:
	var has_record := not record.is_empty()
	empty_state.visible = not has_record
	for control in [
		detail_nameplate,
		detail_name,
		detail_group,
		detail_aliases,
		detail_scenarios,
		detail_headline,
		detail_biography,
	]:
		control.visible = has_record
	for value in _attribute_values.values():
		(value as Label).visible = has_record
	if not has_record:
		return

	detail_nameplate.call(
		"configure",
		str(record.get("name", "")),
		_accent_for_group(str(record.get("group", ""))),
		Vector2(DETAIL_NAMEPLATE_SIZE, DETAIL_NAMEPLATE_SIZE),
		false
	)
	detail_name.text = str(record.get("name", ""))
	detail_group.text = "人物分类 · %s" % str(record.get("group", ""))
	var aliases: Array = record.get("aliases", [])
	detail_aliases.visible = not aliases.is_empty()
	detail_aliases.text = "字／别称 · %s" % "、".join(aliases)
	var scenarios: Array = record.get("scenarios", [])
	detail_scenarios.visible = not scenarios.is_empty()
	var scenario_labels: Array[String] = []
	for scenario in scenarios:
		scenario_labels.append("%s（%s）" % [
			str(scenario.get("name", "")),
			str(scenario.get("role", "")),
		])
	detail_scenarios.text = "内置开局 · %s" % "；".join(scenario_labels)
	var attributes: Dictionary = record.get("attributes", {})
	for attribute_id in _attribute_values:
		(_attribute_values[attribute_id] as Label).text = str(
			int(attributes.get(attribute_id, 0))
		)
	detail_headline.text = str(record.get("headline", ""))
	detail_biography.text = str(record.get("biography", ""))
	detail_scroll.scroll_vertical = 0


func _accent_for_group(group: String) -> Color:
	return GROUP_ACCENTS.get(group, Color("8d6534")) as Color


func _on_search_gui_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event
	if not key_event.pressed or key_event.echo or key_event.keycode != KEY_DOWN:
		return
	var root_item := character_tree.get_root()
	var first := root_item.get_first_child() if root_item != null else null
	if first != null:
		character_tree.grab_focus()
		first.select(0)
		character_tree.scroll_to_item(first, false)
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void:
	if (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_ESCAPE
	):
		_return_to_title()
		get_viewport().set_input_as_handled()


func _reset_filters() -> void:
	search_edit.text = ""
	group_filter.select(0)
	scenario_filter.select(0)
	_refresh_list()
	search_edit.grab_focus()


func _finish_initial_layout() -> void:
	_apply_responsive_layout()
	_style_archive_internal_scrollbars()
	if search_edit != null:
		search_edit.grab_focus()


func _apply_responsive_layout() -> void:
	if _split == null:
		return
	var desired_list_width := clampf(
		size.x * LIST_WIDTH_RATIO,
		float(LIST_MIN_WIDTH),
		float(LIST_MAX_WIDTH)
	)
	var available_width := _split.size.x if _split.size.x > 0.0 else size.x
	_split.split_offset = int(desired_list_width - available_width * 0.5)


func _return_to_title() -> bool:
	if _transitioning:
		return false
	_transitioning = true
	var result := get_tree().change_scene_to_file(TITLE_SCENE_PATH)
	if result != OK:
		_transitioning = false
		push_error("无法返回游戏首页：%s" % error_string(result))
		return false
	return true


func set_search_query(value: String) -> void:
	if search_edit == null:
		return
	search_edit.text = value
	_refresh_list()


func set_group_filter(value: String) -> void:
	if group_filter == null:
		return
	for index in range(group_filter.item_count):
		if str(group_filter.get_item_metadata(index)) == value:
			group_filter.select(index)
			_refresh_list()
			return


func get_group_filter() -> String:
	if group_filter == null or group_filter.item_count == 0:
		return ""
	return str(group_filter.get_item_metadata(group_filter.selected))


func set_scenario_filter(value: String) -> void:
	if scenario_filter == null:
		return
	for index in range(scenario_filter.item_count):
		if str(scenario_filter.get_item_metadata(index)) == value:
			scenario_filter.select(index)
			_refresh_list()
			return


func get_scenario_filter() -> String:
	if scenario_filter == null or scenario_filter.item_count == 0:
		return ""
	return str(scenario_filter.get_item_metadata(scenario_filter.selected))


func get_visible_character_ids() -> Array[String]:
	var result: Array[String] = []
	for record in _visible_records:
		result.append(str(record.get("id", "")))
	return result


func select_character(character_id: String) -> bool:
	var root_item := character_tree.get_root() if character_tree != null else null
	if root_item == null:
		return false
	var item := root_item.get_first_child()
	while item != null:
		if str(item.get_metadata(0)) == character_id:
			item.select(0)
			character_tree.scroll_to_item(item, true)
			_selected_character_id = character_id
			_refresh_detail(_records_by_id.get(character_id, {}))
			return true
		item = item.get_next()
	return false


func get_selected_character_summary() -> Dictionary:
	if _selected_character_id.is_empty():
		return {}
	var record: Dictionary = _records_by_id.get(_selected_character_id, {})
	return {
		"id": str(record.get("id", "")),
		"name": str(record.get("name", "")),
		"group": str(record.get("group", "")),
		"presentation_mode": "nameplate",
	}


func get_archive_contract() -> Dictionary:
	return {
		"title_scene_path": TITLE_SCENE_PATH,
		"catalog_version": DataScript.CATALOG_VERSION,
		"formal_count": DataScript.FORMAL_COUNT,
		"records": _records.size(),
		"group_counts": _group_counts.duplicate(true),
		"scenario_count": _scenarios.size(),
		"scenario_counts": _scenario_counts.duplicate(true),
		"scenario_role_counts": _scenario_role_counts.duplicate(true),
		"scenario_filter": get_scenario_filter(),
		"visible_records": _visible_records.size(),
		"selected_character_id": _selected_character_id,
		"list_width_min": LIST_MIN_WIDTH,
		"list_width_max": LIST_MAX_WIDTH,
		"vertical_scrollbar_width": ARCHIVE_VERTICAL_SCROLLBAR_WIDTH,
		"vertical_scrollbar_min_grab": ARCHIVE_VERTICAL_SCROLLBAR_MIN_GRAB,
		"scroll_navigation_buttons": 2,
		"presentation_mode": "nameplate",
		"detail_nameplate_size": DETAIL_NAMEPLATE_SIZE,
		"nameplate_uses_raster_asset": false,
		"detail_portrait_size": 0,
		"list_icon_size": 0,
		"data_policy": "formal_catalog_v5_only",
		"user_data_access": false,
		"save_controls": 0,
		"edit_controls": 0,
		"drag_controls": 0,
	}
