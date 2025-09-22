extends ScrollContainer
# QUOTE SCENE
@onready var word_unit_scene = preload("res://scenes/WordUnit/WordUnit.tscn")
@export var word_array : Array
@onready var quote_container = $VBoxContainer/MarginContainer/FlowContainer
@onready var credit_label = $VBoxContainer/CreditLabel
@export var author : String
@export var quote : String
func compile_quote():
	credit_label.text = author
	if word_array.size() == 0:
		return
	for word in word_array:
		var word_unit = word_unit_scene.instantiate()
		quote_container.add_child(word_unit)
		word_unit.generate_word(word)
		word_unit.add_to_group("word_units")

#func _make_author_label():
	#var label = Label.new()
	#label.text = author
	#quote_container.add_child(label)
	#label.add_theme_font_size_override("font_size", 48)
	#label.add_theme_color_override("color", Color.BLACK)
