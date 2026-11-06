extends SceneTree

var failures: Array[String] = []
const TEST_FILES := [
	"user://sandbox_save_automated_test.json",
	"user://backpack_preferences_automated_test.json",
	"user://sandbox_snapshots_automated_test.json"
]


func _init() -> void:
	call_deferred("_run")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _remove_test_files() -> void:
	for path in TEST_FILES:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _find_free_normalized(map_board) -> Vector2:
	var best := Vector2(0.5, 0.5)
	var best_distance := -1.0
	for y_step in range(3, 8):
		for x_step in range(3, 8):
			var candidate := Vector2(float(x_step) / 10.0, float(y_step) / 10.0)
			var candidate_world: Vector2 = map_board.map_normalized_to_world(candidate)
			var nearest := INF
			for place_world in map_board._place_world_positions:
				nearest = minf(nearest, candidate_world.distance_to(place_world))
			if nearest > best_distance:
				best_distance = nearest
				best = candidate
	return best


func _run() -> void:
	_remove_test_files()
	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var card = main.backpack.get_character_card("liu_bei")
	_expect(card != null, "背包应公开可见人物卡供真实 GUI 验收定位")
	if card != null:
		var data: Dictionary = card.build_backpack_drag_data()
		var preview: Dictionary = card.get_backpack_drag_preview_contract()
		_expect(str(data.get("source", "")) == "backpack", "拖拽数据来源应明确为背包")
		_expect(str(data.get("character_id", "")) == "liu_bei", "拖拽数据应保留人物 ID")
		_expect(data.get("preview_size", Vector2.ZERO) == Vector2(136, 46), "预览应与地图军势标记同为 136×46")
		_expect(str(data.get("preview_anchor", "")) == "center", "预览热点应为中心")
		_expect(preview.get("offset", Vector2.ZERO) == Vector2(-68, -23), "预览子节点应使用负半尺寸偏移")
		_expect(preview.get("pointer_to_center_error", Vector2.ONE).is_zero_approx(), "鼠标到预览中心的契约误差应为零")
		_expect(str(preview.get("font_path", "")).ends_with("Source_Han_Serif.otf"), "预览应显式使用项目思源宋体")

		var free_normalized := _find_free_normalized(main.map_board)
		var free_world: Vector2 = main.map_board.map_normalized_to_world(free_normalized)
		for zoom_value in [0.75, 1.0, 1.75, 2.50, 3.00]:
			main.map_board.zoom = zoom_value
			main.map_board.pan = main.map_board.size * 0.5 - free_world * zoom_value + Vector2(19, -13)
			main.map_board._apply_camera(false)
			var target: Vector2 = main.map_board.pan + free_world * zoom_value
			_expect(main.map_board._can_drop_data(target, data), "75%/100%/175%/250% 非零平移下应接受合法背包人物")
			var mapped: Dictionary = main.map_board.screen_to_valid_map_normalized(target)
			_expect(bool(mapped.get("valid", false)), "自由落点应位于地理内容范围内")
			_expect(mapped.get("normalized", Vector2.ZERO).distance_to(free_normalized) < 0.00001, "缩放平移后目标坐标换算应保持准确")
			main.map_board.clear_native_drag_feedback()

		main.map_board.zoom = 3.00
		var luoyang_place: Dictionary = main._find_place("luoyang")
		var luoyang_normalized := Vector2(float(luoyang_place.get("x", 0.5)), float(luoyang_place.get("y", 0.5)))
		var luoyang_world: Vector2 = main.map_board.map_normalized_to_world(luoyang_normalized)
		main.map_board.pan = main.map_board.size * 0.5 - luoyang_world * main.map_board.zoom
		main.map_board._apply_camera(false)
		var luoyang_screen: Vector2 = main.map_board.get_place_screen_position("luoyang")
		_expect(main.map_board._can_drop_data(luoyang_screen, data), "洛阳吸附区应接受刘备卡")
		var feedback: Dictionary = main.map_board.get_native_drag_feedback_state()
		var guide: Dictionary = feedback.get("guide", {})
		var avoid_rect: Rect2 = feedback.get("avoid_rect", Rect2())
		_expect(str(feedback.get("candidate_id", "")) == "luoyang", "原生背包拖拽应进入洛阳候选")
		_expect(avoid_rect.size == Vector2(136, 46), "吸附提示应避让真实预览尺寸")
		_expect(avoid_rect.get_center().distance_to(luoyang_screen) < 0.001, "提示避让矩形应以鼠标为中心")
		_expect(float(guide.get("overlap_area", -1.0)) == 0.0, "吸附提示不得遮挡人物预览")
		main.map_board.clear_native_drag_feedback()
		feedback = main.map_board.get_native_drag_feedback_state()
		_expect(str(feedback.get("candidate_id", "")) == "", "取消后应清除吸附候选")
		_expect(not bool(feedback.get("guide", {}).get("visible", true)), "取消后应隐藏吸附提示")

		var invalid_source := data.duplicate(true)
		invalid_source["source"] = "map"
		var unknown := data.duplicate(true)
		unknown["character_id"] = "unknown_character"
		_expect(not main.map_board._can_drop_data(luoyang_screen, invalid_source), "地图不得接受伪造来源")
		_expect(not main.map_board._can_drop_data(luoyang_screen, unknown), "地图不得接受未知人物")

		main.map_board.zoom = 3.00
		main.map_board.pan = main.map_board.size * 0.5 - free_world * main.map_board.zoom
		main.map_board._apply_camera(false)
		var free_screen: Vector2 = main.map_board.pan + free_world * main.map_board.zoom
		await process_frame
		await process_frame
		var cache_before: Dictionary = main.map_board.get_static_cache_state()
		var undo_before: int = main._undo_stack.size()
		main.map_board._drop_data(free_screen, data)
		await process_frame
		_expect(main.placements.has("liu_bei"), "合法自由投放应只摆出目标人物")
		_expect(main._undo_stack.size() == undo_before + 1, "一次投放应只新增一个撤销步骤")
		if main.placements.has("liu_bei"):
			var placed: Dictionary = main.placements["liu_bei"]
			var placed_normalized := Vector2(float(placed.get("x", 0.0)), float(placed.get("y", 0.0)))
			_expect(placed_normalized.distance_to(free_normalized) < 0.00001, "自由投放结果应保持精确归一化坐标")
			_expect(not placed.has("place_id"), "远离城池的自由投放不得误吸附")
		_expect(main.backpack.get_character_card("liu_bei") == null, "摆出后人物应从背包移除")
		var map_card = main.map_board._card_by_id.get("liu_bei")
		if map_card != null:
			var expected_global: Vector2 = main.map_board.get_global_transform_with_canvas() * free_screen
			_expect(map_card.get_global_rect().get_center().distance_to(expected_global) <= 1.0, "落地人物视觉中心应与释放点误差不超过 1 像素")
		var cache_after: Dictionary = main.map_board.get_static_cache_state()
		_expect(int(cache_before.get("static_builds", 0)) == int(cache_after.get("static_builds", -1)), "背包投放不得重建地形缓存")
		_expect(int(cache_before.get("annotation_builds", 0)) == int(cache_after.get("annotation_builds", -1)), "背包投放不得重建注记缓存")
		_expect(not main.map_board._can_drop_data(free_screen, data), "已摆出人物不得被重复投放")

	main.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("BACKPACK_DRAG_CONTRACT_TEST_OK preview=centered size=136x46 font=explicit validation=strict zoom=75/100/175/250/300 pan=nonzero snap_guide=clear cancel=clean drop=accurate duplicate=blocked cache=stable")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
