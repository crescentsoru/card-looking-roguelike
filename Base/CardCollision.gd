extends Area2D

func _on_mouse_entered():
	get_parent()._on_card_area_mouse_entered()

func _on_mouse_exited():
	get_parent()._on_card_area_mouse_exited()
