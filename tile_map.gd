extends TileMapLayer
var a =  Vector2i(1, 1)
var noise := FastNoiseLite.new()
func _ready() -> void:
	randomize()
	noise.seed = randi()
	noise.frequency = 0.01
	set_cell(a, 0, Vector2i(0, 0), 0)
	for x in range(70):
		var height = int(noise.get_noise_1d(x) * 10 + 20 / 2)
		for y in range(height, 20):
			set_cell(Vector2i(x, y-1), 0, Vector2i(0, 1), 0)
			set_cell(Vector2i(x, height-2), 0, Vector2i(0, 0), 0)
