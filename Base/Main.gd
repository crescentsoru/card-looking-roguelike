extends Node2D

				#####SAVEFILE
##The "ground" which contains empty tiles and item/weapon cards
var field:Array = []

##Player and enemy cards
var units:Array = []

var hiddentiles:Array = []


##Other misc saved settings in the file
var level_settings:Dictionary = {
	playerposX = -1,
	playerposY = -1,
	
	
	#All of the random_ vars only do something when developer_mode is false
	random_items = 0, #amount of random items, excludes gold
	random_units = 0, #amount of enemy units put in random tiles around the level
	random_gold = 0, #gold tiles. Just the 5 gold tile, not all tiles that add gold
	random_coins = 0, #coin tiles
	random_custom = [], #cards in this list will be randomly placed 
	difficulty = 5, #determines the level of ALL units on screen regardless if they're manually placed or randomized
	
	
	door_type = "locked", #locked, free
	doorX = -1, #if not -1, door coords will be spawned in when all enemies are slain 
	doorY = -1,
	doorfilename = "next", 
	
	savestate = false,
	
	}
#door types-
#none lets you go through a door as long as you walk into one.
#spawn creates a door at doorX,doorY coordinates when all enemies are slain.
#locked doesn't let you go through doors until all enemies are slain. 


		##GENERATION
##for custom random cards
var string2dictref = {
	"cake" : Tile_Cake,
	"ham" : Tile_Ham,
	"potion" : Tile_Potion,
	"elixir": Tile_Elixir,
	"coin" : Tile_Horseshoe,
	"gold" : Tile_Gold,
	"knife" : Tile_Knife,
	"hammer" : Tile_Hammer,
	"staff" : Tile_Staff,
	"axe" : Tile_Axe,
	"cutlass" : Tile_Cutlass,
	"sword" : Tile_Sword,
	#units
	"hamzilla" : Unit_Hamzilla,
	"kithullu" : Unit_Kithullu,
	"stool" : Unit_Stool,
	"stump" : Unit_Stump,
	"fatchick" : Unit_FatChick,
	"punchrat" : Unit_PunchRat,
	"eyefly" : Unit_EyeFly,
	"mimic" : Unit_Mimic,
	
	}


##Makes the current grid an "empty" grid with normal tiles.
func empty_field(extentX,extentY): 
	field = []
	for x in extentX:
		field.append([])
	for x in len(field):
		for y in extentY:
			var row = field[x]
			var newtile = Tile_default.duplicate(true) #duplicate is used because doing an = makes it a ref rather than copy
			row.append(newtile)
			row[y].positionX = x
			row[y].positionY = y

func update_tile_position(pos:Vector2):
	for x in len(field):
		for y in len(field[0]):
			if Vector2(pos.x,pos.y) == Vector2(x,y):
				field[x][y].positionX = pos.x
				field[x][y].positionY = pos.y




##Empty units array with the same size as field
func initialize_units():
	units = []
	for x in len(field):
		units.append([])
	for x in units:
		for y in len(field[0]):
			x.append(null)

##Based on the extents provided by editor UI 
func new_field():
	var split:PackedStringArray = $CanvasLayer/EditorUI/extents.text.split(",")
	if len(split) < 2:
		battleprint("Completely invalid dimensional input.")
		return
	var ext: = Vector2i(int(split[0]),int(split[1]))
	if ext.x == 0 or ext.y == 0:
		battleprint (str(ext) + " is an invalid dimensional input.")
		return
	empty_field(ext.x,ext.y)
	initialize_units()
	search_player()
	generate_cards()

			########################
######################TILE CODE#####
			########################
##Returns a merge of the default Tile dictionary and the tile parameter.
##Default tile is copied, then input values are written over that copy
func instance_tile(tile:Dictionary):
	var result = Tile_default.duplicate(true)
	result.merge(tile,true)
	return result

##Does the above + updates internal position, use this instead
func tile_at(tile:Dictionary, pos:Vector2):
	field[pos.x][pos.y] = instance_tile(tile)
	update_tile_position(pos)

				##TILE DATA
const Tile_default = {
	tilename = "",
	tileid = "empty", #id for visuals
	editorid = "Tile_default", #wip
	type = "floor", #floor, empty, heal, gold, weapon, chest
	description = "An empty tile.",
	hp = -1, #when hp or attack are -1, don't show that number in the corner of the card
	attack = -1, #attack, or gold amount for gold
	heals_overtime = false,

	ambush_chance = 0, #spawns enemies around you, used for campfire 
	delete_on_use = true, #if false, doesn't delete itself when stepped on as a heal item 
	
	positionX = -1, positionY = -1, #for clicking to move and Infinite scrolling 
}

const Tile_Void = {
	tilename = "VOID",
	tileid = "empty",
	type = "void",
	description = "An empty tile.",
	hp = 0,
	attack = 0,
	heals_overtime = false,
	
	positionX = -1, positionY = -1,
}

const Tile_Door = { 
	tilename = "Door",
	tileid = "door",
	type = "door",
	description = "A door to the next level.",
	filename = "test", #can also be 'next' which runs a custom queue
	hp = 0, attack = 0, 
	
	}

	#ITEMS


const Tile_ChestClosed = {
	tilename = "Harvest Scroll",
	tileid = "ChestClosed", 
	type = "chest",
	hp = 0,
	attack = 0, 
}

const Tile_ChestOpened = {
	tilename = "Useless Scroll",
	tileid = "ChestOpened", 
	type = "floor",
	hp = -1,
	attack = -1, 
}

const Tile_Cake:Dictionary = {
	tilename = "Strawberry",
	tileid = "Cake", 
	type = "heal", 
	hp = 5,
	attack = 0,
	heals_overtime = true,
	}

const Tile_Ham:Dictionary = {
	tilename = "Ham",
	tileid = "Ham", 
	type = "heal", 
	hp = 7,
	attack = 0,
	heals_overtime = true,
	}

const Tile_Potion:Dictionary = {
	tilename = "Potion",
	tileid = "Potion",
	type = "heal",
	hp = 10,
	attack = 0,
	heals_overtime = false,
	}


const Tile_Elixir:Dictionary = {
	tilename = "Buff Rune",
	tileid = "Elixir",
	type = "elixir",
	hp = 1,
	attack = 1,
	heals_overtime = false,
	}

const Tile_Campfire:Dictionary = {
	tilename = "Fountain",
	tileid = "CampFire", 
	type = "heal", 
	hp = 99,
	attack = 0,
	delete_on_use = false,
	ambush_chance = 100,
	ambush_amount = 1, #increases each time campfire is used
	heals_overtime = false,
	}

const Tile_Backpack:Dictionary = {
	tilename = "Item Box",
	tileid = "BackPack", 
	type = "chest", 
	hp = 0,
	attack = 0,
	delete_on_use = true,
	heals_overtime = false,
	}

#yes this used to be a horseshoe but the sprite got changed to coins 
const Tile_Horseshoe:Dictionary = {
	tilename = "Coins",
	tileid = "SolidLuck",
	type = "gold",
	hp = 0,
	attack = 1,
	heals_overtime = false,
	}


const Tile_Gold:Dictionary = {
	tilename = "Treasure Ring",
	tileid = "Gold",
	type = "gold",
	hp = 0,
	attack = 5,
	heals_overtime = false,
	}


	#WEAPONS
const Tile_Knife:Dictionary = {
	tilename = "Knife",
	tileid = "Knife", 
	type = "weapon", 
	hp = 1,
	attack = 2,
	}

const Tile_Hammer:Dictionary = {
	tilename = "Hammer",
	tileid = "Hammer", 
	type = "weapon", 
	hp = 0,
	attack = 5,
	}

const Tile_Staff:Dictionary = {
	tilename = "Staff",
	tileid = "MasterStaff", 
	type = "weapon",
	hp = 3, #cause its magic idk 
	attack = 0,
	}

