extends CanvasLayer


const all_options = [
	"multishot",
	"bomb",
	"dash",
	"extra seed",
	"seed regen",
	"tougher plants"
]


export var multishot_icon: Texture
export var bomb_icon: Texture
export var dash_icon: Texture
export var extra_seed_icon: Texture
export var seed_regen_icon: Texture
export var tougher_plants_icon: Texture


var current_options

func option_valid(name):
	if name == "multishot" and UpgradeState.dict["can_multishot"]:
		return false
		
	if name == "bomb" and UpgradeState.dict["can_bomb"]:
		return false
		
	if name == "dash" and UpgradeState.dict["can_dash"]:
		return false
		
	return true


func get_icon(name):
	# well, this is kind of a klugey way to do this. Unfortunately I don't know Godot any better
	if name == "multishot": return multishot_icon
	if name == "bomb": return bomb_icon
	if name == "dash": return dash_icon
	if name == "extra seed": return extra_seed_icon
	if name == "seed regen": return seed_regen_icon
	if name == "tougher plants": return tougher_plants_icon
	
	assert(false)


func do_upgrade():
	get_tree().paused = true
	
	var valid_options = []
	if UpgradeState.dict['first_upgrade']:
		UpgradeState.change_value("first_upgrade", false)
		valid_options.append('multishot')
		valid_options.append('bomb')
		valid_options.append('dash')
	else:
		for option in all_options:
			if option_valid(option):
				valid_options.append(option)
				
		valid_options.shuffle()
	current_options = valid_options
	
	$Option1.icon = get_icon(valid_options[0])
	$Option2.icon = get_icon(valid_options[1])
	$Option3.icon = get_icon(valid_options[2])
	
	self.show()


func _pick_option(opt):
	var name = current_options[opt]
	if name == "multishot":
		UpgradeState.change_value("can_multishot", true)
	if name == "bomb":
		UpgradeState.change_value("can_bomb", true)
	if name == "dash":
		UpgradeState.change_value("can_dash", true)
	if name == "extra seed":
		UpgradeState.increment_value("extra_seed")
	if name == "seed regen":
		UpgradeState.increment_value("seed_regen")
	if name == "tougher plants":
		UpgradeState.increment_value("tougher_plants")
	
	get_tree().paused = false
	self.hide()


func _on_Option1_pressed():
	_pick_option(0)


func _on_Option2_pressed():
	_pick_option(1)


func _on_Option3_pressed():
	_pick_option(2)
