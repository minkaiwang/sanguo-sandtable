extends RefCounted

## 三国推演志的代码式视觉令牌与样式工厂。
##
## M2-D27 起统一采用“白昼浅绢”令牌。每个工厂都返回新的 StyleBoxFlat，
## 避免人物卡、按钮或面板在运行时修改样式时互相污染。

const FONT := preload("res://assets/fonts/Source_Han_Serif.otf")
const WINDOW_CLOSE_ICON := preload("res://assets/ui/icons/project/close_ink_v1.svg")

const BACKGROUND_APP := Color("#D8D7C2")
const INK_SHELL := Color("#F4ECD6")
const INK_BOARD := Color("#E6E0C8")
const INK_RECORD_BASE := Color("#FBF5E5")
const INK_DIALOG := Color("#FBF5E5")
const INK_LIST := Color("#FFF9E9")
const INK_LIST_SELECTED := Color("#E6D5A8")
const INK_LIST_HOVER := Color("#F2E6C8")

const TEXT_PRIMARY := Color("#29251C")
const TEXT_BUTTON := Color("#332E23")
const TEXT_BUTTON_HOVER := Color("#201A10")
const TEXT_BODY := Color("#3C382D")
const TEXT_FIELD := Color("#4D493D")
const TEXT_HINT := Color("#5B6157")
const TEXT_SUMMARY := Color("#53584F")
const TEXT_PANEL_TITLE := Color("#594424")
const TEXT_HISTORICAL := Color("#4F584D")
const TEXT_DISABLED := Color("#4F5249")
const TEXT_SUCCESS := Color("#416B52")
const TEXT_WARNING := Color("#7B5018")
const TEXT_DANGER := Color("#8A332B")
const TEXT_ACCENT := Color("#7B5A1D")
const TEXT_PLACEHOLDER := Color("#6C7065")
const RICH_HEADING_HEX := "7b5a1d"
const RICH_BODY_HEX := "4d493d"

const BORDER_SHELL := Color("#9DA48F")
const BORDER_BOARD := Color("#A5A88F")
const BORDER_BRASS := Color("#A1844B")
const BORDER_BRASS_SOFT := Color("#B09A68")
const GOLD_FOCUS := Color("#A77B27")
const SHADOW := Color(0.15, 0.12, 0.07, 0.18)

## 次级长列表统一使用的实际鼠标命中尺寸。
## 背包有更宽的专用规格；其余列表不再依赖 Godot 默认的 10—14px 细条。
const ACCESSIBLE_SCROLLBAR_WIDTH := 26.0
const ACCESSIBLE_SCROLLBAR_MIN_GRAB := 56.0
const ACCESSIBLE_SCROLLBAR_STEP := 96.0

const FONT_CAPTION := 12
const FONT_META := 13
const FONT_NOTE := 14
const FONT_BODY := 16
const FONT_ACTION := 18
const DIALOG_VARIANT_META := &"ui_dialog_variant"
const DIALOG_VARIANT_DEFAULT := "default"
const DIALOG_VARIANT_RECORD := "record"


