extends AnimatedSprite2D
var directionPath
var direction
var mouseRotation
var dying = false
var count := 0
var start = true
var once = true
var damage
func _ready() -> void:
	pass

	
	
func _process(delta: float) -> void:
	damage = get_node("../Stats").thunderSpellDamage
	if (animation == "Initial"):
		directionPath = get_global_mouse_position()
		direction = (directionPath-global_position).normalized()
		rotation = direction.angle()
	if (not dying and not (animation == "Initial")):
		if once == true:
			once = false
			directionPath = get_global_mouse_position()
			direction = (directionPath-global_position).normalized()
			rotation = direction.angle()
			if (position.x > get_global_mouse_position().x):
				flip_v = true
		position += direction * 9

	if animation == "Initial":
		var player = get_node("../Knight")
		global_position = player.global_position
	if (not is_playing() and not (animation == "Hit")):
			play("Fly")
	if (not is_playing() and animation == "Hit"):
		queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if animation == "Fly":
		if body.is_in_group("golem"):
			play("Hit")
			body.take_damage(damage)
			dying = true
			
			
		if body.is_in_group("slime"):
			play("Hit")
			body.health -= damage
			dying = true
		if "TileMapLayer" == body.name:
			play("Hit")
			dying = true
	

func _on_animation_finished(anim_name: String) -> void:
	if (anim_name == "Start"):
		play("Fly")
		
	
	
		
