extends Node

@export var typing_sfx_stream: AudioStream


func play_typing():
	var p = AudioStreamPlayer.new()
	p.stream = typing_sfx_stream
	
	add_child(p)
	
	# vary pitch:
	p.pitch_scale = randf_range(0.90, 1.10)
	p.volume_linear = 0.08
	p.play()
	p.finished.connect(func(): p.queue_free())
