extends Node2D

var chickens = []

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		for chicken in chickens:
			if chicken and is_instance_valid(chicken):
				chicken.queue_free()
		chickens.clear()
		var _tmp = get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("hard_mode"):
		for _i in rand_range(0, 100):
			var chicken : KinematicBody2D = load("res://Actors/BadGuy/BadGuy.tscn").instance()
			chickens.append(chicken)
			var size = rand_range(1.5, 4.5)
			chicken.scale = Vector2(size, size)
			get_tree().root.add_child(chicken)
			chicken.position.y = rand_range(100, 400)
			chicken.position.x = rand_range(200, 7000)
