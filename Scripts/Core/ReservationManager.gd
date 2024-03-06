extends Node
var reservations : Array[Reservation] = []

# Function to reserve a position for a unit
# This version attempts to place units in a grid pattern around the target position
func reserve_position(unit: Node, target_position: Vector3, unit_radius: float = 5.0) -> Vector3:
	var position := _find_nearest_available_position(target_position, unit_radius)
	reservations.append(Reservation.new(unit, position, unit_radius))
	return position

# Release the position when a unit reaches its destination or is destroyed
func release_position(unit: Node) -> void:
	reservations = reservations.filter(func(reservation: Reservation) -> bool: return reservation.unit != unit)

# Attempt to find the nearest available position in a grid pattern around the target position
func _find_nearest_available_position(target_position: Vector3, unit_radius: float) -> Vector3:
	var layer := 0
	var position := target_position
	while true:
		var positions_in_layer := _generate_positions_around(target_position, layer, unit_radius)
		for potential_position in positions_in_layer:
			if not _is_position_occupied(potential_position, unit_radius):
				return potential_position
		layer += 1

	 #should reach here but here just to satisfy "Not All code paths return a value" Error
	return Vector3.ZERO

# Generate potential positions around a target in a square layer
func _generate_positions_around(center: Vector3, layer: int, spacing: float) -> Array[Vector3]:
	var positions : Array[Vector3]= []
	if layer == 0:
		return [center]  # The center position for the first layer
	var side_length := layer * 2
	for i in range(-layer, layer + 1):
		positions.append(center + Vector3(i * spacing, 0, -layer * spacing))  # Top side
		positions.append(center + Vector3(i * spacing, 0, layer * spacing))   # Bottom side
	for i in range(-layer + 1, layer):
		positions.append(center + Vector3(-layer * spacing, 0, i * spacing))  # Left side
		positions.append(center + Vector3(layer * spacing, 0, i * spacing))   # Right side
	return positions

# Check if a position is already occupied by another unit
func _is_position_occupied(position: Vector3, radius: float) -> bool:
	for reservation in reservations:
		if position.distance_to(reservation.position) < radius * 2:  # Considering both units' radii
			return true
	return false


