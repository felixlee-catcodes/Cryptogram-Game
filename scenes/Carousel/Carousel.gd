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
const SWIPE_THRESHOL : float = 100.0

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
#region HANDLE INPUT:
#func _unhandled_input(event):
	#if event is InputEventPanGesture or (event is InputEventMouseButton and not event.pressed):
		#snap_to_nearest_page()

func _ready():
	quote_book = QuoteBook.new().load_book()
	_set_bg_texture()
	
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	_build_pages()

	
func snap_to_nearest_page() -> void:
	Log.pr("page width: ", page_width)
	var target_index = round(scroll.scroll_horizontal / page_width)
	current_page = clamp(target_index, 0, pages.get_child_count() - 1)

	var target_x = current_page * page_width
	var tween = create_tween()
	tween.tween_property(scroll, "scroll_horizontal", target_x, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	update_dots()
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
	Log.pr("PAGE COUNT: ", total_pages)
	
	for page_index in range(total_pages):
		var page = CenterContainer.new()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.size_flags_vertical = Control.SIZE_EXPAND_FILL
		page.custom_minimum_size = Vector2(scroll.size.x, 0)
		#page_stack.add_theme_constant_override("separation", 50)

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
			card.set_quote_text(entry.text, entry.author)
			page_stack.add_child(card)
			#Log.pr("entry: ", entry.author)
		
		pages.add_child(page)
		
		
		
		
		#page.custom_minimum_size = Vector2(scroll.size.x, scroll.size.y)
		#pages.add_child(page)

	### FILL PAGE W/ UP TO 3 QUOTES:
		#for i in range(quotes_per_page):
			#var quote_index = page_index * quotes_per_page + i
			#if quote_index >= quotes.size():
				#break
			#var entry : QuoteEntry = quotes[quote_index]
			#var card = quote_card_scene.instantiate()
			#card.set_quote_text(entry.text, entry.author)
			#page.add_child(card)
		#
		## ADD A DOT:
		#var dot = ColorRect.new()
		#dot.color = Color.WHITE_SMOKE
		#dot.custom_minimum_size = Vector2(16, 8)
		#dots.add_child(dot)

func _set_bg_texture() -> void :
	bg_texture = ThemeManager.active_theme.bg_texture
	background.set_texture(bg_texture)


func update_dots() -> void:
	for i in range(dots.get_child_count()):
		var dot = dots.get_child(i)
		if i == current_page:
			dot.modulate = Color.WEB_GRAY
		else: dot.modulate = Color.WHITE_SMOKE
