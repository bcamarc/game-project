extends Control

var item = null
@onready var icon = find_child("TextureRect", true, false)

func _ready():
	print("ICON NODE =", icon)

func set_item(new_item):
	item = new_item

	if icon == null:
		print("ERROR: icon still null")
		return

	if item and item.has("icon"):
		icon.texture = item["icon"]
	else:
		icon.texture = null


func _get_drag_data(position):
	if item == null:
		return null

	var preview = TextureRect.new()

	if icon and icon.texture:
		preview.texture = icon.texture

	preview.custom_minimum_size = Vector2(32, 32)
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
