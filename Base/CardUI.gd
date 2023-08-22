extends Node2D

func update_visuals_tile(tile):
	if tile.type == "door":
		$Visual/name.text = get_parent().get_parent().get_parent().doorlevel
	else:
		$Visual/name.text = tile.tilename
	
	$Visual/health.text = str(min(tile.hp,99))
	$Visual/attack.text = str(min(tile.attack,99))
	$Visual/image.texture = load("res://Content/images/" + tile.tileid + ".tres")


func update_visuals_unit(unit):
	if unit != null:
		$Visual/name.text = unit.unitname
		$Visual/health.text = str(min(unit.hp,99))
		$Visual/attack.text = str(min(unit.attack,99))
		$Visual/image.texture = load("res://Content/images/" + unit.unitid + ".tres")
	else:
		$Visual/name.text = "REMOVE"
		$Visual/health.text = "-"
		$Visual/attack.text = "-"
		$Visual/image.texture = load("res://Content/images/" + "empty" + ".tres")


func _process(delta):
	pass
