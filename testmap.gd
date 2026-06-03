extends TileMapLayer

const DESERT_BACKGROUND: Texture2D = preload("res://art/desert_background.webp")
const ICE_BACKGROUND: Texture2D = preload("res://art/ice_background.jpg")
const FIRE_BACKGROUND: Texture2D = preload("res://art/lava_background.jpg")

var noise := FastNoiseLite.new()
var zombieScene = preload("res://zombie.tscn")
var slimeScene = preload("res://test_monster.tscn")
var golemScene = preload("res://golem.tscn")
var shadowKnightScene = preload("res://shadow_knight.tscn")
var gateScene = preload("res://gate1.tscn")
var map_width := 700
var ground_height := 20
var safe_x := 0
var safe_y := 0
var world_level := 1
@onready var background_sprite: Sprite2D = $ParallaxBackground/Sprite2D

const MAX_GATE_LEVEL := 4
const LEVEL_FOUR_BOSS_OFFSET := 18
const LEVEL_FOUR_BARRIER_HEIGHT := 26

func set_gate_data(x: int, y: int, level: int = 1):
	safe_x = x
	safe_y = y
	world_level = level

func _ready() -> void:
	add_to_group("current_map")
	randomize()
	noise.seed = randi()
	noise.frequency = 0.01
	call_deferred("_spawn_map")

func on_next_level():
	queue_free()

func _spawn_map():
	clear()
	_apply_level_theme()
	_clear_level_four_barriers()
	var mob_count := 1 if world_level == MAX_GATE_LEVEL else 12
	var safe_radius := 4
	var tile_x := _tile_column_for_level(world_level)
	for x in range(map_width):
		var distance: int = absi(x - safe_x)
		var height: int
		if world_level == MAX_GATE_LEVEL:
			height = _level_four_surface_height()
		elif distance <= safe_radius:
			height = safe_y + 4
		else:
			var noise_val: int = int(noise.get_noise_1d(x) * 10 + ground_height / 2)
			var blend: float = clampf(float(distance - safe_radius) / 10.0, 0.0, 1.0)
			height = int(lerp(float(safe_y + 4), float(noise_val), blend))
		for y in range(height, ground_height + 20):
			set_cell(Vector2i(x, y), 0, Vector2i(tile_x, 1))
		set_cell(Vector2i(x, height - 1), 0, Vector2i(tile_x, 0))

	if world_level == MAX_GATE_LEVEL:
		_spawn_level_four_barriers()

	_spawn_enemies(mob_count)

	if world_level < MAX_GATE_LEVEL:
		var gate_x := randi_range(50, map_width - 50)
		while absi(gate_x - safe_x) < 15:
			gate_x = randi_range(50, map_width - 50)
		var gate_y := _get_surface_height(gate_x, safe_radius)
		var gate = gateScene.instantiate()
		add_child(gate)
		gate.top_level = true
		gate.global_position = map_to_local(Vector2i(gate_x, gate_y - 10))

func _tile_column_for_level(level: int) -> int:
	match level:
		2:
			return 2
		3:
			return 6
		4:
			return 4
		_:
			return 0

func _enemy_scene_for_level(level: int) -> PackedScene:
	match level:
		1:
			return zombieScene
		2:
			return slimeScene
		3:
			return golemScene
		4:
			return shadowKnightScene
		_:
			return zombieScene

func _spawn_enemies(mob_count: int) -> void:
	if world_level == MAX_GATE_LEVEL:
		_spawn_shadow_knight()
		return

	var enemy_scene: PackedScene = _enemy_scene_for_level(world_level)
	var slot_width: float = float(map_width) / float(mob_count + 1)

	for i in range(mob_count):
		var x: int = int(round(float(i + 1) * slot_width))
		if absi(x - safe_x) < 15:
			if x < safe_x:
				x = maxi(0, safe_x - 20)
			else:
				x = mini(map_width - 1, safe_x + 20)

		var y: int = int(noise.get_noise_1d(x) * 10 + ground_height / 2)
		var mob: Node2D = enemy_scene.instantiate() as Node2D
		if mob == null:
			continue

		add_child(mob)
		mob.top_level = true
		mob.global_position = map_to_local(Vector2i(x, y - 3))

func _spawn_shadow_knight() -> void:
	var boss := shadowKnightScene.instantiate() as Node2D
	if boss == null:
		return

	var offset := LEVEL_FOUR_BOSS_OFFSET
	if safe_x > map_width / 2:
		offset = -LEVEL_FOUR_BOSS_OFFSET

	var boss_x := clampi(safe_x + offset, 4, map_width - 5)
	var boss_y := _level_four_surface_height()

	add_child(boss)
	boss.top_level = true
	boss.global_position = map_to_local(Vector2i(boss_x, boss_y - 5))

func _level_four_surface_height() -> int:
	return clampi(safe_y + 4, 4, ground_height + 12)

func _spawn_level_four_barriers() -> void:
	var tile_size := Vector2(48.0, 48.0)
	if tile_set != null:
		tile_size = Vector2(tile_set.tile_size)

	var surface_y := _level_four_surface_height()
	var barrier_top_y := surface_y - LEVEL_FOUR_BARRIER_HEIGHT
	var barrier_tiles := LEVEL_FOUR_BARRIER_HEIGHT + (ground_height + 20 - surface_y)
	var barrier_center_y := barrier_top_y + int(round(float(barrier_tiles) * 0.5))
	var barrier_shape_size := Vector2(tile_size.x, tile_size.y * float(barrier_tiles))

	_create_level_four_barrier("Level4LeftBarrier", Vector2i(-1, barrier_center_y), barrier_shape_size)
	_create_level_four_barrier("Level4RightBarrier", Vector2i(map_width, barrier_center_y), barrier_shape_size)

func _create_level_four_barrier(node_name: String, tile_position: Vector2i, shape_size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 7

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = shape_size
	collision.shape = shape

	body.add_child(collision)
	add_child(body)
	body.position = map_to_local(tile_position)

func _clear_level_four_barriers() -> void:
	for child in get_children():
		if child.name == "Level4LeftBarrier" or child.name == "Level4RightBarrier":
			child.queue_free()

func _background_for_level(level: int) -> Texture2D:
	match level:
		2:
			return DESERT_BACKGROUND
		3:
			return ICE_BACKGROUND
		4:
			return FIRE_BACKGROUND
		_:
			return null

func _apply_level_theme() -> void:
	if background_sprite == null or not is_instance_valid(background_sprite):
		return

	var texture: Texture2D = _background_for_level(world_level)
	background_sprite.texture = texture

	if texture == null:
		background_sprite.visible = false
		return

	background_sprite.visible = true
	background_sprite.z_as_relative = false
	background_sprite.z_index = -1000
	background_sprite.centered = true

	var viewport_size := get_viewport_rect().size
	var scale_factor: float = maxf(
		viewport_size.x / float(texture.get_width()),
		viewport_size.y / float(texture.get_height())
	)
	background_sprite.position = viewport_size * 0.5
	background_sprite.scale = Vector2.ONE * scale_factor

func _get_surface_height(x: int, safe_radius: int) -> int:
	if world_level == MAX_GATE_LEVEL:
		return _level_four_surface_height()

	var distance: int = absi(x - safe_x)
	if distance <= safe_radius:
		return safe_y + 4

	var noise_val: int = int(noise.get_noise_1d(x) * 10 + ground_height / 2)
	var blend: float = clampf(float(distance - safe_radius) / 10.0, 0.0, 1.0)
	return int(lerp(float(safe_y + 4), float(noise_val), blend))
