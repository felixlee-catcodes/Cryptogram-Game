extends Control

# Node refs (adjust paths if needed)
@onready var scroll          : ScrollContainer = $MainVBox/Scroll
@onready var pages           : HBoxContainer   = $MainVBox/Scroll/Pages
@onready var page_indicator  : HBoxContainer   = $MainVBox/PageIndicators

# Content sources
@export var quote_card_scene : PackedScene
@export var quote_book       : QuoteBook
@export var quotes_per_page  : int = 3

# Swipe vars
const SWIPE_THRESHOLD : float = 100.0
var drag_start_x : float = 0.0
var dragging : bool = false

# pagination
var current_page : int = 0
var page_width : float = 0.0


func _ready() -> void:
	# Let the ScrollContainer be controllable programmatically, but
	# prevent it from handling mouse/touch drag itself:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# build pages from your quote_book (ensure quote_book is set)
	_build_pages()

	# wait a frame for layout to settle, compute page width
	await get_tree().process_frame
	_update_page_width()

	# initial snap to page 0 (with animation off)
	_snap_to_page(0, true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_page_width()


# -----------------------
# PAGE BUILDING + DOTS
# -----------------------
func _build_pages() -> void:
	# clear
	for c in pages.get_children():
		c.queue_free()
	for d in page_indicator.get_children():
		d.queue_free()

	var quotes := quote_book.quotes if quote_book else []
	var page_count := int(ceil(float(quotes.size()) / float(quotes_per_page)))

	for i in range(page_count):
		# Each page is a CenterContainer that fills viewport width,
		# with a VBox inside to stack up to N cards (evenly spaced).
		var page_center := CenterContainer.new()
		page_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page_center.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		# force minimum width so HBox gives it full viewport width (updated again on resize)
		page_center.custom_minimum_size = Vector2(scroll.size.x, 0)

		var page_vbox := VBoxContainer.new()
		page_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page_vbox.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		page_vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		# flexible top spacer so cards distribute vertically
		var top_flex := Control.new()
		top_flex.size_flags_vertical = Control.SIZE_EXPAND_FILL
		page_vbox.add_child(top_flex)

		# add up to quotes_per_page cards (each inside its own CenterContainer to center horizontally)
		var cards_added := 0
		for j in range(quotes_per_page):
			var idx := i * quotes_per_page + j
			if idx >= quotes.size():
				break
			var entry := quotes[idx]

			var cwrap := CenterContainer.new()
			cwrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cwrap.size_flags_vertical   = Control.SIZE_SHRINK_CENTER

			var card := quote_card_scene.instantiate()
			# Call your QuoteCard API — adjust method name if yours differs:
			if card.has_method("set_quote_text"):
				card.set_quote_text(entry.text, entry.author)
			else:
				# fallback: set labels if fields exist
				if card.has_node("VBoxContainer/TextLabel"):
					card.get_node("VBoxContainer/TextLabel").text = entry.text
				if card.has_node("VBoxContainer/SourceLabel"):
					card.get_node("VBoxContainer/SourceLabel").text = entry.author

			cwrap.add_child(card)
			page_vbox.add_child(cwrap)
			cards_added += 1

			# add flexible spacer between cards (but not after last)
			if j < quotes_per_page - 1:
				var mid := Control.new()
				mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
				page_vbox.add_child(mid)

		# flexible bottom spacer
		var bottom_flex := Control.new()
		bottom_flex.size_flags_vertical = Control.SIZE_EXPAND_FILL
		page_vbox.add_child(bottom_flex)

		page_center.add_child(page_vbox)
		pages.add_child(page_center)

	# build dots (buttons)
	for k in range(page_count):
		var dot := Button.new()
		dot.toggle_mode = true
		dot.focus_mode = Control.FOCUS_NONE
		dot.custom_minimum_size = Vector2(16, 16)
		# style it as a round dot via a simple StyleBoxFlat
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color.GRAY	
		sb.corner_radius_all = 8
		dot.add_theme_stylebox_override("normal", sb)
		# pressed/checked style
		var sb_on := StyleBoxFlat.new()
		sb_on.bg_color = Color.WHITE
		sb_on.corner_radius_all = 8
		dot.add_theme_stylebox_override("pressed", sb_on)
		dot.add_theme_stylebox_override("hover", sb_on)

		# connect with argument for the page index
		#player.hit.connect(_on_player_hit.bind("sword", 100))
		dot.pressed.connect(_on_dot_pressed.bind([k]))
		#dot.connect("pressed", Callable(self, "_on_dot_pressed"), [k])
		page_indicator.add_child(dot)

	# make sure indicator reflects current page
	_update_page_indicator()


# Dot pressed handler
func _on_dot_pressed(which_page: int) -> void:
	_snap_to_page(which_page)


# update toggle state of dots
func _update_page_indicator() -> void:
	for i in range(page_indicator.get_child_count()):
		var dot = page_indicator.get_child(i)
		if dot is Button:
			dot.pressed = (i == current_page)


# -----------------------
# SWIPE / INPUT HANDLING
# -----------------------
func _gui_input(event: InputEvent) -> void:
	# TOUCH PRESS
	if event is InputEventScreenTouch:
		if event.pressed:
			drag_start_x = event.position.x
			dragging = true
		else:
			# release
			if dragging:
				var delta = event.position.x - drag_start_x
				_handle_release(delta)
			dragging = false
		return

	# TOUCH DRAG (finger moved)
	if event is InputEventScreenDrag and dragging:
		# move scroll by relative x (follow finger)
		scroll.scroll_horizontal = clamp(scroll.scroll_horizontal - event.relative.x, 0, _max_scroll())
		return

	# MOUSE PRESS/RELEASE (desktop)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			drag_start_x = event.position.x
			dragging = true
		else:
			if dragging:
				var delta_m = event.position.x - drag_start_x
				_handle_release(delta_m)
			dragging = false
		return

	# MOUSE MOTION while dragging
	if event is InputEventMouseMotion and dragging:
		scroll.scroll_horizontal = clamp(scroll.scroll_horizontal - event.relative.x, 0, _max_scroll())
		return


func _handle_release(delta_x: float) -> void:
	# If fling/swipe passed threshold, move next/prev page, otherwise snap to nearest
	if abs(delta_x) > SWIPE_THRESHOLD:
		if delta_x < 0:
			_snap_to_page(current_page + 1)
		else:
			_snap_to_page(current_page - 1)
	else:
		# snap to nearest page according current scroll position
		if page_width > 0:
			var nearest := int(round(scroll.scroll_horizontal / page_width))
			_snap_to_page(nearest)
		else:
			_snap_to_page(current_page)


# -----------------------
# SNAP (animated)
# -----------------------
func _snap_to_page(page_index: int, instant: bool=false) -> void:
	var count := pages.get_child_count()
	if count == 0:
		return
	page_index = clamp(page_index, 0, count - 1)
	current_page = page_index

	# compute target x based on page index and page_width
	var target_x := page_index * page_width
	if instant:
		scroll.scroll_horizontal = int(target_x)
	else:
		# smooth tween
		var t = create_tween()
		t.tween_property(scroll, "scroll_horizontal", target_x, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	_update_page_indicator()


# -----------------------
# HELPERS
# -----------------------
func _update_page_width() -> void:
	# page width = viewport width + separation between pages
	var sep := 0
	Log.pr("pages? ", pages)
	# try to grab HBox separation theme constant (if you set one)
	#if pages.has_method("get_theme_constant"):
	#sep = pages.get_theme_constant("separation")
	page_width = scroll.size.x + 15

	# make sure each page child has the same custom width so CenterContainer will center correctly
	for c in pages.get_children():
		if c is Control:
			c.custom_minimum_size.x = scroll.size.x


func _max_scroll() -> float:
	var count := pages.get_child_count()
	if count <= 1:
		return 0.0
	return max(0.0, (count - 1) * page_width)
