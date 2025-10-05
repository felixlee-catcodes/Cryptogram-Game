extends MenuButton
@onready var qb_menu_button : MenuButton = $"."

@export var custom_popup : PackedScene # my TagScene with a PopupPanel as root
@export var quote_book : QuoteBook

var qb_options_scene : PopupPanel


func _ready():
	button_pressed = false
	qb_options_scene = custom_popup.instantiate()
	qb_menu_button.add_child(qb_options_scene)
	qb_options_scene.hide()
	

func _on_id_pressed(id):
	match id:
		pass


func _on_pressed():
	var offset = global_position + Vector2(0, 108)
	var rect = Rect2(offset, size)
	Log.pr(rect)
	qb_options_scene.popup(rect)
