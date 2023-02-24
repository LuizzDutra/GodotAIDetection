extends Node2D

func _ready():
	$DetectionCast.target = get_parent().get_node("Enemy")

func _process(delta):
	$DetectionCast.calculate_cast_scan(delta)
