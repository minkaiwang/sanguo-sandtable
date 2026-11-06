extends Node

@onready var root: Window = get_tree().root
var failures: Array[String] = []
var capture_root := ""

func _ready() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--release-artifacts="):
			capture_root = argument.trim_prefix("--release-artifacts=")
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _settle() -> void:
	for _frame in range(8):
		await get_tree().process_frame

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
		get_tree().quit(2)
		return
	var title = load("res://scenes/title_screen.tscn").instantiate()
	root.add_child(title)
	get_tree().current_scene = title
	await _settle()
	for viewport_size in [Vector2i(1280, 720), Vector2i(1440, 900)]:
		root.size = viewport_size
		await _settle()
		_expect(title.start_button != null and not title.start_button.disabled, "标题开始入口可用")
		_expect(root.get_visible_rect().encloses(title.start_button.get_global_rect()), "开始按钮位于视口内")
		await _capture("title_%dx%d" % [viewport_size.x, viewport_size.y])
	_expect(ResourceLoader.exists(title.COVER_PATH), "发布封面可加载")
	_expect(not root.has_node("_mcp_game_helper"), "发布副本不加载AI开发服务")
	title.about_button.pressed.emit()
	await _settle()
	_expect(title.about_dialog.visible, "说明按钮可用")
	await _capture("about_1440x900")
	title.about_dialog.hide()
	title.settings_button.pressed.emit()
	await _settle()
	title.vsync_toggle.button_pressed = not title.vsync_toggle.button_pressed
	var chosen_vsync: bool = title.vsync_toggle.button_pressed
	title.settings_dialog.get_ok_button().pressed.emit()
	await _settle()
	_expect(not title.settings_dialog.visible, "设置应用后关闭窗口")
	title.character_archive_button.pressed.emit()
	await _settle()
	var archive = get_tree().current_scene
	_expect(archive.scene_file_path == "res://scenes/character_archive.tscn", "人物志按钮完成场景切换")
	archive.set_search_query("苏双")
	_expect(archive.get_visible_character_ids() == ["su_shuang"], "人物志搜索苏双")
	_expect(archive.select_character("su_shuang"), "人物志可选苏双")
	await _settle()
	await _capture("archive_su_shuang_1440x900")
	archive.return_button.pressed.emit()
	await _settle()
	title = get_tree().current_scene
	_expect(title.scene_file_path == "res://scenes/title_screen.tscn", "人物志返回标题")
	_expect(bool(title._settings.get("vsync")) == chosen_vsync, "重新进入标题保持显示设置")
	title.new_sandbox_button.pressed.emit()
	await _settle()
	var main = get_tree().current_scene
	_expect(main.automated_test_mode and main.characters.size() == 90, "主场景隔离加载90人")
	_expect(main.new_sandbox_dialog.visible, "选择开局按钮实际打开开局窗口")
	for template_id in ["blank_sandbox", "yellow_turban_liu_bei_184", "coalition_190", "warlords_196", "guandu_200", "red_cliffs_208"]:
		var candidate: Dictionary = main._build_scenario_template_candidate(template_id)
		_expect(bool(candidate.get("ok", false)), "开局必须可用：" + template_id)
	var guandu_index := -1
	for index in range(main.new_sandbox_list.item_count):
		if str(main.new_sandbox_list.get_item_metadata(index).get("id", "")) == "guandu_200":
			guandu_index = index
	_expect(guandu_index >= 0, "开局列表包含官渡")
	main.new_sandbox_list.select(guandu_index)
	main.new_sandbox_list.item_selected.emit(guandu_index)
	main.new_sandbox_title_input.text = "官渡演示"
	root.size = Vector2i(1280, 720)
	await _settle()
	main.new_sandbox_dialog.popup_centered(main.NEW_SANDBOX_DIALOG_SIZE)
	await _settle()
	_expect(root.get_visible_rect().encloses(Rect2(Vector2(main.new_sandbox_dialog.position), Vector2(main.new_sandbox_dialog.size))), "小窗口开局选择完整可见")
	await _capture("opening_guandu_1280x720")
	main.new_sandbox_dialog.get_ok_button().pressed.emit()
	await _settle()
	_expect(main.new_sandbox_confirmation_dialog.visible, "新建开局先确认")
	_expect(root.get_visible_rect().encloses(Rect2(Vector2(main.new_sandbox_confirmation_dialog.position), Vector2(main.new_sandbox_confirmation_dialog.size))), "小窗口开局确认完整可见")
	await _capture("opening_confirmation_1280x720")
	main.new_sandbox_confirmation_dialog.get_ok_button().pressed.emit()
	await _settle()
	_expect(main.placements.size() == 20 and str(main.scenario_state.get("scenario_id", "")) == "guandu_200", "官渡按钮流程实际创建20人开局")
	main._on_character_dropped("su_shuang", Vector2(0.45, 0.48))
	var bookmark_count: int = main.named_snapshots.size()
	var bookmark_event := InputEventKey.new()
	bookmark_event.keycode = KEY_S
	bookmark_event.ctrl_pressed = true
	bookmark_event.shift_pressed = true
	bookmark_event.pressed = true
	main._unhandled_key_input(bookmark_event)
	_expect(main.named_snapshots.size() == bookmark_count + 1, "Ctrl+Shift+S保存快照")
	var chronicle_event := InputEventKey.new()
	chronicle_event.keycode = KEY_J
	chronicle_event.ctrl_pressed = true
	chronicle_event.pressed = true
	main._unhandled_key_input(chronicle_event)
	await _settle()
	_expect(main.chronicle_dialog.visible, "Ctrl+J打开纪事")
	main.chronicle_add_button.pressed.emit()
	await _settle()
	main.chronicle_title_input.text = "援军计划"
	main.chronicle_body_input.text = "苏双进入沙盘，准备下一步推演。"
	main._refresh_chronicle_editor_state()
	main.chronicle_editor_dialog.get_ok_button().pressed.emit()
	await _settle()
	_expect(main.chronicle_entries.size() == 1, "纪事按钮保存")
	main.chronicle_dialog.get_ok_button().pressed.emit()
	await _settle()
	_expect(not main.chronicle_dialog.visible, "纪事关闭按钮收起弹窗")
	main._on_undo_pressed()
	_expect(main.chronicle_entries.is_empty(), "纪事撤销")
	main._on_redo_pressed()
	_expect(main.chronicle_entries.size() == 1, "纪事重做")
	var placement_before: Dictionary = main.placements.duplicate(true)
	var identity_before: String = str(main.sandbox_metadata.get("sandbox_id", ""))
	var snapshot_count: int = main.named_snapshots.size()
	for viewport_size in [Vector2i(1280, 720), Vector2i(1440, 900)]:
		root.size = viewport_size
		await _settle()
		await _capture("sandbox_guandu_%dx%d" % [viewport_size.x, viewport_size.y])
	main._on_character_details_requested("su_shuang")
	for viewport_size in [Vector2i(1280, 720), Vector2i(1440, 900)]:
		root.size = viewport_size
		await _settle()
		main._on_character_details_requested("su_shuang")
		await _settle()
		await _capture("detail_su_shuang_%dx%d" % [viewport_size.x, viewport_size.y])
	main.character_detail_dialog.hide()
	main._on_character_detail_dialog_closed()
	main.sandbox_file_menu.get_popup().id_pressed.emit(12)
	await _settle()
	title = get_tree().current_scene
	_expect(title.scene_file_path == "res://scenes/title_screen.tscn", "沙盘菜单返回标题")
	_expect(title.start_button.text == "继续当前沙盘", "标题识别已保存沙盘")
	title.start_button.pressed.emit()
	await _settle()
	var restarted = get_tree().current_scene
	_expect(restarted._placements_match(restarted.placements, placement_before), "继续沙盘后人物ID、坐标与驻城保持")
	_expect(str(restarted.sandbox_metadata.get("sandbox_id", "")) == identity_before, "继续沙盘后身份保持")
	_expect(restarted.chronicle_entries.size() == 1 and str(restarted.chronicle_entries[0].get("body", "")).contains("苏双"), "继续沙盘后纪事正文保持")
	_expect(restarted.named_snapshots.size() == snapshot_count, "继续沙盘后快照保持")
	restarted.queue_free()
	await get_tree().process_frame
	if failures.is_empty():
		print("BASIC_RELEASE_TEST_OK menu_flow=title_archive_new_save_continue settings=persisted archive=90 scenarios=6 guandu=20 shortcut=snapshot chronicle=undo_redo restart=placements_identity_chronicle_snapshots")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)
