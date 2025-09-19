extends Node
# MAIN
@onready var word_unit = preload("res://scenes/WordUnit/WordUnit.tscn")
@onready var game_manager = $GameManager
@onready var quote_scene = %QuoteScene

func _ready():
	EventHub.game.new_game.connect(_on_new_game)
	setup_puzzle()
	game_manager.start_game()


func setup_puzzle():
	var puzzle = game_manager.get_new_puzzle()
	#Log.pr("new puzzle? ",puzzle)
	var cipher_text = split_text(puzzle.cipherText)
	quote_scene.word_array = cipher_text
	quote_scene.author = puzzle.author
	quote_scene.quote = puzzle.plainText
	quote_scene.compile_quote()


func _on_new_game():
	get_tree().reload_current_scene()


func split_text(quote: String) -> Array:
	return quote.split(" ")
