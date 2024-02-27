#extends CharacterBody3D
#
#
#const SPEED = 100.0
#const JUMP_VELOCITY = 4.5
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#var _collided := move_and_slide()

extends CharacterBody3D

const SPEED = 100.0
const JUMP_VELOCITY = 4.5
var target_position: Vector3 = Vector3.ZERO
var is_moving_to_target := false

func _physics_process(delta: float) -> void:
	# Add gravity if the character is not on the floor.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Move towards target position if set
	if is_moving_to_target:
		var direction := (target_position - global_transform.origin).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Check if close to the target position to stop moving
		if global_transform.origin.distance_to(target_position) < 1.0:
			is_moving_to_target = false
			velocity.x = 0
			velocity.z = 0
	else:
		# Handle manual movement/deceleration when not moving to target
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if input_dir.length() > 0:
			var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.z = move_toward(velocity.z, 0, SPEED * delta)

	var _collided := move_and_slide()

func move_to(position: Vector3) -> void:
	target_position = position
	is_moving_to_target = true
