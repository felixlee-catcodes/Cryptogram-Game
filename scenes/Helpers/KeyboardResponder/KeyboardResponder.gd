extends Node

func handle_notification(target: Control, what):
	match what:
		NOTIFICATION_VIRTUAL_KEYBOARD_SHOW:
			var height = DisplayServer.virtual_keyboard_get_height()
	
		NOTIFICATION_VIRTUAL_KEYBOARD_HIDE:
			pass
