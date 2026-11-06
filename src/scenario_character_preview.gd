class_name ScenarioCharacterPreview
extends PanelContainer


signal character_profile_requested(character_id: String)


const UiThemeScript = preload("res://src/ui_theme.gd")
const CharacterNameplateScript = preload("res://src/character_nameplate.gd")

const TILE_WIDTH := 56.0
const TILE_HEIGHT := 52.0
const NAMEPLATE_SIZE := 30.0

var _records: Array[Dictionary] = []
var _tiles_by_id: Dictionary = {}
var _ordered_ids: Array[String] = []
var _summary_label: Label
var _scroll: ScrollContainer
var _row: HBoxContainer
var _empty_label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, 94.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	var panel_style := UiThemeScript.make_shell_panel(
		Color("#F8F0DA"),
		UiThemeScript.BORDER_BRASS_SOFT,
		1,
		4
	)
	panel_style.content_margin_left = 10.0
	panel_style.content_margin_top = 7.0
	panel_style.content_margin_right = 10.0
	panel_style.content_margin_bottom = 7.0
	add_theme_stylebox_override("panel", panel_style)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	add_child(column)

	var heading_row := HBoxContainer.new()
	heading_row.add_theme_constant_override("separation", 8)
	column.add_child(heading_row)
	var title := Label.new()
	title.text = "重点人物 · 可查看人物卡"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UiThemeScript.TEXT_PANEL_TITLE)
	heading_row.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_row.add_child(spacer)
	_summary_label = Label.new()
	_summary_label.add_theme_font_size_override("font_size", 12)
	_summary_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	heading_row.add_child(_summary_label)

	_scroll = ScrollContainer.new()
	_scroll.name = "CharacterPreviewScroll"
	_scroll.custom_minimum_size = Vector2(0.0, 54.0)
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.focus_mode = Control.FOCUS_NONE
	_scroll.follow_focus = true
	column.add_child(_scroll)
	_row = HBoxContainer.new()
	_row.name = "CharacterPreviewRow"
	_row.add_theme_constant_override("separation", 4)
	_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_row)

	_empty_label = Label.new()
	_empty_label.custom_minimum_size = Vector2(0.0, 54.0)
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty_label.add_theme_color_override("font_color", UiThemeScript.TEXT_HINT)
	column.add_child(_empty_label)
	_rebuild()
	call_deferred("_style_scrollbars")


func set_records(records: Array[Dictionary], empty_text := "未设置重点人物") -> void:
	_records.clear()
	for record in records:
		_records.append(record.duplicate(false))
	if _empty_label != null:
		_empty_label.text = empty_text
	_rebuild()
	call_deferred("_style_scrollbars")


func clear(empty_text := "未设置重点人物") -> void:
	set_records([], empty_text)


func get_display_state() -> Dictionary:
	var preplaced_count := 0
	var pending_count := 0
	var ids: Array[String] = []
	for record in _records:
		var character_id := str(record.get("id", ""))
		if not character_id.is_empty():
			ids.append(character_id)
		if str(record.get("state", "pending")) == "preplaced":
			preplaced_count += 1
		else:
			pending_count += 1
	return {
		"record_count": _records.size(),
		"tile_count": _tiles_by_id.size(),
		"preplaced_count": preplaced_count,
		"pending_count": pending_count,
		"ids": ids,
		"empty_visible": _empty_label.visible if _empty_label != null else false,
		"scroll_visible": _scroll.visible if _scroll != null else false,
		"scroll_value": _scroll.scroll_horizontal if _scroll != null else 0,
		"scroll_max": _scroll.get_h_scroll_bar().max_value if _scroll != null else 0.0,
		"scroll_page": _scroll.get_h_scroll_bar().page if _scroll != null else 0.0,
		"content_width": _row.size.x if _row != null else 0.0,
		"presentation_mode": "nameplate",
	}


func get_tile(character_id: String) -> Control:
	return _tiles_by_id.get(character_id) as Control


func get_scroll_container() -> ScrollContainer:
	return _scroll


func _style_scrollbars() -> void:
	if _scroll == null or not is_instance_valid(_scroll):
		return
	UiThemeScript.style_accessible_scrollbars_in(self)


func get_focused_character_id() -> String:
	for character_id in _ordered_ids:
		var tile := _tiles_by_id.get(character_id) as Control
		if tile != null and tile.has_focus():
			return character_id
	return ""


func focus_character(character_id: String) -> bool:
	var tile := _tiles_by_id.get(character_id) as Control
	if tile == null:
		return false
	_set_roving_focus(character_id)
	tile.grab_focus()
	call_deferred("_ensure_tile_visible", character_id)
	return true


func _rebuild() -> void:
	if _row == null:
		return
	for child in _row.get_children():
		child.queue_free()
	_tiles_by_id.clear()
	_ordered_ids.clear()
	var preplaced_count := 0
	for record in _records:
		var character_id := str(record.get("id", ""))
		if character_id.is_empty() or _tiles_by_id.has(character_id):
			continue
		var state := str(record.get("state", "pending"))
		if state == "preplaced":
			preplaced_count += 1
		var tile := _build_tile(record, state)
		_row.add_child(tile)
		_tiles_by_id[character_id] = tile
		_ordered_ids.append(character_id)
		if _ordered_ids.size() == 1:
			tile.focus_mode = Control.FOCUS_ALL
	var pending_count := maxi(0, _tiles_by_id.size() - preplaced_count)
	if _summary_label != null:
		_summary_label.text = (
			"图上 %d · 待摆 %d" % [preplaced_count, pending_count]
			if not _tiles_by_id.is_empty()
			else "图上 0 · 待摆 0"
		)
	if _scroll != null:
		_scroll.visible = not _tiles_by_id.is_empty()
		_scroll.scroll_horizontal = 0
	if _empty_label != null:
		_empty_label.visible = _tiles_by_id.is_empty()
	call_deferred("_style_scrollbars")


