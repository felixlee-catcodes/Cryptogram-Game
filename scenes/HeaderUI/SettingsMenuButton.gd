extends MenuButton
@onready var settings = $"."

enum MenuItems {
	SETTINGS, 
	RESET_GAME, 
	GET_HINT,
	NEW_GAME, 
	QUIT_GAME
}

var menu : PopupMenu

func _ready():
	button_pressed = false
	menu = get_popup()
	menu.add_separator("Settings", MenuItems.SETTINGS)
	menu.add_item("Reset Game", MenuItems.RESET_GAME)
	menu.add_item("Get Hint", MenuItems.GET_HINT)
	menu.add_item("New Game", MenuItems.NEW_GAME)
	menu.add_item("Quit Game", MenuItems.QUIT_GAME)
	menu.hide_on_item_selection = false
	menu.id_pressed.connect(_on_id_pressed)

func _on_id_pressed(id):
	Log.pr("id: ", id)
	
	match id:
		MenuItems.NEW_GAME:
			EventHub.game.new_game.emit()
		MenuItems.RESET_GAME:
			EventHub.game.reset_game.emit()
