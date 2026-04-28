extends CharacterBody2D
var health = 175
var died = false
var fa_death = false
var enemy_fire := load("res://enemy_fire.tscn")
var floor = false
var count = 0
var monsterPos := global_position.x
var alien_death = false
var attacking = false
signal death(x, y)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):

	velocity.x = 0
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	var random = randf()
	if random < 0.030 and is_on_floor():
		velocity.y = randi_range(-700,0)
	elif random > 0.035 and random < 0.05:
		var spell = enemy_fire.instantiate()
		spell.global_position = position
		get_tree().current_scene.add_child(spell)
		
		#var fire_alien = get_node("..//fire_alien")
	
	$AnimationPlayer.play("idle")
	move_and_slide()
	
	
func take_damage(delta):
	health -= delta
	
	
func _process(delta: float) -> void:
	add_to_group("fire_alien")
	if has_node("../AlienPlayer"):
		if (died):
			alien_death = true
		#died = true
			emit_signal("death", position.x, position.y)
		if (alien_death):
			#$AnimatedSprite2D.play("death")
		
			queue_free()
		if health <= 0:
			died = true		
		if ((floor and not is_on_floor()) and not died):
			velocity.y = 5000
			move_and_slide()
		else:
			floor = false
		if attacking and not died:
			if count % 20 == 0:
				#if not $AnimatedSprite2D.is_playing():
					#$AnimatedSprite2D.play("Attack")
				get_node("../Stats").health -= 10
			
		$ProgressBar.value = health
		count += 1

		var alien = get_node("../AlienPlayer")
		#var distance = $AnimatedSprite2D.global_position.distance_to(alien.global_position)
		monsterPos = global_position.x


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "AlienPlayer":
		attacking = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "AlienPlayer":
		attacking = false
