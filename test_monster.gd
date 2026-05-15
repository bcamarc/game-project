extends CharacterBody2D

@onready var stats = null

var speed := 75.0
var direction := Vector2.ZERO
var attacking := false
var count := 0
var ability := false
var health := 50.0
var died := false
var slime_death := false
var floor_check := false
var damaged := false

var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var jump_velocity := -300.0
var jump_cooldown := 0.35
var jump_timer := 0.0

signal death(x, y)

func _ready() -> void:
	stats = get_stats()
	add_to_group("alien")
	add_to_group("slime")
	add_to_group("enemy")

	if not is_on_floor():
		floor_check = true

	var golem = get_node_or_null("../Golem")
	if golem:
		$RayCast2D.add_exception(golem)

	var test_monster = get_node_or_null("../TestMonster")
	if test_monster:
		$RayCast2D.add_exception(test_monster)

func _physics_process(delta: float) -> void:
	if health <= 0:
		handle_death()
		return

	if jump_timer > 0.0:
		jump_timer -= delta

	# Always apply gravity so the slime doesn't float
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0

	$ProgressBar.value = health
	count += 1

	var players = get_tree().get_nodes_in_group("alien_player")
	if players.is_empty():
		if not died:
			$AnimatedSprite2D.play("Idle")
		move_and_slide()
		return

	# Pick nearest player in group
	var alien: Node2D = null
	var closest_dist := INF
	for p in players:
		if p is Node2D:
			var d = global_position.distance_to((p as Node2D).global_position)
			if d < closest_dist:
				closest_dist = d
				alien = p as Node2D

	if alien == null:
		$AnimatedSprite2D.play("Idle")
		move_and_slide()
		return

	var monster_pos_x = global_position.x
	var distance = global_position.distance_to(alien.global_position)

	# Optional initial drop behavior
	if floor_check and not is_on_floor() and not died:
		velocity.y = 500.0
		move_and_slide()
		return
	else:
		floor_check = false

	if distance <= 400.0 or damaged:
		if alien.global_position.x >= monster_pos_x:
			direction.x = 1.0
			$AnimatedSprite2D.flip_h = false
		else:
			direction.x = -1.0
			$AnimatedSprite2D.flip_h = true

		velocity.x = speed * direction.x

		if attacking and not died:
			if count % 20 == 0 and not $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("Attack")

			if count % 40 == 0:
				if stats == null:
					stats = get_stats()
				if stats:
					stats.total_health -= 5

			if not $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("Run")
		else:
			if not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != "Run":
				$AnimatedSprite2D.play("Run")

		if ability and randf() < 0.001:
			$AnimatedSprite2D.play("Ability")
			$slimeFx.play("ability")
			if stats == null:
				stats = get_stats()
			if stats:
				stats.total_health -= 5
			else:
				print("hp is broken")

		# Better jump logic for random terrain / higher player
		$RayCast2D.target_position = Vector2(35.0 * direction.x, -6.0)

		var player_is_above: bool = alien.global_position.y < global_position.y - 12.0
		var player_is_close_x: bool = absf(alien.global_position.x - global_position.x) < 96.0
		var blocked_ahead: bool = $RayCast2D.is_colliding()

		if is_on_floor() and jump_timer <= 0.0:
			if blocked_ahead or (player_is_above and player_is_close_x):
				$AnimatedSprite2D.play("Jump")
				velocity.y = jump_velocity
				jump_timer = jump_cooldown


		if is_on_floor() and jump_timer <= 0.0:
			if blocked_ahead or (player_is_above and player_is_close_x):
				$AnimatedSprite2D.play("Jump")
				velocity.y = jump_velocity
				jump_timer = jump_cooldown
	else:
		velocity.x = 0.0
		if not died:
			$AnimatedSprite2D.play("Idle")

	move_and_slide()

func handle_death() -> void:
	if not died:
		slime_death = true
		died = true
		velocity = Vector2.ZERO

	if slime_death:
		$AnimatedSprite2D.play("death")
		slime_death = false

	if died and $AnimatedSprite2D.animation == "death" and not $AnimatedSprite2D.is_playing():
		if stats == null:
			stats = get_stats()
		if stats:
			stats.add_exp(7)
		else:
			print("stats is broken")
		death.emit(position.x, position.y)
		queue_free()

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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		attacking = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		attacking = false

func _on_ability_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		ability = true

func _on_ability_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		ability = false

func take_damage(a) -> void:
	damaged = true
	health -= a
