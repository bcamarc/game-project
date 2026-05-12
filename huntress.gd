extends CharacterBody2D
@export var knight: CharacterBody2D

var arrows: PackedScene = preload("res://arrow.tscn")
var monsterPos := 0.0
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var floor := true
var health := 50
var damaged := false
var dead := false
signal death(x, y)

func _ready() -> void:
	add_to_group("huntress")
	monsterPos = global_position.x

	
	if $AnimatedSprite2D.sprite_frames.has_animation("death"):
		$AnimatedSprite2D.sprite_frames.set_animation_loop("death", false)

	if is_on_floor():
		floor = false

func _physics_process(delta: float) -> void:
	var alien = knight if knight != null else get_node("../Knight")
	var distance = global_position.distance_to(alien.global_position)
	monsterPos = global_position.x
	$ProgressBar.value = max(health, 0)

	
	if dead:
		return

	
	if health <= 0:
		_die()
		return

	if distance <= 400:
		if round(alien.alienPos.x) >= round(monsterPos) + 50:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true

	if not is_on_floor():
		velocity += get_gravity() * delta

	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("idle")

func _on_timer_timeout() -> void:
	if dead:
		return
	$AnimatedSprite2D.play("attack")

func _process(delta: float) -> void:
	if dead:
		return

	if floor and not is_on_floor():
		velocity.y = 500
		move_and_slide()
	else:
		velocity.y = 0
		floor = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "attack" and not dead:
		var arrow = arrows.instantiate()
		arrow.global_position = $arrow_spawn.global_position
		get_tree().current_scene.add_child(arrow)

		if $AnimatedSprite2D.flip_h:
			arrow.direction = -1
			arrow.get_node("AnimatedSprite2D").flip_h = true
		else:
			arrow.direction = 1
			arrow.get_node("AnimatedSprite2D").flip_h = false

	elif $AnimatedSprite2D.animation == "death":
		get_node("../Stats").add_exp(10)
		death.emit(global_position.x, global_position.y)
		queue_free()

func take_damage(a: int) -> void:
	if dead:
		return

	damaged = true
	health -= a

	if health <= 0:
		_die()

func _die() -> void:
	if dead:
		return

	dead = true
	health = 0
	velocity = Vector2.ZERO

	if has_node("Timer"):
		$Timer.stop()

	$AnimatedSprite2D.play("death")
