extends Control

var item = null
var icon = null


func _ready():
	icon = find_child("TextureRect", true, false)
	_apply_item()


func set_item(new_item):
	item = new_item

	if icon != null:
		_apply_item()


func _apply_item():
	if item and item.has("icon"):
		icon.texture = item["icon"]
	else:
		icon.texture = null

	tooltip_text = _build_item_tooltip()
	var panel := find_child("Panel", true, false) as Control
	if panel != null:
		panel.tooltip_text = tooltip_text
	if icon is Control:
		icon.tooltip_text = tooltip_text
		icon.mouse_filter = Control.MOUSE_FILTER_PASS

func _build_item_tooltip() -> String:
	if not (item is Dictionary):
		return ""

	var lines: Array[String] = []
	var item_name := str(item.get("name", "Unknown Item"))
	var rarity := str(item.get("rarity", ""))
	lines.append(item_name if rarity.is_empty() else rarity + " " + item_name)

	var item_type := str(item.get("type", ""))
	if not item_type.is_empty():
		lines.append(item_type.capitalize())

	for stat_name in ["damage", "defense", "speed", "magic", "strength", "vitality", "intellegience", "intelligence", "dexterity"]:
		if item.has(stat_name):
			var display_name: String = "Intelligence" if stat_name == "intellegience" else stat_name.capitalize()
			lines.append("+" + str(item[stat_name]) + " " + display_name)

	if item_type == "consumable":
		var use_effect := str(item.get("use_effect", ""))
		var use_amount: Variant = item.get("use_amount", 0)
		lines.append("Use: +" + str(use_amount) + " " + use_effect.capitalize())
		lines.append("Left click to use")
	elif item_type == "weapon":
		var weapon_class := str(item.get("weapon_class", ""))
		if not weapon_class.is_empty():
			lines.append("Class: " + weapon_class.capitalize())
		lines.append("Drag to weapon slot")
	else:
		lines.append("Drag to matching equipment slot")

	return "\n".join(lines)


func _get_drag_data(position):
	if item == null:
		return null

	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(100, 100)

	var preview = TextureRect.new()
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(100, 100)

	container.add_child(preview)

	set_drag_preview(container)

	return {
		"item": item,
		"from": self
	}

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var grid := get_parent()
		var weapons_panel = grid.get_parent() if grid != null else null
		if weapons_panel != null and weapons_panel.has_method("consume_slot") and weapons_panel.consume_slot(self):
			accept_event()


func _can_drop_data(position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("item")


func _drop_data(position, data):
	var from_slot = data["from"]
	var incoming_item = data["item"]

	var temp = item
	set_item(incoming_item)

	if from_slot and from_slot != self:
		from_slot.set_item(temp)
