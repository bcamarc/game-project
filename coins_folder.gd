extends Node2D
var scene = load("res://coin.tscn")
func _ready() -> void:
	call_deferred("spawn_things")
	

func _process(delta: float) -> void:
	spawn_things()

func spawn_things():
	
	for node in get_tree().get_nodes_in_group("golem"):
		if node.has_signal("death"):
			
			if not node.is_connected("death", Callable(self, "_on_test_monster_death")):
				node.connect("death", Callable(self, "_on_test_monster_death"))

	#for node in get_tree().get_nodes_in_group("alien"):
		#if node.has_signal("death"):
			#node.connect("death", Callable(self, "_on_test_monster_death2"))
	for node in get_tree().get_nodes_in_group("alien"):
		if node.has_signal("death"):
		
			if not node.is_connected("death", Callable(self, "_on_test_monster_death2")):
				node.connect("death", Callable(self, "_on_test_monster_death2"))

func _on_test_monster_death(x: Variant, y: Variant) -> void:
	var instance = scene.instantiate()
	var instance2 = scene.instantiate()
	add_child(instance)
	add_child(instance2)
	instance.position = Vector2(x,y)
	instance2.position = Vector2(x+ 10, y)
	
func _on_test_monster_death2(x: Variant, y: Variant) -> void:
	var instance = scene.instantiate()
	#var instance2 = scene.instantiate()
	add_child(instance)
	#add_child(instance2)
	instance.position = Vector2(x,y)
	#instance2.position = Vector2(x+ 10, y)

func _on_test_monster_death3(x: Variant, y: Variant) -> void:
	var instance = scene.instantiate()
	var instance2 = scene.instantiate()
	var instance3 = scene.instantiate()
	var instance4 = scene.instantiate()
	var instance5 = scene.instantiate()
	var instance6 = scene.instantiate()
	add_child(instance)
	add_child(instance2)
	add_child(instance3)
	add_child(instance4)
	add_child(instance5)
	add_child(instance6)
	instance.position = Vector2(x,y)
	instance2.position = Vector2(x+ 10, y)
	instance3.position = Vector2(x+20,y)
	instance4.position = Vector2(x+ 30, y)
	instance5.position = Vector2(x-10,y)
	instance6.position = Vector2(x-12, y)
