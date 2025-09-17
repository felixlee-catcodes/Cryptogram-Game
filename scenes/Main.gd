extends Node
#@onready var word_unit = $EncryptedMessageDisplay/WordUnit
@onready var quote_scene = %QuoteScene
@onready var word_unit = preload("res://scenes/WordUnit/WordUnit.tscn")
@onready var game_manager = $GameManager

var test_sentence : String = "This is just a test."

func _ready():
	var puzzle = game_manager.get_new_puzzle()
	var cipher_text = split_text(puzzle.cipherText)
	quote_scene.word_array = cipher_text
	quote_scene.compile_text()

func split_text(quote: String) -> Array:
		
	return quote.split(" ")
