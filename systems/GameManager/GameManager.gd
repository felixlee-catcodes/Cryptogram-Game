extends Node
class_name GameManager

@onready var timer = $Timer
@onready var all_correct_scene = preload("res://scenes/AllCorrectPopup/AllCorrectPopup.tscn")

enum CellStatus {EMPTY, CORRECT, INCORRECT}

var current_puzzle : Dictionary
var current_cipher : Dictionary
var cell_states : Dictionary = {}
var elapsed_time : int
var raw_data : Dictionary
var hints_used : int = 0

func _ready():
	EventHub.inputs.text_input.connect(_update_progress)
	EventHub.game.reset_game.connect(_on_reset_game)
	EventHub.game.get_hint.connect(_on_get_hint)
	EventHub.game.check_game.connect(_on_check_game)


func start_game():
	Log.pr("current scene? ",get_tree().current_scene)
	InputManager.letter_to_groups.clear()
	timer.start()


func _on_timer_timeout():
	elapsed_time += 1
	EventHub.ui_events.update_timer.emit(elapsed_time)


func _update_progress(cell: LetterCell, key: String):
	var cipher_letter = cell.encoded_letter
	#var correct_key = current_cipher.find_key(cipher_letter)
	
	if key == "Clear":
		cell_states.erase(cipher_letter)
		return
	
	if current_cipher.has(key) and current_cipher[key] == cipher_letter:
		cell_states[cipher_letter] = {"key": key, "status": CellStatus.CORRECT}
	else:
		cell_states[cipher_letter] = {"key": key, "status": CellStatus.INCORRECT}

	check_completion()


func get_incorrect_cells() -> Array:
	if cell_states.keys().is_empty():
		Log.pr("handle check game, no cell input")
	return cell_states.keys().filter(func(k):
		return cell_states[k].status == CellStatus.INCORRECT)


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

func _on_check_game():
	var incorrect_cells = get_incorrect_cells()
	for c in incorrect_cells:
		get_tree().call_group(c, "show_incorrect")
	if incorrect_cells.is_empty():
		show_popup()

func show_popup() -> void:
	var all_correct_popup = all_correct_scene.instantiate()
	var fadeout : Tween = create_tween()
	
	var parent_node = find_parent("Main")
	parent_node.add_child(all_correct_popup)
	fadeout.tween_property(all_correct_popup, "modulate:a", 0.0, 5.0)
	await get_tree().create_timer(2.0).timeout
	all_correct_popup.queue_free()

func check_completion():
	if cell_states.size() == current_cipher.size():
		timer.stop()
		current_puzzle["hints_used"] = hints_used
		EventHub.game.game_over.emit(elapsed_time, current_puzzle)
		update_player_stats(elapsed_time, hints_used)
		#Log.pr(SaveManager.stats.completion_record)
		#QuoteApiManager.mark_quote_solved(raw_data)
		cell_states.clear()


func update_player_stats(time: int, num_hints: int = 0):
	SaveManager.record_solve(time, num_hints)


func _on_reset_game():
	get_tree().call_group("letter_cells", "clear_cell")


func _on_get_hint():
	var empty_cells = get_tree().get_nodes_in_group("empty_cells")

	var randIdx = randi_range(0, empty_cells.size() - 1)
	var chosen_cell: LetterCell = empty_cells[randIdx]
	var cipher_char = chosen_cell.encoded_letter
	var cipher_group = chosen_cell.get_groups()[0]

	var plain_text_char : String = current_cipher.find_key(cipher_char)

	get_tree().call_group(cipher_group, "_update_text", plain_text_char)
	EventHub.inputs.text_input.emit(chosen_cell, plain_text_char)
	
	elapsed_time += 5
	hints_used += 1
