class_name CityFactionWindow
extends Control


const WindowFont := preload("res://assets/fonts/Source_Han_Serif.otf")

signal collapsed_changed(group_key: String, collapsed: bool)
signal rename_requested(group_key: String)

var group_key := ""
var place_name := ""
var faction_name := ""
var member_count := 0
var collapsed := false
var auto_compact := false
var accent := Color("8f7a52")
var action_summary: Dictionary = {}
var faction_marker := ""

var _background: Panel
var _toggle_button: Button
var _accent_strip: ColorRect


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background = Panel.new()
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

	_accent_strip = ColorRect.new()
	_accent_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_accent_strip)

	_toggle_button = Button.new()
	_toggle_button.name = "FactionToggle"
	_toggle_button.focus_mode = Control.FOCUS_ALL
	_toggle_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_toggle_button.add_theme_font_override("font", WindowFont)
	_toggle_button.add_theme_font_size_override("font_size", 13)
	_toggle_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_toggle_button.pressed.connect(_toggle_collapsed)
	_toggle_button.gui_input.connect(_on_toggle_gui_input)
	add_child(_toggle_button)


func setup(
	group_key_value: String,
	place_name_value: String,
	faction_name_value: String,
	member_count_value: int,
	collapsed_value: bool,
	accent_value: Color,
	natural_size: Vector2,
	auto_compact_value := false,
	action_summary_value: Dictionary = {},
	faction_marker_value := ""
) -> void:
	group_key = group_key_value
	place_name = place_name_value
	faction_name = faction_name_value
	member_count = maxi(1, member_count_value)
	collapsed = collapsed_value
	auto_compact = auto_compact_value
	accent = accent_value
	action_summary = action_summary_value.duplicate(true)
	faction_marker = faction_marker_value.strip_edges()
	name = "CityFaction_%s" % group_key.replace("::", "_")
	custom_minimum_size = natural_size
	size = natural_size
	_background.position = Vector2.ZERO
	_background.size = natural_size
	_accent_strip.position = Vector2(4, 5)
	_accent_strip.size = Vector2(6, 22)
	_accent_strip.color = accent
	_toggle_button.position = Vector2(12, 4)
	_toggle_button.size = Vector2(maxf(1.0, natural_size.x - 16.0), 24.0)
	_toggle_button.custom_minimum_size = _toggle_button.size
	_toggle_button.disabled = auto_compact
	_apply_style()
	_refresh_text()


func get_toggle_button() -> Button:
	return _toggle_button


func _apply_style() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.97, 0.94, 0.85, 0.96)
	panel_style.border_color = accent
	panel_style.set_border_width_all(1)
	panel_style.corner_radius_top_left = 7
	panel_style.corner_radius_top_right = 7
	panel_style.corner_radius_bottom_left = 7
	panel_style.corner_radius_bottom_right = 7
	panel_style.shadow_color = Color(0.16, 0.12, 0.06, 0.20)
	panel_style.shadow_size = 3
	_background.add_theme_stylebox_override("panel", panel_style)

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color("#F7F0DC")
	normal_style.border_color = Color(0.58, 0.61, 0.53, 0.92)
	normal_style.set_border_width_all(1)
	normal_style.corner_radius_top_left = 5
	normal_style.corner_radius_top_right = 5
	normal_style.corner_radius_bottom_left = 5
	normal_style.corner_radius_bottom_right = 5
	_toggle_button.add_theme_stylebox_override("normal", normal_style)
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = Color("#FFF5D8")
	hover_style.border_color = accent
	_toggle_button.add_theme_stylebox_override("hover", hover_style)
	var pressed_style := normal_style.duplicate()
	pressed_style.bg_color = Color("#E6D8B2")
	pressed_style.border_color = accent.darkened(0.12)
	_toggle_button.add_theme_stylebox_override("pressed", pressed_style)
	_toggle_button.add_theme_color_override("font_color", Color("#30291D"))
	_toggle_button.add_theme_color_override("font_hover_color", Color("#21180B"))
	_toggle_button.add_theme_color_override("font_pressed_color", Color("#21180B"))


func _refresh_text() -> void:
	var short_action := str(action_summary.get("short", "待"))
	var action_suffix := " · %s" % short_action if collapsed or auto_compact else ""
	var identity_prefix := "%s·" % faction_marker if not faction_marker.is_empty() else ""
	_toggle_button.text = "%s %s%s · %d%s" % ["▸" if collapsed else "▾", identity_prefix, faction_name, member_count, action_suffix]
	_toggle_button.tooltip_text = "%s · %s%s · %d 人\n%s\n%s" % [
		place_name,
		"势力编号 %s · " % faction_marker if not faction_marker.is_empty() else "",
		faction_name,
		member_count,
		str(action_summary.get("detail", "行动：待命 %d｜进攻 0｜防御 0｜支援 0｜谋划 0" % member_count)),
		"全图视角自动收起；放大地图后可展开人物"
		if auto_compact
		else ("%s；右键重命名本局势力" % ("点击展开人物" if collapsed else "点击收起，只显示势力"))
	]


func _toggle_collapsed() -> void:
	collapsed_changed.emit(group_key, not collapsed)


func _on_toggle_gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null or mouse_event.button_index != MOUSE_BUTTON_RIGHT or not mouse_event.pressed:
		return
	rename_requested.emit(group_key)
	get_viewport().set_input_as_handled()
