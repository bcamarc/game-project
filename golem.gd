extends CharacterBody2D

var speed := 50
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
var floor_check := false
var fps := true
var abilityFXScene := load("res://golem_ability.tscn")
var abilityRadius := false
signal death(x, y)

var attack_damage := 5
var attack_frame := 4
var attack_cooldown := 0.8
var attack_timer := 0.0

func _ready() -> void:
	add_to_group("golem")
	if not is_on_floor():
		floor_check = true
	$AnimatedSprite2D.connect("frame_changed", Callable(self, "_on_frame_changed"))

func _process(delta: float) -> void:
	if shieldHealth < 0:
		shieldHealth = 0
	# Look 2 levels up for Knight
	if has_node("../../Knight"):
		attack_timer += delta
		var abilityFX = abilityFXScene.instantiate()
		if floor_check and not is_on_floor():
			velocity.y = 500
			move_and_slide()
		else:
			velocity.y = 0
			floor_check = false
		$ProgressBar.value = health
		$ProgressBar2.value = shieldHealth
		count += 1
		Acount += 1
		if count > 50:
			first = true
		var alien = get_node("../../Knight")
		var distance = $AnimatedSprite2D.global_position.distance_to(alien.global_position)
		monsterPos = global_position.x

		if distance <= 550:
			if round(alien.alienPos.x) >= round(monsterPos):
				direction.x = 1
				$AnimatedSprite2D.flip_h = false
			else:
				direction.x = -1
				$AnimatedSprite2D.flip_h = true
			velocity.x = speed * direction.x
		else:
			if not $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("Idle")

		$RayCast2D.target_position = Vector2(35 * direction.x, -3)
		if $RayCast2D.is_colliding() or is_on_wall():
			velocity.y = -150
		if not is_on_wall() and not is_on_floor():
			velocity.y = 100

		if attacking:
			if attack_timer >= attack_cooldown:
				attack_timer = 0.0
				first = false
				$AnimatedSprite2D.play("AttackB")
				$AttackFX.play("default")
		else:
			if not $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("Run")

		if not attacking and Acount > 130:
			move_and_slide()

		if randf() < 0.001 and distance <= 1000:
			Acount = 0
			$AnimatedSprite2D.play("Ability")
			if shieldHealth + 50 < 100:
				shieldHealth += 50
			else:
				shieldHealth = 100

		if abilityRadius and randf() < 0.0007:
			$AnimatedSprite2D.play("AbilityAttack")
			add_child(abilityFX)
			get_node("../../Stats").total_health -= 15

	if health <= 0:
		emit_signal("death", position.x, position.y)
		get_node("../../Stats").add_exp(7)
		queue_free()

func _on_frame_changed():
	if $AnimatedSprite2D.animation == "AttackB" and $AnimatedSprite2D.frame == attack_frame:
		get_node("../../Stats").total_health -= attack_damage

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Knight":
		attacking = true

func take_damage(a: int):
	if shieldHealth <= a:
		health -= a - shieldHealth
		shieldHealth = 0
	else:
		shieldHealth -= a

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Knight":
		attacking = false

func _on_ability_area_body_entered(body: Node2D) -> void:
	if body.name == "Knight":
		abilityRadius = true

func _on_ability_area_body_exited(body: Node2D) -> void:
	if body.name == "Knight":
		abilityRadius = false
