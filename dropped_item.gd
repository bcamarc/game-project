extends Sprite2D
var item_data: Dictionary

func _ready() -> void:
	if not item_data.is_empty() and item_data.has("icon"):
		texture = item_data["icon"]

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
