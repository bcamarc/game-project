extends CharacterBody2D


var jump_force := 800
var gravity := 600
var jumpCount := 0
func _ready() -> void:
	print(name)
func _physics_process(delta):
	var speed = get_node("../Stats").speed
	var direction := Vector2.ZERO
	#i love music
	if Input.is_action_pressed("Left"):
		direction.x -= 1
		$Knight.flip_h = true
	if Input.is_action_pressed("right"):
		direction.x += 1
		$Knight.flip_h = false
	velocity.x = direction.x * speed
	if (jumpCount == 1 and Input.is_action_just_pressed("jump") and not is_on_floor()):
		velocity.y = -jump_force
		jumpCount = 0
	if not is_on_floor():
		velocity.y += gravity * delta
		$AnimationPlayer.play("RESET")
	else:
		if (direction.x !=0):
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("knightAnimation")
			velocity.y = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_force
			jumpCount = 1;

	move_and_slide()
