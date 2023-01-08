extends Node

signal game_over

export(PackedScene) var mob_scene
export(PackedScene) var big_mob_scene
export(PackedScene) var projectile_scene
export(PackedScene) var plant_scene
export(PackedScene) var bomb_scene
var score
var game_over = false
var shown_harvest_message = false
var shown_protect_message = false
var new_plants = 0
var pumpkin_souls = 0
var plants = []

const max_pumpkin_souls = 3


func max_projectiles():
	return 3 + UpgradeState.dict["extra_seed"]
	

func projectile_timer_wait_time():
	var result = 2.0
	for _i in range(0, UpgradeState.dict["seed_regen"]):
		result *= 0.75
	return result
	

func _ready():
	randomize()
	$HUD.player = $Player
	$PauseManager.toggle_pause = funcref(self, "toggle_pause")
	_process_settings()
	GameSettings.connect("setting_changed", self, "_on_GameSettings_setting_changed")
	UpgradeState.connect("upgrade_changed", self, "_on_GameSettings_upgrade_changed")
	new_game()


func _input(event):
	if event.is_action("shoot") and event.is_pressed() and not $Player.dead:
		if $Player.projectiles > 0:
			var base_direction = get_viewport().get_mouse_position() - $Player.position
			var angles
			if UpgradeState.dict["can_multishot"]:
				angles = [-PI / 12, 0, PI / 12]
			else:
				angles = [0]
			
			for angle in angles:
				var direction = base_direction.rotated(angle)
				var projectile = projectile_scene.instance()
				add_child(projectile)
				projectile.throw($Player.position, direction)
			
			$Player.shoot()
			$HUD.update_projectiles($Player.projectiles)
			if $ProjectileTimer.is_stopped():
				$ProjectileTimer.start()
		else:
			$Wops.play()
	if event.is_action("bomb") and event.is_pressed() and not $Player.dead and UpgradeState.dict["can_bomb"] and $Player.bomb_cooldown_progress() >= 1:
		var target = get_viewport().get_mouse_position()
		var bomb = bomb_scene.instance()
		add_child(bomb)
		bomb.throw($Player.position, target)
		$Player.start_bomb_timer()


func toggle_pause():
	if get_tree().paused:
		get_tree().paused = false
	else:
		get_tree().paused = true


func do_game_over():
	$MobTimer.stop()
	$HUD.show_game_over()
	game_over = true
	emit_signal("game_over")
	

func new_game():
	UpgradeState.reset()
	game_over = false
	score = 0
	pumpkin_souls = 0
	plants = []
	$Player.start($StartPosition.position)
	$Player.projectiles = max_projectiles()
	$ProjectileTimer.wait_time = projectile_timer_wait_time()
	$StartTimer.start()
	$NewPlantTimer.start()
	$MobTimer.wait_time = 10
	$HUD.reset()
	$HUD.update_score(score)
	$HUD.update_projectiles($Player.projectiles)
	$HUD.update_pumpkin_souls(pumpkin_souls)
	$HUD.show_explainers()
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("projectiles", "queue_free")
	get_tree().call_group("harvestables", "queue_free")
	_hitstop(1.0)


func _create_mob():
	var mob = mob_scene.instance()
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.offset = randi()
	
	var direction = mob_spawn_location.rotation + PI / 2
	mob.position = mob_spawn_location.position
	
	mob.player = $Player
	mob.plants = plants
	
	mob.connect("killed", self, "_on_Mob_killed")
	self.connect("game_over", mob, "_on_game_over")
	
	add_child(mob)


func _on_MobTimer_timeout():
	_create_mob()
	_create_mob()
	
	
func _process_settings():
	$Music.playing = GameSettings.dict['music']


func _on_GameSettings_setting_changed(name, value):
	if name == 'music':
		$Music.playing = value


func _on_GameSettings_upgrade_changed(name, value):
	if name == 'extra_seed':
		if $ProjectileTimer.is_stopped():
			$ProjectileTimer.start()
	if name == 'seed_regen':
		$ProjectileTimer.wait_time = projectile_timer_wait_time()
		
	

func _hitstop(time):
	if not get_tree().paused:
		get_tree().paused = true
		yield(get_tree().create_timer(0.083), 'timeout')
		get_tree().paused = false
		

func _new_plant(p):
	var plant = plant_scene.instance()
	add_child(plant)
	plant.connect("pumpkin_done", self, "_on_Plant_pumpkin_done")
	plant.connect("plant_death", self, "_on_Plant_plant_death")
	plant.position = p
	plants.append(plant)
	
	if not shown_protect_message:
		shown_protect_message = true
		plant.show_protect()
	

func _on_Plant_plant_death(plant, killer):
	for i in range(0, len(plants)):
		if plants[i] == plant:
			plants.remove(i)
			break
	
	var p = killer.position
	killer.queue_free()
	var mob = big_mob_scene.instance()
	mob.position = p
	mob.player = $Player
	self.connect("game_over", mob, "_on_game_over")
	add_child(mob)
	

func _on_Mob_killed(mob, other):
	if game_over:
		return
		
	score += 1
	$HUD.update_score(score)
	
	if new_plants > 0 and other.is_in_group("projectiles"):
		new_plants -= 1
		call_deferred("_new_plant", mob.position)
		
		_hitstop(0.166)
		other.queue_free()
	else:
		_hitstop(0.083)
	
	
func _on_StartTimer_timeout():
	$MobTimer.start()
	$MobTimerTimer.start()
	$HUD.hide_explainers()
	_create_mob()
	_create_mob()


func _on_MobTimerTimer_timeout():
	$MobTimer.wait_time *= 0.95


func _on_ProjectileTimer_timeout():
	$Player.projectiles += 1
	$HUD.update_projectiles($Player.projectiles)
	if $Player.projectiles >= max_projectiles():
		$ProjectileTimer.stop()
	_hitstop(0.083)
	
	
func _on_Plant_pumpkin_done(plant):
	if not shown_harvest_message:
		shown_harvest_message = true
		plant.show_harvest()


func _on_Player_harvested(plant):
	for i in range(0, len(plants)):
		if plants[i] == plant:
			plants.remove(i)
			break

	score += 10
	plant.queue_free()
	pumpkin_souls += 1
	$HUD.update_pumpkin_souls(pumpkin_souls)
	$HUD.update_score(score)
	if pumpkin_souls == max_pumpkin_souls:
		_do_upgrade()


func _on_NewPlantTimer_timeout():
	new_plants += 1


func _do_upgrade():
	$UpgradeMenu.do_upgrade()
	pumpkin_souls = 0
	$HUD.update_pumpkin_souls(pumpkin_souls)


func _on_Player_hit():
	do_game_over()
