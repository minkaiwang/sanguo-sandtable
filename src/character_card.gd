class_name CharacterCard
extends PanelContainer

const CardFont := preload("res://assets/fonts/Source_Han_Serif.otf")
const CharacterNameplateScript := preload("res://src/character_nameplate.gd")
const CharacterActionPolicyScript := preload("res://src/character_action_policy.gd")
const DRAG_START_DISTANCE_SCREEN := 5.0
const MAP_CARD_SIZE := Vector2(136, 46)
const MAP_OVERVIEW_SIZE := Vector2(82, 28)
const BACKPACK_DRAG_PREVIEW_SIZE := MAP_CARD_SIZE
const DEFAULT_TROOP_COUNT := 1000
const MIN_TROOP_COUNT := 0
const MAX_TROOP_COUNT := 999999

signal map_drag_started(character_id: String, grab_local: Vector2)
signal map_drag_ended(character_id: String, global_position: Vector2)
signal map_selected(character_id: String, additive: bool)
signal map_hover_changed(character_id: String, hovered: bool)
signal map_context_requested(character_id: String, viewport_position: Vector2)
signal backpack_details_requested(character_id: String)

var character_id := ""
var character_name := ""
var source := "backpack"
var accent := Color("8d6534")
var selected := false
var stack_count := 1
var stack_expanded := false
var stack_is_top := false
var stack_force_hidden := false
var stack_place_name := ""
var city_faction_name := ""
var runtime_attributes: Dictionary = {}
var action_state := "standby"
var troop_count := DEFAULT_TROOP_COUNT
var portrait_texture: Texture2D
var selection_count := 0
var hovered := false
var _manual_dragging := false
var _press_pending := false
var _press_viewport_position := Vector2.ZERO
var _press_local_position := Vector2.ZERO
var _panel_style: StyleBoxFlat
var _accent_marker: ColorRect
var _backpack_drag_request_count := 0
var _action_label: Label
var _troop_label: Label
var _map_nameplate: PanelContainer
var _map_compact_detail := false
var _map_detail_row: HBoxContainer
var _map_overview_row: HBoxContainer
var _map_overview_label: Label
var _content_margin: MarginContainer
var _content_row: HBoxContainer
var _backpack_name_label: Label
var _backpack_hint_label: Label


func setup(
	id_value: String,
	name_value: String,
	source_value: String,
	accent_value: Color,
	portrait_value: Texture2D = null
) -> void:
	character_id = id_value
	character_name = name_value
	source = source_value
	accent = accent_value
	portrait_texture = portrait_value
	name = "Card_%s" % character_id
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	_update_tooltip()

	if source == "map":
		custom_minimum_size = MAP_CARD_SIZE
		size = custom_minimum_size
		set_process_input(false)
		mouse_entered.connect(set_hovered.bind(true))
		mouse_exited.connect(set_hovered.bind(false))
	else:
		custom_minimum_size = Vector2(0, 54)

	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = Color("f4e7c5") if source == "map" else Color("#F2ECD9")
	_panel_style.border_color = accent if source == "map" else Color("#A1A892")
	_panel_style.set_border_width_all(1)
	_panel_style.corner_radius_top_left = 6
	_panel_style.corner_radius_top_right = 6
	_panel_style.corner_radius_bottom_left = 6
	_panel_style.corner_radius_bottom_right = 6
	_panel_style.shadow_color = Color(0, 0, 0, 0.24)
	_panel_style.shadow_size = 2 if source == "map" else 1
	add_theme_stylebox_override("panel", _panel_style)

	var margin := MarginContainer.new()
	_content_margin = margin
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 5 if source == "map" else 10)
	margin.add_theme_constant_override("margin_right", 5 if source == "map" else 10)
	margin.add_theme_constant_override("margin_top", 3 if source == "map" else 7)
	margin.add_theme_constant_override("margin_bottom", 3 if source == "map" else 7)
	add_child(margin)

	var row := HBoxContainer.new()
	_content_row = row
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 4 if source == "map" else 9)
	margin.add_child(row)
	if source == "map":
		_map_detail_row = row

	_accent_marker = ColorRect.new()
	_accent_marker.color = accent
	_accent_marker.custom_minimum_size = Vector2(4 if source == "map" else 6, 0)
	_accent_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_accent_marker)

	if source == "map":
		_build_map_nameplate(row)
		# Full name is the primary identity; the legacy initial tile is redundant.
		_map_nameplate.visible = false

		var identity_column := VBoxContainer.new()
		identity_column.name = "IdentityAndTroops"
		identity_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		identity_column.add_theme_constant_override("separation", -3)
		identity_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(identity_column)

		var label := Label.new()
		label.name = "CharacterName"
		label.text = character_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", CardFont)
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color("241a0f"))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		identity_column.add_child(label)

		_troop_label = Label.new()
		_troop_label.name = "TroopCount"
		_troop_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_troop_label.add_theme_font_override("font", CardFont)
		_troop_label.add_theme_font_size_override("font_size", 11)
		_troop_label.add_theme_color_override("font_color", Color("664923"))
		_troop_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		identity_column.add_child(_troop_label)
		_refresh_troop_presentation()

		_action_label = Label.new()
		_action_label.name = "ActionStateBadge"
		_action_label.custom_minimum_size = Vector2(18, 18)
		_action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_action_label.add_theme_font_override("font", CardFont)
		_action_label.add_theme_font_size_override("font_size", 11)
		_action_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(_action_label)
		_refresh_action_presentation()
		_build_map_overview_row(margin)
	else:
		var label := Label.new()
		_backpack_name_label = label
		label.text = character_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", CardFont)
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color("#29251C"))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(label)
		var hint := Label.new()
		_backpack_hint_label = hint
		# 卡牌内只保留短标签，右键操作由背包副标题和 tooltip 说明；
		# 这样三字人物名在窄栏中仍能给滚动条留出明确间隙。
		hint.text = "小传"
		hint.add_theme_font_size_override("font_size", 12)
		hint.add_theme_color_override("font_color", Color("#6C7065"))
		hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(hint)


