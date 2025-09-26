extends HBoxContainer

@onready var letter_cell_scene = preload("res://scenes/LetterCell/LetterCell.tscn")
@onready var punctuation_scene = preload("res://scenes/WordUnit/Punctuation.tscn")

@export var theme_font_color : Color

func _ready():
	ThemeManager.connect("theme_changed", Callable(self, "_on_theme_changed"))
	if ThemeManager.active_theme != null:
		_on_theme_changed(ThemeManager.active_theme)


func _on_theme_changed(theme: ColorTheme) -> void:
	theme_font_color = theme.font_color


func generate_word(_word) -> Node:
	var regex = RegEx.new()
	regex.compile(r"\p{P}")
	for letter in _word: 
		var result = regex.search(letter)

		if result:
			var punctuation = punctuation_scene.instantiate()
			var symbol : Label = punctuation.find_child("Symbol")
			punctuation.add_to_group("punctuation_cells")
			symbol.text = letter
			symbol.add_theme_color_override("font_color", theme_font_color)
			add_child(punctuation)
			continue
			
		var letter_cell = letter_cell_scene.instantiate()
		letter_cell.encoded_letter = letter
		add_child(letter_cell)
	return self
