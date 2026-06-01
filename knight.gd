extends CharacterBody2D
@onready var sprite = $KnightSprite
var pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass 
	
func _physics_process(delta: float) -> void:
	sprite.play("menu")
	
