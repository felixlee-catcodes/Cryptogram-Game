extends TextureButton
## KEYBOARD BUTTON

@export var unpressed_png : Texture2D

@export var pressed_png : Texture2D

@export var key : String

func _ready():
	EventHub.inputs.input_changed.connect(_on_input_changed)
	EventHub.inputs.simulate_input.connect(_on_simulate_input)
	texture_normal = unpressed_png
	texture_pressed = pressed_png
	scale = Vector2(3,3)
	add_to_group("virtual_buttons")


func reset_button() -> void:
	self.button_pressed = false


func _on_simulate_input(_key):
	if self.key == _key:
		button_pressed = true

func _on_pressed():
	if self.key == "Clear" or self.key == "Right" or self.key == "Left":
		EventHub.keys.keyboard_input.emit(key)
		return


func _on_input_changed(key):
	if self.key == key:
		button_pressed = false

func _on_toggled(toggled_on):
	if toggled_on and not Input.is_physical_key_pressed(OS.find_keycode_from_string(key)):
		EventHub.keys.keyboard_input.emit(key)
	elif not toggled_on: button_pressed = false
	
