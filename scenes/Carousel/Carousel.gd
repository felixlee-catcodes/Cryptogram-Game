@tool
extends Control

@export var	bg_texture : Texture2D
@export var quote_book : QuoteBook
@export var quote_card_scene : PackedScene = load("res://scenes/QuoteCard/QuoteCard.tscn")
@export var quotes_per_page : int = 3

@onready var background: TextureRect = $Background
@onready var scroll : ScrollContainer = $MainVBox/Scroll
@onready var pages: HBoxContainer = $MainVBox/Scroll/Pages
@onready var dots = $MainVBox/PageIndicators

var current_page : int = 0
var page_width : int = 0

## swipe variables:
var drag_start_x : float = 0.0
var dragging : bool = false
const SWIPE_THRESHOLD : float = 100.0

#region OG _READY()
#func _ready():
	#quote_book = QuoteBook.new().load_book()
	#populate_pages()
	#_set_bg_texture()
	### wait for 1st frame for layout to be ready
	#await get_tree().process_frame
	#if pages.get_child_count() > 0:
		##page_width = pages.get_child(0).size.x
		#page_width = pages.get_child(0).size.x + pages.get_theme_constant("separation")
		#Log.pr("page width: ", page_width)
		#
	#
	#update_dots()
#endregion
func _ready():
	quote_book = QuoteBook.new().load_book()
	_set_bg_texture()
	
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_build_pages()
#region HANDLE INPUT:
# --- swipe handling ---
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
	
	_build_page_indicators(pages.get_child_count())
#endregion

func _build_pages() -> void:
	await get_tree().process_frame
	for page in pages.get_children():
		page.custom_minimum_size.x = scroll.size.x
		Log.pr("scroll size: ", scroll.size.x)

	##clear out old children if rebuilding:
	for p in pages.get_children():
		p.queue_free()
	#for dot in dots.get_children():
		#dot.queue_free()
	
	var quotes = quote_book.quotes
	var total_pages = int(ceil(float(quotes.size())/ quotes_per_page))
	#Log.pr("PAGE COUNT: ", total_pages)
	
	for page_index in range(total_pages):
		var page = CenterContainer.new()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.size_flags_vertical = Control.SIZE_EXPAND_FILL
		page.custom_minimum_size = Vector2(scroll.size.x, 0)

		var page_stack = VBoxContainer.new()
		page_stack.add_theme_constant_override("separation", 50)
		page_stack.alignment = VBoxContainer.ALIGNMENT_CENTER
		page.add_child(page_stack)
		
		for j in range(quotes_per_page):
			var idx = page_index * quotes_per_page + j
			if idx >= quotes.size():
				break
			var entry = quotes[idx]
			
			var card = quote_card_scene.instantiate()
			card.set_quote_text(entry.text, entry.author, entry.date_added, entry.solve_time, entry.hints_used)
			page_stack.add_child(card)
		
		pages.add_child(page)
		
		
	_build_page_indicators(total_pages)


func _build_page_indicators(page_count: int) -> void:
	for child in dots.get_children():
		child.queue_free()
	
	for i in range(page_count):
		var dot = Button.new()
		dot.toggle_mode = true
		dot.text = ""
		dot.custom_minimum_size = Vector2(24, 24)
		dot.focus_mode = Control.FOCUS_NONE
		dot.add_theme_color_override("font_color", Color.TRANSPARENT)
		
		##STLYE AS CIRCLE:
		dot.add_theme_stylebox_override("normal", _make_dot_style(1 == current_page))
		dot.add_theme_stylebox_override("hover", _make_dot_style(1 == current_page))
		dot.add_theme_stylebox_override("pressed", _make_dot_style(true))
		
		dot.pressed.connect(func():
			snap_to_nearest_page(i))
		
		dots.add_child(dot)

func _make_dot_style(active : bool) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color.WHITE if active else Color.GRAY
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 0
	sb.content_margin_bottom = 0
	sb.content_margin_top = 0
	sb.content_margin_right = 0
	return sb

func _set_bg_texture() -> void :
	bg_texture = ThemeManager.active_theme.bg_texture
	background.set_texture(bg_texture)


func update_dots() -> void:
	for i in range(dots.get_child_count()):
		var dot = dots.get_child(i)
		if i == current_page:
			dot.modulate = Color.WEB_GRAY
		else: dot.modulate = Color.WHITE_SMOKE