func set_backpack_compact(value: bool) -> bool:
	if source != "backpack" or _content_margin == null or _content_row == null:
		return false
	custom_minimum_size = Vector2(76, 36) if value else Vector2(0, 54)
	_content_margin.add_theme_constant_override("margin_left", 6 if value else 10)
	_content_margin.add_theme_constant_override("margin_right", 6 if value else 10)
	_content_margin.add_theme_constant_override("margin_top", 4 if value else 7)
	_content_margin.add_theme_constant_override("margin_bottom", 4 if value else 7)
	_content_row.add_theme_constant_override("separation", 5 if value else 9)
	if _accent_marker != null:
		_accent_marker.custom_minimum_size = Vector2(4 if value else 6, 0)
	if _backpack_name_label != null:
		_backpack_name_label.add_theme_font_size_override("font_size", 14 if value else 17)
		_backpack_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS if value else TextServer.OVERRUN_NO_TRIMMING
	if _backpack_hint_label != null:
		_backpack_hint_label.visible = not value
	_update_tooltip()
	return true


func _build_map_overview_row(parent: MarginContainer) -> void:
	_map_overview_row = HBoxContainer.new()
	_map_overview_row.name = "OverviewForceRow"
	_map_overview_row.visible = false
	_map_overview_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_overview_row.add_theme_constant_override("separation", 4)
	parent.add_child(_map_overview_row)

	var overview_accent := ColorRect.new()
	overview_accent.name = "OverviewAccent"
	overview_accent.color = accent
	overview_accent.custom_minimum_size = Vector2(5, 0)
	overview_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_overview_row.add_child(overview_accent)

	_map_overview_label = Label.new()
	_map_overview_label.name = "OverviewIdentity"
	_map_overview_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map_overview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_map_overview_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_map_overview_label.add_theme_font_override("font", CardFont)
	_map_overview_label.add_theme_font_size_override("font_size", 12)
	_map_overview_label.add_theme_color_override("font_color", Color("2b2114"))
	_map_overview_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_overview_row.add_child(_map_overview_label)
	_refresh_overview_presentation()


func _build_map_nameplate(parent: HBoxContainer) -> void:
	_map_nameplate = CharacterNameplateScript.new()
	_map_nameplate.name = "MapCharacterNameplate"
	_map_nameplate.call("configure", character_name, accent, Vector2(32, 32), true)
	parent.add_child(_map_nameplate)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if source == "map":
		return null
	_backpack_drag_request_count += 1
	var data := build_backpack_drag_data()
	set_drag_preview(_build_backpack_drag_preview())
	modulate = Color(1, 1, 1, 0.35)
	return data


func build_backpack_drag_data() -> Dictionary:
	return {
		"kind": "character_card",
		"character_id": character_id,
		"character_name": character_name,
		"source": source,
		"preview_size": BACKPACK_DRAG_PREVIEW_SIZE,
		"preview_anchor": "center"
	}


