extends CharacterBody2D


var MOVE_SPEED = 200.0
var gravity = 980.0



var coyote_time = 0.1
var coyote_timer = 0.0
var coyote_can = 0



var max_stamina = 4.0
var stamina = 4.0



var DESH_SPEED = Vector2(400.0, 200.0)

var max_dash = 1.0
var dash = 1.0

var dash_timer = 0
var dash_time = 0.15



var JUMP_VELOCITY = -300.0

var buffer_jump_time = 0.1
var buffer_jump_timer = 0.0
var buffer_jump_can = 0




@onready var camera = $Camera2D
@onready var fade_rect = $CanvasLayer/ColorRect

#Состояния игрока
@onready var anim = $Animations
enum {
	MOVE,
	DASH,
	JUMP,
	FALL,
	GRABING,
	DEATH,
	CAMERA_MOVE,
	DIALOG
}
var state = MOVE

func _ready():
	#Лимиты для камеры
	var areas = get_tree().get_nodes_in_group("screen_maps")
	for area in areas:
		area.connect("get_area_screen", Callable(self, "_change_camera"))


	
	$".".visible = true


func _physics_process(delta: float) -> void:
	update_timer(delta)

	match state:
		MOVE: state_move(delta)
		JUMP: state_jump(delta)
		DASH: state_dash(delta)
		GRABING: state_grabing(delta)
		CAMERA_MOVE: state_camera()
		FALL: state_fall(delta)
	
	if buffer_jump_can and is_on_floor(): state = JUMP
	
	
	move_and_slide()
	
	
func update_timer(delta):
	if is_on_floor():
		coyote_timer = coyote_time
		coyote_can = 1
	else:
		coyote_timer -= delta
		if coyote_timer <= 0: coyote_can = 0
	
	if buffer_jump_can:
		buffer_jump_timer -= delta
		if buffer_jump_timer <= 0: buffer_jump_can = 0
	
	if dash_timer > 0: dash_timer -= delta
	
	



func state_fall(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y >= 0: anim.play("foal")
	else: state = MOVE
	
	#передвижение в воздухе
	var direction := Input.get_axis("left", "right")
	if direction: velocity.x = lerp(velocity.x, direction * MOVE_SPEED, 0.2)
	else:  velocity.x = lerp(velocity.x, 0.0, 0.15)
	
	if direction == 1: anim.flip_h = 0
	elif direction == -1: anim.flip_h = 1
	
	
	#Рывок
	if Input.is_action_just_pressed("dash") and dash > 0: state = DASH
	

func state_move(delta):
	if is_on_floor():
		#Востонавливаем стандартные характеристики
		stamina = max_stamina
		dash = max_dash
	else: state = FALL
	
	
	#Передвижение влево и вправо
	var direction := Input.get_axis("left", "right")
	if direction: 
		velocity.x = lerp(velocity.x, direction * MOVE_SPEED, 0.2)
		if is_on_floor(): anim.play("run")
	else:  velocity.x = lerp(velocity.x, 0.0, 0.15)
	
	#Направление анимации
	if direction == 1: anim.flip_h = 0
	elif direction == -1: anim.flip_h = 1
	else: anim.play("idle")
	
	
	#Рывок
	if Input.is_action_just_pressed("dash") and dash > 0: state = DASH
	
	#Прыжок
	if Input.is_action_pressed("jump"): state = JUMP

func state_jump(delta):
	#Прыжок
	if (is_on_floor() or coyote_can):
		velocity.y = JUMP_VELOCITY
		anim.play("jump")
	else: 
		buffer_jump_can = 1
		buffer_jump_timer = buffer_jump_time
	state = FALL
	
	
	
	
func state_dash(delta):
	if dash > 0:
		dash_timer = dash_time
		dash -= 1
		var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
		if direction == Vector2(0, 0): velocity.x = DESH_SPEED.x * (-1 if anim.flip_h else 1)
		else: velocity = direction.normalized() * DESH_SPEED
		
		anim.play("dash")
		await get_tree().create_timer(1).timeout
		
	if not dash_timer > 0:
		state = MOVE


func state_grabing(delta):
	pass
	#if not grab: velocity = Vector2.ZERO
	#if stamina > 0:
		#stamina -= delta / 5
		#if Input.is_action_just_pressed("jump"): 
			#state = JUMP
			#grab = 1
		#
		#
		#
		#print(stamina)
	#else:
		#state = MOVE
	#if Input.is_action_just_released("grab"): 
		#state = MOVE
		#grab = 1

	
	
#Смена лимитов для камеры
func state_camera():
	velocity = lerp(velocity, Vector2.ZERO, 0.1)
	anim.play("idle")
	await  get_tree().create_timer(1.5).timeout
	state = MOVE

func _change_camera(position, size):
	state = CAMERA_MOVE
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
