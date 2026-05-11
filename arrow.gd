#extends CharacterBody2D
#
#
#var directionPath
#var direction = 1
#var mouseRotation
#var dying = false
#var damage
#var speed = 400
#
#
#
	#
#func _ready() -> void:
	#directionPath = Vector2(0,0)
	#direction = 1
	#rotation = 0
	#$AnimatedSprite2D.flip_h = true
	#
#
#
#func _process(delta: float) -> void:
	#damage = get_node("../Stats").fireSpellDamage
	#if (not dying):
		#var xd = position.x + (direction * 5.5)
		#position = (Vector2(xd, position.y))
		#
#func _physics_process(delta):
	#if $RayCast2D.is_colliding():
		#var collider = $RayCast2D.get_collider()
		#if collider is TileMapLayer:
			#queue_free()
		#elif collider.is_in_group("player"):
			#queue_free()
#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if "TileMapLayer" == body.name:
		#
		#dying = true
		#queue_free()
	#if body.is_in_group("alien_player"):
		#
		#get_node("../Stats").health -= 7.5
		#dying = true
		#queue_free()
	#
	#
extends CharacterBody2D

var direction := 1
var dying := false
var damage
var speed := 250.0

# arc settings
var gravity := 1200.0
var initial_upward_speed := -500.0  # negative = up in Godot 2D

func _ready() -> void:
	$AnimatedSprite2D.flip_h = true

	velocity.x = speed * direction
	velocity.y = initial_upward_speed

func _physics_process(delta: float) -> void:
	damage = get_node("../Stats").fireSpellDamage
	if dying:
		return

	velocity.y += gravity * delta
	move_and_slide()
	rotation = velocity.angle()

	# despawn immediately on physics collision
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var collider := col.get_collider()

		if collider is TileMapLayer:
			queue_free()
			return
		if collider.is_in_group("alien_player"):
			get_node("../Stats").base_health -= 7.5
			queue_free()
			return
