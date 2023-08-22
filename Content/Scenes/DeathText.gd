extends Label

var deathtexts:Array[String] = ["Death Time", "Busta",  "Coward", "L", 
"One Day I'll See You Again", "Ballin' No More","SHINDA!", "BALLS OVER", 


]

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(1,1,1,0)
	var rng:= randi() % len(deathtexts)
	if global.save.deaths <= 1:
		rng= randi() % 4
	text = deathtexts[rng]
	if len(text) > 20: scale = Vector2(0.8,0.8)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	modulate.a += 0.009
	scale += Vector2(0.002,0.002)
