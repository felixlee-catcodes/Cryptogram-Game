extends Panel
class_name QuoteCard

@export var scroll_speed: float = 60.0 # pixels per second

@onready var text_label = $CenterContainer/VBoxContainer/TextLabel
@onready var source_label = $CenterContainer/VBoxContainer/SourceLabel
@onready var stats_panel = $StatsPanel
@onready var bar_1 = $StatsPanel/ScrollContainer/StatsBar/Bar1
@onready var stats_bar = $StatsPanel/ScrollContainer/StatsBar

var text : String
var source : String

func _ready():
	var scroll_container : ScrollContainer = $StatsPanel.get_node("ScrollContainer")
	var duplicate = bar_1.duplicate()
	duplicate.name = "Bar_2"
	stats_bar.add_child(duplicate)
	

func _process(delta):
	var scroll_container : ScrollContainer = $StatsPanel/ScrollContainer
	scroll_container.scroll_horizontal += scroll_speed * delta
	
	var total_width = stats_bar.size.x
	if scroll_container.scroll_horizontal >= total_width:
		scroll_container.scroll_horizontal  = 0


func set_stats_visible(_visible: bool):
	$StatsPanel.visible = _visible


func set_quote_text(_text: String, _source: String, date, solve_time: int, num_hints: int, tags: Array) -> void:
	Log.prn("tags: ", tags)
	text = _text
	source = source
	var text_label : Label = $CenterContainer/VBoxContainer.get_node("TextLabel")
	var source_label : Label = $CenterContainer/VBoxContainer.get_node("SourceLabel")
	
	var date_label : Label = $StatsPanel/ScrollContainer/StatsBar/Bar1.get_node("Date")
	var time_label : Label = $StatsPanel/ScrollContainer/StatsBar/Bar1.get_node("Time")
	var hints_label : Label = $StatsPanel/ScrollContainer/StatsBar/Bar1.get_node("Hints")
	var date_time_dict = convert_date_time(date, solve_time)
	
	
	text_label.add_theme_font_size_override("font_size", 32)
	text_label.add_theme_color_override("font_color", ThemeManager.active_theme.panel_color)
	source_label.add_theme_font_size_override("font_size", 28)
	source_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	source_label.add_theme_color_override("font_color", ThemeManager.active_theme.panel_color)
	
	text_label.text = "\"%s\"" % _text
	source_label.text = "- %s" % _source
	date_label.text = date_time_dict["date"]
	time_label.text = "Solved in %s" % date_time_dict["time"]
	hints_label.text = "No hints used!" if num_hints == 0 else "%d Hints Used" % num_hints
	populate_tags(tags)


func populate_tags(tagArr: Array):
	var tag_container : HBoxContainer = $StatsPanel/ScrollContainer/StatsBar/Bar1.get_node("TagContainer")

	if not tagArr.is_empty():
		for tag in tagArr:
			var tag_style = StyleBoxFlat.new()
			tag_style.set_corner_radius_all(10)
			tag_style.content_margin_left = 7
			tag_style.content_margin_top = 2
			tag_style.content_margin_bottom = 2
			tag_style.content_margin_right = 7
			tag_style.bg_color = ThemeManager.active_theme.base_color
			var label : Label = Label.new()
			label.text = tag
			label.add_theme_stylebox_override("normal", tag_style)
			label.add_theme_font_size_override("font_size", 20)
			label.add_theme_color_override("font_color", Color.BLACK)
			
			tag_container.add_child(label)


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
