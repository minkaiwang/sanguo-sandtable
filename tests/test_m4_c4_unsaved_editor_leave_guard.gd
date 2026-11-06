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
	_expect(main.automated_test_mode, "未提交草稿门禁专项必须使用自动隔离状态")
	_expect(main.SAVE_VERSION == 18 and main.character_catalog_version == 6, "离开门禁必须运行于 v18／目录 v6")
	_expect(not auto_accept_quit, "主沙盘必须继续由安全关闭流程接管系统关闭")
	main.chronicle_entries.clear()
	main.scenario_state = main._empty_scenario_state()
	main._undo_stack.clear()
	main._redo_stack.clear()
	_expect(main._save(), "离开门禁专项基线必须成功写入隔离存档")

	# 未提交纪事：系统关闭与返回标题都必须先进入既有放弃确认，且不得尝试写盘。
	main._open_new_chronicle_editor()
	await _wait_frames(2)
	main.chronicle_title_input.text = "尚未提交的纪事"
	main.chronicle_body_input.text = "这段文字必须留在编辑器里。"
	main._refresh_chronicle_editor_state()
	var chronicle_entries_before: Array = main.chronicle_entries.duplicate(true)
	var chronicle_history_before: Array = main._undo_stack.duplicate(true)
	var chronicle_save_before := _file_snapshot(main.save_path)
	main._save_writes_blocked = true
	main._save_write_block_reason = "草稿门禁顺序故障注入"
	main._primary_recovery_requires_reload = true
	main._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	await _wait_frames(2)
	_expect(is_instance_valid(main) and main.is_inside_tree(), "未提交纪事必须拒绝系统关闭并保留主沙盘")
	_expect(
		main.chronicle_editor_discard_confirmation_dialog.visible
		and not main.chronicle_editor_dialog.visible,
		"未提交纪事关闭请求必须复用既有放弃确认"
	)
	_expect(
		main.chronicle_title_input.text == "尚未提交的纪事"
		and main.chronicle_body_input.text == "这段文字必须留在编辑器里。",
		"拒绝关闭后必须原样保留纪事标题与正文"
	)
	_expect(
		main.chronicle_entries == chronicle_entries_before
		and main._undo_stack == chronicle_history_before
		and _file_snapshot(main.save_path) == chronicle_save_before,
		"拒绝关闭不得写纪事、历史或存档"
	)
	_expect(not main.message_dialog.visible, "纪事草稿门禁必须发生在存档写保护检查之前")

	main._return_to_chronicle_editor()
	await _wait_frames(2)
	_expect(main.chronicle_editor_dialog.visible, "选择继续编辑后必须回到原纪事草稿")
	_expect(not main._return_to_title_screen(), "未提交纪事也必须阻止返回标题")
	await _wait_frames(2)
	_expect(current_scene == main and main.chronicle_editor_discard_confirmation_dialog.visible, "返回标题被拒绝后必须留在当前主沙盘并再次显示放弃确认")

	# 保存草稿后应恢复正常离开能力。
	main._primary_recovery_requires_reload = false
	main._save_writes_blocked = false
	main._save_write_block_reason = ""
	main._return_to_chronicle_editor()
	await _wait_frames(2)
	main._confirm_chronicle_editor()
	await _wait_frames(4)
	_expect(main.chronicle_entries.size() == 1 and str(main.chronicle_entries[0].get("title", "")) == "尚未提交的纪事", "明确保存后必须把纪事提交到既有七字段状态")
	_expect(main._request_safe_quit(false), "纪事保存后安全关闭必须恢复")

	# 上下文系统预填是草稿基线；玩家未改动时不能误报为 dirty。
	main._open_new_chronicle_editor({
		"kind": "test_prefill",
		"prefill_body": "地点：洛阳\n\n",
	})
	await _wait_frames(2)
	_expect(not main._chronicle_editor_has_changes(), "系统预填且玩家未修改时必须保持 clean")
	main._save_writes_blocked = true
	main._save_write_block_reason = "clean 预填写盘探针"
	var clean_original: Dictionary = main._chronicle_editor_original.duplicate(true)
	var clean_context: Dictionary = main._chronicle_editor_return_context.duplicate(true)
	var clean_save := _file_snapshot(main.save_path)
	var clean_history: Array = main._undo_stack.duplicate(true)
	for leave_route in ["quit", "title"]:
		var left: bool = main._request_safe_quit(false) if leave_route == "quit" else main._return_to_title_screen()
		_expect(not left, "clean 预填保存失败必须拒绝离开：%s" % leave_route)
		await process_frame
		_expect(main.message_dialog.visible and not main.chronicle_editor_dialog.visible and not main.chronicle_editor_discard_confirmation_dialog.visible, "错误提示必须独占显示，不与 clean 编辑器争用弹窗")
		main.message_dialog.hide()
		await _wait_frames(3)
		_expect(main.chronicle_editor_dialog.visible and main.chronicle_body_input.text == "地点：洛阳\n\n", "关闭错误必须返回原纪事预填正文")
		_expect(main._chronicle_editor_original == clean_original and main._chronicle_editor_return_context == clean_context, "失败提示往返必须保留原稿和导航上下文")
		_expect(_file_snapshot(main.save_path) == clean_save and main._undo_stack == clean_history, "失败离开不得写盘或新增历史")
	main._save_writes_blocked = false
	main._save_write_block_reason = ""
	_expect(main._request_safe_quit(false), "clean 系统预填必须允许正常安全关闭")
	main.chronicle_editor_dialog.hide()
	main._cancel_chronicle_editor()
	await _wait_frames(3)
	if main.chronicle_dialog != null:
		main.chronicle_dialog.hide()

	# 未应用玩法分组：pending 状态必须保留，继续编辑和明确放弃都沿用现有流程。
	main.scenario_state = main._empty_scenario_state()
	_expect(main._save(), "玩法分组草稿基线必须成功写入隔离存档")
	main._open_scenario_editor()
	await _wait_frames(2)
	var clean_pending: Dictionary = main._pending_scenario_editor_state.duplicate(true)
	var clean_scenario_save := _file_snapshot(main.save_path)
	main._save_writes_blocked = true
	main._save_write_block_reason = "clean 分组写盘探针"
	for leave_route in ["quit", "title"]:
		var left: bool = main._request_safe_quit(false) if leave_route == "quit" else main._return_to_title_screen()
		_expect(not left, "clean 分组保存失败必须拒绝离开：%s" % leave_route)
		await process_frame
		_expect(main.message_dialog.visible and not main.scenario_editor_dialog.visible, "clean 分组必须为错误提示让位")
		main.message_dialog.hide()
		await _wait_frames(3)
		_expect(main.scenario_editor_dialog.visible and main._pending_scenario_editor_state == clean_pending, "关闭错误必须恢复同一分组编辑状态")
		_expect(_file_snapshot(main.save_path) == clean_scenario_save, "clean 分组失败退出不得写盘")
	main._save_writes_blocked = false
	main._save_write_block_reason = ""
	var pending_scenario: Dictionary = main._empty_scenario_state()
	pending_scenario["factions"] = [{"id": "play_leave_guard", "name": "未应用分组", "color": "#0077BB"}]
	pending_scenario["character_assignments"] = [{"character_id": "liu_bei", "faction_id": "play_leave_guard"}]
	main._pending_scenario_editor_state = pending_scenario.duplicate(true)
	main._pending_scenario_faction_id = "play_leave_guard"
	main._refresh_scenario_editor("play_leave_guard")
	await _wait_frames(2)
	var scenario_state_before: Dictionary = main.scenario_state.duplicate(true)
	var scenario_history_before: Array = main._undo_stack.duplicate(true)
	var scenario_save_before := _file_snapshot(main.save_path)
	main._save_writes_blocked = true
	main._save_write_block_reason = "玩法分组草稿门禁顺序故障注入"
	_expect(not main._request_safe_quit(false), "未应用玩法分组必须拒绝系统关闭")
	await _wait_frames(2)
	_expect(
		main.scenario_editor_discard_confirmation_dialog.visible
		and not main.scenario_editor_dialog.visible,
		"未应用玩法分组关闭请求必须复用既有放弃确认"
	)
	_expect(main._pending_scenario_editor_state == pending_scenario, "拒绝关闭后必须原样保留玩法分组 pending 状态")
	_expect(
		main.scenario_state == scenario_state_before
		and main._undo_stack == scenario_history_before
		and _file_snapshot(main.save_path) == scenario_save_before,
		"拒绝关闭不得提交分组、历史或存档"
	)
	_expect(not main.message_dialog.visible, "玩法分组草稿门禁必须发生在存档写保护检查之前")

	main._return_to_scenario_editor()
	await _wait_frames(2)
	_expect(main.scenario_editor_dialog.visible and main._pending_scenario_editor_state == pending_scenario, "选择继续编辑后必须恢复同一玩法分组草稿")
	_expect(not main._return_to_title_screen(), "未应用玩法分组也必须阻止返回标题")
	await _wait_frames(2)
	_expect(current_scene == main and main.scenario_editor_discard_confirmation_dialog.visible, "玩法分组阻断返回标题后必须留在当前主沙盘")
	main.scenario_editor_discard_confirmation_dialog.hide()
	main._confirm_discard_scenario_editor()
	_expect(main._pending_scenario_editor_state.is_empty() and main.scenario_state == scenario_state_before, "明确放弃后必须只清空 pending 状态，不改当前分组")
	main._save_writes_blocked = false
	main._save_write_block_reason = ""
	_expect(main._request_safe_quit(false), "明确放弃玩法分组后安全关闭必须恢复")

	# 活动推演是未持久化的流程态：关闭与返回标题必须在写盘前阻断，并引导显式结束或取消。
	main._on_character_dropped("liu_bei", Vector2(0.32, 0.42))
	main.map_board._clear_map_selection()
	_expect(main._save(), "活动推演离开门禁基线必须成功写入隔离存档")
	main._open_simulation_session_start_dialog()
	main.simulation_session_name_input.text = "离开保护推演"
	main.simulation_session_start_dialog.hide()
	main._confirm_start_simulation_session()
	await _wait_frames(2)
	_expect(not main.active_simulation_session.is_empty(), "活动推演离开门禁必须从真实开始流程建立会话态")
	var session_move: Dictionary = main.placements.duplicate(true)
	session_move["liu_bei"] = {"x": 0.51, "y": 0.53, "place_id": "luoyang"}
	_expect(main._commit_placements(session_move, "活动推演离开保护移动", "已移动"), "活动推演期间的地图改动必须先按既有原子路径提交")
	var active_session_before: Dictionary = main.active_simulation_session.duplicate(true)
	var session_placements_before: Dictionary = main.placements.duplicate(true)
	var session_snapshots_before: Array = main.named_snapshots.duplicate(true)
	var session_undo_before: Array = main._undo_stack.duplicate(true)
	var session_redo_before: Array = main._redo_stack.duplicate(true)
	var session_save_before := _file_snapshot(main.save_path)
	main._save_writes_blocked = true
	main._save_write_block_reason = "活动推演门禁顺序故障注入"
	main._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	await _wait_frames(2)
	_expect(is_instance_valid(main) and main.is_inside_tree(), "活动推演必须拒绝系统关闭并保留主沙盘")
	_expect(
		main.simulation_session_cancel_dialog.visible
		and "结束并复盘" in main.status_label.text
		and "取消助手" in main.status_label.text,
		"活动推演关闭请求必须给出结束复盘或显式取消的现有入口"
	)
	_expect(
		main.active_simulation_session == active_session_before
		and main.placements == session_placements_before
		and main.named_snapshots == session_snapshots_before
		and main._undo_stack == session_undo_before
		and main._redo_stack == session_redo_before
		and _file_snapshot(main.save_path) == session_save_before,
		"拒绝关闭后必须原样保留活动会话、地图、快照、历史和存档字节"
	)
	_expect(not main.message_dialog.visible, "活动推演门禁必须发生在存档写保护检查之前")
	_expect(not main._return_to_title_screen(), "活动推演也必须阻止直接返回标题")
	await _wait_frames(2)
	_expect(
		current_scene == main
		and main.simulation_session_cancel_dialog.visible
		and main.active_simulation_session == active_session_before,
		"活动推演阻断返回标题后必须留在当前主沙盘并保留同一会话"
	)
	main.simulation_session_cancel_dialog.hide()
	main._confirm_cancel_simulation_session()
	_expect(main.active_simulation_session.is_empty(), "明确取消助手后必须只结束活动会话态")
	_expect(
		main.placements == session_placements_before
		and main.named_snapshots == session_snapshots_before
		and main._undo_stack == session_undo_before
		and main._redo_stack == session_redo_before,
		"明确取消助手必须保留地图改动、起点快照及既有撤销历史"
	)
	main._save_writes_blocked = false
	main._save_write_block_reason = ""
	_expect(main._request_safe_quit(false), "明确取消活动推演助手后安全关闭必须恢复")

	# 两类草稿都已解决后，真实返回标题仍走原保存与退出策略。
	_expect(main._return_to_title_screen(), "保存／放弃草稿并取消活动助手后必须能够正常返回标题")
	await _wait_frames(7)
	var title_scene := current_scene
	_expect(title_scene != null and title_scene.scene_file_path == "res://scenes/title_screen.tscn", "草稿处理完毕后必须到达标题场景")
	_expect(auto_accept_quit, "返回标题后必须继续恢复 SceneTree 默认退出策略")

	if title_scene != null:
		title_scene.queue_free()
	await process_frame
	for path in isolated_paths:
		_remove_file(path)

	if failures.is_empty():
		print("M4_C4_UNSAVED_EDITOR_LEAVE_GUARD_TEST_OK chronicle=dirty_preserved+save scenario=pending_preserved+discard simulation=active_preserved+explicit_cancel prefill=clean clean_failure=exclusive_message_then_same_editor_2x2 reload_gate=after_draft_guard leave=wm_close+title schema=v18 formal_state=unchanged")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
