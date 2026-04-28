extends CharacterBody2D
#
#
#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#
#
#func _physics_process(delta: float) -> void:
	#velocity.x = 250
	## Add the gravity.
	##if not is_on_floor():
		##velocity += get_gravity() * delta
##
	### Handle jump.
	##if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		##velocity.y = JUMP_VELOCITY
##
	### Get the input direction and handle the movement/deceleration.
	### As good practice, you should replace UI actions with custom gameplay actions.
	##var direction := Input.get_axis("ui_left", "ui_right")
	##if direction:
		##velocity.x = direction * SPEED
	##else:
		##velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
#extends AnimatedSprite2D
var directionPath
var direction = 1
var mouseRotation
var dying = false
var damage
var speed = 400



	
func _ready() -> void:
	directionPath = Vector2(0,0)
	direction = 1
	rotation = 0
	$AnimatedSprite2D.flip_h = true
	


func _process(delta: float) -> void:
	damage = get_node("../Stats").fireSpellDamage
	if (not dying):
		var xd = position.x + (direction * 5.5)
		position = (Vector2(xd, position.y))
		#if collision is TileMapLayer:
			#queue_free()
func _physics_process(delta):
	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		if collider is TileMapLayer:
			queue_free()
		elif collider.is_in_group("player"):
			queue_free()
func _on_area_2d_body_entered(body: Node2D) -> void:
	if "TileMapLayer" == body.name:
		#play("destroyed")
		dying = true
		queue_free()
	#if body.is_in_group("golem"):
		##play("destroyed")
		#body.take_damage(damage)
		#dying = true
		#queue_free()
	if body.is_in_group("alien_player"):
		#play("destroyed")
		get_node("../Stats").health -= 7.5
		dying = true
		queue_free()
	#if body.is_in_group("slime"):
		##play("destroyed")
		#body.health -= damage
		#dying = true
		#queue_free()
	
