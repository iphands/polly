extends KinematicBody2D

const MAX_SPEED = 300
const ACCELERATION = 400
const gravity : int = 2000
var velocity : Vector2 = Vector2.ZERO
var player = null
var hp = 1
var dying = false
var can_hurt = true

onready var sprite = $AnimatedSprite
onready var death = $AudioDeath
onready var hit_box = $HitBox

func _ready():
	sprite.flip_h = true

func _physics_process(delta):
	if dying: return
	
	if hp < 1:
		dying = true
		$CollisionMain.set_deferred("disabled", true)
		sprite.queue_free()
		$HitBox.queue_free()
		$HurtBox.queue_free()
		death.play()

	if player != null:
		sprite.play("run")
		var dist = (player.global_position - global_position).normalized()
		sprite.flip_h =  dist.x < 0
		if (player.global_position.y - global_position.y) < 80:
			velocity.y -= (gravity * 1.1) * delta
			#if abs(player.global_position.x - global_position.x) < 200:
			#	velocity.y -= (gravity * 1.1) * delta
		
		velocity = velocity.move_toward(dist * MAX_SPEED, ACCELERATION * delta)
	else:
		sprite.play("idle")
		velocity = Vector2(0, velocity.y)

	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func player_locked():
	return player != null

func _on_Area2D_body_entered(body):
	player = body

func _on_Area2D_body_exited(_body):
	player = null
	
func bounce_back():
	velocity.x *= -1

func _on_HurtBox_body_entered(_body):
	if (player.global_position.y - global_position.y) < -50:
		# print(player.global_position.y - global_position.y)
		hp -= 1
		if hp > 0: $AudioHurt.play()
		player.bounce_back_up()
		velocity.y += 1000

func _on_AudioDeath_finished():
	self.queue_free()
