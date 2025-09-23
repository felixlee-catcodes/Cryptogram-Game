extends Node

var cell_in_focus : LetterCell = null
var ordered_cells : Array = [LetterCell]
var prev_cell_in_focus : LetterCell = null
var letter_to_groups : Dictionary = {}

func _ready():
	EventHub.keys.keyboard_input.connect(_register_key)
	EventHub.cells.cell_focused.connect(_update_focused_cell)
	EventHub.cells.exit_focus.connect(_revert_focused_cells)


func _input(event):
	if event is InputEventKey and event.pressed:
		var code = event.keycode
		if code >= KEY_A and code <= KEY_Z:
			var key = OS.get_keycode_string(code)
			EventHub.keys.keyboard_input.emit(key)


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
	Log.pr(letter_to_groups)
	if not cell_in_focus:
		return

	var line_edit = cell_in_focus.decoded_letter_input
	var prev_text = line_edit.text
	var group = cell_in_focus.get_groups()[0]
	
	# remove old mapping if text is changing:
	if prev_text != "" and letter_to_groups.has(prev_text):
		letter_to_groups[prev_text].erase(group)
		
		if letter_to_groups[prev_text].size() == 1:
			#only 1 group left, clear warning:
			var lone_group = letter_to_groups[prev_text][0]
			get_tree().call_group(lone_group, "undo_warn_duplicate")
		
		# no groups left, clear entry
		if letter_to_groups[prev_text].is_empty():
			letter_to_groups.erase(prev_text)
		
	if key_text == "Clear":
		EventHub.inputs.text_input.emit(cell_in_focus, key_text)
		line_edit.text = ""
		cell_in_focus.decoded_letter_input.grab_focus()
		update_sister_cells(cell_in_focus, "")
		return

	# add new mapping:
	line_edit.text = key_text
	if not letter_to_groups.has(key_text):
		letter_to_groups[key_text] = []
	letter_to_groups[key_text].append(group)

	# apply warning if duplicate:
	Log.pr(letter_to_groups[key_text].size())
	if letter_to_groups[key_text].size() > 1:
		Log.pr(letter_to_groups[key_text].size())
		for g in letter_to_groups[key_text]:
			get_tree().call_group(group, "warn_duplicated_letter")
	else: 
		get_tree().call_group(group, "undo_warn_duplicate")
		
	# propagate event
	EventHub.inputs.text_input.emit(cell_in_focus, key_text)
	update_sister_cells(cell_in_focus, key_text)
	line_edit.grab_focus()
	cell_in_focus.move_focus_to_next()


func update_sister_cells(cell: LetterCell, key: String) -> void:
	Log.pr("update_sister_cells called")
	var group = cell.get_groups()[0]
	get_tree().call_group(group, "_update_text", key)


func highlight_sister_cells(group):
	get_tree().call_group(group, "highlight_sister_cell")


func _update_focused_cell(cell: LetterCell):
	cell_in_focus = cell
	prev_cell_in_focus = cell
	
	cell_in_focus.decoded_letter_input.grab_focus()
	
	var group = cell_in_focus.get_groups()[0]	
	highlight_sister_cells(group)


func _revert_focused_cells(_cell):
	get_tree().call_group(cell_in_focus.get_groups()[0], "revert_unfocused_cells")
