extends Node2D

export(PackedScene) var explosion_scene

const max_range = 200
const throw_time = 1
const gravity = 400
const start_vertical_velocity = -throw_time * gravity / 2
var start: Vector2
var end: Vector2
var progress = 0

func _process(dt):
	progress += dt
	
	if progress > throw_time:
		progress = throw_time
	
	var vertical_offset = Vector2(0, 0)
	vertical_offset.y = progress * start_vertical_velocity + progress * progress * gravity * 0.5
	
	position = start + (end - start) * progress + vertical_offset
	
	if progress == throw_time:
		var explosion = explosion_scene.instance()
		explosion.position = position
		get_tree().get_root().add_child(explosion)
		queue_free()
	


func throw(start: Vector2, target: Vector2):
	var delta_p = target - start
	if delta_p.length() > max_range:
		target = start + delta_p.normalized() * max_range
	
	self.start = start
	end = target
	position = start
