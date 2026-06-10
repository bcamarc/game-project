extends CharacterBody2D

@onready var stats = null
var target_player: Node2D = null
@export var dropped_item_scene: PackedScene 

var possible_drops = ItemDropPool.monster_items()
var speed := 75.0
var direction := Vector2.ZERO
var attacking := false
var count := 0
var ability := false
var health := 100.0
var died := false
var slime_death := false
var spawn_drop_active := false
var spawn_drop_speed := 1600.0
var damaged := false

var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var jump_velocity := -300.0
var jump_cooldown := 0.35
var jump_timer := 0.0
const MELEE_STOP_DISTANCE := 42.0

signal death(x, y)

func _ready() -> void:
	stats = get_stats()
	add_to_group("alien")
	add_to_group("slime")
	add_to_group("enemy")

	if not is_on_floor():
		spawn_drop_active = true

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
	var player_delta_x: float = alien.global_position.x - monster_pos_x

	if spawn_drop_active and not is_on_floor() and not died:
		velocity.y = maxf(velocity.y, spawn_drop_speed)
		move_and_slide()
		return
	else:
		spawn_drop_active = false

	if distance <= 520.0 or damaged:
		if player_delta_x >= 0.0:
			direction.x = 1.0
			$AnimatedSprite2D.flip_h = false
		else:
			direction.x = -1.0
			$AnimatedSprite2D.flip_h = true

		if attacking or absf(player_delta_x) <= MELEE_STOP_DISTANCE:
			velocity.x = 0.0
		else:
			velocity.x = speed * direction.x

		if attacking and not died:
			if count % 20 == 0 and not $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("Attack")

			if count % 40 == 0:
				damage_player(5)

			if not $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("Run")
		else:
			if not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != "Run":
				$AnimatedSprite2D.play("Run")

		if ability and randf() < 0.001:
			$AnimatedSprite2D.play("Ability")
			$slimeFx.play("ability")
			damage_player(5)

		var tilemap = get_node_or_null("../TileMapLayer")
		var block_width := 48.0
		var block_height := 48.0
		var tile_layer := tilemap as TileMapLayer
		if tile_layer != null and tile_layer.tile_set != null:
			block_width = float(tile_layer.tile_set.tile_size.x) * absf(tile_layer.global_scale.x)
			block_height = float(tile_layer.tile_set.tile_size.y) * absf(tile_layer.global_scale.y)

		var wall_ahead: bool = false
		var floor_ahead: bool = true
		if tile_layer != null and direction.x != 0.0:
			# Tile-based probing is symmetric left/right and avoids false jumps on flat ground.
			var probe_x := global_position.x + direction.x * block_width * 0.9
			var wall_probe_low := Vector2(probe_x, global_position.y + block_height * 0.15)
			var wall_probe_mid := Vector2(probe_x, global_position.y - block_height * 0.35)
			var floor_probe_near := Vector2(probe_x, global_position.y + block_height * 0.95)
			var floor_probe_far := Vector2(probe_x, global_position.y + block_height * 1.35)
			wall_ahead = _has_solid_tile(tile_layer, wall_probe_low) or _has_solid_tile(tile_layer, wall_probe_mid)
			floor_ahead = _has_solid_tile(tile_layer, floor_probe_near) or _has_solid_tile(tile_layer, floor_probe_far)
		else:
			# Fallback for non-tile terrains.
			$RayCast2D.target_position = Vector2(30.0 * direction.x, -4.0)
			$RayCast2D.force_raycast_update()
			if $RayCast2D.is_colliding():
				wall_ahead = true
			var ledge_ray = get_node_or_null("LedgeRayCast2D") as RayCast2D
			if ledge_ray != null:
				ledge_ray.position = Vector2(20.0 * direction.x, 0.0)
				ledge_ray.target_position = Vector2(0.0, 24.0)
				ledge_ray.force_raycast_update()
				floor_ahead = ledge_ray.is_colliding()

		# Jump up when the player is above us and in the movement direction.
		var player_dx := absf(alien.global_position.x - global_position.x)
		var player_dy := global_position.y - alien.global_position.y
		var player_one_block_up := player_dy > block_height * 0.45 and player_dy < block_height * 1.9
		var player_is_ahead := (alien.global_position.x - global_position.x) * direction.x > 0.0
		var player_not_too_close := player_dx > block_width * 2.0
		# Only do a climb jump when there is an actual wall to climb.
		var should_jump_to_player := player_one_block_up and player_is_ahead and player_not_too_close and wall_ahead
		var should_path_jump := wall_ahead or not floor_ahead

		if is_on_floor() and jump_timer <= 0.0:
			# Avoid repeated hop spam during melee contact.
			if should_jump_to_player or (should_path_jump and not attacking):
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
		var s = get_stats(target_player)
		if s:
			s.add_exp(14)
		else:
			print("stats is broken")
		death.emit(position.x, position.y)
		spawn_loot()
		queue_free()

func get_stats(player: Node2D = null) -> Node:
	# Use the same Stats node the player scripts use: ../Stats from the player.
	if player != null and is_instance_valid(player):
		var player_stats := player.get_node_or_null("../Stats")
		if player_stats != null:
			stats = player_stats
			return stats

	# Scene-local Stats (map child) is preferred over autoload when both exist.
	var scene := get_tree().current_scene
	if scene != null:
		var scene_stats := scene.get_node_or_null("Stats")
		if scene_stats != null:
			stats = scene_stats
			return stats

	# Final fallback: autoload singleton.
	var singleton_stats := get_node_or_null("/root/Stats")
	if singleton_stats != null:
		stats = singleton_stats
		return stats

	return null

func _has_solid_tile(tile_layer: TileMapLayer, world_pos: Vector2) -> bool:
	var local_pos := tile_layer.to_local(world_pos)
	var cell := tile_layer.local_to_map(local_pos)
	return tile_layer.get_cell_source_id(cell) != -1

func damage_player(amount: int) -> void:
	if _is_player_immune(target_player):
		return

	var s = get_stats(target_player)
	if s:
		if s.has_method("add_hp"):
			s.add_hp(-amount)
		else:
			s.total_health -= amount
	else:
		print("hp is broken")

func _is_player_immune(player: Node2D) -> bool:
	return player != null and is_instance_valid(player) and player.has_method("is_immune_to_damage") and bool(player.call("is_immune_to_damage"))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		attacking = true
		target_player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		attacking = false
		if body == target_player:
			target_player = null

func _on_ability_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		ability = true

func _on_ability_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		ability = false

func take_damage(a) -> void:
	damaged = true
	health -= a

func spawn_loot() -> void:
	if dropped_item_scene == null or possible_drops.is_empty():
		return

	var dropped_item := ItemDropPool.roll_monster_item()
	if dropped_item.is_empty():
		return

	var item_instance = dropped_item_scene.instantiate()
	item_instance.item_data = dropped_item
	get_parent().add_child(item_instance)
	item_instance.global_position = global_position
