#extends CanvasLayer
#
#@onready var knight_btn: BaseButton = %KnightButton
#@onready var huntress_btn: BaseButton = %HuntressButton
#@onready var wizard_btn: BaseButton = %WizardButton
#
#func _ready() -> void:
	#hide()
	#process_mode = Node.PROCESS_MODE_ALWAYS
#
	#knight_btn.pressed.connect(func(): select_player("knight"))
	#huntress_btn.pressed.connect(func(): select_player("huntress"))
	#wizard_btn.pressed.connect(func(): select_player("wizard"))
#
#func select_player(player_name: String) -> void:
	#Stats.set_player(player_name)
	#get_tree().paused = false
	#hide()
	#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("character"):
		#toggle_menu()
		#
		#get_viewport().set_input_as_handled()
#
#func toggle_menu() -> void:
	#visible = !visible
	#get_tree().paused = !get_tree().paused
	#get_tree().paused = visible
extends CanvasLayer

@onready var knight_btn: BaseButton = %KnightButton
@onready var huntress_btn: BaseButton = %HuntressButton
@onready var wizard_btn: BaseButton = %WizardButton

func _ready() -> void:
	hide()
	toggle_menu()
	process_mode = Node.PROCESS_MODE_ALWAYS

	knight_btn.pressed.connect(func(): select_player("knight"))
	huntress_btn.pressed.connect(func(): select_player("huntress"))
	wizard_btn.pressed.connect(func(): select_player("wizard"))

func select_player(player_name: String) -> void:
	Stats.set_player(player_name)
	hide()
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("character"):
		toggle_menu()
		get_viewport().set_input_as_handled()

func toggle_menu() -> void:
	visible = !visible
	get_tree().paused = visible
