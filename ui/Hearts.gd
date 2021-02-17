extends Node2D

onready var hearts_full = $Label/HeartFull

func _ready():
	set_hearts(4)
	var player = get_node("/root/MainScene/Player")
	player.connect("hearts_changed", self, "set_hearts")

func set_hearts(hearts : int):
	hearts_full.visible = hearts > 0
	hearts_full.margin_right = hearts * 53
