extends RefCounted


const PRESET_HEX := [
	"#0077BB",
	"#EE7733",
	"#009988",
	"#CC3311",
	"#AA4499",
	"#33BBEE",
	"#332288",
	"#117733",
	"#999933",
	"#DDCC77",
	"#CC6677",
	"#882255"
]
const UNASSIGNED_HEX := "#737B72"
const _HEX_DIGITS := "0123456789ABCDEF"


static func normalize_hex(value: Variant) -> String:
	var text := str(value).strip_edges()
	if text.length() != 7 or not text.begins_with("#"):
		return ""
	var digits := text.substr(1).to_upper()
	for character in digits:
		if _HEX_DIGITS.find(character) < 0:
			return ""
	return "#%s" % digits


static func is_canonical_hex(value: Variant) -> bool:
	var text := str(value)
	return not text.is_empty() and normalize_hex(text) == text


static func default_hex(index: int) -> String:
	return PRESET_HEX[posmod(index, PRESET_HEX.size())]


static func first_unused_hex(factions: Array) -> String:
	var used: Dictionary = {}
	for faction_value in factions:
		if faction_value is Dictionary:
			var normalized := normalize_hex((faction_value as Dictionary).get("color", ""))
			if not normalized.is_empty():
				used[normalized] = true
	for preset in PRESET_HEX:
		if not used.has(preset):
			return preset
	return default_hex(factions.size())


static func to_color(value: Variant, fallback := Color("737B72")) -> Color:
	var normalized := normalize_hex(value)
	return Color.from_string(normalized, fallback) if not normalized.is_empty() else fallback


static func to_hex(value: Color) -> String:
	return "#%s" % value.to_html(false).to_upper()


static func render_on_light(value: Variant, background := Color("F4E7C5"), target_ratio := 3.0) -> Color:
	return _adjust_toward(to_color(value), background, Color.BLACK, target_ratio)


static func render_on_dark(value: Variant, background := Color("0B120F"), target_ratio := 3.0) -> Color:
	return _adjust_toward(to_color(value), background, Color.WHITE, target_ratio)


static func contrast_ratio(first: Color, second: Color) -> float:
	var lighter := maxf(_relative_luminance(first), _relative_luminance(second))
	var darker := minf(_relative_luminance(first), _relative_luminance(second))
	return (lighter + 0.05) / (darker + 0.05)


static func _adjust_toward(raw: Color, background: Color, target: Color, target_ratio: float) -> Color:
	if contrast_ratio(raw, background) >= target_ratio:
		return raw
	for step in range(1, 17):
		var candidate := raw.lerp(target, float(step) / 16.0)
		if contrast_ratio(candidate, background) >= target_ratio:
			return candidate
	return target


static func _relative_luminance(value: Color) -> float:
	return 0.2126 * _linear_channel(value.r) \
		+ 0.7152 * _linear_channel(value.g) \
		+ 0.0722 * _linear_channel(value.b)


static func _linear_channel(value: float) -> float:
	return value / 12.92 if value <= 0.04045 else pow((value + 0.055) / 1.055, 2.4)