const Tile_Axe:Dictionary = {
	tilename = "Throwing axe",
	tileid = "Axe", 
	type = "weapon", 
	hp = 2, 
	attack = 2,
	}

const Tile_Cutlass:Dictionary = {
	tilename = "Cutlass",
	tileid = "Cutlass", 
	type = "weapon",
	hp = 1,
	attack = 3,
	}

const Tile_Sword:Dictionary = {
	tilename = "Throwbow",
	tileid = "LongSword", 
	type = "weapon",
	hp = 0,
	attack = 6,
	}








		######REMDERING

var card_margins := Vector2(4,4)


func card_position_formula(input:Vector2):
	return ( Vector2(32,48) + card_margins ) + (Vector2(64,96) + card_margins) * Vector2(input.x,input.y) 

var uid_next := 0 #the uid of the next created unit

##Generates the entire area 
func generate_cards():
	for x in get_node("Tiles").get_children():
		x.queue_free() #delete existing cards first1
	for x in get_node("Units").get_children():
		x.queue_free()

			##TILE LAYER
	for x in len(field):
		for y in len(field[0]):
			var tile = field[x][y]
			var cardload := preload("res://Base/CardTile.tscn")
			var card = cardload.instantiate() 
			get_node("Tiles").add_child(card)
			card.position = card_position_formula(Vector2(x,y))
			#Making cards unique
			card.positionX = x
			card.positionY = y
			card.update_visuals()
			#Adding collision to cards for editor mode (not adding them speeds up the game)
			if developer_mode:
				var cardcollision = preload("res://Base/CardCollision.tscn").instantiate()
				card.add_child(cardcollision)
			
			##UNIT LAYER
#	var uid:int = 0 #Every unit card has a UID to track movements more easily 
	for x in len(units):
		for y in len(units[0]):
			var unit = units[x][y]
			if unit != null:
				generate_card_by_pos(x,y)

func generate_card_by_pos(posX:int,posY:int):
	var unit = units[posX][posY]
	var cardload := preload("res://Base/CardUnit.tscn")
	var card = cardload.instantiate()
	get_node("Units").add_child(card)
	card.position = card_position_formula(Vector2(posX,posY))

	card.originalpos = card.position
	#Making cards unique
	card.uid = uid_next
	unit.uid = uid_next
	uid_next+=1
	card.positionX = posX
	card.positionY = posY
	card.update_visuals()

func delete_card_by_pos(posX:int,posY:int):
	var pos:Vector2i = Vector2i(posX,posY)
	for x in $Units.get_children():
		if pos == Vector2i(x.positionX,x.positionY):
			x.queue_free()
	uid_next +=1 

##Deletes card and creates a card on the same spot
func update_card_by_pos(posX:int,posY):
	delete_card_by_pos(posX,posY)
	generate_card_by_pos(posX,posY)




						####UNITS

func instance_unit(unit:Dictionary,level:int=1):
	var result = Unit_default.duplicate(true)
	result.merge(unit,true)
	var newhp = float(result.hp)
	var newatk = float(result.attack)
	result.level = level
	if level > 1: #so walls and voids couldn't have even more levels 
		newhp = newhp * (0.75 * (level) )
		newatk = newatk * (0.75 * (level) )
	result.hp = int(newhp)
	result.attack = int(newatk)
	return result

##Does the above + updates internal position, use this instead. This is used both for moving and creating units 
func unit_at(unit:Dictionary, pos:Vector2,level:int=1):
	
	units[pos.x][pos.y] = instance_unit(unit,level)
	update_unit_position(pos)

##Creates a visual card after unit_at(). Do not use this to move units it'll get fucky
func unit_create(unit:Dictionary,pos:Vector2,level:int=1):
	unit_at(unit,pos,level)
	generate_card_by_pos(pos.x,pos.y)

func update_unit_position(pos:Vector2):
	for x in len(units):
		for y in len(units[0]):
			if Vector2(pos.x,pos.y) == Vector2(x,y):
				units[x][y].positionX = pos.x
				units[x][y].positionY = pos.y
				



#for level editor to make sure there isn't more than one player unit 
func erase_player():
	for x in len(units): for y in len(units[0]):
		if units[x][y] == Player:
			units[x][y] = null
			delete_card_by_pos(x,y)

func check_enemy_presence() -> bool:
	for x in len(units):
		for y in len(units[0]):
			if units[x][y] != null: #this here's the reason why I regret making units dict a grid, gotta do this every time 
				if units[x][y].type == "enemy":
					return true
	return false


				####UNIT DATA
var Player := {} #this is the REFERENCE to the Player card on the board

const Unit_default:Dictionary = {
	unitname = "default",
	unitid = "default", #visuals
	description = "default description",
	type = "enemy", #player, enemy
	hp = 1,
	hp_max = 1, #player
	hp_overtime = 0, #player
	attack = 1,
	movement = 0.0,
	mimic = false, #annoying to implement otherwise 
	level = 1, #for display purposes
	
		#character specifics
		
	#ability
	ability_cooldown = 0,
	ability_cooldown_max = 5,
	
	
	#Blondie
	dodge_chance = 0,
	unlock_attempted = false, #checked through character_id, just like extra gold chance 
	
	#Yari
	campfire_protection = false,
	
	
	
	positionX=-1, positionY=-1,
	uid = -1,
	}

const Unit_Player:Dictionary = {
	unitname = "Player",
	unitid = "blondie",
	characterid = "blondie",
	description = "It's you!",
	type = "player",
	hp = 10,
	hp_max = 10,
	
	attack = 1,
	movement = 1.0,
	
	}

const Unit_Hamzilla:Dictionary = {
	unitname = "Beetle",
	unitid = "Hamzilla",
	type = "enemy",
	hp = 1,
	attack = 1,
	}

const Unit_Kithullu:Dictionary = {
	unitname = "Orc",
	unitid = "Kithulu",
	type = "enemy",
	hp = 1,
	attack = 2,
	}

const Unit_Stool:Dictionary = {
	unitname = "Wolf",
	unitid = "StoolBite",
	type = "enemy",
	hp = 2,
	attack = 1,
	}

const Unit_Stump:Dictionary = {
	unitname = "Turtle",
	unitid = "StumpEye",
	type = "enemy",
	hp = 5,
	attack = 1,
	}

const Unit_FatChick:Dictionary = {
	unitname = "Ogre",
	unitid = "FatChick",
	type = "enemy",
	hp = 2,
	attack = 3,
	}

const Unit_PunchRat:Dictionary = {
	unitname = "Serpent",
	unitid = "PunchRat",
	type = "enemy",
	hp = 3,
	attack = 3,
	}

const Unit_EyeFly:Dictionary = {
	unitname = "Bat",
	unitid = "EyeFly",
	type = "enemy",
	hp = 2,
	attack = 4,
	}

const Unit_Mimic:Dictionary = {
	unitname = "Harvest Scroll",
	unitid = "ChestClosed",
	type = "enemy",
	hp = 4,
	hp_max = 4, #if mimic bool is true, when this is equal to hp then show Mimic as chest 
	attack = 3,
	mimic = true,
	}

const Unit_Wall:Dictionary = {
	unitname = "WALL",
	unitid = "wall",
	type = "wall", 
	hp = 99,
	attack = 1,
	}

const Unit_Void:Dictionary = {
	unitname = "$&@($&&!@",
	unitid = "void",
	type = "void",
	hp = 99,
	hp_max = 99,
	attack = 99,
	
	
	
	}



				###INPUTS

var input_queue:Array[String] = []
var input_queue_max := 5
var input_lock := 10 #how many frames a card movement anim lasts and forces input queues instead of inputs. Also fade timer
var input_forbidden := 0 #timer for how many frames any new inputs are ignored
var queued_tile = null
var state_fade := "idle"
var youaredying := false

