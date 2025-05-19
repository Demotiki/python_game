extends Area2D

var zone = false

signal get_area_screen(position, size)

func _ready():
	add_to_group("screen_maps")







func _on_body_entered(_body):
	zone = true
	var size = $area.shape.get_rect().size * $".".global_scale
	emit_signal("get_area_screen", $area.global_position, size / 2)



func _on_body_exited(_body):
	zone = false
