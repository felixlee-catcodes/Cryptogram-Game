extends Node

var cell_in_focus : LetterCell = null
var ordered_cells : Array = [LetterCell]
var prev_cell_in_focus : LetterCell = null


func _ready():
	EventHub.keys.keyboard_input.connect(_register_key)
	EventHub.cells.cell_focused.connect(_update_focused_cell)
	EventHub.cells.exit_focus.connect(_revert_focused_cells)


func register_cell(cell: LetterCell):
	ordered_cells.append(cell)


func get_next_empty(cell: LetterCell) -> LetterCell:
	var idx = ordered_cells.find(cell)
	if idx == -1:
		return null
	for i in range(idx + 1, ordered_cells.size()):
		var candidate : LetterCell = ordered_cells[i]
		if candidate.encoded_letter == cell.encoded_letter:
			continue
		if candidate.has_text:
			continue
		return candidate
	return null


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
		EventHub.inputs.text_input.emit(cell_in_focus, key_text)
		line_edit.text = ""
		cell_in_focus.decoded_letter_input.grab_focus()
		update_sister_cells(cell_in_focus, "")
		
	else:
		line_edit.text = key_text
		EventHub.inputs.text_input.emit(cell_in_focus, key_text)
		update_sister_cells(cell_in_focus, key_text)
		cell_in_focus.move_focus_to_next()


func update_sister_cells(cell: LetterCell, key: String) -> void:
	var group = cell.get_groups()[0]
	get_tree().call_group(group, "_update_text", key)


func highlight_sister_cells(group):
	Log.pr("focus entered on group: ", group)
	get_tree().call_group(group, "highlight_sister_cell")


#func revert_sister_cells(cell):
	#var focus_group = cell_in_focus.get_groups()[0]
	#get_tree().call_group(focus_group, "revert_unfocused_cells")
#

func _update_focused_cell(cell: LetterCell):
	cell_in_focus = cell
	prev_cell_in_focus = cell
	var group = cell_in_focus.get_groups()[0]
	Log.pr("previous cell group: ", prev_cell_in_focus.get_groups()[0])
	
	highlight_sister_cells(group)


func _revert_focused_cells(_cell):
	get_tree().call_group(cell_in_focus.get_groups()[0], "revert_unfocused_cells")


	
	
