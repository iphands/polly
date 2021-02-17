extends KinematicBody2D

enum STATE { RUNNING, IDLE, MID_AIR}

var is_duocorn : bool = false
var mid_jump : int = 0
var score : int = 0
var speed : int = base_speed
var start_position: Vector2 = Vector2()
var velocity : Vector2 = Vector2()
var hp = 4
var state = STATE.IDLE
var last_state = state

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
onready var audio_gallop = $AudioGallop
onready var audio_sparkles = $AudioSparkles

signal hearts_changed

func sprite_handle_jumping():
	# if !is_on_floor() and !Input.is_action_pressed("jump"):
	if !is_on_floor():
		if velocity.y < 0: sprite.play("jump_rising")
		else: sprite.play("jump_falling")
		
func sprite_try_run():
	if ((Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"))
		and (!Input.is_action_pressed("jump") or is_on_floor())):
		state = STATE.RUNNING
		sprite.play("run")

func _ready():
	print(get_path())
	start_position = position
	emit_signal("hearts_changed", hp)
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
		hp = 4
		emit_signal("hearts_changed", -1)
		$AudioEvolve.play()
		is_duocorn = true
		duo_sprite.visible = true
		uni_sprite.visible = false
	else:
		sprite = uni_sprite
		particles.emitting = false
		audio_sparkles.stop()
		emit_signal("hearts_changed", 4)
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
		if !audio_sparkles.playing:
			audio_sparkles.playing = true

	if (Input.is_action_pressed("run") and 
		(Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"))):
		speed *= 1.05
		if speed > max_speed: speed = max_speed
		var pitch = speed / (max_speed * 1.0) + 0.40
		pitch = clamp(pitch, 1.05, 1.40)
		audio_gallop.pitch_scale = pitch
		audio_sparkles.volume_db = 0
		sprite.speed_scale = (speed / base_speed)
	else:
		audio_gallop.pitch_scale = 1.0
		particles.emitting = false
		audio_sparkles.volume_db -= 0.5
		if audio_sparkles.volume_db < -40:
			audio_sparkles.stop()
		speed = base_speed
	
	sprite_try_run()
	sprite_handle_jumping()	

	if Input.is_action_just_pressed("move_left"):    flip_stuff(1)
	elif Input.is_action_just_pressed("move_right"): flip_stuff(-1)

	if Input.is_action_pressed("move_left"):  
		velocity.x -= run_speed
	elif Input.is_action_pressed("move_right"):
		velocity.x += run_speed
	elif !Input.is_action_pressed("jump"):
		sprite.play("default")
		state = STATE.IDLE

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
	
	if position.y > 220: die()
	
	if !is_on_floor():
		state = STATE.MID_AIR

	if last_state != state:	
		audio_gallop.playing = STATE.RUNNING == state

	last_state = state

func die():
	emit_signal("hearts_changed", 0)
	hp = 0

func bounce_back_up():
	velocity.y = -500

func _on_HurtBox_body_entered(body):
	if is_duocorn:
		hp = 4
		do_duocorn(false)
	else:
		hp -= 1
		emit_signal("hearts_changed", hp)

	body.bounce_back()
	if (body.global_position.x - global_position.x) > 0:
		velocity.x -= 20000
	else:
		velocity.x += 20000
