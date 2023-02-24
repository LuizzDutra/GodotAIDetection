extends RayCast2D
class_name DetectionCast

var target setget change_target
var target_top: Position2D
var target_bottom: Position2D
var target_pos = Vector2.ZERO

var target_dir_abs = 0
export var facing = 2
export var max_range = 500
var target_last_seen_pos = null
var target_seen_point = Vector2.ZERO

var sweep_angle = 0
var func_time = 0
export var func_speed = 2
var cast_rotation = 0

var detecting_target = false
var rot = true

export var collide_bodies = true setget change_collide_bodies
export var collide_areas = true setget change_collide_areas

func _ready():
	collide_with_areas = collide_areas
	collide_with_bodies = collide_bodies

func calculate_cast_scan(delta: float):
	var target_dir = global_position.direction_to(target_pos)
	target_pos = target.global_position
	if target_dir.x == 0:
		target_dir_abs = 0
	else:
		target_dir_abs = int(target_dir.x/abs(target_dir.x))
	match facing:
		target_dir_abs, 2:
			if rot and target_bottom != null and target_top != null:
				calculate_cast_rotation(delta)
			if not rot:
				cast_rotation = 0
			enabled = true
			cast_to = (target_dir.normalized()*max_range).rotated(cast_rotation)
			force_raycast_update()
			
		_:
			enabled = false
	if is_colliding() and get_collider().name == "DetectArea" and target.is_a_parent_of(get_collider()):
		detecting_target = true
		rot = false
		var cast_buffer = [cast_to, get_collision_point()]
		cast_to = ((get_collider().global_position - global_position).normalized()*max_range)
		force_raycast_update()
		if is_colliding() and get_collider().name == "DetectArea":
			target_last_seen_pos = get_collider().global_position
			target_seen_point = get_collision_point() - target_last_seen_pos
		else:
			cast_to = cast_buffer[0]
			force_raycast_update()
			target_seen_point = cast_buffer[1]
			target_last_seen_pos = target_seen_point
			target_pos = target_last_seen_pos
		return
	rot = true
	detecting_target = false
	return

func calculate_cast_rotation(delta: float):
	func_time += delta
	sweep_angle = (target_bottom.global_position - global_position).angle_to(target_top.global_position - global_position)
	cast_rotation = sin(PI * func_time * func_speed) * sweep_angle

func change_target(n):
	target = n
	if n.get("global_positon"):
		target_pos = n.global_position
		return
	
func change_collide_bodies(n):
	collide_bodies = n
	collide_with_bodies = n
func change_collide_areas(n):
	collide_areas = n
	collide_with_areas = n
	
