extends Control

var item = null
@onready var icon = $TextureRect

func _ready():
	
	custom_minimum_size = Vector2(200,200)
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
	return typeof(data) == TYPE_DICTIONARY and data.has("item")

func _drop_data(position, data):
	var from_slot = data["from"]
	var incoming_item = data["item"]

	var temp = item
	set_item(incoming_item)

	if from_slot and from_slot != self:
		from_slot.set_item(temp)
