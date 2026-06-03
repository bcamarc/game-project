extends Panel
@export var slot_scene: PackedScene
@onready var grid = $GridContainer

var items = []
var slot_count := 20

func _ready():
	build_inventory()

func build_inventory():
	for i in range(slot_count):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		if i < items.size():
			slot.set_item(items[i])

func add_item(item_data: Dictionary) -> bool:
	for slot in grid.get_children():
		if slot.has_method("set_item") and slot.get("item") == null:
			slot.set_item(item_data)
			return true
	return false
