extends TileMapLayer

var noise := FastNoiseLite.new()

@export var map_width := 200
@export var map_height := 40

func _ready() -> void:
	randomize()

	noise.seed = randi()
	noise.frequency = 0.05
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	call_deferred("_generate_terrain")


func _generate_terrain():
	clear()

	for x in range(map_width):
		# generate height using noise
		var height := int(noise.get_noise_1d(x) * 10 + map_height / 2)

		for y in range(height, map_height):
			# place your normal tile (atlas coords 1,1 — change if needed)
			set_cell(Vector2i(x, y), 0, Vector2i(1, 1), 0)