var using_ability := false

func input_handler():
	input_to_queue("up")
	input_to_queue("down")
	input_to_queue("left")
	input_to_queue("right")
	
	if Input.is_action_just_pressed("ability"):
		abilitybutton_pressed()
	
	if frame >= input_lock and len(input_queue) > 0:
		var next_input = input_queue[0]
		call_deferred("button_" + next_input)
		input_queue.pop_at(0)

	if Input.is_action_just_pressed("switchmode") and developer_mode: flip_editor_mode()

func input_to_queue(input:String):
	if Input.is_action_just_pressed(input) and !overlay_opened and input_forbidden == 0:
		if len(input_queue) < input_queue_max:
			input_queue.append(input)

func button_up():
	if using_ability:
		use_ability(Vector2(0,-1))
	else:
		move_player(Vector2(0,-1))
		advance_turn()

func button_down():
	if using_ability:
		use_ability(Vector2(0,1))
	else:
		move_player(Vector2(0,1))
		advance_turn()

func button_left():
	if using_ability:
		use_ability(Vector2(-1,0))
	else:
		move_player(Vector2(-1,0))
		advance_turn()

func button_right():
	if using_ability:
		use_ability(Vector2(1,0))
	else:
		move_player(Vector2(1,0))
		advance_turn()




func update_MouseCollisions():
	$MouseCollisions.position = card_position_formula(Vector2(Player.positionX,Player.positionY))
	for x in $MouseCollisions.get_children():
		if boopable(x.deltapos):
			x.get_node("glow").visible = false
			x.get_node("borderGlowing").visible = false


		##############TURN LOGIC & PLAYER ACTIONS
var turn := 0
var phase := 0
var frame := 0 #resets to 0 at turn start 

func advance_turn():
	turn+=1
	frame=0
	phase=0
	##UPDATE GAME
	for x in len(units): for y in len(units[0]): if units[x][y] != null: #loop through units on grid
		var unit:Dictionary = units[x][y]
		if unit.hp_overtime > 0:
			unit.hp_overtime -= 1
			heal(unit,1,true)
	
	player_death_check()
	##UPDATE VISUALS
	for x in $Tiles.get_children(): #let me know when this crashes 
		x.update_visuals()
		x.get_node("glow").visible = false
	update_unit_cards(true)
			
		
	#UI
	update_ui()
	update_MouseCollisions()

func update_unit_cards(newturn=true):
	for x in $Units.get_children():
		x.frame = 0
		x.originalpos = x.position
		
		var unit = search_unit_by_uid(x.uid)
		if unit != null:
			x.positionX = unit.positionX
			x.positionY = unit.positionY
			x.update_visuals()
		else:
			x.die()

		if x.type == "player" and newturn:
					#Camera
			$Camera.update_target(card_position_formula(Vector2(x.positionX,x.positionY)))

func full_hp_max(unit:Dictionary): #includes additional hp from a player character upgrade
	if unit.has("characterid"):
		return unit.hp_max + global.save.characters[unit.characterid].extra_hp
	else:
		return unit.hp_max


func search_unit_by_uid(uid):
	for x in len(units):
		for y in len(units[0]):
			if units[x][y] != null:
				if units[x][y].uid == uid:
					return units[x][y]
	return null

##Includes attacking code. 
func move_unit_to_pos(unit:Dictionary,destination:Vector2):
	var realdestination = destination
			##out of bounds prevention
	if realdestination.x < 0: #leftmost
		realdestination.x = 0
		boop()
	if realdestination.x > len(units)-1: #rightmost
		realdestination.x = len(units)-1
		boop()
	if realdestination.y < 0: #topmost
		realdestination.y = 0
		boop()
	if realdestination.y > len(units[0])-1: #bottommost
		realdestination.y = len(units[0])-1
		boop()
	if field[realdestination.x][realdestination.y].type == "void":
		realdestination = Vector2(unit.positionX,unit.positionY)
		boop()
	var target_unit = units[realdestination.x][realdestination.y]
	var target_tile = field[realdestination.x][realdestination.y]
	if target_unit == null: #if tile is empty
		if realdestination == destination and target_tile.type == "weapon": #so you can't toss weapons while standing on them
			var tossdirection = realdestination -  Vector2(unit.positionX,unit.positionY)
			var defender = line_damage_recipients(realdestination, tossdirection * 4,"block")
			var defender_unit = null
			if len(defender) > 0:
				for pos in defender:
					attack(unit,units[pos.x][pos.y],false,target_tile.attack)
				defender_unit = units[defender[0].x][defender[0].y]
	

			target_tile.hp -= 1
			if (target_tile.hp < 0 and (!Player.characterid=="barbara") ) or \
			(target_tile.hp < -1 and Player.characterid == "barbara"):
				tile_at(Tile_default,realdestination)
					#animation
			#toss graphic
			var tossgraphic = preload("res://Content/Scenes/weapontoss.tscn").instantiate()
			add_child(tossgraphic)
			tossgraphic.position = card_position_formula(realdestination)
			tossgraphic.direction = tossdirection
			tossgraphic.range = 3
			tossgraphic.texture = load("res://Content/images/" + target_tile.tileid + ".tres")
			#card animation
			for x in $Units.get_children():
				if x.uid == unit.uid: #attacker
					x.state = "bump"
					x.latest_direction = tossdirection 
				if defender_unit!=null: #defender
					if Vector2(x.positionX,x.positionY) in defender: 
						x.state = "shake"
			
			
			
		else:
			units[unit.positionX][unit.positionY] = null #yes this actually works dictionaries are weird 
			units[realdestination.x][realdestination.y] = unit
			unit.positionX = realdestination.x
			unit.positionY = realdestination.y
	elif target_unit != unit:
		attack(unit,target_unit)
		if unit.type == "player":
			if unit.characterid == "yari" and !global.settings.gameplayActiveQuirk and rngpercent(30):
				yari_pierce(realdestination-Vector2(unit.positionX,unit.positionY),true)
				spawn_notification("Pierce")
		#animation
		for x in $Units.get_children():
			if x.uid == unit.uid: #attacker
				x.state = "bump"
				x.latest_direction = Vector2(target_unit.positionX,target_unit.positionY) - Vector2(unit.positionX,unit.positionY)
			if x.uid == target_unit.uid:
				x.state = "shake"




func attack(attacker:Dictionary,defender:Dictionary,counter:=true,additionalatk:int=0):
	var fullattack = attacker.attack
	var truecounter:= counter
	if attacker.has("characterid"):
		fullattack += global.extra_atk(attacker.characterid)
		if attacker.characterid == "barbara" and !global.settings.gameplayActiveQuirk:
			if rngpercent(20):
				fullattack+= attacker.attack+global.extra_atk("barbara")
				spawn_notification("ExtraAtk")
		#Yari quirk
		if attacker.characterid == "yari" and defender.unitname == "Chest" and defender.hp == defender.hp_max:
			truecounter = false
	var attackertile = field[attacker.positionX][attacker.positionY]
	if attackertile.type == "weapon" and attacker.type == "player": #shouldn't happen anymore but whatever 
		fullattack += attackertile.attack
	fullattack+=additionalatk #this is used for tossing weapons
	harm(defender,fullattack)
	if attacker.ability_cooldown > 0: attacker.ability_cooldown -=1
	#Counterattack, remove if phase system is implemented

	
	if truecounter:
		var rng:int = randi() % 100
		if rng < attacker.dodge_chance and not global.settings.gameplayActiveQuirk:
			battleprint("Dodged " + str(defender.attack) + " damage!")
			spawn_notification("Dodge")
			return
		harm(attacker,defender.attack)
	


