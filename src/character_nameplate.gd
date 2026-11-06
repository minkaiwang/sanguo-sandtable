class_name CharacterNameplate
extends PanelContainer

## 运行界面统一使用的人物名牌。
##
## 小尺寸用于地图与开局预览，只显示姓名首字；大尺寸显示完整竖排姓名。
## 名牌完全由 Control 绘制，不依赖逐人图片资产。

const NameplateFont := preload("res://assets/fonts/Source_Han_Serif.otf")
const DEFAULT_ACCENT := Color("8d6534")
const BACKGROUND := Color("f4e6bf")
const TEXT_COLOR := Color("3f2c17")

var _display_name := ""
var _compact := true
var _target_size := Vector2(32, 32)
var _accent := DEFAULT_ACCENT
var _panel_style: StyleBoxFlat
var _accent_bar: ColorRect
var _name_label: Label
var _content: HBoxContainer


func _init() -> void:
	name = "CharacterNameplate"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true

	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = BACKGROUND
	_panel_style.border_color = _accent.darkened(0.12)
	_panel_style.set_border_width_all(1)
	_panel_style.corner_radius_top_left = 4
	_panel_style.corner_radius_top_right = 4
	_panel_style.corner_radius_bottom_left = 4
	_panel_style.corner_radius_bottom_right = 4
	add_theme_stylebox_override("panel", _panel_style)

	var margin := MarginContainer.new()
	margin.name = "NameplateMargin"
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 2)
	margin.add_theme_constant_override("margin_right", 2)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	add_child(margin)

	_content = HBoxContainer.new()
	_content.name = "NameplateContent"
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_theme_constant_override("separation", 2)
	margin.add_child(_content)

	_accent_bar = ColorRect.new()
	_accent_bar.name = "NameplateAccent"
	_accent_bar.color = _accent
	_accent_bar.custom_minimum_size = Vector2(3, 0)
	_accent_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(_accent_bar)

	_name_label = Label.new()
	_name_label.name = "NameplateText"
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_override("font", NameplateFont)
	_name_label.add_theme_color_override("font_color", TEXT_COLOR)
	_name_label.add_theme_constant_override("line_spacing", -4)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(_name_label)
	_refresh()


func configure(
	display_name: String,
	accent: Color = DEFAULT_ACCENT,
	target_size: Vector2 = Vector2(32, 32),
	compact := true
) -> void:
	_display_name = display_name.strip_edges()
	_accent = accent
	_target_size = target_size
	_compact = compact
	_refresh()


func set_display_name(value: String) -> void:
	var normalized := value.strip_edges()
	if _display_name == normalized:
		return
	_display_name = normalized
	_refresh()


func set_accent(value: Color) -> void:
	if _accent.is_equal_approx(value):
		return
	_accent = value
	_refresh()


func get_nameplate_contract() -> Dictionary:
	return {
		"presentation_mode": "nameplate",
		"full_name": _display_name,
		"display_text": _name_label.text if _name_label != null else "",
		"compact": _compact,
		"target_size": _target_size,
		"font_size": _font_size_for_name(),
		"accent": _accent,
		"uses_raster_asset": false,
	}


func _refresh() -> void:
	if _panel_style == null or _accent_bar == null or _name_label == null:
		return
	custom_minimum_size = _target_size
	size = _target_size
	_panel_style.border_color = _accent.darkened(0.12)
	_accent_bar.color = _accent
	_accent_bar.custom_minimum_size = Vector2(3 if _compact else 5, 0)
	_name_label.text = _compact_name() if _compact else _vertical_name()
	_name_label.tooltip_text = _display_name
	_name_label.add_theme_font_size_override("font_size", _font_size_for_name())
	tooltip_text = _display_name
	queue_redraw()


func _compact_name() -> String:
	return _display_name.left(1) if not _display_name.is_empty() else "人"


func _vertical_name() -> String:
	if _display_name.is_empty():
		return "人"
	var characters: PackedStringArray = []
	for index in range(_display_name.length()):
		characters.append(_display_name.substr(index, 1))
	return "\n".join(characters)


func _font_size_for_name() -> int:
	if _compact:
		return 17 if _target_size.x <= 32.0 else 19
	var length := maxi(1, _display_name.length())
	if length <= 2:
		return 34
	if length == 3:
		return 27
	return 22
