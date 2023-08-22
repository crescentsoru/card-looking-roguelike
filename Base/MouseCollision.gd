extends Area2D

var hovered = false

##Used for passing the value to Main_node so it can check if a tile is boopable or not
@export var deltapos:Vector2i = Vector2i(0,0)


func _process(delta):
	var Main_node = get_parent().get_parent()
	if hovered:

		if Input.is_action_just_released("leftclick") and !Main_node.editor_mode and !Main_node.overlay_opened and !Main_node.ui_hovered:
			if name != "middle":
				Main_node.input_queue.append(name)



func _on_mouse_entered():
	hovered = true
	if !get_parent().get_parent().boopable(deltapos) and !get_parent().get_parent().overlay_opened:
		$glow.visible = true
		$borderGlowing.visible = true

func _on_mouse_exited():
	hovered = false
	$glow.visible = false
	$borderGlowing.visible = false
