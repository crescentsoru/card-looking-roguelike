extends Node2D

var frame:= 0

var speed := 0.7
var held_multiplier:= 2.5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("A") or Input.is_action_pressed("leftclick") or Input.is_action_pressed("ability"):
		held_multiplier = 2
	else:
		held_multiplier = 1
	
	for x in get_children():
		x.position.y -= speed * held_multiplier

	frame+=1*held_multiplier
	if $Cake.position.y <= 0: get_tree().change_scene_to_file("res://Menus/MainMenu.tscn")
	
