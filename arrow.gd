# Arrow.gd
extends CharacterBody2D

var direction := 1
var dying := false
var damage := 0
var speed := 400.0
var gravity := 700.0
var arc_lift := 80.0
var hitbox: Area2D


var target_position := Vector2.ZERO
var has_target := false

func _enter_tree() -> void:
	top_level = true

func set_target_position(pos: Vector2) -> void:
	target_position = pos
	has_target = true

func _ready() -> void:
	rotation = 0.0
	scale = Vector2.ONE
	global_scale = Vector2.ONE
	_update_damage()

	hitbox = $Area2D
	$AnimatedSprite2D.flip_h = false
	$AnimatedSprite2D.flip_v = false

	if not hitbox.body_entered.is_connected(_on_area_2d_body_entered):
		hitbox.body_entered.connect(_on_area_2d_body_entered)

	if has_target:
		var aim: Vector2 = target_position - global_position
		if aim.length_squared() < 0.0001:
			aim = Vector2(float(direction), 0.0)
		aim = aim.normalized()
		velocity = aim * speed
		velocity.y -= arc_lift
	else:
		velocity = Vector2(float(direction) * speed, -arc_lift)

func _physics_process(delta: float) -> void:
	if dying:
		return
	_update_damage()
	velocity.y += gravity * delta
	move_and_slide()
	rotation = velocity.angle()

	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		if collider is TileMapLayer:
			queue_free()
			return

func _on_area_2d_body_entered(body: Node2D) -> void:
	if dying:
		return

	if _is_enemy_target(body):
		if body.has_method("take_damage"):
			body.take_damage(damage - 18)
			dying = true
			queue_free()
			return

		var p := body.get_parent()
		if p != null and _is_enemy_target(p) and p.has_method("take_damage"):
			p.take_damage(damage)
			dying = true
			queue_free()
			return


func _update_damage() -> void:
	var stats := _resolve_stats()
	if stats != null:
		damage = 16 + stats.total_damage
	else:
		damage = 16


func _resolve_stats() -> Node:
	var parent_stats := get_node_or_null("../Stats")
	if parent_stats != null:
		return parent_stats

	var scene := get_tree().current_scene
	if scene != null:
		var scene_stats := scene.get_node_or_null("Stats")
		if scene_stats != null:
			return scene_stats

	var singleton_stats := get_node_or_null("/root/Stats")
	if singleton_stats != null:
		return singleton_stats

	return null


func _is_enemy_target(body: Node) -> bool:
	return body.is_in_group("enemy") or body.is_in_group("golem") or body.is_in_group("slime")
