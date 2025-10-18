extends Control
#GAME OVER SCENE
class_name GameOverScene

# need access to finished puzzle data: author, quote, solve -> send via signal?
@export var finished_puzzle : Dictionary
@export var curr_time : int = 0

# need access to stats: best and average times
@onready var solved_quote = $VBoxContainer/QuoteContainer/CenterContainer/VBoxContainer/SolvedQuote
@onready var source = $VBoxContainer/QuoteContainer/CenterContainer/VBoxContainer/Source

@onready var stats_display = $VBoxContainer/StatsDisplay
@onready var curr_time_value = $VBoxContainer/StatsDisplay/CurrentTime/CurrTimeValue
@onready var best_time_value = $VBoxContainer/StatsDisplay/BestTime/BestTimeValue
@onready var avg_time_value = $VBoxContainer/StatsDisplay/AverageTime/AvgTimeValue

@onready var curr_time_label = $VBoxContainer/StatsDisplay/CurrentTime/CurrTimeLabel
@onready var best_time_label = $VBoxContainer/StatsDisplay/BestTime/BestTimeLabel
@onready var avg_time_label = $VBoxContainer/StatsDisplay/AverageTime/AvgTimeLabel

@onready var hints_used = $VBoxContainer/HintsUsed
@onready var quotes_left = $VBoxContainer/QuotesLeft

@onready var new_game : Button = $VBoxContainer/Buttons/NewGame
@onready var save_text : MenuButton = $VBoxContainer/Buttons/SaveText

@export var button_normal : Color
@export var button_hover : Color
@export var button_pressed : Color
@export var theme_font_color : Color

var quote_book : QuoteBook
var tags : Array[String] = []

func _ready():
	save_text.button_pressed = false
	ThemeManager.connect("theme_changed", Callable(self, "_on_theme_changed"))
	if ThemeManager.active_theme != null:
		_on_theme_changed(ThemeManager.active_theme)
	_set_stats()
	_apply_theme_styling()
	EventHub.ui_events.transmit_tags.connect(_on_transmit_tags)

	quote_book = QuoteBook.new().load_book()


#region APPLY THEME STYLING
func _apply_theme_styling() -> void:
	save_text.flat = false
	var inner_button = save_text.get_children()
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = button_normal
	normal_style.set_content_margin_all(15)
	new_game.add_theme_stylebox_override("normal", normal_style)
	save_text.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = button_hover
	new_game.add_theme_stylebox_override("hover", hover_style)
	save_text.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = button_pressed
	pressed_style.set_content_margin_all(15)
	new_game.add_theme_stylebox_override("pressed", pressed_style)
	save_text.add_theme_stylebox_override("pressed", pressed_style)
	
	#solved_quote.add_theme_color_override("font_color", theme_font_color)
	curr_time_label.add_theme_color_override("font_color", theme_font_color)
	best_time_label.add_theme_color_override("font_color", theme_font_color)
	avg_time_label.add_theme_color_override("font_color", theme_font_color)
	curr_time_value.add_theme_color_override("font_color", theme_font_color)
	best_time_value.add_theme_color_override("font_color", theme_font_color)
	avg_time_value.add_theme_color_override("font_color", theme_font_color)


func _on_theme_changed(_theme: ColorTheme):
	button_hover = _theme.basic_ui_color
	button_normal = _theme.basic_ui_color
	button_pressed = _theme.addtl_accent_color
	theme_font_color = _theme.font_color
#endregion


func _set_stats() -> void:
	animate_text()
	solved_quote.text = "\"%s\"" % finished_puzzle["plainText"]
	source.text = "- %s" % finished_puzzle["author"]
	
	curr_time_value.text = _convert_time(curr_time)
	best_time_value.text = _convert_time(SaveManager.stats.best_time)
	avg_time_value.text = _convert_time(SaveManager.stats.all_time_avg)
	quotes_left.text = "Quotes left: %02d" % QuoteApiManager.cached_quotes.size()
	hints_used.text = "Hints used: %02d" % finished_puzzle["hints_used"]


func animate_text() -> void:
	var tween_text : Tween = create_tween()
	solved_quote.visible_ratio = 0
	source.visible_ratio = 0
	curr_time_label.visible_ratio = 0
	curr_time_value.visible_ratio = 0
	best_time_label.visible_ratio = 0
	best_time_value.visible_ratio = 0
	avg_time_label.visible_ratio = 0
	avg_time_value.visible_ratio = 0
	
	tween_text.tween_property(solved_quote, "visible_ratio", 1.0, 2.5)
	tween_text.tween_property(source, "visible_ratio", 1.0, 1.5)

	for stat_section in stats_display.get_children():
		for label in stat_section.get_children():
			tween_text.tween_property(label, "visible_ratio", 1.0, 0.5)
			get_tree().create_timer(0.25)
	


func _convert_time(time: int) -> String:
	var m = int(time / 60.0)
	var s = time - m * 60
	var t = "%02d:%02d" % [m, s]
	return t


func _on_new_game_pressed():
	var new_game_scene = load("res://scenes/Main.tscn").instantiate()
	await TransitionManager.transition_to_scene(new_game_scene, TransitionManager.transitions["grid_flip"])
	EventHub.game.new_game.emit()
	Log.pr("new game button clicked")


func _on_transmit_tags(_tags: Array):
	var quote : String = finished_puzzle["plainText"]
	var author : String = finished_puzzle["author"]
	
	quote_book.add_quote(quote, author, curr_time_value.text, finished_puzzle["hints_used"], _tags)
