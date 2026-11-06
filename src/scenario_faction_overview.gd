class_name ScenarioFactionOverview
extends PanelContainer

signal faction_selected(record: Dictionary)
signal faction_selection_cleared

const UiThemeScript = preload("res://src/ui_theme.gd")

const GRID_VIEWPORT_HEIGHT := 190.0
const GRID_VISIBLE_BUTTON_COUNT := 6

var _records: Array[Dictionary] = []
var _buttons_by_id: Dictionary = {}
var _selected_faction_id := ""
var _scroll: ScrollContainer
var _grid: GridContainer
var _empty_label: Label
var _hint_label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(440.0, 126.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	var panel_style := UiThemeScript.make_shell_panel(
		Color("#F8F0DA"),
		UiThemeScript.BORDER_BRASS_SOFT,
		1,
		4
	)
	panel_style.content_margin_left = 10.0
	panel_style.content_margin_top = 8.0
	panel_style.content_margin_right = 10.0
	panel_style.content_margin_bottom = 8.0
	add_theme_stylebox_override("panel", panel_style)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	add_child(column)

	var heading_row := HBoxContainer.new()
	heading_row.add_theme_constant_override("separation", 8)
	column.add_child(heading_row)
	var title := Label.new()
	title.text = "开局势力"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	heading_row.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_row.add_child(spacer)
	_hint_label = Label.new()
	_hint_label.name = "FactionOverviewHint"
	_hint_label.text = "选择一方，预览城池与人物落点"
	_hint_label.add_theme_font_size_override("font_size", 12)
	_hint_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	heading_row.add_child(_hint_label)

	_scroll = ScrollContainer.new()
	_scroll.name = "FactionOverviewScroll"
	_scroll.custom_minimum_size = Vector2(0.0, GRID_VIEWPORT_HEIGHT)
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.follow_focus = true
	column.add_child(_scroll)

	_grid = GridContainer.new()
	_grid.name = "FactionOverviewGrid"
	_grid.columns = 2
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 5)
	_scroll.add_child(_grid)

	_empty_label = Label.new()
	_empty_label.text = "空白沙盘 · 从人物背包自由摆放"
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	_empty_label.custom_minimum_size = Vector2(0.0, 44.0)
	column.add_child(_empty_label)
	_rebuild_rows()
	call_deferred("_style_scrollbars")


func set_records(records: Array[Dictionary], empty_text := "空白沙盘 · 从人物背包自由摆放") -> void:
	_records.clear()
	for record in records:
		_records.append(record.duplicate(true))
	if _empty_label != null:
		_empty_label.text = empty_text
	_selected_faction_id = ""
	_rebuild_rows()
	call_deferred("_style_scrollbars")


func clear_selection(emit_change := true) -> void:
	_selected_faction_id = ""
	for button_value in _buttons_by_id.values():
		var button: Button = button_value
		button.set_pressed_no_signal(false)
	if emit_change:
		faction_selection_cleared.emit()


func select_faction(faction_id: String, emit_change := true) -> bool:
	if not _buttons_by_id.has(faction_id):
		return false
	_selected_faction_id = faction_id
	for id_value in _buttons_by_id:
		var button: Button = _buttons_by_id[id_value]
		button.set_pressed_no_signal(str(id_value) == faction_id)
	if _scroll != null:
		var selected_button := _buttons_by_id[faction_id] as Control
		_scroll.call_deferred("ensure_control_visible", selected_button)
	if emit_change:
		var record := get_record(faction_id)
		if not record.is_empty():
			faction_selected.emit(record)
	return true


func get_record(faction_id: String) -> Dictionary:
	for record in _records:
		if str(record.get("id", "")) == faction_id:
			return record.duplicate(true)
	return {}


func get_display_state() -> Dictionary:
	return {
		"record_count": _records.size(),
		"selected_faction_id": _selected_faction_id,
		"button_count": _buttons_by_id.size(),
		"columns": _grid.columns if _grid != null else 0,
		"empty_visible": _empty_label.visible if _empty_label != null else false,
		"scroll_visible": _scroll.visible if _scroll != null else false,
		"scroll_value": _scroll.scroll_vertical if _scroll != null else 0,
		"scroll_max": _scroll.get_v_scroll_bar().max_value if _scroll != null else 0.0,
		"scroll_page": _scroll.get_v_scroll_bar().page if _scroll != null else 0.0,
		"content_height": _grid.size.y if _grid != null else 0.0,
		"hint_text": _hint_label.text if _hint_label != null else "",
	}


func get_first_button() -> Button:
	if _records.is_empty():
		return null
	return _buttons_by_id.get(str(_records[0].get("id", ""))) as Button


func get_scroll_container() -> ScrollContainer:
	return _scroll


func _style_scrollbars() -> void:
	if _scroll == null or not is_instance_valid(_scroll):
		return
	UiThemeScript.style_accessible_scrollbars_in(self)


func _rebuild_rows() -> void:
	if _grid == null:
		return
	for child in _grid.get_children():
		child.queue_free()
	_buttons_by_id.clear()
	if _scroll != null:
		_scroll.visible = not _records.is_empty()
		_scroll.scroll_vertical = 0
	if _empty_label != null:
		_empty_label.visible = _records.is_empty()
	for record in _records:
		var faction_id := str(record.get("id", ""))
		if faction_id.is_empty():
			continue
		var color := Color(str(record.get("color", "#8B8068")))
		var button := Button.new()
		button.name = "Faction_%s" % faction_id
		button.text = "%s\n人物 %d · 城池 %d" % [
			str(record.get("name", faction_id)),
			int(record.get("character_count", 0)),
			int(record.get("city_count", 0)),
		]
		button.tooltip_text = "%s：%d 位预摆人物，%d 座归属城池" % [
			str(record.get("name", faction_id)),
			int(record.get("character_count", 0)),
			int(record.get("city_count", 0)),
		]
		button.icon = _make_color_swatch(color)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.custom_minimum_size = Vector2(210.0, 46.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.toggled.connect(_on_faction_toggled.bind(faction_id))
		_grid.add_child(button)
		_buttons_by_id[faction_id] = button
	_update_hint()
	call_deferred("_style_scrollbars")


func _update_hint() -> void:
	if _hint_label == null:
		return
	if _records.size() > GRID_VISIBLE_BUTTON_COUNT:
		_hint_label.text = "共 %d 方 · 向下滚动预览" % _records.size()
		return
	_hint_label.text = "选择一方，预览城池与人物落点"


func _on_faction_toggled(pressed: bool, faction_id: String) -> void:
	if not pressed:
		if _selected_faction_id == faction_id:
			clear_selection(true)
		return
	select_faction(faction_id, true)


func _make_color_swatch(color: Color) -> ImageTexture:
	var image := Image.create(14, 14, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.22, 0.19, 0.13, 1.0))
	for y in range(2, 12):
		for x in range(2, 12):
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)
