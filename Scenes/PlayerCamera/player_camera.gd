extends Node3D

var edge_scroll_speed: float = 70.0
var edge_threshold: float = 15.0 # 10 pixel

var drag_speed: float = 5
var is_dragging: bool = false
var triggerred_dragged_threshold: float = 15.0
var last_mouse_position: Vector2 = Vector2.ZERO
var is_reverse_gripped: int = -1 # 1

# Speed and Zoom Variables
var zoom_speed: float = 10.0
var zoom_min: float = 5.0
var zoom_max: float = 100.0

# Focus Variables
var focus_target: Node3D = null
var cinematic_speed: float = 5.0

@onready var camera_root = self

func _ready():
	# Initialize camera position, if needed
	pass


func _process(delta: float):
	handle_camera_movement(delta)
	handle_zoom(delta)
	handle_camera_edge_movement(delta)
	handle_camera_drag_movement(delta)
	if focus_target:
		follow_focus_target(delta)

#func _input(event):

func handle_camera_movement(delta: float):
	var movement = Vector3.ZERO
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_down"):
		movement.z += 1
	if Input.is_action_pressed("ui_up"):
		movement.z -= 1
	movement = movement.normalized() * edge_scroll_speed * delta
	camera_root.global_transform.origin += movement

func handle_zoom(delta: float):
	if Input.is_action_pressed("zoom_in"):
		if position.y > zoom_min:
			position.y -= zoom_speed * delta
	if Input.is_action_pressed("zoom_out"):
		if position.y < zoom_max:
			position.y += zoom_speed * delta

func handle_camera_edge_movement(delta: float):
	var mouse_position = get_viewport().get_mouse_position()

	var viewport_size = get_viewport().size
	if mouse_position.x > viewport_size.x - edge_threshold:
		# Move camera right
		camera_root.global_transform.origin.x += edge_scroll_speed * get_process_delta_time()
	if mouse_position.x <= edge_threshold:
		camera_root.global_transform.origin.x -= edge_scroll_speed * get_process_delta_time()
		
	if mouse_position.y > viewport_size.y - edge_threshold:
		# Move camera right
		camera_root.global_transform.origin.z += edge_scroll_speed * get_process_delta_time()
	if mouse_position.y <= edge_threshold:
		camera_root.global_transform.origin.z -= edge_scroll_speed * get_process_delta_time()

func handle_camera_drag_movement(delta):
	### CnC Generals ZH like camera movement
	if Input.is_action_just_pressed("mouse_drag"):
		is_dragging = true
		last_mouse_position = get_viewport().get_mouse_position()
	elif Input.is_action_just_released("mouse_drag"):
		is_dragging = false
	
	elif Input.is_action_pressed("mouse_drag"):
		var relative_mouse_pos = last_mouse_position - get_viewport().get_mouse_position()
		if relative_mouse_pos.length() >= triggerred_dragged_threshold:
			var drag_vector = relative_mouse_pos * drag_speed * delta
			translate(-Vector3(drag_vector.x, 0, drag_vector.y))

func follow_focus_target(delta: float):
	var direction = (focus_target.global_transform.origin - global_transform.origin).normalized()
	global_transform.origin += direction * cinematic_speed * delta
	look_at(focus_target.global_transform.origin, Vector3.UP)

# Call this function to set a new focus target
func set_focus_target(target: Node3D):
	focus_target = target
