extends Control

@export var	bg_texture : Texture2D
@export var quote_book : QuoteBook
@export var quote_card_scene : PackedScene = load("res://scenes/QuoteCard/QuoteCard.tscn")
@export var quotes_per_page : int = 3
@export var next_texture : Texture2D
@export var prev_texture : Texture2D


@onready var background: TextureRect = $Background
@onready var searchbar = $MainVBox/Control/SearchBar
@onready var scroll : ScrollContainer = $MainVBox/Scroll
@onready var pages: HBoxContainer = $MainVBox/Scroll/Pages
@onready var dots = $MainVBox/PageIndicators

const MAX_DOTS_VISIBLE : int = 5
var page_window_start : int = 0
var total_pages : int = 0

var all_entries : Array = []
var show_stats : bool = false

var current_page : int = 0
var page_width : int = 0

## swipe variables:
var drag_start_x : float = 0.0
var dragging : bool = false
const SWIPE_THRESHOLD : float = 100.0


func _ready():
	EventHub.ui_events.show_stats.connect(_on_stats_toggled)
	EventHub.inputs.update_archive.connect(_on_update_archive)
	quote_book = QuoteBook.new().load_book()
	_apply_custom_styles()
	
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_build_pages()

func _on_update_archive():
	_build_pages()


func _apply_custom_styles() -> void :
	bg_texture = ThemeManager.active_theme.bg_texture
	background.set_texture(bg_texture)
	
	var search_sb = StyleBoxFlat.new()
	search_sb.bg_color = ThemeManager.active_theme.basic_ui_color
	search_sb.set_corner_radius_all(20)
	
	var focus_sb = StyleBoxFlat.new()
	focus_sb.bg_color = ThemeManager.active_theme.basic_ui_color
	focus_sb.border_color = ThemeManager.active_theme.focus_color
	focus_sb.set_border_width_all(5)
	focus_sb.border_blend = true
	focus_sb.set_corner_radius_all(20)
	
	searchbar.add_theme_stylebox_override("normal", search_sb)
	searchbar.add_theme_stylebox_override("focus", focus_sb)
	searchbar.add_theme_color_override("font_color", ThemeManager.active_theme.font_color)


#region HANDLE INPUT:

## --- swipe handling ---
func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) \
	or (event is InputEventScreenTouch and event.pressed):
		if event.pressed:
			drag_start_x = event.position.x
			dragging = true
		elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed) \
	or (event is InputEventScreenTouch and not event.pressed):
			if dragging:
				var delta = event.position.x - drag_start_x
				if abs(delta) > SWIPE_THRESHOLD:
					if delta < 0:
						snap_to_nearest_page(current_page + 1)
					else:
						snap_to_nearest_page(current_page - 1)
				else:
					snap_to_nearest_page(current_page)
			dragging = false

	elif (event is InputEventMouseMotion and dragging) \
	or (event is InputEventScreenDrag and dragging):
		# optional: live dragging (scroll moves with finger)
		scroll.scroll_horizontal -= int(event.relative.x)

	
func snap_to_nearest_page(page_index: int) -> void:
	if page_index < 0 or page_index >= pages.get_child_count():
		return
	
	current_page = page_index
	var page = pages.get_child(page_index)
	var target_x = page.position.x
	scroll.scroll_horizontal = int(target_x)
	
	if current_page < page_window_start:
		page_window_start = current_page
	elif current_page >= page_window_start + MAX_DOTS_VISIBLE:
		page_window_start = current_page - MAX_DOTS_VISIBLE + 1
		
	_build_page_indicators()
#endregion

func _build_pages() -> void:
	await get_tree().process_frame
	
	for page in pages.get_children():
		page.custom_minimum_size.x = scroll.size.x
		#Log.pr("scroll size: ", scroll.size.x)

	##clear out old children if rebuilding:
	for p in pages.get_children():
		p.queue_free()

	
	var quotes = quote_book.quotes
	total_pages = int(ceil(float(quotes.size())/ quotes_per_page))
	
	for page_index in range(total_pages):
		var page = CenterContainer.new()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.size_flags_vertical = Control.SIZE_EXPAND_FILL
		page.custom_minimum_size = Vector2(scroll.size.x, 0)

		var page_stack = VBoxContainer.new()
		page_stack.add_theme_constant_override("separation", 40)
		page_stack.alignment = VBoxContainer.ALIGNMENT_CENTER
		page.add_child(page_stack)
		
		for j in range(quotes_per_page):
			var idx = page_index * quotes_per_page + j
			if idx >= quotes.size():
				break
			var entry = quotes[idx]
			
			var card = quote_card_scene.instantiate()
			card.card_data = entry
			card.call_deferred("set_quote_text", entry)
			
			page_stack.add_child(card)
			card.set_stats_visible(show_stats)
			#all_entries.append(entry)
			#Log.pr(card, card.text)
			
		
		pages.add_child(page)
		
		
	_build_page_indicators()


