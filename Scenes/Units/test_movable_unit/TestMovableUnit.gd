extends CharacterBody3D
class_name MovableUnit

const SPEED = 80.0
var is_moving_to_target := false
var movement_delta: float
var target_position: Vector3
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
#
func _ready() -> void:
	ReservationManager.reserve_position(self, position)

func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		return

	movement_delta = SPEED * delta
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var direction_to_next_position: Vector3 = global_position.direction_to(next_path_position)
	var distance_to_next_position: float = global_position.distance_to(next_path_position)
	var new_velocity: Vector3 = direction_to_next_position * movement_delta

	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = new_velocity
		#pass
	#else:
		##_on_navigation_agent_3d_velocity_computed(new_velocity)
		#pass


func move_to(position: Vector3) -> void:
	ReservationManager.release_position(self)
	target_position = ReservationManager.reserve_position(self, position)
	navigation_agent.set_target_position(target_position)


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
