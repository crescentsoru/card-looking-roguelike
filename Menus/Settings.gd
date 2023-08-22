#Used for Settings and Upgrades. Differentiated by the name of the node. 

extends NinePatchRect

@onready var Main_node = get_parent().get_parent()


func _ready():
	if name == "Settings":
		$mixMaster.value = global.settings.mixMaster
		$mixMusic.value = global.settings.mixMusic
		$mixSound.value = global.settings.mixSound
		if !get_parent().name == "CanvasLayer": #if this is created in main menu,
			get_node("ToMainMenu").queue_free() #no reason to have a button to go back to main menu 
	if name == "GameplaySettings":
		draw_gameplay_bools()
		
	if name == "Upgrade":
		pass


func save_settings():
	global.settings.mixMaster = $mixMaster.value
	global.settings.mixMusic = $mixMusic.value
	global.settings.mixSound = $mixSound.value


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		close()
	if Input.is_action_just_pressed("fullscreen"):
		fullscreen()
	if name == "Settings":
		global.setbusvolumes()
		save_settings()



func close():
	global.save_user_setting()
	if get_parent().name =="Main":
		get_parent().overlay_opened = false
	else:
		Main_node.overlay_opened = false
	queue_free()

func fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		global.settings.fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		global.settings.fullscreen = false


func goto_main_menu():
	if get_parent().name != "Main": #if in-game. very hacky but theres no expectations of this being used elsewhere 
		Main_node.savestate()
		get_tree().change_scene_to_file("res://Menus/MainMenu.tscn")


func wipe_firstclick():
	$wipesave/Label.text = "Are you sure? Press again to confirm."
	$wipesave.self_modulate = Color(0.9,0.1607,0.1313,1)
	$wipesave/hovered.self_modulate = Color(1,0.2607,0.2313,1)
	$wipesave.buttonfunction = "wipe_secondclick"

func wipe_secondclick():
	global.wipe_gamesave()
	$wipesave.self_modulate = Color(1,0.7607,0.6313,1)
	$wipesave/hovered.self_modulate = Color(1,1,1,1)
	$wipesave/Label.text = "Success. Gold and upgrade progress is reset."
	$wipesave.buttonfunction = "wipe_firstclick"

func draw_gameplay_bools(optionList:Array= ["qolDontWasteItem","qolNoVoidCard","gameplayActiveQuirk"]):
	var pos = Vector2(2, 24)
	for x in optionList:
		
		var boolsettingnode = preload("res://Menus/BoolSettingTrigger.tscn").instantiate()
		add_child(boolsettingnode)
		boolsettingnode.position = pos
		boolsettingnode.settingname = x
		boolsettingnode.update_visual()
		pos.y += 42
