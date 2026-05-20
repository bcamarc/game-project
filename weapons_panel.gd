extends Panel
@export var slot_scene: PackedScene
@onready var grid = $GridContainer

var items = [
	{"name": "Sword", "icon": preload("res://RPG Icons/Icon6.png"), "type": "weapon"},
	{"name": "Shield", "icon": preload("res://RPG Icons/Icon184.png"), "type": "chestplate"},
	{"name": "Potion", "icon": preload("res://RPG Icons/Icon163.png"), "type": "helmet"}
]

func _ready():
	build_inventory()

func build_inventory():
	for i in range(items.size()):
		var slot = slot_scene.instantiate()
		slot.set_item(items[i])
		grid.add_child(slot)
