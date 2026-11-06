extends SceneTree

var failures: Array[String] = []
var cleanup_backup_paths: Array[String] = []


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


func _write_text(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		failures.append("测试夹具无法写入：%s" % path)
		return
	file.store_string(value)
	file.close()


func _snapshot_file(path: String) -> Dictionary:
	return {
		"exists": FileAccess.file_exists(path),
		"text": FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""
	}


func _same_snapshot(path: String, snapshot: Dictionary) -> bool:
	return bool(snapshot.get("exists", false)) == FileAccess.file_exists(path) and str(snapshot.get("text", "")) == (FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else "")


func _selected_item_metadata(item_list: ItemList) -> String:
	var selected_items := item_list.get_selected_items()
	if selected_items.is_empty():
		return ""
	return str(item_list.get_item_metadata(int(selected_items[0])))


func _focus_owner_description(node: Node) -> String:
	var owner := node.get_viewport().gui_get_focus_owner()
	if owner == null:
		return "null"
	return "%s/%s visible=%s" % [owner.name, owner.get_class(), owner.is_visible_in_tree()]


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


func _snapshot_scenario_state() -> Dictionary:
	return {
		"scenario_id": "custom_blank",
		"start_year": null,
		"era_label": "完全自定义",
		"scenario_kind": "custom",
		"featured_character_ids": [],
		"history_layer_ids": [],
		"factions": [{"id": "play_snapshot_test", "name": "快照测试势力", "color": "#0077BB"}],
		"character_assignments": [
			{"character_id": "liu_bei", "faction_id": "play_snapshot_test"},
			{"character_id": "guan_yu", "faction_id": "play_snapshot_test"}
		],
		"city_ownership": []
	}


func _run() -> void:
	var auto_save := "user://sandbox_save_automated_test.json"
	var auto_preferences := "user://backpack_preferences_automated_test.json"
	var auto_snapshots := "user://sandbox_snapshots_automated_test.json"
	var snapshot_replace_repro := ProjectSettings.globalize_path(auto_snapshots) + ".replace-repro.tmp"
	var snapshot_write_repro := ProjectSettings.globalize_path(auto_snapshots) + ".write-repro.tmp"
	var snapshot_stale_artifacts: Array[String] = []
	for artifact_index in range(13):
		snapshot_stale_artifacts.append(ProjectSettings.globalize_path(auto_snapshots) + ".write-authority-%02d.tmp" % artifact_index)
	var uncommitted_only_store := "user://sandbox_snapshots_uncommitted_only_automated_test.json"
	var uncommitted_only_write := ProjectSettings.globalize_path(uncommitted_only_store) + ".write-repro.tmp"
	var ambiguous_store := "user://sandbox_snapshots_ambiguous_automated_test.json"
	var ambiguous_replace_a := ProjectSettings.globalize_path(ambiguous_store) + ".replace-a.tmp"
	var ambiguous_replace_b := ProjectSettings.globalize_path(ambiguous_store) + ".replace-b.tmp"
	var snapshot_export_base := "user://snapshot_export_automated_test"
	var snapshot_export_path := snapshot_export_base + ".tianxia"
	var snapshot_export_protected := "user://snapshot_export_protected_automated_test.tianxia"
	var snapshot_export_while_save_blocked := "user://snapshot_export_save_blocked_automated_test.tianxia"
	var blocked_export_target := "user://snapshot_blocked_export_automated_test.tianxia"
	var blocked_save_dir := "user://snapshot_blocked_save_dir_automated_test"
	var blocked_store_dir := "user://snapshot_blocked_store_dir_automated_test"
	for path in [auto_save, auto_preferences, auto_snapshots, snapshot_replace_repro, snapshot_write_repro, uncommitted_only_store, uncommitted_only_write, ambiguous_store, ambiguous_replace_a, ambiguous_replace_b, snapshot_export_path, snapshot_export_protected, snapshot_export_while_save_blocked]:
		_remove_file(path)
	for artifact_path in snapshot_stale_artifacts:
		_remove_file(artifact_path)
	_remove_empty_dir(blocked_save_dir)
	_remove_empty_dir(blocked_store_dir)
	_remove_empty_dir(blocked_export_target)

	var formal_save := "user://sandbox_save.json"
	var formal_preferences := "user://backpack_preferences.json"
	var formal_snapshots := "user://sandbox_snapshots.json"
	var formal_save_before := _snapshot_file(formal_save)
	var formal_preferences_before := _snapshot_file(formal_preferences)
	var formal_snapshots_before := _snapshot_file(formal_snapshots)

	var legacy_v3 := {
		"save_version": 3,
		"map_id": "map_three_kingdoms_alpha",
		"map_geometry_version": 3,
		"camera": {"x": -40, "y": -25, "zoom": 1.1},
		"cards": [{"character_id": "liu_bei", "x": 0.31, "y": 0.42}],
		"annotations": [{"id": "marker_4", "kind": "marker", "x": 0.45, "y": 0.51, "label": "旧版标记", "style": "amber"}]
	}
	_write_text(auto_save, JSON.stringify(legacy_v3))

	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_expect(main.automated_test_mode and main.snapshot_store_path == auto_snapshots, "命名快照测试必须使用自动测试隔离路径")
	_expect(main.placements.has("liu_bei") and main.annotations.has("marker_4"), "v3→v18 迁移必须保留人物和标记")
	var migrated: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(auto_save))
	var initial_metadata: Dictionary = migrated.get("metadata", {})
	var initial_id := str(initial_metadata.get("sandbox_id", ""))
	_expect(int(migrated.get("save_version", 0)) == 18 and int(migrated.get("character_catalog_version", 0)) == 6 and int(migrated.get("map_geometry_version", 0)) == 4 and main._is_safe_record_id(initial_id), "本机 v3 应原子迁移为 geometry v4／存档 v18／人物目录 v6，并补齐完整可编辑状态")
	_expect(migrated.get("player_strokes", {}) == {"semantic_layer": "player_authored", "verification_status": "not_project_verified", "strokes": []}, "v3→v18 迁移必须补齐严格空 player_strokes 根对象")
	_expect(_scenario_state_matches(main.scenario_state, _empty_scenario_state()) and _scenario_state_matches(migrated.get("scenario_state", {}), _empty_scenario_state()), "旧存档迁移不得从人物原型分类推断玩法势力")
	_expect(str(main.sandbox_metadata.get("sandbox_id", "")) == initial_id, "迁移写入和运行内存必须使用同一个沙盘 ID")
	main._save()
	var resaved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(auto_save))
	_expect(str(resaved.get("metadata", {}).get("sandbox_id", "")) == initial_id, "普通保存不得改变沙盘 ID")

	var legacy_external: Dictionary = main._decode_sandbox_document(legacy_v3, true)
	_expect(bool(legacy_external.get("ok", false)) and bool(legacy_external.get("metadata_migration_required", false)), "外部 v3 只能标记为待建立身份，不得伪造来源分支")
	_expect(legacy_external.get("sandbox_metadata", {}).is_empty(), "外部旧备份预览阶段不得生成随机沙盘 ID")
	var invalid_v4: Dictionary = main._decode_sandbox_document({"save_version": 4, "map_id": "map_three_kingdoms_alpha", "map_geometry_version": 4, "cards": [], "annotations": []}, true)
	_expect(str(invalid_v4.get("error_code", "")) == "invalid_metadata", "v4 缺少身份信息必须非破坏性拒绝")
	var self_parent_metadata: Dictionary = main.sandbox_metadata.duplicate(true)
	self_parent_metadata["branch_parent_id"] = initial_id
	var self_parent_result: Dictionary = main._decode_sandbox_document({
		"save_version": 4, "metadata": self_parent_metadata, "map_id": "map_three_kingdoms_alpha",
		"map_geometry_version": 3, "camera": {"x": 0, "y": 0, "zoom": 1}, "cards": [], "annotations": []
	}, true)
	_expect(str(self_parent_result.get("error_code", "")) == "invalid_metadata", "沙盘分支来源不得指向自身")
	var legacy_v4_payload: Dictionary = main._build_sandbox_payload().duplicate(true)
	legacy_v4_payload["save_version"] = 4
	legacy_v4_payload.erase("character_catalog_version")
	legacy_v4_payload.erase("scenario_state")
	legacy_v4_payload.erase("chronicle")
	legacy_v4_payload.erase("player_strokes")
	legacy_v4_payload.erase("character_actions")
	legacy_v4_payload.erase("character_troops")
	var legacy_v4_store := {
		"snapshot_store_version": 1,
		"snapshots": [{
			"snapshot_id": "snapshot_legacy_v4",
			"name": "旧版 v4 快照",
			"note": "兼容测试",
			"created_at": "2026-07-22T00:00:00+08:00",
			"sandbox": legacy_v4_payload
		}]
	}
	var legacy_v4_store_result: Dictionary = main._decode_snapshot_store(legacy_v4_store)
	_expect(bool(legacy_v4_store_result.get("ok", false)) and (legacy_v4_store_result.get("snapshots", []) as Array).size() == 1, "已有 v4 命名快照必须继续通过当前快照库解码")
	if bool(legacy_v4_store_result.get("ok", false)):
		var legacy_snapshot: Dictionary = (legacy_v4_store_result.get("snapshots", []) as Array)[0]
		var legacy_snapshot_decoded: Dictionary = main._decode_sandbox_document(legacy_snapshot.get("sandbox", {}), false)
		_expect(bool(legacy_snapshot_decoded.get("ok", false)) and _scenario_state_matches(legacy_snapshot_decoded.get("scenario_state", {}), _empty_scenario_state()), "v4 命名快照应规范化为空场景状态且不伪造势力")

	main.favorite_character_ids = {"liu_bei": true}
	main.backpack.set_favorites(main.favorite_character_ids)
	main._save_preferences()
	var preference_bytes := FileAccess.get_file_as_string(auto_preferences)
	var edited_metadata: Dictionary = main.sandbox_metadata.duplicate(true)
	edited_metadata["title"] = "我的蜀汉"
	edited_metadata["note"] = "从黄巾起义开始，自由推演。"
	edited_metadata["scenario_source"] = "黄巾起义（184 年）"
	var history_before_info: int = main._undo_stack.size()
	_expect(main._commit_sandbox_metadata(edited_metadata, "编辑沙盘信息", "测试"), "沙盘名称、说明和开局来源应能原子保存")
	_expect(str(main.sandbox_metadata.get("sandbox_id", "")) == initial_id and main._undo_stack.size() == history_before_info + 1, "编辑信息应保留 ID 并形成一个历史动作")
	main._on_undo_pressed()
	_expect(str(main.sandbox_metadata.get("title", "")) == "未命名沙盘", "撤销应恢复编辑前的沙盘名称")
	main._on_redo_pressed()
	_expect(str(main.sandbox_metadata.get("title", "")) == "我的蜀汉" and str(main.sandbox_metadata.get("sandbox_id", "")) == initial_id, "重做应恢复信息且不得重生 ID")

	main.placements = {"liu_bei": {"x": 0.26, "y": 0.38}, "guan_yu": {"x": 0.28, "y": 0.40}}
	main.annotations = {"marker_8": {"id": "marker_8", "kind": "marker", "x": 0.5, "y": 0.48, "label": "准备进军", "style": "amber"}}
	main.scenario_state = _snapshot_scenario_state()
	main.map_board.zoom = 1.24
	main.map_board.pan = Vector2(-130, -70)
	main.map_board._apply_camera()
	main._refresh_views()
	main._save()
	var snapshot_source_placements: Dictionary = main.placements.duplicate(true)
	var snapshot_source_annotations: Dictionary = main.annotations.duplicate(true)
	var snapshot_source_camera: Dictionary = main.map_board.get_camera_state()
	var snapshot_source_metadata: Dictionary = main.sandbox_metadata.duplicate(true)
	var snapshot_source_scenario_state: Dictionary = main.scenario_state.duplicate(true)
	var history_before_snapshot: int = main._undo_stack.size()
	var snapshot_result: Dictionary = main._create_named_snapshot("攻打汉中之前", "兵分两路前，关羽暂驻荆州。")
	_expect(bool(snapshot_result.get("ok", false)) and FileAccess.file_exists(auto_snapshots), "命名快照应写入独立本机快照库")
	var first_snapshot: Dictionary = snapshot_result.get("snapshot", {})
	var first_snapshot_id := str(first_snapshot.get("snapshot_id", ""))
	_expect(main._is_safe_record_id(first_snapshot_id) and int(first_snapshot.get("sandbox", {}).get("save_version", 0)) == 18 and int(first_snapshot.get("sandbox", {}).get("character_catalog_version", 0)) == 6, "命名快照应有独立 ID 并保存 v18／人物目录 v6 完整状态")
	_expect(_scenario_state_matches(first_snapshot.get("sandbox", {}).get("scenario_state", {}), snapshot_source_scenario_state), "命名快照必须保存玩法势力与人物分配")
	_expect(str(first_snapshot.get("sandbox", {}).get("metadata", {}).get("sandbox_id", "")) == initial_id, "创建快照不得改变或复制新的当前分支 ID")
	_expect(main._undo_stack.size() == history_before_snapshot and FileAccess.get_file_as_string(auto_preferences) == preference_bytes, "创建快照不得污染沙盘历史或人物收藏")
	var snapshot_text := FileAccess.get_file_as_string(auto_snapshots)
	_expect(snapshot_text.find("favorite_character_ids") == -1 and snapshot_text.find("preferences_path") == -1, "命名快照库不得包含收藏或本机偏好路径")
	var duplicate_result: Dictionary = main._create_named_snapshot("攻打汉中之前", "同名阶段也应保留")
	_expect(bool(duplicate_result.get("ok", false)) and str(duplicate_result.get("snapshot", {}).get("snapshot_id", "")) != first_snapshot_id, "同名快照应作为不同阶段保留并获得不同 ID")
	_expect(str(main.sandbox_metadata.get("sandbox_id", "")) == initial_id, "连续创建快照仍不得改变当前沙盘 ID")

	# Windows 两步替换在旧库侧移后中断时，启动必须恢复已提交旧库，绝不能把未提交 write 旁路当成新库。
	var committed_snapshot_store_text := FileAccess.get_file_as_string(auto_snapshots)
	var committed_snapshot_count: int = main.named_snapshots.size()
	_write_text(snapshot_write_repro, JSON.stringify({"snapshot_store_version": 1, "snapshots": [], "updated_at": "2026-08-31T00:00:00+08:00"}))
	_expect(DirAccess.rename_absolute(ProjectSettings.globalize_path(auto_snapshots), snapshot_replace_repro) == OK, "快照恢复夹具必须把已提交旧库侧移到 replace 位置")
	main.named_snapshots.clear()
	main._load_named_snapshots()
	_expect(FileAccess.file_exists(auto_snapshots) and FileAccess.get_file_as_string(auto_snapshots) == committed_snapshot_store_text, "主路径缺失时必须逐字节恢复唯一已提交快照库")
	_expect(main.named_snapshots.size() == committed_snapshot_count and not main._snapshot_writes_blocked, "恢复后必须重新载入全部已提交快照并允许后续安全写入")
	_expect(FileAccess.file_exists(snapshot_write_repro) and not FileAccess.file_exists(snapshot_replace_repro), "未提交 write 旁路必须原样保留且永不载入；已提交 replace 应提升回主路径")
	_remove_file(snapshot_write_repro)

	var authoritative_store_before := FileAccess.get_file_as_string(auto_snapshots)
	var authoritative_artifacts_before: Dictionary = {}
	for artifact_index in range(snapshot_stale_artifacts.size()):
		var artifact_path := snapshot_stale_artifacts[artifact_index]
		var artifact_text := "STALE_SNAPSHOT_WRITE_%02d" % artifact_index
		_write_text(artifact_path, artifact_text)
		authoritative_artifacts_before[artifact_path] = artifact_text
	var authoritative_store_state: Dictionary = main._inspect_snapshot_store_recovery(auto_snapshots)
	main.named_snapshots.clear()
	main._load_named_snapshots()
	_expect(
		str(authoritative_store_state.get("status", "")) == "primary_valid"
		and int(authoritative_store_state.get("artifact_count", 0)) == snapshot_stale_artifacts.size()
		and str(authoritative_store_state.get("primary", {}).get("status", "")) == "valid",
		"有效命名快照主库必须优先于过量事务残留，不能被误判为候选过多"
	)
	_expect(main.named_snapshots.size() == committed_snapshot_count and not main._snapshot_writes_blocked, "过量事务残留旁边的有效命名快照主库必须完整载入并保持可写")
	_expect(FileAccess.get_file_as_string(auto_snapshots) == authoritative_store_before, "命名快照权威检查必须保持有效主库逐字节不变")
	for artifact_path in snapshot_stale_artifacts:
		_expect(FileAccess.get_file_as_string(artifact_path) == str(authoritative_artifacts_before.get(artifact_path, "")), "命名快照权威检查必须保留全部事务残留")
		_remove_file(artifact_path)

	var normal_snapshot_store_path: String = main.snapshot_store_path
	_write_text(uncommitted_only_write, committed_snapshot_store_text)
	main.snapshot_store_path = uncommitted_only_store
	var stale_memory_snapshots: Array[Dictionary] = [{"snapshot_id": "snapshot_should_clear"}]
	main.named_snapshots = stale_memory_snapshots
	main._load_named_snapshots()
	_expect(main.named_snapshots.is_empty() and main._snapshot_writes_blocked and not FileAccess.file_exists(uncommitted_only_store), "只有未提交 write 旁路时不得载入或新建空库，必须进入明确写保护")
	main.snapshot_store_path = normal_snapshot_store_path
	main._load_named_snapshots()
	_expect(main.named_snapshots.size() == committed_snapshot_count and not main._snapshot_writes_blocked, "回到正常快照路径后必须恢复已提交库与可写状态")
	_remove_file(uncommitted_only_write)

	_write_text(ambiguous_replace_a, committed_snapshot_store_text)
	_write_text(ambiguous_replace_b, JSON.stringify({"snapshot_store_version": 1, "snapshots": [], "updated_at": "2026-08-31T00:00:00+08:00"}))
	main.snapshot_store_path = ambiguous_store
	main._load_named_snapshots()
	_expect(main.named_snapshots.is_empty() and main._snapshot_writes_blocked and not FileAccess.file_exists(ambiguous_store), "两份内容不同的已提交候选必须进入歧义写保护，不得自动选择或生成主库")
	_expect(FileAccess.file_exists(ambiguous_replace_a) and FileAccess.file_exists(ambiguous_replace_b), "歧义恢复必须原样保留全部已提交候选")
	main.snapshot_store_path = normal_snapshot_store_path
	main._load_named_snapshots()
	_expect(main.named_snapshots.size() == committed_snapshot_count and not main._snapshot_writes_blocked, "退出歧义夹具后必须重新载入正常快照库")
	_remove_file(ambiguous_replace_a)
	_remove_file(ambiguous_replace_b)

	var first_snapshot_before_rename: Dictionary = main._find_named_snapshot(first_snapshot_id).duplicate(true)
	var second_snapshot_id := str(duplicate_result.get("snapshot", {}).get("snapshot_id", ""))
	var second_snapshot_before_rename: Dictionary = main._find_named_snapshot(second_snapshot_id).duplicate(true)
	var history_before_rename: int = main._undo_stack.size()
	var rename_result: Dictionary = main._rename_named_snapshot(first_snapshot_id, "  汉中决战前\n  ")
	var renamed_snapshot: Dictionary = main._find_named_snapshot(first_snapshot_id).duplicate(true)
	_expect(bool(rename_result.get("ok", false)) and str(renamed_snapshot.get("name", "")) == "汉中决战前", "重命名应清理首尾空白和换行并持久化新名称")
	_expect(str(renamed_snapshot.get("snapshot_id", "")) == first_snapshot_id and str(renamed_snapshot.get("note", "")) == str(first_snapshot_before_rename.get("note", "")), "重命名不得改变快照 ID、备注或创建语义")
	_expect(str(renamed_snapshot.get("created_at", "")) == str(first_snapshot_before_rename.get("created_at", "")) and JSON.stringify(renamed_snapshot.get("sandbox", {})) == JSON.stringify(first_snapshot_before_rename.get("sandbox", {})), "重命名不得重建快照时间或沙盘内容")
	_expect(JSON.stringify(main._find_named_snapshot(str(second_snapshot_before_rename.get("snapshot_id", "")))) == JSON.stringify(second_snapshot_before_rename), "重命名一个快照不得影响其他快照")
	_expect(main._undo_stack.size() == history_before_rename and FileAccess.get_file_as_string(auto_preferences) == preference_bytes, "重命名不得污染沙盘历史或人物收藏")
	var store_after_rename := FileAccess.get_file_as_string(auto_snapshots)
	var unchanged_rename: Dictionary = main._rename_named_snapshot(first_snapshot_id, "汉中决战前")
	_expect(bool(unchanged_rename.get("unchanged", false)) and FileAccess.get_file_as_string(auto_snapshots) == store_after_rename, "同名重命名应作为无变化操作且不写盘")
	var invalid_rename: Dictionary = main._rename_named_snapshot(first_snapshot_id, " \n ")
	_expect(not bool(invalid_rename.get("ok", true)) and FileAccess.get_file_as_string(auto_snapshots) == store_after_rename, "空名称必须拒绝且快照库字节不变")

	# 命名快照目录重开时必须维持所选快照、滚动位置与键盘操作链。
	var focus_snapshots_baseline: Array[Dictionary] = main.named_snapshots.duplicate(true)
	var focus_store_baseline := FileAccess.get_file_as_string(auto_snapshots)
	var focus_save_baseline := FileAccess.get_file_as_string(auto_save)
	var focus_preferences_baseline := FileAccess.get_file_as_string(auto_preferences)
	var focus_history_size: int = main._undo_stack.size()
	var focus_snapshots: Array[Dictionary] = []
	for focus_index in range(24):
		focus_snapshots.append({
			"snapshot_id": "snapshot_focus_%02d" % focus_index,
			"name": "焦点压力快照 %02d" % focus_index,
			"note": "只用于命名快照列表焦点与滚动压力测试。",
			"created_at": "2026-08-%02dT12:00:00+08:00" % (focus_index + 1),
			"sandbox": first_snapshot.get("sandbox", {}).duplicate(true),
		})
	main.named_snapshots = focus_snapshots
	_expect(bool(main._write_snapshot_store(main.named_snapshots).get("ok", false)), "快照列表焦点压力夹具必须可写入隔离快照库")
	main._open_snapshot_manager()
	for _frame in range(5):
		await process_frame
	_expect(main.snapshot_manager_dialog.visible and main.snapshot_list.item_count == 24, "命名快照管理器应展示完整焦点压力列表")
	_expect(main.snapshot_list.get_viewport().gui_get_focus_owner() == main.snapshot_list and _selected_item_metadata(main.snapshot_list) == "snapshot_focus_23", "首次打开命名快照管理器必须聚焦最新快照")

	main.snapshot_manager_dialog.hide()
	await process_frame
	main._open_snapshot_manager("snapshot_focus_18")
	await process_frame
	main.snapshot_export_button.grab_focus()
	for _frame in range(3):
		await process_frame
	_expect(main.snapshot_export_button.get_viewport().gui_get_focus_owner() == main.snapshot_export_button, "列表延迟恢复不得抢走其他可见控件已取得的焦点；实际=%s dialog=%s list=%s" % [_focus_owner_description(main.snapshot_export_button), main.snapshot_manager_dialog.visible, main.snapshot_list.is_visible_in_tree()])

	var snapshot_scroll_bar: VScrollBar = main.snapshot_list.get_v_scroll_bar()
	var snapshot_scroll_limit := maxf(0.0, float(snapshot_scroll_bar.max_value) - float(snapshot_scroll_bar.page))
	var rename_index := 12
	main.snapshot_list.select(rename_index)
	main._on_snapshot_selected(rename_index)
	snapshot_scroll_bar.value = snapshot_scroll_limit * 0.55
	main.snapshot_list.grab_focus()
	var rename_snapshot_id := _selected_item_metadata(main.snapshot_list)
	var rename_scroll_before := float(snapshot_scroll_bar.value)
	main._request_rename_selected_snapshot()
	main.snapshot_rename_input.text = "重命名后仍在原位"
	main.snapshot_rename_dialog.hide()
	await process_frame
	main._confirm_rename_selected_snapshot()
	for _frame in range(7):
		await process_frame
	_expect(str(main._find_named_snapshot(rename_snapshot_id).get("name", "")) == "重命名后仍在原位", "通过重命名弹窗保存后必须更新原快照")
	_expect(main.snapshot_list.get_viewport().gui_get_focus_owner() == main.snapshot_list and _selected_item_metadata(main.snapshot_list) == rename_snapshot_id, "重命名确认后必须回到原快照并恢复列表焦点；实际=%s selected=%s dialog=%s list=%s" % [_focus_owner_description(main.snapshot_list), _selected_item_metadata(main.snapshot_list), main.snapshot_manager_dialog.visible, main.snapshot_list.is_visible_in_tree()])
	_expect(absf(float(main.snapshot_list.get_v_scroll_bar().value) - rename_scroll_before) <= 1.0, "重命名确认往返不得把长快照列表跳回顶部")

	var cancel_index := 15
	main.snapshot_list.select(cancel_index)
	main._on_snapshot_selected(cancel_index)
	main.snapshot_list.get_v_scroll_bar().value = snapshot_scroll_limit * 0.7
	main.snapshot_list.grab_focus()
	var canceled_snapshot_id := _selected_item_metadata(main.snapshot_list)
	var cancel_scroll_before := float(main.snapshot_list.get_v_scroll_bar().value)
	main._request_rename_selected_snapshot()
	main.snapshot_rename_dialog.hide()
	await process_frame
	main._cancel_rename_selected_snapshot()
	for _frame in range(7):
		await process_frame
	_expect(main.snapshot_list.get_viewport().gui_get_focus_owner() == main.snapshot_list and _selected_item_metadata(main.snapshot_list) == canceled_snapshot_id, "取消重命名后必须回到原快照并恢复列表焦点；实际=%s selected=%s" % [_focus_owner_description(main.snapshot_list), _selected_item_metadata(main.snapshot_list)])
	_expect(absf(float(main.snapshot_list.get_v_scroll_bar().value) - cancel_scroll_before) <= 1.0, "取消重命名往返不得改变原滚动位置")

	var delete_middle_index := 10
	main.snapshot_list.select(delete_middle_index)
	main._on_snapshot_selected(delete_middle_index)
	main.snapshot_list.get_v_scroll_bar().value = snapshot_scroll_limit * 0.45
	main.snapshot_list.grab_focus()
	var deleted_middle_id := _selected_item_metadata(main.snapshot_list)
	var expected_next_id := str(main.snapshot_list.get_item_metadata(delete_middle_index + 1))
	var middle_scroll_before := float(main.snapshot_list.get_v_scroll_bar().value)
	main._request_delete_selected_snapshot()
	main.snapshot_delete_confirmation_dialog.hide()
	await process_frame
	main._confirm_delete_selected_snapshot()
	for _frame in range(7):
		await process_frame
	_expect(main._find_named_snapshot(deleted_middle_id).is_empty(), "删除中间快照必须移除原记录")
	_expect(main.snapshot_list.get_viewport().gui_get_focus_owner() == main.snapshot_list and _selected_item_metadata(main.snapshot_list) == expected_next_id, "删除中间快照后必须聚焦原顺序下一项；实际=%s selected=%s" % [_focus_owner_description(main.snapshot_list), _selected_item_metadata(main.snapshot_list)])
	_expect(absf(float(main.snapshot_list.get_v_scroll_bar().value) - middle_scroll_before) <= 1.0, "删除中间快照不得无故改变列表滚动位置")

	var delete_last_index: int = main.snapshot_list.item_count - 1
	main.snapshot_list.select(delete_last_index)
	main._on_snapshot_selected(delete_last_index)
	var last_scroll_bar: VScrollBar = main.snapshot_list.get_v_scroll_bar()
	var last_scroll_limit := maxf(0.0, float(last_scroll_bar.max_value) - float(last_scroll_bar.page))
	last_scroll_bar.value = last_scroll_limit
	main.snapshot_list.grab_focus()
	var deleted_last_id := _selected_item_metadata(main.snapshot_list)
	var expected_previous_id := str(main.snapshot_list.get_item_metadata(delete_last_index - 1))
	main._request_delete_selected_snapshot()
	main.snapshot_delete_confirmation_dialog.hide()
	await process_frame
	main._confirm_delete_selected_snapshot()
	for _frame in range(7):
		await process_frame
	_expect(main._find_named_snapshot(deleted_last_id).is_empty(), "删除末尾快照必须移除原记录")
	_expect(main.snapshot_list.get_viewport().gui_get_focus_owner() == main.snapshot_list and _selected_item_metadata(main.snapshot_list) == expected_previous_id, "删除末尾快照后必须聚焦原顺序上一项；实际=%s selected=%s" % [_focus_owner_description(main.snapshot_list), _selected_item_metadata(main.snapshot_list)])
	_expect(float(main.snapshot_list.get_v_scroll_bar().value) > 0.0, "删除末尾快照后长列表不得跳回顶部")

	var only_snapshot: Dictionary = main.named_snapshots[0].duplicate(true)
	var only_snapshots: Array[Dictionary] = [only_snapshot]
	main.named_snapshots = only_snapshots
	_expect(bool(main._write_snapshot_store(main.named_snapshots).get("ok", false)), "唯一快照焦点夹具必须可写入隔离快照库")
	main.snapshot_manager_dialog.hide()
	await process_frame
	main._open_snapshot_manager(str(only_snapshot.get("snapshot_id", "")))
	for _frame in range(3):
		await process_frame
	main._request_delete_selected_snapshot()
	main.snapshot_delete_confirmation_dialog.hide()
	await process_frame
	main._confirm_delete_selected_snapshot()
	for _frame in range(7):
		await process_frame
	_expect(main.named_snapshots.is_empty() and main.snapshot_list.item_count == 0, "删除唯一快照后管理器必须进入空态")
	_expect(main.snapshot_manager_dialog.get_cancel_button().get_viewport().gui_get_focus_owner() == main.snapshot_manager_dialog.get_cancel_button(), "快照删除至空时焦点必须落到可见的关闭动作；实际=%s" % _focus_owner_description(main.snapshot_manager_dialog.get_cancel_button()))

	main.snapshot_manager_dialog.hide()
	main.named_snapshots = focus_snapshots_baseline
	_write_text(auto_snapshots, focus_store_baseline)
	_expect(FileAccess.get_file_as_string(auto_snapshots) == focus_store_baseline, "焦点压力测试结束后快照库字节必须恢复原基线")
	_expect(FileAccess.get_file_as_string(auto_save) == focus_save_baseline and FileAccess.get_file_as_string(auto_preferences) == focus_preferences_baseline, "快照列表焦点链不得改写 v18 当前沙盘或人物收藏")
	_expect(main._undo_stack.size() == focus_history_size, "快照列表焦点链不得进入地图撤销历史")

	var changed_placements: Dictionary = main.placements.duplicate(true)
	changed_placements["zhang_fei"] = {"x": 0.71, "y": 0.22}
	main.scenario_state = _empty_scenario_state()
	main._commit_placements(changed_placements, "继续推演", "测试")
	main.map_board.zoom = 0.88
	main.map_board.pan = Vector2(-20, -10)
	main.map_board._apply_camera()
	main._save()
	var before_restore_placements: Dictionary = main.placements.duplicate(true)
	var before_restore_annotations: Dictionary = main.annotations.duplicate(true)
	var before_restore_camera: Dictionary = main.map_board.get_camera_state()
	var before_restore_metadata: Dictionary = main.sandbox_metadata.duplicate(true)
	var before_restore_scenario_state: Dictionary = main.scenario_state.duplicate(true)
	var history_before_restore: int = main._undo_stack.size()

	var runtime_save_before_export := _snapshot_file(auto_save)
	var runtime_preferences_before_export := _snapshot_file(auto_preferences)
	var runtime_store_before_export := _snapshot_file(auto_snapshots)
	var exported_snapshot_before: Dictionary = main._find_named_snapshot(first_snapshot_id).duplicate(true)
	var export_result: Dictionary = main._write_named_snapshot_transfer_file(snapshot_export_base, first_snapshot_id, false)
	_expect(bool(export_result.get("ok", false)) and FileAccess.file_exists(snapshot_export_path), "选中快照应能导出为自动补扩展名的 .tianxia 文件")
	var exported_document: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(snapshot_export_path))
	_expect(str(exported_document.get("format", "")) == "tianxia_sandbox_backup" and int(exported_document.get("format_version", 0)) == 1, "快照导出必须继续使用外部备份信封 v1")
	_expect(str(exported_document.get("snapshot", {}).get("snapshot_id", "")) == first_snapshot_id and str(exported_document.get("snapshot", {}).get("name", "")) == "汉中决战前", "快照导出应携带来源快照 ID 和当前展示名称")
	var exported_payload_decoded: Dictionary = main._decode_sandbox_document(exported_document.get("sandbox", {}), false)
	var source_payload_decoded: Dictionary = main._decode_sandbox_document(exported_snapshot_before.get("sandbox", {}), false)
	_expect(main._placements_match(exported_payload_decoded.get("placements", {}), source_payload_decoded.get("placements", {})) and main._annotations_match(exported_payload_decoded.get("annotations", {}), source_payload_decoded.get("annotations", {})), "快照导出必须写出快照当时的人物和标记，而不是当前局面")
	_expect(main._camera_states_match(exported_payload_decoded.get("camera", {}), source_payload_decoded.get("camera", {})) and main._sandbox_metadata_match(exported_payload_decoded.get("sandbox_metadata", {}), source_payload_decoded.get("sandbox_metadata", {})), "快照导出必须保留快照当时的视角和完整沙盘身份")
	_expect(_scenario_state_matches(exported_payload_decoded.get("scenario_state", {}), snapshot_source_scenario_state) and _scenario_state_matches(source_payload_decoded.get("scenario_state", {}), snapshot_source_scenario_state), "快照导出必须保留快照当时的场景状态，而不是当前局面")
	_expect(str(exported_document.get("sandbox", {}).get("updated_at", "")) == str(exported_snapshot_before.get("sandbox", {}).get("updated_at", "")), "快照导出不得重建快照的更新时间")
	_expect(not exported_document.get("sandbox", {}).get("cards", []).any(func(card): return str(card.get("character_id", "")) == "zhang_fei"), "快照创建后新增的当前人物不得混入旧快照导出")
	_expect(FileAccess.get_file_as_string(snapshot_export_path).find("favorite_character_ids") == -1 and FileAccess.get_file_as_string(snapshot_export_path).find("snapshot_store_path") == -1, "快照导出不得包含收藏或本机快照路径")
	var exported_read: Dictionary = main._read_sandbox_transfer_file(snapshot_export_path, true)
	_expect(bool(exported_read.get("ok", false)) and str(exported_read.get("source_snapshot_id", "")) == first_snapshot_id and str(exported_read.get("source_snapshot_name", "")) == "汉中决战前", "导出的快照文件应可读回并保留来源快照身份")
	_expect(str(exported_read.get("sandbox_metadata", {}).get("sandbox_id", "")) == initial_id and main._placements_match(exported_read.get("placements", {}), snapshot_source_placements), "快照导出往返应保留来源沙盘身份和人物状态")
	var tampered_export: Dictionary = exported_document.duplicate(true)
	tampered_export["snapshot"]["source_sandbox_id"] = "sbx_tampered"
	_expect(str(main._decode_sandbox_document(tampered_export, true).get("error_code", "")) == "invalid_snapshot_metadata", "来源快照声明与内层沙盘身份不一致时必须拒绝")
	_expect(_same_snapshot(auto_save, runtime_save_before_export) and _same_snapshot(auto_preferences, runtime_preferences_before_export) and _same_snapshot(auto_snapshots, runtime_store_before_export), "导出已有快照不得写当前存档、偏好或快照库")
	_expect(main._placements_match(main.placements, before_restore_placements) and _scenario_state_matches(main.scenario_state, before_restore_scenario_state) and main._sandbox_metadata_match(main.sandbox_metadata, before_restore_metadata) and main._undo_stack.size() == history_before_restore, "快照导出不得改变当前局面、场景状态、身份或历史")

	_write_text(snapshot_export_protected, "SENTINEL")
	var protected_export: Dictionary = main._write_named_snapshot_transfer_file(snapshot_export_protected, first_snapshot_id, false)
	_expect(str(protected_export.get("error_code", "")) == "target_exists" and FileAccess.get_file_as_string(snapshot_export_protected) == "SENTINEL", "未确认覆盖时必须保留同名目标原字节")
	var overwritten_export: Dictionary = main._write_named_snapshot_transfer_file(snapshot_export_protected, first_snapshot_id, true)
	_expect(bool(overwritten_export.get("ok", false)) and str(JSON.parse_string(FileAccess.get_file_as_string(snapshot_export_protected)).get("snapshot", {}).get("snapshot_id", "")) == first_snapshot_id, "明确确认后才可原子替换为选中快照")
	var missing_export: Dictionary = main._write_named_snapshot_transfer_file("user://missing_snapshot_export_automated_test", "snapshot_missing", false)
	_expect(str(missing_export.get("error_code", "")) == "snapshot_not_found" and not FileAccess.file_exists("user://missing_snapshot_export_automated_test.tianxia"), "不存在的快照不得创建导出文件")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(blocked_export_target))
	var failed_export: Dictionary = main._write_named_snapshot_transfer_file(blocked_export_target, first_snapshot_id, true)
	_expect(not bool(failed_export.get("ok", true)) and DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(blocked_export_target)), "外部目标写盘失败时原目录和游戏内快照必须保留")
	main._save_writes_blocked = true
	var protected_save_export: Dictionary = main._write_named_snapshot_transfer_file(snapshot_export_while_save_blocked, first_snapshot_id, false)
	main._save_writes_blocked = false
	_expect(bool(protected_save_export.get("ok", false)), "导出已载入快照是只读动作，不应依赖当前主存档可写")
	_expect(JSON.stringify(main._find_named_snapshot(first_snapshot_id)) == JSON.stringify(exported_snapshot_before), "覆盖保护和失败导出全过程不得修改游戏内快照")

	var restore_result: Dictionary = main._apply_named_snapshot(first_snapshot)
	if not str(restore_result.get("backup_path", "")).is_empty():
		cleanup_backup_paths.append(str(restore_result.get("backup_path", "")))
	_expect(bool(restore_result.get("ok", false)) and not bool(restore_result.get("unchanged", false)), "修改局面后应能恢复命名快照")
	var branch_metadata: Dictionary = main.sandbox_metadata.duplicate(true)
	var branch_id := str(branch_metadata.get("sandbox_id", ""))
	_expect(branch_id != initial_id and main._is_safe_record_id(branch_id), "从快照继续必须建立新的沙盘分支 ID")
	_expect(str(branch_metadata.get("branch_parent_id", "")) == initial_id and str(branch_metadata.get("source_snapshot_id", "")) == first_snapshot_id, "新分支必须指向来源沙盘和来源快照")
	_expect(main._placements_match(main.placements, snapshot_source_placements) and main._annotations_match(main.annotations, snapshot_source_annotations), "恢复命名快照应还原人物和标记")
	_expect(_scenario_state_matches(main.scenario_state, snapshot_source_scenario_state), "恢复命名快照应还原玩法势力与人物分配")
	_expect(main._camera_states_match(main.map_board.get_camera_state(), snapshot_source_camera), "恢复命名快照应还原当时视角")
	_expect(main._undo_stack.size() == history_before_restore + 1 and main.favorite_character_ids.has("liu_bei"), "整次快照恢复应只有一个历史动作且收藏不变")

	main._on_undo_pressed()
	_expect(main._placements_match(main.placements, before_restore_placements) and main._annotations_match(main.annotations, before_restore_annotations), "一次撤销应完整回到恢复前局面")
	_expect(_scenario_state_matches(main.scenario_state, before_restore_scenario_state), "撤销快照恢复应还原恢复前场景状态")
	_expect(main._camera_states_match(main.map_board.get_camera_state(), before_restore_camera) and main._sandbox_metadata_match(main.sandbox_metadata, before_restore_metadata), "撤销快照恢复应同时还原视角和原分支身份")
	main._on_redo_pressed()
	_expect(str(main.sandbox_metadata.get("sandbox_id", "")) == branch_id, "重做必须恢复同一个分支 ID，不能再次生成")
	_expect(str(main.sandbox_metadata.get("source_snapshot_id", "")) == first_snapshot_id, "重做必须保留精确来源快照")
	_expect(_scenario_state_matches(main.scenario_state, snapshot_source_scenario_state), "重做快照恢复必须恢复快照的场景状态")
	var shared_restore: Dictionary = main._apply_import_result(exported_read)
	if not str(shared_restore.get("backup_path", "")).is_empty():
		cleanup_backup_paths.append(str(shared_restore.get("backup_path", "")))
	_expect(bool(shared_restore.get("ok", false)) and not bool(shared_restore.get("unchanged", false)), "从导出的快照文件继续时，即使内容相同也应建立可追溯的新分支")
	var shared_branch_id := str(main.sandbox_metadata.get("sandbox_id", ""))
	_expect(shared_branch_id != branch_id and str(main.sandbox_metadata.get("branch_parent_id", "")) == initial_id, "共享快照文件建立的新分支应直接指向快照来源沙盘")
	_expect(str(main.sandbox_metadata.get("source_snapshot_id", "")) == first_snapshot_id, "从导出的快照文件继续必须保留来源快照 ID")
	_expect(_scenario_state_matches(main.scenario_state, snapshot_source_scenario_state), "从导出的快照文件继续必须保留玩法势力与人物分配")
	branch_id = shared_branch_id

	var backup_document: Dictionary = main._build_sandbox_document()
	_expect(int(backup_document.get("format_version", 0)) == 1 and int(backup_document.get("sandbox", {}).get("save_version", 0)) == 18 and int(backup_document.get("sandbox", {}).get("character_catalog_version", 0)) == 6, "外部备份信封保持 v1，内部沙盘升级为 v18／人物目录 v6")
	_expect(_scenario_state_matches(backup_document.get("sandbox", {}).get("scenario_state", {}), snapshot_source_scenario_state), "外部备份必须保存当前分支的场景状态")
	_expect(str(backup_document.get("sandbox", {}).get("metadata", {}).get("sandbox_id", "")) == branch_id, "外部备份应保留当前分支身份")
	_expect(JSON.stringify(backup_document).find("favorite_character_ids") == -1, "外部备份仍不得包含人物收藏")

	var metadata_before_failure: Dictionary = main.sandbox_metadata.duplicate(true)
	var history_before_failure: int = main._undo_stack.size()
	var normal_save_path: String = main.save_path
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(blocked_save_dir))
	main.save_path = blocked_save_dir
	var failed_metadata: Dictionary = main.sandbox_metadata.duplicate(true)
	failed_metadata["title"] = "不应写入"
	_expect(not main._commit_sandbox_metadata(failed_metadata, "失败测试", "不应出现"), "沙盘信息写盘失败时提交必须失败")
	_expect(main._sandbox_metadata_match(main.sandbox_metadata, metadata_before_failure) and main._undo_stack.size() == history_before_failure, "沙盘信息写盘失败不得改变元数据或历史")
	main.save_path = normal_save_path
	_remove_empty_dir(blocked_save_dir)

	var normal_store_path: String = main.snapshot_store_path
	var snapshot_count_before_failure: int = main.named_snapshots.size()
	var snapshots_before_failure := JSON.stringify(main.named_snapshots)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(blocked_store_dir))
	main.snapshot_store_path = blocked_store_dir
	var failed_snapshot_result: Dictionary = main._create_named_snapshot("不应创建", "写盘失败")
	_expect(not bool(failed_snapshot_result.get("ok", true)) and main.named_snapshots.size() == snapshot_count_before_failure, "快照库写盘失败不得增加内存快照")
	var failed_rename_result: Dictionary = main._rename_named_snapshot(first_snapshot_id, "不应改名")
	_expect(not bool(failed_rename_result.get("ok", true)) and JSON.stringify(main.named_snapshots) == snapshots_before_failure, "快照库写盘失败不得改变内存中的快照名称或内容")
	_expect(main._sandbox_metadata_match(main.sandbox_metadata, metadata_before_failure), "快照创建失败不得改变当前沙盘身份")
	main.snapshot_store_path = normal_store_path
	_remove_empty_dir(blocked_store_dir)

	var delete_result: Dictionary = main._delete_named_snapshot(first_snapshot_id)
	_expect(bool(delete_result.get("ok", false)) and main._find_named_snapshot(first_snapshot_id).is_empty(), "删除命名快照应更新独立快照库而不改变当前沙盘")
	_expect(str(main.sandbox_metadata.get("sandbox_id", "")) == branch_id, "删除来源快照不得改变已经建立的分支身份")

	main.queue_free()
	await process_frame
	var reloaded = packed.instantiate()
	root.add_child(reloaded)
	await process_frame
	await process_frame
	_expect(str(reloaded.sandbox_metadata.get("sandbox_id", "")) == branch_id, "重启后当前分支 ID 必须稳定")
	_expect(_scenario_state_matches(reloaded.scenario_state, snapshot_source_scenario_state), "重启后必须恢复当前分支的场景状态")
	_expect(reloaded.named_snapshots.size() == 1, "重启后应恢复剩余的命名快照")
	_expect(reloaded.favorite_character_ids.has("liu_bei"), "重启后人物收藏应独立恢复")
	reloaded.queue_free()
	await process_frame

	for backup_path in cleanup_backup_paths:
		_remove_file(backup_path)
	_expect(_same_snapshot(formal_save, formal_save_before), "专项测试不得改变正式沙盘存档")
	_expect(_same_snapshot(formal_preferences, formal_preferences_before), "专项测试不得改变正式人物收藏")
	_expect(_same_snapshot(formal_snapshots, formal_snapshots_before), "专项测试不得改变正式命名快照库")
	for path in [auto_save, auto_preferences, auto_snapshots, snapshot_replace_repro, snapshot_write_repro, uncommitted_only_store, uncommitted_only_write, ambiguous_store, ambiguous_replace_a, ambiguous_replace_b, snapshot_export_path, snapshot_export_protected, snapshot_export_while_save_blocked, "user://missing_snapshot_export_automated_test.tianxia"]:
		_remove_file(path)
	for artifact_path in snapshot_stale_artifacts:
		_remove_file(artifact_path)
	_remove_empty_dir(blocked_save_dir)
	_remove_empty_dir(blocked_store_dir)
	_remove_empty_dir(blocked_export_target)

	if failures.is_empty():
		print("SANDBOX_SNAPSHOT_TEST_OK v3_to_v18_catalog6=atomic v4_snapshot=compatible scenario=stable_complete identity=stable metadata=history snapshots=persistent recovery=committed_replace_only+write_ignored+ambiguity_blocked rename=atomic list_focus=return_scroll_delete_neighbor export=roundtrip branch=lineage undo_redo=exact favorites=isolated failures=non_destructive")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
