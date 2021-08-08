extends KinematicBody2D

enum states { IDLE, ROAM, CHASE }

const MAX_SPEED = 300
const ACCELERATION = 400
const gravity : int = 2000
const ROAM_MAX = 2
const IDLE_STATES = [ states.IDLE, states.ROAM ]
var velocity : Vector2 = Vector2.ZERO
var player = null
var hp = 1
var dying = false
var can_hurt = true
var state = states.ROAM

onready var sprite = $AnimatedSprite
onready var audio_death = $AudioDeath
onready var hit_box = $HitBox
onready var initial_pos = global_position

func _ready():
	sprite.flip_h = true
	$StateTimer.start(rand_range(0, ROAM_MAX))

func die():
	audio_death.play()
	dying = true
	$CollisionMain.set_deferred("disabled", true)
	sprite.queue_free()
	$HitBox.queue_free()
	$HurtBox.queue_free()

	var butterfly = load("res://Actors/BadGuy/Butterfly.tscn").instance()
	get_tree().root.add_child(butterfly)
	butterfly.position = position

func _physics_process(delta):
	if dying: return
	if hp < 1:
		die()
		return

	can_hurt = true
	if player != null:
		sprite.play("run")
		var dist = (player.global_position - global_position).normalized()
		sprite.flip_h =  dist.x < 0
		if (player.global_position.y - global_position.y) < 80:
			velocity.y -= (gravity * 1.1) * delta
			#if abs(player.global_position.x - global_position.x) < 200:
			#	velocity.y -= (gravity * 1.1) * delta
		
		velocity = velocity.move_toward(dist * MAX_SPEED, ACCELERATION * delta)
	elif state == states.ROAM:
		sprite.play("run")
		if abs(global_position.x - initial_pos.x) > 50:
			velocity.x = velocity.x + rand_range(-25, 25)
		else:
			velocity = velocity.move_toward(initial_pos, 0.8)
		sprite.flip_h = velocity.x < 0
		sprite.speed_scale = abs(velocity.x / 200)
		
	else:
		sprite.play("idle")
		velocity = Vector2(0, velocity.y)

	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func player_locked():
	return player != null

func _on_Area2D_body_entered(body):
	state = states.CHASE
	player = body

func _on_Area2D_body_exited(_body):
	state = states.ROAM
	player = null
	
func bounce_back():
	velocity.x *= -1

func _on_AudioDeath_finished():
	self.queue_free()

func _on_HurtBox_area_entered(area):
	can_hurt = false
	var tmp_player = area.get_parent()
	if (tmp_player.global_position.y - global_position.y) < -50:
		hp -= 1
		if hp > 0: $AudioHurt.play()
		tmp_player.bounce_back_up()
		velocity.y += 1000

func _on_StateTimer_timeout():
	if state == states.CHASE: return
	$StateTimer.stop()
	# print("old state: " + str(state))
	state = IDLE_STATES[rand_range(0, IDLE_STATES.size())]
	# print("new state: " + str(state))
	$StateTimer.start(rand_range(0, ROAM_MAX))
