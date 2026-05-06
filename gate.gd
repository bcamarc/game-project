extends AnimatedSprite2D
signal next_level
func _ready() -> void:
	next_level.connect(get_node("../TileMapLayer").on_next_level)
func _on_area_2d_body_entered(body: Node2D) -> void:
	next_level.emit()
	if (body.name == "Knight"):
		print("yay")
