class_name CharacterProfilePolicy
extends RefCounted


const SCHEMA_VERSION := 1
const ROOT_KEYS := ["schema_version", "profiles"]
const PROFILE_KEYS := ["character_id", "headline", "biography", "source_refs"]
const HEADLINE_MAX_LENGTH := 40
const BIOGRAPHY_MIN_LENGTH := 40
const BIOGRAPHY_MAX_LENGTH := 240
const SOURCE_REF_LIMIT := 3


static func decode_document(
	document_value: Variant,
	runtime_characters_value: Variant,
	source_registry_document_value: Variant
) -> Dictionary:
	if not document_value is Dictionary:
		return _failure("document_not_dictionary", "人物小传顶层必须是对象。")
	if not runtime_characters_value is Array:
		return _failure("characters_not_array", "人物小传缺少运行人物数组。")
	if not source_registry_document_value is Dictionary:
		return _failure("source_registry_not_dictionary", "人物小传缺少来源登记表。")
	var document: Dictionary = document_value
	var runtime_characters: Array = runtime_characters_value
	var source_registry: Dictionary = source_registry_document_value
	if not _has_exact_keys(document, ROOT_KEYS):
		return _failure("invalid_root_keys", "人物小传根字段不完整或包含未登记字段。")
	if not _is_integer_number(document.get("schema_version", null)) or int(document.get("schema_version")) != SCHEMA_VERSION:
		return _failure("unsupported_schema", "人物小传版本不受支持。")
	if not _is_integer_number(source_registry.get("schema_version", null)) or int(source_registry.get("schema_version")) != 1:
		return _failure("unsupported_source_schema", "人物小传来源登记表版本不受支持。")

	var character_ids := {}
	for character_value in runtime_characters:
		if not character_value is Dictionary:
			return _failure("character_not_dictionary", "运行人物记录必须是对象。")
		var character_id_value: Variant = (character_value as Dictionary).get("id", null)
		if not character_id_value is String:
			return _failure("invalid_character_id", "运行人物 ID 必须是字符串。")
		var character_id := str(character_id_value)
		if not _is_safe_id(character_id) or character_ids.has(character_id):
			return _failure("invalid_or_duplicate_character_id", "运行人物 ID 无效或重复：%s。" % character_id)
		character_ids[character_id] = true
	if character_ids.is_empty():
		return _failure("empty_character_catalog", "人物小传不能在空人物目录上加载。")

	var source_values: Variant = source_registry.get("sources", null)
	if not source_values is Array:
		return _failure("sources_not_array", "人物小传来源登记表缺少 sources 数组。")
	var sources_by_id := {}
	for source_value in source_values:
		if not source_value is Dictionary:
			return _failure("source_not_dictionary", "人物小传来源记录必须是对象。")
		var source: Dictionary = source_value
		var source_id_value: Variant = source.get("id", null)
		if not source_id_value is String:
			return _failure("invalid_source_id", "人物小传来源 ID 必须是字符串。")
		var source_id := str(source_id_value)
		if not _is_safe_id(source_id) or sources_by_id.has(source_id):
			return _failure("invalid_or_duplicate_source_id", "人物小传来源 ID 无效或重复：%s。" % source_id)
		sources_by_id[source_id] = source.duplicate(true)

	var profiles_value: Variant = document.get("profiles", null)
	if not profiles_value is Array:
		return _failure("profiles_not_array", "人物小传 profiles 必须是数组。")
	var profiles: Array = profiles_value
	if profiles.size() != character_ids.size():
		return _failure("incomplete_profile_set", "人物小传必须完整覆盖当前 %d 人。" % character_ids.size())
	var profiles_by_id := {}
	var seen_headlines := {}
	var seen_biographies := {}
	var decoded_profiles: Array[Dictionary] = []
	var source_reference_count := 0
	var used_source_ids := {}
	for index in range(profiles.size()):
		var decoded_result := _decode_profile(
			profiles[index],
			index,
			character_ids,
			sources_by_id,
			profiles_by_id,
			seen_headlines,
			seen_biographies
		)
		if not bool(decoded_result.get("ok", false)):
			return decoded_result
		var profile: Dictionary = (decoded_result.get("profile", {}) as Dictionary).duplicate(true)
		var character_id := str(profile.get("character_id", ""))
		profiles_by_id[character_id] = profile
		decoded_profiles.append(profile)
		for source_ref_value in profile.get("source_refs", []):
			used_source_ids[str(source_ref_value)] = true
			source_reference_count += 1
	return {
		"ok": true,
		"profiles": decoded_profiles,
		"profiles_by_id": profiles_by_id,
		"sources_by_id": sources_by_id,
		"profile_count": decoded_profiles.size(),
		"source_reference_count": source_reference_count,
		"unique_source_count": used_source_ids.size(),
	}