##Checks for death too
func harm(unit:Dictionary,damage:int):
	unit.hp -= damage
	if unit.hp <= 0:
		#if unit.type == "wall": wall_around(unit)
		if unit.type == "wall": void_around(unit)
		if Player.characterid == "vi" and !global.settings.gameplayActiveQuirk and unit.type == "enemy": #spawn potion
			if field[unit.positionX][unit.positionY].type == "floor" and rngpercent(15):
				spawn_notification("Potion",0.5)
				tile_at(Tile_Potion,Vector2(unit.positionX,unit.positionY))
		units[unit.positionX][unit.positionY] = null
		battleprint (unit.unitname + " has died. ")
		playsound("kill.ogg",unit.positionX,unit.positionY)
		
	else:
		playsound("attack.ogg",unit.positionX,unit.positionY)

##Moves the given unit in a direction instead of a specific coordinate
func move_unit_by_delta(unit:Dictionary,delta:Vector2):
	var destination := Vector2(unit.positionX,unit.positionY) + delta
	move_unit_to_pos(unit,destination)

func move_player(delta:Vector2):
	var initial_pos = Vector2(Player.positionX,Player.positionY)
	move_unit_by_delta(Player,delta)
	if Vector2(Player.positionX,Player.positionY) != initial_pos: #if the player moved a tile
		activate_tile(Player)
		playsound("move.ogg",Player.positionX,Player.positionY)
	reveal_cards()
	

func player_death_check():
	if Player.hp <= 0: 
		youaredying = true
		input_lock = 180
		global.save.deaths+=1 

func spawn_deathtext():
	var deathtext = preload("res://Content/Scenes/DeathText.tscn").instantiate()
	$CanvasLayer.add_child(deathtext)
	deathtext.position = Vector2 (180, 140)

func spawn_notification(texture:String,scale:float=1.0):
	var notif = preload("res://Content/Scenes/Notif.tscn").instantiate()
	for x in $Units.get_children(): if x.uid == Player.uid:
		x.add_child(notif)
	notif.scale = Vector2(scale,scale)
	notif.position += Vector2(-20,-30)

	notif.texture = load("res://Content/images/" + texture + ".tres")


func abilitybutton_pressed():
	if Player.ability_cooldown == 0:
		if using_ability:
			using_ability = false
			update_ui()
		else:
			using_ability = true
			$CanvasLayer/abilitybutton.self_modulate = Color(0.2,0.4,1,1)
		input_queue = []
	

func use_ability(direction:Vector2):
	var playerpos:= Vector2(Player.positionX,Player.positionY)
	var destination = playerpos + direction
	var unit = units[destination.x][destination.y]
	
	var cooldown_refund := 0
	match Player.characterid:
		"blondie":
			#open door
			if field[destination.x][destination.y].type == "door":
				level_settings.door_type = "unlocked"
				battleprint ("Finesse unlocks the door! Finesse needs more time cooldown time after picking a lock.")
				cooldown_refund -= 3
			#attack
			var tossdirection = direction * 2
			var defender = line_damage_recipients(playerpos, tossdirection )

			var defender_unit = null
			if len(defender) > 0:
				defender_unit = units[defender[0].x][defender[0].y]
				attack(Player, defender_unit,false,1)
					#animation
			#toss graphic
			var tossgraphic = preload("res://Content/Scenes/weapontoss.tscn").instantiate()
			add_child(tossgraphic)
			tossgraphic.position = card_position_formula(playerpos)
			tossgraphic.direction = tossdirection
			tossgraphic.range = 0.6
			tossgraphic.texture = load("res://Content/images/Knife.tres")
			#card animation
			for x in $Units.get_children():
				if x.uid == Player.uid: #attacker
					x.state = "bump"
					x.latest_direction = tossdirection 
				if defender_unit!=null: #defender
					if x.uid == defender_unit.uid: 
						x.state = "shake"
		"barbara":
			
			if unit== null:
				Player.hp_overtime += 3
			else:
				attack(Player,unit,true,Player.attack+global.extra_atk("barbara"))
				if unit.hp <= 0:
					cooldown_refund = 3
					spawn_notification("ExtraAtk")
			#animation
				for x in $Units.get_children():
					if x.uid == Player.uid: #attacker
						x.state = "bump"
						x.latest_direction = playerpos - destination
					if x.uid == unit.uid:
						x.state = "shake"
			
			
			
		"vi":
			var tossdirection = direction * 4
			var defender = line_damage_recipients(playerpos, tossdirection)
			var defender_unit = null
			if len(defender) > 0:
				defender_unit = units[defender[0].x][defender[0].y]
				attack(Player, defender_unit,true,1)
				if defender_unit.hp <= 0:
					Player.hp_max +=1 
					#animation
			#toss graphic
			var tossgraphic = preload("res://Content/Scenes/weapontoss.tscn").instantiate()
			add_child(tossgraphic)
			tossgraphic.position = card_position_formula(playerpos)
			tossgraphic.direction = tossdirection
			tossgraphic.range = 0.9 #I no longer care to find out why this doesn't look the same as thrown enemies
			tossgraphic.texture = load("res://Content/images/Potion.tres")
			tossgraphic.self_modulate = Color(1,0.3,1,1)
			#card animation
			for x in $Units.get_children():
				if x.uid == Player.uid: #attacker
					x.state = "bump"
					x.latest_direction = tossdirection 
				if defender_unit!=null: #defender
					if x.uid == defender_unit.uid:
						x.state = "shake"
						x.modulate = Color(1,0.5,1,1)
		"yari":
			if unit != null: yari_pierce(direction,false) #can't use it if there's no adjacent enemy 
			else: cooldown_refund = Player.ability_cooldown_max 
	
	
	
	using_ability = false
	Player.ability_cooldown = Player.ability_cooldown_max - cooldown_refund
	advance_turn()
	update_ui()


func yari_pierce(direction:Vector2,passivequirk=false):
	var damage_range_buff = 0 
	if !passivequirk:
		damage_range_buff = 1 


	var playerpos:= Vector2(Player.positionX,Player.positionY)
	var destination = playerpos + direction
	var tossdirection = direction * (3 + damage_range_buff)
	var defender = line_damage_recipients(playerpos, tossdirection,"pierce")

	if len(defender) > 0:
		for pos in defender:
			if pos.distance_to(playerpos) <= 1:
				if !passivequirk: attack(Player,units[pos.x][pos.y],false,0)
			else:
				attack(Player,units[pos.x][pos.y],false,damage_range_buff)
				if passivequirk: battleprint("Pierced through the enemy to hit " + units[pos.x][pos.y] + "!")


			#animation



	#toss graphic, no fitting sprite exists for this so not using it 

#	var tossgraphic = preload("res://Content/Scenes/weapontoss.tscn").instantiate()
#	add_child(tossgraphic)
#	tossgraphic.position = card_position_formula(realdestination)
#	tossgraphic.direction = tossdirection
#	tossgraphic.range = 3
#	tossgraphic.texture = load("res://Content/images/" + "empty" + ".tres")

	
	#card animation
	for x in $Units.get_children():
		if x.uid == Player.uid: #attacker
			x.state = "bump"
			x.latest_direction = tossdirection 
		if Vector2(x.positionX,x.positionY) in defender: 
			x.state = "shake"

func reset_run():
	global.save.dead = true
	global.current_player = {} #wipe current player first
	global.current_player = global.character_defaults[Player.characterid].duplicate()

	get_tree().change_scene_to_file("res://Menus/MainMenu.tscn")

