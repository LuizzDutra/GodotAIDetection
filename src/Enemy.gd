extends KinematicBody2D

onready var player: KinematicBody2D = get_parent().get_node("Player")
onready var player_top = player.get_node("Top")
onready var player_bottom = player.get_node("Bottom")

onready var cast = $RayCast2D
onready var alert_scan_timer = $AlertScanTimer
var alert_scan_ready = true
onready var alert_timer = $AlertTimer

var player_dir_abs = 0
var facing = -1
var max_range = 500
var player_last_seen_pos = null
var player_seen_point = Vector2.ZERO

var sweep_angle = 0
var func_time = 0
var func_speed = 2
var cast_rotation = 0

enum {IDLE_STATE, ALERT_STATE, ATTACK_STATE}
var State = 0

func _physics_process(delta):
	if State == IDLE_STATE:
		idle_state_routine(delta)
	if State == ALERT_STATE:
		alert_state_routine(delta)
	if State == ATTACK_STATE:
		attack_state_routine(delta)

func attack_state_routine(delta: float):
	var player_dir = (player_last_seen_pos-global_position)
	#print(global_position)
	#cast.cast_to = player_dir
	#if cast.get_collider() != null and cast.get_collider().name != "DetectArea":
		#player_dir += player_seen_point
		#cast.cast_to = player_dir
	#facing = player_dir_abs
	facing = 2
	#print(player_seen_point)
	if not calculate_cast_scan(delta, player_dir, false):
		State = ALERT_STATE
		#print("ha")
	pass
	

func alert_state_routine(delta: float):
	if player_last_seen_pos == null:
		State = IDLE_STATE
		return
	var player_dir = (player.global_position - global_position)
	#facing = int(player_last_seen_pos.x/abs(player_last_seen_pos.x))
	if calculate_cast_scan(delta, player_dir):
		State = ATTACK_STATE
		alert_scan_timer.stop()
		alert_timer.stop()
		alert_scan_ready = true
	else:
		if alert_scan_timer.is_stopped() and alert_scan_ready:
			alert_scan_timer.start()
			facing = 2
			#alert_timer.start()
			#print("yes")

func idle_state_routine(delta: float):
	var player_dir = global_position.direction_to(player.global_position)
	if calculate_cast_scan(delta, player_dir):
		State = ALERT_STATE

func calculate_cast_scan(delta: float, player_dir: Vector2, rot: bool = true) -> bool:
	#print(facing)
	#print(player_dir)
	if player_dir.x == 0:
		player_dir_abs = 0
	else:
		player_dir_abs = int(player_dir.x/abs(player_dir.x))
	#print(player_dir_abs)
	#print(facing)
	match facing:
		player_dir_abs, 2:
			if rot:
				calculate_cast_rotation(delta)
			if not rot:
				cast_rotation = 0
			cast.enabled = true
			cast.cast_to = (player_dir.normalized()*max_range).rotated(cast_rotation)
			cast.force_raycast_update()
			
		_:
			cast.enabled = false
	if cast.is_colliding() and cast.get_collider().name == "DetectArea":
		var cast_buffer = [cast.cast_to, cast.get_collision_point()]
		cast.cast_to = ((cast.get_collider().global_position - global_position).normalized()*max_range)
		cast.force_raycast_update()
		if cast.is_colliding() and cast.get_collider().name == "DetectArea":
			#print("yes")
			player_last_seen_pos = cast.get_collider().global_position
			player_seen_point = cast.get_collision_point() - player_last_seen_pos
		else:
			#print("here")
			cast.cast_to = cast_buffer[0]
			cast.force_raycast_update()
			player_seen_point = cast_buffer[1]
			player_last_seen_pos = player_seen_point
			
		return true
		
	return false

func calculate_cast_rotation(delta: float):
	func_time += delta
	sweep_angle = (player_bottom.global_position - global_position).angle_to(player_top.global_position - global_position)
	#print(rad2deg(sweep_angle))
	cast_rotation = sin(PI * func_time * func_speed) * sweep_angle

func _process(delta):
	#Debugging
	match State:
		0:
			$Label.text = "Idle"
		1:
			$Label.text = "Alert"
		2:
			$Label.text = "Attack"
	match facing:
		-1:
			$Label2.text = "Left"
		1:
			$Label2.text = "Right"
		2:
			$Label2.text = "All"


func _on_AlertScanTimer_timeout():
	var dir = player_last_seen_pos - global_position
	facing = int(dir.x/abs(dir.x))
	alert_scan_ready = false
	alert_timer.start()


func _on_AlertTimer_timeout():
	State = IDLE_STATE
