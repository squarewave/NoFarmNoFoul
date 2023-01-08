extends Node

signal upgrade_changed(name, value)

const default_dict = {
	'first_upgrade': true,
	'can_dash': false,
	'can_multishot': false,
	'can_bomb': false,
	'extra_seed': 0,
	'seed_regen': 0,
	'tougher_plants': 0,
}

var dict


func _ready():
	reset()


func reset():
	dict = {}
	for k in default_dict:
		dict[k] = default_dict[k]


func change_value(name, value):
	dict[name] = value
	emit_signal("upgrade_changed", name, value)
	
func increment_value(name):
	change_value(name, dict[name] + 1)
