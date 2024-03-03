extends CharacterBody3D
class_name MovableUnit

const SPEED = 80.0
var is_moving_to_target := false
var movement_delta: float

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		return

	movement_delta = SPEED * delta
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_delta
	if navigation_agent.avoidance_enabled:
		### We don't need this???
		navigation_agent.velocity = new_velocity
	else:
		_on_navigation_agent_3d_velocity_computed(new_velocity)


func move_to(position: Vector3) -> void:
	navigation_agent.set_target_position(position)


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
