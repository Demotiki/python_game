extends Node2D

var zones = 0

@onready var dialog = $Dialog
signal change_text

var inst_anaible = false

func  _ready() -> void:
	$loading.visible = 1
	await get_tree().create_timer(1.0).timeout
	$loading.visible = 0


func _process(delta: float) -> void:
	
	if $screen_maps/screen_map.zone: zones = 1
	if $screen_maps/screen_map2.zone: zones = 2
	if $screen_maps/screen_map3.zone: zones = 3
	
	var window_scene = load("res://data/scn/window_editor.tscn")
	
	
	if Input.is_action_just_pressed("redactor"):
		get_tree().root.add_child(window_scene.instantiate())
		get_tree().paused = true
		
	if Input.is_action_just_pressed("esc"):
		if dialog.visible: dialog.visible = false
		else: $YES_NO.visible = true
	if $YES_NO.voit == 1: get_tree().change_scene_to_file("res://data/scn/MENU_START.tscn")
	

	if Input.is_action_just_pressed("help"):
		dialog.visible = !dialog.visible
		var character = 1
		var text = ""
		if zones == 1:
			text = "Здравствуй путник, что не можешь выйти, дам подсказку, нужно использовть print(пароль),\
			 чтобы вывести в консоль пароль(P.S Который час?)"
		elif zones == 2 or zones == 3:
			text = "Дальше только тестовый геймплей"
		emit_signal("change_text", text, character)
