extends Node3D

## orbits point in 3d space with zoom
## map inputs "camera_zoom_in" and "camera_zoom_out" for zoom
## if camera is orthoganal, size will be changed instead of distance from point

@export_group("Orbiting")
@export var rotation_enabled: bool = true
@export var mouse_multiplier_y: float = 0.01
@export var mouse_multiplier_x: float = 0.005
@export var camera_limit_x: Vector2 = Vector2(-40,0)
@export_enum("LMB:0","RMB:1","MMB:2","Button4:6","Button5:7") var rotate_mask_flag: int = 1
@export var rotate_button: MouseButton = MOUSE_BUTTON_RIGHT
@export var capture_mouse_while_rotating: bool = true
@export_subgroup("Physics")
@export var enable_physics: bool = true
@export var friction = 0.05
# Not needed @export var max_speed = 500
# https://docs.godotengine.org/en/4.2/classes/class_%40globalscope.html#enum-globalscope-mousebuttonmask
@export_group("Zooming")
@export var zoom_enabled: bool = true
@export var zoom_limit: Vector2 = Vector2(7,20)
@export var zoom_speed: float = 0.05 # Speed camera moves
@export var zoom_factor: float = 0.5 # Adjustment value
@export var zoom_in_input: String = "camera_zoom_in"
@export var zoom_out_input: String = "camera_zoom_out"
#@export var fov_limit: Vector2 = Vector2(35,100)
#@export var fov_zoom_speed: int = 1

@onready var camera = $Camera3D

var cur_speed: Vector2 = Vector2(0,0)
var zoom_goal: float = 0
var ortho = false

func get_camera_global_position():
	return(camera.global_position)

func get_camera_global_rotation():
	return(camera.global_rotation)

func get_camera():
	return(camera)

## thank you to reddit user u/JakB
## https://www.reddit.com/r/godot/comments/1cd1xf9/how_to_detect_mouse_click_in_3d_space_w_gridmaps/
func get_cursor_world_position() -> Vector3:
	const RAY_DISTANCE = 64.0
	
	if not is_instance_valid(camera): return Vector3.ZERO
	var mouse_pos = get_viewport().get_mouse_position()
	
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * RAY_DISTANCE
	
	var ray_params := PhysicsRayQueryParameters3D.create(from, to)
	var ray_result: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray_params)
	
	return ray_result.get("position", to) # return Vector3.ZERO if needed

func _ready():
	if camera.projection == camera.PROJECTION_ORTHOGONAL:
		ortho=true
	if not ortho: zoom_goal=camera.position.z
	else: zoom_goal=camera.size

func _input(event):
	pass

func _unhandled_input(event):
	if zoom_enabled:
		if event.is_action(zoom_in_input):
			zoom_goal=zoom_goal-zoom_factor
			zoom_goal=clamp(zoom_goal,zoom_limit.x,zoom_limit.y)
		if event.is_action(zoom_out_input):
			zoom_goal=zoom_goal+zoom_factor
			zoom_goal=clamp(zoom_goal,zoom_limit.x,zoom_limit.y)
	if rotation_enabled:
		if event is InputEventMouseButton:
			if event.button_index == rotate_button:
				if event.pressed:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				if not event.pressed:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event is InputEventMouseMotion:
			if bool(event.button_mask & (1 << rotate_mask_flag)): # if button mask contains flag
				#print("in event")
				var relative = event.screen_relative
				if enable_physics: # if physics enabled add speed to process later
					cur_speed.y += int(relative.x)
					cur_speed.x += int(relative.y)
				else:
					rotate_y(relative.x * mouse_multiplier_y)
					rotate_x(relative.y * mouse_multiplier_x)

func _process(delta):
	if enable_physics and rotation_enabled:
		if cur_speed != Vector2(0,0): # if current speed not 0
			#print(cur_speed)
			global_rotate(Vector3(0,1,0),deg_to_rad(cur_speed.y * mouse_multiplier_y))
			rotate_object_local(Vector3(1,0,0),deg_to_rad(cur_speed.x * mouse_multiplier_x))
			rotation_degrees.x = clamp(rotation_degrees.x,camera_limit_x.x,camera_limit_x.y)
			cur_speed.x = lerpf(cur_speed.x, 0, friction) # bring to zero by factor of friction
			cur_speed.y = lerpf(cur_speed.y, 0, friction)
	if zoom_enabled:
		if not ortho:
			if camera.position.z != zoom_goal:
				camera.position.z = lerpf(camera.position.z,zoom_goal,zoom_speed)
		else:
			if camera.size != zoom_goal:
				camera.size = lerpf(camera.size,zoom_goal,zoom_speed)
