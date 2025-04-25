extends Node2D

var inter = 0

func _process(delta: float) -> void:
	var window_scene = load("res://data/scn/window_editor.tscn")
	var window_instance = window_scene.instantiate()
	if Input.is_action_just_pressed("redactor"):
		get_tree().root.add_child(window_instance)
		get_tree().paused = true
		
	if Input.is_action_just_pressed("esc"):
		get_tree().change_scene_to_file("res://data/scn/MENU_START.tscn")	
	
	if Input.is_action_just_pressed("interaction"):
		inter += 1
	if inter > 4:
		$object/Label.visible = true
