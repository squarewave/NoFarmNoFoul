extends CanvasLayer

signal start_game

var num_projectiles = -1
var num_pumpkin_souls = -1
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartButton.hide()
	$Message.hide()
	_process_settings(get_node("/root/GameSettings"))
	UpgradeState.connect("upgrade_changed", self, "_on_UpgradeState_upgrade_changed")
	

func _process(_dt):
	_update_dash_info()
	_update_bomb_info()


func _update_dash_info():
	if UpgradeState.dict["can_dash"]:
		$DashInfo.show()
	else:
		$DashInfo.hide()
		
	$DashInfo/TextureProgress.value = player.dash_cooldown_progress()


func _update_bomb_info():
	if UpgradeState.dict["can_bomb"]:
		$BombInfo.show()
	else:
		$BombInfo.hide()
		
	$BombInfo/TextureProgress.value = player.bomb_cooldown_progress()


func show_message(text, time):
	$Message.text = text
	$Message.show()
	$MessageTimer.wait_time = time
	$MessageTimer.start()
	

func show_game_over():
	show_message("GAME OVER", 2)
	yield($MessageTimer, "timeout")
	show_message("game by squarewave\ngodotengine.org/license", 2)
	yield($MessageTimer, "timeout")
	$StartButton.show()


func update_score(score):
	$ScoreLabel.text = str(score)
	
	
func hide_explainers():
	$Explainers.hide()
	
	
func show_explainers():
	$Explainers.show()
	
	
func reset():
	$Projectile4.hide()
	$Projectile5.hide()
	

func update_projectiles(projectiles):
	var all_projectiles = [$Projectile1, $Projectile2, $Projectile3, $Projectile4, $Projectile5]
	for i in range(0, all_projectiles.size()):
		if i < projectiles:
			all_projectiles[i].modulate = Color.white
		else:
			all_projectiles[i].modulate = Color(0, 0, 0, 0.25)
	
	if num_projectiles != -1:
		for i in range(num_projectiles, all_projectiles.size()):
			all_projectiles[i].frame = 0
			all_projectiles[i].play()
	
	num_projectiles = projectiles
	

func update_pumpkin_souls(pumpkin_souls):
	var all_pumpkin_souls = [$PumpkinSoul1, $PumpkinSoul2, $PumpkinSoul3]
	for i in range(0, all_pumpkin_souls.size()):
		if i < pumpkin_souls:
			all_pumpkin_souls[i].modulate = Color.white
		else:
			all_pumpkin_souls[i].modulate = Color(0, 0, 0, 0.25)
	
	if num_pumpkin_souls != -1:
		for i in range(num_pumpkin_souls, all_pumpkin_souls.size()):
			all_pumpkin_souls[i].frame = 0
			all_pumpkin_souls[i].play()
	
	num_pumpkin_souls = pumpkin_souls
	
	
func _process_settings(settings):
	$MusicToggle.pressed = settings.dict['music']


func _on_MessageTimer_timeout():
	$Message.hide()


func _on_StartButton_pressed():
	$StartButton.hide()
	$Explainers.show()
	emit_signal("start_game")


func _on_MusicToggle_toggled(button_pressed):
	get_node("/root/GameSettings").change_setting('music', button_pressed)
	
	
func _on_UpgradeState_upgrade_changed(name, value):
	if name == "can_dash":
		$DashExplainer.show()
		yield(get_tree().create_timer(2.0), "timeout")
		$DashExplainer.hide()
	if name == "can_bomb":
		$BombExplainer.show()
		yield(get_tree().create_timer(2.0), "timeout")
		$BombExplainer.hide()
	if name == "extra_seed":
		if value == 1:
			$Projectile4.show()
		if value == 2:
			$Projectile5.show()
