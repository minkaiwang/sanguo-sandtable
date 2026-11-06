class_name BackpackPanel
extends PanelContainer

signal character_returned(character_id: String)
signal favorite_toggled(character_id: String, favorite: bool)
signal placed_character_focus_requested(character_id: String)
signal character_details_requested(character_id: String, browse_ids: Array[String])
signal collapse_requested()
signal hand_candidate_changed(character_id: String, selected: bool, selected_count: int)
signal hand_candidate_limit_reached(limit: int)
signal scenario_take_completed(added_count: int, pending_count: int, capacity_limited: bool)

const CharacterCardScript = preload("res://src/character_card.gd")
const UiThemeScript = preload("res://src/ui_theme.gd")
const HAND_CANDIDATE_LIMIT := 8
## 交互尺寸按桌面鼠标的实际命中目标设置，而不是只按视觉细线设置。
## 32px 能覆盖常见系统缩放下的鼠标误差，也让滑轨本身成为明确的操作目标；
## 滑块再保留 72px 的纵向抓取长度，避免长列表里出现“看得到但抓不住”。
const BACKPACK_SCROLLBAR_WIDTH := 32.0
const BACKPACK_SCROLLBAR_GRABBER_MIN_HEIGHT := 72.0
const BACKPACK_CHARACTER_SCROLL_MIN_VISIBLE_HEIGHT := 145.0
## 滚动容器自身会预留系统滚动条的 12px 最小槽位；在 32px 实际命中条
## 的基础上再留 22px，给卡牌按钮留出清晰视觉间隙，同时把窄栏的
## 自然最小宽度控制在既有 292—294px 合约内。
const BACKPACK_SCROLLBAR_CONTENT_CLEARANCE := 22
const BACKPACK_SCROLLBAR_STEP := 108.0

var _characters: Array = []
var _placed: Dictionary = {}
var _search_edit: LineEdit
var _group_filter: OptionButton
var _favorites_only: CheckButton
var _featured_only: CheckButton
var _scenario_focus_summary: Label
var _scenario_guidance_row: HBoxContainer
var _scenario_guidance_label: Label
var _scenario_take_button: Button
var _scenario_outer_candidates_panel: PanelContainer
var _scenario_outer_candidates_label: Label
var _scroll_top_button: Button
var _scroll_bottom_button: Button
var _cards_box: VBoxContainer
var _count_label: Label
var _favorite_ids: Dictionary = {}
var _selected_group := ""
var _featured_scenario_id := ""
var _featured_scenario_label := ""
var _featured_character_ids: Dictionary = {}
var _scenario_take_ids: Array[String] = []
var _scenario_conditional_ids: Array[String] = []
var _scenario_take_label := ""
var _scenario_take_hint := ""
var _visible_character_ids: Array[String] = []
var _visible_placed_character_ids: Array[String] = []
var _visible_profile_character_ids: Array[String] = []
var _favorite_buttons: Dictionary = {}
var _character_cards: Dictionary = {}
var _placed_focus_buttons: Dictionary = {}
var _placed_details_buttons: Dictionary = {}
var _scroll: ScrollContainer
var _suppress_search_signal := false
var _refresh_count := 0
var _hand_candidate_ids: Array[String] = []
var _visible_hand_candidate_ids: Array[String] = []
var _hand_toggle_buttons: Dictionary = {}
var _hand_character_cards: Dictionary = {}
var _hand_placed_buttons: Dictionary = {}
var _hand_panel: PanelContainer
var _hand_header_button: Button
var _hand_clear_button: Button
var _hand_grid: GridContainer
var _hand_expanded := true
var _hand_auto_collapsed_for_space := false


func _ready() -> void:
	custom_minimum_size = Vector2(292, 0)
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP

	var style := StyleBoxFlat.new()
	style.bg_color = UiThemeScript.INK_SHELL
	style.border_color = UiThemeScript.BORDER_SHELL
	style.set_border_width_all(1)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 3)
	column.add_child(title_row)

	var title := Label.new()
	title.text = "人物背包"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)

	_count_label = Label.new()
	_count_label.add_theme_font_size_override("font_size", 14)
	_count_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_row.add_child(_count_label)

	_scroll_top_button = Button.new()
	_scroll_top_button.name = "BackpackScrollTopButton"
	_scroll_top_button.text = "首"
	_scroll_top_button.custom_minimum_size = Vector2(32, 32)
	_scroll_top_button.tooltip_text = "回到人物列表顶部（Home）"
	_scroll_top_button.focus_mode = Control.FOCUS_ALL
	_scroll_top_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_style_scroll_navigation_button(_scroll_top_button)
	_scroll_top_button.pressed.connect(_scroll_to_top)
	title_row.add_child(_scroll_top_button)

	_scroll_bottom_button = Button.new()
	_scroll_bottom_button.name = "BackpackScrollBottomButton"
	_scroll_bottom_button.text = "尾"
	_scroll_bottom_button.custom_minimum_size = Vector2(32, 32)
	_scroll_bottom_button.tooltip_text = "跳到人物列表末尾（End）"
	_scroll_bottom_button.focus_mode = Control.FOCUS_ALL
	_scroll_bottom_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_style_scroll_navigation_button(_scroll_bottom_button)
	_scroll_bottom_button.pressed.connect(_scroll_to_bottom)
	title_row.add_child(_scroll_bottom_button)

	var collapse_button := Button.new()
	collapse_button.name = "CollapseBackpackButton"
	collapse_button.text = "收起"
	collapse_button.tooltip_text = "把人物背包收成窄栏，为地图腾出空间"
	collapse_button.custom_minimum_size = Vector2(44, 30)
	collapse_button.focus_mode = Control.FOCUS_ALL
	_style_scroll_navigation_button(collapse_button)
	collapse_button.pressed.connect(func(): collapse_requested.emit())
	title_row.add_child(collapse_button)

	var subtitle := Label.new()
	subtitle.text = "左键拖图；右键小传 · 右侧滑轨可点按/拖动 · 首/尾定位"
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	column.add_child(subtitle)

	_search_edit = LineEdit.new()
	_search_edit.placeholder_text = "搜索人物姓名或别名…  Ctrl+F"
	_search_edit.tooltip_text = "搜索人物姓名、字号或别名（Ctrl+F）"
	_search_edit.clear_button_enabled = true
	_search_edit.text_changed.connect(_on_search_changed)
	column.add_child(_search_edit)

	var filter_row := HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 8)
	column.add_child(filter_row)

	_group_filter = OptionButton.new()
	_group_filter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_group_filter.tooltip_text = "按人物原型分类筛选；剧本时期阵营另行记录"
	_group_filter.item_selected.connect(_on_group_selected)
	filter_row.add_child(_group_filter)

	_favorites_only = CheckButton.new()
	_favorites_only.text = "仅看收藏"
	_favorites_only.tooltip_text = "只显示已经星标的人物"
	_favorites_only.toggled.connect(_on_favorites_only_toggled)
	filter_row.add_child(_favorites_only)
	_rebuild_group_filter()

	_featured_only = CheckButton.new()
	_featured_only.name = "FeaturedCharactersOnly"
	_featured_only.text = "本局重点人物"
	_featured_only.tooltip_text = "切换人物背包的显示范围；地图与当前沙盘保持原样"
	_featured_only.focus_mode = Control.FOCUS_ALL
	_featured_only.visible = false
	_featured_only.toggled.connect(_on_featured_only_toggled)
	column.add_child(_featured_only)

	_scenario_focus_summary = Label.new()
	_scenario_focus_summary.name = "ScenarioFocusSummary"
	_scenario_focus_summary.visible = false
	_scenario_focus_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scenario_focus_summary.add_theme_font_size_override("font_size", 12)
	_scenario_focus_summary.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	_scenario_focus_summary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_scenario_focus_summary)

	_scenario_guidance_row = HBoxContainer.new()
	_scenario_guidance_row.name = "ScenarioTakeGuidanceRow"
	_scenario_guidance_row.add_theme_constant_override("separation", 6)
	_scenario_guidance_row.visible = false
	column.add_child(_scenario_guidance_row)

	_scenario_guidance_label = Label.new()
	_scenario_guidance_label.name = "ScenarioTakeGuidanceLabel"
	_scenario_guidance_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scenario_guidance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scenario_guidance_label.add_theme_font_size_override("font_size", 12)
	_scenario_guidance_label.add_theme_color_override("font_color", UiThemeScript.TEXT_ACCENT)
	_scenario_guidance_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scenario_guidance_row.add_child(_scenario_guidance_label)

	_scenario_take_button = Button.new()
	_scenario_take_button.name = "ScenarioTakeGuidanceButton"
	_scenario_take_button.text = "拿补位"
	_scenario_take_button.custom_minimum_size = Vector2(68, 32)
	_scenario_take_button.focus_mode = Control.FOCUS_ALL
	_scenario_take_button.tooltip_text = "按顺序把推荐人物放到手边；不会自动摆到地图"
	_scenario_take_button.pressed.connect(take_scenario_recommendations)
	_scenario_guidance_row.add_child(_scenario_take_button)

	column.add_child(_build_hand_tray())

	var divider := HSeparator.new()
	column.add_child(divider)

	_scroll = ScrollContainer.new()
	_scroll.name = "BackpackCharacterScroll"
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.gui_input.connect(_on_scroll_container_gui_input)
	column.add_child(_scroll)
	_style_scrollbar()

	var cards_margin := MarginContainer.new()
	cards_margin.name = "BackpackCardsScrollbarClearance"
	cards_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Godot 的滚动条覆盖在内容右缘；显式留出同宽空白，避免收藏按钮
	# 落到滑轨下面，尤其是在 1366 宽度与系统缩放场景中。
	cards_margin.add_theme_constant_override("margin_right", BACKPACK_SCROLLBAR_CONTENT_CLEARANCE)
	_scroll.add_child(cards_margin)

	_cards_box = VBoxContainer.new()
	_cards_box.name = "BackpackCharacterRows"
	_cards_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cards_box.add_theme_constant_override("separation", 8)
	_cards_box.resized.connect(_on_scroll_layout_changed)
	cards_margin.add_child(_cards_box)

	var return_hint := Label.new()
	return_hint.text = "也可以把地图上的卡牌拖回这里"
	return_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return_hint.add_theme_font_size_override("font_size", 12)
	return_hint.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(return_hint)


