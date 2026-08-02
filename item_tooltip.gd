extends Control

# A small hover tooltip that follows the mouse showing item details.
# Create with: var t = preload("res://item_tooltip.gd").new(); parent.add_child(t); t.populate(item); t.show_at(position)

@onready var _panel: Panel = null
@onready var _name_label: Label = null
@onready var _classes_label: Label = null
@onready var _rarity_label: Label = null
@onready var _stats_vbox: VBoxContainer = null

var follow_cursor := true
var offset := Vector2(18, 18)

func _init():
	# Build UI programmatically so this script can be instanced without a .tscn
	_panel = Panel.new()
	_panel.custom_minimum_size = Vector2(220, 96)
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.margin_left = 6
	vbox.margin_top = 6
	vbox.margin_right = -6
	vbox.margin_bottom = -6
	_panel.add_child(vbox)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 16)
	_name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	vbox.add_child(_name_label)

	_rarity_label = Label.new()
	_rarity_label.add_theme_font_size_override("font_size", 12)
	_rarity_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	vbox.add_child(_rarity_label)

	_classes_label = Label.new()
	_classes_label.add_theme_font_size_override("font_size", 12)
	_classes_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	vbox.add_child(_classes_label)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	_stats_vbox = VBoxContainer.new()
	vbox.add_child(_stats_vbox)

	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	if visible and follow_cursor:
		global_position = get_global_mouse_position() + offset

func populate(item: Dictionary) -> void:
	# populate fields from an item dictionary
	if not (item is Dictionary):
		_name_label.text = "Unknown"
		_rarity_label.text = ""
		_classes_label.text = ""
		_stats_vbox.clear()
		return

	var name := str(item.get("name", "Unknown Item"))
	var rarity := str(item.get("rarity", "Common"))
	var allowed := item.get("classes", [])

	_name_label.text = name
	_rarity_label.text = "Rarity: " + rarity

	if typeof(allowed) == TYPE_ARRAY and allowed.size() > 0:
		_classes_label.text = "Classes: " + ", ".join(allowed)
	else:
		_classes_label.text = "Classes: All"

	# stats
	_stats_vbox.clear()
	var stats_order := ["damage", "defense", "speed", "magic", "strength", "vitality", "intelligence", "dexterity"]
	for s in stats_order:
		if item.has(s):
			var lbl := Label.new()
			lbl.text = "+%s %s" % [str(item[s]), s.capitalize()]
			lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
			_stats_vbox.add_child(lbl)

func show_at(global_pos: Vector2) -> void:
	visible = true
	_process(0)
	global_position = global_pos + offset

func hide_tooltip() -> void:
	visible = false
