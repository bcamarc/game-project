extends TileMapLayer
var a =  Vector2i(1, 1)
var noise := FastNoiseLite.new()
var slimeScene := load("res://test_monster.tscn")
var golemScene := load("res://golem.tscn")
#print(GameState.highest_level_reached)
var moon := false
var mercury := false
var venus := false
var earth := false
var mars := true
var jupiter := false
var saturn := false
var uranus := false
var neptune := false
var mapSpace := 40
var spawned := false
func _ready() -> void:
	
	
	
	randomize()
	noise.seed = randi()
	noise.frequency = 0.02
	call_deferred("_spawn_map")
func _spawn_map():
	var mobCount := 10
	
	var mobSpacing := mapSpace / mobCount

	# generate terrain
	#for x in range(mapSpace):
		#var height = int(noise.get_noise_1d(x) * 10 + 20 / 2)
		#for y in range(height, 20):
			#set_cell(Vector2i(x, y - 8), 1, Vector2i(1, 1), 0) old terrain generation
			#set_cell(Vector2i(x, height - 9), 1, Vector2i(2, 1), 0)
	if moon:
		moon_gen()
	if mercury:
		mercury_gen()
	if venus:
		venus_gen()
	if earth:
		earth_gen()
	if mars:
		mars_gen()
	if jupiter:
		jupiter_gen()
	if saturn:
		saturn_gen()
	if uranus:
		uranus_gen()
	if neptune:
		neptune_gen()
	# spawn mobs evenly
	#for i in range(mobCount):
		#
			#
		#var mob_x = int(i * mobSpacing + mobSpacing / 2)
		#var mob_y = int(noise.get_noise_1d(mob_x) * 10 + 20 / 2)
		##if i == mobCount - 1:
			##var goalpost_scene = preload("res://goalpost.tscn")
			##var goalpost = goalpost_scene.instantiate()
			##get_parent().add_child(goalpost)
			##var tile_pos = Vector2i(580, noise.get_noise_1d(mob_x) * 10 + 20 / 2)
			##goalpost.global_position = map_to_local(tile_pos)
#
		#var mob 
		#if randf() < 0.5:
			#mob = slimeScene.instantiate()
		#else:
			#mob = golemScene.instantiate()
#
		#get_parent().add_child(mob)
		#mob.position = map_to_local(Vector2(mob_x *3, mob_y - 25))
func get_surface_y(x: int) -> int:
	for y in range(-600, 600): # adjust if needed
		if get_cell_source_id(Vector2i(x, y)) != -1:
			return y - 1
		
	return 0
		
func moon_gen():
	for x in range (mapSpace):
		var height = int(noise.get_noise_1d(x) * 10 + 20 / 2)
		for y in range (height, 20):
			if (randf() < 0.25):
				set_cell(Vector2i(x, y-8), 1, Vector2i(0, 1), 0)
			elif (randf() < 0.5):
				set_cell(Vector2i(x, y-8), 1, Vector2i(1, 1), 0)
			elif (randf() <0.75):
				set_cell(Vector2i(x, y-8), 1, Vector2i(2, 1), 0)
			else:
				set_cell(Vector2i(x, y-8), 1, Vector2i(3, 1), 0)
			if x == mapSpace - 6:
				var goalpost_scene = preload("res://goalpost.tscn")
				var goalpost = goalpost_scene.instantiate()
				get_parent().add_child(goalpost)
				var tile_pos = Vector2i(x*3, get_surface_y(x))
				goalpost.global_position = map_to_local(tile_pos)
func mercury_gen():
	for x in range (mapSpace):
		var height = int(noise.get_noise_1d(x) * 10 + 20 / 2)
		for y in range (height, 20):
			if (randf() < 0.25):
				set_cell(Vector2i(x, y-8), 1, Vector2i(0, 9), 0)
			elif (randf() < 0.5):
				set_cell(Vector2i(x, y-8), 1, Vector2i(1, 9), 0)
			elif (randf() <0.75):
				set_cell(Vector2i(x, y-8), 1, Vector2i(2, 9), 0)
			else:
				set_cell(Vector2i(x, y-8), 1, Vector2i(3, 9), 0)
			if x == mapSpace - 6:
				var goalpost_scene = preload("res://goalpost.tscn")
				var goalpost = goalpost_scene.instantiate()
				get_parent().add_child(goalpost)
				var tile_pos = Vector2i(x*3, get_surface_y(x))
				goalpost.global_position = map_to_local(tile_pos)
func venus_gen():
	for x in range (mapSpace):
		var height = int(noise.get_noise_1d(x) * 10 + 20 / 2)
		for y in range (height, 20):
			if (randf() < 0.25):
				set_cell(Vector2i(x, y-8), 1, Vector2i(0, 2), 0)
			elif (randf() < 0.5):
				set_cell(Vector2i(x, y-8), 1, Vector2i(1, 2), 0)
			elif (randf() <0.75):
				set_cell(Vector2i(x, y-8), 1, Vector2i(2, 2), 0)
			else:
				set_cell(Vector2i(x, y-8), 1, Vector2i(3, 2), 0)
			if x == mapSpace - 6:
				#var goalpost_scene = preload("res://goalpost.tscn")
				#var goalpost = goalpost_scene.instantiate()
				#get_parent().add_child(goalpost)
				#var tile_pos = Vector2i(x*3, get_surface_y(x))
				#goalpost.global_position = map_to_local(tile_pos)
				
				var fire_alien = preload("res://fire_alien.tscn")
				var boss = fire_alien.instantiate()
				get_parent().add_child(boss)
				var alien_pos = Vector2i(x*3, get_surface_y(x))
				boss.global_position = map_to_local(alien_pos)
			
