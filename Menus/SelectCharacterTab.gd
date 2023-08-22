extends NinePatchRect

@export var characterid:String = "blondie"
#this is for new game


func _ready():
	update_data()

func update_data():
	var character = global.save.characters[characterid]
	var character_default = global.character_defaults[characterid]
	$portrait.texture = load("res://Content/images/" + characterid + ".tres")
	$select_button/Label.text = character.displayname
	$goldamount.text =  str(character.gold) + " gold"
	if global.settings.gameplayActiveQuirk: #active
		$description.text = character_default.description_active
	else:									#passive
		$description.text = character_default.description_passive
			#stats
	$hp_amount.text = str(character_default.hp + character.extra_hp) + "  HP"
	$atk_amount.text = str(character_default.attack + character.extra_attack) + "  ATK"

func select():
	global.current_player = {} #wipe current player first
	global.current_player = global.character_defaults[characterid].duplicate()
	get_tree().change_scene_to_file("res://Base/main.tscn")
	

func _process(delta):
	pass
