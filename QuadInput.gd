@tool
class_name QuadInput extends MeshInstance3D

@onready var _viewport: SubViewport = $SubViewport
@onready var _area: Area3D = $Area3D

var _last_event_pos2D := Vector2()
var _last_event_time := -1.0

func _ready() -> void:
	_area.input_event.connect(_on_input_event)

func _on_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var mesh_size: Vector2 = mesh.size
	var event_pos3D := global_transform.affine_inverse() * event_position
	var event_pos2D := Vector2(event_pos3D.x, -event_pos3D.y) / mesh_size + Vector2(0.5, 0.5)
	event_pos2D *= Vector2(_viewport.size.x, _viewport.size.y)

	var current_time := Time.get_ticks_msec() / 1000.0

	event.position = event_pos2D
	if event is InputEventMouse:
		event.global_position = event_pos2D

	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		event.relative = event_pos2D - _last_event_pos2D
		var time_diff := current_time - _last_event_time
		event.velocity = event.relative / time_diff if time_diff > 0 else Vector2.ZERO

	_last_event_pos2D = event_pos2D
	_last_event_time = current_time
	_viewport.push_input(event)
