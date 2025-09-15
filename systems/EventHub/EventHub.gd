extends Node 

@warning_ignore_start("unused_signal")

var keys = KeyboardEvents.new()
var cells = LetterCellEvents.new()


class LetterCellEvents:
	signal cell_focused(cell)


class KeyboardEvents:
	signal keyboard_input(key)