func _style_scrollbar() -> void:
	var scroll_bar := _scroll.get_v_scroll_bar()
	scroll_bar.name = "BackpackScrollbar"
	# 主背包有专用 32px／72px 规格；全局次级滚动条扫描时保留这套更大的命中区。
	scroll_bar.set_meta("preserve_accessible_scrollbar", true)
	# 32px 是实际可命中的控件宽度，不只是把细线画粗；保留整条轨道接收点击。
	scroll_bar.custom_minimum_size.x = BACKPACK_SCROLLBAR_WIDTH
	scroll_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll_bar.focus_mode = Control.FOCUS_ALL
	scroll_bar.custom_step = BACKPACK_SCROLLBAR_STEP
	scroll_bar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	scroll_bar.tooltip_text = "拖动滑块；点击轨道翻页；滚轮或 ↑↓ 查看全部人物"

	var track := StyleBoxFlat.new()
	track.bg_color = Color("c9c2ab")
	track.border_color = Color("8d927e")
	track.set_border_width_all(1)
	track.set_corner_radius_all(10)
	scroll_bar.add_theme_stylebox_override("scroll", track)
	scroll_bar.add_theme_stylebox_override("scroll_focus", track)

	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Color("6f7e68")
	grabber.border_color = Color("4d5e50")
	grabber.set_border_width_all(1)
	grabber.set_corner_radius_all(10)
	grabber.content_margin_left = 3.0
	grabber.content_margin_right = 3.0
	# VScrollBar 以抓手样式的最小高度限制滑块，不使用 SplitContainer 的
	# minimum_grab_thickness 常量。上下各 36px，确保短列表视窗下也有
	# 至少 72px 的可拖动目标。
	grabber.content_margin_top = 36.0
	grabber.content_margin_bottom = 36.0
	scroll_bar.add_theme_stylebox_override("grabber", grabber)
	var grabber_highlight := grabber.duplicate() as StyleBoxFlat
	grabber_highlight.bg_color = UiThemeScript.BORDER_BRASS_SOFT
	grabber_highlight.border_color = UiThemeScript.GOLD_FOCUS
	scroll_bar.add_theme_stylebox_override("grabber_highlight", grabber_highlight)
	scroll_bar.add_theme_stylebox_override("grabber_pressed", grabber_highlight)
	# 让轨道两端也成为清晰的、可点击的步进入口；没有图标时 Godot 会
	# 把端点压成几乎不可见的细条，玩家很难判断滚动条是否可用。
	var step_up := UiThemeScript._make_ui_icon("triangle_up", UiThemeScript.TEXT_BUTTON)
	var step_down := UiThemeScript._make_ui_icon("triangle_down", UiThemeScript.TEXT_BUTTON)
	var step_up_hover := UiThemeScript._make_ui_icon("triangle_up", UiThemeScript.GOLD_FOCUS)
	var step_down_hover := UiThemeScript._make_ui_icon("triangle_down", UiThemeScript.GOLD_FOCUS)
	var step_up_disabled := UiThemeScript._make_ui_icon("triangle_up", UiThemeScript.TEXT_DISABLED)
	var step_down_disabled := UiThemeScript._make_ui_icon("triangle_down", UiThemeScript.TEXT_DISABLED)
	for icon_name in ["decrement", "decrement_highlight", "decrement_pressed"]:
		scroll_bar.add_theme_icon_override(icon_name, step_up if icon_name == "decrement" else step_up_hover)
	for icon_name in ["increment", "increment_highlight", "increment_pressed"]:
		scroll_bar.add_theme_icon_override(icon_name, step_down if icon_name == "increment" else step_down_hover)
	scroll_bar.add_theme_icon_override("decrement_disabled", step_up_disabled)
	scroll_bar.add_theme_icon_override("increment_disabled", step_down_disabled)
	# StyleBox 的 content margin 同时决定可抓取滑块的最小高度；显式保留
	# 合约值，避免未来主题改动把滑块缩回细小目标。
	if scroll_bar.get_theme_stylebox("grabber").get_minimum_size().y < BACKPACK_SCROLLBAR_GRABBER_MIN_HEIGHT:
		grabber.content_margin_top = BACKPACK_SCROLLBAR_GRABBER_MIN_HEIGHT * 0.5
		grabber.content_margin_bottom = BACKPACK_SCROLLBAR_GRABBER_MIN_HEIGHT * 0.5
		scroll_bar.add_theme_stylebox_override("grabber", grabber)
	scroll_bar.gui_input.connect(_on_scrollbar_gui_input)
	scroll_bar.value_changed.connect(_on_scrollbar_value_changed)
	call_deferred("_update_scroll_navigation")


func _style_scroll_navigation_button(button: Button) -> void:
	if button == null:
		return
	var normal := UiThemeScript.make_shell_panel(Color("e9e5d2"), UiThemeScript.BORDER_SHELL, 1, 3)
	normal.content_margin_left = 4
	normal.content_margin_right = 4
	normal.content_margin_top = 3
	normal.content_margin_bottom = 3
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("f8efd5")
	hover.border_color = UiThemeScript.GOLD_FOCUS
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	var focus := normal.duplicate() as StyleBoxFlat
	focus.border_color = UiThemeScript.GOLD_FOCUS
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("d9d8ca")
	disabled.border_color = Color("b8b9ab")
	button.add_theme_stylebox_override("disabled", disabled)


func _on_scrollbar_value_changed(_value: float) -> void:
	_update_scroll_navigation()


