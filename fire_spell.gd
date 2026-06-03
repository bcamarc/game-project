extends AnimatedSprite2D
var directionPath
var direction
var mouseRotation
var dying = false
var damage

func _ready() -> void:
	directionPath = get_global_mouse_position()
	direction = (directionPath-global_position).normalized()
	rotation = direction.angle()
	
func _process(delta: float) -> void:
	damage = get_node("../Stats").fireSpellDamage
	
	if (not dying):
		position += direction * 5.5
	if (not is_playing()):
			queue_free()
			

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("golem"):
		play("destroyed")
		body.take_damage(damage)
		dying = true
		
		
		
	if body.is_in_group("slime"):
		play("destroyed")
		body.take_damage(damage)
		dying = true
	
	if body.is_in_group("enemy"):
		play("destroyed")
		body.take_damage(damage)
		dying = true
		
	
	if body is TileMapLayer:
		play("destroyed")
		dying = true