func _build_backpack_drag_preview() -> Control:
	# Godot 会把拖拽预览根节点的原点放到鼠标位置；用零尺寸根节点和
	# 负半尺寸子节点，保证鼠标、预览中心与最终自由落点严格重合。
	var preview_root := Control.new()
	preview_root.name = "BackpackDragPreviewRoot"
	preview_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_root.custom_minimum_size = Vector2.ZERO
	preview_root.size = Vector2.ZERO

	var preview := PanelContainer.new()
	preview.name = "BackpackDragPreviewPanel"
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.custom_minimum_size = BACKPACK_DRAG_PREVIEW_SIZE
	preview.size = BACKPACK_DRAG_PREVIEW_SIZE
	preview.position = -BACKPACK_DRAG_PREVIEW_SIZE * 0.5
	var preview_style := StyleBoxFlat.new()
	preview_style.bg_color = Color("fff2ce")
	preview_style.border_color = accent
	preview_style.set_border_width_all(2)
	preview_style.corner_radius_top_left = 8
	preview_style.corner_radius_top_right = 8
	preview_style.corner_radius_bottom_left = 8
	preview_style.corner_radius_bottom_right = 8
	preview_style.shadow_color = Color(0, 0, 0, 0.35)
	preview_style.shadow_size = 6
	preview.add_theme_stylebox_override("panel", preview_style)

	var preview_label := Label.new()
	preview_label.text = "  %s  " % character_name
	preview_label.name = "CharacterName"
	preview_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview_label.add_theme_font_override("font", CardFont)
	preview_label.add_theme_font_size_override("font_size", 15)
	preview_label.add_theme_color_override("font_color", Color("2c2418"))
	preview.add_child(preview_label)
	preview_root.add_child(preview)
	return preview_root


func get_backpack_drag_preview_contract() -> Dictionary:
	return {
		"size": BACKPACK_DRAG_PREVIEW_SIZE,
		"offset": -BACKPACK_DRAG_PREVIEW_SIZE * 0.5,
		"pointer_to_center_error": Vector2.ZERO,
		"map_card_size": MAP_CARD_SIZE,
		"font_path": CardFont.resource_path,
		"anchor": "center"
	}


func get_backpack_drag_request_count() -> int:
	return _backpack_drag_request_count


func _gui_input(event: InputEvent) -> void:
	if source == "backpack":
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			backpack_details_requested.emit(character_id)
			accept_event()
		return
	if source != "map":
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_press_pending = false
			_manual_dragging = false
			set_process_input(false)
			modulate = Color.WHITE
			map_context_requested.emit(character_id, get_viewport().get_mouse_position())
			accept_event()
			return
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			map_selected.emit(character_id, event.shift_pressed)
			_press_pending = true
			_press_viewport_position = get_viewport().get_mouse_position()
			_press_local_position = event.position
			set_process_input(true)
			accept_event()


func set_selected(value: bool) -> void:
	if source != "map" or selected == value:
		return
	selected = value
	_refresh_map_attention_style()
	_update_tooltip()
	queue_redraw()


func set_hovered(value: bool) -> void:
	if source != "map" or hovered == value:
		return
	hovered = value
	_refresh_map_attention_style()
	map_hover_changed.emit(character_id, hovered)
	queue_redraw()


func is_hovered() -> bool:
	return hovered


func _refresh_map_attention_style() -> void:
	if source != "map" or _panel_style == null:
		return
	if selected:
		_panel_style.bg_color = Color("fff0c9")
		_panel_style.border_color = Color("e0b850")
		_panel_style.set_border_width_all(2)
		_panel_style.shadow_color = Color(0.10, 0.07, 0.02, 0.44 if hovered else 0.38)
		_panel_style.shadow_size = 6 if hovered else 5
	elif hovered:
		_panel_style.bg_color = Color("fff6dd")
		_panel_style.border_color = accent.lightened(0.16)
		_panel_style.set_border_width_all(2)
		_panel_style.shadow_color = Color(0.10, 0.07, 0.02, 0.34)
		_panel_style.shadow_size = 4
	else:
		_panel_style.bg_color = Color("f4e7c5")
		_panel_style.border_color = accent
		_panel_style.set_border_width_all(1)
		_panel_style.shadow_color = Color(0, 0, 0, 0.24)
		_panel_style.shadow_size = 2
	add_theme_stylebox_override("panel", _panel_style)


func set_selection_context(value: int) -> void:
	var normalized := maxi(0, value)
	if selection_count == normalized:
		return
	selection_count = normalized
	_update_tooltip()


