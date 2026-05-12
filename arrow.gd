extends CharacterBody2D

var monster_pos := 0.0
var direction := 1
var dying := false
var damage := 0.0
var speed := 175.0

@export var knight: CharacterBody2D

@export var gravity := 1200.0
@export var initial_upward_speed := -500.0
@export var sprite_angle_offset_degrees := 0.0
@export var add_180_when_shooting_left := true

func _ready() -> void:
	
	var spawn_global_pos := global_position
	var spawn_global_rot := global_rotation
	top_level = true
	global_position = spawn_global_pos
	global_rotation = spawn_global_rot
	scale = Vector2.ONE

	monster_pos = global_position.x
	var alien = knight if knight != null else get_node("../Knight")

	if alien.alienPos.x >= monster_pos + 50.0:
		direction = 1
	else:
		direction = -1

	
	$AnimatedSprite2D.flip_h = false
	$AnimatedSprite2D.flip_v = false

	velocity.x = speed * direction
	velocity.y = initial_upward_speed

func _physics_process(delta: float) -> void:
	damage = get_node("../Stats").fireSpellDamage
	if dying:
		return

	
	velocity.y += gravity * delta
	move_and_slide()

	
	var angle := velocity.angle() + deg_to_rad(sprite_angle_offset_degrees)
	if direction < 0 and add_180_when_shooting_left:
		angle += PI
	rotation = angle

	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var collider := col.get_collider()

		if collider is TileMapLayer:
			dying = true
			queue_free()
			return

		if collider.is_in_group("alien_player"):
			get_node("../Stats").total_health -= 7.5
			dying = true
			queue_free()
			return
