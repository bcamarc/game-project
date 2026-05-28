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
var stats: Node = null

signal death(x, y)

func _ready() -> void:
	add_to_group("alien")
	add_to_group("enemy")
	stats = _resolve_stats()
	if not is_on_floor():
		floor = true

	$RayCast2D.add_exception(get_node("../Golem"))
	$RayCast2D.add_exception(get_node("../TestMonster"))


func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("player") != null:

		if ((floor and not is_on_floor()) and not died):
			velocity.y = 5000
			move_and_slide()
		else:
			floor = false

		$ProgressBar.value = health
		count += 1

		var alien =  get_tree().get_nodes_in_group("player")[0]
		var distance = $Sprite2D.global_position.distance_to(alien.global_position)
		monsterPos = global_position.x

		if distance <= 400:

			if round(alien.alienPos.x) >= round(monsterPos):
				direction.x = 1
				$Sprite2D.flip_h = true
			else:
				direction.x = -1
				$Sprite2D.flip_h = false

			velocity.x = speed * direction.x

			if attacking and not died:
				if count % 40 == 0:
					var current_stats := _resolve_stats()
					if current_stats != null:
						if current_stats.has_method("add_hp"):
							current_stats.add_hp(-2.5)
						else:
							current_stats.total_health -= 2.5
					$AnimationPlayer.play("attack")
			else:
				move_and_slide()
				$AnimationPlayer.play("walk")
				if not $AnimationPlayer.is_playing():
					$AnimationPlayer.play("walk")

		else:
			$AnimationPlayer.play("idle")

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
#
		#if ability and randf() < 0.001:
			#$AnimatedSprite2D.play("Ability")
			#$slimeFx.play("ability")
			#get_node("../Stats").health -= 5

		if not is_on_wall() and not is_on_floor() and count % 5 == 0:
			velocity.y = 400

		$RayCast2D.target_position = Vector2(35 * direction.x, -5)

		if $RayCast2D.is_colliding() and $RayCast2D.get_collider() == get_node("../TileMapLayer"):
			#$AnimatedSprite2D.play("Jump")
			velocity.y = -300

	else:
		print("player not found")

	if health <= 0:
		if (not died):
			slime_death = true
			died = true
		if (slime_death):
			#$AnimatedSprite2D.play("death")
			slime_death = false
			
		
		queue_free()
		var current_stats := _resolve_stats()
		if current_stats != null and current_stats.has_method("add_exp"):
			current_stats.add_exp(5)
		death.emit(position.x, position.y)
		
func take_damage(d):
	health -= d

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		attacking = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		attacking = false


func _on_ability_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		ability = true


func _on_ability_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		ability = false


func _resolve_stats() -> Node:
	if is_instance_valid(stats):
		return stats

	var parent_stats := get_node_or_null("../Stats")
	if parent_stats != null:
		stats = parent_stats
		return stats

	var scene := get_tree().current_scene
	if scene != null:
		var scene_stats := scene.get_node_or_null("Stats")
		if scene_stats != null:
			stats = scene_stats
			return stats

	var singleton_stats := get_node_or_null("/root/Stats")
	if singleton_stats != null:
		stats = singleton_stats
		return stats

	return null
