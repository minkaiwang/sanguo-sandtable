extends SceneTree


var failures: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


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


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_path := "user://sandbox_save_automated_test.json"
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_expect(main.undo_button.disabled and main.redo_button.disabled, "初始撤销与重做按钮应禁用")
	var scenario_before_actions := {
		"scenario_id": "custom_blank",
		"start_year": null,
		"era_label": "完全自定义",
		"scenario_kind": "custom",
		"featured_character_ids": [],
		"history_layer_ids": [],
		"factions": [{"id": "play_history_test", "name": "历史栈测试势力", "color": "#0077BB"}],
		"character_assignments": [{"character_id": "liu_bei", "faction_id": "play_history_test"}],
		"city_ownership": []
	}
	main.scenario_state = scenario_before_actions.duplicate(true)
	_expect(main._save(), "历史测试的 v16 完整场景状态应能写入隔离存档")

	main._on_character_dropped("liu_bei", Vector2(0.20, 0.30))
	_expect(main.placements.has("liu_bei"), "摆放刘备应生效")
	_expect(_scenario_state_matches(main.scenario_state, scenario_before_actions), "普通摆放不得改变玩法势力状态")
	main._on_undo_pressed()
	_expect(not main.placements.has("liu_bei"), "撤销摆放应让刘备回到背包")
	_expect(_scenario_state_matches(main.scenario_state, scenario_before_actions), "撤销摆放不得丢失玩法势力状态")
	main._on_redo_pressed()
	_expect(main.placements.has("liu_bei"), "重做摆放应恢复刘备")
	_expect(_scenario_state_matches(main.scenario_state, scenario_before_actions), "重做摆放不得丢失玩法势力状态")

	main._on_character_dropped("liu_bei", Vector2(0.40, 0.50))
	main._on_undo_pressed()
	var restored_position: Dictionary = main.placements.get("liu_bei", {})
	_expect(is_equal_approx(float(restored_position.get("x", 0.0)), 0.20), "撤销移动应恢复原坐标")
	main._on_redo_pressed()
	var moved_position: Dictionary = main.placements.get("liu_bei", {})
	_expect(is_equal_approx(float(moved_position.get("x", 0.0)), 0.40), "重做移动应恢复新坐标")

	main._on_character_returned("liu_bei")
	_expect(not main.placements.has("liu_bei"), "收回后人物应离开地图")
	main._on_undo_pressed()
	_expect(main.placements.has("liu_bei"), "撤销收回应恢复人物")

	var before_clear: Dictionary = main.placements.duplicate(true)
	main._on_clear_pressed()
	_expect(main.placements.is_empty(), "清空应移除全部人物")
	main._on_undo_pressed()
	_expect(main._placements_match(main.placements, before_clear), "一次撤销应完整恢复清空前状态")
	_expect(_scenario_state_matches(main.scenario_state, scenario_before_actions), "清空及其撤销不得改写场景状态")

	main._on_character_dropped("zhang_jiao", Vector2(0.60, 0.60))
	_expect(main.redo_button.disabled, "撤销后执行新动作应清空重做分支")
	var undo_count: int = main._undo_stack.size()
	main._on_character_dropped("zhang_jiao", Vector2(0.60, 0.60))
	_expect(main._undo_stack.size() == undo_count, "原地重复落点不应产生历史")

	main.queue_free()
	await process_frame
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if failures.is_empty():
		print("HISTORY_TEST_OK place=pass move=pass return=pass clear=atomic branch=pass noop=pass scenario_state=v16_stable")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
