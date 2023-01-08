extends Area2D

signal killed

export(PackedScene) var explosion_scene

export var speed = 100
export var attack_cooldown = 1
var player
var dead = false
var health = 10
var growing = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.playing = true
	$AnimatedSprite.animation = "grow"
	growing = true
	$GrowSound.play()
	yield($AnimatedSprite, "animation_finished")
	growing = false
	$AnimatedSprite.animation = "run"
	

func _process(delta):
	if dead or player.dead or growing:
		return
	
	var target = player
	var dp = (target.position - position).normalized()
	var velocity = dp * speed
	
	$AnimatedSprite.flip_h = velocity.x < 0
	position += velocity * delta
	
	$TextureProgress.value = health


func _on_game_over():
	$AnimatedSprite.play("dance")
	

func damage(other):
	health -= 1
	if health == 0:
		kill(other)
	

func kill(other):
	$CollisionPolygon2D.set_deferred("disabled", true)
	dead = true
	
	$AnimatedSprite.animation = "death"
	emit_signal("killed", self, other)
	
	yield($AnimatedSprite, "animation_finished")
	
	var explosion = explosion_scene.instance()
	explosion.position = position
	get_tree().get_root().add_child(explosion)
	queue_free()


func _on_BigMob_area_entered(area):
	if area.is_in_group("projectiles") or area.is_in_group("explosions"):
		damage(area)
		area.queue_free()
		$DamagedSound.play()

