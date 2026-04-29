extends AnimatedSprite2D

func _process(delta: float) -> void:
	global_position = get_node("../Knight").global_position
