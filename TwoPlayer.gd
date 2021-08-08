extends Node2D

var chickens = []

onready var player_one = get_node("/root/MainScene/Player")
onready var player_two = get_node("/root/MainScene/Player2")

func _ready():
	$ParallaxBackground/ParallaxLayer/Sprite.global_position.y = 700
	

func restart():
	for chicken in chickens:
		if chicken:
			chicken.queue_free()
	chickens.clear()
	var _tmp = get_tree().reload_current_scene()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		restart()
	
	if Input.is_action_just_pressed("hard_mode"):
		for _i in rand_range(0, 100):
			var chicken : KinematicBody2D = load("res://Actors/BadGuy/BadGuy.tscn").instance()
			chickens.append(chicken)
			var size = rand_range(1.5, 4.5)
			chicken.scale = Vector2(size, size)
			get_tree().root.add_child(chicken)
			chicken.position.y = rand_range(100, 400)
			chicken.position.x = rand_range(200, 7000)


func _on_Timer_timeout():
	
	var new_chickens = []
	for chicken in chickens:
		if chicken != null:
			new_chickens.append(chicken)
	chickens = new_chickens
	
	if chickens.size() > 10:
		return
	
	var chicken : KinematicBody2D = load("res://Actors/BadGuy/BadGuy.tscn").instance()
	chickens.append(chicken)
	
	var size = rand_range(1.5, 4.5)
	chicken.scale = Vector2(size, size)
	get_tree().root.add_child(chicken)
	chicken.position.x = rand_range(50, 2500)
	chicken.position.y = rand_range(400, -800)
	
	if player_one == null && player_two == null:
		restart()

