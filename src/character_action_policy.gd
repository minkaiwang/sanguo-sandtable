class_name CharacterActionPolicy
extends RefCounted

## 人物行动是玩家在当前沙盘中的整理标签。
## 这里只维护稳定的枚举、显示名称和视觉提示；不负责移动、战斗或胜负计算。

const DEFAULT_ACTION := "standby"
const ACTION_STANDBY := "standby"
const ACTION_ATTACK := "attack"
const ACTION_DEFEND := "defend"

const ACTION_DEFINITIONS := [
	{"action": ACTION_STANDBY, "label": "待命", "short": "待", "section": "战场", "color": "#59645A", "hint": "暂留原处，等待下一步安排"},
	{"action": ACTION_ATTACK, "label": "进攻", "short": "攻", "section": "战场", "color": "#B6533F", "hint": "标记为准备进攻"},
	{"action": ACTION_DEFEND, "label": "防御", "short": "防", "section": "战场", "color": "#3F727A", "hint": "标记为准备防御"},
]

const ACTION_VALUES := [
	ACTION_STANDBY,
	ACTION_ATTACK,
	ACTION_DEFEND,
]

const STORED_ACTION_VALUES := [
	ACTION_ATTACK,
	ACTION_DEFEND,
]


static func definitions() -> Array:
	return ACTION_DEFINITIONS.duplicate(true)


static func action_values() -> Array[String]:
	return ACTION_VALUES.duplicate()


static func stored_action_values() -> Array[String]:
	return STORED_ACTION_VALUES.duplicate()


static func is_valid_action(action: String) -> bool:
	return action in ACTION_VALUES


static func is_stored_action(action: String) -> bool:
	return action in STORED_ACTION_VALUES


static func normalize(action: String) -> String:
	return action if is_valid_action(action) else DEFAULT_ACTION


static func label(action: String) -> String:
	for definition in ACTION_DEFINITIONS:
		if str(definition.get("action", "")) == action:
			return str(definition.get("label", ""))
	return "待命"


static func short_label(action: String) -> String:
	for definition in ACTION_DEFINITIONS:
		if str(definition.get("action", "")) == action:
			return str(definition.get("short", "待"))
	return "待"


static func section(action: String) -> String:
	for definition in ACTION_DEFINITIONS:
		if str(definition.get("action", "")) == action:
			return str(definition.get("section", "战场"))
	return "战场"


static func color(action: String) -> Color:
	for definition in ACTION_DEFINITIONS:
		if str(definition.get("action", "")) == action:
			return Color(str(definition.get("color", "#59645A")))
	return Color("#59645A")


static func hint(action: String) -> String:
	for definition in ACTION_DEFINITIONS:
		if str(definition.get("action", "")) == action:
			return str(definition.get("hint", ""))
	return "暂留原处，等待下一步安排"


static func empty_counts() -> Dictionary:
	var result := {}
	for action in ACTION_VALUES:
		result[action] = 0
	return result