##If level has a Player already, it's a save file. If not, load player data from global then put it in the level 
func search_player():
	if true:
		for x in len(units):
			for y in len(units[0]):
				if units[x][y] != null:
					if units[x][y].type == "player":
						if level_settings.savestate:		###  S A V E S T A T E
							Player = units[x][y]
							update_ui()
							update_MouseCollisions()
							return
						else:								###  L  E  V  E  L
							if level_settings.playerposX != -1: #this shouldn't happen outside of outdated levels
								units[x][y] = null #erase existing player first
								var pos := Vector2i(level_settings.playerposX,level_settings.playerposY) 
								unit_at(global.current_player,pos) #add global currentplayer into the level
								global.current_player.unlock_attempted = false
								if global.current_player.characterid == "yari": global.current_player.campfire_protection = true
								Player = units[pos.x][pos.y] #create reference
								update_ui()
								update_MouseCollisions()
								reveal_cards()
								return #has to happen or else for loop can find the newly created player and create it again 
							else:
								battleprint ("What the fuck?")

func reveal_cards():
	var v2 = Vector2(Player.positionX,Player.positionY)
	var tiles_checked = prune_oob([v2+Vector2(1,0),v2+Vector2(0,1),v2+Vector2(-1,0),v2+Vector2(0,-1),v2])
	for pos in tiles_checked:
		for hidden in hiddentiles:
			if pos.x == hidden[0] and pos.y == hidden[1]:
				hiddentiles.erase(hidden)

func add_markerplayer(x,y): #hello everybody my name is 
	level_settings.playerposX = x
	level_settings.playerposY = y
	$MarkerPlayer.position = card_position_formula(Vector2(x,y))



##eats stuff on the floor
func activate_tile(unit:Dictionary): 
	var tile = field[unit.positionX][unit.positionY]
	if tile.type == "heal":
		#ambush
		var rng:int = randi() % 100
		if rng <= tile.ambush_chance and tile.ambush_chance != 0:
			start_tile_queue(tile)
			return
			
		#healing
		if tile.heals_overtime:
			if (unit.hp < full_hp_max(unit)) or !global.settings.qolDontWasteItem:
				unit.hp_overtime += tile.hp
				if unit.characterid == "barbara" and !global.settings.gameplayActiveQuirk:
					unit.hp_overtime += tile.hp
					battleprint ("Got double health recovery over time from Barbara's passive.")
					spawn_notification("Ham",0.5)
				clear_tile(tile)
				playsound("bite.ogg",unit.positionX,unit.positionY)
		else:
			var realheal:int = tile.hp
			if unit.characterid == "vi" and tile.tilename == "Potion":
				realheal * 1.5
			if heal(unit,realheal) and tile.delete_on_use:
				clear_tile(tile)
				playsound("potion.ogg",unit.positionX,unit.positionY)
			elif !global.settings.qolDontWasteItem:
				clear_tile(tile)
				playsound("potion.ogg",unit.positionX,unit.positionY)
		
	elif tile.type == "elixir":
		var rng = randi() % 2
		if rng == 0:
			unit.attack+=1
		else:
			unit.hp_max+=1
			unit.hp+=1
		clear_tile(tile)
	elif tile.type == "chest":
		if tile.tilename == "Chest": loot_around(tile,4)
		else:
			if Player.characterid == "vi": loot_around(tile,4)
			else: loot_around(tile,1)
		heal(unit,tile.hp)
		if tile.tileid == "ChestClosed":
			tile_at(Tile_ChestOpened,Vector2(unit.positionX,unit.positionY))
		else:
			tile_at(Tile_default,Vector2(unit.positionX,unit.positionY))
	elif tile.type == "gold":
		if unit.has("characterid"):
			global.add_gold(unit.characterid,tile.attack)
			if unit.characterid == "blondie": # and !global.settings.gameplayActiveQuirk
				if rngpercent(25):
					var additionalgold:int = max(1,tile.attack/2)
					global.add_gold(unit.characterid,additionalgold)
					battleprint ("Looted an additional " + str(additionalgold) + " gold!")
					spawn_notification("Gold",0.5)
			playsound("coin.ogg",tile.positionX,tile.positionY)
			clear_tile(tile)
			savestate()
	elif tile.type == "door":
		if level_settings.door_type != "locked" or !check_enemy_presence():
			start_tile_queue(tile)
		else:
			if !unit.unlock_attempted and unit.characterid == "blondie" and !global.settings.gameplayActiveQuirk:
				unit.unlock_attempted = true 
				var rng:int = randi() % 100
				if rng < 15:
					battleprint("Blondie unlocked the door by chance.")
					level_settings.door_type = "unlocked"
					return
			battleprint("It's not safe enough to progress.")


func rngpercent(chance):
	var rng:int = randi() % 100
	if rng < chance:
		return true
	else: return false


##Starts a fade(implies time passing) and saves a tile to have its code be executed after the input lock
func start_tile_queue(tile,fadetime:int=25):
	$CanvasLayer/fade.fadeout()
	input_lock = fadetime
	input_forbidden = fadetime + 1
	queued_tile = tile

##activates stuff on a timer like doors and campfires
func activate_queued_tile():
	if queued_tile.type == "door":
		$CanvasLayer/fade.fadein()
		#save player data to global first
		global.current_player = Player.duplicate(true)

		load_level(queued_tile.filename)
	elif queued_tile.type == "heal" and queued_tile.tileid == "CampFire":
		$CanvasLayer/fade.fadein()
		#ambush_around(Player)
		Player.hp = full_hp_max(Player)
		update_ui()
		random_units_strewnabout(queued_tile.ambush_amount,false,level_settings.difficulty)
		if Player.campfire_protection == true: Player.campfire_protection = false
		else:
			queued_tile.ambush_amount +=1
		
		savestate()
		playsound("rest.ogg",Player.positionX,Player.positionY)
	
	
	queued_tile = null
	input_lock = 10

func clear_tile(tile):
	var pos = Vector2(tile.positionX,tile.positionY)
	tile_at(Tile_default, pos)

func loot_around(tile,minimumloot:int=1):
	var v2 = Vector2(tile.positionX,tile.positionY)
	var orthogonals = prune_oob([v2+Vector2(1,0),v2+Vector2(0,1),v2+Vector2(-1,0),v2+Vector2(0,-1)])
	var correct_tiles = []
		#Pruning
	for pos in orthogonals:
		var postile = field[pos.x][pos.y]
		if postile.type == "floor": #only empty tiles
			correct_tiles.append(pos)
		#Actual loot
	var attempts:int = min ( max(minimumloot, (randi() % 4) + 1) , len(correct_tiles) )
	for i in attempts:
		loot_at(correct_tiles[i])
#	for pos in correct_tiles:
#		loot_at(pos)


func loot_at(tilepos):
	var die_sides:int = len(loot_table)
	var random = randi() % die_sides
	tile_at(loot_table[random],tilepos)

func loot_nogold_at(tilepos):
	var die_sides:int = len(loot_table_nogold)
	var random = randi() % die_sides
	tile_at(loot_table_nogold[random],tilepos)

const loot_table = [
	Tile_Cake,Tile_Ham,Tile_Potion, Tile_Elixir,Tile_Horseshoe,Tile_Gold,
	Tile_Knife,Tile_Hammer,Tile_Staff,Tile_Axe,Tile_Cutlass,Tile_Sword
	]

const loot_table_nogold = [
	Tile_Cake,Tile_Ham,Tile_Potion, Tile_Elixir,
	Tile_Knife,Tile_Hammer,Tile_Staff,Tile_Axe,Tile_Cutlass,Tile_Sword
	]

#prunes out of bounds tiles
func prune_oob(tilelist:Array) -> Array:
	var result:Array = []
	for pos in tilelist:
		if pos.x >= 0 and pos.x < len(field): #no out of bounds
			if pos.y >= 0 and pos.y < len(field[0]): #no oob
				var postile = field[pos.x][pos.y]
				result.append(pos)
	return result