func set_accent(value: Color) -> void:
	if accent.is_equal_approx(value):
		return
	accent = value
	if _accent_marker != null:
		_accent_marker.color = accent
	if _map_overview_row != null:
		var overview_accent := _map_overview_row.get_node_or_null("OverviewAccent") as ColorRect
		if overview_accent != null:
			overview_accent.color = accent
	if _map_nameplate != null:
		_map_nameplate.call("set_accent", accent)
	if source == "map" and _panel_style != null:
		_refresh_map_attention_style()
	_update_tooltip()
	queue_redraw()


func get_accent() -> Color:
	return accent


func set_stack_state(count: int, expanded: bool, is_top: bool, place_name: String = "", force_hidden := false) -> void:
	stack_count = maxi(1, count)
	stack_expanded = expanded
	stack_is_top = is_top
	stack_force_hidden = force_hidden
	stack_place_name = place_name
	visible = not stack_force_hidden and (stack_count <= 1 or stack_expanded or stack_is_top)
	_update_tooltip()
	queue_redraw()


func set_city_faction_context(value: String) -> void:
	if city_faction_name == value:
		return
	city_faction_name = value
	_update_tooltip()


func set_runtime_attributes(value: Dictionary) -> bool:
	if source != "map":
		return false
	var next_attributes := value.duplicate(true)
	if runtime_attributes == next_attributes:
		return false
	runtime_attributes = next_attributes
	_update_tooltip()
	return false


func set_map_compact_detail(value: bool) -> bool:
	if source != "map" or _map_compact_detail == value:
		return false
	_map_compact_detail = value
	if _map_detail_row != null:
		_map_detail_row.visible = not value
	if _map_overview_row != null:
		_map_overview_row.visible = value
	var target_size := MAP_OVERVIEW_SIZE if value else MAP_CARD_SIZE
	custom_minimum_size = target_size
	size = target_size
	_refresh_overview_presentation()
	_update_tooltip()
	return true


func is_map_compact_detail() -> bool:
	return _map_compact_detail


func get_runtime_attributes() -> Dictionary:
	return runtime_attributes.duplicate(true)


func set_troop_count(value: int) -> void:
	var normalized := clampi(value, MIN_TROOP_COUNT, MAX_TROOP_COUNT)
	if troop_count == normalized and _troop_label != null:
		return
	troop_count = normalized
	_refresh_troop_presentation()
	_update_tooltip()


func get_troop_count() -> int:
	return troop_count


func set_portrait_texture(value: Texture2D) -> void:
	if portrait_texture == value:
		return
	portrait_texture = value


func has_portrait_texture() -> bool:
	return portrait_texture != null


func get_map_marker_contract() -> Dictionary:
	var nameplate_contract: Dictionary = (
		_map_nameplate.call("get_nameplate_contract") as Dictionary
		if _map_nameplate != null
		else {}
	)
	return {
		"size": MAP_CARD_SIZE,
		"overview_size": MAP_OVERVIEW_SIZE,
		"overview_active": _map_compact_detail,
		"overview_display": _map_overview_label.text if _map_overview_label != null else "",
		"presentation_mode": "nameplate",
		"nameplate_size": nameplate_contract.get("target_size", Vector2.ZERO),
		"nameplate_display": str(nameplate_contract.get("display_text", "")),
		"initial_tile_visible": _map_nameplate != null and _map_nameplate.visible,
		"nameplate_uses_raster_asset": bool(nameplate_contract.get("uses_raster_asset", true)),
		"portrait_size": Vector2.ZERO,
		"portrait_available": false,
		"portrait_visible": false,
		"portrait_fallback": "",
		"legacy_portrait_asset_available": has_portrait_texture(),
		"name": character_name,
		"troop_count": troop_count,
		"troop_display": _format_compact_troop_count(troop_count),
		"action": action_state,
		"shows_four_dimensions": false,
		"screen_constant_after_zoom": 1.75
	}


func _refresh_troop_presentation() -> void:
	if _troop_label != null:
		_troop_label.text = "兵 %s" % _format_compact_troop_count(troop_count)
	_refresh_overview_presentation()


func _refresh_overview_presentation() -> void:
	if _map_overview_label == null:
		return
	_map_overview_label.text = "%s · %s" % [
		character_name,
		_format_overview_troop_count(troop_count)
	]


func _format_overview_troop_count(value: int) -> String:
	var normalized := clampi(value, MIN_TROOP_COUNT, MAX_TROOP_COUNT)
	if normalized < 1000:
		return str(normalized)
	if normalized < 10000 and normalized % 1000 == 0:
		return "%d千" % (normalized / 1000)
	return _format_compact_troop_count(normalized)


