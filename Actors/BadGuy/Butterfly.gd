extends AnimatedSprite

var target = Vector2(rand_range(-9000, 9000), -5000)



func _ready():
	flip_h = global_position.x > target.x
	var colors = [
		Color(0,1,0),
		Color(1,0.45,0.45),
		Color(1,0,1),
		Color(0,0,1),
		Color(1,0.25,1),
		Color(1,1,0.25),
		Color(1,0,0),
		Color(1,0.75,0.75),
		Color(1,0.55,0.55),
	]
	colors.shuffle()
	self_modulate = colors[0]
 
func _physics_process(delta):
	global_position = global_position.move_toward(target, 4)
	if global_position.y > 4000:
		queue_free()
