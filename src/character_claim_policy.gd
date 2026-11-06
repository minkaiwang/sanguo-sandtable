class_name CharacterClaimPolicy
extends RefCounted


const SCHEMA_VERSION := 2
const ROOT_KEYS := ["schema_version", "claims"]
const CLAIM_KEYS := [
	"id", "character_id", "field", "value", "layer",
	"source_refs", "source_locator", "confidence"
]
const ALLOWED_FIELDS := ["identity", "alias", "affiliation"]
const ALLOWED_LAYERS := ["historical", "romance"]
const AFFILIATION_CONFIDENCE := ["text_explicit", "source_inferred", "approximate", "disputed"]


static func decode_document(document_value: Variant, characters_by_id: Dictionary, sources_by_id: Dictionary) -> Dictionary:
	if not document_value is Dictionary:
		return _failure("document_not_dictionary", "人物事实表顶层必须是对象。")
	var document: Dictionary = document_value
	if not _has_exact_keys(document, ROOT_KEYS):
		return _failure("invalid_root_keys", "人物事实表根字段不完整或包含未登记字段。")
	if not _is_integer(document.get("schema_version", null)) or int(document.get("schema_version")) != SCHEMA_VERSION:
		return _failure("unsupported_schema", "人物事实表版本不受支持。")
	var claims_value: Variant = document.get("claims", null)
	if not claims_value is Array:
		return _failure("claims_not_array", "人物事实表 claims 必须是数组。")
	var claim_ids := {}
	var fact_keys := {}
	var identity_by_character := {}
	var claims_by_character := {}
	var decoded_claims: Array[Dictionary] = []
	for claim_value in claims_value:
		var result := validate_record(claim_value, characters_by_id, sources_by_id)
		if not bool(result.get("ok", false)):
			return result
		var claim: Dictionary = (result.get("claim", {}) as Dictionary).duplicate(true)
		var claim_id := str(claim.get("id", ""))
		if claim_ids.has(claim_id):
			return _failure("duplicate_claim_id", "人物事实 ID 重复：%s。" % claim_id)
		claim_ids[claim_id] = true
		var character_id := str(claim.get("character_id", ""))
		var field := str(claim.get("field", ""))
		var value := str(claim.get("value", ""))
		var fact_key := "%s|%s|%s" % [character_id, field, value]
		if fact_keys.has(fact_key):
			return _failure("duplicate_fact", "人物事实重复：%s。" % fact_key)
		fact_keys[fact_key] = true
		if field == "identity":
			if identity_by_character.has(character_id):
				return _failure("duplicate_identity", "人物只能有一条规范姓名身份事实：%s。" % character_id)
			identity_by_character[character_id] = claim
		if not claims_by_character.has(character_id):
			claims_by_character[character_id] = []
		(claims_by_character[character_id] as Array).append(claim)
		decoded_claims.append(claim)
	return {
		"ok": true,
		"claims": decoded_claims,
		"claims_by_character": claims_by_character,
		"identity_by_character": identity_by_character,
	}


static func validate_record(claim_value: Variant, characters_by_id: Dictionary, sources_by_id: Dictionary) -> Dictionary:
	if not claim_value is Dictionary:
		return _failure("claim_not_dictionary", "人物事实记录必须是对象。")
	var claim: Dictionary = claim_value
	if not _has_exact_keys(claim, CLAIM_KEYS):
		return _failure("invalid_claim_keys", "人物事实字段不完整或包含未登记字段。")
	var claim_id := str(claim.get("id", "")).strip_edges()
	if not _is_safe_id(claim_id):
		return _failure("invalid_claim_id", "人物事实 ID 无效：%s。" % claim_id)
	var character_id := str(claim.get("character_id", "")).strip_edges()
	if not characters_by_id.has(character_id):
		return _failure("unknown_character", "人物事实引用未知人物：%s。" % character_id)
	var field := str(claim.get("field", "")).strip_edges()
	if not ALLOWED_FIELDS.has(field):
		return _failure("invalid_field", "人物事实字段无效：%s。" % field)
	var value := str(claim.get("value", "")).strip_edges()
	if value.is_empty():
		return _failure("empty_value", "人物事实值不得为空。")
	var layer := str(claim.get("layer", "")).strip_edges()
	if not ALLOWED_LAYERS.has(layer):
		return _failure("invalid_layer", "人物身份、别名和归属事实只能属于历史或演义层。")
	var confidence := str(claim.get("confidence", "")).strip_edges()
	if field in ["identity", "alias"]:
		if confidence != "text_explicit":
			return _failure("invalid_explicit_confidence", "规范姓名与别名事实必须由原文明载。")
	elif not AFFILIATION_CONFIDENCE.has(confidence):
		return _failure("invalid_affiliation_confidence", "人物归属事实置信度无效。")
	if field == "identity":
		var canonical_name := str((characters_by_id.get(character_id, {}) as Dictionary).get("name", "")).strip_edges()
		if value != canonical_name:
			return _failure("identity_name_mismatch", "规范姓名事实必须与人物当前显示名完全一致：%s。" % character_id)
	if str(claim.get("source_locator", "")).strip_edges().is_empty():
		return _failure("missing_source_locator", "人物事实缺少原文定位：%s。" % claim_id)
	var source_values: Variant = claim.get("source_refs", null)
	if not source_values is Array or source_values.is_empty():
		return _failure("missing_sources", "人物事实至少需要一条固定版本来源：%s。" % claim_id)
	var seen_sources := {}
	var expected_role: String = str({
		"identity": "character_identity",
		"alias": "character_alias",
		"affiliation": "character_affiliation",
	}.get(field, ""))
	for source_id_value in source_values:
		if not source_id_value is String:
			return _failure("invalid_source_id", "人物事实来源 ID 必须是字符串：%s。" % claim_id)
		var source_id := str(source_id_value).strip_edges()
		if source_id.is_empty() or seen_sources.has(source_id):
			return _failure("duplicate_or_empty_source", "人物事实来源为空或重复：%s。" % claim_id)
		seen_sources[source_id] = true
		if not sources_by_id.has(source_id):
			return _failure("unknown_source", "人物事实引用未知来源：%s。" % source_id)
		var source: Dictionary = sources_by_id.get(source_id, {})
		if str(source.get("layer", "")) != layer:
			return _failure("source_layer_mismatch", "人物事实与来源层级不一致：%s。" % claim_id)
		if not (source.get("roles", []) as Array).has(expected_role):
			return _failure("source_role_mismatch", "人物事实来源用途不匹配：%s。" % claim_id)
	return {"ok": true, "claim": claim.duplicate(true)}


static func _has_exact_keys(record: Dictionary, allowed: Array) -> bool:
	if record.size() != allowed.size():
		return false
	for key in record.keys():
		if not allowed.has(str(key)):
			return false
	return true


static func _is_integer(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) and is_equal_approx(float(value), roundf(float(value)))


static func _is_safe_id(value: String) -> bool:
	if value.is_empty() or value.length() > 96:
		return false
	var pattern := RegEx.new()
	return pattern.compile("^[a-z0-9][a-z0-9_]*$") == OK and pattern.search(value) != null


static func _failure(error_code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": error_code, "message": message}
