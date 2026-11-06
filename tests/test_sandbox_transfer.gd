extends SceneTree

var failures: Array[String] = []
var created_backup_paths: Array[String] = []


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


func _snapshot_file(path: String) -> Dictionary:
	return {
		"exists": FileAccess.file_exists(path),
		"text": FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""
	}


func _same_snapshot(path: String, snapshot: Dictionary) -> bool:
	return bool(snapshot.get("exists", false)) == FileAccess.file_exists(path) and str(snapshot.get("text", "")) == (FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else "")


func _scenario_state_matches(first_value: Variant, second_value: Variant) -> bool:
	if not (first_value is Dictionary) or not (second_value is Dictionary):
		return false
	var first: Dictionary = first_value
	var second: Dictionary = second_value
	for contract_key in ["scenario_id", "start_year", "era_label", "scenario_kind"]:
		if not first.has(contract_key) or not second.has(contract_key) or first.get(contract_key) != second.get(contract_key):
			return false
	for contract_array_key in ["featured_character_ids", "history_layer_ids", "city_ownership"]:
		if not (first.get(contract_array_key, null) is Array) or not (second.get(contract_array_key, null) is Array) or first.get(contract_array_key) != second.get(contract_array_key):
			return false
	var first_factions_value: Variant = first.get("factions", null)
	var second_factions_value: Variant = second.get("factions", null)
	var first_assignments_value: Variant = first.get("character_assignments", null)
	var second_assignments_value: Variant = second.get("character_assignments", null)
	if not (first_factions_value is Array) or not (second_factions_value is Array) or not (first_assignments_value is Array) or not (second_assignments_value is Array):
		return false
	var first_factions := {}
	var second_factions := {}
	for faction_value in first_factions_value:
		if not (faction_value is Dictionary):
			return false
		first_factions[str(faction_value.get("id", ""))] = {"name": str(faction_value.get("name", "")), "color": str(faction_value.get("color", ""))}
	for faction_value in second_factions_value:
		if not (faction_value is Dictionary):
			return false
		second_factions[str(faction_value.get("id", ""))] = {"name": str(faction_value.get("name", "")), "color": str(faction_value.get("color", ""))}
	var first_assignments := {}
	var second_assignments := {}
	for assignment_value in first_assignments_value:
		if not (assignment_value is Dictionary):
			return false
		first_assignments[str(assignment_value.get("character_id", ""))] = str(assignment_value.get("faction_id", ""))
	for assignment_value in second_assignments_value:
		if not (assignment_value is Dictionary):
			return false
		second_assignments[str(assignment_value.get("character_id", ""))] = str(assignment_value.get("faction_id", ""))
	return first_factions == second_factions and first_assignments == second_assignments


func _empty_scenario_state() -> Dictionary:
	return {
		"scenario_id": "custom_blank",
		"start_year": null,
		"era_label": "完全自定义",
		"scenario_kind": "custom",
		"featured_character_ids": [],
		"history_layer_ids": [],
		"factions": [],
		"character_assignments": [],
		"city_ownership": []
	}


func _sample_scenario_state() -> Dictionary:
	return {
		"scenario_id": "custom_blank",
		"start_year": null,
		"era_label": "完全自定义",
		"scenario_kind": "custom",
		"featured_character_ids": [],
		"history_layer_ids": [],
		"factions": [{"id": "play_transfer_test", "name": "备份测试势力", "color": "#0077BB"}],
		"character_assignments": [
			{"character_id": "liu_bei", "faction_id": "play_transfer_test"},
			{"character_id": "guan_yu", "faction_id": "play_transfer_test"}
		],
		"city_ownership": []
	}


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		failures.append("测试夹具无法写入：%s" % path)
		return
	file.store_string(text)
	file.close()


