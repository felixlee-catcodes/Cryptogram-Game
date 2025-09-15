extends HBoxContainer

@onready var letter_cell_scene = preload("res://scenes/LetterCell/LetterCell.tscn")
@onready var punctuation_scene = preload("res://scenes/WordUnit/Punctuation.tscn")


func generate_word(_word) -> Node:
	var regex = RegEx.new()
	regex.compile(r"\p{P}")
	for letter in _word: 
		var result = regex.search(letter)

		if result:
			var punctuation = punctuation_scene.instantiate()
			var symbol = punctuation.find_child("Symbol")
			punctuation.add_to_group("punctuation_cells")
			symbol.text = letter
			add_child(punctuation)
			continue
			
		var letter_cell = letter_cell_scene.instantiate()
		letter_cell.encoded_letter = letter
		add_child(letter_cell)
	return self
