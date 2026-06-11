extends CharacterBody2D

var speed := 75.0
var direction := Vector2.ZERO
var attacking := false
var ability := false
var health := 50.0
var died := false
var damaged := false
var stats: Node = null
var target_player: Node2D = null

var dropped_item_scene: PackedScene = preload("res://dropped_item.tscn")
var possible_drops = ItemDropPool.monster_items()

var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var jump_velocity := -360.0
var jump_cooldown := 0.4
var jump_timer := 0.0
var spawn_drop_active := false
var spawn_drop_speed := 1600.0

var attack_damage := 3.0
var attack_cooldown := 0.65
var attack_timer := 0.0
var ability_damage := 5.0
var ability_chance_per_second := 0.15
var chase_distance := 500.0
const MELEE_STOP_DISTANCE := 42.0

signal death(x, y)

func _ready() -> void:
	add_to_group("alien")
	add_to_group("enemy")
	add_to_group("test")
	stats = _resolve_stats()

	if not is_on_floor():
		spawn_drop_active = true

	_add_raycast_exception("../Golem")
	_add_raycast_exception("../TestMonster")

func _physics_process(delta: float) -> void:
	if died:
		return

	if health <= 0.0:
		_die()
		return

	_update_timers(delta)
	_apply_gravity(delta)

	$ProgressBar.value = health

	var player := _find_nearest_player()
	if player == null:
		target_player = null
		attacking = false
		velocity.x = 0.0
		_play_animation("idle")
		move_and_slide()
		return

	target_player = player

	if spawn_drop_active and not is_on_floor():
		velocity.y = maxf(velocity.y, spawn_drop_speed)
		move_and_slide()
		return
	spawn_drop_active = false

	var distance := global_position.distance_to(player.global_position)
	var should_chase := distance <= chase_distance or damaged

	if should_chase:
		_move_toward_player(player)
		_try_jump_over_terrain(player)

		if attacking:
			_try_attack_player()
		else:
			_play_animation("walk")

		_try_ability_attack(delta)
	else:
		velocity.x = 0.0
		_play_animation("idle")

	move_and_slide()

func _update_timers(delta: float) -> void:
	if jump_timer > 0.0:
		jump_timer -= delta
	if attack_timer > 0.0:
		attack_timer -= delta

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

func _find_nearest_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("alien_player")
	if players.is_empty():
		players = get_tree().get_nodes_in_group("player")

	var nearest: Node2D = null
	var nearest_distance := INF
	for p in players:
		if p is Node2D and is_instance_valid(p):
			var distance := global_position.distance_to((p as Node2D).global_position)
			if distance < nearest_distance:
				nearest = p as Node2D
				nearest_distance = distance

	return nearest

func _move_toward_player(player: Node2D) -> void:
	var delta_x: float = player.global_position.x - global_position.x
	if delta_x >= 0.0:
		direction.x = 1.0
		$Sprite2D.flip_h = true
	else:
		direction.x = -1.0
		$Sprite2D.flip_h = false

	if attacking or absf(delta_x) <= MELEE_STOP_DISTANCE:
		velocity.x = 0.0
		return

	velocity.x = speed * direction.x

