extends Control
class_name LetterCell

var is_focused : bool = false
@export var encoded_letter : String

@onready var decoded_letter_input = $VBoxContainer/DecodedLetterInput
@onready var encrypted_letter = $VBoxContainer/EncryptedLetter


func _ready():
	decoded_letter_input.focus_mode = Control.FOCUS_CLICK
	decoded_letter_input.max_length = 1
	encrypted_letter.append_text(encoded_letter)
	add_to_group("letter_cells")
	set_focus_styling()
	

func set_focus_styling():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 0.5, 0.5)
	decoded_letter_input.add_theme_stylebox_override("focus", style)


func _on_decoded_letter_input_focus_entered():
	is_focused = true
	EventHub.cells.cell_focused.emit(self)


func _on_decoded_letter_input_focus_exited():
	is_focused = false


func move_focus_to_next():
	var parent = get_parent()
	if not parent:
		return

	var siblings = parent.get_children()
	var index = siblings.find(self)

	for i in range(index + 1, siblings.size()):
		var next_cell = siblings[index + 1]
		Log.pr("index: ", i)
		Log.pr("next cell? ", next_cell)
		if index + 1 < siblings.size():
			if next_cell.is_in_group("punctuation_cells"):
				continue
			if next_cell.is_in_group("letter_cells"):
				next_cell.decoded_letter_input.grab_focus()
				return
