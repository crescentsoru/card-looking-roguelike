extends Node

var level_queue:Array[String] = ["Start", "Hyde", "Friday", "Busters", "Action", "MacintoshKid", "Future", #Tutorials except MacintoshKid
"Karate","Castletwo", "Chicken", "MacintoshKid2", "NoGang", 
"Rest1", "Karate2", "Chicken2", "NoGang2", "FridayAlt2", 
"Rest2","Chicken3", "Karate3", "FridayAlt3", "NoGang3", "Hyde3",
"Rest3", ]




var save:Dictionary={ #gamesave
				characters = {
		blondie={
			displayname = "Thief",

			gold = 0,
			extra_hp = 0,
			extra_attack = 0,
			completed = false,
		}, #blondie end
		barbara={
			displayname = "Barbarian",

			gold = 0,
			extra_hp = 0,
			extra_attack = 0,
			completed = false,
			}, #barbara end
		vi={
			displayname = "Chemist",

			gold = 0,
			extra_hp = 0,
			extra_attack = 0,
			completed = false,
			}, #vi end
		yari={
			displayname = "Guardian",

			gold = 0,
			extra_hp = 0,
			extra_attack = 0,
			completed = false,
			}, #yari end
				}, #characters end
	
	
	dead = false, #if true, then you just died and you can't use Continue. Not used
	deaths = 0,
	
								} #save end 

var save_default:Dictionary = {} #saved at the start of every game 


##When new level is loaded, the Player on the field is saved into this var and then loaded through the playermarker system
var current_player:Dictionary = {}

var nextlevel := ""

const character_defaults:Dictionary = {
							"blondie": {
	unitname = "Thief",
	unitid = "blondie",
	characterid = "blondie",
	description = "It's you!",
	type = "player",
	hp = 11,
	hp_max = 11,
	
	attack = 2,
	
	ability_cooldown = 4,
	ability_cooldown_max = 4,
	ability_name = "Ability: Finesse",
	
	dodge_chance = 15,
	
	
	movement = 1.0,
	description_passive = "+Chance to find extra gold\n+Chance to open locked doors once per level\n+Chance to dodge attacks",
	description_active = "+Passive: Earn more gold occasionally\n+Finesse: Unlock doors and strikes enemies while dodging all damage",
									},
	
							"barbara": {
	unitname = "Barbarian",
	unitid = "barbara",
	characterid = "barbara",
	description = "It's you!!",
	type = "player",
	hp = 14,
	hp_max = 14,
	attack = 1,
	movement = 1.0,
	
	ability_cooldown = 6,
	ability_cooldown_max = 6,
	ability_name = "Ability: Bandit Swing",
	
	description_passive = "+Get one more use out of weapons\n+Chance to hit +3 damage\n+Get double healing from food",
	description_active = "+Passive: Get one more use out of weapons\n+Bandit Swing: Double damage melee, recover 3 cooldown points on kill",
								},
	
							"vi": {
	unitname = "Chemist",
	unitid = "vi",
	characterid = "vi",
	description = "It's you!!~",
	type = "player",
	hp = 10,
	hp_max = 10,
	attack = 1,
	movement = 1.0,
	
	

	ability_cooldown = 8,
	ability_cooldown_max = 8,
	ability_name = "Ability: Weakness Potion",
	
	
	description_passive = "+More healing from Potions\n+Chance for enemies to drop Potions on death\n+Maximum loot from Backpacks",
	description_active = "+Passive: More healing from Potions and maximum loot from Backpacks\n+Weakness Potion: Absorb max health from slain enemies",
								},
	
								"yari": {
	unitname = "Guardian",
	unitid = "yari",
	characterid = "yari",
	description = "It's you!!~~",
	type = "player",
	hp = 12,
	hp_max = 12,
	attack = 1,
	movement = 1.0,
	campfire_protection = true,
	
	ability_cooldown = 6,
	ability_cooldown_max = 6,
	ability_name = "Ability: Pierce",
	
	
	description_passive = "+Campfires spawn less enemies\n+Doesn't take first damage from Ghosts\n+Chance to pierce through enemy",
	description_active = "+Passive: Campfires spawn less enemies, no first damage from Ghosts\n+Pierce: Damage through adjacent enemy with +1 damage",
								},
	
	}




