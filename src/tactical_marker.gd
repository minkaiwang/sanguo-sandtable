class_name TacticalMarker
extends PanelContainer

const DRAG_START_DISTANCE_SCREEN := 5.0
const COMPACT_SIZE := Vector2(92, 29)
const EXPANDED_SIZE := Vector2(142, 34)
const AFFILIATED_COMPACT_SIZE := Vector2(164, 29)
const AFFILIATED_EXPANDED_SIZE := Vector2(214, 34)

signal marker_drag_started(marker_id: String, grab_local: Vector2)
signal marker_drag_ended(marker_id: String, global_position: Vector2)
signal marker_selected(marker_id: String)
signal edit_requested(marker_id: String)
signal delete_requested(marker_id: String)

var marker_id := ""
var label_text := ""
var marker_type := "note"
var faction_id := ""
var faction_name := ""
var faction_color := Color.TRANSPARENT
var _press_pending := false
var _manual_dragging := false
var _press_viewport_position := Vector2.ZERO
var _press_local_position := Vector2.ZERO
var _label: Label
var _type_badge: Label
var _pin: ColorRect
var _edit_button: Button
var _delete_button: Button
var _panel_style: StyleBoxFlat
var _hovered := false
var _selected := false
var _actions_visible := false
var _presentation_revision := 0


func setup(id_value: String, label_value: String, marker_type_value: String = "note") -> void:
	marker_id = id_value
	label_text = label_value
	marker_type = _normalized_marker_type(marker_type_value)
	name = "TacticalMarker_%s" % marker_id
	custom_minimum_size = EXPANDED_SIZE
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	mouse_entered.connect(set_hovered.bind(true))
	mouse_exited.connect(set_hovered.bind(false))
	_update_tooltip()

	_panel_style = StyleBoxFlat.new()
	_panel_style.set_border_width_all(1)
	_panel_style.corner_radius_top_left = 6
	_panel_style.corner_radius_top_right = 6
	_panel_style.corner_radius_bottom_left = 6
	_panel_style.corner_radius_bottom_right = 6
	_panel_style.shadow_color = Color(0, 0, 0, 0.32)
	_panel_style.shadow_size = 3
	add_theme_stylebox_override("panel", _panel_style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 7)
	margin.add_theme_constant_override("margin_right", 3)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_bottom", 3)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_child(row)

	_pin = ColorRect.new()
	_pin.custom_minimum_size = Vector2(5, 0)
	_pin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_pin)

	_type_badge = Label.new()
	_type_badge.custom_minimum_size = Vector2(16, 0)
	_type_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_type_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_type_badge.add_theme_font_size_override("font_size", 12)
	_type_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_type_badge)

	_label = Label.new()
	_label.text = _display_label()
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_label.clip_text = true
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color("f1dfb7"))
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_label)

	_edit_button = Button.new()
	_edit_button.name = "EditButton"
	_edit_button.text = "改"
	_edit_button.flat = true
	_edit_button.focus_mode = Control.FOCUS_NONE
	_edit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_edit_button.visible = false
	_edit_button.custom_minimum_size = Vector2(28, 26)
	_edit_button.tooltip_text = "修改标记类型或文字"
	_edit_button.add_theme_font_size_override("font_size", 12)
	_edit_button.add_theme_color_override("font_color", Color("c8c2a9"))
	_edit_button.pressed.connect(func(): edit_requested.emit(marker_id))
	row.add_child(_edit_button)

	_delete_button = Button.new()
	_delete_button.name = "DeleteButton"
	_delete_button.text = "×"
	_delete_button.flat = true
	_delete_button.focus_mode = Control.FOCUS_NONE
	_delete_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_delete_button.visible = false
	_delete_button.custom_minimum_size = Vector2(24, 26)
	_delete_button.tooltip_text = "删除标记（可撤销）"
	_delete_button.add_theme_font_size_override("font_size", 16)
	_delete_button.add_theme_color_override("font_color", Color("cf8376"))
	_delete_button.pressed.connect(func(): delete_requested.emit(marker_id))
	row.add_child(_delete_button)
	_apply_marker_type_presentation()
	_refresh_presentation(false)


func set_label_text(value: String) -> void:
	label_text = value
	if _label != null:
		_label.text = _display_label()
	_refresh_presentation(false)
	_update_tooltip()


func set_marker_type(value: String) -> void:
	var normalized := _normalized_marker_type(value)
	if marker_type == normalized:
		return
	marker_type = normalized
	_apply_marker_type_presentation()
	_update_tooltip()


func set_faction_affiliation(id_value: String, name_value: String, color_value: Color) -> void:
	var normalized_id := id_value.strip_edges()
	var normalized_name := name_value.strip_edges()
	if normalized_id.is_empty() or normalized_name.is_empty():
		normalized_id = ""
		normalized_name = ""
		color_value = Color.TRANSPARENT
	if faction_id == normalized_id and faction_name == normalized_name and faction_color.is_equal_approx(color_value):
		return
	faction_id = normalized_id
	faction_name = normalized_name
	faction_color = color_value
	if _label != null:
		_label.text = _display_label()
	_apply_marker_type_presentation()
	_refresh_presentation(false)
	_update_tooltip()


func set_selected(value: bool) -> void:
	if _selected == value:
		return
	_selected = value
	_refresh_presentation()


func set_hovered(value: bool) -> void:
	if _hovered == value:
		return
	_hovered = value
	_refresh_presentation()


