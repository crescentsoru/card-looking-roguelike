extends Node2D
var state := "idle" #idle for walking anim, bump for attacks, shake for defending 

#unit data related
var positionX:int = -1
var positionY:int = -1
var uid:int = 0
var type := "enemy"
var level := 1 

##Animation stuff
var frame:= 0 #set to 0 when turn resets, used for animation
var originalpos = Vector2(0,0)
var movement_end_frame = 18
var rotation_anim_degrees = 1.4 #per frame
var latest_direction = Vector2(0,1)


@onready var Main_node = get_parent().get_parent()
@onready var units = get_parent().get_parent().units

func update_visuals():
	var unit = units[positionX][positionY]
	$Visual/name.text = unit.unitname
	$Visual/health.text = str(min(unit.hp,99))
	$Visual/attack.text = str(min(unit.attack,99))
	$Visual/image.texture = load("res://Content/images/" + unit.unitid + ".tres")
	
	if unit.type == "player":
		z_index = 10 #lets Player card get rendered above other cards
		$Visual/attack.text = str(unit.attack+global.extra_atk(unit.characterid))
	type = unit.type
	if unit.has("level"): level = unit.level
	if level > 1: $Visual/level.text = "Lv. " + str(level)
	if unit.has("mimic"):
		if unit.mimic:
			if unit.hp == unit.hp_max: #obscured
				$Visual/name.text = "Harvest Scroll"
				$Visual/health.text = "0"
				$Visual/attack.text = "0"
				$Visual/image.texture = load("res://Content/images/ChestClosed.tres")
			else: #exposed
				$Visual/name.text = "Ghost"
				$Visual/health.text = str(unit.hp)
				$Visual/attack.text = str(unit.attack)
				$Visual/image.texture = load("res://Content/images/Mimic.tres")
	hide_check()




func hide_check():
	
	for x in Main_node.hiddentiles:
		if positionX == x[0] and positionY == x[1]:
			$Visual.visible = false
			return
	$Visual.visible = true

func update_movement():
	if state == "idle":
		var expectedpos = ( Vector2(32,48) + Main_node.card_margins ) + \
		(Vector2(64,96) + Main_node.card_margins) * Vector2(positionX,positionY) 
		var fraction = float(frame) / movement_end_frame
		if position == expectedpos:
			return
		var delta = expectedpos - originalpos
		position = originalpos +  (delta * min(fraction,1))
		if frame >= 0 and frame < 5:
			rotate(deg_to_rad(rotation_anim_degrees))
		if frame >= 5 and frame < 14:
			rotate( - deg_to_rad(rotation_anim_degrees))
		if frame > 14 and frame < 18:
			rotate(deg_to_rad(rotation_anim_degrees))
		if frame >= 18:
			rotation = 0
	elif state == "bump":
		if frame >= 0 and frame < 6:
			position += latest_direction * 6
		
		if frame >= 8 and frame <= 15:
			position -= latest_direction * 4
		
		if frame == 16:
			state = "idle"
			frame = 500
	elif state == "shake":
		shake(6)
		
		if frame == 4:
			modulate = Color(3, 3, 3, 1)
		if frame > 5 and frame < 16:
			modulate-= Color(0.2,0.2,0.2,0)
			
		if frame == 18:
			modulate = Color(1, 1, 1, 1)
			position = originalpos
			state = "idle"
	elif state == "playersuicide":
		
		if frame == 0: rotation = 0
		if frame >= 0 and frame < 6:
			position += latest_direction * 6
		if frame >= 8 and frame <= 15:
			position -= latest_direction * 4.5
		if frame == 10:
			$Visual/health.text = "0"
		if frame == 16:
			state = "dead"
	elif state == "dead":
		if type == "player":
			var intensity := 10
			if frame > 46: intensity = 8
			if frame > 66: intensity = 6
			if frame > 86: intensity = 4
			if frame > 106: intensity = 3
			if frame > 126: intensity = 2
			modulate.a += 0.03 #cringe but it works, makes fadeout slower

			if frame == 100:
				Main_node.get_node("CanvasLayer/fade").fadeout(0.012)
			if frame == 96:
				Main_node.spawn_deathtext()
			
			if frame == 5:
				originalpos = position
			if frame > 5:
				position = originalpos + Vector2(( randi()%intensity )-(intensity/2),( randi()%intensity) -(intensity/2))

				
		shake(4)
		modulate.a -= 0.039
		if modulate.a <= 0:
			queue_free()



func die():
	match type:
		"enemy":
			state = "dead"
			$Visual/health.text = "0"
		"wall":
			state = "dead"
			$Visual/health.text = "0"
		"player":
			state = "playersuicide"
			

func shake(intensity:int):
	if frame == 5:
		originalpos = position #let me know if this causes offsets
	if frame > 6 and frame <= 18:
		position = originalpos + Vector2(( randi()%intensity )-(intensity/2),( randi()%intensity) -(intensity/2))


func _ready():
	pass

func _process(delta):
	update_movement()
	frame += 2

func playsound(soundname:String):
	var soundfile = load( "res://Content/sound/" + soundname )
	var soundnode = preload("res://Base/sound2D.tscn").instantiate()
	add_child(soundnode)
	soundnode.stream = soundfile
	soundnode.play()
