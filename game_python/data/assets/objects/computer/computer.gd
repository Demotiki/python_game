extends Area2D

var in_zone = false
signal open_door

func _ready() -> void:
	add_to_group("computers")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interaction") and in_zone:
		emit_signal("open_door")




func _on_body_entered(_body) -> void:
	in_zone = true
	$Label.visible = true

func _on_body_exited(_body) -> void:
	in_zone = false
	$Label.visible = false
