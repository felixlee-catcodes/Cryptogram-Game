extends PopupPanel
class_name EditTagsScene

@export var entry_data : QuoteEntry

@onready var quote_book : QuoteBook
@onready var tag_container = $MainContainer/TagContainer
@onready var line_edit = $MainContainer/LineEdit

var tags : Dictionary
var prev_tags : Array

func _ready():
	quote_book = QuoteBook.new().load_book()
	prev_tags = quote_book.prev_tags
	line_edit.text_submitted.connect(update_tag_list)
	Log.prn(entry_data.tags)
	tags_to_dict()
	populate_tags(tags)


func tags_to_dict():
	for t in entry_data.tags:
		tags[t] = {"checked": true}
	
	for t in prev_tags:
		if not tags.has(t):
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
		cb_hover_pressed.set_corner_radius_all(12)
		cb_hover_pressed.set_expand_margin_all(5)
		cb_pressed.set_corner_radius_all(12)
		cb_pressed.set_expand_margin_all(5)
		cb_pressed.bg_color = ThemeManager.active_theme.base_color
		cb.add_theme_stylebox_override("focus", cb_focus)
		cb.add_theme_stylebox_override("normal", cb_normal)
		cb.add_theme_stylebox_override("pressed", cb_pressed)
		cb.add_theme_stylebox_override("hover_pressed", cb_hover_pressed)
		cb.text = t
		cb.toggle_mode = true
		cb.toggled.connect(_on_checked.bind(t))
		cb.set_pressed_no_signal(data_list[t]["checked"])
		tag_container.add_child(cb)

func _on_checked(toggle_mode: bool, tag: String) -> void:
	tags[tag]["checked"] = toggle_mode


func update_tag_list(new_text) -> void:
	tags[new_text] = {"checked": true}
	populate_tags(tags)
	line_edit.text = ""


func _on_save_changes_pressed():
	var checked = tags.keys().filter(func(t):
		return tags[t]["checked"])
	quote_book.update_tags(entry_data, checked)
	EventHub.inputs.update_archive.emit()
	hide()
