extends CenterContainer
#GAME OVER SCENE

# need access to finished puzzle data: author, quote, solve -> send via signal?
@export var finished_puzzle : Dictionary
# need access to stats: best and average times
@onready var solved_quote = $VBoxContainer/SolvedQuote

# need reference to the quote book for saving@onready var curr_time_label = $StatsDisplay/CurrentTime/CurrTimeLabel
@onready var curr_time_value = $VBoxContainer/StatsDisplay/CurrentTime/CurrTimeValue
@onready var best_time_value = $VBoxContainer/StatsDisplay/BestTime/BestTimeValue
@onready var avg_time_value = $VBoxContainer/StatsDisplay/AverageTime/AvgTimeValue

@onready var hints_used = $VBoxContainer/HintsUsed
@onready var quotes_left = $VBoxContainer/QuotesLeft

var quote_book : QuoteBook

func _ready():
	EventHub.game.game_over.connect(_on_game_over)
	quote_book = QuoteBook.new().load_book()


func _on_game_over(time, puzzle):
	finished_puzzle = puzzle
	solved_quote.text = "%s" % puzzle["plainText"]
	curr_time_value.text = _convert_time(time)
	best_time_value.text = _convert_time(SaveManager.stats.best_time)
	avg_time_value.text = _convert_time(SaveManager.stats.all_time_avg)
	quotes_left.text = "Quotes left: %02d" % QuoteApiManager.cached_quotes.size()
	hints_used.text = "Hints used: %02d" % puzzle["hints_used"]


func _convert_time(time) -> String:
	var m = int(time / 60.0)
	var s = time - m * 60
	var t = "%02d:%02d" % [m, s]
	return t


func _on_new_game_pressed():
	EventHub.game.new_game.emit()


func _on_save_text_pressed():
	var quote = finished_puzzle["plainText"]
	var author = finished_puzzle["author"]
	
	quote_book.add_quote(quote, author, curr_time_value.text)
