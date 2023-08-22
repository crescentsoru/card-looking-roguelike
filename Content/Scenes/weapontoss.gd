extends Sprite2D

var direction := Vector2(1,0)
var speed:= 3.3
var range:= 3.0
var actionframe:= 0

func _ready():
	pass # Replace with function body.



func _process(delta):
	actionframe+=1
	if actionframe > 13:
		modulate.a -= 0.12
	position+= direction * speed * range
	if modulate.a <= 0: queue_free()
