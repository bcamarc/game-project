extends Node2D
@onready var alien := get_node("../../Knight")
func _process(delta: float) -> void:
	if not is_instance_valid(alien):
		queue_free()
		return

	global_position = alien.global_position + Vector2(0, 10)

	if not $AnimatedSprite2D.is_playing():
		queue_free()