func _build_page_indicators() -> void:
	for child in dots.get_children():
		child.queue_free()
	
	if page_window_start > 0:
		var prev = Button.new()
		#prev.text = "<"
		prev.icon = prev_texture
		prev.focus_mode = Control.FOCUS_NONE
		prev.pressed.connect(func():
			page_window_start = max(page_window_start - MAX_DOTS_VISIBLE, 0)
			_build_page_indicators()
			)
		dots.add_child(prev)
	var window_end = min(page_window_start + MAX_DOTS_VISIBLE, total_pages)
	for i in range(page_window_start, window_end):
		var dot = Button.new()
		dot.toggle_mode = true
		dot.text = "%d" % (i + 1)
		dot.custom_minimum_size = Vector2(24, 24)
		dot.focus_mode = Control.FOCUS_NONE
		dot.add_theme_color_override("font_color", Color.BLACK)
		dot.add_theme_color_override("font_hover_color", Color.BLACK)
		dot.add_theme_color_override("font_focus_color", Color.GHOST_WHITE)
		
		var active = (i == current_page)
		##STLYE AS CIRCLE:
		dot.add_theme_stylebox_override("normal", _make_dot_style(active))
		dot.add_theme_stylebox_override("hover", _make_dot_style(active))
		dot.add_theme_stylebox_override("pressed", _make_dot_style(true))
		
		dot.pressed.connect(func():
			snap_to_nearest_page(i))
		
		dots.add_child(dot)
	
	if window_end < total_pages:
		var next = Button.new()
		next.icon = next_texture
		next.focus_mode = Control.FOCUS_NONE
		next.pressed.connect(func():
			page_window_start = min(page_window_start + MAX_DOTS_VISIBLE, total_pages - MAX_DOTS_VISIBLE)
			_build_page_indicators()
			)
		dots.add_child(next)

func _make_dot_style(active : bool) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = ThemeManager.active_theme.basic_ui_color if active else Color.WHITE
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 0
	sb.content_margin_bottom = 0
	sb.content_margin_top = 0
	sb.content_margin_right = 0
	return sb


func update_dots() -> void:
	for i in range(dots.get_child_count()):
		var dot = dots.get_child(i)
		if i == current_page:
			dot.modulate = ThemeManager.active_theme.basic_ui_color
		else: dot.modulate = Color.WHITE_SMOKE


func _on_search_bar_text_changed(new_text: String):
	new_text = new_text.strip_edges().to_lower()
	
	if new_text == "":
		display_search_matches(quote_book.quotes)
		return
	
	var matches : Array = []
	for entry in quote_book.quotes:
		if new_text in entry.text.to_lower() or new_text in entry.author.to_lower():
			matches.append(entry)
	
	display_search_matches(matches)


func display_search_matches(data_list: Array) -> void:
	for p in pages.get_children():
		p.queue_free()
		
	if data_list.is_empty():
		Log.pr("no results found")
		$MainVBox/NoResultsLabel.visible = true
		return
	else: 
		$MainVBox/NoResultsLabel.visible = false
	var total_pages = int(ceil(float(data_list.size())/ quotes_per_page))
	
	for page_idx in range(total_pages):
		var page = CenterContainer.new()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.size_flags_vertical = Control.SIZE_EXPAND_FILL
		page.custom_minimum_size = Vector2(scroll.size.x, 0)
		
		var page_stack = VBoxContainer.new()
		page_stack.add_theme_constant_override("separation", 40)
		page_stack.alignment = VBoxContainer.ALIGNMENT_CENTER
		page.add_child(page_stack)
		
		for j in range(quotes_per_page):
			var idx = page_idx * quotes_per_page + j
			if idx >= data_list.size():
				break

			var entry = data_list[idx]
			var card = quote_card_scene.instantiate()
			card.set_quote_text(entry)
			card.set_stats_visible(show_stats)
			page_stack.add_child(card)

			Log.pr(card, card.text)
		
		pages.add_child(page)
		
		
	_build_page_indicators()


func _on_stats_toggled(_show : bool) -> void:
	show_stats = _show
	_build_pages()
	#Log.pr("showing stats? ", show_stats)
