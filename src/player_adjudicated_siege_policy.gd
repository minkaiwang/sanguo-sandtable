class_name PlayerAdjudicatedSiegePolicy
extends RefCounted


const SIDE_ATTACKER := "attacker"
const SIDE_DEFENDER := "defender"

const OUTCOME_ATTACKER_WIN := "attacker_win"
const OUTCOME_DEFENDER_WIN := "defender_win"
const OUTCOME_TRUCE := "truce"
const OUTCOME_ATTACKER_RETREAT := "attacker_retreat"
const OUTCOME_DEFENDER_RETREAT := "defender_retreat"
const OUTCOME_UNRESOLVED := "unresolved"
const OUTCOMES := [
	OUTCOME_ATTACKER_WIN,
	OUTCOME_DEFENDER_WIN,
	OUTCOME_TRUCE,
	OUTCOME_ATTACKER_RETREAT,
	OUTCOME_DEFENDER_RETREAT,
	OUTCOME_UNRESOLVED,
]

const HANDLING_KEEP := "keep"
const HANDLING_RETURN_ALL := "return_all"
const HANDLING_RETURN_SELECTED := "return_selected"
const HANDLING_DEFER := "defer"
const HANDLINGS := [HANDLING_KEEP, HANDLING_RETURN_ALL, HANDLING_RETURN_SELECTED, HANDLING_DEFER]


static func normalize_ids(values: Array, allowed_ids: Array = []) -> Array[String]:
	var allowed: Dictionary = {}
	for allowed_value in allowed_ids:
		allowed[str(allowed_value)] = true
	var result: Array[String] = []
	for value in values:
		var character_id := str(value).strip_edges()
		if character_id.is_empty() or character_id in result:
			continue
		if not allowed.is_empty() and not allowed.has(character_id):
			continue
		result.append(character_id)
	return result


static func validate_start(target_place_id: String, attacker_ids: Array, defender_ids: Array, placed_ids: Array, valid_city_ids: Array) -> Dictionary:
	var normalized_place_id := target_place_id.strip_edges()
	var allowed_placed := normalize_ids(placed_ids)
	var attackers := normalize_ids(attacker_ids, allowed_placed)
	var defenders := normalize_ids(defender_ids, allowed_placed)
	if normalized_place_id.is_empty() or normalized_place_id not in normalize_ids(valid_city_ids):
		return {"ok": false, "message": "请先选择一座有效城池。"}
	if attackers.is_empty():
		return {"ok": false, "message": "进攻方至少需要一名当前在地图上的人物。"}
	if defenders.is_empty():
		return {"ok": false, "message": "防守方至少需要一名当前在地图上的人物。"}
	for character_id in attackers:
		if character_id in defenders:
			return {"ok": false, "message": "同一人物不能同时属于进攻方和防守方。"}
	return {
		"ok": true,
		"target_place_id": normalized_place_id,
		"attacker_ids": attackers,
		"defender_ids": defenders,
		"participant_ids": attackers + defenders,
	}


static func defeated_side(outcome: String) -> String:
	match outcome:
		OUTCOME_ATTACKER_WIN, OUTCOME_DEFENDER_RETREAT:
			return SIDE_DEFENDER
		OUTCOME_DEFENDER_WIN, OUTCOME_ATTACKER_RETREAT:
			return SIDE_ATTACKER
		_:
			return ""


static func defeated_candidates(outcome: String, attacker_ids: Array, defender_ids: Array, placements: Dictionary) -> Array[String]:
	var side := defeated_side(outcome)
	var source: Array = attacker_ids if side == SIDE_ATTACKER else defender_ids
	if side.is_empty():
		return []
	return normalize_ids(source, placements.keys())


static func resolve_return_ids(outcome: String, handling: String, selected_ids: Array, attacker_ids: Array, defender_ids: Array, placements: Dictionary) -> Dictionary:
	if outcome not in OUTCOMES:
		return {"ok": false, "message": "玩家裁定结果无效。"}
	if handling not in HANDLINGS:
		return {"ok": false, "message": "局面处理方式无效。"}
	if handling in [HANDLING_KEEP, HANDLING_DEFER]:
		return {"ok": true, "return_ids": []}
	var candidates := defeated_candidates(outcome, attacker_ids, defender_ids, placements)
	if candidates.is_empty():
		return {"ok": false, "message": "这个结果没有战败方，不能执行收回。"}
	if handling == HANDLING_RETURN_ALL:
		return {"ok": true, "return_ids": candidates}
	var selected := normalize_ids(selected_ids, candidates)
	if selected.is_empty():
		return {"ok": false, "message": "请至少勾选一名要收回卡包的人物。"}
	return {"ok": true, "return_ids": selected}


static func placements_without(state_placements: Dictionary, return_ids: Array) -> Dictionary:
	var next_placements := state_placements.duplicate(true)
	for character_id in normalize_ids(return_ids):
		next_placements.erase(character_id)
	return next_placements


static func outcome_label(outcome: String) -> String:
	match outcome:
		OUTCOME_ATTACKER_WIN:
			return "进攻方取胜"
		OUTCOME_DEFENDER_WIN:
			return "防守方取胜"
		OUTCOME_TRUCE:
			return "双方罢战／平局"
		OUTCOME_ATTACKER_RETREAT:
			return "进攻方主动撤退"
		OUTCOME_DEFENDER_RETREAT:
			return "防守方主动撤退"
		_:
			return "尚未分出结果"


static func handling_label(handling: String) -> String:
	match handling:
		HANDLING_RETURN_ALL:
			return "战败方整方收回卡包"
		HANDLING_RETURN_SELECTED:
			return "收回选中的战败人物"
		HANDLING_DEFER:
			return "暂不处理，返回地图"
		_:
			return "保持人物当前位置"
