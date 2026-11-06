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


func _remove_empty_dir(path: String) -> void:
	var absolute_path := ProjectSettings.globalize_path(path)
	if DirAccess.dir_exists_absolute(absolute_path):
		DirAccess.remove_absolute(absolute_path)


func _scenario_state_initial() -> Dictionary:
	return {
		"scenario_id": "custom_blank",
		"start_year": null,
		"era_label": "完全自定义",
		"scenario_kind": "custom",
		"featured_character_ids": [],
		"history_layer_ids": [],
		"factions": [
			{"id": "play_quick_liu", "name": "刘备一行", "color": "#0077BB"},
			{"id": "play_quick_old", "name": "旧势力", "color": "#CC3311"},
		],
		"character_assignments": [
			{"character_id": "liu_bei", "faction_id": "play_quick_liu"},
			{"character_id": "zhang_fei", "faction_id": "play_quick_old"},
		],
		"city_ownership": [
			{"place_id": "luoyang", "faction_id": "play_quick_liu"},
		],
	}


func _scenario_state_changed() -> Dictionary:
	return {
		"scenario_id": "custom_blank",
		"start_year": null,
		"era_label": "完全自定义",
		"scenario_kind": "custom",
		"featured_character_ids": [],
		"history_layer_ids": [],
		"factions": [
			{"id": "play_quick_liu", "name": "蜀汉先声", "color": "#33AA77"},
			{"id": "play_quick_cao", "name": "曹操一行", "color": "#EE7733"},
		],
		"character_assignments": [
			{"character_id": "liu_bei", "faction_id": "play_quick_cao"},
			{"character_id": "guan_yu", "faction_id": "play_quick_cao"},
			{"character_id": "zhang_fei", "faction_id": "play_quick_liu"},
		],
		"city_ownership": [
			{"place_id": "luoyang", "faction_id": "play_quick_cao"},
			{"place_id": "changan", "faction_id": "play_quick_liu"},
		],
	}


func _annotation(annotation_id: String, label: String, x: float) -> Dictionary:
	return {
		"id": annotation_id,
		"marker_type": "note",
		"semantic_layer": "player_authored",
		"verification_status": "not_project_verified",
		"x": x,
		"y": 0.4,
		"label": label,
		"style": "amber",
	}


func _stroke(stroke_id: String, label: String, stroke_type: String = "plan") -> Dictionary:
	return {
		"id": stroke_id,
		"stroke_type": stroke_type,
		"label": label,
		"points": [{"x": 0.2, "y": 0.2}, {"x": 0.4, "y": 0.4}],
		"created_at": "2026-08-06T07:00:00",
		"updated_at": "2026-08-06T07:00:00",
	}