func _build_tile(record: Dictionary, state: String) -> PanelContainer:
	var character_id := str(record.get("id", ""))
	var character_name := str(record.get("name", character_id))
	var is_preplaced := state == "preplaced"
	var state_label := "图" if is_preplaced else "待"
	var state_text := "已在地图预摆" if is_preplaced else "待从人物背包摆放"
	var accent := Color("#4F8069") if is_preplaced else Color("#B47C1D")

	var tile := PanelContainer.new()
	tile.name = "Character_%s" % character_id
	tile.custom_minimum_size = Vector2(TILE_WIDTH, TILE_HEIGHT)
	tile.focus_mode = Control.FOCUS_CLICK
	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tile.tooltip_text = "%s · %s" % [character_name, state_text]
	tile.set_meta("character_id", character_id)
	tile.set_meta("accent", accent)
	tile.set_meta("hovered", false)
	tile.gui_input.connect(_on_tile_gui_input.bind(character_id, tile))
	tile.focus_entered.connect(_on_tile_focus_entered.bind(character_id, tile))
	tile.focus_exited.connect(_on_tile_focus_exited.bind(tile))
	tile.mouse_entered.connect(_on_tile_mouse_entered.bind(tile))
	tile.mouse_exited.connect(_on_tile_mouse_exited.bind(tile))
	_apply_tile_visual(tile)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 1)
	tile.add_child(column)
	var nameplate_row := HBoxContainer.new()
	nameplate_row.name = "CharacterNameplateRow"
	nameplate_row.alignment = BoxContainer.ALIGNMENT_CENTER
	nameplate_row.add_theme_constant_override("separation", 2)
	column.add_child(nameplate_row)

	var nameplate := CharacterNameplateScript.new() as PanelContainer
	nameplate.name = "PreviewCharacterNameplate"
	nameplate.call(
		"configure",
		character_name,
		accent,
		Vector2(NAMEPLATE_SIZE, NAMEPLATE_SIZE),
		true
	)
	nameplate_row.add_child(nameplate)

	var badge := Label.new()
	badge.custom_minimum_size = Vector2(18.0, 18.0)
	badge.text = state_label
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 12)
	badge.add_theme_color_override("font_color", Color("#FFF9E9"))
	var badge_style := UiThemeScript.make_shell_panel(accent, accent.darkened(0.18), 1, 3)
	badge.add_theme_stylebox_override("normal", badge_style)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nameplate_row.add_child(badge)

	var name_label := Label.new()
	name_label.custom_minimum_size = Vector2(TILE_WIDTH - 6.0, 15.0)
	name_label.text = character_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", UiThemeScript.TEXT_BODY)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(name_label)
	return tile


func _on_tile_gui_input(event: InputEvent, character_id: String, tile: Control) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event != null:
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_set_roving_focus(character_id)
			tile.grab_focus()
			character_profile_requested.emit(character_id)
			tile.accept_event()
		return
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	if key_event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
		character_profile_requested.emit(character_id)
		tile.accept_event()
		return
	if key_event.keycode == KEY_LEFT:
		_move_tile_focus(character_id, -1)
		tile.accept_event()
	elif key_event.keycode == KEY_RIGHT:
		_move_tile_focus(character_id, 1)
		tile.accept_event()


func _on_tile_focus_entered(character_id: String, tile: Control) -> void:
	_set_roving_focus(character_id)
	_apply_tile_visual(tile)
	call_deferred("_ensure_tile_visible", character_id)


func _on_tile_focus_exited(tile: Control) -> void:
	_apply_tile_visual(tile)


func _on_tile_mouse_entered(tile: Control) -> void:
	tile.set_meta("hovered", true)
	_apply_tile_visual(tile)


func _on_tile_mouse_exited(tile: Control) -> void:
	tile.set_meta("hovered", false)
	_apply_tile_visual(tile)


func _set_roving_focus(character_id: String) -> void:
	for id_value in _ordered_ids:
		var tile := _tiles_by_id.get(id_value) as Control
		if tile != null:
			tile.focus_mode = Control.FOCUS_ALL if id_value == character_id else Control.FOCUS_CLICK


func _move_tile_focus(character_id: String, offset: int) -> void:
	var index := _ordered_ids.find(character_id)
	var next_index := index + offset
	if index < 0 or next_index < 0 or next_index >= _ordered_ids.size():
		return
	focus_character(_ordered_ids[next_index])


func _ensure_tile_visible(character_id: String) -> void:
	var tile := _tiles_by_id.get(character_id) as Control
	if tile != null and _scroll != null and tile.is_inside_tree():
		_scroll.ensure_control_visible(tile)


func _apply_tile_visual(tile: Control) -> void:
	if tile == null or not is_instance_valid(tile):
		return
	var accent: Color = tile.get_meta("accent", Color("#8B8068"))
	var highlighted := tile.has_focus() or bool(tile.get_meta("hovered", false))
	var tile_style := UiThemeScript.make_shell_panel(
		Color("#FFFDF4") if highlighted else Color("#FFF9E9"),
		accent.darkened(0.18) if highlighted else accent,
		2 if highlighted else 1,
		3
	)
	tile_style.content_margin_left = 3.0
	tile_style.content_margin_top = 2.0
	tile_style.content_margin_right = 3.0
	tile_style.content_margin_bottom = 2.0
	tile.add_theme_stylebox_override("panel", tile_style)