func ambush_around(unit):
	var v2 = Vector2(unit.positionX,unit.positionY)
	var orthogonals = prune_oob([v2+Vector2(1,0),v2+Vector2(0,1),v2+Vector2(-1,0),v2+Vector2(0,-1)])
	var correct_tiles = []#so glad I made this a pos list and not tile list
			#Pruning
	for pos in orthogonals:
		var posunit = units[pos.x][pos.y]
		var postile = field[pos.x][pos.y]
		if posunit == null and postile.type != "void": #only empty tiles. only time the units grid structure is useful
			correct_tiles.append(pos)
			#Random amount of ambushing enemies 
	var rng = randi() % (len(correct_tiles)) #amount of erased enemies
	while rng > 0:
		var rng2 = randi() % len(correct_tiles) #determines randomly which position is being deleted
		correct_tiles.pop_at(rng2)
		rng-=1
			#Ambush
	for pos in correct_tiles:
		ambush_at(pos)


func ambush_at(tilepos:Vector2,level:int=1):

	var die_sides:int = len(ambush_table)
	var random = randi() % die_sides
	unit_create(ambush_table[random],tilepos,level)

const ambush_table = [
	Unit_Hamzilla, Unit_Hamzilla, Unit_Kithullu, Unit_Stool,
	Unit_Stump, Unit_FatChick, Unit_PunchRat,Unit_EyeFly, Unit_Mimic,
	]

func wall_around(unit):
	var v2 = Vector2(unit.positionX,unit.positionY)
	var orthogonals = [v2+Vector2(1,0),v2+Vector2(0,1),v2+Vector2(-1,0),v2+Vector2(0,-1)] 
	var correct_tiles = []#so glad I made this a pos list and not tile list
			#Pruning
	for pos in orthogonals:
		if pos.x >= 0 and pos.x < len(field): #no out of bounds
			if pos.y >= 0 and pos.y < len(field[0]):
				var posunit = units[pos.x][pos.y]
				var postile = field[pos.x][pos.y]
				if posunit == null and postile.type != "void" and postile.type != "door": #only empty tiles
					correct_tiles.append(pos)
			#Ambush
	for pos in correct_tiles:
		unit_create(Unit_Wall,pos)

##Creates a void card in adjacent cards of the unit that are at the boundary of the level
func void_around(unit):
	if !global.settings.qolNoVoidCard:
		var v2 = Vector2(unit.positionX, unit.positionY)
		var orthogonals = prune_oob([v2+Vector2(1,0),v2+Vector2(0,1),v2+Vector2(-1,0),v2+Vector2(0,-1)])
		var correct_tiles = []
		for pos in orthogonals:
			if pos.x == 0 or pos.x == len(field)-1 or pos.y == 0 or pos.y == len(field[0])-1:
				correct_tiles.append(pos)
		for pos in correct_tiles:
			unit_create(Unit_Void,pos,1)


func heal(unit:Dictionary,amount:int,overtime:bool = false,):
	var initial_hp:int = unit.hp
	unit.hp = min (full_hp_max(unit) , unit.hp + amount )
	var healed:int = unit.hp - initial_hp
	if healed == 0:
		return false
	else:
		var hp_display_load := preload("res://Content/Scenes/hp_display.tscn")
		var hp_display = hp_display_load.instantiate()
		for x in $Units.get_children():
			if x.uid == unit.uid:
				x.add_child(hp_display)
				hp_display.overtime = overtime #smaller text particle for constant heals
				hp_display.text = "+" + str(healed)
				hp_display.position.y -= 48
		return true #this is some black magic shit im sorry

##for tossing weapons orthogonally. Direction includes range. Not meant to support diagonal/angled directions. 
##types are block(can only harm the first thing the line meets);"pierce".
func line_damage_recipients(origin:Vector2, direction:Vector2,attacktype:String="block", ) -> Array[Vector2]:
	var result:Array[Vector2] = []
	var positions:Array  = []
	if direction.x != 0:
		var side = plusorminus(direction.x) #scuff
		for num in abs(direction.x): #scuff
			positions.append(origin + Vector2(num*side,0))

	if direction.y != 0:
		var side = plusorminus(direction.y) #scuff
		for num in abs(direction.y): #SCUFF
			positions.append(origin + Vector2(0,num*side))
	
	
	positions = prune_oob(positions)
	
	for pos in positions:
		var unit = units[pos.x][pos.y]
		if unit != null and pos != origin:

			result.append(pos)
			if attacktype == "block": break
	
	
	return result

func plusorminus(input:int) -> int:  #SCUUUFFFFF
	if input > 0: return 1
	else: return - 1



			################UI

var ui_hovered := false
var overlay_opened = false #for settings and any other "window" like setting progression. Blocks inputs 

##Out of bounds attempt
func boop():
	battleprint("Boop!")

##Used to not turn on glows for mouse collision for hidden tiles and out of bounds 
func boopable(delta) -> bool:
	var realpos:Vector2i = Vector2i(Player.positionX,Player.positionY) + delta
	if realpos.x < 0 or realpos.x > len(units)-1:
		return true
	if realpos.y < 0 or realpos.y > len(units[0])-1:
		return true
	if field[realpos.x][realpos.y].type == "void":
		return true

	return false

var battlelog:Array[String] = []
var battlelog_size:= 5
@onready var battlelog_node = get_node("CanvasLayer/battlelog")

func battleprint(string:String):
	battlelog.append("* " + string)
	if battlelog.size() > battlelog_size:
			battlelog.pop_front()
	var result_string := ""
	for i in battlelog:
		result_string += i + "\n"
	battle_print_update(result_string)

func battle_print_update(result_string: String):
	battlelog_node.text = result_string
	battlelog_node.scroll_to_line(battlelog_node.get_line_count() - 1)

func battle_print_clear():
	battlelog = []
	battlelog_node.text = ""


func open_settings():
	var canvas = get_node("CanvasLayer")
	if overlay_opened:
		for x in canvas.get_children():
			if x.name == "Settings":
				close_windows()
				overlay_opened = false
				return
		close_windows() #this and VVV only happen if no Settings node is found, i.e. a different window is open
		spawn_settings() 

	else:
		spawn_settings()


func open_upgrade():
	var canvas = get_node("CanvasLayer")
	if overlay_opened:
		for x in canvas.get_children():
			if x.name == "Upgrade":
				close_windows()
				overlay_opened = false
				return
		close_windows() #this and VVV only happen if no Settings node is found, i.e. a different window is open
		spawn_upgrade() 
	else:
		spawn_upgrade()



func close_windows():
	for x in get_node("CanvasLayer").get_children():
		if x.name == "Settings" or x.name == "Upgrade":
			x.close()
func spawn_settings():
	var settings = preload("res://Menus/Settings.tscn").instantiate()
	get_node("CanvasLayer").add_child(settings)
	settings.position = Vector2(128,48)
	overlay_opened = true
func spawn_upgrade():
	var upgrade = preload("res://Menus/Upgrade.tscn").instantiate()
	get_node("CanvasLayer").add_child(upgrade)
	upgrade.position = Vector2(128,48)
	overlay_opened = true



func playsound(soundname:String,positionX,positionY):
	var soundfile = load( "res://Content/sound/" + soundname )
	var soundnode = preload("res://Base/sound2D.tscn").instantiate()
	add_child(soundnode)
	soundnode.position = card_position_formula(Vector2(positionX,positionY))
	soundnode.stream = soundfile
	soundnode.play()


		#####LEVEL EDITOR

var developer_mode:bool = false #allows switching into editor mode


var editor_mode := false
const brush_tiles:Array[Dictionary] = [Tile_default,Tile_ChestClosed,Tile_Cake,Tile_Ham,Tile_Potion,Tile_Elixir,Tile_Campfire,Tile_Backpack,Tile_Horseshoe,Tile_Gold, Tile_Void, Tile_Knife,Tile_Hammer,Tile_Staff,Tile_Axe,Tile_Cutlass,Tile_Sword,Tile_Door]
const brush_units:Array = [null, Unit_Player, Unit_Wall, Unit_Hamzilla, Unit_Kithullu, Unit_Stool, Unit_Stump, Unit_FatChick, Unit_PunchRat, Unit_EyeFly, Unit_Mimic]