func _format_compact_troop_count(value: int) -> String:
	var normalized := clampi(value, MIN_TROOP_COUNT, MAX_TROOP_COUNT)
	if normalized < 10000:
		return _format_integer_with_separators(normalized)
	var unit_text := "%.1f" % (float(normalized) / 10000.0)
	if unit_text.ends_with(".0"):
		unit_text = unit_text.left(-2)
	return "%s万" % unit_text


func _format_integer_with_separators(value: int) -> String:
	var digits := str(maxi(0, value))
	var grouped := ""
	for index in range(digits.length()):
		if index > 0 and (digits.length() - index) % 3 == 0:
			grouped += ","
		grouped += digits[index]
	return grouped


func set_action_state(value: String) -> void:
	if source != "map":
		return
	var normalized := CharacterActionPolicyScript.normalize(value)
	if action_state == normalized and _action_label != null:
		return
	action_state = normalized
	_refresh_action_presentation()
	_update_tooltip()
	queue_redraw()


func get_action_state() -> String:
	return action_state


func _refresh_action_presentation() -> void:
	if _action_label == null:
		return
	var badge_text := CharacterActionPolicyScript.short_label(action_state)
	var badge_color := CharacterActionPolicyScript.color(action_state)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = badge_color
	badge_style.border_color = badge_color.lightened(0.22)
	badge_style.set_border_width_all(1)
	badge_style.corner_radius_top_left = 4
	badge_style.corner_radius_top_right = 4
	badge_style.corner_radius_bottom_left = 4
	badge_style.corner_radius_bottom_right = 4
	_action_label.text = badge_text
	_action_label.add_theme_color_override("font_color", Color("fff7df"))
	_action_label.add_theme_stylebox_override("normal", badge_style)


func _action_label_text() -> String:
	return CharacterActionPolicyScript.label(action_state)


func _update_tooltip() -> void:
	var lines := PackedStringArray([character_name])
	if source == "map":
		if selected and selection_count > 1:
			lines.append("已加入临时多选（共 %d 人）；拖动可整组移动" % selection_count)
		elif selected:
			lines.append("已选中；按 Shift 点击其他人物可临时多选")
		else:
			lines.append("轻点选中；按 Shift 点击可增删多选")
		lines.append("右键打开人物操作")
		lines.append("当前兵力：%s（玩家设定）" % _format_integer_with_separators(troop_count))
		lines.append("当前行动：%s（玩家标注）" % _action_label_text())
		if not city_faction_name.is_empty():
			lines.append("本局势力：%s" % city_faction_name)
		if stack_count > 1:
			lines.append("%s共 %d 人；%s" % [stack_place_name if not stack_place_name.is_empty() else "同城", stack_count, "已展开" if stack_expanded else "轻点展开"])
	else:
		lines.append("左键拖动摆到地图")
		lines.append("右键查看人物小传")
	tooltip_text = "\n".join(lines)


func _draw() -> void:
	if source != "map" or stack_count <= 1 or not stack_is_top:
		return
	var badge_center := Vector2(size.x - 5.0, 6.0)
	var badge_text := "×%d" % stack_count
	var badge_font_size := 10
	var badge_text_size := CardFont.get_string_size(badge_text, HORIZONTAL_ALIGNMENT_LEFT, -1, badge_font_size)
	draw_circle(badge_center, 10.0, Color(0.08, 0.07, 0.04, 0.94))
	draw_circle(badge_center, 9.0, Color("d8b85b"), false, 1.5, true)
	draw_string(CardFont, badge_center + Vector2(-badge_text_size.x * 0.5, 3.5), badge_text, HORIZONTAL_ALIGNMENT_LEFT, -1, badge_font_size, Color("f7e9b7"))


func _input(event: InputEvent) -> void:
	if not _manual_dragging and not _press_pending:
		return
	if event is InputEventMouseMotion and _press_pending:
		if event.position.distance_to(_press_viewport_position) >= DRAG_START_DISTANCE_SCREEN:
			_press_pending = false
			_manual_dragging = true
			modulate = Color(1.0, 1.0, 1.0, 0.88)
			map_drag_started.emit(character_id, _press_local_position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var was_dragging := _manual_dragging
		_press_pending = false
		_manual_dragging = false
		set_process_input(false)
		modulate = Color.WHITE
		if was_dragging:
			map_drag_ended.emit(character_id, get_viewport().get_mouse_position())
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate = Color.WHITE
		if is_inside_tree():
			get_tree().call_group("native_drag_feedback_targets", "clear_native_drag_feedback")