func earth_gen():
	for x in range (mapSpace):
		var height = int(noise.get_noise_1d(x) * 10 + 20 / 2)
		for y in range (height, 20):
			if (randf() < 0.25):
				set_cell(Vector2i(x, y-8), 1, Vector2i(0, 3), 0)
			elif (randf() < 0.5):
				set_cell(Vector2i(x, y-8), 1, Vector2i(1, 3), 0)
			elif (randf() <0.75):
				set_cell(Vector2i(x, y-8), 1, Vector2i(2, 3), 0)
			else:
				set_cell(Vector2i(x, y-8), 1, Vector2i(3, 3), 0)
			if x == mapSpace - 6:
				var goalpost_scene = preload("res://goalpost.tscn")
				var goalpost = goalpost_scene.instantiate()
				get_parent().add_child(goalpost)
				var tile_pos = Vector2i(x*3, get_surface_y(x))
				goalpost.global_position = map_to_local(tile_pos)
func mars_gen():
	for x in range (mapSpace):
		var height = 12
		for y in range (height, 20):
			if (randf() < 0.25):
				set_cell(Vector2i(x, y-8), 2, Vector2i(0, 4), 0)
			elif (randf() < 0.5):
				set_cell(Vector2i(x, y-8), 2, Vector2i(1, 4), 0)
			elif (randf() <0.75):
				set_cell(Vector2i(x, y-8), 2, Vector2i(2, 4), 0)
			else:
				set_cell(Vector2i(x, y-8), 2, Vector2i(3, 4), 0)
			if x == mapSpace - 6:
				var goalpost_scene = preload("res://goalpost.tscn")
				var goalpost = goalpost_scene.instantiate()
				get_parent().add_child(goalpost)
				var tile_pos = Vector2i(x*3, get_surface_y(x))
				goalpost.global_position = map_to_local(tile_pos)
func jupiter_gen():
	for x in range (mapSpace):
		var height = int(noise.get_noise_1d(x) * 10 + 20 / 2)
		for y in range (height, 20):
			if (randf() < 0.25):
				set_cell(Vector2i(x, y-8), 1, Vector2i(0, 5), 0)
			elif (randf() < 0.5):
				set_cell(Vector2i(x, y-8), 1, Vector2i(1, 5), 0)
			elif (randf() <0.75):
				set_cell(Vector2i(x, y-8), 1, Vector2i(2, 5), 0)
			else:
				set_cell(Vector2i(x, y-8), 1, Vector2i(3, 5), 0)
			if x == mapSpace - 6:
				var goalpost_scene = preload("res://goalpost.tscn")
				var goalpost = goalpost_scene.instantiate()
				get_parent().add_child(goalpost)
				var tile_pos = Vector2i(x*3, get_surface_y(x))
				goalpost.global_position = map_to_local(tile_pos)
func saturn_gen():
	for x in range (mapSpace):
		var height = int(noise.get_noise_1d(x) * 10 + 20 / 2)
		for y in range (height, 20):
			if (randf() < 0.25):
				set_cell(Vector2i(x, y-8), 1, Vector2i(0, 6), 0)
			elif (randf() < 0.5):
				set_cell(Vector2i(x, y-8), 1, Vector2i(1, 6), 0)
			elif (randf() <0.75):
				set_cell(Vector2i(x, y-8), 1, Vector2i(2, 6), 0)
			else:
				set_cell(Vector2i(x, y-8), 1, Vector2i(3, 6), 0)
			if x == mapSpace - 6:
				var goalpost_scene = preload("res://goalpost.tscn")
				var goalpost = goalpost_scene.instantiate()
				get_parent().add_child(goalpost)
				var tile_pos = Vector2i(x*3, get_surface_y(x))
				goalpost.global_position = map_to_local(tile_pos)
func uranus_gen():
	for x in range (mapSpace):
		var height = int(noise.get_noise_1d(x) * 10 + 20 / 2)
		for y in range (height, 20):
			if (randf() < 0.25):
				set_cell(Vector2i(x, y-8), 1, Vector2i(0, 7), 0)
			elif (randf() < 0.5):
				set_cell(Vector2i(x, y-8), 1, Vector2i(1, 7), 0)
			elif (randf() <0.75):
				set_cell(Vector2i(x, y-8), 1, Vector2i(2, 7), 0)
			else:
				set_cell(Vector2i(x, y-8), 1, Vector2i(3, 7), 0)
			if x == mapSpace - 6:
				var goalpost_scene = preload("res://goalpost.tscn")
				var goalpost = goalpost_scene.instantiate()
				get_parent().add_child(goalpost)
				var tile_pos = Vector2i(x*3, get_surface_y(x))
				goalpost.global_position = map_to_local(tile_pos)
func neptune_gen():
	for x in range (mapSpace):
		var height = int(noise.get_noise_1d(x) * 10 + 20 / 2)
		for y in range (height, 20):
			if (randf() < 0.25):
				set_cell(Vector2i(x, y-8), 1, Vector2i(0, 8), 0)
			elif (randf() < 0.5):
				set_cell(Vector2i(x, y-8), 1, Vector2i(1, 8), 0)
			elif (randf() <0.75):
				set_cell(Vector2i(x, y-8), 1, Vector2i(2, 8), 0)
			else:
				set_cell(Vector2i(x, y-8), 1, Vector2i(3, 8), 0)
			if x == mapSpace - 6:
				var goalpost_scene = preload("res://goalpost.tscn")
				var goalpost = goalpost_scene.instantiate()
				get_parent().add_child(goalpost)
				var tile_pos = Vector2i(x*3, get_surface_y(x))
				goalpost.global_position = map_to_local(tile_pos)
