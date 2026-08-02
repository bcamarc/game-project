extends Control

var item: Dictionary | null = null
@onready var icon: TextureRect = $TextureRect
@export var slot_type = "" 

func _ready():
	custom_minimum_size = Vector2(48,48)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.texture = null
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var stats = _resolve_stats()
	if stats != null and stats.has_signal("player_changed"):
		stats.connect("player_changed", Callable(self, "_on_player_changed"))
	refresh_from_stats()

func set_item(new_item: Dictionary | null) -> bool:
	if new_item != null and not _can_equip_item(new_item):
		return false

	_set_item_unchecked(new_item)
	return true

func _set_item_unchecked(new_item: Dictionary | null) -> void:
	item = new_item

	if item != null and item.has("icon"):
		icon.texture = item["icon"]
	else:
		icon.texture = null

	_update_equipped_item()

func _update_equipped_item() -> void:
	var stats = _resolve_stats()
	if stats == null:
		return

	var equipment = stats.get("equipment")
	if not (equipment is Dictionary):
		return

	equipment[slot_type] = item
	if stats.has_method("update_stats"):
		stats.update_stats()

func refresh_from_stats() -> void:
	var stats = _resolve_stats()
	if stats == null:
		return

	var equipment = stats.get("equipment")
	if not (equipment is Dictionary):
		return

	if not equipment.has(slot_type):
		return

	_set_item_unchecked(equipment[slot_type])

func _resolve_stats() -> Node:
	var global_stats := get_node_or_null("/root/Stats")
	if global_stats != null:
		return global_stats

	var scene := get_tree().current_scene
	if scene != null:
		var scene_stats := scene.get_node_or_null("Stats")
		if scene_stats != null:
			return scene_stats

	var stats_node := get_tree().get_first_node_in_group("stats")
	if stats_node != null:
		return stats_node

	return null

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_get_drag_data(event.position)

func _get_drag_data(position):
	if item == null:
		return null

	var preview = TextureRect.new()
	preview.texture = icon.texture if icon != null else null
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(48, 48)

	set_drag_preview(preview)

	return {
		"item": item,
		"from": self
	}

func _can_drop_data(position, data):
	if typeof(data) != TYPE_DICTIONARY:
		return false

	if not data.has("item"):
		return false

	var incoming_item = data["item"]

	return _can_equip_item(incoming_item)

func _drop_data(position, data):
	if not _can_drop_data(position, data):
		return

	var from_slot = data["from"]
	var incoming_item = data["item"]

	var temp = item
	if not set_item(incoming_item):
		return

	if from_slot and from_slot != self:
		from_slot.set_item(temp)

func _can_equip_item(incoming_item) -> bool:
	if not (incoming_item is Dictionary):
		return false

	if not incoming_item.has("type"):
		return false

	if incoming_item["type"] != slot_type:
		return false

	if slot_type != "weapon":
		return true

	var stats = _resolve_stats()
	if stats == null:
		return false

	return ItemDropPool.can_player_use_item(str(stats.get("current_player")), incoming_item)

func _on_player_changed(_player_name: String) -> void:
	refresh_from_stats()

	if item == null or _can_equip_item(item):
		return

	var removed_item = item
	_set_item_unchecked(null)

	var inventory := get_tree().get_first_node_in_group("inventory")
	if inventory == null or not inventory.has_method("add_item") or not inventory.add_item(removed_item):
		_set_item_unchecked(removed_item)
