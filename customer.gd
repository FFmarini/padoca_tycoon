extends CharacterBody2D

@export var speed := 120.0
var target_position: Vector2

func set_target(pos: Vector2) -> void:
	target_position = pos

func _physics_process(_delta):
	var direction = target_position - global_position

	if direction.length() > 5:
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
