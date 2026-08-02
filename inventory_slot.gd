var it := item as Dictionary
var lines := []
var item_name := str(it.get("name", "Unknown Item"))
var rarity := str(it.get("rarity", ""))
lines.append(item_name if rarity.is_empty() else rarity + " " + item_name)

var item_type := str(it.get("type", ""))
if not item_type.is_empty():
	lines.append(item_type.capitalize())

for stat_name in ["damage","defense","speed","magic","strength","vitality","intellegience","intelligence","dexterity"]:
	if it.has(stat_name):
		var display_name := "Intelligence" if stat_name == "intellegience" else stat_name.capitalize()
		lines.append("+" + str(it[stat_name]) + " " + display_name)

if item_type == "consumable":
	var use_effect := str(it.get("use_effect", ""))
	var use_amount := int(it.get("use_amount", 0))
	lines.append("Use: +" + str(use_amount) + " " + use_effect.capitalize())
	lines.append("Left click to use")
elif item_type == "weapon":
	var weapon_class := str(it.get("weapon_class", ""))
	if not weapon_class.is_empty():
		lines.append("Class: " + weapon_class.capitalize())
	lines.append("Drag to weapon slot")
else:
	lines.append("Drag to matching equipment slot")

return "\n".join(lines)
