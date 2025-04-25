extends Area2D

signal get_area_screen(position, size)

func _ready():
	add_to_group("screen_maps")




func _on_body_entered(_body):
	var size = $area.shape.get_rect().size * $".".global_scale
	emit_signal("get_area_screen", $area.global_position, size / 2)
