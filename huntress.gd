extends CharacterBody2D
@export var knight: CharacterBody2D

var arrows := load("res://arrow.tscn")
var monsterPos := global_position.x
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var floor = true


func _physics_process(delta: float) -> void:
	var alien = get_node("../Knight")
	var distance = global_position.distance_to(alien.global_position)
	monsterPos = global_position.x

	if distance <= 400:

		if round(alien.alienPos.x) >= round(monsterPos):
			#direction.x = 1
			$AnimatedSprite2D.flip_h = false
		else:
			#direction.x = -1
			$AnimatedSprite2D.flip_h = true
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("idle")


func _on_timer_timeout() -> void:
	$AnimatedSprite2D.play("attack")
func _ready() -> void:
	#knight = get_tree().get_first_node_in_group("player")
	if (is_on_floor()):
		floor = false
		#print("aaaaaa")	
func _process(delta: float) -> void:
	if floor and not is_on_floor():
			velocity.y = 500
			move_and_slide()
	else:
		velocity.y = 0
		floor = false
		#print("done")	
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "attack":
		var arrow = arrows.instantiate()
		arrow.global_position = $arrow_spawn.global_position
		get_tree().current_scene.add_child(arrow)
		var arrow_list = arrows.instantiate()
		arrow_list.global_position = $arrow_spawn.global_position

		
		get_tree().current_scene.add_child(arrow)
		if $AnimatedSprite2D.flip_h:
			arrow.direction = -1
			arrow.get_node("AnimatedSprite2D").flip_h = true
		else:
			arrow.direction = 1
			arrow.get_node("AnimatedSprite2D").flip_h = false
			