func _run() -> void:
	var auto_save := "user://sandbox_save_automated_test.json"
	var auto_preferences := "user://backpack_preferences_v2_automated_test.json"
	var export_path := "user://sandbox_export_automated_test.tianxia"
	var import_path := "user://sandbox_import_automated_test.tianxia"
	var existing_path := "user://sandbox_existing_automated_test.tianxia"
	var invalid_path := "user://sandbox_invalid_automated_test.tianxia"
	var blocker_path := "user://backup_blocker_automated_test"
	var extensionless_path := "user://sandbox_extensionless_automated_test"
	var runtime_target_dir := "user://runtime_target_dir_automated_test"
	for path in [auto_save, auto_preferences, export_path, import_path, existing_path, invalid_path, blocker_path, extensionless_path + ".tianxia"]:
		_remove_file(path)
	_remove_empty_dir(runtime_target_dir)

	var formal_save := "user://sandbox_save.json"
	var formal_preferences := "user://backpack_preferences.json"
	var formal_save_before := _snapshot_file(formal_save)
	var formal_preferences_before := _snapshot_file(formal_preferences)

	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_expect(main.automated_test_mode, "专项测试必须运行在自动测试隔离模式")
	_expect(main.save_path == auto_save and main.preferences_path == auto_preferences, "自动测试不得使用正式存档或偏好路径")

	var luoyang: Dictionary = main._find_place("luoyang")
	main.placements = {
		"liu_bei": {"x": float(luoyang.get("x", 0.5)), "y": float(luoyang.get("y", 0.5)), "place_id": "luoyang"},
		"guan_yu": {"x": 0.31, "y": 0.47}
	}
	main.annotations = {
		"marker_2": {"id": "marker_2", "kind": "marker", "x": 0.60, "y": 0.42, "label": "粮道", "style": "amber"},
		"marker_1": {"id": "marker_1", "kind": "marker", "x": 0.40, "y": 0.52, "label": "援军", "style": "amber"}
	}
	main.scenario_state = _sample_scenario_state()
	main.character_states = {
		"liu_bei": {"state_schema": "four_dimensions_v1", "might": 86, "intelligence": 84, "leadership": 88, "charisma": 98},
		"guan_yu": {"state_schema": "four_dimensions_v1", "might": 99, "intelligence": 78, "leadership": 94, "charisma": 90}
	}
	main.favorite_character_ids = {"liu_bei": true}
	main.backpack.set_favorites(main.favorite_character_ids)
	main.map_board.zoom = 1.08
	main.map_board.pan = Vector2(-82, -44)
	main.map_board._apply_camera()
	main._refresh_views()
	main._save()

	var document: Dictionary = main._build_sandbox_document()
	_expect(str(document.get("format", "")) == "tianxia_sandbox_backup" and int(document.get("format_version", 0)) == 1, "备份应使用独立 v1 信封")
	var encoded := JSON.stringify(document)
	_expect(encoded.find("favorite_character_ids") == -1 and encoded.find("backpack_preferences") == -1, "备份不得包含人物收藏或偏好路径")
	for forbidden_map_token in ["\"source_ref\"", "\"source_locator\"", "\"crosscheck_ref\"", "\"coordinate_basis\"", "\"coordinate_note\"", "xiapi_archaeology_2014_2018", "chgis_tgaz", "thepaper_lujiang_gushu_site_2025", "res://data/map_places.json", "res://data/map_sources.json"]:
		_expect(encoded.find(forbidden_map_token) < 0, ".tianxia 只能携带玩家状态与稳定地点 ID，不得夹带地图来源记录：%s" % forbidden_map_token)
	var payload: Dictionary = document.get("sandbox", {})
	_expect(int(payload.get("save_version", 0)) == 18 and int(payload.get("character_catalog_version", 0)) == 6, "外部备份信封保持 v1，内部运行存档应为 v18／人物目录 v6")
	_expect(_scenario_state_matches(payload.get("scenario_state", {}), _sample_scenario_state()), "v18 备份必须携带完整稳定场景契约")
	_expect(payload.get("player_strokes", {}) == {"semantic_layer": "player_authored", "verification_status": "not_project_verified", "strokes": []}, "v18 备份必须携带严格空 player_strokes 根对象")
	_expect(payload.get("character_states", {}).get("records", []).size() == 2, "v18 备份必须携带严格本局人物属性")
	_expect(payload.get("cards", [])[0].get("character_id", "") == "guan_yu", "导出人物应按 ID 稳定排序")
	_expect(payload.get("annotations", [])[0].get("id", "") == "marker_1", "导出标记应按 ID 稳定排序")
	var injected_map_provenance := document.duplicate(true)
	injected_map_provenance["sandbox"] = (document.get("sandbox", {}) as Dictionary).duplicate(true)
	injected_map_provenance["sandbox"]["cards"] = (injected_map_provenance["sandbox"].get("cards", []) as Array).duplicate(true)
	injected_map_provenance["sandbox"]["cards"][0] = (injected_map_provenance["sandbox"]["cards"][0] as Dictionary).duplicate(true)
	injected_map_provenance["sandbox"]["cards"][0]["source_ref"] = "xiapi_archaeology_2014_2018"
	_expect(not bool(main._decode_sandbox_text(JSON.stringify(injected_map_provenance), true).get("ok", true)), ".tianxia 人物落点不得夹带地图来源字段")
	var injected_map_registry := document.duplicate(true)
	injected_map_registry["map_sources"] = [{"id": "xiapi_archaeology_2014_2018"}]
	_expect(not bool(main._decode_sandbox_text(JSON.stringify(injected_map_registry), true).get("ok", true)), ".tianxia v1 信封不得夹带未定义的地图来源记录")

	var write_result: Dictionary = main._write_sandbox_transfer_file(export_path, false)
	_expect(bool(write_result.get("ok", false)) and FileAccess.file_exists(export_path), "应能把当前沙盘备份到独立文件")
	var roundtrip: Dictionary = main._read_sandbox_transfer_file(export_path, true)
	_expect(bool(roundtrip.get("ok", false)), "刚导出的备份应能重新读取")
	_expect(main._placements_match(main.placements, roundtrip.get("placements", {})), "导出—读取应保留人物和 place_id")
	_expect(main._annotations_match(main.annotations, roundtrip.get("annotations", {})), "导出—读取应保留标记文字与位置")
	_expect(main._camera_states_match(main.map_board.get_camera_state(), roundtrip.get("camera", {})), "备份应保留地图视角")
	_expect(_scenario_state_matches(roundtrip.get("scenario_state", {}), main.scenario_state), "导出—读取应保留完整场景状态")
	_expect(roundtrip.get("character_states", {}) == main.character_states, "导出—读取应保留本局人物属性")

	_write_text(existing_path, "SENTINEL")
	var protected_result: Dictionary = main._write_sandbox_transfer_file(existing_path, false)
	_expect(str(protected_result.get("error_code", "")) == "target_exists", "未确认覆盖时应拒绝替换已有外部备份")
	_expect(FileAccess.get_file_as_string(existing_path) == "SENTINEL", "覆盖保护失败时原文件字节必须不变")
	var overwrite_result: Dictionary = main._write_sandbox_transfer_file(existing_path, true)
	_expect(bool(overwrite_result.get("ok", false)) and bool(main._read_sandbox_transfer_file(existing_path, true).get("ok", false)), "明确允许后才可原子覆盖外部备份")
	_write_text(extensionless_path + ".tianxia", "SENTINEL")
	main._on_export_file_selected(ProjectSettings.globalize_path(extensionless_path))
	_expect(main.export_overwrite_dialog.visible and main._pending_export_path.to_lower().ends_with(".tianxia"), "无扩展名导出应针对最终 .tianxia 路径再次确认")
	_expect(FileAccess.get_file_as_string(extensionless_path + ".tianxia") == "SENTINEL", "最终文件覆盖确认前不得改写已有备份")
	main.export_overwrite_dialog.hide()
	main._confirm_export_overwrite()
	_expect(bool(main._read_sandbox_transfer_file(extensionless_path + ".tianxia", true).get("ok", false)), "明确确认后才可替换补扩展名后的目标文件")

	var v2_document := {
		"save_version": 2,
		"map_id": "map_three_kingdoms_alpha",
		"map_geometry_version": 3,
		"camera": {"x": 0, "y": 0, "zoom": 1},
		"cards": [
			{"character_id": "liu_bei", "x": float(luoyang.get("x", 0.5)), "y": float(luoyang.get("y", 0.5))},
			{"character_id": "guan_yu", "x": 0.2, "y": 0.3, "place_id": "luoyang"}
		]
	}
	var v2_result: Dictionary = main._decode_sandbox_document(v2_document, true)
	_expect(bool(v2_result.get("ok", false)) and int(v2_result.get("source_save_version", 0)) == 2, "应兼容读取 v2 原始存档：%s" % JSON.stringify(v2_result))
	_expect(str(v2_result.get("placements", {}).get("liu_bei", {}).get("place_id", "")).is_empty(), "v2 精确城池自由落点不得被再次吸附")
	_expect(str(v2_result.get("placements", {}).get("guan_yu", {}).get("place_id", "")) == "luoyang", "v2 有效 place_id 应保留")
	_expect(v2_result.get("placements", {}).size() == 2, "合法 v2 两个人物应完整恢复")
	_expect(v2_result.get("annotations", {}).is_empty() and v2_result.get("warnings", []).size() >= 1, "v2 缺少标记时应为空并给出兼容提示")
	_expect(_scenario_state_matches(v2_result.get("scenario_state", {}), _empty_scenario_state()), "v1—v4 旧存档必须兼容为空场景状态，不得从人物分类推断")
	var unknown_v2_document: Dictionary = v2_document.duplicate(true)
	(unknown_v2_document.get("cards", []) as Array).append({"character_id": "ghost_general", "x": 0.1, "y": 0.2})
	var unknown_v2_result: Dictionary = main._decode_sandbox_document(unknown_v2_document, true)
	_expect(
		not bool(unknown_v2_result.get("ok", true))
		and str(unknown_v2_result.get("error_code", "")) == "cards_unknown_character",
		"旧档含目录外人物时必须明确拒绝，不能静默丢弃后继续迁移"
	)
	var duplicate_v2_document: Dictionary = v2_document.duplicate(true)
	(duplicate_v2_document.get("cards", []) as Array).append({"character_id": "liu_bei", "x": 0.8, "y": 0.8})
	var duplicate_v2_result: Dictionary = main._decode_sandbox_document(duplicate_v2_document, true)
	_expect(
		not bool(duplicate_v2_result.get("ok", true))
		and str(duplicate_v2_result.get("error_code", "")) == "cards_duplicate_character",
		"旧档重复引用同一人物时必须明确拒绝，不能静默选择其中一条"
	)

	var legacy_v4_document: Dictionary = main._build_sandbox_payload().duplicate(true)
	legacy_v4_document["save_version"] = 4
	legacy_v4_document.erase("character_catalog_version")
	legacy_v4_document.erase("scenario_state")
	legacy_v4_document.erase("chronicle")
	legacy_v4_document.erase("player_strokes")
	legacy_v4_document.erase("character_states")
	legacy_v4_document.erase("character_actions")
	legacy_v4_document.erase("character_troops")
	var legacy_v4_result: Dictionary = main._decode_sandbox_document(legacy_v4_document, true)
	_expect(bool(legacy_v4_result.get("ok", false)) and int(legacy_v4_result.get("source_save_version", 0)) == 4, "带完整身份的 v4 存档必须继续兼容读取")
	_expect(_scenario_state_matches(legacy_v4_result.get("scenario_state", {}), _empty_scenario_state()), "v4 兼容读取只能得到空场景状态")
	var legacy_v5_document: Dictionary = main._build_sandbox_payload().duplicate(true)
	legacy_v5_document["save_version"] = 5
	legacy_v5_document.erase("character_catalog_version")
	legacy_v5_document.erase("chronicle")
	legacy_v5_document.erase("player_strokes")
	legacy_v5_document.erase("character_states")
	legacy_v5_document.erase("character_actions")
	legacy_v5_document.erase("character_troops")
	var legacy_v5_result: Dictionary = main._decode_sandbox_document(legacy_v5_document, true)
	_expect(bool(legacy_v5_result.get("ok", false)) and int(legacy_v5_result.get("source_save_version", 0)) == 5, "v5 存档必须继续兼容读取")
	_expect((legacy_v5_result.get("chronicle_entries", []) as Array).is_empty(), "v5 兼容读取只能得到空玩家纪事")
	var legacy_v6_document: Dictionary = main._build_sandbox_payload().duplicate(true)
	legacy_v6_document["save_version"] = 6
	legacy_v6_document.erase("character_catalog_version")
	legacy_v6_document.erase("player_strokes")
	legacy_v6_document.erase("character_states")
	legacy_v6_document.erase("character_actions")
	legacy_v6_document.erase("character_troops")
	var legacy_v6_result: Dictionary = main._decode_sandbox_document(legacy_v6_document, true)
	_expect(bool(legacy_v6_result.get("ok", false)) and int(legacy_v6_result.get("source_save_version", 0)) == 6, "v6 存档必须继续兼容读取")
	_expect((legacy_v6_result.get("player_strokes", []) as Array).is_empty(), "v6 兼容读取只能得到空玩家推演线")
	var missing_scenario_state: Dictionary = main._build_sandbox_payload().duplicate(true)
	missing_scenario_state.erase("scenario_state")
	_expect(not bool(main._decode_sandbox_document(missing_scenario_state, true).get("ok", true)), "v18 缺少 scenario_state 必须严格拒绝")
	var invalid_scenario_state: Dictionary = main._build_sandbox_payload().duplicate(true)
	invalid_scenario_state["scenario_state"] = {
		"factions": [{"id": "play_transfer_test", "name": "备份测试势力"}],
		"character_assignments": [{"character_id": "liu_bei", "faction_id": "play_missing"}]
	}
	_expect(not bool(main._decode_sandbox_document(invalid_scenario_state, true).get("ok", true)), "v18 场景状态引用未知势力时必须严格拒绝")

	var malformed_document := {
		"save_version": 3,
		"map_id": "map_three_kingdoms_alpha",
		"map_geometry_version": 3,
		"camera": {"x": 0, "y": 0, "zoom": 1},
		"cards": [],
		"annotations": [
			{"id": "marker_7", "kind": "marker", "x": -1, "y": 2, "label": "第一行\n第二行且这是一个非常非常非常非常长的标记", "style": "unknown"},
			{"id": "marker_7", "kind": "marker", "x": 0.1, "y": 0.1, "label": "重复"},
			{"id": "bad id", "kind": "marker", "x": 0.1, "y": 0.1},
			{"id": "arrow_1", "kind": "arrow", "x": 0.1, "y": 0.1},
			{"id": "marker_8", "kind": "marker", "x": "wrong", "y": {}, "label": "异常坐标"}
		]
	}
	var malformed_result: Dictionary = main._decode_sandbox_document(malformed_document, true)
	_expect(not bool(malformed_result.get("ok", true)) and str(malformed_result.get("error_code", "")) == "map_geometry_migration_failed", "geometry v3 任一坏坐标必须阻止整档迁移，不能在新旧投影间静默猜测")

	var state_before_invalid := {
		"placements": main.placements.duplicate(true),
		"annotations": main.annotations.duplicate(true),
		"scenario_state": main.scenario_state.duplicate(true),
		"undo": main._undo_stack.size(),
		"redo": main._redo_stack.size(),
		"save": _snapshot_file(auto_save)
	}
	_write_text(invalid_path, "{bad json")
	main._on_import_file_selected(ProjectSettings.globalize_path(invalid_path))
	if main.message_dialog != null:
		main.message_dialog.hide()
	_expect(main._placements_match(main.placements, state_before_invalid.get("placements", {})) and main._annotations_match(main.annotations, state_before_invalid.get("annotations", {})) and _scenario_state_matches(main.scenario_state, state_before_invalid.get("scenario_state", {})), "无效 JSON 不得改变当前沙盘内存或场景状态")
	_expect(main._undo_stack.size() == int(state_before_invalid.get("undo", -1)) and main._redo_stack.size() == int(state_before_invalid.get("redo", -1)), "无效 JSON 不得改变历史栈")
	_expect(_same_snapshot(auto_save, state_before_invalid.get("save", {})), "无效 JSON 不得改写当前自动存档")
	_expect(not bool(main._decode_sandbox_text("[]", true).get("ok", true)), "顶层数组应被拒绝")
	_expect(str(main._decode_sandbox_document({}, true).get("error_code", "")) == "wrong_format", "无关 JSON 对象不得被误认成空沙盘")
	_expect(str(main._decode_sandbox_document({"foo": 1}, true).get("error_code", "")) == "wrong_format", "缺少旧存档指纹的对象必须拒绝")
	_expect(str(main._decode_sandbox_document({"save_version": 99, "cards": [], "annotations": []}, true).get("error_code", "")) == "unsupported_version", "未来存档版本必须拒绝，不能降级覆写")
	_expect(str(main._decode_sandbox_document({"format": "tianxia_sandbox_backup", "format_version": 1.5, "sandbox": {}}, true).get("error_code", "")) == "unsupported_format", "小数备份版本不得向下取整后误判兼容")
	_expect(str(main._decode_sandbox_document({"save_version": 3, "map_id": "other_map", "cards": [], "annotations": []}, true).get("error_code", "")) == "wrong_map", "不同地图的备份必须拒绝")
	var excessive_annotations: Array = []
	excessive_annotations.resize(501)
	_expect(str(main._decode_sandbox_document({"save_version": 3, "map_id": "map_three_kingdoms_alpha", "map_geometry_version": 4, "cards": [], "annotations": excessive_annotations}, true).get("error_code", "")) == "too_many_annotations", "外部标记数量必须受安全上限保护")
	_expect(str(main._decode_sandbox_document({"save_version": 3, "map_id": "map_three_kingdoms_alpha", "map_geometry_version": 5, "cards": [], "annotations": []}, true).get("error_code", "")) == "unsupported_map_geometry", "未来地图几何版本必须硬拒绝")

	var imported_document := {
		"format": "tianxia_sandbox_backup",
		"format_version": 1,
		"exported_at": "2026-07-22T12:00:00+08:00",
		"sandbox": {
			"save_version": 3,
			"map_id": "map_three_kingdoms_alpha",
			"map_geometry_version": 3,
			"camera": {"x": -30, "y": -20, "zoom": 0.92},
			"cards": [{"character_id": "cao_cao", "x": 0.22, "y": 0.33}],
			"annotations": [{"id": "marker_99", "kind": "marker", "x": 0.55, "y": 0.44, "label": "曹军前锋", "style": "amber"}]
		}
	}
	_write_text(import_path, JSON.stringify(imported_document))
	var original_placements: Dictionary = main.placements.duplicate(true)
	var original_annotations: Dictionary = main.annotations.duplicate(true)
	var original_scenario_state: Dictionary = main.scenario_state.duplicate(true)
	var original_camera: Dictionary = main.map_board.get_camera_state()
	var original_history_size: int = main._undo_stack.size()
	var original_cache: Dictionary = main.map_board.get_static_cache_state()
	main._on_import_file_selected(ProjectSettings.globalize_path(import_path))
	_expect(bool(main._pending_import_result.get("ok", false)) and main.import_confirmation_dialog.visible, "选择有效备份后应只生成预览，不立即覆盖")
	main.import_confirmation_dialog.hide()
	main._cancel_sandbox_import()
	_expect(main._placements_match(main.placements, original_placements) and main._annotations_match(main.annotations, original_annotations) and _scenario_state_matches(main.scenario_state, original_scenario_state), "取消恢复应保持人物、标记和场景状态不变")
	_expect(main._camera_states_match(main.map_board.get_camera_state(), original_camera) and main._undo_stack.size() == original_history_size, "取消恢复应保持视角和历史不变")
	var cache_after_cancel: Dictionary = main.map_board.get_static_cache_state()
	_expect(int(cache_after_cancel.get("static_builds", -1)) == int(original_cache.get("static_builds", -2)) and int(cache_after_cancel.get("annotation_builds", -1)) == int(original_cache.get("annotation_builds", -2)), "恢复预览与取消不应重建地图缓存")

	var import_candidate: Dictionary = main._read_sandbox_transfer_file(import_path, true)
	var migrated_home_camera: Dictionary = main.map_board.get_home_camera_state()
	var apply_result: Dictionary = main._apply_import_result(import_candidate)
	_expect(bool(apply_result.get("ok", false)), "确认后应能恢复合法备份")
	if not str(apply_result.get("backup_path", "")).is_empty():
		created_backup_paths.append(str(apply_result.get("backup_path", "")))
	await process_frame
	await process_frame
	_expect(main.placements.size() == 1 and main.placements.has("cao_cao") and main.annotations.has("marker_99"), "恢复应一次性替换人物与标记")
	_expect(_scenario_state_matches(main.scenario_state, _empty_scenario_state()), "恢复 v3 备份必须得到稳定 custom_blank 场景，不能残留上一个沙盘的势力")
	_expect(main.favorite_character_ids.has("liu_bei"), "恢复沙盘不得覆盖玩家人物收藏")
	_expect(main._undo_stack.size() == original_history_size + 1 and main._redo_stack.is_empty(), "整次恢复应只产生一个撤销动作并清空重做分支")
	_expect(main._camera_states_match(main.map_board.get_camera_state(), migrated_home_camera), "恢复 geometry v3 备份应回到地图 B 天下全图")
	_expect(main._next_annotation_serial >= 100, "导入 marker_99 后的新标记 ID 不得冲突")
	var cache_after_import: Dictionary = main.map_board.get_static_cache_state()
	_expect(int(cache_after_import.get("static_builds", -1)) == int(original_cache.get("static_builds", -2)), "恢复人物和标记不应重建静态地理缓存")
	_expect(int(cache_after_import.get("annotation_builds", 0)) <= int(original_cache.get("annotation_builds", 0)) + 1, "恢复不同视角最多只应触发一次缩放注记更新")

	main._on_undo_pressed()
	_expect(main._placements_match(main.placements, original_placements) and main._annotations_match(main.annotations, original_annotations), "一次撤销应完整恢复导入前的人物与标记")
	_expect(_scenario_state_matches(main.scenario_state, original_scenario_state), "撤销旧备份恢复必须同时恢复导入前场景状态")
	_expect(main._camera_states_match(main.map_board.get_camera_state(), original_camera), "撤销恢复应同时还原导入前视角")
	main._on_redo_pressed()
	_expect(main.placements.has("cao_cao") and main.annotations.has("marker_99"), "一次重做应完整恢复导入内容")
	_expect(_scenario_state_matches(main.scenario_state, _empty_scenario_state()), "重做旧备份恢复必须再次应用空场景状态")
	_expect(main._camera_states_match(main.map_board.get_camera_state(), migrated_home_camera), "重做恢复应再次回到地图 B 天下全图")

	var source_bytes_before := FileAccess.get_file_as_string(import_path)
	main._on_character_dropped("cao_cao", Vector2(0.40, 0.40))
	_expect(FileAccess.get_file_as_string(import_path) == source_bytes_before, "恢复后的继续编辑不得改写外部备份文件")

	var failure_document := imported_document.duplicate(true)
	var failure_payload: Dictionary = failure_document.get("sandbox", {}).duplicate(true)
	failure_payload["cards"] = [{"character_id": "sun_jian", "x": 0.7, "y": 0.7}]
	failure_document["sandbox"] = failure_payload
	var failure_candidate: Dictionary = main._decode_sandbox_document(failure_document, true)
	var before_failure_placements: Dictionary = main.placements.duplicate(true)
	var before_failure_annotations: Dictionary = main.annotations.duplicate(true)
	var before_failure_scenario_state: Dictionary = main.scenario_state.duplicate(true)
	var before_failure_save := _snapshot_file(auto_save)
	_write_text(blocker_path, "BLOCK")
	var normal_backup_dir: String = main.backup_dir
	main.backup_dir = blocker_path
	var failure_result: Dictionary = main._apply_import_result(failure_candidate)
	main.backup_dir = normal_backup_dir
	_expect(not bool(failure_result.get("ok", true)), "无法创建导入前安全备份时必须阻止恢复")
	_expect(main._placements_match(main.placements, before_failure_placements) and main._annotations_match(main.annotations, before_failure_annotations) and _scenario_state_matches(main.scenario_state, before_failure_scenario_state), "安全备份失败不得改变当前内存状态")
	_expect(_same_snapshot(auto_save, before_failure_save), "安全备份失败不得改写当前本机存档")

	var write_failure_state: Dictionary = main.placements.duplicate(true)
	var write_failure_annotations: Dictionary = main.annotations.duplicate(true)
	var write_failure_scenario_state: Dictionary = main.scenario_state.duplicate(true)
	var write_failure_camera: Dictionary = main.map_board.get_camera_state()
	var write_failure_undo_size: int = main._undo_stack.size()
	var write_failure_redo_size: int = main._redo_stack.size()
	var write_failure_save := _snapshot_file(auto_save)
	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(runtime_target_dir))
	_expect(directory_error == OK, "测试应能建立不可作为文件目标的目录")
	var normal_save_path: String = main.save_path
	main.save_path = runtime_target_dir
	var disk_failure_result: Dictionary = main._apply_import_result(failure_candidate)
	main.save_path = normal_save_path
	if not str(disk_failure_result.get("backup_path", "")).is_empty():
		created_backup_paths.append(str(disk_failure_result.get("backup_path", "")))
	_expect(not bool(disk_failure_result.get("ok", true)), "安全备份成功但正式存档写入失败时必须阻止恢复")
	_expect(main._placements_match(main.placements, write_failure_state) and main._annotations_match(main.annotations, write_failure_annotations) and _scenario_state_matches(main.scenario_state, write_failure_scenario_state), "正式存档写入失败不得改变人物、标记或场景状态")
	_expect(main._camera_states_match(main.map_board.get_camera_state(), write_failure_camera), "正式存档写入失败不得改变地图视角")
	_expect(main._undo_stack.size() == write_failure_undo_size and main._redo_stack.size() == write_failure_redo_size, "正式存档写入失败不得改变历史栈")
	_expect(_same_snapshot(auto_save, write_failure_save), "正式存档写入失败不得改写原本机存档")
	main.save_path = runtime_target_dir
	var failed_commit_state: Dictionary = main.placements.duplicate(true)
	var failed_commit_history: int = main._undo_stack.size()
	var failed_next: Dictionary = main.placements.duplicate(true)
	failed_next["liu_bei"] = {"x": 0.12, "y": 0.18}
	_expect(not main._commit_placements(failed_next, "写入失败测试", "不应出现"), "普通操作无法落盘时不得先改变内存")
	_expect(main._placements_match(main.placements, failed_commit_state) and main._undo_stack.size() == failed_commit_history, "普通操作写入失败时状态和历史必须不变")
	var failed_undo_stack: int = main._undo_stack.size()
	var failed_redo_stack: int = main._redo_stack.size()
	main._on_undo_pressed()
	_expect(main._placements_match(main.placements, failed_commit_state), "撤销无法落盘时不得改变当前状态")
	_expect(main._undo_stack.size() == failed_undo_stack and main._redo_stack.size() == failed_redo_stack, "撤销无法落盘时不得移动历史栈")
	main.save_path = normal_save_path
	_remove_empty_dir(runtime_target_dir)

	_expect(_same_snapshot(formal_save, formal_save_before), "自动测试全过程不得改变正式沙盘存档")
	_expect(_same_snapshot(formal_preferences, formal_preferences_before), "自动测试全过程不得改变正式人物收藏")

	main.queue_free()
	await process_frame
	for backup_path in created_backup_paths:
		_remove_file(backup_path)

	var future_document := {"save_version": 99, "map_id": "map_three_kingdoms_alpha", "cards": [], "annotations": [], "future_field": "KEEP_ME"}
	_write_text(auto_save, JSON.stringify(future_document))
	var future_bytes := FileAccess.get_file_as_string(auto_save)
	var future_main = packed.instantiate()
	root.add_child(future_main)
	await process_frame
	await process_frame
	_expect(future_main._save_writes_blocked, "启动遇到未来版本本机存档时必须禁止旧程序写回")
	_expect(not future_main._save(), "写回保护开启后自动保存必须失败")
	_expect(FileAccess.get_file_as_string(auto_save) == future_bytes, "未来版本本机存档在旧程序中必须保持原字节")
	future_main.queue_free()
	await process_frame

	_expect(_same_snapshot(formal_save, formal_save_before), "自动测试结束时正式沙盘存档仍须保持原字节")
	_expect(_same_snapshot(formal_preferences, formal_preferences_before), "自动测试结束时正式人物收藏仍须保持原字节")
	for path in [auto_save, auto_preferences, export_path, import_path, existing_path, invalid_path, blocker_path, extensionless_path + ".tianxia"]:
		_remove_file(path)
	_remove_empty_dir(runtime_target_dir)
	if failures.is_empty():
		print("SANDBOX_TRANSFER_TEST_OK roundtrip=v18_catalog6_scenario_complete map_provenance=stable_ids_only v2_v7=compatible unknown_duplicate=explicit_reject malformed=safe unrelated_json=rejected overwrite=confirmed history=atomic camera=restored write_failure=non_destructive future_save=protected isolation=pass")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
