extends KinematicBody2D

onready var player: KinematicBody2D = get_parent().get_node("Player")
onready var player_top = player.get_node("Top")
onready var player_bottom = player.get_node("Bottom")

onready var cast: DetectionCast = $RayCast2D
onready var alert_scan_timer = $AlertScanTimer
var alert_scan_ready = true
onready var alert_timer = $AlertTimer



enum {IDLE_STATE, ALERT_STATE, ATTACK_STATE}
var State = 0

func _ready():
	cast.target = player
	cast.target_top = player_top
	cast.target_bottom = player_bottom

func _physics_process(delta):
	cast.calculate_cast_scan(delta)
	match State:
		IDLE_STATE:
			idle_state_routine(delta)
		ALERT_STATE:
			alert_state_routine(delta)
		ATTACK_STATE:
			attack_state_routine(delta)

func attack_state_routine(delta: float):#attack behavior goes here
	#raycast administration
	cast.facing = 2
	if not cast.detecting_target:
		State = ALERT_STATE
	#rest of behavior 
	

func alert_state_routine(delta: float):#alert behavior goes here
	#raycast administration
	if cast.detecting_target:
		State = ATTACK_STATE
		alert_scan_timer.stop()
		alert_timer.stop()
		alert_scan_ready = true
	else:
		if alert_scan_timer.is_stopped() and alert_scan_ready:
			alert_scan_timer.start()
			cast.facing = 2
	#rest of behavior goes here

func idle_state_routine(delta: float):#idle behavior goes here
	#raycast administration
	if cast.detecting_target:
		State = ALERT_STATE
	#rest of behavior



func _process(delta):
	#Debugging
	match State:
		0:
			$Label.text = "Idle"
		1:
			$Label.text = "Alert"
		2:
			$Label.text = "Attack"
	match cast.facing:
		-1:
			$Label2.text = "Left"
		1:
			$Label2.text = "Right"
		2:
			$Label2.text = "All"


func _on_AlertScanTimer_timeout():
	var dir = cast.target_last_seen_pos - global_position
	cast.facing = int(dir.x/abs(dir.x))
	alert_scan_ready = false
	alert_timer.start()


func _on_AlertTimer_timeout():
	State = IDLE_STATE