func _run() -> void:
	var auto_save := "user://sandbox_save_automated_test.json"
	var auto_snapshots := "user://sandbox_snapshots_automated_test.json"
	var blocked_save_dir := "user://quick_bookmark_blocked_save_automated_test"
	var blocked_store_dir := "user://quick_bookmark_blocked_store_automated_test"
	for path in [auto_save, auto_snapshots]:
		_remove_file(path)
	_remove_empty_dir(blocked_save_dir)
	_remove_empty_dir(blocked_store_dir)

	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_expect(main.automated_test_mode and main.snapshot_store_path == auto_snapshots, "快速留存必须使用自动测试隔离路径")
	var popup: PopupMenu = main.sandbox_file_menu.get_popup()
	var quick_item_index := popup.get_item_index(main.QUICK_SITUATION_BOOKMARK_MENU_ID)
	_expect(quick_item_index >= 0 and popup.get_item_text(quick_item_index) == "留住此刻    Ctrl+Shift+S", "沙盘菜单必须显示一键“留住此刻”及 Ctrl+Shift+S 提示")

	main.placements = {
		"liu_bei": {"x": 0.2, "y": 0.3, "place_id": "luoyang"},
		"zhang_fei": {"x": 0.3, "y": 0.4},
	}
	main.annotations = {
		"marker_old": _annotation("marker_old", "旧标记", 0.25),
		"marker_change": _annotation("marker_change", "待改标记", 0.35),
	}
	main.player_strokes.clear()
	main.player_strokes.append(_stroke("stroke_old", "旧路线"))
	main.player_strokes.append(_stroke("stroke_change", "待改路线"))
	main.scenario_state = _scenario_state_initial()
	main.character_actions.clear()
	main.character_troops.clear()
	main._refresh_views()
	var initial_validation: Dictionary = main._validate_sandbox_payload_for_write(main._build_sandbox_payload(), true)
	_expect(bool(initial_validation.get("ok", false)), "首次快速留存夹具必须先通过正式写前校验：%s" % str(initial_validation))

	var first_history := JSON.stringify(main._undo_stack)
	var first_redo := JSON.stringify(main._redo_stack)
	var first_camera: Dictionary = main.map_board.get_camera_state().duplicate(true)
	var first_result: Dictionary = main._create_quick_situation_bookmark({
		"month": 8, "day": 6, "hour": 7, "minute": 21, "second": 3,
	})
	_expect(bool(first_result.get("ok", false)), "首次留住此刻应安全建立现有格式命名快照：%s" % str(first_result))
	var first_record: Dictionary = first_result.get("snapshot", {})
	var first_id := str(first_record.get("snapshot_id", ""))
	_expect(str(first_record.get("name", "")) == "8月6日 07:21:03 的局面", "自动名称必须包含秒，支持同一分钟连续留存")
	_expect(str(first_record.get("note", "")) == "首次留存：人物2、势力2、归属城池1、标记2、推演线2。", "首次留存应使用当前结构计数摘要")
	_expect(first_record.size() == 5 and first_record.has("snapshot_id") and first_record.has("name") and first_record.has("note") and first_record.has("created_at") and first_record.has("sandbox"), "快速留存不得扩张快照库 v1 记录结构")
	_expect(JSON.stringify(main._undo_stack) == first_history and JSON.stringify(main._redo_stack) == first_redo and main.map_board.get_camera_state() == first_camera, "快速留存不得污染撤销、重做或镜头")

	var manual_result: Dictionary = main._create_named_snapshot("人工阶段", "手工命名快照也应成为同沙盘基线。")
	var manual_id := str(manual_result.get("snapshot", {}).get("snapshot_id", ""))
	_expect(bool(manual_result.get("ok", false)) and not manual_id.is_empty(), "专项夹具必须建立同沙盘手工快照：%s" % str(manual_result))

	main.placements = {
		"liu_bei": {"x": 0.42, "y": 0.52, "place_id": "changan"},
		"guan_yu": {"x": 0.55, "y": 0.45},
	}
	main.annotations = {
		"marker_change": _annotation("marker_change", "已改标记", 0.36),
		"marker_new": _annotation("marker_new", "新标记", 0.45),
	}
	main.player_strokes.clear()
	main.player_strokes.append(_stroke("stroke_change", "已改路线", "advance"))
	main.player_strokes.append(_stroke("stroke_new", "新路线", "reinforcement"))
	main.scenario_state = _scenario_state_changed()
	main.character_actions = {"liu_bei": "attack"}
	main.character_troops = {"liu_bei": 5000}
	main.active_simulation_session = {
		"session_id": "session_quick_test",
		"name": "中途节点",
		"session_type": "advance",
		"baseline": {},
	}
	var changed_validation: Dictionary = main._validate_sandbox_payload_for_write(main._build_sandbox_payload(), true)
	_expect(bool(changed_validation.get("ok", false)), "变化后的快速留存夹具必须通过正式写前校验：%s" % str(changed_validation))
	var active_session_before := JSON.stringify(main.active_simulation_session)
	var contract: Dictionary = main._build_quick_situation_bookmark_contract({
		"month": 8, "day": 6, "hour": 7, "minute": 22, "second": 4,
	})
	_expect(bool(contract.get("has_baseline", false)) and str(contract.get("baseline_snapshot_id", "")) == manual_id, "应逆序选择最近的同沙盘快照，不依赖快照名称")
	var change_note := str(contract.get("note", ""))
	for expected_token in ["摆出1", "收回1", "移动1", "兵力1", "行动1", "编组3", "城池2", "势力+1/-1/改1", "标记+1/-1/改1", "推演线+1/-1/改1"]:
		_expect(change_note.contains(expected_token), "紧凑摘要缺少变化：%s；实际：%s" % [expected_token, change_note])
	_expect(change_note.length() <= main.MAX_SNAPSHOT_NOTE_LENGTH, "自动变化摘要不得超过既有 120 字备注上限")
	var second_result: Dictionary = main._create_quick_situation_bookmark({
		"month": 8, "day": 6, "hour": 7, "minute": 22, "second": 4,
	})
	_expect(bool(second_result.get("ok", false)) and str(second_result.get("snapshot", {}).get("note", "")) == change_note, "活动推演中也应允许留住中途节点：%s" % str(second_result))
	_expect(JSON.stringify(main.active_simulation_session) == active_session_before, "快速留存不得结束、改写或隐藏活动推演")

	var third_result: Dictionary = main._create_quick_situation_bookmark({
		"month": 8, "day": 6, "hour": 7, "minute": 22, "second": 5,
	})
	_expect(bool(third_result.get("ok", false)) and str(third_result.get("snapshot", {}).get("note", "")) == "较上次留存：未检测到结构变化。", "无变化时仍应允许留下明确节点：%s" % str(third_result))
	_expect(str(third_result.get("snapshot", {}).get("name", "")) != str(second_result.get("snapshot", {}).get("name", "")), "连续秒级留存名称必须可区分")

	var count_before_busy: int = main.named_snapshots.size()
	main.city_ownership_tool_active = true
	main._on_sandbox_file_menu_pressed(main.QUICK_SITUATION_BOOKMARK_MENU_ID)
	_expect(main.named_snapshots.size() == count_before_busy and main.city_ownership_tool_active, "连续设置或地图草稿未完成时不得静默取消并创建快照")
	_expect(main.status_label.text.contains("先完成或取消"), "临时工具阻止快速留存时必须给出明确状态提示")
	main.city_ownership_tool_active = false

	var current_id := str(main.sandbox_metadata.get("sandbox_id", ""))
	main.sandbox_metadata["sandbox_id"] = "sandbox_quick_other_001"
	var cross_contract: Dictionary = main._build_quick_situation_bookmark_contract({
		"month": 8, "day": 6, "hour": 7, "minute": 23, "second": 1,
	})
	_expect(not bool(cross_contract.get("has_baseline", true)) and str(cross_contract.get("note", "")).begins_with("首次留存："), "其他沙盘或分支的快照不得被用作变化基线")
	main.sandbox_metadata["sandbox_id"] = current_id

	var store_before_failure := FileAccess.get_file_as_string(auto_snapshots)
	var count_before_failure: int = main.named_snapshots.size()
	main._save_writes_blocked = true
	var blocked_save_result: Dictionary = main._create_quick_situation_bookmark({"month": 8, "day": 6, "hour": 7, "minute": 24, "second": 1})
	main._save_writes_blocked = false
	_expect(not bool(blocked_save_result.get("ok", true)) and main.named_snapshots.size() == count_before_failure and FileAccess.get_file_as_string(auto_snapshots) == store_before_failure, "当前沙盘保存失败时不得尝试追加快照")

	main._snapshot_writes_blocked = true
	main._snapshot_write_block_reason = "测试写保护"
	var protected_store_result: Dictionary = main._create_quick_situation_bookmark({"month": 8, "day": 6, "hour": 7, "minute": 24, "second": 2})
	main._snapshot_writes_blocked = false
	main._snapshot_write_block_reason = ""
	_expect(not bool(protected_store_result.get("ok", true)) and main.named_snapshots.size() == count_before_failure and FileAccess.get_file_as_string(auto_snapshots) == store_before_failure, "快照库写保护必须保持内存和原文件不变")

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(blocked_store_dir))
	var normal_store_path: String = main.snapshot_store_path
	main.snapshot_store_path = blocked_store_dir
	var blocked_store_result: Dictionary = main._create_quick_situation_bookmark({"month": 8, "day": 6, "hour": 7, "minute": 24, "second": 3})
	main.snapshot_store_path = normal_store_path
	_expect(not bool(blocked_store_result.get("ok", true)) and main.named_snapshots.size() == count_before_failure, "快照目标写盘失败不得增加内存记录")

	if main.named_snapshots.is_empty():
		failures.append("前置快照均未建立，无法执行 50 条上限夹具")
	else:
		var sample_record: Dictionary = main.named_snapshots[0].duplicate(true)
		var limit_records: Array[Dictionary] = []
		for index in range(main.SNAPSHOT_LIMIT):
			var copy := sample_record.duplicate(true)
			copy["snapshot_id"] = "snapshot_quick_limit_%03d" % index
			limit_records.append(copy)
		main.named_snapshots = limit_records
		main._save_writes_blocked = true
		var limit_result: Dictionary = main._create_quick_situation_bookmark({"month": 8, "day": 6, "hour": 7, "minute": 25, "second": 1})
		main._save_writes_blocked = false
		_expect(not bool(limit_result.get("ok", true)) and str(limit_result.get("message", "")).contains("50") and main.named_snapshots.size() == main.SNAPSHOT_LIMIT, "达到 50 条上限时应先拒绝，不依赖主存档写入")

	main.queue_free()
	await process_frame
	for path in [auto_save, auto_snapshots]:
		_remove_file(path)
	_remove_empty_dir(blocked_save_dir)
	_remove_empty_dir(blocked_store_dir)

	if failures.is_empty():
		print("QUICK_SITUATION_BOOKMARK_TEST_OK store=v1 baseline=same-sandbox summary=bounded transient=preserved failures=non-destructive")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
