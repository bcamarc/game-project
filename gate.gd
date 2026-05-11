extends AnimatedSprite2D
signal next_level
signal gate_entered(x)
var stop := false
func _ready() -> void:
	gate_entered.connect(get_node("../TileMapLayer").on_next_level)
	gate_entered.connect(get_node("../Stats").on_next_level)
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	print ("a")
	stop = true
	if (body.name == "Knight"):
		gate_entered.emit(global_position.x)
func _process(delta: float) -> void:
	
	if (not stop):
		global_position.y += 1
		print("a")
	if (not stop):
		global_position.y += 1
		print("a")
	if (not stop):
		global_position.y += 1
		print("a")
	if (not stop):
		global_position.y += 1
		print("a")
	if (not stop):
		global_position.y += 1
		print("a")
	if (not stop):
		global_position.y += 1
		print("a")
