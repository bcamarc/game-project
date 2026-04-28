extends CharacterBody2D

@export var walk_time := 0.5
@onready var sprite: Sprite2D = $Sprite2D
var jump_force := 400
var gravity := 600
var jumpCount := 0
var alienPos := Vector2.ZERO


var planets: Array[Node2D] = []
var current_index = 0
#var max_level = get_node("../Stats").highest_level
var can_walk = true

var moves = 0
var count = 0
var count2 = 0
var count3 = 0
var count4 = 0
var level: int
func _ready() -> void:
	#level = GameState.highest_level
	pass

func _move_right() -> void:
	if level > moves:
		var direction := Vector2.ZERO
		direction.x += 1
		
	
	
	moves += 1

func _physics_process(delta):
	var speed = 150#get_node("../Stats").speed
	#var health = 200#get_node("../Stats").health
	#alienPos = $AlienPlayer.global_position
	count3+=1
	count +=1
	count2 += 1
	count4 +=1
	# --- Movement Input ---
	var direction := Vector2.ZERO
	if Input.is_action_pressed("Left"):
		direction.x -= 1
		sprite.flip_h = true

	if Input.is_action_pressed("right"):
		
		direction.x += 1
		sprite.flip_h = false

	velocity.x = direction.x * speed

	if jumpCount == 1 and Input.is_action_just_pressed("jump") and not is_on_floor():
		velocity.y = -jump_force
		jumpCount = 0

	
	

		#if direction.x != 0:
		#	$AnimationPlayer.play("Run")
		#else:
		#	$AnimationPlayer.play("Idle")

	else:
		
		if direction.x != 0:
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("Idle")
			velocity.y = 0

		
		

		
		if not is_on_floor():
			velocity.y += gravity * delta
	

	# --- Move ---
	move_and_slide()
var entered_m = false

func _on_area_2d_body_entered(body: PhysicsBody2D) -> void:
	
	entered_m = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	entered_m = false
	
	
func _process(delta):
	if entered_m == true:
		var level = GameState.get_level()
		
		if Input.is_action_just_pressed("ui_select"):
			if level == 1:
				get_tree().change_scene_to_file("res://map.tscn")
			elif level == 2:
				get_tree().change_scene_to_file("res://venus.tscn")
			elif level == 3:
				get_tree().change_scene_to_file("res://earth.tscn")
			elif level == 4:
				get_tree().change_scene_to_file("res://mars.tscn")
			elif level == 5:
				get_tree().change_scene_to_file("res://jupiter.tscn")
			elif level == 6:
				get_tree().change_scene_to_file("res://saturn.tscn")
			elif level == 7:
				get_tree().change_scene_to_file("res://uranus.tscn")
			elif level == 8:
				get_tree().change_scene_to_file("res://neptune.tscn")
			else:
				get_tree().change_scene_to_file("res://pluto.tscn")
			
