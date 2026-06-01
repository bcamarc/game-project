extends Control

var item = null
@onready var icon = $TextureRect
@export var slot_type = "" 

func _ready():
	
	custom_minimum_size = Vector2(48,48)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.texture = null
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func set_item(new_item):
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

	if not stats.get("equipment") is Dictionary:
		return

	stats.equipment[slot_type] = item
	if stats.has_method("update_stats"):
		stats.update_stats()

func _resolve_stats() -> Node:
	var scene := get_tree().current_scene
	if scene != null:
		var scene_stats := scene.get_node_or_null("Stats")
		if scene_stats != null:
			return scene_stats

	var stats_node := get_tree().get_first_node_in_group("stats")
	if stats_node != null:
		return stats_node

	return get_node_or_null("/root/Stats")

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_get_drag_data(event.position)

func _get_drag_data(position):
	if item == null:
		return null

	var preview = TextureRect.new()
	preview.texture = icon.texture
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

	if not incoming_item.has("type"):
		return false

	return incoming_item["type"] == slot_type

func _drop_data(position, data):
	var from_slot = data["from"]
	var incoming_item = data["item"]

	var temp = item
	set_item(incoming_item)

	if from_slot and from_slot != self:
		from_slot.set_item(temp)
