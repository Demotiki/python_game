extends Node2D

var inter = 0



var inst_anaible = false

func  _ready() -> void:
	$loading.visible = 1
	await get_tree().create_timer(3).timeout
	$loading.visible = 0

func _process(delta: float) -> void:
	var window_scene = load("res://data/scn/window_editor.tscn")
	
	
	if Input.is_action_just_pressed("redactor"):
		get_tree().root.add_child(window_scene.instantiate())
		get_tree().paused = true
		
	if Input.is_action_just_pressed("esc"):
		get_tree().change_scene_to_file("res://data/scn/MENU_START.tscn")	
	
	if Input.is_action_just_pressed("interaction"):
		inter += 1
	if inter > 4:
		$object/Label.visible = true
