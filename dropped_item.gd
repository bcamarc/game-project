extends Sprite2D
var _item_data: Dictionary
var item_data: Dictionary:
	get:
		return _item_data
	set(value):
		_item_data = value
		_apply_item_icon()

func _ready() -> void:
	_apply_item_icon()

func _apply_item_icon() -> void:
	if not _item_data.is_empty() and _item_data.has("icon"):
		texture = _item_data["icon"]
	else:
		texture = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if item_data.is_empty():
		return

	if not body.is_in_group("player") and not body.is_in_group("alien_player"):
		return

	var inventory := get_tree().get_first_node_in_group("inventory")
	if inventory == null or not inventory.has_method("add_item"):
		return

	if inventory.add_item(item_data):
		queue_free()
