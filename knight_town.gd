extends CharacterBody2D


const SPEED := 180.0
const JUMP_VELOCITY = -400.0

@onready var sprite: AnimatedSprite2D = $KnightSprite


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("Left", "right")
	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0.0
	else:
		velocity.x = 0.0

	_update_animation(direction)

	move_and_slide()

func _update_animation(direction: float) -> void:
	var desired_animation := "Idle"

	if not is_on_floor():
		if velocity.y < 0.0:
			desired_animation = "jump_start"
		else:
			desired_animation = "jump_end"
	elif direction != 0.0:
		desired_animation = "Run"

	if sprite.animation != desired_animation:
		sprite.play(desired_animation)