func _on_scroll_layout_changed() -> void:
	# 容器先完成子项测量，再更新首／尾按钮状态；仅靠 _ready 时机
	# 会在首次载入 80 人时把“尾”误判为不可用。
	call_deferred("_update_scroll_navigation")


func _on_scroll_container_gui_input(event: InputEvent) -> void:
	_handle_scroll_navigation_key(event)


func _on_scrollbar_gui_input(event: InputEvent) -> void:
	_handle_scroll_navigation_key(event)


func _handle_scroll_navigation_key(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	match key_event.keycode:
		KEY_HOME:
			_scroll_to_top()
			get_viewport().set_input_as_handled()
		KEY_END:
			_scroll_to_bottom()
			get_viewport().set_input_as_handled()
		KEY_PAGEUP:
			_scroll_page(-1)
			get_viewport().set_input_as_handled()
		KEY_PAGEDOWN:
			_scroll_page(1)
			get_viewport().set_input_as_handled()


func _scroll_to_top() -> void:
	if _scroll == null:
		return
	_scroll.scroll_vertical = 0
	_update_scroll_navigation()


func _scroll_to_bottom() -> void:
	if _scroll == null:
		return
	var scroll_bar := _scroll.get_v_scroll_bar()
	if scroll_bar == null:
		return
	_scroll.scroll_vertical = int(ceil(_scroll_limit(scroll_bar)))
	_update_scroll_navigation()


func _scroll_page(direction: int) -> void:
	if _scroll == null or direction == 0:
		return
	var scroll_bar := _scroll.get_v_scroll_bar()
	if scroll_bar == null:
		return
	var page := maxf(float(scroll_bar.page), BACKPACK_SCROLLBAR_STEP)
	var limit := _scroll_limit(scroll_bar)
	var target := clampf(
		float(_scroll.scroll_vertical) + page * float(signi(direction)),
		0.0,
		limit
	)
	_scroll.scroll_vertical = int(round(target))
	_update_scroll_navigation()


func _update_scroll_navigation() -> void:
	if _scroll == null:
		return
	var scroll_bar := _scroll.get_v_scroll_bar()
	if scroll_bar == null:
		return
	var maximum := _scroll_limit(scroll_bar)
	var can_scroll := maximum > 0.5
	var at_top := _scroll.scroll_vertical <= 0
	var at_bottom := float(_scroll.scroll_vertical) >= maximum - 0.5
	if _scroll_top_button != null:
		_scroll_top_button.disabled = not can_scroll or at_top
	if _scroll_bottom_button != null:
		_scroll_bottom_button.disabled = not can_scroll or at_bottom


func _scroll_limit(scroll_bar: ScrollBar) -> float:
	if scroll_bar == null:
		return 0.0
	## ScrollBar.max_value 是内容总范围，实际可滚动值还要扣除当前视窗 page。
	return maxf(0.0, float(scroll_bar.max_value) - float(scroll_bar.page))


func set_characters(value: Array) -> void:
	_characters = value
	_sanitize_hand_candidates()
	_rebuild_group_filter()
	set_favorites(_favorite_ids)


func set_placed(value: Dictionary) -> void:
	_placed = value
	_refresh_cards()


func set_favorites(value: Dictionary) -> void:
	var valid_ids := {}
	for character in _characters:
		var character_id := str(character.get("id", ""))
		if not character_id.is_empty() and bool(value.get(character_id, false)):
			valid_ids[character_id] = true
	_favorite_ids = valid_ids
	_refresh_cards()


func is_favorite(character_id: String) -> bool:
	return _favorite_ids.has(character_id)


func toggle_favorite(character_id: String) -> void:
	if not _has_character(character_id):
		return
	var next_value := not _favorite_ids.has(character_id)
	if next_value:
		_favorite_ids[character_id] = true
	else:
		_favorite_ids.erase(character_id)
	favorite_toggled.emit(character_id, next_value)
	_refresh_cards()


func set_search_query(value: String) -> void:
	if _search_edit == null:
		return
	_suppress_search_signal = true
	_search_edit.set_text(value)
	_suppress_search_signal = false
	_refresh_cards()


func set_group_filter(group: String) -> void:
	if _group_filter == null:
		_selected_group = group
		return
	for index in range(_group_filter.item_count):
		if str(_group_filter.get_item_metadata(index)) == group:
			_group_filter.select(index)
			_selected_group = group
			_refresh_cards()
			return
	_group_filter.select(0)
	_selected_group = ""
	_refresh_cards()


func set_favorites_only(value: bool) -> void:
	if _favorites_only == null:
		return
	_favorites_only.set_pressed_no_signal(value)
	_refresh_cards()


func set_scenario_focus(
	scenario_id: String,
	scenario_label: String,
	character_ids: Array,
	default_enabled: bool,
	refresh_cards := true
) -> void:
	var next_ids: Dictionary = {}
	for character_id_value in character_ids:
		var character_id := str(character_id_value)
		if not character_id.is_empty() and _has_character(character_id):
			next_ids[character_id] = true
	var scenario_changed := scenario_id != _featured_scenario_id
	_featured_scenario_id = scenario_id
	_featured_scenario_label = scenario_label.strip_edges()
	_featured_character_ids = next_ids
	if _featured_only == null:
		return
	var has_featured := not _featured_character_ids.is_empty()
	_featured_only.visible = has_featured
	if not has_featured:
		_featured_only.set_pressed_no_signal(false)
	elif scenario_changed:
		_featured_only.set_pressed_no_signal(default_enabled)
	_featured_only.text = "本局重点 · %d 人" % _featured_character_ids.size()
	_featured_only.tooltip_text = (
		"%s重点人物；取消勾选可查看完整人物目录。只改变背包显示，不修改沙盘。"
		% (_featured_scenario_label + " · " if not _featured_scenario_label.is_empty() else "")
	)
	_update_scenario_focus_summary()
	_update_scenario_take_guidance()
	if refresh_cards:
		_refresh_cards()


func set_scenario_take_guidance(guidance: Dictionary, refresh_cards := true) -> void:
	_scenario_take_ids.clear()
	_scenario_conditional_ids.clear()
	_scenario_take_label = str(guidance.get("label", "")).strip_edges()
	_scenario_take_hint = str(guidance.get("hint", "")).strip_edges()
	var seen := {}
	var take_values: Variant = guidance.get("take_character_ids", [])
	if take_values is Array:
		for value in take_values:
			var character_id := str(value).strip_edges()
			if not character_id.is_empty() and not seen.has(character_id) and _has_character(character_id):
				seen[character_id] = true
				_scenario_take_ids.append(character_id)
	var conditional_values: Variant = guidance.get("conditional_character_ids", [])
	if conditional_values is Array:
		for value in conditional_values:
			var character_id := str(value).strip_edges()
			if not character_id.is_empty() and not seen.has(character_id) and _has_character(character_id):
				seen[character_id] = true
				_scenario_conditional_ids.append(character_id)
	_update_scenario_take_guidance()
	if refresh_cards:
		_refresh_cards()


func set_featured_only(value: bool) -> void:
	if _featured_only == null:
		return
	_featured_only.set_pressed_no_signal(value and not _featured_character_ids.is_empty())
	_refresh_cards()


func is_featured_only() -> bool:
	return _featured_filter_active()


func get_featured_character_ids() -> Array[String]:
	var result: Array[String] = []
	for character in _characters:
		var character_id := str(character.get("id", ""))
		if _featured_character_ids.has(character_id):
			result.append(character_id)
	return result


func get_featured_only_button() -> CheckButton:
	return _featured_only


func get_scenario_take_button() -> Button:
	return _scenario_take_button


func get_scenario_take_state() -> Dictionary:
	var pending_ids := _scenario_take_pending_ids()
	return {
		"visible": _scenario_guidance_row != null and _scenario_guidance_row.visible,
		"label": _scenario_take_label,
		"hint": _scenario_take_hint,
		"take_ids": _scenario_take_ids.duplicate(),
		"conditional_ids": _scenario_conditional_ids.duplicate(),
		"pending_ids": pending_ids,
		"button_disabled": _scenario_take_button != null and _scenario_take_button.disabled,
		"button_text": _scenario_take_button.text if _scenario_take_button != null else "",
	}


func get_scenario_outer_candidates_state() -> Dictionary:
	return {
		"visible": _scenario_outer_candidates_panel != null \
			and _scenario_outer_candidates_panel.is_inside_tree() \
			and _scenario_outer_candidates_panel.visible,
		"text": _scenario_outer_candidates_label.text if _scenario_outer_candidates_label != null else "",
		"character_ids": _scenario_conditional_ids.duplicate(),
		"scroll_child_index": _scenario_outer_candidates_panel.get_index() if _scenario_outer_candidates_panel != null and _scenario_outer_candidates_panel.is_inside_tree() else -1,
		"rect": _scenario_outer_candidates_panel.get_global_rect() if _scenario_outer_candidates_panel != null and _scenario_outer_candidates_panel.is_inside_tree() else Rect2(),
	}


func take_scenario_recommendations() -> void:
	var added_count := 0
	var capacity_limited := false
	for character_id in _scenario_take_ids:
		if _placed.has(character_id) or _hand_candidate_ids.has(character_id):
			continue
		if _hand_candidate_ids.size() >= HAND_CANDIDATE_LIMIT:
			capacity_limited = true
			break
		if add_hand_candidate(character_id):
			added_count += 1
	var pending_count := _scenario_take_pending_ids().size()
	if pending_count > 0 and _hand_candidate_ids.size() >= HAND_CANDIDATE_LIMIT:
		capacity_limited = true
	_update_scenario_take_guidance()
	if added_count > 0 and _hand_header_button != null and _hand_header_button.is_visible_in_tree():
		_hand_header_button.grab_focus()
	scenario_take_completed.emit(added_count, pending_count, capacity_limited)


func get_scenario_focus_summary() -> Dictionary:
	var counts := _scenario_focus_counts()
	counts["visible"] = _scenario_focus_summary != null and _scenario_focus_summary.visible
	counts["text"] = _scenario_focus_summary.text if _scenario_focus_summary != null else ""
	counts["scenario_label"] = _featured_scenario_label
	return counts


func get_visible_character_ids() -> Array[String]:
	return _visible_character_ids.duplicate()


func get_visible_placed_character_ids() -> Array[String]:
	return _visible_placed_character_ids.duplicate()


func get_visible_profile_character_ids() -> Array[String]:
	return _visible_profile_character_ids.duplicate()


func get_group_options() -> Array[String]:
	var groups: Array[String] = []
	if _group_filter == null:
		return groups
	for index in range(_group_filter.item_count):
		groups.append(str(_group_filter.get_item_metadata(index)))
	return groups


func get_favorite_button(character_id: String) -> Button:
	return _favorite_buttons.get(character_id) as Button


func get_character_card(character_id: String) -> CharacterCard:
	return _character_cards.get(character_id) as CharacterCard


func get_placed_focus_button(character_id: String) -> Button:
	return _placed_focus_buttons.get(character_id) as Button


func get_placed_details_button(character_id: String) -> Button:
	return _placed_details_buttons.get(character_id) as Button


func get_scroll_container() -> ScrollContainer:
	return _scroll


func get_scroll_top_button() -> Button:
	return _scroll_top_button


func get_scroll_bottom_button() -> Button:
	return _scroll_bottom_button


func get_search_edit() -> LineEdit:
	return _search_edit


func focus_search(select_existing_text := true) -> bool:
	if _search_edit == null or not is_instance_valid(_search_edit) or not _search_edit.is_visible_in_tree():
		return false
	_search_edit.grab_focus()
	if select_existing_text:
		_search_edit.select_all()
	return true


func prepare_new_sandbox_landing(show_featured: bool) -> void:
	if _search_edit != null:
		_suppress_search_signal = true
		_search_edit.set_text("")
		_suppress_search_signal = false
	_selected_group = ""
	if _group_filter != null:
		for index in range(_group_filter.item_count):
			if str(_group_filter.get_item_metadata(index)).is_empty():
				_group_filter.select(index)
				break
	if _favorites_only != null:
		_favorites_only.set_pressed_no_signal(false)
	if _featured_only != null:
		_featured_only.set_pressed_no_signal(
			show_featured
			and _featured_only.visible
			and not _featured_character_ids.is_empty()
		)
	_refresh_cards()
	if _scroll != null:
		_scroll.scroll_vertical = 0


func focus_character_entry(character_id: String) -> String:
	var target: Control
	var action := ""
	if _hand_toggle_buttons.has(character_id):
		target = _hand_toggle_buttons.get(character_id) as Control
		action = "take"
	elif _placed_focus_buttons.has(character_id):
		target = _placed_focus_buttons.get(character_id) as Control
		action = "locate"
	if target == null or not is_instance_valid(target) or not target.is_visible_in_tree():
		return ""
	if _scroll != null:
		_scroll.ensure_control_visible(target)
	target.grab_focus()
	return action if target.has_focus() else ""


func get_refresh_count() -> int:
	return _refresh_count


func get_hand_candidate_ids() -> Array[String]:
	return _hand_candidate_ids.duplicate()


func get_visible_hand_candidate_ids() -> Array[String]:
	return _visible_hand_candidate_ids.duplicate()


func is_hand_candidate(character_id: String) -> bool:
	return _hand_candidate_ids.has(character_id)


func get_hand_toggle_button(character_id: String) -> Button:
	return _hand_toggle_buttons.get(character_id) as Button


func get_hand_character_card(character_id: String) -> CharacterCard:
	return _hand_character_cards.get(character_id) as CharacterCard


func get_hand_placed_button(character_id: String) -> Button:
	return _hand_placed_buttons.get(character_id) as Button


func get_hand_header_button() -> Button:
	return _hand_header_button


func _capture_hand_focus_context() -> Dictionary:
	var viewport := get_viewport()
	if viewport == null or _hand_panel == null:
		return {}
	var focus_owner := viewport.gui_get_focus_owner()
	if (
		focus_owner == null
		or not is_instance_valid(focus_owner)
		or (focus_owner != _hand_panel and not _hand_panel.is_ancestor_of(focus_owner))
	):
		return {}
	var character_id := ""
	for character_id_value in _hand_placed_buttons:
		var placed_button := _hand_placed_buttons.get(character_id_value) as Button
		if placed_button == focus_owner:
			character_id = str(character_id_value)
			break
	return {"character_id": character_id}


func _capture_favorite_focus_context() -> Dictionary:
	var viewport := get_viewport()
	if viewport == null:
		return {}
	var focus_owner := viewport.gui_get_focus_owner()
	if focus_owner == null or not is_instance_valid(focus_owner):
		return {}
	var character_id := ""
	for character_id_value in _favorite_buttons:
		if _favorite_buttons.get(character_id_value) == focus_owner:
			character_id = str(character_id_value)
			break
	if character_id.is_empty():
		return {}
	return {
		"character_id": character_id,
		"visible_order": _visible_character_ids.duplicate(),
		"visible_index": _visible_character_ids.find(character_id),
		"scroll_vertical": _scroll.scroll_vertical if _scroll != null else 0
	}


func _control_can_receive_restored_focus(control: Control) -> bool:
	return (
		control != null
		and is_instance_valid(control)
		and control.is_visible_in_tree()
		and control.focus_mode != Control.FOCUS_NONE
		and not (control is BaseButton and (control as BaseButton).disabled)
	)


func _restore_hand_focus_after_refresh(context: Dictionary) -> void:
	if context.is_empty() or not is_inside_tree():
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var current_owner := viewport.gui_get_focus_owner()
	if current_owner is Control and _control_can_receive_restored_focus(current_owner as Control):
		return
	var character_id := str(context.get("character_id", ""))
	var target := _hand_placed_buttons.get(character_id) as Control if not character_id.is_empty() else null
	for candidate in [target, _hand_header_button, _scenario_take_button, _featured_only, _search_edit]:
		var control := candidate as Control
		if not _control_can_receive_restored_focus(control):
			continue
		control.grab_focus()
		if control.has_focus():
			return


func _restore_favorite_focus_after_refresh(context: Dictionary) -> void:
	if context.is_empty() or not is_inside_tree():
		return
	# ScrollContainer 要到下一帧才会拿到重建后的内容高度；等布局稳定后再
	# 恢复旧位置并确保目标可见，避免长收藏列表被中途钳到顶部。
	await get_tree().process_frame
	if not is_inside_tree():
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var current_owner := viewport.gui_get_focus_owner()
	if current_owner is Control and _control_can_receive_restored_focus(current_owner as Control):
		return
	if _scroll != null:
		var scroll_bar := _scroll.get_v_scroll_bar()
		var restored_scroll := clampi(
			int(context.get("scroll_vertical", 0)),
			0,
			int(ceil(_scroll_limit(scroll_bar)))
		)
		_scroll.scroll_vertical = restored_scroll

	var visible_order: Array[String] = []
	for value in context.get("visible_order", []):
		visible_order.append(str(value))
	var original_id := str(context.get("character_id", ""))
	var original_index := int(context.get("visible_index", visible_order.find(original_id)))
	var candidate_ids: Array[String] = []
	if not original_id.is_empty():
		candidate_ids.append(original_id)
	for index in range(maxi(0, original_index + 1), visible_order.size()):
		var next_id := visible_order[index]
		if not candidate_ids.has(next_id):
			candidate_ids.append(next_id)
	for index in range(mini(original_index - 1, visible_order.size() - 1), -1, -1):
		var previous_id := visible_order[index]
		if not candidate_ids.has(previous_id):
			candidate_ids.append(previous_id)

	for candidate_id in candidate_ids:
		var favorite_button := _favorite_buttons.get(candidate_id) as Control
		if not _control_can_receive_restored_focus(favorite_button):
			continue
		if _scroll != null:
			_scroll.ensure_control_visible(favorite_button)
		favorite_button.grab_focus()
		if favorite_button.has_focus():
			return

	var fallback_controls: Array[Control] = []
	if _scroll != null:
		fallback_controls.append(_scroll.get_v_scroll_bar())
	fallback_controls.append(_search_edit)
	for control in fallback_controls:
		if not _control_can_receive_restored_focus(control):
			continue
		control.grab_focus()
		if control.has_focus():
			return


func toggle_hand_candidate(character_id: String) -> bool:
	if _hand_candidate_ids.has(character_id):
		return remove_hand_candidate(character_id)
	return add_hand_candidate(character_id)


func take_hand_candidate_and_focus_next(character_id: String) -> bool:
	if _hand_candidate_ids.has(character_id):
		return false
	var order_before: Array[String] = _visible_character_ids.duplicate()
	var start_index := order_before.find(character_id)
	if not add_hand_candidate(character_id):
		return false
	call_deferred("_focus_next_take_action", order_before, start_index)
	return true


func _focus_next_take_action(order_before: Array[String], start_index: int) -> void:
	if order_before.is_empty():
		return
	var normalized_start := maxi(-1, start_index)
	for index in range(normalized_start + 1, order_before.size()):
		var next_id := order_before[index]
		var next_button := _hand_toggle_buttons.get(next_id) as Button
		if next_button == null or not is_instance_valid(next_button) or not next_button.is_visible_in_tree():
			continue
		if _scroll != null:
			_scroll.ensure_control_visible(next_button)
		next_button.grab_focus()
		return
	if _hand_header_button != null and _hand_header_button.is_visible_in_tree():
		_hand_header_button.grab_focus()


func add_hand_candidate(character_id: String) -> bool:
	if not _has_character(character_id) or _placed.has(character_id) or _hand_candidate_ids.has(character_id):
		return false
	if _hand_candidate_ids.size() >= HAND_CANDIDATE_LIMIT:
		hand_candidate_limit_reached.emit(HAND_CANDIDATE_LIMIT)
		return false
	_hand_candidate_ids.append(character_id)
	_hand_expanded = true
	_hand_auto_collapsed_for_space = false
	_refresh_cards()
	_preserve_character_list_after_hand_change()
	hand_candidate_changed.emit(character_id, true, _hand_candidate_ids.size())
	_update_scenario_take_guidance()
	return true


func remove_hand_candidate(character_id: String) -> bool:
	if not _hand_candidate_ids.has(character_id):
		return false
	_hand_candidate_ids.erase(character_id)
	_refresh_cards()
	hand_candidate_changed.emit(character_id, false, _hand_candidate_ids.size())
	_update_scenario_take_guidance()
	return true


func clear_hand_candidates() -> bool:
	if _hand_candidate_ids.is_empty():
		return false
	_hand_candidate_ids.clear()
	_refresh_cards()
	hand_candidate_changed.emit("", false, 0)
	_update_scenario_take_guidance()
	return true


func set_hand_tray_expanded(value: bool) -> void:
	if _hand_expanded == value:
		return
	_hand_expanded = value
	_hand_auto_collapsed_for_space = false
	_refresh_hand_tray()


func get_hand_tray_contract() -> Dictionary:
	var pending_count := _visible_hand_candidate_ids.size()
	var placed_count := maxi(0, _hand_candidate_ids.size() - pending_count)
	return {
		"count": _hand_candidate_ids.size(),
		"visible_count": _visible_hand_candidate_ids.size(),
		"pending_count": pending_count,
		"placed_count": placed_count,
		"capacity": HAND_CANDIDATE_LIMIT,
		"expanded": _hand_expanded,
		"auto_collapsed_for_space": _hand_auto_collapsed_for_space,
		"visible": _hand_panel != null and _hand_panel.visible,
		"slots": _hand_candidate_ids.duplicate(),
		"header_text": _hand_header_button.text if _hand_header_button != null else "",
		"rect": _hand_panel.get_global_rect() if _hand_panel != null and _hand_panel.is_inside_tree() else Rect2()
	}


func _on_search_changed(_value: String) -> void:
	if _suppress_search_signal:
		return
	_refresh_cards()


func _on_group_selected(index: int) -> void:
	_selected_group = str(_group_filter.get_item_metadata(index))
	_refresh_cards()


func _on_favorites_only_toggled(_value: bool) -> void:
	_refresh_cards()


func _on_featured_only_toggled(_value: bool) -> void:
	_refresh_cards()


func _rebuild_group_filter() -> void:
	if _group_filter == null:
		return
	var previous_group := _selected_group
	_group_filter.clear()
	_group_filter.add_item("全部分类")
	_group_filter.set_item_metadata(0, "")
	var seen := {}
	for character in _characters:
		var group := str(character.get("group", "")).strip_edges()
		if group.is_empty():
			group = "其他"
		if seen.has(group):
			continue
		seen[group] = true
		_group_filter.add_item(group)
		_group_filter.set_item_metadata(_group_filter.item_count - 1, group)
	_selected_group = ""
	for index in range(_group_filter.item_count):
		if str(_group_filter.get_item_metadata(index)) == previous_group:
			_group_filter.select(index)
			_selected_group = previous_group
			break


func _build_hand_tray() -> PanelContainer:
	_hand_panel = PanelContainer.new()
	_hand_panel.name = "HandCandidateTray"
	_hand_panel.visible = false
	_hand_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hand_panel.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_shell_panel(
			Color("#FBF5E5"),
			UiThemeScript.BORDER_BRASS_SOFT,
			1,
			6
		)
	)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 7)
	margin.add_theme_constant_override("margin_right", 7)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 7)
	_hand_panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 5)
	column.add_child(header)

	_hand_header_button = Button.new()
	_hand_header_button.name = "HandCandidateTrayToggle"
	_hand_header_button.text = "▼ 手边备选"
	_hand_header_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_hand_header_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hand_header_button.custom_minimum_size = Vector2(0, 30)
	_hand_header_button.tooltip_text = "收起或展开手边备选；这里只保留本次运行中的临时选择"
	_hand_header_button.pressed.connect(_toggle_hand_tray_expanded)
	header.add_child(_hand_header_button)

	_hand_clear_button = Button.new()
	_hand_clear_button.name = "ClearHandCandidatesButton"
	_hand_clear_button.text = "清空"
	_hand_clear_button.custom_minimum_size = Vector2(48, 30)
	_hand_clear_button.tooltip_text = "清空待摆名单；地图人物保持原样"
	_hand_clear_button.pressed.connect(clear_hand_candidates)
	header.add_child(_hand_clear_button)

	_hand_grid = GridContainer.new()
	_hand_grid.name = "HandCandidateGrid"
	_hand_grid.columns = 2
	_hand_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hand_grid.add_theme_constant_override("h_separation", 6)
	_hand_grid.add_theme_constant_override("v_separation", 5)
	column.add_child(_hand_grid)
	return _hand_panel


