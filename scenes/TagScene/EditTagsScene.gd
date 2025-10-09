extends PopupPanel
class_name EditTagsScene

@export var entry_data : QuoteEntry = null

@onready var quote_book : QuoteBook
@onready var tag_container = $MainContainer/ScrollContainer/TagContainer
@onready var line_edit = $MainContainer/LineEdit

var tags : Dictionary
var prev_tags : Array
var data_null : bool

func _ready():
	data_null = (entry_data == null)
	quote_book = QuoteBook.new().load_book()
	prev_tags = quote_book.prev_tags
	line_edit.text_submitted.connect(update_tag_list)
	if entry_data == null:
		pass
	tags_to_dict()
	populate_tags(tags)


func tags_to_dict():
	if not data_null:
		for t in entry_data.tags:
			tags[t] = {"checked": true}
	
	for t in prev_tags:
		if not tags.has(t):
			tags[t] = {"checked": false}


func populate_tags(data_list) -> void:
	for t in tag_container.get_children():
		tag_container.remove_child(t)
		t.queue_free()

	for t in data_list:
		var cb : CheckBox = CheckBox.new()
		style_checkbox(cb)
		cb.text = t
		cb.toggle_mode = true
		cb.toggled.connect(_on_checked.bind(t))
		cb.set_pressed_no_signal(data_list[t]["checked"])
		tag_container.add_child(cb)


func style_checkbox(node: CheckBox) -> void:
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
		node.add_theme_stylebox_override("focus", cb_focus)
		node.add_theme_stylebox_override("normal", cb_normal)
		node.add_theme_stylebox_override("pressed", cb_pressed)
		node.add_theme_stylebox_override("hover_pressed", cb_hover_pressed)


func _on_checked(toggle_mode: bool, tag: String) -> void:
	tags[tag]["checked"] = toggle_mode


func update_tag_list(new_text) -> void:
	tags[new_text] = {"checked": true}
	populate_tags(tags)
	line_edit.text = ""


func _on_save_changes_pressed():
	var checked = tags.keys().filter(func(t):
		return tags[t]["checked"])
	if not data_null:
		quote_book.update_tags(entry_data, checked)
		EventHub.inputs.update_archive.emit()
	else: EventHub.ui_events.transmit_tags.emit(checked)

	hide()


func _on_line_edit_focus_entered():
	await get_tree().process_frame
	var parent = get_tree().root.get_child(0)
	var keyboard_height = DisplayServer.virtual_keyboard_get_height()
	var screen_height = parent.get_viewport().get_visible_rect().size.y
	
	var popup_bttm = self.get_size_with_decorations().y + self.get_position_with_decorations().y
	var visible_bttm = screen_height - 520
	
	if popup_bttm > visible_bttm:
		var offset = popup_bttm - visible_bttm
		Log.pr("offset: ", offset)
		Log.pr("popup bttm: ", popup_bttm)
		Log.pr("vis bttm: ",visible_bttm)
		var tween : Tween = create_tween()
		tween.tween_property(self, "position:y", visible_bttm/2, 0.25)
