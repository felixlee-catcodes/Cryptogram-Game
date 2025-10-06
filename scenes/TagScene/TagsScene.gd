extends PopupPanel
class_name TagScene
##TAG EDITOR POP SCENE

## later this will be a reference to the QuoteBook resource's tag list
#@onready var tag_test = load("res://resources/QuoteBook/TagTestQuoteEntry.tres")
@onready var quote_book : QuoteBook

@onready var main_container = $MainContainer
@onready var tag_container = $MainContainer/ScrollContainer/TagContainer
@onready var line_edit = $MainContainer/LineEdit
@onready var tag_search = $MainContainer/TagSearch

var newest_tag : String = ""
var tags : Dictionary
var matches : Array


func _ready():
	#main_container.theme = "res://resources/Themes/custom_theme_1.tres"
	quote_book = QuoteBook.new().load_book()
	#Log.prn("prev tags: ", quote_book.prev_tags)
	line_edit.text_submitted.connect(update_tag_list)
	tag_search.text_changed.connect(_on_search_bar_text_changed)
	tags_to_dict()
	populate_tags(tags)


func tags_to_dict() -> void:
	for t in quote_book.prev_tags:
		tags[t] = {"checked": false}


func populate_tags(data_list) -> void:
	#clear any existing children:
	for t in tag_container.get_children():
		tag_container.remove_child(t)
		t.queue_free()

	for t in data_list:
		var cb : CheckBox = CheckBox.new()
		var cb_normal = StyleBoxFlat.new()
		var cb_pressed = StyleBoxFlat.new()
		var cb_hover_pressed = StyleBoxFlat.new()
		var cb_focus = StyleBoxFlat.new()
		cb_focus.bg_color = ThemeManager.active_theme.basic_ui_color
		cb_normal.bg_color = Color("e9e9e9")
		cb_hover_pressed.bg_color = ThemeManager.active_theme.addtl_accent_color
		cb_pressed.bg_color = ThemeManager.active_theme.base_color
		cb.add_theme_stylebox_override("focus", cb_focus)
		cb.add_theme_stylebox_override("normal", cb_normal)
		cb.add_theme_stylebox_override("pressed", cb_pressed)
		cb.add_theme_stylebox_override("hover_pressed", cb_hover_pressed)
		cb.add_theme_font_size_override("font_size", 40)
		cb.text = t
		cb.toggle_mode = true
		cb.toggled.connect(_on_checked.bind(t))
		cb.set_pressed_no_signal(data_list[t]["checked"])
		cb.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tag_container.add_child(cb)


func _on_checked(toggle_mode: bool, tag: String) -> void:
	tags[tag]["checked"] = toggle_mode


func update_tag_list(new_text) -> void:
	tags[new_text] = {"checked": true}
	populate_tags(tags)
	line_edit.text = ""


func _on_search_bar_text_changed(new_text: String):
	new_text = new_text.strip_edges().to_lower()
	
	if new_text == "":
		populate_tags(tags)
		return
	
	var matches : Dictionary = {}
	for tag in tags:
		if new_text in tag.to_lower():
			matches[tag] = tags[tag]
	
	populate_tags(matches)


func _on_button_pressed():
	var checked = tags.keys().filter(func(t):
		return tags[t]["checked"])
	EventHub.ui_events.transmit_tags.emit(checked)
	hide()