var brush_type := "tile" #tile,unit
var brushtile_select:int = 0
var brushunit_select:int = 0


var doorlevel = "next" #which filename is saved to door tile when it is placed 




##godot focusing by default fucking sucks in Godot so I have to code it 
var focusmode = "default" #idle, text



func flip_editor_mode():
	editor_mode = not editor_mode
	$CanvasLayer/EditorUI.visible = editor_mode
	$Camera.update_target($Camera.position) #camera fucks off into the neverlands otherwise
	for x in $Tiles.get_children(): #let me know when this crashes 
		x.update_visuals()
		x.get_node("glow").visible = false

func editor_input_handler():
	var currentlevel_node:= get_node("CanvasLayer/EditorUI/currentlevel")
	var extents_node:= get_node("CanvasLayer/EditorUI/extents")
	var doorlevel_node := get_node("CanvasLayer/EditorUI/doorlevel")
	#visuals
	#When the text in the textbox is yellow, then the text matches var currentlevel
	if currentlevel_node.text == currentlevel:
		currentlevel_node.add_theme_color_override("font_color",Color(0.95,0.95,0,1)) 
	else:
		currentlevel_node.add_theme_color_override("font_color",Color(1,1,1,1)) 
	##Same thing for doorlevel
	if doorlevel_node.text == doorlevel:
		doorlevel_node.add_theme_color_override("font_color",Color(0.95,0.95,0,1)) 
	else:
		doorlevel_node.add_theme_color_override("font_color",Color(1,1,1,1)) 
	#focus
	if currentlevel_node.has_focus() or extents_node.has_focus() or doorlevel_node.has_focus():
		focusmode = "text"
	else:
		focusmode = "default"
	
	#inputs
	match focusmode:
		"default":
			var camera_speed:= 2.5
			if Input.is_key_pressed(KEY_SHIFT): camera_speed = 6
			if Input.is_action_pressed("left"): $Camera.position.x -= camera_speed / $Camera.zoom.x
			if Input.is_action_pressed("right"): $Camera.position.x += camera_speed / $Camera.zoom.x
			if Input.is_action_pressed("up"): $Camera.position.y -= camera_speed / $Camera.zoom.y
			if Input.is_action_pressed("down"): $Camera.position.y += camera_speed / $Camera.zoom.y
			if Input.is_action_pressed("zoom-in"): $Camera.zoom -= Vector2(0.02,0.02)
			if Input.is_action_pressed("zoom-out"): $Camera.zoom += Vector2(0.02,0.02)
			if Input.is_action_pressed("zoom-reset"): $Camera.zoom = Vector2(1,1)
			
			if Input.is_action_just_pressed("savelevel"):
				save_current_level()
				battleprint("Saved level " + currentlevel + " to file")
			if Input.is_action_just_pressed("loadlevel"):
				load_current_level()
				battleprint("Loaded level " + currentlevel + " from file")
			if Input.is_action_just_pressed("switchmode"):
				flip_editor_mode()
			#brush select inputs
			for x in 20:
				if Input.is_action_just_pressed("brush-"+str(x)):
					if brush_type == "tile":
						if x < len(brush_tiles): #prevents crashes if there's less than 19 cards in the palette
							brushtile_select = x
							$CanvasLayer/EditorUI/CardUI.update_visuals_tile(brush_tiles[brushtile_select])
					else:
						if x < len(brush_units): #prevents crashes
							brushunit_select = x
							$CanvasLayer/EditorUI/CardUI.update_visuals_unit(brush_units[brushunit_select])
			if Input.is_action_just_pressed("brushswitch"):
				brush_switch()
		
		"text":
			if currentlevel_node.has_focus(): #current level
				if Input.is_action_just_pressed("ui_accept"):
					currentlevel_node.undo()
					#currentlevel_node.text = currentlevel_node.text.substr(0,len(currentlevel_node.text)-1) #yep it's that bad
					currentlevel_node.release_focus()
					currentlevel = currentlevel_node.text
				if Input.is_action_just_pressed("ui_cancel"):
					currentlevel_node.release_focus()
			elif extents_node.has_focus():  #extents
				if Input.is_action_just_pressed("ui_accept"):
					extents_node.undo()
					extents_node.release_focus()
					edit_extents(extents_node.text)
				if Input.is_action_just_pressed("ui_cancel"):
					extents_node.release_focus()
			elif doorlevel_node.has_focus(): #doorlevel
				if Input.is_action_just_pressed("ui_accept"):
					doorlevel_node.undo()
					doorlevel_node.release_focus()
					doorlevel = doorlevel_node.text
				if Input.is_action_just_pressed("ui_cancel"):
					doorlevel_node.release_focus()

func difficulty_minus():
	level_settings.difficulty-=1
	$CanvasLayer/EditorUI/difficultyshow.text = str(level_settings.difficulty)

func difficulty_plus():
	level_settings.difficulty+=1
	$CanvasLayer/EditorUI/difficultyshow.text = str(level_settings.difficulty)



func update_ui():
	$CanvasLayer/goldamount.text = (str(global.save["characters"][Player.characterid]["gold"]) +  "    gold")
	$CanvasLayer/hpamount.text = (str(Player.hp) + "/" + str(full_hp_max(Player)) + "    health")
	$MarkerPlayer.position = card_position_formula(Vector2(level_settings.playerposX,level_settings.playerposY))
	
	$CanvasLayer/EditorUI/difficultyshow.text = str(level_settings.difficulty)
	if !developer_mode:
		$MarkerPlayer.visible = false
	$CanvasLayer/abilitycooldown.text = str(Player.ability_cooldown)
	if Player.ability_cooldown > 0:
		$CanvasLayer/abilitybutton.self_modulate = Color (1,0.1,0.1,1)
	else:
		$CanvasLayer/abilitybutton.self_modulate = Color (0,1,0.3294,1)
	$CanvasLayer/abilitybutton/Label.text = Player.ability_name


func brush_left():
	if brush_type == "tile" and brushtile_select > 0:
		brushtile_select -= 1
		brush_display_update()
	elif brushunit_select > 0:
		brushunit_select -= 1
		brush_display_update()

func brush_right():
	if brush_type == "tile" and brushtile_select < len(brush_tiles)-1:
		brushtile_select += 1
		brush_display_update()
	elif brushunit_select < len(brush_units)-1:
		brushunit_select += 1
		brush_display_update()

func brush_switch():
				if brush_type == "tile":
					brush_type = "unit"
				else:
					brush_type = "tile"
				battleprint(brush_type)
				brush_display_update()

func brush_display_update():
	if brush_type == "tile":
		$CanvasLayer/EditorUI/CardUI.update_visuals_tile(brush_tiles[brushtile_select]) 
	if brush_type == "unit":
		$CanvasLayer/EditorUI/CardUI.update_visuals_unit(brush_units[brushunit_select])

	#SAVING/LOADING LEVELS
var currentlevel = "Start" #both saving and loading


func save_current_level():
	#saving to parsable data
	var result:Dictionary = {
		"settings" : {},   
		"field" : [],
		"units" : [], 
		"hiddentiles" : {},
		
							}
	
	result.field = field.duplicate() #doesn't need duplicate(true) because it's saved to file instantly anyways
	result.units = units.duplicate()
	result.hiddentiles = hiddentiles.duplicate()
	result.settings = level_settings.duplicate()
	
	#saving to file
	var savefile = FileAccess.open('res://Levels/' + currentlevel + '.cdlevel', FileAccess.WRITE)
	var save_as_json = JSON.stringify(result)
	savefile.store_string(save_as_json)
	savefile.close()

