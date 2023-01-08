extends Area2D

var speed = 400
var velocity: Vector2

func _process(dt):
	position = position + velocity * dt


func throw(start: Vector2, direction: Vector2):

	position = start
	var delta = direction.normalized();
	velocity = delta * speed
	
	$AnimatedSprite.play("default")
	if abs(delta.x) < 0.2:
		$AnimatedSprite.play("vertical")
	if abs(delta.y) < 0.2:
		$AnimatedSprite.play("horizontal")
	
	$AnimatedSprite.flip_h = sign(velocity.x) == sign(velocity.y)
