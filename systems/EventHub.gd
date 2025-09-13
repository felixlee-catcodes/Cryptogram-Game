extends Node
class_name EventHub

var keys = KeyboardEvents.new()

class KeyboardEvents:
	signal keyboard_input(key)
