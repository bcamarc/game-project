extends TileMapLayer

var noise := FastNoiseLite.new()

var slimeScene = preload("res://test_monster.tscn")
var golemScene = preload("res://golem.tscn")

var map_width := 700
var ground_height := 20

var safe_x := 0

func _ready() -> void:
	randomize()
	noise.seed = randi()
	noise.frequency = 0.01
	call_deferred("_spawn_map")

func _spawn_map():
	clear()

	var mob_count := 6
	var safe_radius := 4

	for x in range(map_width):
		var height = int(noise.get_noise_1d(x) * 10 + ground_height / 2)

		for y in range(height, ground_height):
			set_cell(Vector2i(x, y - 1), 0, Vector2i(2, 0), 0)

		set_cell(Vector2i(x, height - 2), 0, Vector2i(2, 1), 0)

	var safe_y := ground_height - 6

	for x in range(safe_x - safe_radius, safe_x + safe_radius + 1):
		for y in range(safe_y, ground_height):
			set_cell(Vector2i(x, y - 1), 0, Vector2i(2, 0), 0)

	for x in range(safe_x - safe_radius, safe_x + safe_radius + 1):
		set_cell(Vector2i(x, safe_y - 2), 0, Vector2i(2, 1), 0)

	for i in range(mob_count):
		var x = int(i * (map_width / mob_count))
		var y = int(noise.get_noise_1d(x) * 10 + ground_height / 2)

		var mob

		if randf() < 0.5:
			mob = slimeScene.instantiate()
		else:
			mob = golemScene.instantiate()

		get_parent().add_child(mob)
		mob.global_position = map_to_local(Vector2i(x, y - 3))
