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


func _snapshot_file(path: String) -> Dictionary:
	return {
		"exists": FileAccess.file_exists(path),
		"text": FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""
	}


func _same_snapshot(path: String, snapshot: Dictionary) -> bool:
	return bool(snapshot.get("exists", false)) == FileAccess.file_exists(path) \
		and str(snapshot.get("text", "")) == (FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else "")


func _run() -> void:
	var auto_paths := [
		"user://sandbox_save_automated_test.json",
		"user://backpack_preferences_automated_test.json",
		"user://sandbox_snapshots_automated_test.json",
		"user://personal_scenario_templates_automated_test.json"
	]
	for path in auto_paths:
		_remove_file(path)
	var formal_paths := [
		"user://sandbox_save.json",
		"user://backpack_preferences.json",
		"user://sandbox_snapshots.json",
		"user://personal_scenario_templates.json"
	]
	var formal_before: Dictionary = {}
	for path in formal_paths:
		formal_before[path] = _snapshot_file(path)

	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	current_scene = main
	await process_frame
	await process_frame
	_expect(main.automated_test_mode, "返回标题专项必须使用自动隔离路径")
	_expect(not auto_accept_quit, "进入主沙盘后必须由安全保存流程接管系统关闭请求")

	var luoyang_place: Dictionary = main._find_place("luoyang")
	main.placements = {
		"liu_bei": {
			"x": float(luoyang_place.get("x", 0.5)),
			"y": float(luoyang_place.get("y", 0.5)),
			"place_id": "luoyang"
		}
	}
	main._refresh_views()
	await process_frame
	_expect(main._return_to_title_screen(), "有效沙盘必须先保存再发起标题场景切换")
	for _frame in range(6):
		await process_frame

	var title_scene := current_scene
	_expect(title_scene != null and title_scene.scene_file_path == "res://scenes/title_screen.tscn", "局内返回必须到达标题场景")
	_expect(title_scene != null and title_scene.title_label != null and title_scene.title_label.text == "三国推演志", "返回后的封面必须显示当前暂定名称")
	_expect(auto_accept_quit, "返回标题页后必须恢复 SceneTree 默认退出策略")
	var isolated_save := "user://sandbox_save_automated_test.json"
	_expect(FileAccess.file_exists(isolated_save), "返回标题前必须写入当前隔离沙盘")
	if FileAccess.file_exists(isolated_save):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(isolated_save))
		var saved_cards: Array = parsed.get("cards", []) if parsed is Dictionary else []
		var saved_character_ids := PackedStringArray()
		for card_value in saved_cards:
			if card_value is Dictionary:
				saved_character_ids.append(str(card_value.get("character_id", "")))
		_expect("liu_bei" in saved_character_ids, "返回标题前的保存必须包含最新人物位置")

	if title_scene != null:
		title_scene.queue_free()
	await process_frame
	for path in formal_paths:
		_expect(_same_snapshot(path, formal_before[path]), "返回标题专项不得改变正式文件：%s" % path)
	for path in auto_paths:
		_remove_file(path)

	if failures.is_empty():
		print("RETURN_TO_TITLE_SCREEN_TEST_OK save=before_transition scene=title quit_policy=restored name=三国推演志 formal_state=unchanged")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
