extends Node
# MAIN
@onready var word_unit = preload("res://scenes/WordUnit/WordUnit.tscn")
@onready var game_manager = $GameManager
@onready var quote_scene = %QuoteScene
@onready var encrypted_message_display = $EncryptedMessageDisplay
@onready var game_over_display = $UILayer/GameOverDisplay

func _ready():
	game_over_display.visible = false
	EventHub.game.new_game.connect(_on_new_game)
	EventHub.game.game_over.connect(_on_game_over)
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


func _on_game_over(time, puzzle):
	quote_scene.visible = false
	game_over_display.finished_puzzle = puzzle
	game_over_display.visible = true


func split_text(quote: String) -> Array:
	return quote.split(" ")
