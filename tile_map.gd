extends TileMapLayer

var noise := FastNoiseLite.new()
var slimeScene = preload("res://test_monster.tscn")
var golemScene = preload("res://golem.tscn")
var zombieScene = preload("res://zombie.tscn")
var gateScene = preload("res://gate1.tscn")

var map_width := 700
var ground_height := 12
var gate_x := 0

func _ready() -> void:
	add_to_group("current_map")
	randomize()
	noise.seed = randi()
	noise.frequency = 0.02
	call_deferred("_spawn_map")

func on_next_level():
	queue_free()

func _spawn_map():
	var mob_count := 20
	gate_x = randi_range(50, map_width - 50)

	for x in range(map_width):
		var height = floor(noise.get_noise_1d(x) * 10 + ground_height / 2)
		for y in range(height, ground_height):
			set_cell(Vector2i(x, y - 1), 0, Vector2i(0, 1), 0)
		set_cell(Vector2i(x, height - 2), 0, Vector2i(0, 0), 0)

	var gate = gateScene.instantiate()
	var gate_y = floor(noise.get_noise_1d(gate_x) * 10 + ground_height / 2)
	add_child(gate)
	gate.top_level = true
	gate.global_position = map_to_local(Vector2i(gate_x, gate_y - 2))

	for i in range(mob_count):
		var x = randi_range(0, map_width - 1)
		var y = floor(noise.get_noise_1d(x) * 10 + ground_height / 2)
		var random = randf()
		#var mob = slimeScene.instantiate() if random < 0.333 elif random <0.666 golemScene.instantiate() else zombieScene.instantiate()
		var mob
		if random < 0.333:
			mob = slimeScene.instantiate()
		elif random < 0.666: 
			mob = golemScene.instantiate()
		else:
			mob = zombieScene.instantiate()
		
		
		add_child(mob)
		mob.top_level = true
		mob.global_position = map_to_local(Vector2i(x, y - 3))
