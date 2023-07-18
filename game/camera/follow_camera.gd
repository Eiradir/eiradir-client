extends Node

@export var enabled: bool = true

var camera: Camera2D
var target_id: String
var target_ref: WeakRef

func _ready():
	camera = get_parent()
	NetworkClient.CameraPositionReceived.connect(_camera_position_received)
	NetworkClient.CameraTargetReceived.connect(_camera_target_received)

func _process(_delta):
	if !enabled:
		return
	var target = target_ref.get_ref() if target_ref else null
	if !target && !target_id.is_empty():
		target = _set_camera_target(target_id)
	if target:
		camera.position = target.position

func _camera_position_received(_pos: Vector3i):
	target_id = ""
	target_ref = null

func _camera_target_received(entity_id: String):
	_set_camera_target(entity_id)

func _set_camera_target(entity_id: String):
	target_id = entity_id
	var entity = %EntityManager.get_node_or_null(entity_id)
	target_ref = weakref(entity)
	return entity
