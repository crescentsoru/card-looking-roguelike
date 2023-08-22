extends NinePatchRect

@export var settingname = ""


func _ready():
	pass


func update_visual():
	$Button/Label.text = on_off(global.settings[settingname])
	$Label.text = global.settings_labels[settingname]
	if global.settings[settingname]:
		$Button.self_modulate = Color(1,1,1,1)
	else:
		$Button.self_modulate = Color(1,0.7607,0.6313,1)


##returns "ON" when true and "OFF" when false
func on_off(input:bool) -> String:
	if input: return "ON"
	else: return "OFF"

func flipsetting():
	global.settings[settingname] = ! global.settings[settingname] #flips bool
	global.save_user_setting()
	update_visual()



func _process(delta):
	pass
