extends AnimatedSprite2D
var directionPath
var direction
var mouseRotation
var dying = false
var damage
var target_position := Vector2.ZERO
var has_target := false
var damage_multiplier := 1.0

func set_target_position(target: Vector2) -> void:
	target_position = target
	has_target = true

func _ready() -> void:
	directionPath = target_position if has_target else get_global_mouse_position()
	direction = (directionPath-global_position).normalized()
	rotation = direction.angle()
	
func _process(delta: float) -> void:
	var stats := get_node_or_null("../Stats")
	if stats == null:
		stats = get_node_or_null("/root/Stats")
	damage = (stats.fireSpellDamage if stats != null else 10) * damage_multiplier
	
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
