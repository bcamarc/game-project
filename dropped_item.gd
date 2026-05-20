extends Sprite2D
var item_data: Dictionary

@onready var sprite = $Sprite2D
func _ready() -> void:
	if item_data and item_data.has("icon"):
		texture = item_data["icon"]
func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("player")):
		print("works")
