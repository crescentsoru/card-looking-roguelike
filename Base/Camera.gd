extends Camera2D

var target_position:Vector2 = Vector2(321,180)
var max_distance:int = 5 #the distance the camera will keep away from the center of the target pos
var deadzone:Vector2 = Vector2(0,0) #if the distance is less than this when update_target() is called, don't bother. doesnt work
var normal:Vector2 = Vector2(0,0)
var speed:int = 6 #position change per frame

@onready var Main_node = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_target(pos:Vector2):
	pass
	##+V2(100,0) is meant to roughly represent the amount of space is taken up by the UI 
	if ((pos+Vector2(100,0)) - position).x > deadzone.x or (pos-position).y > deadzone.y:
		target_position = pos
		normal = (pos - position).normalized()


func _process(delta):
	if position.distance_to(target_position) > max_distance:
		position += normal * speed
