extends Control

var item = null
@onready var icon = $TextureRect

func _ready():
	icon.texture = null

func set_item(new_item):
	item = new_item

	if item != null and item.has("icon"):
		icon.texture = item["icon"]
	else:
		icon.texture = null

func _can_drop_data(position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("item")

func _drop_data(position, data):
	var from_slot = data["from"]
	var incoming_item = data["item"]

	var temp = item
	set_item(incoming_item)

	if from_slot and from_slot != self:
		from_slot.set_item(temp)
