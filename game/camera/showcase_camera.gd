extends Node

@export var enabled: bool = true
@export var move_speed: float = 100.0
@export var path_map_coordinates: Array[Vector2i] = [
	Vector2i(72, 77),
	Vector2i(113, 372),
	Vector2i(277, 589),
	Vector2i(163, 893),
	Vector2i(587, 742),
	Vector2i(510, 416),
	Vector2i(281, 78),
	Vector2i(422, 89),
	Vector2i(730, 131),
	Vector2i(938, 199),
	Vector2i(929, 430),
	Vector2i(995, 682),
	Vector2i(997, 862),
	Vector2i(984, 996),
]

var camera: Camera2D
var path_coordinates = []
var target_position_index = 0

func _ready():
	for map_pos in path_map_coordinates:
		path_coordinates.append(ChunkManager.map_to_global(map_pos))
	camera = get_parent()
	camera.position = path_coordinates[target_position_index]
	_set_new_target_position()
	NetworkClient.CameraTargetReceived.connect(_camera_target_received)
	
func _input(event: InputEvent):
	if FocusManager.keyboard_captured:
		return
	if event is InputEventKey:
		if event.pressed && event.keycode == KEY_F:
			enabled = !enabled

func _process(delta):
	if not enabled || Input.is_action_pressed("use"):
		return
	var global_transform = camera.global_transform
	var direction = (path_coordinates[target_position_index] - global_transform.origin).normalized()
	var new_position = global_transform.origin + direction * move_speed * delta
	camera.global_transform.origin = new_position

	if global_transform.origin.distance_to(path_coordinates[target_position_index]) < 100:
		_set_new_target_position()

func _set_new_target_position():
	target_position_index = (target_position_index + 1) % len(path_coordinates)

func _camera_target_received(_entity_id: String):
	enabled = false