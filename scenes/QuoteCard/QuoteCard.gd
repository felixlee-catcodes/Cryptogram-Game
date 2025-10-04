extends Panel
class_name QuoteCard

@export var scroll_speed: float = 60.0 # pixels per second

#@onready var text_label = $CenterContainer/VBoxContainer/TextLabel
#@onready var source_label = $CenterContainer/VBoxContainer/SourceLabel
@onready var stats_panel = $StatsPanel
@onready var bar_1 = $StatsPanel/ScrollContainer/StatsBar/Bar1
@onready var stats_bar = $StatsPanel/ScrollContainer/StatsBar
@onready var scroll_container = $StatsPanel/ScrollContainer
@onready var delete_quote : TextureButton = $DeleteQuote

var total_width : float

var text : String
var source : String
@export var card_data : QuoteEntry

func _ready():
	delete_quote.pressed.connect(_on_clicked.bind(card_data))
	Log.pr(QuoteBook.new().load_book().quotes.size())
	var _duplicate = bar_1.duplicate()
	_duplicate.name = "Bar2"
	stats_bar.add_child(_duplicate)
	await get_tree().process_frame  # wait for layout
	total_width = bar_1.size.x * 2
	Log.pr("total width: ", total_width, " times 2: ", total_width * 2)

func _on_clicked(data: QuoteEntry):
	var qb = QuoteBook.new().load_book()
	Log.pr("data? ", data)
	qb.remove_entry(data)
	Log.pr(QuoteBook.new().load_book().quotes.size())
	EventHub.inputs.update_archive.emit()


func _process(delta):
	var scroll_container : ScrollContainer = $StatsPanel/ScrollContainer
	

	scroll_container.scroll_horizontal += scroll_speed * delta
	
	#var total_width = stats_bar.size.x
	if scroll_container.scroll_horizontal >= total_width:
		scroll_container.scroll_horizontal -= total_width


func set_stats_visible(_visible: bool):
	$StatsPanel.visible = _visible


func set_quote_text(entry: QuoteEntry) -> void:
	card_data = entry
	Log.prn("tags: ", entry.tags)
	text = entry.text
	source = source
	var text_label : Label = $CenterContainer/VBoxContainer.get_node("TextLabel")
	var source_label : Label = $CenterContainer/VBoxContainer.get_node("SourceLabel")
	
	var date_label : Label = $StatsPanel/ScrollContainer/StatsBar/Bar1.get_node("Date")
	var time_label : Label = $StatsPanel/ScrollContainer/StatsBar/Bar1.get_node("Time")
	var hints_label : Label = $StatsPanel/ScrollContainer/StatsBar/Bar1.get_node("Hints")
	var date_time_dict = convert_date_time(entry.date_added, entry.solve_time)
	
	
	text_label.add_theme_font_size_override("font_size", 32)
	text_label.add_theme_color_override("font_color", ThemeManager.active_theme.panel_color)
	source_label.add_theme_font_size_override("font_size", 28)
	source_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	source_label.add_theme_color_override("font_color", ThemeManager.active_theme.panel_color)
	
	text_label.text = "\"%s\"" % entry.text
	source_label.text = "- %s" % entry.author
	date_label.text = date_time_dict["date"]
	time_label.text = "Solved in %s" % date_time_dict["time"]
	hints_label.text = "No hints used!" if entry.hints_used == 0 else "%d Hints Used" % entry.hints_used
	populate_tags(entry.tags)
	print("Before frame: ", stats_bar.size.x)
	await get_tree().process_frame
	
	await update_ticker()
	print("After frame: ", stats_bar.size.x)


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
	
	
	

func update_ticker() -> void:
	if stats_bar == null or bar_1 == null:
		await get_tree().process_frame
		if stats_bar == null or bar_1 == null:
			return  # still not ready, bail out
	# Remove old duplicate if present
	if stats_bar.has_node("Bar2"):
		stats_bar.get_node("Bar2").queue_free()

		# Duplicate Bar1 so Bar2 matches current content
		var _duplicate = bar_1.duplicate()
		_duplicate.name = "Bar2"
		stats_bar.add_child(_duplicate)

		# Wait for layout to run (sometimes you need two frames to be safe)
		await get_tree().process_frame
		await get_tree().process_frame

		# Measure the width of the original bar (this is the distance to wrap)
		# Use combined minimum size which accounts for children and their margins
		total_width = bar_1.get_combined_minimum_size().x

		# Debug — remove or comment out if not needed
		print_debug("Ticker widths -> total_width:", total_width, "viewport:", scroll_container.size.x)

		# If the content now fits the viewport, reset the scroll
	if total_width <= scroll_container.size.x:
		scroll_container.scroll_horizontal = 0


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