var settings = {
	mixMaster = 100,
	mixSound = 100,
	mixMusic = 100,
	fullscreen = false,
	
	#Don't bother with these
	qolDontWasteItem = true,
	qolNoVoidCard = true,
	gameplayActiveQuirk = true,
	}

##Used for names for the options in gameplay settings. I axed that feature and menu so ignore this 
const settings_labels := {
	
	
	qolDontWasteItem = "Don't waste healing items when picked up at full health",
	qolNoVoidCard = "Remove void card at the edge of levels",
	gameplayActiveQuirk = "Character quirks are activated by the Ability Button instead of passively",
	}



func _ready():
	save_default = save.duplicate(true) #a default is needed for when you're wiping saves 
	load_user_setting()
	load_gamesave()
	setbusvolumes()
	if settings.fullscreen: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _process(delta):
	pass

#Audio

func to_db(input:int) -> float:
	if input == 0:
		return -9999.0 #mute
	else:
		return linear_to_db(input/100.0)


func setbusvolumes():
	bus_to_db("Master",settings.mixMaster)
	bus_to_db("Music",settings.mixMusic)
	bus_to_db("Sound",settings.mixSound)

func bus_to_db(bus:String,volume):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), to_db(volume) )

func save_user_setting():
	var savefile = FileAccess.open('user://settings.cfg', FileAccess.WRITE)
	var save_as_json = JSON.stringify(settings)
	
	savefile.store_string(save_as_json)
	savefile.close()

func load_user_setting():
	if !FileAccess.file_exists("user://settings.cfg"): #if no setting file exists, create one from default values
		save_user_setting()
	var loadfile = FileAccess.open('user://settings.cfg', FileAccess.READ)
	var parsed_json = JSON.parse_string(loadfile.get_as_text())

	settings.merge(parsed_json,true)
	loadfile.close()

		#############CHARACTER CODE

func save_gamesave():
	var savefile = FileAccess.open('user://gamesave.cfg', FileAccess.WRITE)
	var save_as_json = JSON.stringify(save)
	
	savefile.store_string(save_as_json)
	savefile.close()

func load_gamesave():
	if !FileAccess.file_exists("user://gamesave.cfg"): #if no gamesave file exists, create one from default values
		save_gamesave()
	var loadfile = FileAccess.open('user://gamesave.cfg', FileAccess.READ)
	var parsed_json = JSON.parse_string(loadfile.get_as_text())
	save.merge(parsed_json,true)
	loadfile.close()

func wipe_gamesave():
	if !FileAccess.file_exists("user://gamesave.cfg"):
		return
	var loadfile = FileAccess.open('user://gamesave.cfg', FileAccess.READ)
	var clearfile = JSON.stringify(save_default)
	loadfile.store_string(clearfile) #wipe on-disk data first
	save = save_default.duplicate(true) #wipe ram data after
	loadfile.close()


		##LEVEL QUEUE

func current_level_queue(input:String) -> int:
	for x in len(level_queue):
		if level_queue[x] == input:
			return x
	return -1

func next_level(input:String) -> String:
	var current = current_level_queue(input)
	if current+1 <= len(level_queue) -1:
		return level_queue[current+1]
	else:
		return "end" #activates title crawl?? 


func extra_atk(char:String) -> int:
	return (save.characters[char].extra_attack)


func extra_hp(char:String) -> int: 
	return (save.characters[char].extra_hp)



##Amount is how many times it had been upgraded before. 
func get_upgrade_cost(amount:int,multiplier:float = 1.2, base_cost:int = 10,) -> int:
	var result:float = float(base_cost)
	for x in amount:
		result = result * multiplier
	
	return int(result)

#Adds gold and updates the gamesave file
func add_gold(characterid:String,amount:int):
	save["characters"][characterid]["gold"]+= amount
	save_gamesave()
