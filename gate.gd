extends AnimatedSprite2D
signal next_level
signal my_position(x)
func _ready() -> void:
	next_level.connect(get_node("../TileMapLayer").on_next_level)
func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if (body.name == "Knight"):
		next_level.emit()
		try_connect()
	
func try_connect():
	var map = get_node_or_null("../TileMapLayer")

	if map == null:
		await get_tree().process_frame
		try_connect()
		return

	if not my_position.is_connected(map.on_need_position):
		my_position.connect(map.on_need_position)

	my_position.emit(global_position.x)
