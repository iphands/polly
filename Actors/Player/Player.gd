extends KinematicBody2D

var is_duocorn : bool = false
var mid_jump : int = 0
var score : int = 0
var speed : int = base_speed
var start_position: Vector2 = Vector2()
var velocity : Vector2 = Vector2()
var hp = 4

const base_speed : int = 250
const max_speed : int = base_speed * 3
const max_speed_close = max_speed * 0.80
const jump_force : int = 600
const jump_force_extra : float = jump_force * 0.030
const gravity : int = 2000

onready var duo_sprite : AnimatedSprite = get_node("DuocornSprite")
onready var uni_sprite : AnimatedSprite = get_node("UnicornSprite")
onready var sprite : AnimatedSprite = duo_sprite
onready var platform : CollisionShape2D = get_node("CollisionShape2D")
onready var particles : Particles2D = get_node("DuocornSprite/Particles2D")

func sprite_handle_jumping():
	# if !is_on_floor() and !Input.is_action_pressed("jump"):
	if !is_on_floor():
		if velocity.y < 0: sprite.play("jump_rising")
		else: sprite.play("jump_falling")
		
func sprite_try_run():
	if ((Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"))
		and (!Input.is_action_pressed("jump") or is_on_floor())):
		sprite.play("run")		

func _ready():
	start_position = position
	do_duocorn(false)

func reset():
	particles.restart()
	do_duocorn(false)
	position = start_position
	speed = base_speed
	velocity.y = 0
	velocity.x = 0

func do_duocorn(b : bool):
	if b:
		sprite = duo_sprite
		is_duocorn = true
		duo_sprite.visible = true
		uni_sprite.visible = false
	else:
		sprite = uni_sprite
		particles.emitting = false
		is_duocorn = false
		uni_sprite.visible = true
		duo_sprite.visible = false

func flip_stuff(dir):
	sprite.flip_h = false if (dir == -1) else true
	particles.process_material.direction.x = dir
	particles.transform[2] = Vector2(-12 * dir, -18)
	particles.rotation_degrees = (-45 * dir)

func _physics_process(delta):
	if hp < 1:
		print("dead")
		queue_free()
	
	var run_speed = speed
	platform.set_disabled(false)
	sprite.speed_scale = 1.00
	velocity.x = (velocity.x * 0.15)

	if is_duocorn and speed >= max_speed_close:	
		particles.emitting = true

	if (Input.is_action_pressed("run") and 
		(Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"))):
		speed *= 1.05
		if speed > max_speed:
			speed = max_speed
		sprite.speed_scale = (speed / base_speed)
	else:
		particles.emitting = false
		speed = base_speed
	
	sprite_try_run()
	sprite_handle_jumping()	

	if Input.is_action_just_pressed("move_left"):    flip_stuff(1)
	elif Input.is_action_just_pressed("move_right"): flip_stuff(-1)

	if Input.is_action_pressed("move_left"):    velocity.x -= run_speed
	elif Input.is_action_pressed("move_right"): velocity.x += run_speed
	elif !Input.is_action_pressed("jump"):      sprite.play("default")

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
	
	if position.y > 220: get_tree().reload_current_scene()

func bounce_back_up():
	velocity.y = -500

func _on_HurtBox_body_entered(body):
	if is_duocorn:
		do_duocorn(false)
	else:
		hp -= 1

	body.bounce_back()
	if (body.global_position.x - global_position.x) > 0:
		velocity.x -= 20000
	else:
		velocity.x += 20000
