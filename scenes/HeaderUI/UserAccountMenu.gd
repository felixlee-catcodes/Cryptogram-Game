extends MenuButton
#@onready var settings = $"."
@onready var parent_node = $"."

enum MenuItems {
	USER, 
	SAVES, 
	RESET_STATS
}

const CUSTOM_THEME = preload("res://resources/Themes/popup_menu_custom.tres")
var menu : PopupMenu
var last_hint_time : float = 0.0
var hint_cooldown : float = 5.0

func _ready():
	button_pressed = false
	menu = get_popup()
	menu.theme = CUSTOM_THEME
	menu.add_separator("User", MenuItems.USER)
	menu.add_item("Saves", MenuItems.SAVES)
	menu.add_item("Reset Stats", MenuItems.RESET_STATS)
	

	menu.hide_on_item_selection = true
	menu.id_pressed.connect(_on_id_pressed)

func _on_id_pressed(id):
	match id:
		MenuItems.SAVES:
			TransitionManager.transition_to_scene("res://scenes/Carousel/Carousel.tscn", TransitionManager.transitions["square_grid_rotate"])
			#get_tree().change_scene_to_file("res://scenes/Carousel/Carousel.tscn")
		MenuItems.RESET_STATS:
			#var dialog : AcceptDialog = await create_dialog()
			#dialog.confirmed.connect(func():
				##quotebook.remove_entry(parent_node.card_data)
				#EventHub.inputs.update_archive.emit())
			EventHub.game.reset_game.emit()


#func create_dialog() -> AcceptDialog:
	#var confirmation : AcceptDialog = AcceptDialog.new()
	#confirmation.theme = CUSTOM_THEME
	#var theme_style = StyleBoxFlat.new()
	##theme_style.bg_color = ThemeManager.active_theme.basic_ui_color
	#confirmation.add_theme_stylebox_override("panel", theme_style)
	#confirmation.title = "Delete Card?"
	#confirmation.dialog_text = "Action cannot be undone"
	#confirmation.add_cancel_button("Cancel")
	#
	#parent_node.add_child(confirmation)
	#await get_tree().process_frame
	#
	#confirmation.popup()
	#await  get_tree().process_frame
	#
	#var parent_rect = parent_node.get_global_rect()
	#var parent_size = Vector2(parent_rect.size.x, parent_rect.size.y)
	#
	#var dialog_size = Vector2(confirmation.size.x, confirmation.size.y)
	#confirmation.position = parent_rect.position + (parent_size - dialog_size) / 2
	#
	#return confirmation
