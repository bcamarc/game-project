extends AnimatedSprite2D

const ICON_PICK_RADIUS := 22.0

var shop_items: Array = []

func _ready() -> void:
	shop_items = ItemDropPool.shop_items()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return

	var clicked_item: Dictionary = _item_for_click(get_global_mouse_position())
	if clicked_item.is_empty():
		return

	var inventory: Node = get_tree().get_first_node_in_group("inventory")
	if inventory != null and inventory.has_method("add_item") and inventory.add_item(clicked_item):
		get_viewport().set_input_as_handled()

func _item_for_click(click_position: Vector2) -> Dictionary:
	var icon_names: Array = [
		"Icon301",
		"Icon302",
		"Icon305",
		"Icon306",
		"Icon307",
		"Icon310",
		"Icon95",
		"Icon115"
	]

	for i in range(icon_names.size()):
		if i >= shop_items.size():
			break

		var icon := get_node_or_null(icon_names[i]) as Sprite2D
		if icon != null and icon.global_position.distance_to(click_position) <= ICON_PICK_RADIUS:
			return shop_items[i]

	return {}