func _preserve_character_list_after_hand_change() -> void:
	# Container 需要一帧才能结算新增手边卡后的真实高度。只在“拿卡”导致
	# 人物目录不足一段可滚动视口时自动收起一次；玩家随后主动展开时尊重其选择。
	await get_tree().process_frame
	if not is_inside_tree() or not _hand_expanded or _hand_panel == null or not _hand_panel.visible:
		return
	if _scroll == null or _scroll.size.y >= BACKPACK_CHARACTER_SCROLL_MIN_VISIBLE_HEIGHT:
		return
	_hand_expanded = false
	_hand_auto_collapsed_for_space = true
	_refresh_hand_tray()


func _toggle_hand_tray_expanded() -> void:
	set_hand_tray_expanded(not _hand_expanded)


func _refresh_hand_tray() -> void:
	if _hand_panel == null or _hand_grid == null:
		return
	for child in _hand_grid.get_children():
		_hand_grid.remove_child(child)
		child.queue_free()
	_visible_hand_candidate_ids.clear()
	_hand_character_cards.clear()
	_hand_placed_buttons.clear()
	_hand_panel.visible = not _hand_candidate_ids.is_empty()
	if _hand_candidate_ids.is_empty():
		return

	for character_id in _hand_candidate_ids:
		var character := _character_for_id(character_id)
		if character.is_empty():
			continue
		var display_name := str(character.get("name", character_id))
		var group := str(character.get("group", "")).strip_edges()
		if group.is_empty():
			group = "其他"

		var slot := HBoxContainer.new()
		slot.name = "HandSlot_%s" % character_id
		slot.custom_minimum_size = Vector2(99, 36)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.add_theme_constant_override("separation", 3)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_hand_grid.add_child(slot)

		if _placed.has(character_id):
			var placed_button := Button.new()
			placed_button.name = "PlacedHandCandidate"
			placed_button.text = "%s 已摆" % display_name
			placed_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			placed_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			placed_button.custom_minimum_size = Vector2(0, 36)
			placed_button.add_theme_font_size_override("font_size", 14)
			var placed_normal := UiThemeScript.make_shell_panel(Color("#E9E5D2"), UiThemeScript.BORDER_SHELL, 1, 3)
			placed_normal.content_margin_left = 3
			placed_normal.content_margin_right = 3
			placed_normal.content_margin_top = 4
			placed_normal.content_margin_bottom = 4
			placed_button.add_theme_stylebox_override("normal", placed_normal)
			var placed_hover := placed_normal.duplicate() as StyleBoxFlat
			placed_hover.bg_color = Color("#F8EFD5")
			placed_hover.border_color = UiThemeScript.GOLD_FOCUS
			placed_button.add_theme_stylebox_override("hover", placed_hover)
			placed_button.add_theme_stylebox_override("pressed", placed_hover)
			var placed_focus := placed_normal.duplicate() as StyleBoxFlat
			placed_focus.border_color = UiThemeScript.GOLD_FOCUS
			placed_focus.set_border_width_all(2)
			placed_button.add_theme_stylebox_override("focus", placed_focus)
			placed_button.tooltip_text = "%s 已摆在地图；点击定位。撤销或收回后会重新成为待摆卡。" % display_name
			placed_button.pressed.connect(_request_placed_character_focus.bind(character_id))
			slot.add_child(placed_button)
			_hand_placed_buttons[character_id] = placed_button
		else:
			var card := CharacterCardScript.new()
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			card.setup(character_id, display_name, "backpack", _accent_for_group(group))
			card.set_backpack_compact(true)
			card.tooltip_text = "%s · 从手边拖到地图；右键查看人物卡" % display_name
			card.backpack_details_requested.connect(_request_hand_character_details)
			slot.add_child(card)
			_hand_character_cards[character_id] = card
			_visible_hand_candidate_ids.append(character_id)

		var remove_button := Button.new()
		remove_button.name = "RemoveHandCandidate"
		remove_button.text = "×"
		remove_button.custom_minimum_size = Vector2(20, 36)
		remove_button.focus_mode = Control.FOCUS_NONE
		remove_button.tooltip_text = "把%s移出待摆名单；地图人物保持原样" % display_name
		remove_button.pressed.connect(toggle_hand_candidate.bind(character_id))
		slot.add_child(remove_button)

	if _hand_header_button != null:
		var pending_count := _visible_hand_candidate_ids.size()
		var placed_count := maxi(0, _hand_candidate_ids.size() - pending_count)
		_hand_header_button.text = "%s 手边（待摆 %d）" % [
			"▼" if _hand_expanded else "▶",
			pending_count
		]
		_hand_header_button.tooltip_text = (
			"手边共 %d 人：%d 人待摆，%d 人已摆在地图。已摆人物可点击定位；收起只隐藏槽位。"
			% [_hand_candidate_ids.size(), pending_count, placed_count]
		)
		if _hand_auto_collapsed_for_space:
			_hand_header_button.tooltip_text += "\n当前窗口为人物列表保留空间，手边已自动收起；点击可展开查看。"
	_hand_grid.visible = _hand_expanded
	if _hand_clear_button != null:
		_hand_clear_button.visible = _hand_expanded


