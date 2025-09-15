extends Node

var cell_in_focus : LetterCell = null
var ordered_cells : Array = [LetterCell]


func _ready():
	EventHub.keys.keyboard_input.connect(_register_key)
	EventHub.cells.cell_focused.connect(_update_focused_cell)


func register_cell(cell: LetterCell):
	ordered_cells.append(cell)


func get_next(cell: LetterCell) -> LetterCell:
	var idx = ordered_cells.find(cell)
	if idx == -1:
		return null
	if idx + 1 < ordered_cells.size():
		return ordered_cells[idx + 1]
	return null


func get_prev(cell: LetterCell) -> LetterCell:
	var idx = ordered_cells.find(cell)
	if idx == -1:
		return null
	if idx - 1 >= 0:
		return ordered_cells[idx - 1]
	return null

func _register_key(key_text):
	if not cell_in_focus:
		return
	var line_edit = cell_in_focus.decoded_letter_input
	if key_text == "Clear":
		line_edit.text = ""
	else:
		line_edit.text = key_text
		cell_in_focus.move_focus_to_next()


func _update_focused_cell(cell):
	cell_in_focus = cell
