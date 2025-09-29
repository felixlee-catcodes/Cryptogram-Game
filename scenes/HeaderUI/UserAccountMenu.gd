extends MenuButton
@onready var settings = $"."

enum MenuItems {
	USER, 
	SAVES, 
	RESET_STATS
}

var menu : PopupMenu
var last_hint_time : float = 0.0
var hint_cooldown : float = 5.0

func _ready():
	button_pressed = false
	menu = get_popup()
	menu.add_separator("User", MenuItems.USER)
	menu.add_item("Saves", MenuItems.SAVES)
	menu.add_item("Reset Stats", MenuItems.RESET_STATS)
	

	menu.hide_on_item_selection = false
	menu.id_pressed.connect(_on_id_pressed)

func _on_id_pressed(id):
	match id:
		MenuItems.SAVES:
			get_tree().change_scene_to_file("res://scenes/Carousel/Carousel.tscn")
		MenuItems.RESET_STATS:
			EventHub.game.reset_game.emit()