func _sanitize_hand_candidates() -> void:
	var valid: Array[String] = []
	for character_id in _hand_candidate_ids:
		if _has_character(character_id) and not valid.has(character_id):
			valid.append(character_id)
	_hand_candidate_ids = valid.slice(0, HAND_CANDIDATE_LIMIT)


func _character_for_id(character_id: String) -> Dictionary:
	for character in _characters:
		if str(character.get("id", "")) == character_id:
			return (character as Dictionary).duplicate(true)
	return {}


func _refresh_cards() -> void:
	if _cards_box == null:
		return
	var hand_focus_context := _capture_hand_focus_context()
	var favorite_focus_context := _capture_favorite_focus_context()
	_refresh_count += 1
	_scenario_outer_candidates_panel = null
	_scenario_outer_candidates_label = null
	for child in _cards_box.get_children():
		_cards_box.remove_child(child)
		child.queue_free()
	_visible_character_ids.clear()
	_visible_placed_character_ids.clear()
	_visible_profile_character_ids.clear()
	_favorite_buttons.clear()
	_character_cards.clear()
	_placed_focus_buttons.clear()
	_placed_details_buttons.clear()
	_hand_toggle_buttons.clear()
	_refresh_hand_tray()
	_update_scenario_focus_summary()
	_update_scenario_take_guidance()

	var query := _search_edit.text.strip_edges().to_lower() if _search_edit != null else ""
	var visible_count := 0
	var placed_visible_count := 0
	var available_count := 0
	var featured_active := _featured_filter_active()
	if not query.is_empty() or featured_active:
		for character in _characters:
			var placed_id := str(character.get("id", ""))
			if not _placed.has(placed_id) or not _character_matches_active_filters(character, query):
				continue
			if placed_visible_count == 0:
				_add_search_section_label(
					"本局重点 · 已在地图"
					if query.is_empty()
					else "已在地图 · 可看卡或定位"
				)
			_add_placed_search_result(character)
			_visible_placed_character_ids.append(placed_id)
			_visible_profile_character_ids.append(placed_id)
			placed_visible_count += 1
	var available_section_start := _cards_box.get_child_count()
	for character in _characters:
		var id := str(character.get("id", ""))
		if _placed.has(id):
			continue
		if _hand_candidate_ids.has(id):
			continue
		available_count += 1
		if not _character_matches_active_filters(character, query):
			continue
		var display_name := str(character.get("name", id))
		var group := str(character.get("group", "")).strip_edges()
		if group.is_empty():
			group = "其他"
		if visible_count == 0:
			if featured_active and query.is_empty():
				_add_search_section_label("本局重点 · 待摆人物")
			elif placed_visible_count > 0:
				_add_search_section_label("人物背包")

		var card_row := HBoxContainer.new()
		card_row.add_theme_constant_override("separation", 6)
		card_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# 行容器只负责排版；滚动后若它成为悬停目标，会截断子卡牌的原生
		# _get_drag_data 链。忽略行本身，姓名卡和收藏按钮仍各自接收输入。
		card_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cards_box.add_child(card_row)
		var card := CharacterCardScript.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.setup(id, display_name, "backpack", _accent_for_group(group))
		card.backpack_details_requested.connect(_request_character_details)
		card_row.add_child(card)
		_character_cards[id] = card

		var hand_button := Button.new()
		hand_button.name = "AddHandCandidate"
		hand_button.custom_minimum_size = Vector2(34, 54)
		hand_button.text = "拿"
		hand_button.tooltip_text = (
			"手边已满（%d/%d）" % [HAND_CANDIDATE_LIMIT, HAND_CANDIDATE_LIMIT]
			if _hand_candidate_ids.size() >= HAND_CANDIDATE_LIMIT
			else "拿到手边；之后可从上方托盘连续拖到地图"
		)
		hand_button.disabled = _hand_candidate_ids.size() >= HAND_CANDIDATE_LIMIT
		hand_button.focus_mode = Control.FOCUS_ALL
		hand_button.pressed.connect(take_hand_candidate_and_focus_next.bind(id))
		card_row.add_child(hand_button)
		_hand_toggle_buttons[id] = hand_button

		var favorite_button := Button.new()
		favorite_button.custom_minimum_size = Vector2(34, 54)
		favorite_button.text = "★" if _favorite_ids.has(id) else "☆"
		favorite_button.tooltip_text = "取消收藏" if _favorite_ids.has(id) else "收藏人物"
		favorite_button.focus_mode = Control.FOCUS_ALL
		favorite_button.add_theme_font_size_override("font_size", 19)
		favorite_button.add_theme_color_override("font_color", UiThemeScript.TEXT_ACCENT if _favorite_ids.has(id) else UiThemeScript.TEXT_HINT)
		favorite_button.pressed.connect(toggle_favorite.bind(id))
		card_row.add_child(favorite_button)
		_favorite_buttons[id] = favorite_button
		_visible_character_ids.append(id)
		_visible_profile_character_ids.append(id)
		visible_count += 1
	if featured_active and query.is_empty() and visible_count > 0:
		var pending_controls: Array[Node] = []
		for child_index in range(available_section_start, _cards_box.get_child_count()):
			pending_controls.append(_cards_box.get_child(child_index))
		for child_index in range(pending_controls.size()):
			_cards_box.move_child(pending_controls[child_index], child_index)
		_visible_profile_character_ids = _visible_character_ids.duplicate()
		_visible_profile_character_ids.append_array(_visible_placed_character_ids)

	if visible_count == 0 and placed_visible_count == 0:
		var empty := Label.new()
		empty.text = "当前筛选下没有可显示的人物"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
		empty.custom_minimum_size = Vector2(0, 70)
		_cards_box.add_child(empty)
	_add_scenario_outer_candidates_summary(featured_active)

	if _count_label != null:
		var filters_active := not query.is_empty() \
			or not _selected_group.is_empty() \
			or (_favorites_only != null and _favorites_only.button_pressed) \
			or featured_active
		if featured_active:
			_count_label.text = "%d 人" % (placed_visible_count + visible_count)
		elif not query.is_empty() and placed_visible_count > 0:
			_count_label.text = "%d 图上 · %d 背包" % [placed_visible_count, visible_count]
		else:
			_count_label.text = "%d / %d" % [visible_count if filters_active else available_count, available_count if filters_active else _characters.size()]
		_count_label.tooltip_text = "图上匹配 %d / 当前背包显示 %d / 背包可用 %d / 总人数 %d" % [placed_visible_count, visible_count, available_count, _characters.size()]
	call_deferred("_update_scroll_navigation")
	if not hand_focus_context.is_empty():
		call_deferred("_restore_hand_focus_after_refresh", hand_focus_context)
	elif not favorite_focus_context.is_empty():
		call_deferred("_restore_favorite_focus_after_refresh", favorite_focus_context)


