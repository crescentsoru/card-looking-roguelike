extends Sprite2D


var actionframe:=0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	actionframe += 1
	
	if actionframe <= 25:
		position.y -= 1
	
	if actionframe > 30:
		modulate.a -= 0.04
	
	if modulate.a <= 0: queue_free()
