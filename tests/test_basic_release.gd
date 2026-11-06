extends SceneTree

func _init() -> void:
	call_deferred("_start_check")

func _start_check() -> void:
	root.add_child(load("res://tests/basic_release_probe.gd").new())
