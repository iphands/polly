extends Area2D

func _ready():
	connect("body_entered", self, "_on_body_enter")

func _on_body_enter(body):
	var player = get_node("/root/MainScene/Player")
	player.do_duocorn(true)
