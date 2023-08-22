extends RichTextLabel

var overtime:bool = false

func _ready():
	pass



func _process(delta):
	if overtime:
		position.y -= 0.3
		modulate.a -= 0.02
	else:
		position.y -= 0.4
		modulate.a -= 0.013

	if modulate.a <= 0:
		queue_free()
