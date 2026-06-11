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
