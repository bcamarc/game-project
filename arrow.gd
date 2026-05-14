#
#extends CharacterBody2D
#
#var direction := 1
#var dying := false
#var damage := 2000
#var speed := 400.0
#var gravity := 700.0 # Controls how much the arrow drops (arc)
#var vertical_velocity := -80.0 # Small upward launch so it starts with a slight rise
#var hitbox: Area2D
#
#func _ready() -> void:
	#rotation = 0
	#$AnimatedSprite2D.flip_h = true
	#hitbox = $Area2D
#
	## Make sure Area2D signal is connected
	#if not hitbox.body_entered.is_connected(_on_area_2d_body_entered):
		#hitbox.body_entered.connect(_on_area_2d_body_entered)
#
#func _process(delta: float) -> void:
	#damage = 30
#
#func _physics_process(delta: float) -> void:
	#if dying:
		#return
#
	## Horizontal movement stays constant
	#velocity.x = direction * speed
#
	## Vertical movement gets pulled down over time to create an arc
	#vertical_velocity += gravity * delta
	#velocity.y = vertical_velocity
#
	#move_and_slide()
#
	## Optional: rotate arrow so it points along travel direction
	#rotation = velocity.angle()
#
	## Keep physical collision for map/walls only
	#if $RayCast2D.is_colliding():
		#var collider = $RayCast2D.get_collider()
		#if collider is TileMapLayer:
			#queue_free()
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if dying:
		#return
#
	#if body.is_in_group("enemy"):
		## If enemy script is on the body itself
		#if body.has_method("take_damage"):
			#body.take_damage(damage)
			#dying = true
			#queue_free()
			#return
#
		## If collider is a child and enemy script is on parent
		#var p := body.get_parent()
		#if p != null and p.is_in_group("enemy") and p.has_method("take_damage"):
			#p.take_damage(damage)
			#dying = true
			#queue_free()
			#return
extends CharacterBody2D

var direction := 1
var dying := false
var damage := 2000
var speed := 400.0
var gravity := 700.0 # Controls how much the arrow drops (arc)
var vertical_velocity := -80.0 # Small upward launch so it starts with a slight rise
var hitbox: Area2D

func _enter_tree() -> void:
	# Detach from parent flips/scales as early as possible.
	top_level = true

func _ready() -> void:
	rotation = 0.0

	# Force a clean, non-mirrored transform.
	scale = Vector2.ONE
	global_scale = Vector2.ONE

	hitbox = $Area2D
	$AnimatedSprite2D.flip_h = false

	# Make sure Area2D signal is connected
	if not hitbox.body_entered.is_connected(_on_area_2d_body_entered):
		hitbox.body_entered.connect(_on_area_2d_body_entered)

func _process(delta: float) -> void:
	damage = 30

func _physics_process(delta: float) -> void:
	if dying:
		return

	# If anything mirrored us (spawn code / parent flip), undo it every frame.
	if global_scale.x < 0.0 or global_scale.y < 0.0:
		global_scale = Vector2(abs(global_scale.x), abs(global_scale.y))

	# Horizontal movement stays constant
	velocity.x = direction * speed

	# Vertical movement gets pulled down over time to create an arc
	vertical_velocity += gravity * delta
	velocity.y = vertical_velocity

	move_and_slide()

	# Rotate arrow so it points along travel direction
	rotation = velocity.angle()

	# Keep physical collision for map/walls only
	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		if collider is TileMapLayer:
			queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if dying:
		return

	if body.is_in_group("enemy"):
		# If enemy script is on the body itself
		if body.has_method("take_damage"):
			body.take_damage(damage)
			dying = true
			queue_free()
			return

		# If collider is a child and enemy script is on parent
		var p := body.get_parent()
		if p != null and p.is_in_group("enemy") and p.has_method("take_damage"):
			p.take_damage(damage)
			dying = true
			queue_free()
			return
