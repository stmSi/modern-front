extends Node3D

### Edge Pan Movement
var edge_scroll_speed: float = 70.0
var edge_threshold: float = 15.0 # pixel to trigger edge panning

### Right-Click Drag Movement
var last_mouse_position: Vector2 = Vector2.ZERO
var drag_speed: float = 5
var is_dragging: bool = false
var triggerred_dragged_threshold: float = 50.0 # pixels to trigger drag movement

### Grip movement
var initial_point := Vector3.ZERO
var plane_normal := Vector3.UP  # Assuming a horizontal plane
var is_gripping: bool = false
# Distance from the origin; adjust based on ground plane
var plane_distance: float = 0

# Speed and Zoom Variables
var zoom_speed: float = 10.0
var zoom_min: float = 5.0
var zoom_max: float = 100.0

# Focus Variables
var focus_target: Node3D = null
var cinematic_speed: float = 5.0
@export var floor_mask := 1

# Assuming you have a way to reference all character instances,
# for simplicity, this example uses a single reference.
@export var selected_character: Node = null

@onready var camera_root: Node3D = self
@onready var camera_3d: Camera3D = $Arm/Camera3D

func _ready() -> void:
	# Initialize camera position, if needed
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var inputEventMouseButton := (event as InputEventMouseButton)
		if inputEventMouseButton.button_index == MOUSE_BUTTON_RIGHT and not inputEventMouseButton.pressed:
			if is_dragging:
				return
			# Perform a raycast from the camera to the mouse position.
			var ray_origin := camera_3d.project_ray_origin(inputEventMouseButton.position)
			var ray_end := ray_origin + camera_3d.project_ray_normal(inputEventMouseButton.position) * 1000
			var space_state := get_world_3d().direct_space_state
			var ray_query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end, floor_mask)
			var result := space_state.intersect_ray(ray_query)
			if result.size() > 0:
				print("Hit: ", result.collider, " at position: ", result.position)
				if selected_character and result.collider is Node3D:
					print(selected_character.is_in_group("MovableUnits"))
					# If a character is selected and we clicked on a Node3D node (e.g., the ground), move the character.
					selected_character.call("move_to", result.position)


func _process(delta: float) -> void:
	handle_camera_wasd_arrow_movement(delta)
	handle_zoom(delta)
	handle_camera_edge_movement(delta)
	handle_camera_drag_movement(delta)
	handle_camera_grip_movement(delta)
	if focus_target:
		follow_focus_target(delta)

func handle_camera_wasd_arrow_movement(delta: float) -> void:
	var movement: Vector3 = Vector3.ZERO
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

func handle_zoom(delta: float) -> void:
	if Input.is_action_pressed("zoom_in"):
		if position.y > zoom_min:
			position.y -= zoom_speed * delta
	if Input.is_action_pressed("zoom_out"):
		if position.y < zoom_max:
			position.y += zoom_speed * delta

func handle_camera_edge_movement(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	var viewport_size := get_viewport().get_visible_rect().size

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

func handle_camera_drag_movement(delta: float) -> void:
	### CnC Generals ZH like camera movement
	if Input.is_action_just_pressed("mouse_drag"):
		last_mouse_position = get_viewport().get_mouse_position()
	elif Input.is_action_just_released("mouse_drag"):
		is_dragging = false

	elif Input.is_action_pressed("mouse_drag"):
		var relative_mouse_pos := last_mouse_position - get_viewport().get_mouse_position()
		if relative_mouse_pos.length() >= triggerred_dragged_threshold:
			is_dragging = true
			var drag_vector := (relative_mouse_pos.length() - triggerred_dragged_threshold) * relative_mouse_pos.normalized() * drag_speed * delta
			translate(-Vector3(drag_vector.x, 0, drag_vector.y))


func handle_camera_grip_movement(delta: float) -> void:
	### Like Dota2-inspired camera movement
	if Input.is_action_pressed("mouse_grip") and not is_gripping:
		initial_point = cast_ray_to_plane()
		is_gripping = true
	elif Input.is_action_just_released("mouse_grip"):
		is_gripping = false

	if is_gripping:
		var current_point := (cast_ray_to_plane() as Vector3)
		if current_point:
			var displacement := initial_point - current_point
			# Move the camera based on the displacement
			self.global_transform.origin += displacement


func cast_ray_to_plane() -> Variant:
	var mouse_pos := camera_3d.get_viewport().get_mouse_position()
	var from := camera_3d.project_ray_origin(mouse_pos)
	var dir := camera_3d.project_ray_normal(mouse_pos)

	var plane := Plane(plane_normal, plane_distance)
	return plane.intersects_ray(from, dir)


func follow_focus_target(delta: float) -> void:
	var direction := (focus_target.global_transform.origin - global_transform.origin).normalized()
	global_transform.origin += direction * cinematic_speed * delta
	look_at(focus_target.global_transform.origin, Vector3.UP)

# Call this function to set a new focus target
func set_focus_target(target: Node3D) -> void:
	focus_target = target
