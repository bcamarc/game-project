extends TileMapLayer

var noise := FastNoiseLite.new()
var zombieScene = preload("res://zombie.tscn")
var gateScene = preload("res://gate1.tscn")

var map_width := 700
var ground_height := 12
var gate_x := 0

const DECORATION_SOURCE_ID := 0
const DECORATION_CHANCE := 0.08
const DECORATION_ATLAS_COORDS := [
	Vector2i(5, 6),
	Vector2i(6, 6),
	Vector2i(5, 7),
	Vector2i(6, 7),
	Vector2i(7, 5),
	Vector2i(7, 6),
	Vector2i(7, 7),
	Vector2i(7, 8),
	Vector2i(8, 5),
	Vector2i(8, 6),
	Vector2i(8, 7),
	Vector2i(8, 8)
]

func _ready() -> void:
	add_to_group("current_map")
	randomize()
	noise.seed = randi()
	noise.frequency = 0.02
	call_deferred("_spawn_map")

func on_next_level():
	queue_free()

func _spawn_map():
	var mob_count := 12
	gate_x = randi_range(50, map_width - 50)

	for x in range(map_width):
		var height = floor(noise.get_noise_1d(x) * 10 + ground_height / 2)
		for y in range(height, ground_height):
			set_cell(Vector2i(x, y - 1), 0, Vector2i(0, 1), 0)
		set_cell(Vector2i(x, height - 2), 0, Vector2i(0, 0), 0)
		_try_place_decoration(x, height)

	var gate = gateScene.instantiate()
	var gate_y = floor(noise.get_noise_1d(gate_x) * 10 + ground_height / 2)
	add_child(gate)
	gate.top_level = true
	gate.global_position = map_to_local(Vector2i(gate_x, gate_y - 10))

	var slot_width: float = float(map_width) / float(mob_count + 1)
	for i in range(mob_count):
		var x: int = int(round(float(i + 1) * slot_width))
		if absi(x - gate_x) < 20:
			if x < gate_x:
				x = maxi(0, gate_x - 25)
			else:
				x = mini(map_width - 1, gate_x + 25)

		var y: int = floor(noise.get_noise_1d(x) * 10 + ground_height / 2)
		var mob: Node2D = zombieScene.instantiate() as Node2D
		if mob == null:
			continue

		add_child(mob)
		mob.top_level = true
		mob.global_position = map_to_local(Vector2i(x, y - 20))

func _try_place_decoration(x: int, surface_height: int) -> void:
	if absi(x - gate_x) <= 6:
		return
	if randf() > DECORATION_CHANCE:
		return

	var decoration_cell := Vector2i(x, surface_height - 3)
	if get_cell_source_id(decoration_cell) != -1:
		return

	var decoration_coords: Vector2i = DECORATION_ATLAS_COORDS.pick_random()
	set_cell(decoration_cell, DECORATION_SOURCE_ID, decoration_coords)