static func _decode_profile(
	value: Variant,
	index: int,
	character_ids: Dictionary,
	sources_by_id: Dictionary,
	profiles_by_id: Dictionary,
	seen_headlines: Dictionary,
	seen_biographies: Dictionary
) -> Dictionary:
	if not value is Dictionary:
		return _failure("profile_not_dictionary", "人物小传第 %d 条必须是对象。" % (index + 1))
	var profile: Dictionary = value
	if not _has_exact_keys(profile, PROFILE_KEYS):
		return _failure("invalid_profile_keys", "人物小传字段不完整或包含未登记字段。")
	var character_id_value: Variant = profile.get("character_id", null)
	if not character_id_value is String:
		return _failure("invalid_profile_character_id", "人物小传 character_id 必须是字符串。")
	var character_id := str(character_id_value)
	if not _is_safe_id(character_id) or not character_ids.has(character_id):
		return _failure("unknown_character", "人物小传引用未知人物：%s。" % character_id)
	if profiles_by_id.has(character_id):
		return _failure("duplicate_profile", "人物小传重复：%s。" % character_id)

	var headline_value: Variant = profile.get("headline", null)
	if not headline_value is String:
		return _failure("invalid_headline", "%s 的人物小传标题必须是字符串。" % character_id)
	var headline := str(headline_value)
	if headline != headline.strip_edges() or headline.is_empty() or headline.length() > HEADLINE_MAX_LENGTH or _contains_control_line_break(headline):
		return _failure("invalid_headline", "%s 的小传标题必须为 1—%d 字且不能带首尾空白或换行。" % [character_id, HEADLINE_MAX_LENGTH])
	if seen_headlines.has(headline):
		return _failure("duplicate_headline", "人物小传标题重复：%s。" % headline)

	var biography_value: Variant = profile.get("biography", null)
	if not biography_value is String:
		return _failure("invalid_biography", "%s 的人物小传正文必须是字符串。" % character_id)
	var biography := str(biography_value)
	if biography != biography.strip_edges() \
			or biography.length() < BIOGRAPHY_MIN_LENGTH \
			or biography.length() > BIOGRAPHY_MAX_LENGTH \
			or _contains_control_line_break(biography):
		return _failure("invalid_biography", "%s 的人物小传必须为 %d—%d 字且不能带首尾空白或换行。" % [character_id, BIOGRAPHY_MIN_LENGTH, BIOGRAPHY_MAX_LENGTH])
	if seen_biographies.has(biography):
		return _failure("duplicate_biography", "人物小传正文重复：%s。" % character_id)

	var source_ref_values: Variant = profile.get("source_refs", null)
	if not source_ref_values is Array or source_ref_values.is_empty() or source_ref_values.size() > SOURCE_REF_LIMIT:
		return _failure("invalid_source_count", "%s 的人物小传必须引用 1—%d 个固定来源。" % [character_id, SOURCE_REF_LIMIT])
	var source_refs: Array[String] = []
	var seen_source_refs := {}
	for source_ref_value in source_ref_values:
		if not source_ref_value is String:
			return _failure("invalid_source_ref", "%s 的人物小传来源 ID 必须是字符串。" % character_id)
		var source_ref := str(source_ref_value)
		if not _is_safe_id(source_ref) or seen_source_refs.has(source_ref) or not sources_by_id.has(source_ref):
			return _failure("duplicate_or_unknown_source", "%s 的人物小传含空白、重复、无效或未知来源。" % character_id)
		var source: Dictionary = sources_by_id.get(source_ref, {})
		if str(source.get("layer", "")) != "historical":
			return _failure("source_layer_mismatch", "%s 的人物小传当前只能引用历史层来源。" % character_id)
		if str(source.get("usage_status", "")) != "reference_only":
			return _failure("source_usage_mismatch", "%s 的人物小传来源必须保持 reference_only。" % character_id)
		var roles_value: Variant = source.get("roles", null)
		if not roles_value is Array or not (roles_value as Array).has("character_identity"):
			return _failure("source_role_mismatch", "%s 的人物小传来源缺少 character_identity 用途。" % character_id)
		seen_source_refs[source_ref] = true
		source_refs.append(source_ref)
	seen_headlines[headline] = true
	seen_biographies[biography] = true
	return {
		"ok": true,
		"profile": {
			"character_id": character_id,
			"headline": headline,
			"biography": biography,
			"source_refs": source_refs,
		},
	}


static func _has_exact_keys(record: Dictionary, allowed: Array) -> bool:
	if record.size() != allowed.size():
		return false
	for key_value in record.keys():
		if not allowed.has(str(key_value)):
			return false
	return true


static func _contains_control_line_break(value: String) -> bool:
	return "\n" in value or "\r" in value or "\t" in value


static func _is_integer_number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] \
		and is_finite(float(value)) \
		and is_equal_approx(float(value), roundf(float(value)))


static func _is_safe_id(value: String) -> bool:
	if value.is_empty() or value != value.strip_edges() or value.length() > 96:
		return false
	var pattern := RegEx.new()
	return pattern.compile("^[a-z0-9][a-z0-9_]*$") == OK and pattern.search(value) != null


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
