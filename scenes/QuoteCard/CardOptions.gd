extends MenuButton

@onready var edit_texture : Texture2D = preload("res://assets/ui-icons/edit_24dp.png")
@onready var delete_texture : Texture2D = preload("res://assets/ui-icons/delete_25dp.png")
@onready var parent_node : QuoteCard  = $".."
@onready var edit_tag_scene : PackedScene = preload("res://scenes/TagScene/EditTagsScene.tscn")

enum MenuItems {
	EDIT_TAGS, 
	DELETE_QUOTE
}

const CUSTOM_THEME := preload("res://resources/Themes/popup_menu_custom.tres")

var menu : PopupMenu
var quotebook : QuoteBook
func _ready():
	quotebook = QuoteBook.new().load_book()
	button_pressed = false
	menu = get_popup()
	menu.add_icon_item(edit_texture, "Edit tags", MenuItems.EDIT_TAGS)
	menu.add_icon_item(delete_texture, "Delete", MenuItems.DELETE_QUOTE)
	menu.hide_on_item_selection = true
	menu.id_pressed.connect(_on_id_pressed)

func _on_id_pressed(id):
	match id:
		MenuItems.EDIT_TAGS:
			var edit_tags_scene = await create_tag_scene()
		MenuItems.DELETE_QUOTE:
			var dialog : AcceptDialog = await create_dialog()
			dialog.confirmed.connect(func():
				quotebook.remove_entry(parent_node.card_data)
				EventHub.inputs.update_archive.emit())

func create_tag_scene() -> EditTagsScene:
	var tag_scene : EditTagsScene = edit_tag_scene.instantiate()
	tag_scene.entry_data = parent_node.card_data
	parent_node.add_child(tag_scene)
	
	tag_scene.popup()
	await  get_tree().process_frame
	
	var parent_rect = parent_node.get_global_rect()
	var parent_size = Vector2(parent_rect.size.x, parent_rect.size.y)
	
	var dialog_size = Vector2(tag_scene.size.x, tag_scene.size.y)
	tag_scene.position = parent_rect.position + (parent_size - dialog_size) / 2
	return tag_scene

func create_dialog() -> AcceptDialog:
	var confirmation : AcceptDialog = AcceptDialog.new()
	confirmation.theme = CUSTOM_THEME
	var theme_style = StyleBoxFlat.new()
	#theme_style.bg_color = ThemeManager.active_theme.basic_ui_color
	confirmation.add_theme_stylebox_override("panel", theme_style)
	confirmation.title = "Delete Card?"
	confirmation.dialog_text = "Action cannot be undone"
	confirmation.add_cancel_button("Cancel")
	
	parent_node.add_child(confirmation)
	await get_tree().process_frame
	
	confirmation.popup()
	await  get_tree().process_frame
	
	var parent_rect = parent_node.get_global_rect()
	var parent_size = Vector2(parent_rect.size.x, parent_rect.size.y)
	
	var dialog_size = Vector2(confirmation.size.x, confirmation.size.y)
	confirmation.position = parent_rect.position + (parent_size - dialog_size) / 2
	
	return confirmation
