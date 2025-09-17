extends ScrollContainer
# QUOTE SCENE
@onready var word_unit_scene = preload("res://scenes/WordUnit/WordUnit.tscn")
@export var word_array : Array
@onready var quote_container = $FlowContainer

func compile_text():
	
	if word_array.size() == 0:
		return
	for word in word_array:
		var word_unit = word_unit_scene.instantiate()
		quote_container.add_child(word_unit)
		word_unit.generate_word(word)
		word_unit.add_to_group("word_units")