static func build_base_theme(default_size: int) -> Theme:
	var app_theme := Theme.new()
	app_theme.default_font = FONT
	app_theme.default_font_size = default_size
	app_theme.set_color("font_color", "Label", TEXT_PRIMARY)
	app_theme.set_color("font_color", "Button", TEXT_BUTTON)
	app_theme.set_color("font_hover_color", "Button", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_pressed_color", "Button", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_focus_color", "Button", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_color", "CheckButton", TEXT_BUTTON)
	app_theme.set_color("font_hover_color", "CheckButton", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_pressed_color", "CheckButton", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_hover_pressed_color", "CheckButton", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_focus_color", "CheckButton", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_disabled_color", "CheckButton", TEXT_DISABLED)
	app_theme.set_color("font_color", "LineEdit", TEXT_FIELD)
	app_theme.set_color("font_placeholder_color", "LineEdit", TEXT_PLACEHOLDER)
	app_theme.set_color("caret_color", "LineEdit", GOLD_FOCUS)
	app_theme.set_color("font_color", "TextEdit", TEXT_BODY)
	app_theme.set_color("font_placeholder_color", "TextEdit", TEXT_PLACEHOLDER)
	app_theme.set_color("caret_color", "TextEdit", GOLD_FOCUS)
	app_theme.set_color("default_color", "RichTextLabel", TEXT_BODY)
	app_theme.set_color("font_color", "PopupMenu", TEXT_BUTTON)
	app_theme.set_color("font_hover_color", "PopupMenu", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_accelerator_color", "PopupMenu", TEXT_HINT)
	app_theme.set_color("font_disabled_color", "PopupMenu", TEXT_DISABLED)
	app_theme.set_color("font_separator_color", "PopupMenu", TEXT_HINT)
	app_theme.set_color("font_color", "ItemList", TEXT_BODY)
	app_theme.set_color("font_hovered_color", "ItemList", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_selected_color", "ItemList", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_hovered_selected_color", "ItemList", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_color", "Tree", TEXT_BODY)
	app_theme.set_color("font_hovered_color", "Tree", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_selected_color", "Tree", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_hovered_selected_color", "Tree", TEXT_BUTTON_HOVER)
	app_theme.set_color("title_color", "Window", TEXT_PANEL_TITLE)
	app_theme.set_icon("close", "Window", WINDOW_CLOSE_ICON)
	app_theme.set_icon("close_pressed", "Window", WINDOW_CLOSE_ICON)
	app_theme.set_color("font_color", "TooltipLabel", TEXT_BODY)
	app_theme.set_font_size("font_size", "TooltipLabel", FONT_NOTE)

	var normal_button := _make_bordered_panel(Color("#E9E5D2"), Color("#9BA38F"), 1, 3)
	normal_button.content_margin_left = 10
	normal_button.content_margin_top = 6
	normal_button.content_margin_right = 10
	normal_button.content_margin_bottom = 6
	var hover_button := normal_button.duplicate() as StyleBoxFlat
	hover_button.bg_color = Color("#F8EFD5")
	hover_button.border_color = GOLD_FOCUS
	var pressed_button := normal_button.duplicate() as StyleBoxFlat
	pressed_button.bg_color = Color("#E2D5B3")
	pressed_button.border_color = GOLD_FOCUS
	var focus_button := normal_button.duplicate() as StyleBoxFlat
	focus_button.border_color = GOLD_FOCUS
	focus_button.set_border_width_all(2)
	var disabled_button := normal_button.duplicate() as StyleBoxFlat
	disabled_button.bg_color = Color("#D9D8CA")
	disabled_button.border_color = Color("#B8B9AB")
	app_theme.set_stylebox("normal", "Button", normal_button)
	app_theme.set_stylebox("hover", "Button", hover_button)
	app_theme.set_stylebox("pressed", "Button", pressed_button)
	app_theme.set_stylebox("focus", "Button", focus_button)
	app_theme.set_stylebox("disabled", "Button", disabled_button)
	app_theme.set_color("font_disabled_color", "Button", TEXT_DISABLED)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		app_theme.set_stylebox(state, "OptionButton", app_theme.get_stylebox(state, "Button"))
	app_theme.set_color("font_color", "OptionButton", TEXT_BUTTON)
	app_theme.set_color("font_hover_color", "OptionButton", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_pressed_color", "OptionButton", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_focus_color", "OptionButton", TEXT_BUTTON_HOVER)
	app_theme.set_color("font_disabled_color", "OptionButton", TEXT_DISABLED)
	app_theme.set_icon("arrow", "OptionButton", _make_ui_icon("chevron_down", TEXT_BUTTON))

	var field_normal := _make_bordered_panel(Color("#FFF9E9"), Color("#A7AA96"), 1, 3)
	field_normal.content_margin_left = 9
	field_normal.content_margin_right = 9
	field_normal.content_margin_top = 6
	field_normal.content_margin_bottom = 6
	var field_focus := field_normal.duplicate() as StyleBoxFlat
	field_focus.border_color = GOLD_FOCUS
	field_focus.set_border_width_all(2)
	app_theme.set_stylebox("normal", "LineEdit", field_normal)
	app_theme.set_stylebox("focus", "LineEdit", field_focus)
	app_theme.set_stylebox("normal", "TextEdit", field_normal)
	app_theme.set_stylebox("focus", "TextEdit", field_focus)
	var spin_up := _make_ui_icon("triangle_up", TEXT_BUTTON)
	var spin_down := _make_ui_icon("triangle_down", TEXT_BUTTON)
	var spin_updown := _make_ui_icon("updown", TEXT_BUTTON)
	var spin_disabled_up := _make_ui_icon("triangle_up", TEXT_DISABLED)
	var spin_disabled_down := _make_ui_icon("triangle_down", TEXT_DISABLED)
	app_theme.set_icon("updown", "SpinBox", spin_updown)
	for state_name in ["up", "up_hover", "up_pressed"]:
		app_theme.set_icon(state_name, "SpinBox", spin_up)
	app_theme.set_icon("up_disabled", "SpinBox", spin_disabled_up)
	for state_name in ["down", "down_hover", "down_pressed"]:
		app_theme.set_icon(state_name, "SpinBox", spin_down)
	app_theme.set_icon("down_disabled", "SpinBox", spin_disabled_down)

	var list_panel := _make_bordered_panel(INK_LIST, BORDER_SHELL, 1, 3)
	list_panel.content_margin_left = 6
	list_panel.content_margin_top = 6
	list_panel.content_margin_right = 6
	list_panel.content_margin_bottom = 6
	var list_focus := list_panel.duplicate() as StyleBoxFlat
	list_focus.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	list_focus.border_color = GOLD_FOCUS
	list_focus.set_border_width_all(2)
	var list_selected := _make_bordered_panel(INK_LIST_SELECTED, BORDER_BRASS_SOFT, 1, 2)
	list_selected.content_margin_left = 4
	list_selected.content_margin_right = 4
	var list_hover := _make_bordered_panel(INK_LIST_HOVER, BORDER_BRASS_SOFT, 1, 2)
	list_hover.content_margin_left = 4
	list_hover.content_margin_right = 4
	for list_type in ["ItemList", "Tree"]:
		app_theme.set_stylebox("panel", list_type, list_panel)
		app_theme.set_stylebox("focus", list_type, list_focus)
		app_theme.set_stylebox("cursor", list_type, list_selected)
		app_theme.set_stylebox("cursor_unfocused", list_type, list_selected)
		app_theme.set_stylebox("selected", list_type, list_selected)
		app_theme.set_stylebox("selected_focus", list_type, list_selected)

	var scroll_track := _make_bordered_panel(Color("#E3DDC8"), Color("#C0B9A4"), 0, 4)
	var scroll_grabber := _make_bordered_panel(Color("#9DA48F"), Color("#838A78"), 1, 4)
	var scroll_grabber_hover := scroll_grabber.duplicate() as StyleBoxFlat
	scroll_grabber_hover.bg_color = Color("#B09A68")
	scroll_grabber_hover.border_color = GOLD_FOCUS
	for scroll_type in ["VScrollBar", "HScrollBar"]:
		app_theme.set_stylebox("scroll", scroll_type, scroll_track)
		app_theme.set_stylebox("scroll_focus", scroll_type, scroll_track)
		app_theme.set_stylebox("grabber", scroll_type, scroll_grabber)
		app_theme.set_stylebox("grabber_highlight", scroll_type, scroll_grabber_hover)
		app_theme.set_stylebox("grabber_pressed", scroll_type, scroll_grabber_hover)

	var separator := StyleBoxFlat.new()
	separator.bg_color = Color("#BDB49A")
	separator.content_margin_top = 1
	separator.content_margin_bottom = 1
	app_theme.set_stylebox("separator", "HSeparator", separator)

	var popup_panel := _make_bordered_panel(INK_DIALOG, BORDER_BRASS_SOFT, 1, 4)
	popup_panel.shadow_color = SHADOW
	popup_panel.shadow_size = 8
	app_theme.set_stylebox("panel", "PopupMenu", popup_panel)
	app_theme.set_stylebox("panel", "PopupPanel", popup_panel)
	app_theme.set_stylebox("hover", "PopupMenu", list_hover)
	app_theme.set_icon("checked", "PopupMenu", _make_ui_icon("checked", TEXT_BUTTON))
	app_theme.set_icon("checked_disabled", "PopupMenu", _make_ui_icon("checked", TEXT_DISABLED))
	app_theme.set_icon("unchecked", "PopupMenu", _make_ui_icon("unchecked", TEXT_HINT))
	app_theme.set_icon("unchecked_disabled", "PopupMenu", _make_ui_icon("unchecked", TEXT_DISABLED))
	app_theme.set_icon("radio_checked", "PopupMenu", _make_ui_icon("radio_checked", TEXT_BUTTON))
	app_theme.set_icon("radio_checked_disabled", "PopupMenu", _make_ui_icon("radio_checked", TEXT_DISABLED))
	app_theme.set_icon("radio_unchecked", "PopupMenu", _make_ui_icon("radio_unchecked", TEXT_HINT))
	app_theme.set_icon("radio_unchecked_disabled", "PopupMenu", _make_ui_icon("radio_unchecked", TEXT_DISABLED))
	app_theme.set_icon("submenu", "PopupMenu", _make_ui_icon("chevron_right", TEXT_BUTTON))
	app_theme.set_icon("submenu_mirrored", "PopupMenu", _make_ui_icon("chevron_left", TEXT_BUTTON))
	app_theme.set_icon("folded_arrow", "ColorPicker", _make_ui_icon("chevron_right", TEXT_BUTTON))
	app_theme.set_icon("expanded_arrow", "ColorPicker", _make_ui_icon("chevron_down", TEXT_BUTTON))
	var tooltip_panel := _make_bordered_panel(INK_DIALOG, BORDER_BRASS_SOFT, 1, 4)
	tooltip_panel.content_margin_left = 9
	tooltip_panel.content_margin_top = 6
	tooltip_panel.content_margin_right = 9
	tooltip_panel.content_margin_bottom = 6
	tooltip_panel.shadow_color = SHADOW
	tooltip_panel.shadow_size = 6
	app_theme.set_stylebox("panel", "TooltipPanel", tooltip_panel)

	var dialog_panel := make_dialog_panel()
	app_theme.set_stylebox("panel", "AcceptDialog", dialog_panel)
	app_theme.set_stylebox("panel", "ConfirmationDialog", dialog_panel)
	app_theme.set_stylebox("embedded_border", "Window", dialog_panel)
	app_theme.set_stylebox("embedded_unfocused_border", "Window", dialog_panel)
	return app_theme


static func make_title_panel() -> StyleBoxFlat:
	var style := _make_bordered_panel(
		Color(0.965, 0.929, 0.826, 0.96),
		Color(0.57, 0.46, 0.25, 0.86),
		3,
		2
	)
	style.shadow_color = Color(0.14, 0.10, 0.04, 0.22)
	style.shadow_size = 10
	return style


static func make_shell_panel(
	background: Color,
	border: Color,
	left_border: int = 1,
	radius: int = 3,
	shadow_size: int = 0
) -> StyleBoxFlat:
	var style := _make_bordered_panel(background, border, left_border, radius)
	if shadow_size > 0:
		style.shadow_color = SHADOW
		style.shadow_size = shadow_size
	return style


static func make_record_panel(
	alpha: float,
	shadow_size: int,
	content_margins: Vector4 = Vector4.ZERO
) -> StyleBoxFlat:
	var background := Color(
		INK_RECORD_BASE.r,
		INK_RECORD_BASE.g,
		INK_RECORD_BASE.b,
		clampf(alpha, 0.0, 1.0)
	)
	var style := _make_bordered_panel(background, BORDER_BRASS, 3, 2)
	style.shadow_color = SHADOW
	style.shadow_size = maxi(shadow_size, 0)
	style.content_margin_left = content_margins.x
	style.content_margin_top = content_margins.y
	style.content_margin_right = content_margins.z
	style.content_margin_bottom = content_margins.w
	return style


static func make_floating_tool_panel(
	alpha: float,
	radius: int,
	content_margins: Vector4
) -> StyleBoxFlat:
	var style := _make_bordered_panel(
		Color(0.965, 0.94, 0.86, clampf(alpha, 0.0, 1.0)),
		BORDER_BRASS_SOFT,
		1,
		radius
	)
	style.content_margin_left = content_margins.x
	style.content_margin_top = content_margins.y
	style.content_margin_right = content_margins.z
	style.content_margin_bottom = content_margins.w
	return style


static func make_dialog_panel() -> StyleBoxFlat:
	var style := _make_bordered_panel(INK_DIALOG, BORDER_BRASS, 1, 5)
	style.shadow_color = SHADOW
	style.shadow_size = 14
	return style


static func apply_dialog_surface(dialog: AcceptDialog, source_style: StyleBoxFlat = null) -> void:
	var panel_style := (
		_dialog_panel_for_variant(str(dialog.get_meta(DIALOG_VARIANT_META, DIALOG_VARIANT_DEFAULT)))
		if source_style == null
		else source_style.duplicate() as StyleBoxFlat
	)
	# Godot 的嵌入式 Window 标题栏位于 AcceptDialog 内容面板上方。
	# 将同一浅绢表面向上延展，让标题和关闭按钮明确属于当前弹窗，
	# 而不是浮在地图、顶栏或封面背景上。
	panel_style.expand_margin_top = 34.0
	dialog.add_theme_stylebox_override("panel", panel_style)
	dialog.add_theme_stylebox_override("embedded_border", panel_style)
	dialog.add_theme_stylebox_override("embedded_unfocused_border", panel_style)
	dialog.add_theme_color_override("title_color", TEXT_PANEL_TITLE)
	dialog.add_theme_icon_override("close", WINDOW_CLOSE_ICON)
	dialog.add_theme_icon_override("close_pressed", WINDOW_CLOSE_ICON)


static func style_accessible_scrollbar(
	scroll_bar: ScrollBar,
	tooltip_text := "",
	width: float = ACCESSIBLE_SCROLLBAR_WIDTH,
	min_grab_height: float = ACCESSIBLE_SCROLLBAR_MIN_GRAB
) -> void:
	"""给次级列表提供稳定、可见、可抓取的滚动条。"""
	if scroll_bar == null or not is_instance_valid(scroll_bar):
		return
	var is_horizontal := scroll_bar is HScrollBar
	var current_width := scroll_bar.custom_minimum_size.y if is_horizontal else scroll_bar.custom_minimum_size.x
	var resolved_width := maxf(maxf(width, 22.0), current_width)
	var current_grabber := scroll_bar.get_theme_stylebox("grabber")
	var current_grabber_min := 0.0
	if current_grabber != null:
		var current_grabber_size := current_grabber.get_minimum_size()
		current_grabber_min = current_grabber_size.x if is_horizontal else current_grabber_size.y
	var resolved_grab := maxf(maxf(min_grab_height, 44.0), current_grabber_min)
	if is_horizontal:
		scroll_bar.custom_minimum_size.y = maxf(scroll_bar.custom_minimum_size.y, resolved_width)
		scroll_bar.add_theme_constant_override("scrollbar_height", int(ceil(resolved_width)))
	else:
		scroll_bar.custom_minimum_size.x = maxf(scroll_bar.custom_minimum_size.x, resolved_width)
	scroll_bar.add_theme_constant_override("scrollbar_width", int(ceil(resolved_width)))
	scroll_bar.add_theme_constant_override("minimum_grab_thickness", int(ceil(resolved_grab)))
	scroll_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll_bar.focus_mode = Control.FOCUS_ALL
	scroll_bar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	scroll_bar.custom_step = maxf(scroll_bar.custom_step, ACCESSIBLE_SCROLLBAR_STEP)
	scroll_bar.z_index = maxi(scroll_bar.z_index, 4)
	scroll_bar.set_meta("accessible_scrollbar_width", resolved_width)
	scroll_bar.set_meta("accessible_scrollbar_min_grab", resolved_grab)
	if not tooltip_text.is_empty():
		scroll_bar.tooltip_text = tooltip_text

	var track := _make_bordered_panel(Color("#E3DDC8"), Color("#B8B39F"), 1, 8)
	track.content_margin_left = 2.0
	track.content_margin_right = 2.0
	scroll_bar.add_theme_stylebox_override("scroll", track)
	scroll_bar.add_theme_stylebox_override("scroll_focus", track)
	var grabber := _make_bordered_panel(Color("#7D8A76"), Color("#596955"), 1, 8)
	grabber.content_margin_left = 3.0
	grabber.content_margin_right = 3.0
	if is_horizontal:
		grabber.content_margin_left = resolved_grab * 0.5
		grabber.content_margin_right = resolved_grab * 0.5
	else:
		grabber.content_margin_top = resolved_grab * 0.5
		grabber.content_margin_bottom = resolved_grab * 0.5
	scroll_bar.add_theme_stylebox_override("grabber", grabber)
	var grabber_hover := grabber.duplicate() as StyleBoxFlat
	grabber_hover.bg_color = Color("#B09A68")
	grabber_hover.border_color = GOLD_FOCUS
	scroll_bar.add_theme_stylebox_override("grabber_highlight", grabber_hover)
	scroll_bar.add_theme_stylebox_override("grabber_pressed", grabber_hover)
	var decrement_kind := "chevron_left" if is_horizontal else "triangle_up"
	var increment_kind := "chevron_right" if is_horizontal else "triangle_down"
	var step_up := _make_ui_icon(decrement_kind, TEXT_BUTTON)
	var step_down := _make_ui_icon(increment_kind, TEXT_BUTTON)
	var step_up_hover := _make_ui_icon(decrement_kind, GOLD_FOCUS)
	var step_down_hover := _make_ui_icon(increment_kind, GOLD_FOCUS)
	var step_up_disabled := _make_ui_icon(decrement_kind, TEXT_DISABLED)
	var step_down_disabled := _make_ui_icon(increment_kind, TEXT_DISABLED)
	scroll_bar.add_theme_icon_override("decrement", step_up)
	scroll_bar.add_theme_icon_override("decrement_highlight", step_up_hover)
	scroll_bar.add_theme_icon_override("decrement_pressed", step_up_hover)
	scroll_bar.add_theme_icon_override("decrement_disabled", step_up_disabled)
	scroll_bar.add_theme_icon_override("increment", step_down)
	scroll_bar.add_theme_icon_override("increment_highlight", step_down_hover)
	scroll_bar.add_theme_icon_override("increment_pressed", step_down_hover)
	scroll_bar.add_theme_icon_override("increment_disabled", step_down_disabled)


static func style_accessible_scrollbars_in(
	root: Node,
	tooltip_text := "",
	skip_preserved := true
) -> int:
	"""在布局完成后统一处理控件内部生成的滚动条。"""
	if root == null or not is_instance_valid(root):
		return 0
	var styled_count := 0
	for node in root.find_children("*", "ScrollBar", true, false):
		var scroll_bar := node as ScrollBar
		if scroll_bar == null or not is_instance_valid(scroll_bar):
			continue
		if skip_preserved and bool(scroll_bar.get_meta("preserve_accessible_scrollbar", false)):
			continue
		var resolved_tooltip := tooltip_text
		if resolved_tooltip.is_empty():
			resolved_tooltip = (
				"拖动查看横向内容；也可用 Shift+滚轮"
				if scroll_bar is HScrollBar
				else "拖动查看列表；点击轨道翻页；滚轮或 ↑↓"
			)
		style_accessible_scrollbar(scroll_bar, resolved_tooltip)
		styled_count += 1
	return styled_count


static func set_dialog_variant(dialog: AcceptDialog, variant: String) -> void:
	if dialog == null:
		return
	var resolved := variant if variant in [DIALOG_VARIANT_DEFAULT, DIALOG_VARIANT_RECORD] else DIALOG_VARIANT_DEFAULT
	dialog.set_meta(DIALOG_VARIANT_META, resolved)


static func _dialog_panel_for_variant(variant: String) -> StyleBoxFlat:
	if variant == DIALOG_VARIANT_RECORD:
		var record_style := make_record_panel(1.0, 8)
		record_style.border_width_left = 1
		record_style.set_corner_radius_all(8)
		return record_style
	return make_dialog_panel()


static func make_rect_button(background: Color, border: Color) -> StyleBoxFlat:
	var style := _make_bordered_panel(background, border, 2, 2)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


static func apply_toolbar_button_style(button: BaseButton, danger: bool) -> void:
	var normal_background := Color("#F3DCD5") if danger else Color("#E6E4D2")
	var normal_border := Color("#B66C63") if danger else Color("#98A18E")
	var normal := _make_bordered_panel(normal_background, normal_border, 1, 3)
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#F8CFC7") if danger else Color("#F8EFD4")
	hover.border_color = Color("#B45D53") if danger else GOLD_FOCUS
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)

	var focus := normal.duplicate() as StyleBoxFlat
	focus.border_color = GOLD_FOCUS
	focus.border_width_left = 2
	button.add_theme_stylebox_override("focus", focus)

	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("#D7D6C7")
	disabled.border_color = Color("#B8B9AB")
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_disabled_color", TEXT_DISABLED)


static func _make_bordered_panel(
	background: Color,
	border: Color,
	left_border: int,
	radius: int
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.border_width_left = maxi(left_border, 0)
	style.set_corner_radius_all(maxi(radius, 0))
	return style


static func _make_ui_icon(kind: String, color: Color) -> ImageTexture:
	var image := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	match kind:
		"chevron_down":
			for step in range(4):
				_stamp_icon_pixel(image, 2 + step, 3 + step, color)
				_stamp_icon_pixel(image, 9 - step, 3 + step, color)
		"chevron_right":
			for step in range(4):
				_stamp_icon_pixel(image, 4 + step, 2 + step, color)
				_stamp_icon_pixel(image, 4 + step, 9 - step, color)
		"chevron_left":
			for step in range(4):
				_stamp_icon_pixel(image, 7 - step, 2 + step, color)
				_stamp_icon_pixel(image, 7 - step, 9 - step, color)
		"triangle_up":
			for row in range(4):
				for x in range(5 - row, 7 + row):
					_set_icon_pixel(image, x, 3 + row, color)
		"triangle_down":
			for row in range(4):
				for x in range(2 + row, 10 - row):
					_set_icon_pixel(image, x, 4 + row, color)
		"updown":
			for row in range(3):
				for x in range(4 - row, 8 + row):
					_set_icon_pixel(image, x, 1 + row, color)
					_set_icon_pixel(image, x, 10 - row, color)
		"checked":
			_draw_icon_box(image, TEXT_HINT)
			for step in range(3):
				_stamp_icon_pixel(image, 2 + step, 6 + step, color)
			for step in range(5):
				_stamp_icon_pixel(image, 5 + step, 8 - step, color)
		"unchecked":
			_draw_icon_box(image, color)
		"radio_checked":
			_draw_icon_ring(image, color)
			for y in range(4, 8):
				for x in range(4, 8):
					if Vector2(x - 5.5, y - 5.5).length_squared() <= 4.0:
						_set_icon_pixel(image, x, y, color)
		"radio_unchecked":
			_draw_icon_ring(image, color)
	return ImageTexture.create_from_image(image)


static func _draw_icon_box(image: Image, color: Color) -> void:
	for x in range(1, 11):
		_set_icon_pixel(image, x, 1, color)
		_set_icon_pixel(image, x, 10, color)
	for y in range(1, 11):
		_set_icon_pixel(image, 1, y, color)
		_set_icon_pixel(image, 10, y, color)


static func _draw_icon_ring(image: Image, color: Color) -> void:
	for y in range(1, 11):
		for x in range(1, 11):
			var distance := Vector2(x - 5.5, y - 5.5).length()
			if distance >= 3.7 and distance <= 5.0:
				_set_icon_pixel(image, x, y, color)


static func _stamp_icon_pixel(image: Image, x: int, y: int, color: Color) -> void:
	_set_icon_pixel(image, x, y, color)
	_set_icon_pixel(image, x, y + 1, color)


static func _set_icon_pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
		image.set_pixel(x, y, color)
