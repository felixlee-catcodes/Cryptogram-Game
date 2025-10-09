extends PanelContainer
@onready var texture_rect = $VBoxContainer/TextureRect
@onready var label = $VBoxContainer/Label

func _ready():
	texture_rect.pivot_offset = size / 2
	scale_elements()

func scale_elements() -> void:
	var scale_tween : Tween = create_tween()
	scale_tween.tween_property(texture_rect, "scale", Vector2(1.3, 1.3), 1.0)
	scale_tween.tween_property(texture_rect, "scale", Vector2(1.0, 1.0), 0.8)
	
	
	#var modulate_text : Tween = create_tween()
	#modulate_text.tween_property(label, "self_modulate", Color.CHARTREUSE, 1.0)
	#modulate_text.tween_property(label, "self_modulate", Color.WHITE, 0.5)
