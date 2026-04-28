extends Node2D
@onready var alien := get_node("../../Knight")
func _ready() -> void:
	
	$AnimatedSprite2D.play("Ability")
	
	
func _process(delta: float) -> void:
	global_position = alien.global_position
	global_position = Vector2i(global_position.x, global_position.y+10)
	if (not $AnimatedSprite2D.is_playing()):
		queue_free()
