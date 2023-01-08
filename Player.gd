extends Area2D

signal hit
signal harvested

export var speed = 100
export var dash_speed = 500
export var max_dash_range = 100
export var dashing_slop_time = 0.1
var projectiles = 0
var dead = false
var dashing = false
var dash_target: Vector2

func _ready():
	if filename != ProjectSettings.get_setting('application/run/main_scene'):
		start(position)


func _dash(dt):
	$AnimatedSprite.animation = "dashing"
	var delta = dash_target - position
	var to_travel = dash_speed * dt
	if to_travel >= delta.length():
		position = dash_target
		yield(get_tree().create_timer(dashing_slop_time), "timeout")
		dashing = false
	else:
		position = position + delta.normalized() * to_travel


func _walk(dt):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.animation = "walk"
	else:
		$AnimatedSprite.animation = "default"

	if velocity.x != 0:
		$AnimatedSprite.flip_h = velocity.x < 0

	position += velocity * dt
	

func _start_dash(target):
	var delta_p = target - position
	if delta_p.length() > max_dash_range:
		target = position + delta_p.normalized() * max_dash_range
	
	dashing = true
	dash_target = target
	
	$DashSound.play()
	$DashTimer.start()
	
	
func _input(event):
	if event.is_action("dash") and event.is_pressed() and not dead and UpgradeState.dict["can_dash"]:
		if $DashTimer.time_left == 0:
			_start_dash(get_viewport().get_mouse_position())
		else:
			$WopsSound.play()


func _process(dt):
	if not dead:
		if dashing:
			_dash(dt)
		else:
			_walk(dt)

	if dead:
		$AnimatedSprite.z_index = -1
	else:
		$AnimatedSprite.z_index = 0
		

func shoot():
	$ShootSound.play()
	projectiles -= 1


func start(pos):
	dead = false
	$AnimatedSprite.pause_mode = Node.PAUSE_MODE_INHERIT
	$AnimatedSprite.play()
	$AnimatedSprite.animation = "default"
	position = pos
	show()
	$CollisionShape2D.disabled = false
	

func dash_cooldown_progress():
	return 1.0 - $DashTimer.time_left / $DashTimer.wait_time
	

func bomb_cooldown_progress():
	return 1.0 - $BombTimer.time_left / $BombTimer.wait_time
	
	
func start_bomb_timer():
	$BombTimer.start()


func kill():
	dead = true
	$AnimatedSprite.pause_mode = Node.PAUSE_MODE_PROCESS
	$AnimatedSprite.play("death")
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true)


func _on_Player_area_entered(area):
	if area.is_in_group("mobs"):
		if not dashing:
			kill()
		else:
			area.kill(self)
	elif area.is_in_group("harvestables"):
		if area.done:
			$HarvestSound.play()
			emit_signal("harvested", area)
			area.queue_free()
			
