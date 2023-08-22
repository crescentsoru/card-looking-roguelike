extends NinePatchRect

@export var characterid:String = "blondie"



func _ready():
	update_data()

func update_data():
	var character = global.save.characters[characterid]
	var character_default = global.character_defaults[characterid]
	$charactername.text = character.displayname
	$portrait.texture = load("res://Content/images/" + characterid + ".tres")
	$goldamount.text =  str(character.gold) + " gold"
			#stats
	var hp_cost:int = global.get_upgrade_cost(character.extra_hp)
	$hp_amount.text = str(character_default.hp + character.extra_hp) + "  HP"
	$hp_button/Label.text = str(hp_cost) + "g"
	if hp_cost > character.gold: $hp_button/Label.add_theme_color_override("font_color",Color(1,0.1,0.1)) #red if cant buy
	else: $hp_button/Label.add_theme_color_override("font_color",Color(1, 0.95, 0))

	var atk_cost:int = global.get_upgrade_cost(character.extra_attack)
	$atk_amount.text = str(character_default.attack + character.extra_attack) + "  ATK"
	$atk_button/Label.text = str(atk_cost) + "g"
	if atk_cost > character.gold: $atk_button/Label.add_theme_color_override("font_color",Color(1,0.1,0.1)) #red if cant buy
	else: $atk_button/Label.add_theme_color_override("font_color",Color(1, 0.95, 0))


func buy_hp():
	var character = global.save.characters[characterid]
	var hp_cost = global.get_upgrade_cost(character.extra_hp)
	if hp_cost <= character.gold:
		character.gold-= hp_cost
		character.extra_hp+=1
		update_data()
	global.save_gamesave()


func buy_atk():
	var character = global.save.characters[characterid]
	var atk_cost = global.get_upgrade_cost(character.extra_attack)
	if atk_cost <= character.gold:
		character.gold-= atk_cost
		character.extra_attack+=1
		update_data()
	global.save_gamesave()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
