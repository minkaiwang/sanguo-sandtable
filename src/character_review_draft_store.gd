class_name CharacterReviewDraftStore
extends RefCounted


static func write_json(path: String, document: Dictionary) -> Dictionary:
	if path.is_empty() or not path.begins_with("res://artifacts/"):
		return {"ok": false, "message": "审核草稿只能写入项目 artifacts。"}
	var absolute_path := ProjectSettings.globalize_path(path)
	var parent := absolute_path.get_base_dir()
	var make_error := DirAccess.make_dir_recursive_absolute(parent)
	if make_error != OK:
		return {"ok": false, "message": "无法建立审核记录目录。"}
	var temporary_path := absolute_path + ".tmp"
	var previous_path := absolute_path + ".previous"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "无法写入审核记录临时文件。"}
	file.store_string(JSON.stringify(document, "\t") + "\n")
	file.flush()
	file.close()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(temporary_path))
	if not (parsed is Dictionary):
		DirAccess.remove_absolute(temporary_path)
		return {"ok": false, "message": "审核记录临时文件校验失败。"}
	if FileAccess.file_exists(absolute_path):
		if FileAccess.file_exists(previous_path):
			DirAccess.remove_absolute(previous_path)
		var backup_error := DirAccess.copy_absolute(absolute_path, previous_path)
		if backup_error != OK:
			DirAccess.remove_absolute(temporary_path)
			return {"ok": false, "message": "无法保护上一份审核记录。"}
		DirAccess.remove_absolute(absolute_path)
	var rename_error := DirAccess.rename_absolute(temporary_path, absolute_path)
	if rename_error != OK:
		if FileAccess.file_exists(previous_path):
			DirAccess.copy_absolute(previous_path, absolute_path)
		DirAccess.remove_absolute(temporary_path)
		return {"ok": false, "message": "审核记录原子替换失败。"}
	return {"ok": true, "path": path}
