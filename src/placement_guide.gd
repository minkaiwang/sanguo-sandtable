class_name PlacementGuide
extends Control

const GuideFont := preload("res://assets/fonts/Source_Han_Serif.otf")
const LABEL_FONT_SIZE := 14
const LABEL_MARGIN := 6.0
const LABEL_TARGET_GAP := 22.0

var target_position := Vector2.ZERO
var place_name := ""
var avoid_rect := Rect2()
var _label_rect := Rect2()
var _text_origin := Vector2.ZERO


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func show_target(screen_position: Vector2, name_value: String, avoid_rect_value := Rect2()) -> void:
	if visible and target_position.is_equal_approx(screen_position) and place_name == name_value and _rect_equal_approx(avoid_rect, avoid_rect_value):
		return
	target_position = screen_position
	place_name = name_value
	avoid_rect = avoid_rect_value
	visible = true
	_update_label_layout()
	queue_redraw()


func hide_target() -> void:
	visible = false
	place_name = ""
	avoid_rect = Rect2()
	_label_rect = Rect2()


func get_layout_contract() -> Dictionary:
	return {
		"visible": visible,
		"place_name": place_name,
		"target_position": target_position,
		"label_rect": _label_rect,
		"avoid_rect": avoid_rect,
		"overlap_area": _rect_overlap_area(_label_rect, avoid_rect)
	}


func _rect_equal_approx(first: Rect2, second: Rect2) -> bool:
	return first.position.is_equal_approx(second.position) and first.size.is_equal_approx(second.size)


func _rect_overlap_area(first: Rect2, second: Rect2) -> float:
	if not first.has_area() or not second.has_area():
		return 0.0
	var overlap := first.intersection(second)
	return overlap.size.x * overlap.size.y if overlap.has_area() else 0.0


func _update_label_layout() -> void:
	var text := "驻：%s" % place_name
	var text_size := GuideFont.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE)
	var label_size := text_size + Vector2(10.0, 7.0)
	var raw_positions := [
		target_position + Vector2(LABEL_TARGET_GAP, LABEL_TARGET_GAP),
		Vector2(target_position.x - label_size.x - LABEL_TARGET_GAP, target_position.y + LABEL_TARGET_GAP),
		Vector2(target_position.x + LABEL_TARGET_GAP, target_position.y - label_size.y - LABEL_TARGET_GAP),
		target_position - label_size - Vector2(LABEL_TARGET_GAP, LABEL_TARGET_GAP)
	]
	if avoid_rect.has_area():
		const CARD_GAP := 8.0
		# 人物卡在带四维、行动与势力色时会比早期姓名卡更宽。候选不仅围绕
		# 城点，也围绕卡牌外缘生成，保证城点落在卡牌中央附近时仍有零遮挡解。
		raw_positions.append_array([
			Vector2(avoid_rect.end.x + CARD_GAP, target_position.y - label_size.y * 0.5),
			Vector2(avoid_rect.position.x - label_size.x - CARD_GAP, target_position.y - label_size.y * 0.5),
			Vector2(target_position.x - label_size.x * 0.5, avoid_rect.position.y - label_size.y - CARD_GAP),
			Vector2(target_position.x - label_size.x * 0.5, avoid_rect.end.y + CARD_GAP)
		])
	var max_position := Vector2(
		maxf(LABEL_MARGIN, size.x - label_size.x - LABEL_MARGIN),
		maxf(LABEL_MARGIN, size.y - label_size.y - LABEL_MARGIN)
	)
	var best_rect := Rect2(Vector2(LABEL_MARGIN, LABEL_MARGIN), label_size)
	var best_score := INF
	for candidate_index in range(raw_positions.size()):
		var raw_position: Vector2 = raw_positions[candidate_index]
		var clamped_position := Vector2(
			clampf(raw_position.x, LABEL_MARGIN, max_position.x),
			clampf(raw_position.y, LABEL_MARGIN, max_position.y)
		)
		var candidate := Rect2(clamped_position, label_size)
		var overlap_area := _rect_overlap_area(candidate, avoid_rect)
		var edge_adjustment := raw_position.distance_to(clamped_position)
		# 人物卡遮挡优先级最高；若均不遮挡，则优先原有的右下方位及最少边缘位移。
		var score := overlap_area * 10000.0 + edge_adjustment * 10.0 + float(candidate_index)
		if score < best_score:
			best_score = score
			best_rect = candidate
	_label_rect = best_rect
	_text_origin = _label_rect.position + Vector2(5.0, LABEL_FONT_SIZE + 3.0)


func _draw() -> void:
	_update_label_layout()
	var gold := Color("d7b661")
	draw_circle(target_position, 13.0, Color(0.05, 0.08, 0.07, 0.72))
	draw_circle(target_position, 11.0, gold, false, 2.0, true)
	draw_line(target_position + Vector2(-16, 0), target_position + Vector2(-7, 0), gold, 2.0, true)
	draw_line(target_position + Vector2(7, 0), target_position + Vector2(16, 0), gold, 2.0, true)
	draw_line(target_position + Vector2(0, -16), target_position + Vector2(0, -7), gold, 2.0, true)
	draw_line(target_position + Vector2(0, 7), target_position + Vector2(0, 16), gold, 2.0, true)
	var text := "驻：%s" % place_name
	draw_rect(_label_rect, Color(0.05, 0.08, 0.07, 0.88), true)
	draw_rect(_label_rect, Color(0.45, 0.53, 0.40, 0.88), false, 1.0)
	draw_string(GuideFont, _text_origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE, Color("f5e4ae"))
