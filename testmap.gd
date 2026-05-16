extends TileMapLayer

var noise := FastNoiseLite.new()
var slimeScene = preload("res://test_monster.tscn")
var golemScene = preload("res://golem.tscn")
var map_width := 700
var ground_height := 20
var safe_x := 0
var safe_y := 0

func set_gate_data(x: int, y: int):
	safe_x = x
	safe_y = y

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
	for x in range(map_width):
		var distance = abs(x - safe_x)
		var height: int
		if distance <= safe_radius:
			height = safe_y + 4
		else:
			var noise_val = int(noise.get_noise_1d(x) * 10 + ground_height / 2)
			var blend = clamp((distance - safe_radius) / 10.0, 0.0, 1.0)
			height = int(lerp(float(safe_y + 4), float(noise_val), blend))
		for y in range(height, ground_height + 20):
			set_cell(Vector2i(x, y), 0, Vector2i(2, 0))
		set_cell(Vector2i(x, height - 1), 0, Vector2i(2, 1))
		
	var spawned_mobs := 0
	while spawned_mobs < mob_count:
		var x = randi_range(0, map_width - 1)
		if abs(x - safe_x) < 15:
			continue
			
		var y = int(noise.get_noise_1d(x) * 10 + ground_height / 2)
		var mob = slimeScene.instantiate() if randf() < 0.5 else golemScene.instantiate()
		add_child(mob)
		mob.top_level = true
		mob.global_position = map_to_local(Vector2i(x, y - 3))
		spawned_mobs += 1
