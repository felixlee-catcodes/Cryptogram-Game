extends Node 

var keys = KeyboardEvents.new()

class KeyboardEvents:
	signal keyboard_input(key)
