extends MenuButton
##SAVE TEXT MENU BUTTON

@onready var settings = $"."
@onready var save_text = %SaveText

@export var custom_popup : PackedScene # my TagScene with a PopupPanel as root
@export var quote_book : QuoteBook

var tag_scene : PopupPanel

func _ready():
	button_pressed = false
	quote_book = QuoteBook.new().load_book()
	var tags : Array = quote_book.prev_tags

	tag_scene = custom_popup.instantiate()
	#tag_scene.size = Vector2(500, 300)
	save_text.add_child(tag_scene)
	tag_scene.hide()


func _on_pressed():
	var offset = global_position + Vector2(0, -150)
	var rect = Rect2(offset, size)
	Log.pr(rect)
	tag_scene.popup_centered()
