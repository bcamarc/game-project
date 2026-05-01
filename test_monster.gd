extends CharacterBody2D

var speed := 75
var monsterPos := global_position.x
var direction := Vector2.ZERO
var attacking := false
var count := 0
var ability := false
var health := 50
var floor := false
var slime_death := false
var died = false

signal death(x, y)

func _ready() -> void:
	add_to_group("alien")
	if not is_on_floor():
		floor = true

	$RayCast2D.add_exception(get_node("../Golem"))
	$RayCast2D.add_exception(get_node("../TestMonster"))


func _process(delta: float) -> void:
	if has_node("../Knight"):

		if ((floor and not is_on_floor()) and not died):
			velocity.y = 5000
			move_and_slide()
		else:
			floor = false

		$ProgressBar.value = health
		count += 1

		var alien = get_node("../Knight")
		var distance = $AnimatedSprite2D.global_position.distance_to(alien.global_position)
		monsterPos = global_position.x

		if distance <= 400:

			if round(alien.alienPos.x) >= round(monsterPos):
				direction.x = 1
				$AnimatedSprite2D.flip_h = false
			else:
				direction.x = -1
				$AnimatedSprite2D.flip_h = true

			velocity.x = speed * direction.x

			if attacking and not died:
				if count % 20 == 0:
					if not $AnimatedSprite2D.is_playing():
						$AnimatedSprite2D.play("Attack")
				if count % 40 == 0:
					get_node("../Stats").total_health -= 2.5
			else:
				move_and_slide()
				if not $AnimatedSprite2D.is_playing():
					$AnimatedSprite2D.play("Run")

		else:
			$AnimatedSprite2D.play("Idle")

		#if attacking and not died:
			#if count % 20 == 0:
				#if not $AnimatedSprite2D.is_playing():
					#$AnimatedSprite2D.play("Attack")
			#if count % 60 == 0:
				#get_node("../Stats").health -= 3
		#else:
			#if (not $AnimatedSprite2D.is_playing()) and (not died):
				#$AnimatedSprite2D.play("Run")
				#move_and_slide()

		if ability and randf() < 0.001:
			$AnimatedSprite2D.play("Ability")
			$slimeFx.play("ability")
			get_node("../Stats").health -= 5

		if not is_on_wall() and not is_on_floor() and count % 5 == 0:
			velocity.y = 400

		$RayCast2D.target_position = Vector2(35 * direction.x, -5)

		if $RayCast2D.is_colliding() and $RayCast2D.get_collider() == get_node("../TileMapLayer"):
			$AnimatedSprite2D.play("Jump")
			velocity.y = -200

	else:
		print("player not found")

	if health <= 0:
		if (not died):
			slime_death = true
			died = true
		if (slime_death):
			$AnimatedSprite2D.play("death")
			slime_death = false
			
		if ( not $AnimatedSprite2D.animation == "death"):
			queue_free()
			get_node("../Stats").add_exp(5)
			death.emit(position.x, position.y)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Knight":
		attacking = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Knight":
		attacking = false


func _on_ability_area_body_entered(body: Node2D) -> void:
	if body.name == "Knight":
		ability = true


func _on_ability_area_body_exited(body: Node2D) -> void:
	if body.name == "Knight":
		ability = false
