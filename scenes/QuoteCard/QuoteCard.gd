extends Panel

@onready var text_label = $CenterContainer/VBoxContainer/TextLabel
@onready var source_label = $CenterContainer/VBoxContainer/SourceLabel
##STATS
@onready var date = $CenterContainer/VBoxContainer/StatsBar/Date
@onready var time = $CenterContainer/VBoxContainer/StatsBar/Time
@onready var hints = $CenterContainer/VBoxContainer/StatsBar/Hints

func _ready():
	pass

func set_quote_text(_text: String, source: String, date, solve_time: int, num_hints: int) -> void:
	var text_label : Label = $CenterContainer/VBoxContainer.get_node("TextLabel")
	var source_label : Label = $CenterContainer/VBoxContainer.get_node("SourceLabel")
	var date_label : Label = $CenterContainer/VBoxContainer/StatsBar.get_node("Date")
	var time_label : Label = $CenterContainer/VBoxContainer/StatsBar.get_node("Time")
	var hints_label : Label = $CenterContainer/VBoxContainer/StatsBar.get_node("Hints")
	
	var date_time_dict = convert_date_time(date, solve_time)
	
	text_label.add_theme_font_size_override("font_size", 32)
	text_label.add_theme_color_override("font_color", ThemeManager.active_theme.panel_color)
	source_label.add_theme_font_size_override("font_size", 32)
	source_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	source_label.add_theme_color_override("font_color", ThemeManager.active_theme.panel_color)
	
	text_label.text = "\"%s\"" % _text
	source_label.text = "- %s" % source
	date_label.text = date_time_dict["date"]
	time_label.text = "Solved in %s" % date_time_dict["time"]
	hints_label.text = "No hints used!" if num_hints == 0 else "%d Hints Used" % num_hints

func convert_date_time(date, _time) -> Dictionary:
	var date_time_dict = {}
	var dt = DateTime.from_isoformat(date)
	var formatted = dt.strftime("%b %d, %Y")
	formatted = formatted[0].to_upper() + formatted.substr(1, formatted.length() - 1)
	
	var m = int(_time / 60.0)
	var s = _time - m * 60
	var t = "%02ss" % [s] if m == 0 else "%dmin %02ss" % [m, s]
	date_time_dict["date"] = formatted
	date_time_dict["time"] = t
	return date_time_dict
