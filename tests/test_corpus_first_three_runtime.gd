extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _expect(value: bool, message: String) -> void:
	if not value:
		failures.append(message)

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_expect(main.automated_test_mode, "必须使用隔离模式")
	_expect(main.characters.size() == 90 and main.character_catalog_version == 6, "必须加载90人目录v6")
	var archive: Dictionary = load("res://src/character_archive_data.gd").new().load_archive()
	_expect(bool(archive.get("ok", false)) and archive.get("records", []).size() == 90, "人物志必须完整载入90人：%s" % archive.get("message", ""))
	main._on_character_dropped("liu_bei", Vector2(0.4, 0.5))
	var base: Dictionary = main._build_sandbox_payload()
	var title = load("res://scenes/title_screen.tscn").instantiate()
	for pair in [[14, 2], [15, 3], [16, 4], [17, 5]]:
		var legacy: Dictionary = base.duplicate(true)
		legacy["save_version"] = pair[0]
		legacy["character_catalog_version"] = pair[1]
		var decoded: Dictionary = main._decode_sandbox_document(legacy, false)
		_expect(bool(decoded.get("ok", false)) and bool(decoded.get("character_catalog_migration_required", false)), "旧目录须可迁移：%s %s" % [pair, decoded.get("message", "")])
		_expect(decoded.get("placements", {}).has("liu_bei"), "旧档解码不得丢失刘备")
		_expect(bool(title._preview_catalog_validation(legacy, pair[0]).get("ok", false)), "标题旧档组合必须兼容：%s" % str(pair))
	# Real v17 disk migration, with a nonempty placement and an exact raw backup.
	var old_payload: Dictionary = base.duplicate(true)
	old_payload["save_version"] = 17
	old_payload["character_catalog_version"] = 5
	var file := FileAccess.open(main.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(old_payload))
	file.close()
	var old_bytes := FileAccess.get_file_as_bytes(main.save_path)
	main._load_save()
	var migrated: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(main.save_path))
	_expect(int(migrated.get("save_version", 0)) == 18 and int(migrated.get("character_catalog_version", 0)) == 6, "真实v17文件必须升级为v18/v6")
	_expect(main.placements.has("liu_bei"), "真实迁移须保留摆位")
	var raw_found := false
	var raw_dir := DirAccess.open(main.backup_dir.path_join("migration_raw"))
	if raw_dir != null:
		for leaf in raw_dir.get_files():
			if FileAccess.get_file_as_bytes(main.backup_dir.path_join("migration_raw").path_join(leaf)) == old_bytes:
				raw_found = true
	_expect(raw_found, "必须保留旧档原字节备份")
	for entry in [["zou_jing", "邹靖"], ["zhang_shiping", "张世平"], ["su_shuang", "苏双"]]:
		var id: String = entry[0]
		main.backpack.set_search_query(entry[1])
		_expect(main.backpack.get_visible_character_ids().has(id), "必须可搜索：" + id)
		_expect(main.backpack.add_hand_candidate(id), "必须可拿取：" + id)
		main._on_character_dropped(id, Vector2(0.45, 0.48))
		_expect(main.placements.has(id), "必须可摆放：" + id)
		main._on_character_details_requested(id)
		_expect(main.character_detail_character_id == id, "必须可打开人物详情：" + id)
		main.character_detail_dialog.hide()
		main._on_character_detail_dialog_closed()
		main._on_character_returned(id)
		_expect(not main.placements.has(id), "必须可收回：" + id)
		main.backpack.remove_hand_candidate(id)
	var current: Dictionary = main._build_sandbox_payload()
	_expect(bool(main._decode_sandbox_document(current, false).get("ok", false)), "当前档必须可读")
	var future: Dictionary = current.duplicate(true)
	future["save_version"] = 19
	future["character_catalog_version"] = 7
	_expect(not bool(main._decode_sandbox_document(future, false).get("ok", true)), "未来档必须拒绝")
	title.free()
	main.queue_free()
	await process_frame
	if failures.is_empty():
		print("CORPUS_FIRST_THREE_RUNTIME_TEST_OK catalog=6/90 save=18 archive=90 legacy=14/15/16/17 migration=raw_backup new=search_take_place_detail_return future=rejected")
		quit(0)
	else:
		for message in failures:
			push_error(message)
		quit(1)
