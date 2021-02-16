extends KinematicBody2D

var score : int = 0

var base_speed : int = 250
var max_speed : int = base_speed * 3
var max_speed_close = max_speed * 0.80
var speed = base_speed
var jump_force : int = 600
var jump_force_extra : int = jump_force * 0.030
var gravity : int = 2000

var velocity : Vector2 = Vector2()
var mid_jump = 0
var start_position: Vector2 = Vector2()
var is_duocorn = false

var forward_old = true
var forward = true

onready var duo_sprite : AnimatedSprite = get_node("DuocornSprite")
onready var uni_sprite : AnimatedSprite = get_node("UnicornSprite")
onready var sprite : AnimatedSprite = duo_sprite
onready var platform : CollisionPolygon2D = get_node("CollisionPolygon2D")
onready var particles : Particles2D = get_node("Particles2D")

func sprite_handle_jumping():
	# if !is_on_floor() and !Input.is_action_pressed("jump"):
	if !is_on_floor():
		if velocity.y < 0: sprite.play("jump_rising")
		else: sprite.play("jump_falling")
		
func sprite_try_run():
	if ((Input.is_action_pressed("move_left") or
		Input.is_action_pressed("move_right"))
		and not Input.is_action_pressed("jump")):
		sprite.play("run")		

func _ready():
	start_position = position
	print(jump_force)
	print(jump_force_extra)
	print(start_position)
	do_duocorn(false)
	print(self.get_path())

func reset():
	particles.restart()
	do_duocorn(false)
	base_speed = 250
	position = start_position
	speed = base_speed
	velocity.y = 0
	velocity.x = 0

func do_duocorn(b : bool):
	if b:
		sprite = duo_sprite
		# particles.emitting = false
		# particles.visible = true
		# particles.restart()
		is_duocorn = true
		duo_sprite.visible = true
		uni_sprite.visible = false 
	else:
		sprite = uni_sprite
		# particles.restart()
		particles.emitting = false
		# particles.visible = false
		is_duocorn = false
		uni_sprite.visible = true
		duo_sprite.visible = false

func _physics_process(delta):
	var run_speed = speed
	platform.set_disabled(false)
	sprite.speed_scale = 1.00
	velocity.x = 0

	if is_duocorn and speed >= max_speed_close:	
		particles.emitting = true

	if (Input.is_action_pressed("run") and 
		(Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"))):
		speed *= 1.02
		if speed > max_speed:
			speed = max_speed
		sprite.speed_scale = (speed / base_speed)
	else:
		particles.emitting = false
		speed = base_speed
	
	sprite_try_run()
	sprite_handle_jumping()	

	forward_old = forward
	if Input.is_action_pressed("move_left"):
		velocity.x -= run_speed
		sprite.flip_h = true
		particles.process_material.direction.x = 1
		particles.transform[2] = Vector2(-9, -9)
		forward = true
	elif Input.is_action_pressed("move_right"):
		sprite.flip_h = false
		velocity.x += run_speed
		particles.process_material.direction.x = -1
		particles.transform[2] = Vector2(9, -9)
		forward = false
	elif !Input.is_action_pressed("jump"):
		sprite.play("default")

	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		if Input.is_action_pressed("move_down"):
			platform.set_disabled(true)
			position.y += 2
			return
		velocity.y -= jump_force
	elif Input.is_action_pressed("jump") and !is_on_floor():
		velocity.y -= jump_force_extra
		if is_duocorn: velocity.y -= jump_force_extra * 0.75
	if position.y > 220:
		reset()
