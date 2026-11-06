extends SceneTree

var failures: Array[String] = []
var capture_root := ""

func _init() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--release-artifacts="):
			capture_root = argument.trim_prefix("--release-artifacts=")
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _settle() -> void:
	for _frame in range(8):
		await process_frame

func _capture(name: String) -> void:
	if capture_root.is_empty():
		return
	if DisplayServer.get_name() == "headless":
		failures.append("截图需要图形渲染器")
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(capture_root)
	_expect(root.get_texture().get_image().save_png(capture_root.path_join(name + ".png")) == OK, "截图落盘：" + name)

func _run() -> void:
	if not OS.get_cmdline_user_args().has("--automated-test-mode"):
		push_error("发布检查必须使用隔离测试模式")
		quit(2)
		return
	root.size = Vector2i(1440, 900)
	var title = load("res://scenes/title_screen.tscn").instantiate()
	root.add_child(title)
	await _settle()
	_expect(title.start_button != null and not title.start_button.disabled, "标题开始入口可用")
	_expect(ResourceLoader.exists(title.COVER_PATH), "发布封面可加载")
	_expect(not root.has_node("_mcp_game_helper"), "发布副本不加载AI开发服务")
	await _capture("title_1440x900")
	title.queue_free()
	await process_frame
	var archive = load("res://scenes/character_archive.tscn").instantiate()
	root.add_child(archive)
	await _settle()
	archive.set_search_query("苏双")
	_expect(archive.get_visible_character_ids() == ["su_shuang"], "人物志搜索苏双")
	_expect(archive.select_character("su_shuang"), "人物志可选苏双")
	await _settle()
	await _capture("archive_su_shuang_1440x900")
	archive.queue_free()
	await process_frame
	var packed := load("res://scenes/main.tscn") as PackedScene
	var main = packed.instantiate()
	root.add_child(main)
	await _settle()
	_expect(main.automated_test_mode and main.characters.size() == 90, "主场景隔离加载90人")
	for scenario_id in ["blank_sandbox", "yellow_turban_liu_bei_184", "coalition_190", "warlords_196", "guandu_200", "red_cliffs_208"]:
		var candidate: Dictionary = main._build_scenario_template_candidate(scenario_id)
		_expect(bool(candidate.get("ok", false)), "开局必须可用：" + scenario_id)
	var guandu: Dictionary = main._build_scenario_template_candidate("guandu_200")
	_expect(bool(main._apply_scenario_candidate(guandu, "基础版测试", "发布检查").get("ok", false)), "官渡开局可实际创建")
	_expect(main.placements.size() == 20, "官渡预摆保持20人")
	main._on_character_dropped("su_shuang", Vector2(0.45, 0.48))
	var bookmark: Dictionary = main._create_named_snapshot("发布检查快照", "非用户正式存档")
	_expect(bool(bookmark.get("ok", false)), "快照保存")
	var entry := {"id": "chron_release_smoke", "entry_type": "note", "title": "援军计划", "time_label": "", "body": "苏双进入沙盘，准备下一步推演。", "created_at": "2026-11-06T12:00:00+08:00", "updated_at": "2026-11-06T12:00:00+08:00"}
	_expect(main._commit_chronicle_entries([entry], "发布纪事", "保存"), "纪事保存")
	main._on_undo_pressed()
	_expect(main.chronicle_entries.is_empty(), "纪事撤销")
	main._on_redo_pressed()
	_expect(main.chronicle_entries.size() == 1, "纪事重做")
	var placement_before: Dictionary = main.placements.duplicate(true)
	var identity_before: String = str(main.sandbox_metadata.get("sandbox_id", ""))
	var snapshot_count: int = main.named_snapshots.size()
	await _settle()
	await _capture("sandbox_guandu_1440x900")
	main._on_character_details_requested("su_shuang")
	await _settle()
	await _capture("detail_su_shuang_1440x900")
	main.queue_free()
	await process_frame
	var restarted = packed.instantiate()
	root.add_child(restarted)
	await _settle()
	_expect(restarted._placements_match(restarted.placements, placement_before), "重启人物ID、坐标与驻城保持")
	_expect(str(restarted.sandbox_metadata.get("sandbox_id", "")) == identity_before, "重启沙盘身份保持")
	_expect(restarted.chronicle_entries.size() == 1 and str(restarted.chronicle_entries[0].get("body", "")).contains("苏双"), "重启纪事正文保持")
	_expect(restarted.named_snapshots.size() == snapshot_count, "重启快照保持")
	restarted.queue_free()
	await process_frame
	if failures.is_empty():
		print("BASIC_RELEASE_TEST_OK title=loaded archive=90 search=pass scenarios=6 guandu=20 snapshot=pass chronicle=undo_redo restart=placements_identity_chronicle_snapshots capture=%s" % ("none" if capture_root.is_empty() else capture_root))
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
