extends NinePatchRect

@export var callednode := "main"
@export var displaytext := "Button"
@export var buttonfunction := "new_field"


var hovered:bool = false
var Main_node #what the fuck am I doing 

func _ready():
	if callednode == "main": Main_node = get_tree().get_root().get_node("Main")
	$Area2D/CollisionShape2D.scale = size
	$Area2D/CollisionShape2D.position = size / 2
	$Label.text = displaytext
	$hovered.size = size


func _process(delta):
	if hovered:
		if Input.is_action_just_released("leftclick"):
			if callednode == "main":
				Main_node.call_deferred(buttonfunction)
			if callednode == "parent":
				get_parent().call_deferred(buttonfunction)


func _on_area_2d_mouse_exited():
	if callednode == "main": Main_node.ui_hovered = false
	hovered= false
	$hovered.visible = false


func _on_area_2d_mouse_entered():
	if callednode == "main": Main_node.ui_hovered = true
	hovered = true
	$hovered.visible = true
