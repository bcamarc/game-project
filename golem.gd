extends CharacterBody2D

@onready var stats: Node = null
var target_player: Node2D = null
var dropped_item_scene: PackedScene = preload("res://dropped_item.tscn")
var possible_drops = ItemDropPool.monster_items()

var speed := 50.0
var monsterPos := global_position.x
var direction := Vector2.ZERO
var attacking := false
var count := 0
var Acount := 400
var ability := false
var health := 200
var shieldHealth := 0
var up := false
var first := true
var spawn_drop_active := false
var spawn_drop_speed := 1600.0
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
	stats = resolve_stats()
	add_to_group("enemy")
	add_to_group("golem")

	if not is_on_floor():
		spawn_drop_active = true

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

	# Fast spawn-only fall so high-spawned enemies clear random terrain quickly.
	if spawn_drop_active and not is_on_floor():
		velocity.y = maxf(velocity.y, spawn_drop_speed)
		move_and_slide()
		return
	else:
		spawn_drop_active = false

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

	# Terrain-only jump logic
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
		damage_player(15)

	if health <= 0:
		emit_signal("death", position.x, position.y)

		var s = resolve_stats(target_player)
		if s:
			s.add_exp(32)
		else:
			print("Stats not found: cannot add exp")

		spawn_loot()
		queue_free()
		return

	move_and_slide()

func resolve_stats(player: Node2D = null) -> Node:
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

	var s = resolve_stats(target_player)
	if s:
		if s.has_method("add_hp"):
			s.add_hp(-amount)
		else:
			s.total_health -= amount
	else:
		print("Stats not found: cannot damage player")

func _is_player_immune(player: Node2D) -> bool:
	return player != null and is_instance_valid(player) and player.has_method("is_immune_to_damage") and bool(player.call("is_immune_to_damage"))

func _on_frame_changed() -> void:
	if $AnimatedSprite2D.animation == "AttackB" and $AnimatedSprite2D.frame == attack_frame:
		damage_player(attack_damage)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		attacking = true
		target_player = body

func take_damage(a: int) -> void:
	if shieldHealth <= a:
		health -= a - shieldHealth
		shieldHealth = 0
	else:
		shieldHealth -= a

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		attacking = false
		if body == target_player:
			target_player = null

func _on_ability_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		abilityRadius = true

func _on_ability_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		abilityRadius = false

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
