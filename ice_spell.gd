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
	play("repeat")
func _process(delta: float) -> void:
	damage = get_node("../Stats").iceSpellDamage
	
	if (not dying):
		position += direction * 5.5
	if (not is_playing()):
			queue_free()
			

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("golem"):
		play("hit")
		body.take_damage(damage)
		body.speed -= 3
		dying = true
	if body.is_in_group("fire_alien") or body.is_in_group("ice_alien"):
		play("hit")
		body.take_damage(damage)
		#body.speed -= 3
		dying = true
		
		
	if body.is_in_group("slime"):
		play("hit")
		body.health -= damage
		dying = true
		body.speed -=3
		
	if "TileMapLayer" == body.name:
		dying = true
		play("hit")
		