func _scenario_focus_counts() -> Dictionary:
	var placed_total := 0
	var featured_placed := 0
	var featured_pending := 0
	var other_available := 0
	for character in _characters:
		var character_id := str(character.get("id", ""))
		if character_id.is_empty():
			continue
		if _placed.has(character_id):
			placed_total += 1
			if _featured_character_ids.has(character_id):
				featured_placed += 1
		elif _featured_character_ids.has(character_id):
			featured_pending += 1
		else:
			other_available += 1
	return {
		"placed_total": placed_total,
		"featured_total": _featured_character_ids.size(),
		"featured_placed": featured_placed,
		"featured_pending": featured_pending,
		"other_available": other_available,
	}


func _update_scenario_focus_summary() -> void:
	if _scenario_focus_summary == null:
		return
	var has_focus := not _featured_character_ids.is_empty()
	_scenario_focus_summary.visible = has_focus
	if not has_focus:
		_scenario_focus_summary.text = ""
		_scenario_focus_summary.tooltip_text = ""
		return
	var counts := _scenario_focus_counts()
	var scenario_label := _featured_scenario_label if not _featured_scenario_label.is_empty() else "历史开局"
	var featured_pending := int(counts.get("featured_pending", 0))
	var focus_state := "重点待摆 %d" % featured_pending if featured_pending > 0 else "重点已齐"
	_scenario_focus_summary.text = "%s · 地图 %d · %s · 其余未上图 %d" % [
		scenario_label,
		int(counts.get("placed_total", 0)),
		focus_state,
		int(counts.get("other_available", 0)),
	]
	_scenario_focus_summary.tooltip_text = "待摆人物排在最前；取消上方筛选可查看其余未上图人物。"


