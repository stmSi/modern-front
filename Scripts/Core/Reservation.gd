class_name Reservation

var unit: Node
var position: Vector3
var radius: float

func _init(p_unit: Node, p_position: Vector3, p_radius: float) -> void:
	unit = p_unit
	position = p_position
	radius = p_radius