func _try_jump_over_terrain(player: Node2D) -> void:
	var tile_layer := get_node_or_null("../TileMapLayer") as TileMapLayer
	var block_width := 48.0
	var block_height := 48.0

	if tile_layer != null and tile_layer.tile_set != null:
		block_width = float(tile_layer.tile_set.tile_size.x) * absf(tile_layer.global_scale.x)
		block_height = float(tile_layer.tile_set.tile_size.y) * absf(tile_layer.global_scale.y)

	var wall_ahead := false
	var floor_ahead := true

	if tile_layer != null and direction.x != 0.0:
		var probe_origin: Vector2 = $CollisionShape2D.global_position
		var collision_half_width := block_width * 0.35
		var collision_shape: Shape2D = $CollisionShape2D.shape
		if collision_shape is RectangleShape2D:
			collision_half_width = (collision_shape as RectangleShape2D).size.x * absf($CollisionShape2D.global_scale.x) * 0.5

		var front_edge_x := probe_origin.x + direction.x * collision_half_width
		var probe_y := probe_origin.y
		var probe_distances := [
			block_width * 0.2,
			block_width * 0.5,
			block_width * 0.85
		]

		wall_ahead = false
		floor_ahead = false
		for distance_ahead in probe_distances:
			var probe_x: float = front_edge_x + direction.x * float(distance_ahead)
			var wall_probe_low := Vector2(probe_x, probe_y + block_height * 0.15)
			var wall_probe_mid := Vector2(probe_x, probe_y - block_height * 0.35)
			var floor_probe := Vector2(probe_x, probe_y + block_height * 1.1)

			wall_ahead = wall_ahead or _has_solid_tile(tile_layer, wall_probe_low) or _has_solid_tile(tile_layer, wall_probe_mid)
			floor_ahead = floor_ahead or _has_solid_tile(tile_layer, floor_probe)
	elif direction.x != 0.0:
		$RayCast2D.position = Vector2(7.0 * direction.x, 11.0)
		$RayCast2D.target_position = Vector2(35.0 * direction.x, -5.0)
		$RayCast2D.force_raycast_update()
		wall_ahead = $RayCast2D.is_colliding()

	var player_dx := absf(player.global_position.x - global_position.x)
	var player_dy := global_position.y - player.global_position.y
	var player_one_block_up := player_dy > block_height * 0.45 and player_dy < block_height * 1.9
	var player_is_ahead := (player.global_position.x - global_position.x) * direction.x > 0.0
	var player_not_too_close := player_dx > block_width * 2.0
	var should_jump_to_player := player_one_block_up and player_is_ahead and player_not_too_close and wall_ahead
	var should_path_jump := wall_ahead or not floor_ahead

	if is_on_floor() and jump_timer <= 0.0 and not attacking:
		if should_jump_to_player or should_path_jump:
			velocity.y = jump_velocity
			jump_timer = jump_cooldown

func _try_attack_player() -> void:
	if attack_timer > 0.0:
		return

	attack_timer = attack_cooldown
	_play_animation("attack")
	_damage_player(attack_damage)

func _try_ability_attack(delta: float) -> void:
	if not ability:
		return
	if randf() > ability_chance_per_second * delta:
		return

	$slimeFx.play("ability")
	_damage_player(ability_damage)

func _die() -> void:
	if died:
		return

	died = true
	velocity = Vector2.ZERO

	var current_stats := _resolve_stats()
	if current_stats != null and current_stats.has_method("add_exp"):
		current_stats.add_exp(5)

	death.emit(position.x, position.y)
	spawn_loot()
	queue_free()

func take_damage(amount) -> void:
	if died:
		return

	damaged = true
	health = maxf(health - float(amount), 0.0)
	_play_animation("hurt")

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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if _is_player(body):
		attacking = true
		target_player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if _is_player(body):
		attacking = false
		if body == target_player:
			target_player = null

func _on_ability_area_body_entered(body: Node2D) -> void:
	if _is_player(body):
		ability = true

func _on_ability_area_body_exited(body: Node2D) -> void:
	if _is_player(body):
		ability = false

func _is_player(body: Node) -> bool:
	return body != null and (body.is_in_group("alien_player") or body.is_in_group("player"))

func _has_solid_tile(tile_layer: TileMapLayer, world_pos: Vector2) -> bool:
	var local_pos := tile_layer.to_local(world_pos)
	var cell := tile_layer.local_to_map(local_pos)
	return tile_layer.get_cell_source_id(cell) != -1

func _damage_player(amount: float) -> void:
	if _is_player_immune(target_player):
		return

	var current_stats := _resolve_stats(target_player)
	if current_stats == null:
		return

	if current_stats.has_method("add_hp"):
		current_stats.add_hp(-amount)
	else:
		current_stats.total_health -= amount

func _is_player_immune(player: Node2D) -> bool:
	return player != null and is_instance_valid(player) and player.has_method("is_immune_to_damage") and bool(player.call("is_immune_to_damage"))

func _resolve_stats(player: Node2D = null) -> Node:
	if is_instance_valid(stats):
		return stats

	if player != null and is_instance_valid(player):
		var player_stats := player.get_node_or_null("../Stats")
		if player_stats != null:
			stats = player_stats
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

func _play_animation(animation_name: String) -> void:
	if $AnimationPlayer.has_animation(animation_name):
		if $AnimationPlayer.current_animation != animation_name:
			$AnimationPlayer.play(animation_name)

func _add_raycast_exception(path: NodePath) -> void:
	var node := get_node_or_null(path)
	if node is CollisionObject2D:
		$RayCast2D.add_exception(node)
