class_name CharacterPromotionPolicy
extends RefCounted


const CharacterClaimPolicyScript = preload("res://src/character_claim_policy.gd")
const CHARACTER_KEYS := ["id", "name", "group", "aliases", "affiliations", "source_refs"]
const ATTRIBUTE_KEYS := ["character_id", "might", "intelligence", "leadership", "charisma"]


static func validate_initial_promotion(
	character_value: Variant,
	attribute_value: Variant,
	claim_document_value: Variant,
	runtime_characters_value: Variant,
	source_payload_value: Variant
) -> Dictionary:
	if not character_value is Dictionary:
		return _failure("character_not_dictionary", "待提升人物必须是对象。")
	if not attribute_value is Dictionary:
		return _failure("attribute_not_dictionary", "待提升人物必须同批提供四维。")
	if not runtime_characters_value is Array:
		return _failure("runtime_characters_not_array", "运行人物必须是数组。")
	if not source_payload_value is Dictionary:
		return _failure("source_payload_not_dictionary", "人物来源注册表必须是对象。")
	var character: Dictionary = character_value
	var attribute: Dictionary = attribute_value
	if not _has_exact_keys(character, CHARACTER_KEYS):
		return _failure("invalid_character_keys", "待提升人物字段不完整或包含未登记字段。")
	if not _has_exact_keys(attribute, ATTRIBUTE_KEYS):
		return _failure("invalid_attribute_keys", "待提升人物四维字段不完整或包含未登记字段。")
	var character_id := str(character.get("id", "")).strip_edges()
	if not _is_safe_id(character_id):
		return _failure("invalid_character_id", "待提升人物 ID 无效。")
	var name := str(character.get("name", "")).strip_edges()
	var group := str(character.get("group", "")).strip_edges()
	if name.is_empty() or group.is_empty():
		return _failure("missing_name_or_group", "待提升人物缺少姓名或原型分类。")
	var characters_by_id := {}
	for runtime_character_value in runtime_characters_value:
		if not runtime_character_value is Dictionary:
			return _failure("invalid_runtime_character", "运行人物记录无效。")
		var runtime_character: Dictionary = runtime_character_value
		var runtime_id := str(runtime_character.get("id", "")).strip_edges()
		if runtime_id.is_empty() or characters_by_id.has(runtime_id):
			return _failure("invalid_runtime_catalog", "运行人物 ID 为空或重复。")
		characters_by_id[runtime_id] = runtime_character
	if characters_by_id.has(character_id):
		return _failure("character_id_collision", "待提升人物 ID 已被运行目录使用。")
	characters_by_id[character_id] = character
	if not character.get("aliases", null) is Array or not character.get("affiliations", null) is Array or not character.get("source_refs", null) is Array:
		return _failure("invalid_character_arrays", "别名、史料归属和来源必须是数组。")
	if not (character.get("affiliations", []) as Array).is_empty():
		return _failure("affiliation_requires_separate_audit", "首批提升包不自动接入史料归属；有归属时必须另走完整关系审计。")
	var sources_by_id := {}
	for source_value in source_payload_value.get("sources", []):
		if source_value is Dictionary:
			sources_by_id[str((source_value as Dictionary).get("id", ""))] = source_value
	var claim_result: Dictionary = CharacterClaimPolicyScript.decode_document(claim_document_value, characters_by_id, sources_by_id)
	if not bool(claim_result.get("ok", false)):
		return _failure("invalid_claim_package", "待提升人物事实包无效：%s" % claim_result.get("message", ""))
	var claims_by_character: Dictionary = claim_result.get("claims_by_character", {})
	for claimed_character_id in claims_by_character.keys():
		if str(claimed_character_id) != character_id:
			return _failure("unrelated_claim", "单人提升包不得夹带其他人物事实。")
	var identity_by_character: Dictionary = claim_result.get("identity_by_character", {})
	if not identity_by_character.has(character_id):
		return _failure("missing_identity", "待提升人物必须恰有一条规范姓名身份事实。")
	var expected_aliases: Array[String] = []
	var expected_sources := {}
	for claim_value in claims_by_character.get(character_id, []):
		var claim: Dictionary = claim_value
		if str(claim.get("field", "")) == "alias":
			expected_aliases.append(str(claim.get("value", "")))
		for source_id_value in claim.get("source_refs", []):
			expected_sources[str(source_id_value)] = true
	expected_aliases.sort()
	var actual_aliases: Array[String] = []
	for alias_value in character.get("aliases", []):
		if not alias_value is String or str(alias_value).strip_edges().is_empty():
			return _failure("invalid_alias", "待提升人物别名必须是非空字符串。")
		actual_aliases.append(str(alias_value).strip_edges())
	actual_aliases.sort()
	if actual_aliases != expected_aliases:
		return _failure("alias_cache_mismatch", "待提升人物别名缓存与事实包不一致。")
	var actual_sources := {}
	for source_id_value in character.get("source_refs", []):
		if not source_id_value is String or str(source_id_value).strip_edges().is_empty():
			return _failure("invalid_source_cache", "待提升人物来源缓存含无效 ID。")
		actual_sources[str(source_id_value).strip_edges()] = true
	if actual_sources.is_empty() or actual_sources != expected_sources:
		return _failure("source_cache_mismatch", "待提升人物来源缓存必须与事实包来源并集一致且非空。")
	if str(attribute.get("character_id", "")).strip_edges() != character_id:
		return _failure("attribute_character_mismatch", "四维记录与待提升人物不一致。")
	for dimension in ["might", "intelligence", "leadership", "charisma"]:
		var value: Variant = attribute.get(dimension, null)
		if not _is_integer_in_range(value, 0, 100):
			return _failure("invalid_attribute_value", "四维必须是 0—100 整数：%s。" % dimension)
	return {
		"ok": true,
		"character_id": character_id,
		"identity_claim_id": str((identity_by_character.get(character_id, {}) as Dictionary).get("id", "")),
		"source_count": expected_sources.size(),
	}


static func _has_exact_keys(record: Dictionary, allowed: Array) -> bool:
	if record.size() != allowed.size():
		return false
	for key in record.keys():
		if not allowed.has(str(key)):
			return false
	return true


static func _is_integer_in_range(value: Variant, minimum: int, maximum: int) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] \
		and is_finite(float(value)) \
		and is_equal_approx(float(value), roundf(float(value))) \
		and int(value) >= minimum \
		and int(value) <= maximum


static func _is_safe_id(value: String) -> bool:
	if value.is_empty() or value.length() > 80:
		return false
	var pattern := RegEx.new()
	return pattern.compile("^[a-z0-9][a-z0-9_]*$") == OK and pattern.search(value) != null


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
