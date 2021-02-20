extends StaticBody2D

func _on_Area2D_body_entered(body):
	print(body)
	var player = get_node("/root/MainScene/Player")
	player.do_duocorn(true)
