extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
var target: Node2D = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("huntress") as Node2D

	if is_instance_valid(target):
		global_position = target.global_position
