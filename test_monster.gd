extends CharacterBody2D

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
signal death(x, y)

func _ready() -> void:
	add_to_group("alien")
	add_to_group("slime")
	add_to_group("enemy")
	if not is_on_floor():
		floor_check = true

	$RayCast2D.add_exception(get_node("../Golem"))
	$RayCast2D.add_exception(get_node("../TestMonster"))

func _physics_process(delta: float) -> void:
	#if not has_node("../Knight") or not has_node(".."):'
	if get_tree().get_nodes_in_group("alien_player") == null:
		print("player not found")
		return

	if health <= 0:
		handle_death()
		return

	$ProgressBar.value = health
	count += 1

	var knight = get_node("../Huntress")
	if knight == null:
		knight = get_node("../Knight")
	var monster_pos_x = global_position.x
	var distance = global_position.distance_to(knight.global_position)

	# Default movement each frame
	#velocity.x = 0.0

	# Optional "drop" behavior you had
	if floor_check and not is_on_floor() and not died:
		velocity.y = 5000.0
		move_and_slide()
		return
	else:
		floor_check = false

	if distance <= 400.0 or damaged:
		
		if round(knight.alienPos.x) >= round(monster_pos_x):
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
				get_node("../Stats").total_health -= 2.5

			if not $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("Run")
		else:
			if not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != "Run":
				$AnimatedSprite2D.play("Run")

		# Ability logic
		if ability and randf() < 0.001:
			$AnimatedSprite2D.play("Ability")
			$slimeFx.play("ability")
			get_node("../Stats").total_health -= 5.0

		# Simple gravity/fall behavior from your original script
		if not is_on_wall() and not is_on_floor() and count % 5 == 0:
			velocity.y = 400.0

		# Jump at wall in front
		$RayCast2D.target_position = Vector2(35.0 * direction.x, -5.0)
		if $RayCast2D.is_colliding() and $RayCast2D.get_collider() == get_node("../TileMapLayer"):
			$AnimatedSprite2D.play("Jump")
			velocity.y = -200.0
	else:
		$AnimatedSprite2D.play("Idle")

	# IMPORTANT: always apply movement every physics frame
	move_and_slide()

func handle_death() -> void:
	if not died:
		slime_death = true
		died = true

	if slime_death:
		$AnimatedSprite2D.play("death")
		slime_death = false

	# Wait until death animation finishes, then free and reward
	if died and $AnimatedSprite2D.animation == "death" and not $AnimatedSprite2D.is_playing():
		queue_free()
		get_node("../Stats").add_exp(5)
		death.emit(position.x, position.y)

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
