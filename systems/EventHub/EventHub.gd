extends Node 

@warning_ignore_start("unused_signal")

var keys = KeyboardEvents.new()
var cells = LetterCellEvents.new()
var inputs = InputEvents.new()
var ui_events = UserInterfaceEvents.new()
var game = GameEvents.new()

class LetterCellEvents:
	signal cell_focused(cell)
	signal exit_focus(cell)


class KeyboardEvents:
	signal keyboard_input(key)


class InputEvents:
	signal text_input(cell: LetterCell, key: String)
	signal input_changed(key: String)
	signal simulate_input(key: String)
	signal update_archive


class UserInterfaceEvents: 
	signal update_timer(time)
	signal transmit_tags(tags: Array)
	signal show_stats(show: bool)


class GameEvents:
	signal game_over(time, solved_puzzle)
	signal new_game
	signal reset_game
	signal get_hint
	signal check_game