func get_presentation_state() -> Dictionary:
	return {
		"hovered": _hovered,
		"selected": _selected,
		"dragging": _manual_dragging,
		"actions_visible": _actions_visible,
		"size": size,
		"marker_type": marker_type,
		"badge": _type_badge.text if _type_badge != null else "",
		"faction_id": faction_id,
		"faction_name": faction_name,
		"display_label": _display_label()
	}


func _update_tooltip() -> void:
	var boundary := "玩家战术便签"
	if marker_type == "player_place":
		boundary = "玩家自定地点"
	elif marker_type == "player_event":
		boundary = "玩家自定事件"
	var affiliation := "所属势力：%s" % faction_name if not faction_name.is_empty() else "所属势力：未指定"
	tooltip_text = "%s\n%s\n%s\n拖动调整位置；悬停或轻点显示修改与删除" % [
		boundary,
		label_text,
		affiliation
	]


func _display_label() -> String:
	if not faction_name.is_empty():
		return "%s｜%s" % [faction_name, label_text]
	if _needs_affiliation_context():
		return "未指定｜%s" % label_text
	return label_text


func _needs_affiliation_context() -> bool:
	return label_text.strip_edges().contains("援军")


func _normalized_marker_type(value: String) -> String:
	return value if value in ["note", "player_place", "player_event"] else "note"


func _apply_marker_type_presentation() -> void:
	if _panel_style == null or _pin == null or _type_badge == null or _label == null:
		return
	match marker_type:
		"player_place":
			_panel_style.bg_color = Color(0.075, 0.15, 0.13, 0.95)
			_panel_style.border_color = Color("579979")
			_pin.color = Color("69b58e")
			_type_badge.text = "地"
			_type_badge.visible = true
			_type_badge.add_theme_color_override("font_color", Color("9dd4b5"))
			_label.add_theme_color_override("font_color", Color("dcebdd"))
		"player_event":
			_panel_style.bg_color = Color(0.16, 0.09, 0.085, 0.95)
			_panel_style.border_color = Color("bd6b5c")
			_pin.color = Color("d47865")
			_type_badge.text = "事"
			_type_badge.visible = true
			_type_badge.add_theme_color_override("font_color", Color("e8a28f"))
			_label.add_theme_color_override("font_color", Color("f0d9c8"))
		_:
			_panel_style.bg_color = Color(0.10, 0.13, 0.11, 0.94)
			_panel_style.border_color = Color("c99b36")
			_pin.color = Color("d9a93a")
			_type_badge.text = ""
			_type_badge.visible = false
			_type_badge.add_theme_color_override("font_color", Color("d9a93a"))
			_label.add_theme_color_override("font_color", Color("f1dfb7"))
	if not faction_name.is_empty():
		_panel_style.border_color = faction_color
		_pin.color = faction_color


func _refresh_presentation(preserve_center := true) -> void:
	if _edit_button == null or _delete_button == null:
		return
	var should_show_actions := _hovered or _selected or _manual_dragging or _press_pending
	var needs_affiliation_space := not faction_name.is_empty() or _needs_affiliation_context()
	var compact_size := AFFILIATED_COMPACT_SIZE if needs_affiliation_space else COMPACT_SIZE
	var expanded_size := AFFILIATED_EXPANDED_SIZE if needs_affiliation_space else EXPANDED_SIZE
	var target_size := expanded_size if should_show_actions else compact_size
	if _actions_visible == should_show_actions and size.is_equal_approx(target_size):
		return
	var old_size := size
	var old_center := position + old_size * scale * 0.5
	_actions_visible = should_show_actions
	_edit_button.visible = should_show_actions
	_delete_button.visible = should_show_actions
	custom_minimum_size = target_size
	_apply_presentation_size(target_size, preserve_center, old_center, old_size)
	_presentation_revision += 1
	call_deferred("_finish_presentation_resize", _presentation_revision, target_size)


func _apply_presentation_size(target_size: Vector2, preserve_center: bool, old_center: Vector2, old_size: Vector2) -> void:
	size = target_size
	if (_press_pending or _manual_dragging) and not old_size.is_equal_approx(size):
		_press_local_position += (size - old_size) * 0.5
	if preserve_center and is_inside_tree():
		position = old_center - size * scale * 0.5


func _finish_presentation_resize(revision: int, target_size: Vector2) -> void:
	if revision != _presentation_revision or size.is_equal_approx(target_size):
		return
	var old_size := size
	var old_center := position + old_size * scale * 0.5
	_apply_presentation_size(target_size, true, old_center, old_size)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_press_pending = true
		_press_viewport_position = get_viewport().get_mouse_position()
		_press_local_position = event.position
		_refresh_presentation()
		set_process_input(true)
		accept_event()


func _input(event: InputEvent) -> void:
	if not _manual_dragging and not _press_pending:
		return
	if event is InputEventMouseMotion and _press_pending:
		if event.position.distance_to(_press_viewport_position) >= DRAG_START_DISTANCE_SCREEN:
			_press_pending = false
			_manual_dragging = true
			_refresh_presentation()
			modulate = Color(1, 1, 1, 0.9)
			marker_drag_started.emit(marker_id, _press_local_position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var was_dragging := _manual_dragging
		_press_pending = false
		_manual_dragging = false
		set_process_input(false)
		modulate = Color.WHITE
		if was_dragging:
			marker_drag_ended.emit(marker_id, get_viewport().get_mouse_position())
		else:
			marker_selected.emit(marker_id)
		_refresh_presentation()
		get_viewport().set_input_as_handled()
