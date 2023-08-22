extends AudioStreamPlayer
var currentfile:String = "yuzu.ogg"

func _ready():
	pass 

func _process(delta):
	if !playing:
		play()
