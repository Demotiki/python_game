extends CharacterBody2D
	
var SPEED = 200.0
var DESH_SPEED = 300
var JUMP_VELOCITY = -300.0
var gravity = 980
var stamina = 4
var dash = 1
var dash_nap = Vector2()


@onready var anim = $Animations
@onready var camera = $Camera2D
@onready var fade_rect = $CanvasLayer/ColorRect

#Состояния игрока
enum {
	MOVE,
	CAMERA_MOVE,
	DASH
}
var state = MOVE

func _ready():
	#Лимиты для камеры
	var areas = get_tree().get_nodes_in_group("screen_maps")
	for area in areas:
		area.connect("get_area_screen", Callable(self, "_change_camera"))
	
	$".".visible = true

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			state_move(delta)
		DASH:
			state_dash()
		CAMERA_MOVE:
			pass

	
	if Input.is_action_just_pressed("dash") and dash:
		dash -= 1 
		state = DASH
		dash_nap = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
					#anim.play("death")
					#await anim.animation_finished
					#get_tree().change_scene_to_file("res://data/scn/MENU_START.tscn")
	move_and_slide() #Плвная анимация

func state_move(delta):
	if is_on_floor(): 
		stamina = 4
		dash = 1
	
	if not is_on_floor() and not (is_on_wall() and Input.is_action_pressed("grab")):
		velocity.y += gravity * delta
		if Input.is_action_pressed("down"): velocity.y += SPEED / 50
		
	if velocity.y > 0:
		anim.play("foal")

	if Input.is_action_just_pressed("jump") and is_on_floor() and \
		not(is_on_wall() and Input.is_action_pressed("grab")) and stamina > 0:
		stamina -= 1
		velocity.y += JUMP_VELOCITY
		anim.play("jump")
	if is_on_wall() and Input.is_action_pressed("grab"):
		if not anim.animation_finished:
			anim.play("grab")
		if velocity.y > 0: velocity.y = 0
			
		var dis = Input.get_axis("up", "down")
		if dis and stamina > 0: 
			velocity.y = SPEED / 4 * dis
			stamina -= 0.02
		else: velocity.y += gravity * delta
		
		if Input.is_action_just_pressed("jump") and stamina > 0:
			stamina -= 1
			velocity.y += JUMP_VELOCITY / 1.5
			anim.play("jump")
			var direction := Input.get_axis("left", "right")
			if direction: velocity.x = direction * SPEED
	
	else:
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
			if direction == 1: 
				if velocity.y == 0:
					anim.play("run")
				anim.flip_h = false
			else: 
				if velocity.y == 0:
					anim.play("run")
				anim.flip_h = true
		else:
			if velocity.y == 0:
				anim.play("idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)

func state_dash():
	if dash_nap.y and dash_nap.x:
		if dash_nap.y == -1: velocity.y = -1 * DESH_SPEED / 1.5
		elif dash_nap.y == 1: velocity.y = DESH_SPEED / 1.5
		if dash_nap.x == -1: velocity.x = -1 * DESH_SPEED
		elif dash_nap.x == 1: velocity.x = DESH_SPEED
	elif dash_nap.y:
		if dash_nap.y == -1: velocity.y = -1 * DESH_SPEED / 1.5
		elif dash_nap.y == 1: velocity.y = DESH_SPEED / 1.5
	elif dash_nap.x:
		if dash_nap.x == -1: velocity.x = -1 * DESH_SPEED
		elif dash_nap.x == 1: velocity.x = DESH_SPEED
		velocity.y = 0
	else:
		if anim.flip_h: velocity.x = -1 * DESH_SPEED
		else: velocity.x = DESH_SPEED
		velocity.y == 0
	anim.play("dash")
	await anim.animation_finished
	
	state = MOVE

func state_window():
	await  get_tree().create_timer(10000).timeout
		
#Смена лимитов для камеры
func _change_camera(position, size):
	var viewport_size = get_viewport().get_visible_rect().size
	var new_zoom = min(viewport_size.x / size.x, viewport_size.y / size.y)
	var new_limits = {
		"limit_left": position.x - size.x,
		"limit_right": position.x + size.x,
		"limit_top": position.y - size.y,
		"limit_bottom": position.y + size.y,
		"zoom": Vector2(new_zoom, new_zoom)
		}
	fade(true)
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	
	for property in new_limits:
		tween.tween_property(camera, property, new_limits[property], 0.5)
	await tween.finished
	fade(false)

	
#Затемнение
func fade(YES_NO: bool, duration: float = 0.1):
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if YES_NO: 
		$CanvasLayer.scale = Vector2(100, 100)
		tween.tween_property(fade_rect, "color:a", 4, duration)
		await tween.finished
	else: 
		tween.tween_property(fade_rect, "color:a", 0, duration)
		await tween.finished
		$CanvasLayer.scale = Vector2(0.1, 0.1)
