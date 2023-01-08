extends Node

signal setting_changed(name, value)

var dict = {
	'music': true,
}


func change_setting(name, value):
	dict[name] = value
	emit_signal("setting_changed", name, value)
