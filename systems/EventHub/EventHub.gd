extends Node 

@warning_ignore_start("unused_signal")

var keys = KeyboardEvents.new()
var cells = LetterCellEvents.new()
var inputs = InputEvents.new()
var ui_events = UserInterfaceEvents.new()

class LetterCellEvents:
	signal cell_focused(cell)
	signal exit_focus(cell)


class KeyboardEvents:
	signal keyboard_input(key)


class InputEvents:
	signal text_input(cell: LetterCell, key: String)


class UserInterfaceEvents: 
	signal update_timer(time)
