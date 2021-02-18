extends AnimatedSprite

var target = Vector2(rand_range(-9000, 9000), -5000)
const colors = [
	Color(0,1,0),
	Color(1,0.45,0.45),
	Color(1,0,1),
	Color(0,0,1),
	Color(1,0.25,1),
	Color(1,1,0.25),
	Color(1,0,0),
	Color(1,0.25,0.75),
]

func _ready():
	flip_h = global_position.x > target.x
	self_modulate = colors[rand_range(0, colors.size())]
 
func _physics_process(_delta):
	global_position = global_position.move_toward(target, 4)
	if global_position.y < -1024:
		queue_free()
