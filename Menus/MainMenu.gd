extends Node2D
# gREEAAGARAHARARHH!!! I HATE UIUX CODE!!!!! BOOOOOO!!!!!!!!!!!
var ui_hovered:bool = false
var overlay_opened = false


func _ready():
	pass



func _process(delta):
	pass



func continuegame():
	if FileAccess.file_exists("user://savestate.cdlevel"):
		global.nextlevel = "savestate"
		get_tree().change_scene_to_file("res://Base/main.tscn")



func exit():
	global.save_user_setting()
	#insert save meta savefile here
	
	get_tree().quit()



func open_settings():
	if overlay_opened:
		for x in get_children():
			if x.name == "Settings": ##if close_windows() and spawn_() are refactored this line can be a node name check. However, for that to work well the filename and root node name would need to be the same
				close_windows()
				overlay_opened = false
				return
		close_windows() #this and VVV only happen if no Settings node is found, i.e. a different window is open
		spawn_settings() 
	else:
		spawn_settings()

func open_upgrade():

	if overlay_opened:
		for x in get_children():
			if x.name == "Upgrade":
				close_windows()
				overlay_opened = false
				return
		close_windows() 
		spawn_upgrade() 
	else:
		spawn_upgrade()

func open_selectcharacter():
	if overlay_opened:
		for x in get_children():
			if x.name == "Select": 
				close_windows()
				overlay_opened = false
				return
		close_windows() 
		spawn_selectcharacter()
	else:
		spawn_selectcharacter()

func open_gameplaysettings():
	if overlay_opened:
		for x in get_children():
			if x.name == "GameplaySettings":
				close_windows()
				overlay_opened = false
				return
		close_windows()
		spawn_gameplaysettings()
	else:
		spawn_gameplaysettings()




func close_windows():
	for x in get_children():
		#this isn't great to do, a more "correct" solution would be creating a class name for UI windows and checking that
		if x.name == "Settings" or x.name == "Upgrade" or x.name == "Select" or x.name == "GameplaySettings": #but I committed to this so keeping it is faster
			x.close()

				# VV V V All of these could be refactored into a single spawn_uiwindow() with a String input

func spawn_settings():
	var settings = preload("res://Menus/Settings.tscn").instantiate()
	add_child(settings)
	settings.position = Vector2(20,8)
	overlay_opened = true
func spawn_upgrade():
	var upgrade = preload("res://Menus/Upgrade.tscn").instantiate()
	add_child(upgrade)
	upgrade.position = Vector2(20,8)
	overlay_opened = true

func spawn_selectcharacter():
	var select = preload("res://Menus/SelectCharacter.tscn").instantiate()
	add_child(select)
	select.position = Vector2(20,8)
	overlay_opened = true


func spawn_gameplaysettings():
	var gameplaysettings = preload("res://Menus/GameplaySettings.tscn").instantiate()
	add_child(gameplaysettings)
	gameplaysettings.position = Vector2(20,8)
	overlay_opened = true
	
