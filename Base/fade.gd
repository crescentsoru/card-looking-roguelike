extends Sprite2D

var state := "fadein"
var fadespeed := 0.05


func _ready():
	visible = true

func fadein(speed:float = 0.05):
	fadespeed = speed
	modulate.a = 1
	state = "fadein"

func fadeout(speed:float = 0.06):
	fadespeed = speed
	modulate.a = 0
	state = "fadeout"


func _process(delta):
	match state:
		"light":pass
		"fadein":
			modulate.a -= fadespeed
			if modulate.a <= 0: state = "light"
		"fadeout":
			modulate.a += fadespeed
			

