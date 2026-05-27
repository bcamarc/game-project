extends TileMapLayer

var noise := FastNoiseLite.new()
var slimeScene = preload("res://test_monster.tscn")
var golemScene = preload("res://golem.tscn")
var gateScene = preload("res://gate1.tscn")
var map_width := 700
var ground_height := 20
var safe_x := 0
var safe_y := 0
var world_level := 1

const MAX_GATE_LEVEL := 4
const BASE_TILE_X := 0
const TILE_X_STEP := 2

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
	var mob_count := 6
	var safe_radius := 4
	var tile_x := BASE_TILE_X + ((world_level - 1) * TILE_X_STEP)
	for x in range(map_width):
		var distance: int = absi(x - safe_x)
		var height: int
		if distance <= safe_radius:
			height = safe_y + 4
		else:
			var noise_val: int = int(noise.get_noise_1d(x) * 10 + ground_height / 2)
			var blend: float = clampf(float(distance - safe_radius) / 10.0, 0.0, 1.0)
			height = int(lerp(float(safe_y + 4), float(noise_val), blend))
		for y in range(height, ground_height + 20):
			set_cell(Vector2i(x, y), 0, Vector2i(tile_x, 1))
		set_cell(Vector2i(x, height - 1), 0, Vector2i(tile_x, 0))
		
	var spawned_mobs := 0
	while spawned_mobs < mob_count:
		var x = randi_range(0, map_width - 1)
		if absi(x - safe_x) < 15:
			continue
			
		var y = int(noise.get_noise_1d(x) * 10 + ground_height / 2)
		var mob = slimeScene.instantiate() if randf() < 0.5 else golemScene.instantiate()
		add_child(mob)
		mob.top_level = true
		mob.global_position = map_to_local(Vector2i(x, y - 3))
		spawned_mobs += 1

	if world_level < MAX_GATE_LEVEL:
		var gate_x := randi_range(50, map_width - 50)
		while absi(gate_x - safe_x) < 15:
			gate_x = randi_range(50, map_width - 50)
		var gate_y := _get_surface_height(gate_x, safe_radius)
		var gate = gateScene.instantiate()
		add_child(gate)
		gate.top_level = true
		gate.global_position = map_to_local(Vector2i(gate_x, gate_y - 2))

func _get_surface_height(x: int, safe_radius: int) -> int:
	var distance: int = absi(x - safe_x)
	if distance <= safe_radius:
		return safe_y + 4

	var noise_val: int = int(noise.get_noise_1d(x) * 10 + ground_height / 2)
	var blend: float = clampf(float(distance - safe_radius) / 10.0, 0.0, 1.0)
	return int(lerp(float(safe_y + 4), float(noise_val), blend))
