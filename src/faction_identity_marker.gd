class_name FactionIdentityMarker
extends Control


const FactionPaletteScript = preload("res://src/faction_palette.gd")
const MarkerFont := preload("res://assets/fonts/Source_Han_Serif.otf")
const MARKER_SIZE := Vector2(20, 20)
const FONT_SIZE := 12

var faction_id := ""
var marker_text := ""
var marker_color := Color("737B72")


func setup(faction_id_value: String, marker_value: String, color_value: Color) -> void:
	faction_id = faction_id_value
	marker_text = marker_value
	marker_color = color_value
	custom_minimum_size = MARKER_SIZE
	size = MARKER_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	var center := MARKER_SIZE * 0.5
	var fill_color := marker_color
	fill_color.a = 0.96
	var border_color := FactionPaletteScript.render_on_dark(
		FactionPaletteScript.to_hex(marker_color),
		Color("0B120F"),
		4.0
	)
	border_color.a = 0.98
	var white_ratio := FactionPaletteScript.contrast_ratio(Color.WHITE, fill_color)
	var black_ratio := FactionPaletteScript.contrast_ratio(Color.BLACK, fill_color)
	var text_color := Color.WHITE if white_ratio >= black_ratio else Color.BLACK
	draw_circle(center, 10.0, Color(0.02, 0.035, 0.028, 0.76))
	draw_circle(center, 8.5, fill_color)
	draw_circle(center, 9.0, border_color, false, 1.1, true)
	var text_size := MarkerFont.get_string_size(
		marker_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		FONT_SIZE
	)
	draw_string(
		MarkerFont,
		center + Vector2(-text_size.x * 0.5, text_size.y * 0.31),
		marker_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		FONT_SIZE,
		text_color
	)
