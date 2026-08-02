extends Control

@export var map_texture: Texture2D

var poi_list := [
	{"name": "Sunhaven Town", "pos": Vector2(0.50, 0.45)},
	{"name": "Whispering Woods", "pos": Vector2(0.22, 0.28)},
	{"name": "Dragon's Tooth Peaks", "pos": Vector2(0.78, 0.17)},
	{"name": "Shadow Spire Dungeon", "pos": Vector2(0.78, 0.78)},
]

func _ready() -> void:
	# full-screen overlay
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0

	mouse_filter = Control.MOUSE_FILTER_STOP

	var backdrop := ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.6)
	backdrop.anchor_left = 0.0
	backdrop.anchor_top = 0.0
	backdrop.anchor_right = 1.0
	backdrop.anchor_bottom = 1.0
	add_child(backdrop)

	# Map image area (keeps aspect)
	var map_tex := TextureRect.new()
	map_tex.name = "MapTexture"
	map_tex.texture = map_texture
	map_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# anchors: inset from edges so UI fits
	map_tex.anchor_left = 0.06
	map_tex.anchor_top = 0.06
	map_tex.anchor_right = 0.94
	map_tex.anchor_bottom = 0.94
	map_tex.margin_left = 0
	map_tex.margin_top = 0
	map_tex.margin_right = 0
	map_tex.margin_bottom = 0
	add_child(map_tex)

	# small instruction label
	var hint := Label.new()
	hint.text = "Press M to close map"
	hint.anchor_right = 1.0
	hint.anchor_bottom = 1.0
	hint.anchor_left = 0.0
	hint.anchor_top = 0.0
	hint.margin_right = -12
	hint.margin_bottom = -12
	hint.margin_left = 12
	hint.margin_top = -28
	hint.align = Label.ALIGN_RIGHT
	add_child(hint)

	# Defer placement of POI buttons until the control has calculated sizes
	call_deferred("_place_pois")

func _place_pois() -> void:
	var map_tex := get_node_or_null("MapTexture") as TextureRect
	if map_tex == null:
		return
	# get inner rect
	var map_rect := map_tex.get_global_rect()
	# create a container for POI buttons so they move together with the map
	var poi_container := Control.new()
	poi_container.name = "POIContainer"
	poi_container.anchor_left = map_tex.anchor_left
	poi_container.anchor_top = map_tex.anchor_top
	poi_container.anchor_right = map_tex.anchor_right
	poi_container.anchor_bottom = map_tex.anchor_bottom
	poi_container.margin_left = map_tex.margin_left
	poi_container.margin_top = map_tex.margin_top
	poi_container.margin_right = map_tex.margin_right
	poi_container.margin_bottom = map_tex.margin_bottom
	add_child(poi_container)

	# calculate positions and add buttons
	for poi in poi_list:
		var btn := Button.new()
		btn.name = poi["name"]
		btn.text = ""
		btn.tooltip_text = poi["name"]
		btn.rect_pivot_offset = Vector2(16, 16)
		btn.rect_size = Vector2(32, 32)
		# place relative to the map rect using normalized coords
		var local_pos := Vector2(map_rect.size.x * poi["pos"].x, map_rect.size.y * poi["pos"].y)
		# position must be relative to the container's rect; convert global->local
		var global_pos := map_rect.position + local_pos
		var container_global_pos := poi_container.get_global_position()
		var pos_in_container := global_pos - container_global_pos
		btn.position = pos_in_container - btn.rect_pivot_offset
		# style: circular button
		btn.add_theme_constant_override("corner_radius", 16)
		btn.add_theme_color_override("font_color", Color(1,1,1))
		# currently we do nothing on click; expose signal for later
		#btn.pressed.connect(func(): print("POI clicked: ", poi["name"]))
		poi_container.add_child(btn)

	# add visible labels beside buttons (optional)
	for child in poi_container.get_children():
		if child is Button:
			var lbl := Label.new()
			lbl.text = child.tooltip_text
			lbl.anchor_left = 0
			lbl.anchor_top = 0
			lbl.anchor_right = 0
			lbl.anchor_bottom = 0
			lbl.position = child.position + Vector2(20, -8)
			lbl.add_theme_color_override("font_color", Color(1,1,0.8))
			poi_container.add_child(lbl)

func _unhandled_input(event) -> void:
	# close when map action pressed (MapManager sets up the input action)
	if Input.is_action_just_pressed("map"):
		queue_free()
