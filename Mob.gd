extends Area2D

signal killed


export var speed = 50
export var attack_cooldown = 1
var player
var plants: Array
var dead = false
var attacking = false
var attack_target
var attack_time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.playing = true
	$AnimatedSprite.animation = "run"
	

func do_attack(dt):
	if not is_instance_valid(attack_target) or dead or player.dead or attack_target.dead:
		attacking = false
		attack_time = 0
		return
	
	attack_time += dt
	if attack_time > attack_cooldown:
		attack_time = 0
		$AttackSound.play()
		$AnimatedSprite.play("attack")
		attack_target.damage(self)
		yield($AnimatedSprite, "animation_finished")
		if $AnimatedSprite.animation == "attack":
			$AnimatedSprite.play("idle")

func _process(delta):
	if dead or player.dead:
		return
		
	if attacking:
		do_attack(delta)
		return
	
	var target = player
	var min_distance = (player.position - position).length_squared()
	for plant in plants:
		var distance = (plant.position - position).length_squared()
		if distance < min_distance:
			target = plant
			min_distance = distance
	
	var dp = (target.position - position).normalized()
	var velocity = dp * speed
	
	$AnimatedSprite.flip_h = velocity.x < 0
	position += velocity * delta
	

func kill(other):
	$CollisionShape2D.set_deferred("disabled", true)
	dead = true
	$DeathSound.play()
	
	$AnimatedSprite.animation = "death"
	emit_signal("killed", self, other)
	
	yield($AnimatedSprite, "animation_finished")
	yield(get_tree().create_timer(30), "timeout")

	queue_free()


func _on_game_over():
	if not dead:
		$AnimatedSprite.play("dance")


func _on_Mob_area_entered(area):
	if area.is_in_group("harvestables"):
		if dead or player.dead or attacking:
			return
		$AnimatedSprite.play("idle")
		attacking = true
		attack_target = area
	elif area.is_in_group("projectiles") or area.is_in_group("explosions") and not dead:
		kill(area)
