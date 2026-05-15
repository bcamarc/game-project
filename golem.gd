extends CharacterBody2D

@onready var stats = null

var speed := 50.0
var monsterPos := global_position.x
var direction := Vector2.ZERO
var attacking := false
var count := 0
var Acount := 400
var ability := false
var health := 100
var shieldHealth := 0
var up := false
var first := true
var floor := false
var fps := true
var abilityFXScene := load("res://golem_ability.tscn")
var abilityRadius := false

var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var jump_velocity := -300.0
var jump_cooldown := 0.4
var jump_timer := 0.0

signal death(x, y)

var attack_damage := 5
var attack_frame := 4
var attack_cooldown := 0.8
var attack_timer := 0.0

func _ready() -> void:
	stats = get_stats()
	add_to_group("enemy")
	add_to_group("golem")

	if not is_on_floor():
		floor = true

	$RayCast2D.add_exception(self)

	var test_monster = get_node_or_null("../TestMonster")
	if test_monster:
		$RayCast2D.add_exception(test_monster)

	$AnimatedSprite2D.connect("frame_changed", Callable(self, "_on_frame_changed"))

func _physics_process(delta: float) -> void:
	if shieldHealth < 0:
		shieldHealth = 0

	if jump_timer > 0.0:
		jump_timer -= delta

	attack_timer += delta
	count += 1
	Acount += 1
	if count > 50:
		first = true

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0

	# Optional initial drop behavior
	if floor and not is_on_floor():
		velocity.y = 500.0
		move_and_slide()
		return
	else:
		floor = false

	$ProgressBar.value = health
	$ProgressBar2.value = shieldHealth

	# Find nearest player in group
	var players = get_tree().get_nodes_in_group("alien_player")
	if players.is_empty():
		velocity.x = 0.0
		if not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != "Idle":
			$AnimatedSprite2D.play("Idle")
		move_and_slide()
		return

	var alien: Node2D = null
	var best_dist := INF
	for p in players:
		if p is Node2D:
			var d = global_position.distance_to((p as Node2D).global_position)
			if d < best_dist:
				best_dist = d
				alien = p as Node2D

	if alien == null:
		velocity.x = 0.0
		move_and_slide()
		return

	var distance = global_position.distance_to(alien.global_position)
	monsterPos = global_position.x

	if distance <= 550.0:
		if alien.global_position.x >= monsterPos:
			direction.x = 1.0
			$AnimatedSprite2D.flip_h = false
		else:
			direction.x = -1.0
			$AnimatedSprite2D.flip_h = true

		velocity.x = speed * direction.x
	else:
		velocity.x = 0.0
		if not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != "Idle":
			$AnimatedSprite2D.play("Idle")

	# Better jump logic for random terrain / player above
	$RayCast2D.target_position = Vector2(35.0 * direction.x, -6.0)
	var blocked_ahead: bool = $RayCast2D.is_colliding()
	var player_is_above: bool = alien.global_position.y < global_position.y - 14.0
	var player_is_close_x: bool = absf(alien.global_position.x - global_position.x) < 120.0

	if is_on_floor() and jump_timer <= 0.0:
		if blocked_ahead or (player_is_above and player_is_close_x):
			$AnimatedSprite2D.play("Jump")
			velocity.y = jump_velocity
			jump_timer = jump_cooldown

	if attacking:
		if attack_timer >= attack_cooldown:
			attack_timer = 0.0
			first = false
			$AnimatedSprite2D.play("AttackB")
			$AttackFX.play("default")
	else:
		if distance <= 550.0 and (not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != "Run"):
			$AnimatedSprite2D.play("Run")

	if randf() < 0.001 and distance <= 1000.0:
		Acount = 0
		$AnimatedSprite2D.play("Ability")
		if shieldHealth + 50 < 100:
			shieldHealth += 50
		else:
			shieldHealth = 100

	if abilityRadius and randf() < 0.0007:
		$AnimatedSprite2D.play("AbilityAttack")
		var abilityFX = abilityFXScene.instantiate()
		add_child(abilityFX)

		if stats == null:
			stats = get_stats()
		if stats:
			stats.total_health -= 15
		else:
			print("something is broken hp")

	if health <= 0:
		emit_signal("death", position.x, position.y)

		if stats == null:
			stats = get_stats()
		if stats:
			stats.add_exp(7)
		else:
			print("somethings broken")
		queue_free()
		return

	move_and_slide()

func get_stats() -> Node:
	if not is_inside_tree():
		return null
	var tree = get_tree()
	if tree == null:
		return null
	var list = tree.get_nodes_in_group("stats")
	if list.is_empty():
		return null
	return list[0]

func _on_frame_changed() -> void:
	if $AnimatedSprite2D.animation == "AttackB" and $AnimatedSprite2D.frame == attack_frame:
		if stats == null:
			stats = get_stats()
		if stats:
			stats.total_health -= attack_damage

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		attacking = true

func take_damage(a: int) -> void:
	if shieldHealth <= a:
		health -= a - shieldHealth
		shieldHealth = 0
	else:
		shieldHealth -= a

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		attacking = false

func _on_ability_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		abilityRadius = true

func _on_ability_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		abilityRadius = false
