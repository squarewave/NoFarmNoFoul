extends Node


var toggle_pause: FuncRef
var paused = false

func _ready():
	$Control.hide()

func _input(event):
	if event.is_action_pressed("pause"):
		if paused:
			$Control.hide()
		else:
			$Control.show()
		paused = not paused

		toggle_pause.call_func()

