extends TextureButton

@export var unpressed_png : Texture2D

@export var pressed_png : AtlasTexture

@export var key : String = ""

func _ready():
	texture_normal = unpressed_png
	texture_pressed = pressed_png
	scale = Vector2(3,3)
