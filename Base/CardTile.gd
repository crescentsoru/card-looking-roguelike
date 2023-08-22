extends Node2D

var positionX:int = -1
var positionY:int = -1

@onready var Main_node = get_parent().get_parent()

var hovered:bool = false


func update_visuals():
	var tile = Main_node.field[positionX][positionY]
	modulate = Color(1,1,1,1)
	$Visual/name.text = tile.tilename
	$Visual/health.text = str(min(tile.hp,99))
	$Visual/attack.text = str(min(tile.attack,99))
	$Visual/image.texture = load("res://Content/images/" + tile.tileid + ".tres")
	if tile.type == "void":
		if Main_node.editor_mode:
			modulate = Color(1,1,1,0.4)
		else: modulate = Color(1,1,1,0)
	if tile.type == "door":
		if Main_node.developer_mode:
			$Visual/name.text = tile.filename
		if Main_node.level_settings.door_type == "locked":
			if Main_node.check_enemy_presence():
				$Visual/image.texture = load("res://Content/images/" + "door_closed" + ".tres")
			else:
				$Visual/image.texture = load("res://Content/images/" + "door" + ".tres")
	if tile.type == "floor":
		$Visual/health.text = ""
		$Visual/attack.text = ""
	if tile.hp == -1:
		$Visual/health.text = ""
	if tile.attack == -1:
		$Visual/attack.text = ""
	for x in Main_node.hiddentiles:
		if x[0] == positionX and x[1] == positionY:
			$Visual.visible = false
	if Main_node.developer_mode and has_node("CardArea"):
		update_hidden_marker()
	update_hidden_gameplay()


	
func _on_card_area_mouse_exited():
	hovered = false
	$glow.visible = false

func _on_card_area_mouse_entered():
	if !Main_node.ui_hovered:
		hovered = true

func mouse_processing():
	if Main_node.editor_mode:
		$glow.visible = true
		var pos:Vector2 = Vector2(positionX,positionY)
		if Input.is_action_just_released("leftclick"):
			if Main_node.brush_type == "tile":
				var tile = Main_node.brush_tiles[Main_node.brushtile_select]
				Main_node.tile_at(tile,pos)
				if tile.has("filename"): #for doors
					Main_node.field[pos.x][pos.y].filename = Main_node.doorlevel
				#Main_node.field[positionX][positionY] = Main_node.brush_tiles[Main_node.brushtile_select]
				update_visuals()
			else: #unit
				if Main_node.brush_units[Main_node.brushunit_select] == null:
					Main_node.units[pos.x][pos.y] = null
				elif Main_node.brush_units[Main_node.brushunit_select].type != "player": #makes sure theres only 1 player unit
					Main_node.unit_at(Main_node.brush_units[Main_node.brushunit_select],pos,Main_node.level_settings.difficulty)
					Main_node.update_card_by_pos(positionX,positionY)
				else: #player
					Main_node.erase_player()
					Main_node.unit_at(Main_node.brush_units[Main_node.brushunit_select],pos)
					Main_node.add_markerplayer(positionX,positionY)
					Main_node.search_player()
					Main_node.update_card_by_pos(positionX,positionY)
				Main_node.update_unit_cards(false)
				
		if Input.is_action_just_pressed("rightclick"):
			var tiledata = [positionX,positionY] #cannot be a Vector2 because json doesn't save them well
			for x in Main_node.hiddentiles:
				if x[0] == tiledata[0] and x[1] == tiledata[1]:
					pass
			if not (tiledata in Main_node.hiddentiles):
				Main_node.hiddentiles.append(tiledata)
				update_hidden_marker()

		if Input.is_action_just_pressed("middleclick"):
			var tiledata = [positionX,positionY] 
			for x in Main_node.hiddentiles:
				if x[0] == tiledata[0] and x[1] == tiledata[1]:
					Main_node.hiddentiles.erase(x)
					update_hidden_marker()
					break 
				
			

func update_hidden_marker():
	if !Main_node.developer_mode: #if this is gameplay then hidden markers can never happen
		return
	for x in Main_node.hiddentiles:
		if x[0] == positionX and x[1] == positionY: #yes I have to do it like this, can't compare arrays directly
			get_node("CardArea/hiddenmarker").visible = true
			return
	get_node("CardArea/hiddenmarker").visible = false


func update_hidden_gameplay():
	for x in Main_node.hiddentiles:
		if x[0] == positionX and x[1] == positionY: #I literally have no clue why comparing arrays didn't work btw 
			$Visual.visible = false
			return
	
	$Visual.visible = true

func _ready():
	pass

func _process(delta):
	if hovered: mouse_processing()
	
