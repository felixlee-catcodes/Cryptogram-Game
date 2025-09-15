extends HFlowContainer

@onready var word_unit_scene = preload("res://scenes/WordUnit/WordUnit.tscn")
@export var word_array : Array

func compile_quote():
	
	if word_array.size() == 0:
		return
	for word in word_array:
		var word_unit = word_unit_scene.instantiate()
		add_child(word_unit)
		word_unit.generate_word(word)
		word_unit.add_to_group("word_units")
