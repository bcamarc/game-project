extends CharacterBody2D

var speed := 75
var monsterPos := global_position.x
var direction := Vector2.ZERO
var attacking := false
var count := 0
var ability := false
var health := 50
var slime_death := false
var died = false
var stats: Node = null
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var jump_velocity := -300.0
var jump_cooldown := 0.4
var jump_timer := 0.0

signal death(x, y)

func _ready() -> void:
	add_to_group("alien")
	add_to_group("enemy")
	stats = _resolve_stats()

	$RayCast2D.add_exception(get_node("../Golem"))
	$RayCast2D.add_exception(get_node("../TestMonster"))


func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("player") != null:
		if jump_timer > 0.0:
			jump_timer -= delta

		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			if velocity.y > 0.0:
				velocity.y = 0.0

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

		else:
			velocity.x = 0.0
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

		var tile_layer := get_node_or_null("../TileMapLayer") as TileMapLayer
		var wall_ahead := false
		var floor_ahead := true
		var probe_x := global_position.x
		var probe_y := global_position.y
		if tile_layer != null and direction.x != 0.0:
			var block_width := 48.0
			var block_height := 48.0
			if tile_layer.tile_set != null:
				block_width = float(tile_layer.tile_set.tile_size.x) * absf(tile_layer.global_scale.x)
				block_height = float(tile_layer.tile_set.tile_size.y) * absf(tile_layer.global_scale.y)

			var probe_origin = $CollisionShape2D.global_position
			probe_x = probe_origin.x + direction.x * block_width * 0.65
			probe_y = probe_origin.y
			var wall_probe_low := Vector2(probe_x, probe_y + block_height * 0.15)
			var wall_probe_mid := Vector2(probe_x, probe_y - block_height * 0.35)
			var floor_probe_near := Vector2(probe_x, probe_y + block_height * 0.95)
			var floor_probe_far := Vector2(probe_x, probe_y + block_height * 1.35)
			wall_ahead = _has_solid_tile(tile_layer, wall_probe_low) or _has_solid_tile(tile_layer, wall_probe_mid)
			floor_ahead = _has_solid_tile(tile_layer, floor_probe_near) or _has_solid_tile(tile_layer, floor_probe_far)

		else:
			$RayCast2D.position = Vector2(7 * direction.x, 11)
			$RayCast2D.target_position = Vector2(35 * direction.x, -5)
			$RayCast2D.force_raycast_update()
			if $RayCast2D.is_colliding():
				wall_ahead = true

		if is_on_floor() and jump_timer <= 0.0 and not attacking:
			if wall_ahead:
				velocity.y = jump_velocity
				jump_timer = jump_cooldown

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
			if distance <= 400:
				$AnimationPlayer.play("walk")
				if not $AnimationPlayer.is_playing():
					$AnimationPlayer.play("walk")

		move_and_slide()

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


func _has_solid_tile(tile_layer: TileMapLayer, world_pos: Vector2) -> bool:
	var local_pos := tile_layer.to_local(world_pos)
	var cell := tile_layer.local_to_map(local_pos)
	return tile_layer.get_cell_source_id(cell) != -1


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
