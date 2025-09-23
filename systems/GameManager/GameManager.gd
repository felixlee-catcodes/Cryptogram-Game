extends Node
class_name GameManager

@onready var timer = $Timer

var current_puzzle : Dictionary
var current_cipher : Dictionary
var solved_cells : Dictionary
var elapsed_time : int
var raw_data : Dictionary

func _ready():
	EventHub.inputs.text_input.connect(_update_progress)
	EventHub.game.reset_game.connect(_on_reset_game)

#WHAT ARE SOME FUNC THE GAMEMANAGER NEEDS?
func start_game():
	timer.start()


func _on_timer_timeout():
	elapsed_time += 1
	EventHub.ui_events.update_timer.emit(elapsed_time)


func _update_progress(cell: LetterCell, key: String):
	var cipher_letter = cell.encoded_letter
	var cipher_keys = current_cipher.keys()
	
	if key == "Clear":
		solved_cells.erase(cipher_letter)

	if cipher_keys.has(key) and current_cipher[key] == cipher_letter:
		solved_cells.get_or_add(cipher_letter, key)
	check_completion()


func get_new_puzzle():
	var quote: Dictionary = await QuoteApiManager.get_random_quote()
	if quote.is_empty():
		await QuoteApiManager.fetch_and_add_quotes()
		quote = await QuoteApiManager.get_random_quote()
	raw_data = quote

	var puzzle_data = PuzzleManager.process_plain_text(quote.quote)
	current_puzzle = puzzle_data
	Log.pr(current_puzzle.plainText)
	current_cipher = puzzle_data["cipher"]
	puzzle_data["author"] = quote["author"]

	return puzzle_data


func check_completion():
	if solved_cells.size() == current_cipher.size():
		timer.stop()
		EventHub.game.game_over.emit(elapsed_time)
		update_player_stats(elapsed_time)
		#Log.pr(SaveManager.stats.completion_record)
		#QuoteApiManager.mark_quote_solved(raw_data)
		solved_cells.clear()
		
		
func update_player_stats(time: int):
	SaveManager.record_solve(time)


func _on_reset_game():
	get_tree().call_group("letter_cells", "clear_cell")
