extends TileMapLayer

var noise := FastNoiseLite.new()

var slimeScene = preload("res://test_monster.tscn")
var golemScene = preload("res://golem.tscn")
var gateScene = preload("res://gate1.tscn")

var map_width := 700
var ground_height := 20

var gate_x := 0

func _ready() -> void:
	randomize()

	noise.seed = randi()
	noise.frequency = 0.01

	call_deferred("_spawn_map")


func on_next_level(x):
	print("worke")
	queue_free()


func _spawn_map():

	var mob_count := 6

	gate_x = randi_range(50, map_width - 50)

	for x in range(map_width):

		var height = int(noise.get_noise_1d(x) * 10 + ground_height / 2)

		for y in range(height, ground_height):
			set_cell(Vector2i(x, y - 1), 0, Vector2i(0, 1), 0)

		set_cell(Vector2i(x, height - 2), 0, Vector2i(0, 0), 0)

		if randi() % 20 == 0:
			set_cell(Vector2i(x, height - 3), 0, Vector2i(6, 6), 0)

		if randi() % 20 == 0:
			set_cell(Vector2i(x, height - 3), 0, Vector2i(8, 5), 0)

	if randf() < 0.5:

		var gate = gateScene.instantiate()

		var gate_y = int(noise.get_noise_1d(gate_x) * 10 + ground_height / 2)

		get_parent().add_child(gate)

		gate.global_position = map_to_local(Vector2i(gate_x, gate_y - 40))

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
