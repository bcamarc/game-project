extends Control

var item = null
var icon = null

# Tooltip support
var ItemTooltipScript := preload("res://item_tooltip.gd")
var _tooltip_instance = null

func _ready():
	icon = find_child("TextureRect", true, false)
	_apply_item()

	# connect hover signals (TextureRect is a Control)
	if icon is Control:
		if not icon.is_connected("mouse_entered", self, "_on_icon_mouse_entered"):
			icon.connect("mouse_entered", self, "_on_icon_mouse_entered")
		if not icon.is_connected("mouse_exited", self, "_on_icon_mouse_exited"):
			icon.connect("mouse_exited", self, "_on_icon_mouse_exited")

func set_item(new_item) -> void:
	item = new_item

	if icon != null:
		_apply_item()

func _apply_item() -> void:
	if item and item.has("icon"):
		if icon != null:
			icon.texture = item["icon"]
	else:
		if icon != null:
			icon.texture = null

	var tooltip_text = _build_item_tooltip()
	var panel := find_child("Panel", true, false) as Control
	if panel != null:
		panel.tooltip_text = tooltip_text
	if icon is Control:
		icon.tooltip_text = tooltip_text
		icon.mouse_filter = Control.MOUSE_FILTER_PASS

func _build_item_tooltip() -> String:
	# ensure item is a Dictionary before treating it as one
	if not (item is Dictionary):
		return ""

	var it = item as Dictionary
	var lines = []
	var item_name = str(it.get("name", "Unknown Item"))
	var rarity = str(it.get("rarity", ""))
	lines.append(item_name if rarity == "" else rarity + " " + item_name)

	var item_type = str(it.get("type", ""))
	if item_type != "":
		lines.append(item_type.capitalize())

	for stat_name in ["damage", "defense", "speed", "magic", "strength", "vitality", "intellegience", "intelligence", "dexterity"]:
		if it.has(stat_name):
			var display_name = ("Intelligence" if stat_name == "intellegience" else stat_name.capitalize())
			lines.append("+" + str(it[stat_name]) + " " + display_name)

	if item_type == "consumable":
		var use_effect = str(it.get("use_effect", ""))
		var use_amount = int(it.get("use_amount", 0))
		lines.append("Use: +" + str(use_amount) + " " + use_effect.capitalize())
		lines.append("Left click to use")
	elif item_type == "weapon":
		var weapon_class = str(it.get("weapon_class", ""))
		if weapon_class != "":
			lines.append("Class: " + weapon_class.capitalize())
		lines.append("Drag to weapon slot")
	else:
		lines.append("Drag to matching equipment slot")

	return "\n".join(lines)

func _get_drag_data(position):
	if item == null:
		return null

	# hide tooltip while dragging
	if _tooltip_instance != null:
		_tooltip_instance.hide_tooltip()

	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(100, 100)

	var preview = TextureRect.new()
	preview.texture = icon.texture if icon != null else null
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

# Tooltip hover handlers
func _on_icon_mouse_entered() -> void:
	if item == null:
		return
	# create tooltip if needed
	if _tooltip_instance == null:
		_tooltip_instance = ItemTooltipScript.new()
		var root = get_tree().current_scene
		if root == null:
			root = get_tree().root
		root.add_child(_tooltip_instance)
	# populate and show it at the cursor position (it will follow)
	_tooltip_instance.populate(item)
	_tooltip_instance.show_at(get_viewport().get_mouse_position())

func _on_icon_mouse_exited() -> void:
	if _tooltip_instance != null:
		_tooltip_instance.hide_tooltip()

func _exit_tree() -> void:
	# ensure tooltip doesn't leak if slot is removed
	if _tooltip_instance != null:
		_tooltip_instance.queue_free()
		_tooltip_instance = null