func savestate():
	#saving to parsable data
	var result:Dictionary = {
		"field" : [],
		"units" : [], 
		"settings" : {},   
		"hiddentiles" : {},
		
							}
	
	result.field = field.duplicate()
	result.units = units.duplicate()
	result.hiddentiles = hiddentiles.duplicate()
	result.settings = level_settings.duplicate()
	#VVV makes sure this is treated as a savestate, the Player card isn't replaced by global.current_player
	result.settings.savestate = true
	#saving to file
	var savefile = FileAccess.open('user://savestate.cdlevel', FileAccess.WRITE)
	var save_as_json = JSON.stringify(result)
	savefile.store_string(save_as_json)
	savefile.close()


func load_level(levelname):
	global.save.dead = false #this isn't useful in any way
		#wipe visuals
	for x in $Units.get_children(): x.queue_free()
	for x in $Tiles.get_children(): x.free() #This can be unstable, please report to me if this causes issues!!!
		#wipe data
	field = []
	units = []
	hiddentiles = []

	global.nextlevel = ""
	level_settings.savestate = false #if this is savestate.cdlevel this will be overwritten 
		#load file
	
	var loadfile = FileAccess.open('res://Levels/' + levelname + '.cdlevel', FileAccess.READ)
	#Filename exceptions
	if levelname == "savestate":
		loadfile = FileAccess.open('user://savestate.cdlevel', FileAccess.READ)
	
	if levelname == "next":
		var nextlevel:String = global.next_level(currentlevel)
		if nextlevel == "end":
			battleprint("Coglaturation!!")
			get_tree().change_scene_to_file("res://Menus/Credits.tscn")
			return
		else:
			loadfile = FileAccess.open('res://Levels/' + nextlevel + '.cdlevel', FileAccess.READ)
			currentlevel = nextlevel

	var parsed_json = JSON.parse_string(loadfile.get_as_text())
	if parsed_json.has("hiddentiles"): hiddentiles = parsed_json.hiddentiles
	field = parsed_json.field
	units = parsed_json.units

	level_settings.merge(parsed_json.settings,true)
	
		#random stuff
	if levelname != "savestate" and !developer_mode:
		random_units_strewnabout(level_settings.random_units,true,level_settings.difficulty)
		random_tiles_strewnabout(level_settings.random_items,"item",true)
		random_tiles_strewnabout(level_settings.random_gold,"gold",true)
		random_tiles_strewnabout(level_settings.random_coins,"coin",true)
		custom_strewnabout(level_settings.random_custom,true,level_settings.difficulty)
	
		#cleanup and visuals
	if levelname != "next": currentlevel = levelname
	$CanvasLayer/EditorUI/currentlevel.text = levelname
	search_player()
	generate_cards()
	$Camera.position = card_position_formula(Vector2(Player.positionX,Player.positionY))
	$Camera.update_target($Camera.position)
	loadfile.close()
	#Autosave 
	savestate()
	global.save_gamesave()

func load_current_level(): #loads level with the name currentlevel.
	load_level(currentlevel)

##Deletes or adds field/unit entries based on string input. int() in var v2 will prune any non-integer chr. 
#Comma separator must be present.
func edit_extents(input:String):
	var split:PackedStringArray = input.split(",")
	if len(split) < 2:
		battleprint("Completely invalid dimensional input.")
		return
	var ext: = Vector2i(int(split[0]),int(split[1]))
	if ext.x == 0 or ext.y == 0:
		battleprint (str(ext) + " is an invalid dimensional input.")
		return
	var diff: = ext - Vector2i(len(field),len(field[0]))
	
	#Y DIMENSION
	for row in len(field):
		var control:int = diff.y
		while control != 0:
			if control > 0:
				field[row].append(Tile_default.duplicate(true))
				units[row].append(null)
				control-=1
			else:
				field[row].pop_back()
				units[row].pop_back()
				control+=1
	#X DIMENSION
	for table in abs(diff.x):
		if diff.x > 0:
			var fullrow:Array = []
			var fullrow_units:Array = []
			for x in ext.x: #fills out an empty row
				fullrow.append(Tile_default.duplicate(true))
				fullrow_units.append(null)
			field.append(fullrow)
			units.append(fullrow_units)
		if diff.x < 0:
			field.pop_back()
			units.pop_back()
	
	
	
	
	
	generate_cards()
	
	
	
##Strewn about means random EMPTY FLOOR tiles across the entire map are picked.
##accepthiddentiles should only be used when levels are loaded initially.
func random_units_strewnabout(amount:int=3,accepthiddentiles=false,level:int=1):
	var potential_tiles:Array[Vector2] = find_empty_tiles(accepthiddentiles)
	if amount > len(potential_tiles):
		amount = len(potential_tiles)
	if amount == 0: return
	for x in amount:
		var rng := randi() % len(potential_tiles)
		ambush_at(potential_tiles[rng],level)
		potential_tiles.erase(potential_tiles[rng])

##types- heal;gold;coin
func random_tiles_strewnabout(amount:int=3,type:String="item",accepthiddentiles:bool=false,):
	var potential_tiles:Array[Vector2] = find_empty_tiles(accepthiddentiles)
	if amount > len(potential_tiles): amount = len(potential_tiles)
	if amount == 0: return
	for x in amount:
		var rng:= randi() % len(potential_tiles)
		match type:
			"item":
				loot_nogold_at(potential_tiles[rng])

			"itemall":
				loot_at(potential_tiles[rng])

			"coin":
				tile_at(Tile_Horseshoe.duplicate(),potential_tiles[rng])

			"gold":
				tile_at(Tile_Gold.duplicate(),potential_tiles[rng])
		potential_tiles.erase(potential_tiles[rng])

func custom_strewnabout(list:Array,accepthiddentiles:bool=false,level:int=1):
	var potential_tiles:Array[Vector2] = find_empty_tiles(accepthiddentiles)
	for x in list:
		if len(potential_tiles) == 0: return
		var randompos:Vector2= potential_tiles [randi() % len(potential_tiles) ]
		var card:Dictionary = string2dictref[x].duplicate()
		if card.type == "enemy": #not the best way to check if it's a unit or tile but it's fine
			unit_create(card, randompos,level)
		else:
			tile_at(card, randompos)
		potential_tiles.erase(randompos)


##Empty means no units and has floor type 
func find_empty_tiles(accepthiddentiles:bool=false) -> Array[Vector2]:
	var potential_tiles:Array[Vector2] = []
	for x in len(field): for y in len(field[0]):
		var tile = field[x][y]
		if tile.type == "floor" and units[x][y] == null:
			if accepthiddentiles or (!tile_is_hidden(Vector2(x,y))):
				potential_tiles.append(Vector2(x,y))
	return potential_tiles

func tile_is_hidden(tilepos:Vector2) -> bool:
	for x in hiddentiles:
		if x[0] == tilepos.x and x[1] == tilepos.y:
			return true
	return false 


func _ready():
	randomize()
	if global.nextlevel != "":
		load_level(global.nextlevel)
	else:
		load_current_level()
	if !global.settings.gameplayActiveQuirk:
		$CanvasLayer/abilitybutton.visible = false
		$CanvasLayer/abilitycooldown.visible = false
	battleprint("Welcome to Card Dungeon!")



func _process(delta):
	if frame >= input_lock:
		if queued_tile != null:
			activate_queued_tile()
			
	frame+=1
	if input_forbidden > 0: input_forbidden-=1
	if editor_mode:
		editor_input_handler()
	else:
		input_handler()
	if Input.is_action_just_pressed("debug1"):
		pass
	#dying
	if youaredying:
		$Camera.zoom += Vector2(0.0027,0.0018)
		
		if frame >= input_lock:
			reset_run()
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_CTRL) and Input.is_action_just_pressed("debug2"):
		if developer_mode:
			battleprint ("Developer mode OFF. ")
			developer_mode = false
		else:
			battleprint ("Developer mode ON. Press Shift+Ctrl+Q to turn it off.")
			developer_mode = true