func _scenario_take_pending_ids() -> Array[String]:
	var result: Array[String] = []
	for character_id in _scenario_take_ids:
		if not _placed.has(character_id) and not _hand_candidate_ids.has(character_id):
			result.append(character_id)
	return result


func _scenario_take_names(ids: Array[String], limit := 3) -> String:
	var names: Array[String] = []
	for character_id in ids:
		var character := _character_for_id(character_id)
		var display_name := str(character.get("name", character_id))
		if display_name not in names:
			names.append(display_name)
	if names.is_empty():
		return ""
	var visible_names := names.slice(0, maxi(1, limit))
	var result := "、".join(visible_names)
	if names.size() > visible_names.size():
		result += "等%d人" % names.size()
	return result


func _add_scenario_outer_candidates_summary(featured_active: bool) -> void:
	if _cards_box == null or _scenario_conditional_ids.is_empty():
		return
	var names := _scenario_take_names(_scenario_conditional_ids, _scenario_conditional_ids.size())
	if names.is_empty():
		return

	_scenario_outer_candidates_panel = PanelContainer.new()
	_scenario_outer_candidates_panel.name = "ScenarioOuterCandidatesSummary"
	_scenario_outer_candidates_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scenario_outer_candidates_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scenario_outer_candidates_panel.add_theme_stylebox_override(
		"panel",
		UiThemeScript.make_shell_panel(UiThemeScript.INK_LIST_HOVER, UiThemeScript.BORDER_BRASS_SOFT, 1, 4)
	)
	_cards_box.add_child(_scenario_outer_candidates_panel)
	# 摘要属于列表内容而非固定 HUD；始终放在滚动内容首位，避免八人手边
	# 展开时继续挤压人物列表的固定视口。
	_cards_box.move_child(_scenario_outer_candidates_panel, 0)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	_scenario_outer_candidates_panel.add_child(margin)

	_scenario_outer_candidates_label = Label.new()
	_scenario_outer_candidates_label.name = "ScenarioOuterCandidatesLabel"
	_scenario_outer_candidates_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scenario_outer_candidates_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scenario_outer_candidates_label.add_theme_font_size_override("font_size", 12)
	_scenario_outer_candidates_label.add_theme_color_override("font_color", UiThemeScript.TEXT_SUMMARY)
	_scenario_outer_candidates_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var access_hint := (
		"取消“本局重点”后，从完整目录逐张拿取。"
		if featured_active
		else "可从下方完整目录逐张拿取。"
	)
	_scenario_outer_candidates_label.text = "同期开局外围可选（%d 人，不随“拿补位”进入手边）：%s；%s" % [
		_scenario_conditional_ids.size(),
		names,
		access_hint,
	]
	margin.add_child(_scenario_outer_candidates_label)


