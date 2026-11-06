extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	main._configure_runtime_profile(PackedStringArray())
	if main.runtime_profile_id != "formal_v18_catalog_v6":
		failures.append("运行标识仍报告旧版，而当前数据为v18/v6")
	main._configure_runtime_profile(PackedStringArray([main.M4_B7_RUNTIME_ARGUMENT]))
	if not FileAccess.file_exists(main.M4_B7_CHARACTER_DATA_ROOT.path_join("character_catalog.json")):
		if main.isolated_catalog_v4_runtime or main.runtime_character_data_root != "res://data":
			failures.append("旧演练参数将发布版切到未提供的目录，人物无法加载")
	main.free()
	if failures.is_empty():
		print("RELEASE_PROFILE_TEST_OK version=18/6 missing_preview=uses_formal_data")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
