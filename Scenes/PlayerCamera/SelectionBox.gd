extends Control

### Selection Box Variables
var is_selecting: bool = false
var selection_start: Vector2 = Vector2.ZERO
var selection_end: Vector2 = Vector2.ZERO
@onready var selection_box: Control = self
@onready var selection_box_panel: Panel = $Panel

@export var selection_color: = Color.AQUAMARINE
@export var selection_border_color := Color.AQUA
@export var bottom_alpha_value: float = 0.1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var inputEventMouseButton := (event as InputEventMouseButton)
		if inputEventMouseButton.button_index == MOUSE_BUTTON_LEFT:
			if inputEventMouseButton.pressed:
				is_selecting = true
				selection_start = inputEventMouseButton.position
				selection_end = inputEventMouseButton.position
			else:
				is_selecting = false
				selection_start = Vector2.ZERO
				selection_end = Vector2.ZERO
				queue_redraw()

	if event is InputEventMouseMotion and is_selecting:
		selection_end = (event as InputEventMouseMotion).position
		queue_redraw()

func update_selection_box() -> void:
	var rect_min := selection_start
	var rect_max := selection_end
	if selection_end.x < selection_start.x:
		rect_min.x = selection_end.x
		rect_max.x = selection_start.x
	if selection_end.y < selection_start.y:
		rect_min.y = selection_end.y
		rect_max.y = selection_start.y
	selection_box.get_rect().position = rect_min
	selection_box.get_rect().size = rect_max - rect_min
	var color := Color.html("#60b05578")
	var points := PackedVector2Array([selection_start,
								  Vector2(selection_end.x, selection_start.y),
								  selection_end,
								  Vector2(selection_start.x, selection_end.y),
								  selection_start])

	var colors := PackedColorArray([
		Color.html("#60b05578"), # Top Start
		Color.html("#60b05578"), # Top End
		Color.html("#60905528"), # Bottom End
		Color.html("#60905528"), # Bottom Start
		Color.html("#60b05578")  # Back to Top Start for closure
	])

	draw_polyline_colors(points, colors, 2.0, true)

func _draw() -> void:
	if is_selecting:
		# Calculate rectangle bounds
		var rect_min := selection_start
		var rect_max := selection_end
		if selection_end.x < selection_start.x:
			rect_min.x = selection_end.x
			rect_max.x = selection_start.x
		if selection_end.y < selection_start.y:
			rect_min.y = selection_end.y
			rect_max.y = selection_start.y

		# Gradient fill
		var points := PackedVector2Array([
			rect_min,
			Vector2(rect_max.x, rect_min.y),
			rect_max,
			Vector2(rect_min.x, rect_max.y)
		])

		var top_color := selection_color
		var bottom_color := Color(
			selection_color.r,
			selection_color.g,
			selection_color.b,
			bottom_alpha_value
		)
		var colors := PackedColorArray([
			top_color,
			top_color,
			bottom_color,
			bottom_color
		])

		draw_polygon(points, colors)

		var _success := points.append(rect_min) # Close the loop for the border
		var border_colors := PackedColorArray([
			selection_border_color, # Top left
			selection_border_color, # Top right
			selection_border_color,  # Bottom right
			selection_border_color,  # Bottom left
			selection_border_color  # Back to top left for closure
		])
		draw_polyline_colors(points, border_colors, 0.5, true)
