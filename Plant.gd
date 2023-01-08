extends Area2D

signal pumpkin_done
signal plant_death

const maturation_time = 15
const stages = [
	"mound",
	"stage1",
	"stage2",
	"stage3",
	"stage4",
	"final",
]


var elapsed = 0
var stage = 0
var health = 3
var done = false
var dead = false


func _ready():
	$AnimatedSprite.play(stages[0])
	$AnimatedSprite.frame = 0
	$PlantingSound.play()
	health += UpgradeState.dict["tougher_plants"]
	$Health.max_value = health


func _process(delta):
	elapsed += delta
	
	var progress = clamp(elapsed / maturation_time, 0, 1)
	var new_stage = floor((len(stages) - 1) * progress)
	
	if new_stage != stage:
		stage = new_stage
		$AnimatedSprite.play(stages[stage])
		
		if new_stage == len(stages) - 1:
			emit_signal("pumpkin_done", self)
			done = true
			

func damage(mob):
	$Health.show()
	health -= 1
	$Health.value = health
	if health == 0:
		dead = true
		$AnimatedSprite.pause_mode = Node.PAUSE_MODE_PROCESS
		emit_signal("plant_death", self, mob)
		queue_free()
			

func show_harvest():
	$ProtectMessage.hide()
	$HarvestMessage.show()


func show_protect():
	$ProtectMessage.show()
