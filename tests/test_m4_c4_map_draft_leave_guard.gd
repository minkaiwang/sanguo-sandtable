extends SceneTree


var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _remove_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _file_snapshot(path: String) -> Dictionary:
	return {
		"exists": FileAccess.file_exists(path),
		"bytes": FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else PackedByteArray(),
	}


func _wait_frames(count: int) -> void:
	for _frame in range(count):
		await process_frame


func _left_press(position: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = position
	return event


func _mouse_button(position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = position
	return event


func _mouse_motion(position: Vector2, relative: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.relative = relative
	return event


func _screen_point(board, normalized_position: Vector2) -> Vector2:
	return board.pan + board.map_normalized_to_world(normalized_position) * board.zoom


func _drag_handle(board, point_index: int, target_normalized: Vector2) -> void:
	var handles: Array[Vector2] = board.get_player_stroke_handle_screen_positions()
	var start := handles[point_index]
	var target := _screen_point(board, target_normalized)
	board._stroke_input_overlay.gui_input.emit(_mouse_button(start, true))
	board._stroke_input_overlay.gui_input.emit(_mouse_motion(target, target - start))
	board._stroke_input_overlay.gui_input.emit(_mouse_button(target, false))


func _run() -> void:
	var isolated_paths := [
		"user://sandbox_save_automated_test.json",
		"user://backpack_preferences_automated_test.json",
		"user://sandbox_snapshots_automated_test.json",
		"user://personal_scenario_templates_automated_test.json",
	]
	for path in isolated_paths:
		_remove_file(path)

	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	current_scene = main
	await _wait_frames(4)
	var board = main.map_board
	_expect(main.automated_test_mode, "地图草稿离开门禁专项必须使用自动隔离状态")
	_expect(main.SAVE_VERSION == 18 and main.character_catalog_version == 6, "地图草稿门禁不得改变 v18／目录 v6")
	_expect(not auto_accept_quit, "主沙盘必须继续由安全关闭流程接管系统关闭")
	main.annotations.clear()
	main.player_strokes.clear()
	main._undo_stack.clear()
	main._redo_stack.clear()
	main._refresh_views()
	_expect(main._save(), "地图草稿门禁专项基线必须成功写入隔离存档")

	# 已打开的标记编辑器包含尚未提交的落点、类型和文字；沙盘菜单与系统关闭都不能静默清掉。
	main._on_annotation_create_requested(Vector2(0.34, 0.46))
	await _wait_frames(2)
	main.annotation_input.text = "尚未放好的援军标记"
	var reinforcement_index: int = main.ANNOTATION_TYPES.find("reinforcement")
	main.annotation_type_select.select(reinforcement_index)
	main._on_annotation_type_selected(reinforcement_index)
	var annotation_pending_before := {
		"id": main._pending_annotation_id,
		"position": main._pending_annotation_position,
		"type": main._pending_annotation_type,
		"faction_id": main._pending_annotation_faction_id,
		"text": main.annotation_input.text,
	}
	var annotation_save_before := _file_snapshot(main.save_path)
	main._save_writes_blocked = true
	main._save_write_block_reason = "地图标记门禁顺序故障注入"
	main._on_sandbox_file_menu_pressed(2)
	await process_frame
	_expect(main.annotation_dialog.visible, "沙盘菜单必须保留尚未完成的标记编辑器")
	_expect(
		main._pending_annotation_id == annotation_pending_before.id
		and main._pending_annotation_position == annotation_pending_before.position
		and main._pending_annotation_type == annotation_pending_before.type
		and main._pending_annotation_faction_id == annotation_pending_before.faction_id
		and main.annotation_input.text == annotation_pending_before.text,
		"拒绝菜单中断后必须原样保留标记落点、类型、势力和文字"
	)
	main._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	await process_frame
	_expect(is_instance_valid(main) and main.is_inside_tree() and main.annotation_dialog.visible, "未完成标记必须拒绝系统关闭并保留当前沙盘")
	_expect(main.annotations.is_empty() and _file_snapshot(main.save_path) == annotation_save_before, "拒绝中断不得提交标记或改写存档")
	_expect(not main.message_dialog.visible and main.status_label.text.contains("先完成或取消"), "标记门禁必须先于存档故障检查并给出解决方式")
	main.annotation_dialog.hide()
	main._cancel_annotation_dialog()

	# 推演线设置对话框本身也是草稿；确认后，即使尚未落点也要保留类型和说明。
	main._open_player_stroke_dialog()
	await _wait_frames(2)
	var stroke_type_index: int = main._player_stroke_type_index("reinforcement")
	main.player_stroke_type_select.select(stroke_type_index)
	main.player_stroke_label_input.text = "尚未完成的援军路线"
	main._on_sandbox_file_menu_pressed(12)
	await process_frame
	_expect(
		current_scene == main
		and main.player_stroke_dialog.visible
		and main.player_stroke_type_select.selected == stroke_type_index
		and main.player_stroke_label_input.text == "尚未完成的援军路线",
		"返回标题菜单必须保留推演线设置中的类型和说明"
	)
	_expect(not main._request_safe_quit(false), "推演线设置未完成时必须拒绝安全关闭")
	_expect(not main.message_dialog.visible, "推演线设置门禁必须发生在存档故障检查之前")
	main.player_stroke_dialog.hide()
	main._confirm_player_stroke_dialog()
	await process_frame
	_expect(board.is_player_stroke_tool_active(), "确认推演线设置后必须进入正式落点流程")
	_expect(
		main._pending_player_stroke_type == "reinforcement"
		and main._pending_player_stroke_label == "尚未完成的援军路线",
		"开始落点后必须保留刚确认的推演线设置"
	)
	main._on_sandbox_file_menu_pressed(2)
	_expect(board.is_player_stroke_tool_active() and board.get_player_stroke_draft_points().is_empty(), "零落点推演线仍须保留已确认的类型和说明")

	# 两个落点形成真正的空间草稿；菜单、返回标题与系统关闭都不得取消或写入旧状态。
	board._stroke_input_overlay.gui_input.emit(_left_press(_screen_point(board, Vector2(0.31, 0.52))))
	board._stroke_input_overlay.gui_input.emit(_left_press(_screen_point(board, Vector2(0.58, 0.43))))
	await process_frame
	var draft_points_before: Array[Vector2] = board.get_player_stroke_draft_points()
	var draft_save_before := _file_snapshot(main.save_path)
	var draft_history_before: Array = main._undo_stack.duplicate(true)
	main._on_sandbox_file_menu_pressed(12)
	await process_frame
	_expect(current_scene == main and board.is_player_stroke_tool_active(), "推演线落点草稿必须阻止菜单返回标题")
	_expect(board.get_player_stroke_draft_points() == draft_points_before and main.player_strokes.is_empty(), "阻断返回标题后必须保留全部草稿点且不得生成正式线")
	main._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	await process_frame
	_expect(
		board.get_player_stroke_draft_points() == draft_points_before
		and main._undo_stack == draft_history_before
		and _file_snapshot(main.save_path) == draft_save_before,
		"拒绝系统关闭后必须保留推演线草稿、历史和存档字节"
	)

	# 明确完成后沿用既有原子提交；随后测试已变化的折点预览。
	main._save_writes_blocked = false
	main._save_write_block_reason = ""
	board.finish_player_stroke_draft()
	await _wait_frames(3)
	_expect(main.player_strokes.size() == 1 and not board.is_player_stroke_tool_active(), "明确完成后必须提交一条正式推演线并退出落点模式")
	var stroke_id := str(main.player_strokes[0].get("id", ""))
	main._undo_stack.clear()
	main._redo_stack.clear()
	_expect(main._save(), "折点预览门禁基线必须成功写入隔离存档")
	var formal_strokes_before: Array[Dictionary] = main.player_strokes.duplicate(true)
	var board_strokes_before: Array[Dictionary] = board.get_player_strokes().duplicate(true)
	var edit_history_before: Array = main._undo_stack.duplicate(true)
	var edit_save_before := _file_snapshot(main.save_path)
	_expect(board.begin_player_stroke_point_edit(stroke_id), "折点预览门禁必须从正式路线编辑流程进入")
	_drag_handle(board, 1, Vector2(0.63, 0.38))
	await process_frame
	var edit_state_before: Dictionary = board.get_player_stroke_point_edit_state().duplicate(true)
	_expect(bool(edit_state_before.get("changed", false)), "折点拖动必须形成尚未提交的变化预览")
	main._save_writes_blocked = true
	main._save_write_block_reason = "折点预览门禁顺序故障注入"
	main._on_sandbox_file_menu_pressed(12)
	await process_frame
	_expect(current_scene == main and board.get_player_stroke_point_edit_state() == edit_state_before, "返回标题菜单必须原样保留已变化的折点预览")
	main._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	await process_frame
	_expect(
		board.get_player_stroke_point_edit_state() == edit_state_before
		and main._player_strokes_match(main.player_strokes, formal_strokes_before)
		and main._player_strokes_match(board.get_player_strokes(), board_strokes_before)
		and main._undo_stack == edit_history_before
		and _file_snapshot(main.save_path) == edit_save_before,
		"拒绝系统关闭后必须只保留折点预览，不得污染正式线、历史或存档"
	)
	_expect(not main.message_dialog.visible and main.status_label.text.contains("保存或取消"), "折点预览门禁必须先于存档故障检查并给出解决方式")

	# 未改变的折点编辑没有待保存内容，不应被共同门禁误判；显式取消 dirty 预览后恢复正常关闭。
	board.cancel_player_stroke_point_edit()
	_expect(board.begin_player_stroke_point_edit(stroke_id), "应能重新进入未变化折点编辑探针")
	_expect(main._guard_active_map_draft_before_interruption("继续"), "未变化的折点编辑不应被误判为未提交草稿")
	board.cancel_player_stroke_point_edit()
	main._save_writes_blocked = false
	main._save_write_block_reason = ""
	_expect(main._request_safe_quit(false), "明确取消地图草稿后安全关闭必须恢复")

	main.queue_free()
	await process_frame
	for path in isolated_paths:
		_remove_file(path)

	if failures.is_empty():
		print("M4_C4_MAP_DRAFT_LEAVE_GUARD_TEST_OK annotation=dialog_preserved stroke_setup=preserved drawing=zero+points_preserved point_edit=changed_preserved+clean_allowed leave=menu+title+wm_close schema=v18 formal_state=unchanged")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