func _update_scenario_take_guidance() -> void:
	if _scenario_guidance_row == null or _scenario_guidance_label == null or _scenario_take_button == null:
		return
	var has_guidance := not _scenario_take_ids.is_empty()
	_scenario_guidance_row.visible = has_guidance
	if not has_guidance:
		_scenario_guidance_label.text = ""
		_scenario_take_button.disabled = true
		_scenario_take_button.tooltip_text = "当前开局没有预设补位人物"
		return
	var pending_ids := _scenario_take_pending_ids()
	var hand_full := _hand_candidate_ids.size() >= HAND_CANDIDATE_LIMIT
	var label := _scenario_take_label if not _scenario_take_label.is_empty() else "本局补位"
	if pending_ids.is_empty():
		_scenario_guidance_label.text = "%s · 已在手边或地图上" % label
		_scenario_take_button.text = "已拿完"
		_scenario_take_button.disabled = true
		_scenario_take_button.tooltip_text = "这组补位人物已经在手边或地图上"
		return
	if hand_full:
		_scenario_guidance_label.text = "%s · 还可拿 %d 人 · 手边已满 %d/%d" % [label, pending_ids.size(), HAND_CANDIDATE_LIMIT, HAND_CANDIDATE_LIMIT]
		_scenario_take_button.text = "手边已满"
		_scenario_take_button.disabled = true
		_scenario_take_button.tooltip_text = "先把手边人物拖到地图，或移出一位，再拿这组补位人物"
		return
	var pending_names := _scenario_take_names(pending_ids)
	_scenario_guidance_label.text = "%s · 可拿 %d 人 · 先放手边，再拖到地图" % [label, pending_ids.size()]
	_scenario_take_button.text = "拿补位"
	_scenario_take_button.disabled = false
	var tooltip := _scenario_take_hint
	if not pending_names.is_empty():
		tooltip += "\n待拿：%s" % pending_names
	if not _scenario_conditional_ids.is_empty():
		var conditional_names := _scenario_take_names(
			_scenario_conditional_ids,
			_scenario_conditional_ids.size()
		)
		if not conditional_names.is_empty():
			tooltip += "\n同期开局外围可选：%s" % conditional_names
			tooltip += "\n按需从完整目录逐张拿取；不会随本按钮进入手边。"
	_scenario_take_button.tooltip_text = tooltip


func _add_search_section_label(text_value: String) -> void:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cards_box.add_child(label)


func _add_placed_search_result(character: Dictionary) -> void:
	var character_id := str(character.get("id", ""))
	var display_name := str(character.get("name", character_id))
	var group := str(character.get("group", "")).strip_edges()
	if group.is_empty():
		group = "其他"
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 52)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#EEE9D7")
	style.border_color = UiThemeScript.BORDER_SHELL
	style.set_border_width_all(1)
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	panel.add_theme_stylebox_override("panel", style)
	_cards_box.add_child(panel)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 9)
	margin.add_theme_constant_override("margin_right", 7)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 6)
	margin.add_child(row)
	var marker := ColorRect.new()
	marker.color = _accent_for_group(group)
	marker.custom_minimum_size = Vector2(5, 0)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(marker)
	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.mouse_filter = Control.MOUSE_FILTER_IGNORE
	labels.add_theme_constant_override("separation", 0)
	row.add_child(labels)
	var name_label := Label.new()
	name_label.text = display_name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", UiThemeScript.TEXT_PRIMARY)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	labels.add_child(name_label)
	var state_label := Label.new()
	state_label.text = "已在地图"
	state_label.tooltip_text = "人物仍可在地图上继续移动"
	state_label.add_theme_font_size_override("font_size", 11)
	state_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	labels.add_child(state_label)
	var details_button := Button.new()
	details_button.text = "人物卡"
	details_button.custom_minimum_size = Vector2(50, 34)
	details_button.tooltip_text = "查看%s人物卡；可继续浏览当前筛选结果" % display_name
	details_button.focus_mode = Control.FOCUS_ALL
	details_button.pressed.connect(_request_character_details.bind(character_id))
	row.add_child(details_button)
	_placed_details_buttons[character_id] = details_button
	var focus_button := Button.new()
	focus_button.text = "定位"
	focus_button.custom_minimum_size = Vector2(46, 34)
	focus_button.tooltip_text = "保持当前缩放，把%s移到地图中央并选中" % display_name
	focus_button.focus_mode = Control.FOCUS_ALL
	focus_button.pressed.connect(_request_placed_character_focus.bind(character_id))
	row.add_child(focus_button)
	_placed_focus_buttons[character_id] = focus_button


func _request_placed_character_focus(character_id: String) -> void:
	if _placed.has(character_id):
		placed_character_focus_requested.emit(character_id)


func _request_character_details(character_id: String) -> void:
	if _has_character(character_id) and _visible_profile_character_ids.has(character_id):
		character_details_requested.emit(character_id, _visible_profile_character_ids.duplicate())


func _request_hand_character_details(character_id: String) -> void:
	if _has_character(character_id) and _visible_hand_candidate_ids.has(character_id):
		character_details_requested.emit(character_id, _visible_hand_candidate_ids.duplicate())


func _character_matches_active_filters(character: Dictionary, query: String) -> bool:
	if not query.is_empty() and not _character_matches_query(character, query):
		return false
	if _featured_filter_active() and not _featured_character_ids.has(str(character.get("id", ""))):
		return false
	var group := str(character.get("group", "")).strip_edges()
	if group.is_empty():
		group = "其他"
	if not _selected_group.is_empty() and group != _selected_group:
		return false
	if _favorites_only != null and _favorites_only.button_pressed and not _favorite_ids.has(str(character.get("id", ""))):
		return false
	return true


func _featured_filter_active() -> bool:
	return _featured_only != null \
		and _featured_only.visible \
		and _featured_only.button_pressed \
		and not _featured_character_ids.is_empty()


func _has_character(character_id: String) -> bool:
	for character in _characters:
		if str(character.get("id", "")) == character_id:
			return true
	return false


func _character_matches_query(character: Dictionary, query: String) -> bool:
	if str(character.get("name", "")).to_lower().find(query) != -1:
		return true
	var aliases = character.get("aliases", [])
	if not (aliases is Array):
		return false
	for alias in aliases:
		if alias is String and str(alias).to_lower().find(query) != -1:
			return true
	return false


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


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("kind", "") == "character_card" and data.get("source", "") == "map"


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	character_returned.emit(str(data.get("character_id", "")))
