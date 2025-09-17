extends Control
class_name LetterCell

var is_focused : bool = false
var has_text : bool = false

@export var encoded_letter : String

@onready var decoded_letter_input = $VBoxContainer/DecodedLetterInput
@onready var encrypted_letter = $VBoxContainer/EncryptedLetter


func _ready():
	InputManager.register_cell(self)
	EventHub.inputs.text_input.connect(_on_text_input)
	add_to_group(encoded_letter)
	decoded_letter_input.focus_mode = Control.FOCUS_CLICK
	decoded_letter_input.max_length = 1
	encrypted_letter.append_text(encoded_letter)
	add_to_group("letter_cells")
	set_focus_styling()


func set_focus_styling():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 0.5, 0.5)
	decoded_letter_input.add_theme_stylebox_override("focus", style)


func _on_text_input(cell: LetterCell, key):
	if cell == self:
		if key == "Clear":
			has_text = false
		else: 
			has_text = true


func _on_decoded_letter_input_focus_entered():
	is_focused = true
	EventHub.cells.cell_focused.emit(self)


func _on_decoded_letter_input_focus_exited():
	is_focused = false
	var parent = get_node("../LetterCell")
	EventHub.cells.exit_focus.emit(parent)


func move_focus_to_next():
	var next_cell : LetterCell = InputManager.get_next_empty(self)
	if next_cell:
		next_cell.decoded_letter_input.grab_focus()


func move_focus_to_prev():
	var prev_cell : LetterCell = InputManager.get_prev(self)
	if prev_cell:
		prev_cell.decoded_letter_input.grab_focus()


func _update_text(text: String) -> void:
	self.decoded_letter_input.text = text
	self.has_text = true


func highlight_sister_cell():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1.0 ,0.5, 0.5, 0.5)
	self.decoded_letter_input.add_theme_stylebox_override("normal", style)


func revert_unfocused_cells():
	self.decoded_letter_input.remove_theme_stylebox_override("normal")
